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
const LIFE_RESULTS = require('./data/lifeResults.json');

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

    describe('General', () => {
        it('Error card should display if there\'s errors from APEX call', async () => {
            getRates.mockImplementationOnce(() => {throw new Error('An error occured while getting rates.');});

            // Arrange
            const element = createElement('c-rating-filter', {
                is: RatingFilter
            });

            element.productType = 'Life';
            element.coverage = 10000;

            document.body.appendChild(element);//Add rating filter to page

            await flushPromises();// Wait for any asynchronous DOM updates

            let errorCard = element.shadowRoot.querySelector('lightning-card[data-id=errorCard]');//Query error card
            expect(errorCard).not.toBeNull();//Error card should be accessible if there's errors
        });
    });

    describe('ADD', () => {
        it('ADD Results section should render when ADD product category is selected', async () => {
            let expectedBillingMethods = [];
            const expectedOptions = [//TODO: Why do we use eligible products value for label and value on checkboxes?
                {
                    label: ADD_RESULTS.eligibleProducts[0].value,
                    value: ADD_RESULTS.eligibleProducts[0].value,
                    checked: true
                },
                {
                    label: ADD_RESULTS.eligibleProducts[1].value,
                    value: ADD_RESULTS.eligibleProducts[1].value,
                    checked: true
                }
            ];

            for (const option of ADD_RESULTS.eligibleBillingOptions) {//Set expected billing methods
                let tempBillMethod = {
                    label: option.billingMethod,
                    value: option.billingMethod.replace(/\s/g, '')
                }
                expectedBillingMethods.push(tempBillMethod);
            }

            getRates.mockResolvedValue(ADD_RESULTS);//Mock ADD results from getRates APEX method
            // Arrange
            const element = createElement('c-rating-filter', {
                is: RatingFilter
            });

            element.productType = 'ADD';//Set productType api property to ADD

            document.body.appendChild(element);//Add rating filter to page

            await flushPromises();// Wait for any asynchronous DOM updates

            let addSection = element.shadowRoot.querySelector('div[data-id=addSection]');//Query ADD section
            let productCheckbox = addSection.querySelector('c-horizontal-checkbox-group');//Query checkbox group within ADD section
            let billingMethods = addSection.querySelector('lightning-combobox[data-id=billingMethod]');//Query Billing Method dropdown from ADD section

            await expect(addSection).toBeAccessible();//ADD section should be accessible
            expect(productCheckbox.label).toEqual('AD&D Eligible Products');//Title for ADD section should equal AD&D Eligible Products
            expect(productCheckbox.options).toEqual(expectedOptions);//Checkboxes should be checked with correct options displayed
            expect(billingMethods.options).toEqual(expectedBillingMethods);//Billing method options should render correct options
        });

        it('Effective date should render when Billing Method is selected for ADD', async () => {
            getRates.mockResolvedValue(ADD_RESULTS);//Mock ADD results from getRates APEX method
            // Arrange
            const element = createElement('c-rating-filter', {
                is: RatingFilter
            });

            element.productType = 'ADD';//Set productType api property to ADD
            element.coverage = 30000;//Set coverage api property

            document.body.appendChild(element);//Add rating filter to page

            await flushPromises();// Wait for any asynchronous DOM updates

            let billingMethods = element.shadowRoot.querySelector('div[data-id=addSection] lightning-combobox[data-id=billingMethod]');//Query Billing Method dropdown from ADD section

            billingMethods.value = ADD_RESULTS.eligibleBillingOptions[0].billingMethod;//Update billing method value
            billingMethods.dispatchEvent(new CustomEvent('change', {detail: {value: billingMethods.value}}));//Billing method dropdown onClick

            await flushPromises();// Wait for any asynchronous DOM updates
            let effectiveDate = element.shadowRoot.querySelector('div[data-id=addSection] span[data-id=effectiveDate]');//Query effective date element
            expect(getRates).toHaveBeenCalledTimes(2);//The getRates APEX method should be called twice. Once when page loads and once when the billing method is changed.
            expect(effectiveDate.textContent).toEqual(ADD_RESULTS.eligibleBillingOptions[0].effectiveDate);//The text within the effective date element should equal effective date from first row of ADD_RESULTS
        });

        it('getRates APEX method should be called when Payment Frequency is changed for ADD', async () => {
            getRates.mockResolvedValue(ADD_RESULTS);//Mock ADD results from getRates APEX method
            // Arrange
            const element = createElement('c-rating-filter', {
                is: RatingFilter
            });

            element.productType = 'ADD';//Set productType api property to ADD
            element.coverage = 8000;//Set coverage api property

            document.body.appendChild(element);//Add rating filter to page

            await flushPromises();// Wait for any asynchronous DOM updates

            let frequency = element.shadowRoot.querySelector('div[data-id=addSection] lightning-combobox[data-id=frequency]');//Query frequency dropdown from ADD section

            frequency.value = 'Annual';//Update billing method value
            frequency.dispatchEvent(new CustomEvent('change', {detail: {value: frequency.value}}));//Frequency dropdown onChange

            await flushPromises();// Wait for any asynchronous DOM updates
            expect(getRates).toHaveBeenCalledTimes(2);//The getRates APEX method should be called twice.  Once when page loads and once when the frequency is changed.
        });

        it('Coverage should get updated when value is changed for ADD', async () => {
            getRates.mockResolvedValue(ADD_RESULTS);//Mock ADD results from getRates APEX method
            // Arrange
            const element = createElement('c-rating-filter', {
                is: RatingFilter
            });

            element.productType = 'ADD';//Set productType api property to ADD

            document.body.appendChild(element);//Add rating filter to page

            await flushPromises();// Wait for any asynchronous DOM updates

            let coverage = element.shadowRoot.querySelector('div[data-id=addSection] lightning-input[data-id=coverage]');//Query coverage input from ADD section
            coverage.value = '30000';//Update coverage amount
            coverage.dispatchEvent(new CustomEvent('blur'));//Coverage field onBlur

            await flushPromises();// Wait for any asynchronous DOM updates
            expect(element.coverage).toEqual(coverage.value);//Coverage should get updated
        });

        it('Coverage should get updated when Enter key is pressed on coverage field for ADD', async () => {
            getRates.mockResolvedValue(ADD_RESULTS);//Mock ADD results from getRates APEX method
            // Arrange
            const element = createElement('c-rating-filter', {
                is: RatingFilter
            });

            element.productType = 'ADD';//Set productType api property to ADD

            document.body.appendChild(element);//Add rating filter to page

            await flushPromises();// Wait for any asynchronous DOM updates

            let coverage = element.shadowRoot.querySelector('div[data-id=addSection] lightning-input[data-id=coverage]');//Query coverage input from ADD section
            coverage.value = '80000';//Update coverage amount

            coverage.dispatchEvent(new KeyboardEvent('keydown', {key: 'Enter'}));//Coverage field onKeyDown. Enter key is pressed

            await flushPromises();// Wait for any asynchronous DOM updates
            expect(element.coverage).toEqual(coverage.value);//Coverage should get updated
        });

        it('An error should display when coverage is invalid for ADD', async () => {
            getRates.mockResolvedValue(ADD_RESULTS);//Mock ADD results from getRates APEX method
            // Arrange
            const element = createElement('c-rating-filter', {
                is: RatingFilter
            });

            element.productType = 'ADD';//Set productType api property to ADD

            document.body.appendChild(element);//Add rating filter to page

            await flushPromises();// Wait for any asynchronous DOM updates

            let coverage = element.shadowRoot.querySelector('div[data-id=addSection] lightning-input[data-id=coverage]');//Query coverage input from ADD section
            coverage.value = 'abc';//Set invalid input
            coverage.dispatchEvent(new CustomEvent('blur'));//Coverage field onBlur

            await flushPromises();// Wait for any asynchronous DOM updates
            let coverageError = element.shadowRoot.querySelector('div[data-id=addSection] div[data-id=coverageError]');//Query coverage error element from ADD section
            expect(coverageError.textContent).toEqual('Coverage must be a number');//Coverage error element should get populated with text
        });
    });
    describe('Life', () => {
        it('Life Results section should render when life product category is selected', async () => {
            let expectedBillingMethods = [];
            const expectedOptions = [//TODO: Why do we use eligible products value for label and value on checkboxes?
                {
                    label: LIFE_RESULTS.eligibleProducts[0].value,
                    value: LIFE_RESULTS.eligibleProducts[0].value,
                    checked: true
                },
                {
                    label: LIFE_RESULTS.eligibleProducts[1].value,
                    value: LIFE_RESULTS.eligibleProducts[1].value,
                    checked: true
                }
            ];

            for (const option of LIFE_RESULTS.eligibleBillingOptions) {//Set expected billing methods
                let tempBillMethod = {
                    label: option.billingMethod,
                    value: option.billingMethod.replace(/\s/g, '')
                }
                expectedBillingMethods.push(tempBillMethod);
            }

            getRates.mockResolvedValue(LIFE_RESULTS);//Mock life results from getRates APEX method
            // Arrange
            const element = createElement('c-rating-filter', {
                is: RatingFilter
            });

            element.productType = 'Life';//Set productType api property to Life

            document.body.appendChild(element);//Add rating filter to page

            await flushPromises();// Wait for any asynchronous DOM updates

            let lifeSection = element.shadowRoot.querySelector('div[data-id=lifeSection]');//Query life section
            let productCheckbox = lifeSection.querySelector('c-horizontal-checkbox-group');//Query checkbox group within life section
            let billingMethods = lifeSection.querySelector('lightning-combobox[data-id=billingMethod]');//Query Billing Method dropdown from life section

            await expect(lifeSection).toBeAccessible();//Life section should be accessible
            expect(productCheckbox.label).toEqual('Life Eligible Products');//Title for Life section should equal Life Eligible Products
            expect(productCheckbox.options).toEqual(expectedOptions);//Checkboxes should be checked with correct options displayed
            expect(billingMethods.options).toEqual(expectedBillingMethods);//Billing method options should render correct options
        });

        it('getRates APEX method should be called when Payment Frequency is changed for Life', async () => {
            getRates.mockResolvedValue(LIFE_RESULTS);//Mock Life results from getRates APEX method
            // Arrange
            const element = createElement('c-rating-filter', {
                is: RatingFilter
            });

            element.productType = 'Life';//Set productType api property to life
            element.coverage = 8000;//Set coverage api property

            document.body.appendChild(element);//Add rating filter to page

            await flushPromises();// Wait for any asynchronous DOM updates

            let frequency = element.shadowRoot.querySelector('div[data-id=lifeSection] lightning-combobox[data-id=frequency]');//Query frequency dropdown from Life section

            frequency.value = 'Annual';//Update billing method value
            frequency.dispatchEvent(new CustomEvent('change', {detail: {value: frequency.value}}));//Frequency dropdown onChange

            await flushPromises();// Wait for any asynchronous DOM updates
            expect(getRates).toHaveBeenCalledTimes(2);//The getRates APEX method should be called twice.  Once when page loads and once when the frequency is changed.
        });

        it('Coverage should get updated when value is changed for Life', async () => {
            getRates.mockResolvedValue(LIFE_RESULTS);//Mock Life results from getRates APEX method
            // Arrange
            const element = createElement('c-rating-filter', {
                is: RatingFilter
            });

            element.productType = 'Life';//Set productType api property to Life

            document.body.appendChild(element);//Add rating filter to page

            await flushPromises();// Wait for any asynchronous DOM updates

            let coverage = element.shadowRoot.querySelector('div[data-id=lifeSection] lightning-input[data-id=coverage]');//Query coverage input from Life section
            coverage.value = '30000';//Update coverage amount
            coverage.dispatchEvent(new CustomEvent('blur'));//Coverage field onBlur

            await flushPromises();// Wait for any asynchronous DOM updates
            expect(element.coverage).toEqual(coverage.value);//Coverage should get updated
        });

        it('Coverage should get updated when Enter key is pressed on coverage field for Life', async () => {
            getRates.mockResolvedValue(LIFE_RESULTS);//Mock Life results from getRates APEX method
            // Arrange
            const element = createElement('c-rating-filter', {
                is: RatingFilter
            });

            element.productType = 'Life';//Set productType api property to Life

            document.body.appendChild(element);//Add rating filter to page

            await flushPromises();// Wait for any asynchronous DOM updates

            let coverage = element.shadowRoot.querySelector('div[data-id=lifeSection] lightning-input[data-id=coverage]');//Query coverage input from Life section
            coverage.value = '80000';//Update coverage amount

            coverage.dispatchEvent(new KeyboardEvent('keydown', {key: 'Enter'}));//Coverage field onKeyDown. Enter key is pressed

            await flushPromises();// Wait for any asynchronous DOM updates
            expect(element.coverage).toEqual(coverage.value);//Coverage should get updated
        });

        it('An error should display when coverage is invalid for Life', async () => {
            getRates.mockResolvedValue(LIFE_RESULTS);//Mock Life results from getRates APEX method
            // Arrange
            const element = createElement('c-rating-filter', {
                is: RatingFilter
            });

            element.productType = 'Life';//Set productType api property to Life

            document.body.appendChild(element);//Add rating filter to page

            await flushPromises();// Wait for any asynchronous DOM updates

            let coverage = element.shadowRoot.querySelector('div[data-id=lifeSection] lightning-input[data-id=coverage]');//Query coverage input from Life section
            coverage.value = 'abc';//Set invalid input
            coverage.dispatchEvent(new CustomEvent('blur'));//Coverage field onBlur

            await flushPromises();// Wait for any asynchronous DOM updates
            let coverageError = element.shadowRoot.querySelector('div[data-id=lifeSection] div[data-id=coverageError]');//Query coverage error element from Life section
            expect(coverageError.textContent).toEqual('Coverage must be a number');//Coverage error element should get populated with text
        });
    });
});