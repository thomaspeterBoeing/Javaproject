import { createElement } from 'lwc';
import ILHSalesConsumerInfo from 'c/iLHSalesConsumerInfo';
import getOpportunityFieldsData from '@salesforce/apex/ConsumerInfoController.getOpportunityFieldsData';


// Mocking imperative Apex method call
jest.mock(
    '@salesforce/apex/ConsumerInfoController.getOpportunityFieldsData',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

const SUCCESS_RESULT = {
    "FirstName" : 'FirstTest'
};

const FAILED_RESULT = {};

describe('c-i-lh-sales-consumer-info', () => {
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

    it('Consumer info should display with successful result', async() => {
        getOpportunityFieldsData.mockResolvedValue(SUCCESS_RESULT);
        // Arrange
        const element = createElement('c-i-lh-sales-consumer-info', {
            is: ILHSalesConsumerInfo
        });

        // Act
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        //Getting the data table element from the policySumSearch search component
        let infoWrapper = element.shadowRoot.querySelector('div[data-id=dummyDiv]');
        let errorDisplay = element.shadowRoot.querySelector('div[data-id=errorDisplay]');

        expect(errorDisplay).toBeNull();
        expect(infoWrapper).not.toBeNull();
    });

    it('Error message should display with failed result', async() => {
        getOpportunityFieldsData.mockRejectedValue(FAILED_RESULT);
        // Arrange
        const element = createElement('c-i-lh-sales-consumer-info', {
            is: ILHSalesConsumerInfo
        });

        // Act
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        //Getting the data table element from the policySumSearch search component
        let infoWrapper = element.shadowRoot.querySelector('div[data-id=dummyDiv]');
        let errorDisplay = element.shadowRoot.querySelector('div[data-id=errorDisplay]');

        expect(errorDisplay).not.toBeNull();
        expect(infoWrapper).toBeNull();
    });
});