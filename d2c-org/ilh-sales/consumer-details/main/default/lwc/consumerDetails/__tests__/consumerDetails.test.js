import { createElement } from 'lwc';
import ConsumerDetails from 'c/consumerDetails';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

const mockGetPicklistValues = require('./data/genderpicklist.json');

describe('c-consumer-Details', () => {
    afterEach(() => {

        // The jsdom instance is shared across test cases in a single file so reset the DOM

        while (document.body.firstChild) {

            document.body.removeChild(document.body.firstChild);

        }

    });

 

    it('renders lightning-record-view-form with given input values', () => {

        const RECORD_ID_INPUT = '0031700000pJRRSAA4';

        const OBJECT_API_NAME_INPUT = 'Account';

 

        // Create component

        const element = createElement('c-consumer-Details', {

            is: ConsumerDetails

        });

        // Set public properties

        element.getValueFromParent = RECORD_ID_INPUT;

        element.objectApiName = OBJECT_API_NAME_INPUT;

        document.body.appendChild(element);

 

        // Validate if correct parameters have been passed to base components

        const formEl = element.shadowRoot.querySelector(

            'lightning-record-view-form'

        );

        expect(formEl.recordId).toBe(RECORD_ID_INPUT);

        expect(formEl.objectApiName.objectApiName).toBe(OBJECT_API_NAME_INPUT);

    });

 

    it('renders given set of lightning-output-field`s in specific order', () => {

        const OUTPUT_FIELDS = ['FirstName', 'LastName', 'MiddleName', 'Suffix', 'Gender__pc','Age__pc','PersonMailingAddress','PersonHomePhone','PersonMobilePhone','PersonOtherPhone','Primary_Phone__pc','PersonBirthdate','PersonEmail'];

        const RECORD_ID_INPUT = '0011700000pJRRSAA4';

        const OBJECT_API_NAME_INPUT = 'Account';

 

        // Create component

        const element = createElement('c-consumer-Details', {

            is: ConsumerDetails

        });

        // Set public properties

        element.recordId = RECORD_ID_INPUT;

        element.objectApiName = OBJECT_API_NAME_INPUT;

        document.body.appendChild(element);

 

        const outputFieldNames = Array.from(

            element.shadowRoot.querySelectorAll('lightning-output-field')

        ).map((outputField) => outputField.fieldName);

        expect(outputFieldNames).toEqual(OUTPUT_FIELDS);

    });

 

    it('is accessible', async () => {

        const element = createElement('c-consumer-Details', {

            is: ConsumerDetails

        });

        document.body.appendChild(element);

 

        // Check accessibility

        await expect(element).toBeAccessible();

    });


    describe('getPicklistValues @wire data', () => {
        it('renders seven lightning-input fields of type checkbox', async () => {
            // Create component
            const element = createElement('c-consumer-Details', {
                is: ConsumerDetails
            });
            document.body.appendChild(element);

            // Emit data from @wire
            getPicklistValues.emit(mockGetPicklistValues);

            // Wait for any asynchronous DOM updates
          //  await flushPromises();

            // Ensures that inputs are checkboxes
            const combo = element.shadowRoot.querySelector('lightning-combobox');
                

                combo.dispatchEvent(new CustomEvent("change", {detail: {value: 'Male'}}));
                return Promise.resolve().then(() => {

                    const outputElement = element.shadowRoot.querySelector('lightning-combobox');
                    console.log(outputElement.textContent + "=======");
                    expect(outputElement.textContent).toBe('new');
                });
            
        });
    });


});