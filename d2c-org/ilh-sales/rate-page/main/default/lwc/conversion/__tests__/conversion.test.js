import { createElement } from 'lwc';
import Conversion from 'c/conversion';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import checkEligibility from '@salesforce/apex/ConversionEligibleQuoteController.checkEligibility';
import getRates from '@salesforce/apex/ConversionEligibleQuoteController.getRates';
import CONSUMERCHECK from '@salesforce/label/c.ConsumerCheck';
import SPECIALHANDLING from '@salesforce/label/c.SpecialHandling';
import ADBORWAIVERRIDER from '@salesforce/label/c.ADBorWaiverRider';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';

// Mocking imperative Apex method call
jest.mock(
    '@salesforce/apex/ConversionEligibleQuoteController.checkEligibility',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

// Mocking imperative Apex method call
jest.mock(
    '@salesforce/apex/ConversionEligibleQuoteController.getRates',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

const CHECK_ELIGIBILITY_RESPONSE = require('./data/eligibilityResponse.json');
const GET_RATES_RESPONSE = require('./data/getRatesResponse.json');
const NON_ELIGIBLE_RESPONSE = require('./data/nonEligibleResponse.json');
const SPECIAL_HANDLING_RESPONSE = require('./data/eligibilityspecialhandling.json');
const MOCK_GET_RECORD = require('./data/mockGetRecord.json');
const POLICY_NUMBER_REQUIRED = 'Policy Number is required!';
const NOT_QUOTABLE_MESSAGE = 'Not Quotable';
const SPECIALHANDLING_MESSAGE ='Not Eligible for Quoting'
const BAD_INPUT_MESSAGE = 'Bad Input';
//const CONSUMERCHECK ='not the customer';
const CONVERTING_COVERAGE_BLANK ='Enter a valid converting coverage amount ';
const GREATER_THAN_MAXCOVERAGE ='Coverage Amount cannot exceed the total coverage available 95,000'
const SHOWRATEMATRIX =false;
const POLICY_NOT_FOUND_MESSAGE = 'This policy/product is not found in the Conversion Eligibility Service';
const APEX_PARAMETERS = { 
    "conversionProductCode": "2022 Whole Life Conversion", 
    "currentTermCompanyCode": "12", 
    "currentTermPolicyNumber": "345", 
    "insuredResidentState": "WI", 
    "conversionCoverageAmount": null, 
    "isTermBeingKept": false, 
    "channel": "TELEM" 
};


describe('c-conversion', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    async function flushPromises() {
        return Promise.resolve();
    }

    it('Rates should display with eligible policy number', async () => {
        checkEligibility.mockResolvedValue(CHECK_ELIGIBILITY_RESPONSE)//Mock check eligibility results;
        getRates.mockResolvedValue(GET_RATES_RESPONSE);

        const element = createElement('c-conversion', {//Create conversion component
            is: Conversion
        });

        element.optyState = 'WI';//Initialize opptyState property on conversion component

        document.body.appendChild(element);//Add conversion component to page

        getRecord.emit(MOCK_GET_RECORD);

        let personIdProvider = element.shadowRoot.querySelector('c-person-id-provider-l-w-c');
        personIdProvider.dispatchEvent(new CustomEvent('personidloaded', { detail: { Account: {Gender__pc: 'Male'}}}));

        let eligibleSection = element.shadowRoot.querySelector('div[data-id=eligibleSection]');//Query Eligibilty section
        expect(eligibleSection).toBeNull();//Expect eligibility section to be null when page is loaded 

        let matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query Matrix
        expect(matrix).toBeNull();//Matrix should be null when the page is loaded

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = '12345';//Set the value of the policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number onChange event

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');//Query check eligibility button
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));//Elgibility button onClick

        await flushPromises();// Wait for any asynchronous DOM updates

        matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query Matrix
        expect(matrix).toBeNull();//Matrix should still be null after click the eligibility button

        let coverage = element.shadowRoot.querySelector('lightning-input[data-id=coverage]');//Query coverage field
        coverage.value = '20000';//Assign a value to the coverage field
        coverage.dispatchEvent(new CustomEvent('change', { detail: { value: coverage.value } }));//Coverage field onChange event

        let getRate = element.shadowRoot.querySelector('lightning-button[data-id=getRate]');//Query Get Rate button
        getRate.dispatchEvent(new CustomEvent('click'));//Get Rate button onClick event
        expect(getRates).toHaveBeenCalled();//getRates APEX mehtod should have been called
        expect(getRates.mock.calls[0][0]).toEqual({ kvpRequestCriteria: APEX_PARAMETERS });//Parameters from mock call should match what is beign sent to getRates APEX method

        await flushPromises();// Wait for any asynchronous DOM updates
        matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query matrix
        await expect(matrix).toBeAccessible();//Matrix should be accessible after clicking get rate button
    });

    it('Error should display when for bad input', async () => {
        checkEligibility.mockResolvedValue([{}]);//Throwing an error for checkEligibility APEX method

        const element = createElement('c-conversion', {//Create conversion component
            is: Conversion
        });

        document.body.appendChild(element);//Add conversion component to page

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = 'aaa';//Assign a value to the policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number field onChange event

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');//Query check eligibility button
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));//Check Eligibility button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates
        let messageDisplay = element.shadowRoot.querySelector('div[data-id=messageDisplay]');//Query message display element
        let eligibleSection = element.shadowRoot.querySelector('div[data-id=eligibleSection]');//Query eligibility section
        let matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query Matrix
        expect(matrix).toBeNull();//Matrix should be null when there's errors on the page
        expect(messageDisplay).not.toBeNull();//Message display should not be null
        expect(messageDisplay.textContent).toEqual(POLICY_NOT_FOUND_MESSAGE);//Text in message display should match
        expect(eligibleSection).toBeNull();//Eligility section should be null because there's errors
    });

    
    it('Error should display when we get an error description from repsonse', async () => {
        checkEligibility.mockResolvedValue(NON_ELIGIBLE_RESPONSE);//Mock response for checkEligibility APEX method

        // Arrange
        const element = createElement('c-conversion', {//Create conversion component
            is: Conversion
        });

        document.body.appendChild(element);//Add conversion component to page

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = 'aaa';//Assign a value to the policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number field onChange

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');//Query check eligility button
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));//Check eligibility button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates
        let messageDisplay = element.shadowRoot.querySelector('div[data-id=messageDisplay]');//Query message display element
        let eligibleSection = element.shadowRoot.querySelector('div[data-id=eligibleSection]');//Query eligibility section
        let matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query Matrix
        expect(matrix).toBeNull();//Matrix should be null when there's errors on the page
        expect(messageDisplay).not.toBeNull();//Message display should not be null
        expect(messageDisplay.textContent).toEqual(NOT_QUOTABLE_MESSAGE);//Text in message display should match
        expect(eligibleSection).toBeNull();//Eligility section should be null because there's errors
    });

    it('Eligible section and matrix should not display after policy number is changed', async () => {
        checkEligibility.mockResolvedValue(CHECK_ELIGIBILITY_RESPONSE);//Mock response for checkEligibility APEX method
        getRates.mockResolvedValue(GET_RATES_RESPONSE);//Mock response for getRates APEX method

        const element = createElement('c-conversion', {//Create conversion component
            is: Conversion
        });

        document.body.appendChild(element);//Add conversion component to page

        getRecord.emit(MOCK_GET_RECORD);

        let personIdProvider = element.shadowRoot.querySelector('c-person-id-provider-l-w-c');
        personIdProvider.dispatchEvent(new CustomEvent('personidloaded', { detail: { Account: {Gender__pc: 'Male'}}}));

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = '12345';//Assign a value to the policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number field onChange

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');//Query check eligility button
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));//Check eligibility button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates

        let eligibleSection = element.shadowRoot.querySelector('div[data-id=eligibleSection]');//Query elgibility section
        expect(eligibleSection).not.toBeNull();//Eligibility should not be null after click check eligility button

        let coverage = element.shadowRoot.querySelector('lightning-input[data-id=coverage]');//Query coverage field
        coverage.value = '20000';//Assign value to coverage field
        coverage.dispatchEvent(new CustomEvent('change', { detail: { value: coverage.value } }));//Coverage field onChange event

        let getRate = element.shadowRoot.querySelector('lightning-button[data-id=getRate]');//Query Get Rate button
        getRate.dispatchEvent(new CustomEvent('click'));//Get Rate button onClick event
        expect(getRates).toHaveBeenCalled();//getRates APEX method should have been called

        await flushPromises();// Wait for any asynchronous DOM updates
        let matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query matrix component
        await expect(matrix).toBeAccessible();//Matrix component should be accessible after click Get Rate

        element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = '12345';//Assign value to policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number field onChange event

        await flushPromises();// Wait for any asynchronous DOM updates
        matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query matrix component
        expect(matrix).toBeNull();//Matrix component should be null after policy number is changed

        eligibleSection = element.shadowRoot.querySelector('div[data-id=eligibleSection]');//Query eligility section
        expect(eligibleSection).toBeNull();//Eligility section should be null after policy number is changed
    });

    it('Error should display when convertingcoverageAmount is null on handleGetRate', async () => {
        checkEligibility.mockResolvedValue(CHECK_ELIGIBILITY_RESPONSE)//Mock check eligibility results;
        getRates.mockResolvedValue(GET_RATES_RESPONSE);

        const element = createElement('c-conversion', {//Create conversion component
            is: Conversion
        });

        element.optyState = 'WI';//Initialize opptyState property on conversion component

        document.body.appendChild(element);//Add conversion component to page

        getRecord.emit(MOCK_GET_RECORD);

        let personIdProvider = element.shadowRoot.querySelector('c-person-id-provider-l-w-c');
        personIdProvider.dispatchEvent(new CustomEvent('personidloaded', { detail: { Account: {Gender__pc: 'Male'}}}));

        let eligibleSection = element.shadowRoot.querySelector('div[data-id=eligibleSection]');//Query Eligibilty section
        expect(eligibleSection).toBeNull();//Expect eligibility section to be null when page is loaded 

        let matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query Matrix
        expect(matrix).toBeNull();//Matrix should be null when the page is loaded

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = '12345';//Set the value of the policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number onChange event

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');//Query check eligibility button
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));//Elgibility button onClick

        await flushPromises();// Wait for any asynchronous DOM updates

        matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query Matrix
        expect(matrix).toBeNull();//Matrix should still be null after click the eligibility button

        let coverage = element.shadowRoot.querySelector('lightning-input[data-id=coverage]');//Query coverage field
        coverage.value = '';//Assign a value to the coverage field
        coverage.dispatchEvent(new CustomEvent('change', { detail: { value: coverage.value } }));//Coverage field onChange event

        let getRate = element.shadowRoot.querySelector('lightning-button[data-id=getRate]');//Query Get Rate button
        getRate.dispatchEvent(new CustomEvent('click'));//Get Rate button onClick event
        
        await flushPromises();// Wait for any asynchronous DOM updates

        let rateErrorMessage = element.shadowRoot.querySelector('div[data-id=messageDisplayRate]');//Query messageDisplayRate
        expect(rateErrorMessage.textContent).toEqual(CONVERTING_COVERAGE_BLANK);

    });

    it('Matrix should not display after coverage is changed', async () => {
        checkEligibility.mockResolvedValue(CHECK_ELIGIBILITY_RESPONSE);//Mock response for checkEligibility APEX method
        getRates.mockResolvedValue(GET_RATES_RESPONSE);//Mock response for getRates APEX method

        const element = createElement('c-conversion', {//Create conversion component
            is: Conversion
        });

        document.body.appendChild(element);//Add conversion component to page

        getRecord.emit(MOCK_GET_RECORD);

        let personIdProvider = element.shadowRoot.querySelector('c-person-id-provider-l-w-c');
        personIdProvider.dispatchEvent(new CustomEvent('personidloaded', { detail: { Account: {Gender__pc: 'Male'}}}));

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = '12345';//Assign a value to the policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number field onChange

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');//Query check eligility button
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));//Check eligibility button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates

        let coverage = element.shadowRoot.querySelector('lightning-input[data-id=coverage]');//Query coverage field
        coverage.value = '20000';//Assign value to coverage field
        coverage.dispatchEvent(new CustomEvent('change', { detail: { value: coverage.value } }));//Coverage field onChange event

        let getRate = element.shadowRoot.querySelector('lightning-button[data-id=getRate]');//Query Get Rate button
        getRate.dispatchEvent(new CustomEvent('click'));//Get Rate button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates
        let matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query matrix component
        await expect(matrix).toBeAccessible();//Matrix component should be accessible after click Get Rate

        coverage = element.shadowRoot.querySelector('lightning-input[data-id=coverage]');//Query coverage field
        coverage.value = '30000';//Assign value to coverage field
        coverage.dispatchEvent(new CustomEvent('change', { detail: { value: coverage.value } }));//Coverage field onChange event

        await flushPromises();// Wait for any asynchronous DOM updates
        matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query matrix component
        expect(matrix).toBeNull();//Matrix component should be null after policy number is changed
    });

    it('Matrix should not display after payment frequency is changed', async () => {
        checkEligibility.mockResolvedValue(CHECK_ELIGIBILITY_RESPONSE);//Mock response for checkEligibility APEX method
        getRates.mockResolvedValue(GET_RATES_RESPONSE);//Mock response for getRates APEX method

        const element = createElement('c-conversion', {//Create conversion component
            is: Conversion
        });

        document.body.appendChild(element);//Add conversion component to page

        getRecord.emit(MOCK_GET_RECORD);

        let personIdProvider = element.shadowRoot.querySelector('c-person-id-provider-l-w-c');
        personIdProvider.dispatchEvent(new CustomEvent('personidloaded', { detail: { Account: {Gender__pc: 'Male'}}}));

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = '12345';//Assign a value to the policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number field onChange

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');//Query check eligility button
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));//Check eligibility button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates

        let coverage = element.shadowRoot.querySelector('lightning-input[data-id=coverage]');//Query coverage field
        coverage.value = '20000';//Assign value to coverage field
        coverage.dispatchEvent(new CustomEvent('change', { detail: { value: coverage.value } }));//Coverage field onChange event

        let getRate = element.shadowRoot.querySelector('lightning-button[data-id=getRate]');//Query Get Rate button
        getRate.dispatchEvent(new CustomEvent('click'));//Get Rate button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates
        let matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query matrix component
        await expect(matrix).toBeAccessible();//Matrix component should be accessible after click Get Rate

        let payFrequency = element.shadowRoot.querySelector('lightning-combobox[data-id=payFrequency]');//Query pay frequency field
        payFrequency.value = 'annual';//Assign value to pay frequency field
        payFrequency.dispatchEvent(new CustomEvent('change', { detail: { value: payFrequency.value } }));//Pay frequency field onChange event

        await flushPromises();// Wait for any asynchronous DOM updates
        matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query matrix component
        expect(matrix).toBeNull();//Matrix component should be null after policy number is changed
    });

    it('Matrix should not display after payment method is changed', async () => {
        checkEligibility.mockResolvedValue(CHECK_ELIGIBILITY_RESPONSE);//Mock response for checkEligibility APEX method
        getRates.mockResolvedValue(GET_RATES_RESPONSE);//Mock response for getRates APEX method

        const element = createElement('c-conversion', {//Create conversion component
            is: Conversion
        });

        document.body.appendChild(element);//Add conversion component to page

        getRecord.emit(MOCK_GET_RECORD);

        let personIdProvider = element.shadowRoot.querySelector('c-person-id-provider-l-w-c');
        personIdProvider.dispatchEvent(new CustomEvent('personidloaded', { detail: { Account: {Gender__pc: 'Male'}}}));

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = '12345';//Assign a value to the policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number field onChange

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');//Query check eligility button
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));//Check eligibility button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates

        let coverage = element.shadowRoot.querySelector('lightning-input[data-id=coverage]');//Query coverage field
        coverage.value = '20000';//Assign value to coverage field
        coverage.dispatchEvent(new CustomEvent('change', { detail: { value: coverage.value } }));//Coverage field onChange event

        let getRate = element.shadowRoot.querySelector('lightning-button[data-id=getRate]');//Query Get Rate button
        getRate.dispatchEvent(new CustomEvent('click'));//Get Rate button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates
        let matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query matrix component
        await expect(matrix).toBeAccessible();//Matrix component should be accessible after click Get Rate

        let payMethod = element.shadowRoot.querySelector('lightning-combobox[data-id=payFrequency]');//Query Payment Method  field
        payMethod.value = 'ACH';//Assign value to pay frequency field
        payMethod.dispatchEvent(new CustomEvent('change', { detail: { value: payMethod.value } }));//Payment Method field onChange event

        await flushPromises();// Wait for any asynchronous DOM updates
        matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query matrix component
        expect(matrix).toBeNull();//Matrix component should be null after payMethod is changed
        let showMatrix =element.shadowRoot.querySelector('div[data-id=showRateMatrix'); // coverage does not seem to improve, so tried this and still no change.
        expect(showMatrix).toBeFalsy();
    });


    it('Matrix should not display after Cancel/Continue Term is changed', async () => {
        checkEligibility.mockResolvedValue(CHECK_ELIGIBILITY_RESPONSE);//Mock response for checkEligibility APEX method
        getRates.mockResolvedValue(GET_RATES_RESPONSE);//Mock response for getRates APEX method

        const element = createElement('c-conversion', {//Create conversion component
            is: Conversion
        });

        document.body.appendChild(element);//Add conversion component to page

        getRecord.emit(MOCK_GET_RECORD);

        let personIdProvider = element.shadowRoot.querySelector('c-person-id-provider-l-w-c');
        personIdProvider.dispatchEvent(new CustomEvent('personidloaded', { detail: { Account: {Gender__pc: 'Male'}}}));

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = '12345';//Assign a value to the policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number field onChange

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');//Query check eligility button
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));//Check eligibility button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates

        let coverage = element.shadowRoot.querySelector('lightning-input[data-id=coverage]');//Query coverage field
        coverage.value = '20000';//Assign value to coverage field
        coverage.dispatchEvent(new CustomEvent('change', { detail: { value: coverage.value } }));//Coverage field onChange event

        let getRate = element.shadowRoot.querySelector('lightning-button[data-id=getRate]');//Query Get Rate button
        getRate.dispatchEvent(new CustomEvent('click'));//Get Rate button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates
        let matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query matrix component
        await expect(matrix).toBeAccessible();//Matrix component should be accessible after click Get Rate

        let cancelContinue = element.shadowRoot.querySelector('lightning-radio-group[data-id=cancelContinue]');//Query Cancel/Continue term field
        cancelContinue.value = 'continue';//Assign value to Cancel/Continue term  field
        cancelContinue.dispatchEvent(new CustomEvent('change', { detail: { value: cancelContinue.value } }));//Cancel/Continue term field onChange event

        await flushPromises();// Wait for any asynchronous DOM updates
        matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query matrix component
        expect(matrix).toBeNull();//Matrix component should be null after policy number is changed
    });

    it('Coverage Amount exceeded message shoud display when converting coverage amount is > maxcoverageAmount', async () => {
        checkEligibility.mockResolvedValue(CHECK_ELIGIBILITY_RESPONSE);//Mock response for checkEligibility APEX method
        getRates.mockResolvedValue(GET_RATES_RESPONSE);//Mock response for getRates APEX method

        const element = createElement('c-conversion', {//Create conversion component
            is: Conversion
        });

        document.body.appendChild(element);//Add conversion component to page

        getRecord.emit(MOCK_GET_RECORD);

        let personIdProvider = element.shadowRoot.querySelector('c-person-id-provider-l-w-c');
        personIdProvider.dispatchEvent(new CustomEvent('personidloaded', { detail: { Account: {Gender__pc: 'Male'}}}));

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = '12345';//Assign a value to the policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number field onChange

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');//Query check eligility button
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));//Check eligibility button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates

        let coverage = element.shadowRoot.querySelector('lightning-input[data-id=coverage]');//Query coverage field
        coverage.value = '200000';//Assign value to coverage field
        coverage.dispatchEvent(new CustomEvent('change', { detail: { value: coverage.value } }));//Coverage field onChange event
               
        let cancelContinue = element.shadowRoot.querySelector('lightning-radio-group[data-id=cancelContinue]');//Query Cancel/Continue term field
        cancelContinue.value = 'continue';//Assign value to Cancel/Continue term  field
        cancelContinue.dispatchEvent(new CustomEvent('change', { detail: { value: cancelContinue.value } }));//Cancel/Continue term field onChange event

        let getRate = element.shadowRoot.querySelector('lightning-button[data-id=getRate]');//Query Get Rate button
        getRate.dispatchEvent(new CustomEvent('click'));//Get Rate button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates
        
        let rateErrorMessage = element.shadowRoot.querySelector('div[data-id=messageDisplayRate]');//Query messageDisplayRate
        expect(rateErrorMessage.textContent).toEqual(GREATER_THAN_MAXCOVERAGE);

        /*let matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query matrix component
        await expect(matrix).toBeAccessible();//Matrix component should be accessible after click Get Rate

        /*let cancelContinue = element.shadowRoot.querySelector('lightning-radio-group[data-id=cancelContinue]');//Query Cancel/Continue term field
        cancelContinue.value = 'continue';//Assign value to Cancel/Continue term  field
        cancelContinue.dispatchEvent(new CustomEvent('change', { detail: { value: cancelContinue.value } }));//Cancel/Continue term field onChange event*/

       /* await flushPromises();// Wait for any asynchronous DOM updates
        matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query matrix component
        expect(matrix).toBeNull();//Matrix component should be null after policy number is changed*/
    });

    it('should hide section when adbWaiverRiderChecked is true', async () => {
        checkEligibility.mockResolvedValue(CHECK_ELIGIBILITY_RESPONSE);//Mock response for checkEligibility APEX method
        getRates.mockResolvedValue(GET_RATES_RESPONSE);//Mock response for getRates APEX method

        const element = createElement('c-conversion', {//Create conversion component
            is: Conversion
        });

        document.body.appendChild(element);//Add conversion component to page

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = '12345';//Assign a value to the policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number field onChange

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');//Query check eligility button
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));//Check eligibility button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates
        
        let ADBWaiverChecked = element.shadowRoot.querySelector('input[data-id=adbwaivercheckbox]');
        ADBWaiverChecked.checked =true;
        ADBWaiverChecked.dispatchEvent(new CustomEvent('change',{detail: {value:ADBWaiverChecked.checked}}));

        await flushPromises();// Wait for any asynchronous DOM updates

        // Query subsequent sections
        let subsequentSections = element.shadowRoot.querySelector('lightning-input[data-id=coverage]');

        // Expect subsequent sections to be hidden
        expect(subsequentSections).toBeNull();

    });
    it('should show section when adbWaiverRiderChecked is false', async () => {
        checkEligibility.mockResolvedValue(CHECK_ELIGIBILITY_RESPONSE);//Mock response for checkEligibility APEX method
        getRates.mockResolvedValue(GET_RATES_RESPONSE);//Mock response for getRates APEX method

        const element = createElement('c-conversion', {//Create conversion component
            is: Conversion
        });

        document.body.appendChild(element);//Add conversion component to page

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = '12345';//Assign a value to the policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number field onChange

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');//Query check eligility button
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));//Check eligibility button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates
        
        let ADBWaiverChecked = element.shadowRoot.querySelector('lightning-checkbox-toggle[data-id=adbwaivercheckbox]');
        ADBWaiverChecked.checked =false;
        ADBWaiverChecked.dispatchEvent(new CustomEvent('change',{detail: {value:ADBWaiverChecked.checked}}));

        await flushPromises();// Wait for any asynchronous DOM updates

        // Query subsequent sections
        let subsequentSections = element.shadowRoot.querySelector('lightning-input[data-id=coverage]');

        // Expect subsequent sections to be hidden
        expect(subsequentSections).toBeAccessible();

    });

    it('should show specialhandling message when specialhandling from service is O and Not Eligible for Quoting', async () => {
        checkEligibility.mockResolvedValue(SPECIAL_HANDLING_RESPONSE);//Mock response for checkEligibility APEX method
        //getRates.mockResolvedValue(GET_RATES_RESPONSE);//Mock response for getRates APEX method

        const element = createElement('c-conversion', {//Create conversion component
            is: Conversion
        });

        document.body.appendChild(element);//Add conversion component to page

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');//Query policy number field
        policyNumber.value = '12345';//Assign a value to the policy number field
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));//Policy number field onChange

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');//Query check eligility button
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));//Check eligibility button onClick event

        await flushPromises();// Wait for any asynchronous DOM updates
        
        let messageDisplay = element.shadowRoot.querySelector('div[data-id=messageDisplay]');//Query message display element
        let eligibleSection = element.shadowRoot.querySelector('div[data-id=eligibleSection]');//Query eligibility section
        let matrix = element.shadowRoot.querySelector('c-rating-matrix');//Query Matrix
        expect(matrix).toBeNull();//Matrix should be null when there's errors on the page
        expect(messageDisplay).not.toBeNull();//Message display should not be null
        expect(messageDisplay.textContent).toEqual("c.ConsumerCheck");//Text in message display should match //incorrect test
        expect(eligibleSection).toBeNull();//Eligility section should be null because there's errors

    });
  
 
});