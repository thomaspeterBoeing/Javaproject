import { createElement } from 'lwc';
import Conversion from 'c/conversion';
import checkEligibility from '@salesforce/apex/ConversionEligibleQuoteController.checkEligibility';
import getRates from '@salesforce/apex/ConversionEligibleQuoteController.getRates';

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

const CHECK_ELIGIBILITY = require('./data/eligibilityResponse.json');
const GET_RATES = require('./data/getRatesResponse.json');
const NON_ELIGIBLE_RESPONSE = require('./data/nonEligibleResponse.json');
const APEX_PARAMETERS = { "conversionProductCode": "2022 Whole Life Conversion", "currentTermCompanyCode": "12", "currentTermPolicyNumber": "345", "insuredResidentState": "WI", "conversionCoverageAmount": null, "isTermBeingKept": false, "channel": "TELEM" }


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
        checkEligibility.mockResolvedValue(CHECK_ELIGIBILITY);
        getRates.mockResolvedValue(GET_RATES);

        // Arrange
        const element = createElement('c-conversion', {
            is: Conversion
        });

        element.optyState = 'WI';

        // Act
        document.body.appendChild(element);

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');
        policyNumber.value = '12345';
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));

        await flushPromises();// Wait for any asynchronous DOM updates

        let coverage = element.shadowRoot.querySelector('lightning-input[data-id=coverage]');
        coverage.value = '20000';
        coverage.dispatchEvent(new CustomEvent('change', { detail: { value: coverage.value } }));

        let getRate = element.shadowRoot.querySelector('lightning-button[data-id=getRate]');
        getRate.dispatchEvent(new CustomEvent('click'));
        expect(getRates).toHaveBeenCalled();
        expect(getRates.mock.calls[0][0]).toEqual({ kvpRequestCriteria: APEX_PARAMETERS });

        await flushPromises();// Wait for any asynchronous DOM updates
        let matrix = element.shadowRoot.querySelector('c-rating-matrix');
        expect(matrix).toBeAccessible();
    });

    it('Error should display when for bad input', async () => {
        checkEligibility.mockRejectedValue(() => {throw new Error('Bad Input');});

        // Arrange
        const element = createElement('c-conversion', {
            is: Conversion
        });

        // Act
        document.body.appendChild(element);

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');
        policyNumber.value = 'aaa';
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));

        await flushPromises();// Wait for any asynchronous DOM updates
        let messageDisplay = element.shadowRoot.querySelector('div[data-id=messageDisplay]');
        let eligibleSection = element.shadowRoot.querySelector('div[data-id=eligibleSection]');
        expect(messageDisplay).not.toBeNull();
        expect(messageDisplay.textContent).toEqual('Policy not found');
        expect(eligibleSection).toBeNull();
    });

    it('Error should display when we get an error from repsonse', async () => {
        checkEligibility.mockResolvedValue(NON_ELIGIBLE_RESPONSE);

        // Arrange
        const element = createElement('c-conversion', {
            is: Conversion
        });

        // Act
        document.body.appendChild(element);

        let policyNumber = element.shadowRoot.querySelector('lightning-input[data-id=policyNumber]');
        policyNumber.value = 'aaa';
        policyNumber.dispatchEvent(new CustomEvent('change', { detail: { value: policyNumber.value } }));

        let checkEligilityBtn = element.shadowRoot.querySelector('lightning-button[data-id=checkEligilityBtn]');
        checkEligilityBtn.dispatchEvent(new CustomEvent('click'));

        await flushPromises();// Wait for any asynchronous DOM updates
        let messageDisplay = element.shadowRoot.querySelector('div[data-id=messageDisplay]');
        let eligibleSection = element.shadowRoot.querySelector('div[data-id=eligibleSection]');
        expect(messageDisplay).not.toBeNull();
        expect(messageDisplay.textContent).toEqual('Not Quotable');
        expect(eligibleSection).toBeNull();
    });
});