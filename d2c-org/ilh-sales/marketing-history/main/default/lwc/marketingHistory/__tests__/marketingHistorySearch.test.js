import { createElement } from 'lwc';
import MarketingHistory from 'c/marketingHistory';
import getMarketHistory from '@salesforce/apex/MarketingHistoryController.getMarketHistory';

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
        mailingDate: new Date(2024, 2, 3),
        offerDescription: 'Description 1',
        campaignProduct: 'product 1',
        channelCode: '1234',
        sourceId: '1234',
        creditUnion:'Credit union 1',
        contractNumber:'1234'
    },
    {        
        mailingDate: new Date(2024, 2, 1),
        offerDescription: 'Description 2',
        campaignProduct: 'product 2',
        channelCode: '5678',
        sourceId: '5678',
        creditUnion:'Credit union 2',
        contractNumber:'5678'
    },
];

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
        getMarketHistory.mockResolvedValue([]);
        // Arrange
        const element = createElement('c-marketing-history', {
            is: MarketingHistory
        });

        //Adding the marketing history search component to the page
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        //Getting the data table element from the marketing history search component
        let tableElement = element.shadowRoot.querySelector('lightning-datatable');
        let noResultsElement = element.shadowRoot.querySelector('[data-id=noResults]')

        expect(tableElement).toBeNull();//Table should not be accessible when there's no results
        await expect(noResultsElement).toBeAccessible();//Wait until results element renders, to check accessibility
        expect(getMarketHistory).toHaveBeenCalledTimes(1);//getMarketingHistory APEX is called only once
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
        let tableElement = element.shadowRoot.querySelector('lightning-datatable');
        
        expect(tableElement).toBeAccessible();//Table element is accessible
        expect(tableElement.data.length).toEqual(2);//There's 2 rows in the table
        expect(getMarketHistory).toHaveBeenCalledTimes(1);//getMarketingHistory APEX is called only once
    });

    it('Table is sorted corectly when loaded', async() => {
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
        let tableElement = element.shadowRoot.querySelector('lightning-datatable');
        
        expect(tableElement.sortedBy).toEqual('mailingDate');//Table is sorted by mailing date
        expect(tableElement.sortedDirection).toEqual('asc');//Table is sorted in descending order
        expect(tableElement.data[0].campaignProduct).toEqual(SEARCH_SUCCESS[1].campaignProduct);//First row should be equal to the second row in the search success
    });

    it('Table is sorted corectly when table column is selected', async() => {
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
        let tableElement = element.shadowRoot.querySelector('lightning-datatable');
        tableElement.dispatchEvent(new CustomEvent('sort', {detail: {fieldName: 'mailingDate', sortDirection: 'desc'}}));

        // Wait for any asynchronous DOM updates
        await flushPromises();
        let tableElementSorted = element.shadowRoot.querySelector('lightning-datatable');//Query datatable again to get sorted results
        expect(tableElementSorted.sortedDirection).toEqual('desc');//Table is sorted in ascending order
        expect(tableElementSorted.data[0].campaignProduct).toEqual(SEARCH_SUCCESS[0].campaignProduct);//First row should be equal to the second row in the search success
    });
});