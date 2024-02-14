import { createElement } from 'lwc';
import IlhSalesCart from 'c/ilhSalesCart';
import getQuotes from '@salesforce/apex/ILHCartController.getQuotes';
import deleteQuote from '@salesforce/apex/ILHCartController.deleteQuote';
import insertQuote from '@salesforce/apex/ILHCartController.insertQuote';
import updateQuotes from '@salesforce/apex/ILHCartController.updateQuotes';
import checkout from '@salesforce/apex/ILHCartController.checkout';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import CART_CHANNEL from '@salesforce/messageChannel/Cart__c';

// Mocking imperative Apex method call
jest.mock(
    '@salesforce/apex/ILHCartController.getQuotes',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/ILHCartController.deleteQuote',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/ILHCartController.insertQuote',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/ILHCartController.updateQuotes',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/ILHCartController.checkout',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

const CART_ITEMS = require('./data/cartItems.json');

describe('c-ilh-sales-cart', () => {
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
    
    it('Saved quotes should get inserted into the cart when the component loads', async () => {
        //Create cart component
        const element = createElement('c-ilh-sales-cart', {
            is: IlhSalesCart
        });

        //Add cart component to page
        document.body.appendChild(element);

        //Quotes to add to table
        getQuotes.emit(CART_ITEMS);

        // Wait for any asynchronous DOM updates
        await flushPromises();
        // Mock handler for toast event
        const toastHandler = jest.fn();
        // Add event listener to catch toast event
        element.addEventListener(ShowToastEventName, toastHandler);

        // Wait for any asynchronous DOM updates
        await flushPromises();
        let tableRows = element.shadowRoot.querySelectorAll('tr[class=cartItem]'); //Query cart item rows
        let row1 = tableRows[0]; //Query second row
        let productNameCell = row1.querySelector('td');//Select first cell from row

        // Wait for any asynchronous DOM updates
        await flushPromises();
        expect(productNameCell.textContent).toEqual(CART_ITEMS[0].productName);//Cell value should equal the product name of the first row in CART_ITEMS
    });

    it('Item is added to cart when inserted', async () => {
        //Parameters for insertQuote method
        const APEX_PARAMETERS = {
            'productCode': 'TestProd',
            'paymentFrequency': 'Monthly',
            'billingMethod': 'ACH',
            'underwritingClassCode': undefined,
            'underwritingClass': undefined,
            'insuredAge': undefined,
            'coverage': '8000',
            'cost': '8.5',
            'action': undefined,
            'quoteId': undefined,
            'oppId': undefined
        };
        //Setting resolved values for APEX mehtods
        insertQuote.mockResolvedValue({});

        //Create cart component
        const element = createElement('c-ilh-sales-cart', {
            is: IlhSalesCart
        });

        //Add cart component to page
        document.body.appendChild(element);

        let payload = {
            productCode: 'TestProd',
            paymentFrequency: 'Monthly',
            billingMethod: 'ACH',
            coverage: 8000,
            cost: 8.5
        };
        publish(MessageContext, CART_CHANNEL, payload);

        // Wait for any asynchronous DOM updates
        await flushPromises();
        expect(insertQuote).toHaveBeenCalled(); //InsertQuote APEX method should be called when a new cart item is published to message channel
        expect(insertQuote.mock.calls[0][0]).toEqual({payload: APEX_PARAMETERS});//Parameter values for insertQuote method should be equal to APEX_PARAMETERS
    });

    it('Toast message is displayed when Paper Kit or Email Summary is selected', async () => {
        //Setting resolved values for APEX mehtods
        checkout.mockResolvedValue({});
        updateQuotes.mockResolvedValue({});

        //Create cart component
        const element = createElement('c-ilh-sales-cart', {
            is: IlhSalesCart
        });

        //Add cart component to page
        document.body.appendChild(element);

        //Quotes to add to table
        getQuotes.emit(CART_ITEMS);

        // Wait for any asynchronous DOM updates
        await flushPromises();
        // Mock handler for toast event
        const toastHandler = jest.fn();
        // Add event listener to catch toast event
        element.addEventListener(ShowToastEventName, toastHandler);

        // Wait for any asynchronous DOM updates
        await flushPromises();
        let tableRows = element.shadowRoot.querySelectorAll('tr[class=cartItem]'); //Query cart item rows
        let row2 = tableRows[1]; //Query second row
        let actionDropdown = row2.querySelector('td[data-id=actionCell] lightning-select'); //Query action dropdown from second row
        actionDropdown.value = 'Paper Kit'; //Updated the action dropdown to 'Paper Kit'
        actionDropdown.dispatchEvent(new CustomEvent('change')); //Action dropdown onChange

        let updateContinueBtn = element.shadowRoot.querySelector('[data-id=updateContinueBtn]'); //Select Update and Continue button
        updateContinueBtn.dispatchEvent(new CustomEvent('click')); //Clicking on the button

        // Wait for any asynchronous DOM updates
        await flushPromises();
        expect(checkout).toHaveBeenCalled();//Checkout APEX method should have been called
        expect(updateQuotes).toHaveBeenCalled();//UpdateQuotes APEX method should have been called
        expect(toastHandler).toHaveBeenCalled();//Toast message should have been called
        expect(toastHandler.mock.calls[0][0].detail.message).toEqual('Paper Kit requested');//Toast message should contain 'Paper Kit requested'
    });

    it('Item is removed from the cart when deleted', async () => {
        //Setting resolved values for APEX mehtods
        deleteQuote.mockResolvedValue({});

        //Create cart component
        const element = createElement('c-ilh-sales-cart', {
            is: IlhSalesCart
        });

        //Add cart component to page
        document.body.appendChild(element);

        //Quotes to add to table
        getQuotes.emit(CART_ITEMS);

        // Wait for any asynchronous DOM updates
        await flushPromises();
        let tableRows = element.shadowRoot.querySelectorAll('tr[class=cartItem]'); //Query cart item rows
        let secondRow = tableRows[1]; //Query second row
        let deleteBtn = secondRow.cells[3].querySelector('lightning-button-icon'); //Query delete button for second row
        deleteBtn.dispatchEvent(new CustomEvent('click')); //Delete button onClick

        // Wait for any asynchronous DOM updates
        await flushPromises();
        expect(deleteQuote).toHaveBeenCalledTimes(1); //DeleteQuote APEX method should be called once
        expect(deleteQuote.mock.calls[0][0]).toEqual({quoteId: CART_ITEMS[1].quoteId});//Quote id parameter for deleteQuote method, should be equal to the quoteId for the second row in CART_ITEMS
    });

    it('Elements are disabled when certain actions are selected', async () => {
        //Create cart component
        const element = createElement('c-ilh-sales-cart', {
            is: IlhSalesCart
        });

        //Add cart component to page
        document.body.appendChild(element);

        //Quotes to add to table
        getQuotes.emit(CART_ITEMS);

        // Wait for any asynchronous DOM updates
        await flushPromises();
        let tableRows = element.shadowRoot.querySelectorAll('tr[class=cartItem]'); //Query cart item rows
        let row1 = tableRows[0]; //Query first row
        let row1ActionDropdown = row1.querySelector('td[data-id=actionCell] lightning-select'); //Query action dropdown from first row
        let deleteBtn = row1.querySelector('td[data-id=actionCell] lightning-button-icon'); //Query delete button for first row
        expect(row1ActionDropdown.options[0].disabled).toEqual(true); //Blank option should be disable when Application is selected
        expect(row1ActionDropdown.options[2].disabled).toEqual(true); //Paper Kit option should be disable when Application is selected
        expect(row1ActionDropdown.options[3].disabled).toEqual(true); //Email Summary option should be disable when Application is selected
        expect(deleteBtn.disabled).toEqual(true); //Delete button should be disabled when Application is selected

        let row3 = tableRows[2]; //Query 3rd row
        let row3ActionDropdown = row3.querySelector('td[data-id=actionCell] lightning-select'); //Query action dropdown from 3rd row
        expect(row3ActionDropdown.options[0].disabled).toEqual(true); //Blank option should be disable when Paper Kit is selected
        expect(row3ActionDropdown.options[1].disabled).toEqual(false); //Application option should be available when Paper Kit is selected
        expect(row3ActionDropdown.options[3].disabled).toEqual(false); //Email Summary option should be available when Paper Kit is selected

        let row4 = tableRows[3]; //Query 4th row
        let row4ActionDropdown = row4.querySelector('td[data-id=actionCell] lightning-select'); //Query action dropdown from 4th row
        expect(row4ActionDropdown.options[0].disabled).toEqual(true); //Blank option should be disable when Email Summary is selected
        expect(row4ActionDropdown.options[1].disabled).toEqual(false); //Application option should be disable when Email Summary is selected
        expect(row4ActionDropdown.options[2].disabled).toEqual(false); //Paper Kit option should be available when Email Summary is selected
    });

    it('Items are updated when Update & Continue button is clicked', async () => {
        //Parameters for insertQuote method
        const APEX_PARAMETERS = [{
            'productCode': CART_ITEMS[1].productCode,
            'paymentFrequency': CART_ITEMS[1].paymentFrequency,
            'billingMethod': undefined,
            'underwritingClassCode': undefined,
            'underwritingClass': undefined,
            'insuredAge': undefined,
            'coverage': CART_ITEMS[1].coverage.toString(),
            'cost': CART_ITEMS[1].cost.toString(),
            'action': 'Application',
            'quoteId': CART_ITEMS[1].quoteId,
            'oppId': undefined
        }];

        //Setting resolved values for APEX mehtods
        updateQuotes.mockResolvedValue({});
        checkout.mockResolvedValue({});

        //Create cart component
        const element = createElement('c-ilh-sales-cart', {
            is: IlhSalesCart
        });

        //Add cart component to page
        document.body.appendChild(element);

        //Quotes to add to table
        getQuotes.emit(CART_ITEMS);

        // Wait for any asynchronous DOM updates
        await flushPromises();
        let tableRows = element.shadowRoot.querySelectorAll('tr[class=cartItem]'); //Query cart item rows
        let row2 = tableRows[1]; //Query second row
        let actionDropdown = row2.querySelector('td[data-id=actionCell] lightning-select'); //Query action dropdown from second row
        actionDropdown.value = 'Application'; //Updated the action dropdown to 'Application'
        actionDropdown.dispatchEvent(new CustomEvent('change')); //Action dropdown onChange

        let updateContinueBtn = element.shadowRoot.querySelector('[data-id=updateContinueBtn]'); //Select Update and Continue button
        updateContinueBtn.dispatchEvent(new CustomEvent('click')); //Clicking on the button

        // Wait for any asynchronous DOM updates
        await flushPromises();
        expect(checkout).toHaveBeenCalledTimes(1); //Checkout APEX method should be called once
        expect(updateQuotes).toHaveBeenCalledTimes(1); //UpdateQuotes APEX method should be called, since we updated an action
        expect(updateQuotes.mock.calls[0][0]).toEqual({quotes: APEX_PARAMETERS});//Quotes parameter on updateQuotes method, should be equal to APEX_PARAMETERS method

    });

    it('Update Quotes should not be called when there\'s no items to update in cart', async () => {
        //Setting resolved values for APEX mehtods
        getQuotes.mockResolvedValue([]);
        updateQuotes.mockResolvedValue({});
        checkout.mockResolvedValue({});

        //Create cart component
        const element = createElement('c-ilh-sales-cart', {
            is: IlhSalesCart
        });

        //Add cart component to page
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();
        let updateContinueBtn = element.shadowRoot.querySelector('[data-id=updateContinueBtn]'); //Select Update and Continue button
        updateContinueBtn.dispatchEvent(new CustomEvent('click')); //Clicking on the button

        // Wait for any asynchronous DOM updates
        await flushPromises();
        expect(checkout).toHaveBeenCalledTimes(1); //Checkout APEX mehtod should only be called once
        expect(updateQuotes).toHaveBeenCalledTimes(0); //UpdateQuotes APEX should not be call since there's no results on the page
    });
});
