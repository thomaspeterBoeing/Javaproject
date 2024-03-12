import { createElement } from 'lwc';
import RatingMatrix from 'c/ratingMatrix';

const PRODUCT_DATA = ['ADD Single Contrib', 'ADD Family Contrib', 'ADD Basic'];
const FREQUENCY = 'monthly';
const RATE_DATA = require('./data/rates.json');

describe('c-rating-matrix', () => {
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

    it('Table should build correctly', async () => {
        const EVENT_VALUE = {//Value of event to be sent when cell is selected
            annual: 18,
            coverage: 10000,
            monthly: 1.5,
            productcode: "2018 ADD Family Contrib",
            productlabel: "ADD Family Contrib",
            quarterly: 4.5,
            semiannual: 9
        };

        const EXPECTED_COLUMNS = [//Set expected columns
            { 
                label: 'Coverage', 
                fieldName: 'coverage', 
                type: 'currency', 
                cellAttributes: { alignment: 'left' } 
            },
            {
                label: PRODUCT_DATA[0],
                type: 'cellselector',
                typeAttributes: {
                    value: { fieldName: PRODUCT_DATA[0] },
                    labelkey: FREQUENCY,
                    labeltype: "currency",
                    checkedvariant: "brand-outline",
                    uncheckedvariant: "base",
                    checkedicon: "action:approval",
                    uncheckedicon: "",
                    lockwhenselected: true,
                    cellallignment: "left"
                }
            },
            {
                label: PRODUCT_DATA[1],
                type: 'cellselector',
                typeAttributes: {
                    value: { fieldName: PRODUCT_DATA[1] },
                    labelkey: FREQUENCY,
                    labeltype: "currency",
                    checkedvariant: "brand-outline",
                    uncheckedvariant: "base",
                    checkedicon: "action:approval",
                    uncheckedicon: "",
                    lockwhenselected: true,
                    cellallignment: "left"
                }
            },
            {
                label: PRODUCT_DATA[2],
                type: 'cellselector',
                typeAttributes: {
                    value: { fieldName: PRODUCT_DATA[2] },
                    labelkey: FREQUENCY,
                    labeltype: "currency",
                    checkedvariant: "brand-outline",
                    uncheckedvariant: "base",
                    checkedicon: "action:approval",
                    uncheckedicon: "",
                    lockwhenselected: true,
                    cellallignment: "left"
                }
            }
        ];

        const element = createElement('c-rating-matrix', {//Create matrix component
            is: RatingMatrix
        });

        document.body.appendChild(element);//Add matrix component to page

        element.buildTable(RATE_DATA, PRODUCT_DATA, FREQUENCY);//Call buildTable method from matrix component

        await flushPromises();// Wait for any asynchronous DOM updates

        let dataTypes = element.shadowRoot.querySelector('c-ilh-sales-custom-data-types');//Query data types component
        expect(dataTypes.columns).toEqual(EXPECTED_COLUMNS);//Data types column should match expected columns
        expect(dataTypes.data).toEqual(RATE_DATA);//Data types data should match rate data
        dataTypes.dispatchEvent(//Mock cell selection
            new CustomEvent('cellselect', {
                detail: { value: EVENT_VALUE},
                bubbles: true
            })
        );
    });

    it('Table should not have any columns if there\'s no products passed in', async () => {
        const element = createElement('c-rating-matrix', {//Create matrix component
            is: RatingMatrix
        });

        document.body.appendChild(element);//Add matrix component to page

        element.buildTable(RATE_DATA, null, FREQUENCY);//Call buildTable method from matrix component

        await flushPromises();// Wait for any asynchronous DOM updates

        let dataTypes = element.shadowRoot.querySelector('c-ilh-sales-custom-data-types');//Query data types component
        expect(dataTypes.columns).toBeNull;//Columns should be null since there was no products passed to buildTable method
    });
});