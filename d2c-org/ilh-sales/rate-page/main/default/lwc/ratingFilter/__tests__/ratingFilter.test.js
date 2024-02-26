import { createElement } from 'lwc';
import RatingFilter from 'c/ratingFilter';
import getRates from '@salesforce/apex/QuoteServiceController.getRates';

// Mocking imperative Apex method call
jest.mock(
    '@salesforce/apex/QuoteServiceController.getRates',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

const ADD_RESULTS = require('./data/addResults.json');

describe('c-rating-filter', () => {
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

    it('ADD Results section should render when ADD product category is selected', async () => {
        getRates.mockResolvedValue(ADD_RESULTS);
        // Arrange
        const element = createElement('c-rating-filter', {
            is: RatingFilter
        });

        element.productType = 'ADD';

        // Act
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        let addSection = element.shadowRoot.querySelector('div[data-id=addSection]'); //Query cart item rows
        await expect(addSection).toBeAccessible();
    });
});