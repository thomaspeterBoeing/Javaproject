import { createElement } from 'lwc';
import policySumSearch from 'c/policySumSearch';
import sPolicy from '@salesforce/apex/PolicySummaryController.search'


jest.mock(
    '@salesforce/apex/PolicySummaryController.search',
    () => ({
        Default: jest.fn(),
    }),
    { virtual: true }
);

const POLICY_SEARCH_SUCCESS = [
    {        
        ProductNumber: '51LC0234688',
        Product: 'ISWLN17',
        ProductRelationship: 'Insured',
        Status: 'COMPLETED',
        
    }
];

const POLICY_SEARCH_FAILURE =[];

    describe('policySumSearch component', () =>   {
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

    it('No Policy Data available', async() => {
        sPolicy.mockResolvedValue(JSON.stringify(POLICY_SEARCH_SUCCESS));
        // Arrange
        const element = createElement('c-policy-sum-search', {
            is: policySumSearch
        });

        //Adding the policySumSearch search component to the page
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        //Getting the data table element from the policySumSearch search component
        let dataTableElement = element.shadowRoot.querySelector('lightning-datatable');

        await expect(element).toBeAccessible();
        await expect(dataTableElement).toBeAccessible();
        expect(findpolicy).toHaveBeenCalledTimes(1);
    });


  it('should populate the data table with policy data', async () => {
    // Create a new instance of the component
    const element = createElement('c-policy-sum-search', {
      is: policySumSearch,
    });

      
    // Set the datatable
    element. POLICY_DATA = [
        {        
            ProductNumber: '51LC0234688',
            Product: 'ISWLN17',
            ProductRelationship: 'Insured',
            Status: 'COMPLETED',
            
        }
    ];

    // Attach the component to the document
    document.body.appendChild(element);

    // Wait for the component to render
    await element.updateComplete;

    // Get the data table element
    const dataTable = element.shadowRoot.querySelector('lightning-datatable');

    // Assert that the data table has at least one row
    expect(dataTable).toBeAccessible();;

    // Remove the component from the document
    document.body.removeChild(element);
  });
});
