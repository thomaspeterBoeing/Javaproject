import { createElement } from 'lwc';
import MarketingHistory from 'c/marketingHistory';
import getMarketHistory    from '@salesforce/apex/MarketingHistoryController.getMarketHistory';
import PersonId from '@salesforce/apex/PersonIDProviderController.getPersonId';

// Mocking imperative Apex method call
jest.mock(
    '@salesforce/apex/MarketingHistoryController.getMarketHistory',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

const SEARCH_SUCCESS = [
    {        
        personId: '123456',
        sourceId: '123456',
        source: 'Test Source',
        mailingDateStr: '2023-08-28T00:00:00Z',
        offerDescription:'Test Description',
        campaignProduct:'TEST',
        channelCode:'123456',
        creditUnion:'Test CU',
        contractNumber:'123456',
    }
];

const SEARCH_FAILURE = [];

describe('c-marketing-history', () => {
    beforeEach(() => {
        myMockedFunction = jest.fn(() => Promise.resolve());
    });
    
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

    it('Table should not display when there\'s no results', async() => {
        getMarketHistory.mockResolvedValue(SEARCH_FAILURE);
        // Arrange
        const element = createElement('c-marketing-history', {
            is: MarketingHistory
        });

        //Adding the marketing history search component to the page
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        //Getting the data table element from the marketing history search component
        let tableElement = element.shadowRoot.querySelector("[id^='dummyTable']");

        await expect(element).toBeAccessible();
        expect(tableElement).toBeNull();
        expect(getMarketHistory).toHaveBeenCalledTimes(1);
    });

    it('Table should display when there\'s results', async() => {
        //Creating a successful mock response for the getMarketHistory APEX method
        getMarketHistory.mockResolvedValue(SEARCH_SUCCESS);

        //Creating marketing history component
        const element = createElement('c-marketing-history', {
            is: MarketingHistory
        });

        //Adding the marketing history search component to the page
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        //Getting the data table element from the marketing history search component
        let tableElement = element.shadowRoot.querySelectorAll("[id^='dummyTable']");
        
        await expect(element).toBeAccessible();
        await expect(tableElement).toBeAccessible();
        expect(getMarketHistory).toHaveBeenCalledTimes(1);
    });
});