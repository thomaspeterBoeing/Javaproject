import { LightningElement, api, track } from 'lwc';

export default class IlhAddressLookup extends LightningElement {

    @api txt_Street;
    @api txt_City;
    @api txt_State;
    @api txt_Zip;
    @api txt_Country;
    stateOptions = [ 'AL', 'AK', 'AS', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FM', 'FL', 'GA', 'GU', 'HI', 'ID', 'IL', 'IN', 
    'IA', 'KS', 'KY', 'LA', 'ME', 'MH', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 
    'NY', 'NC', 'ND', 'MP', 'OH', 'OK', 'OR', 'PW', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VI', 
    'VA', 'WA', 'WV', 'WI', 'WY' ];

    @track
    address = {
        street: '',
        city: '',
        province: '',
        postalCode: '',
        country: '',
    };

    connectedCallback() {
        this.address.street = this.txt_Street;
        this.address.city = this.txt_City;
        this.address.province = this.txt_State;
        this.address.postalCode = this.txt_Zip;
        this.address.country = this.txt_Country;
    }

    @api
    validate() {
        const addressInput = this.template.querySelector('lightning-input-address');
        const validity = {
            isValid: true,
            errorMessage: 'Zip code should be either 5 or 9 digits!'
        };

        // Country Field Validation
        if (!addressInput.country) {
            addressInput.setCustomValidityForField("Complete this field.", "country");
            validity.isValid = false;
        } else {
            addressInput.setCustomValidityForField("", "country"); // Reset previously set message
        }

        // Postal Code Validation
        if (!this.isValidPostalCode(addressInput.postalCode)) {
            addressInput.setCustomValidityForField("Invalid postal code.", "postalCode");
            validity.isValid = false;
        } else {
            addressInput.setCustomValidityForField("", "postalCode"); // Reset previously set message
        }

        return validity;
    }

    isValidPostalCode(postalCode) {
        const postalCodePattern = /^\d{5}(-\d{4})?$/;
        return postalCodePattern.test(postalCode);
    }

    handleChange(event) {
        this.txt_Street = event.detail.street;
        this.txt_City = event.detail.city;
        this.txt_State = event.detail.province;
        this.txt_Zip = this.formatPostalCode(event.detail.postalCode);
        this.address.postalCode = this.txt_Zip;
        this.txt_Country = event.detail.country;
    }

    formatPostalCode(strPostalCode) {
        let formattedPostalCode;

        if (strPostalCode) {
            formattedPostalCode = strPostalCode.replace(this.specialCharacters, "");
            if (formattedPostalCode.length > 5) {
                formattedPostalCode = formattedPostalCode.slice(0, 5) + '-' + formattedPostalCode.slice(5);
            }    
        }
        return formattedPostalCode;
    }

    get specialCharacters() {
        return /[-\(\)\s\*A-Z]/g;
    }
}