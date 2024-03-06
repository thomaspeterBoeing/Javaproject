import { createElement } from 'lwc';
import IlhAddressLookup from 'c/ilhAddressLookup';

describe('c-ilh-address-lookup', () => {
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


    it('Validate with values for country and postal code', async () => {
        const element = createElement('c-ilh-address-lookup', {//Create lookup component
            is: IlhAddressLookup
        });

        document.body.appendChild(element);//Add lookup component to page

        let inputAddress = element.shadowRoot.querySelector('lightning-input-address');
        inputAddress.country = 'US';
        inputAddress.postalCode = '11111';

        expect(element.validate().isValid).toBeTruthy();
    });

    it('Validate country with no value', () => {
        // Arrange
        const element = createElement('c-ilh-address-lookup', {
            is: IlhAddressLookup
        });
    });

    it('Validate postal code with no value', () => {
        // Arrange
        const element = createElement('c-ilh-address-lookup', {
            is: IlhAddressLookup
        });
    });

    it('Validate postal code with a value', () => {
        // Arrange
        const element = createElement('c-ilh-address-lookup', {
            is: IlhAddressLookup
        });
    });

    it('Test handleChange with no postal code value', () => {
        // Arrange
        const element = createElement('c-ilh-address-lookup', {
            is: IlhAddressLookup
        });
    });

    it('Test handleChange with a postal code value', () => {
        // Arrange
        const element = createElement('c-ilh-address-lookup', {
            is: IlhAddressLookup
        });
    });
});