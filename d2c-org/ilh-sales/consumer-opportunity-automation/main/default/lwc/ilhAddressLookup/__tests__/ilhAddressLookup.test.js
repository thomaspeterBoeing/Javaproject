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

    it('Validate when country and postal code has values', () => {
        const element = createElement('c-ilh-address-lookup', {//Create lookup component
            is: IlhAddressLookup
        });

        document.body.appendChild(element);//Add lookup component to page

        let inputAddress = element.shadowRoot.querySelector('lightning-input-address');//Query address component
        inputAddress.country = 'US';//Update value of country property
        inputAddress.postalCode = '11111';//Update value of postal code property

        expect(element.validate().isValid).toBeTruthy();//The value from the validate method should be valid
    });

    it('Validate when country has no value', () => {
        const element = createElement('c-ilh-address-lookup', {//Create lookup component
            is: IlhAddressLookup
        });

        document.body.appendChild(element);//Add lookup component to page

        let inputAddress = element.shadowRoot.querySelector('lightning-input-address');//Query address component
        inputAddress.country = '';//Update value of country property
        inputAddress.postalCode = '11111';//Update value of postal code property

        expect(element.validate().isValid).not.toBeTruthy();//The value from the validate method should not be valid because country is empty
    });

    it('Validate when postal code has no value', () => {
        const element = createElement('c-ilh-address-lookup', {//Create lookup component
            is: IlhAddressLookup
        });

        document.body.appendChild(element);//Add lookup component to page

        let inputAddress = element.shadowRoot.querySelector('lightning-input-address');//Query address component
        inputAddress.country = 'US';//Update value of country property
        inputAddress.postalCode = '';//Update value of postal code property

        expect(element.validate().isValid).not.toBeTruthy();//The value from the validate method should not be valid because postal code is empty
    });

    it('Test handleChange with no postal code value', () => {
        const element = createElement('c-ilh-address-lookup', {//Create lookup component
            is: IlhAddressLookup
        });

        document.body.appendChild(element);//Add lookup component to page

        expect(element.txt_Zip).toBeUndefined();//Check that the zip property is undefined before we update

        let inputAddress = element.shadowRoot.querySelector('lightning-input-address');//Query address component
        inputAddress.postalCode = '';//Update postal code
        inputAddress.dispatchEvent(new CustomEvent('change', {detail: {postalCode: inputAddress.postalCode}}));//Input address onChange

        expect(element.txt_Zip).toBeUndefined();//Zip property should still be undefined
    });

    it('Test handleChange when postal code has a value, and should format correctly', () => {
        const element = createElement('c-ilh-address-lookup', {//Create lookup component
            is: IlhAddressLookup
        });

        document.body.appendChild(element);//Add lookup component to page

        expect(element.txt_Zip).toBeUndefined();//Check that the zip property is undefined before we update

        let inputAddress = element.shadowRoot.querySelector('lightning-input-address');//Query address component
        inputAddress.postalCode = '111111111';//Update postal code
        inputAddress.dispatchEvent(new CustomEvent('change', {detail: {postalCode: inputAddress.postalCode}}));//Input address onChange

        expect(element.txt_Zip).toEqual('11111-1111');//Zip property should be formatted correctly
    });

    it('Input properties should have a value when values are changed', () => {
        const element = createElement('c-ilh-address-lookup', {//Create lookup component
            is: IlhAddressLookup
        });

        document.body.appendChild(element);//Add lookup component to page

        expect(element.txt_Zip).toBeUndefined();//Check that the zip property is undefined before we update
        expect(element.txt_Street).toBeUndefined();//Check that the street property is undefined before we update
        expect(element.txt_City).toBeUndefined();//Check that the city property is undefined before we update
        expect(element.txt_State).toBeUndefined();//Check that the state property is undefined before we update
        expect(element.txt_Country).toBeUndefined();//Check that the country property is undefined before we update

        let inputAddress = element.shadowRoot.querySelector('lightning-input-address');//Query address component

        inputAddress.postalCode = '11111';//Update postal code
        inputAddress.street = '123 Main Street';//Update street
        inputAddress.city = 'Madison';//Update city
        inputAddress.province = 'WI';//Update state
        inputAddress.country = 'US';//Update country

        inputAddress.dispatchEvent(new CustomEvent('change', {//Input address component onChange event
            detail: { 
                postalCode: inputAddress.postalCode,
                street: inputAddress.street,
                city: inputAddress.city,
                province: inputAddress.province,
                country: inputAddress.country
            }
        }));

        expect(element.txt_Zip).toEqual('11111');//Zip property should have been updated correctly
        expect(element.txt_Street).toEqual('123 Main Street');//Street property should have been updated correctly
        expect(element.txt_City).toEqual('Madison');//City property should have been updated correctly
        expect(element.txt_State).toEqual('WI');//State property should have been updated correctly
        expect(element.txt_Country).toEqual('US');//Country property should have been updated correctly
    });
});