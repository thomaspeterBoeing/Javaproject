import { LightningElement, api, track } from 'lwc';

export default class IlhAddressLookup extends LightningElement {

    @api txt_Street;
    @api txt_City;
    @api txt_State;
    @api txt_Zip;
    @api txt_Country;
    stateOptions = [
        { "value": "AK", "label": "AK" }, { "value": "AL", "label": "AL" }, { "value": "AR", "label": "AR" }, { "value": "AZ", "label": "AZ" },
        { "value": "CA", "label": "CA" }, { "value": "CO", "label": "CO" }, { "value": "CT", "label": "CT" }, { "value": "DC", "label": "DC" },
        { "value": "DE", "label": "DE" }, { "value": "FL", "label": "FL" }, { "value": "GA", "label": "GA" }, { "value": "HI", "label": "HI" },
        { "value": "IA", "label": "IA" }, { "value": "ID", "label": "ID" }, { "value": "IL", "label": "IL" }, { "value": "IN", "label": "IN" },
        { "value": "KS", "label": "KS" }, { "value": "KY", "label": "KY" }, { "value": "LA", "label": "LA" }, { "value": "MA", "label": "MA" },
        { "value": "MD", "label": "MD" }, { "value": "ME", "label": "ME" }, { "value": "MI", "label": "MI" }, { "value": "MN", "label": "MN" },
        { "value": "MO", "label": "MO" }, { "value": "MS", "label": "MS" }, { "value": "MT", "label": "MT" }, { "value": "NC", "label": "NC" },
        { "value": "ND", "label": "ND" }, { "value": "NE", "label": "NE" }, { "value": "NH", "label": "NH" }, { "value": "NJ", "label": "NJ" },
        { "value": "NM", "label": "NM" }, { "value": "NV", "label": "NV" }, { "value": "NY", "label": "NY" }, { "value": "OH", "label": "OH" },
        { "value": "OK", "label": "OK" }, { "value": "OR", "label": "OR" }, { "value": "PA", "label": "PA" }, { "value": "RI", "label": "RI" },
        { "value": "SC", "label": "SC" }, { "value": "SD", "label": "SD" }, { "value": "TN", "label": "TN" }, { "value": "TX", "label": "TX" },
        { "value": "UT", "label": "UT" }, { "value": "VA", "label": "VA" }, { "value": "VT", "label": "VT" }, { "value": "WA", "label": "WA" },
        { "value": "WI", "label": "WI" }, { "value": "WV", "label": "WV" }, { "value": "WY", "label": "WY" }, { "value": "PR", "label": "PR" },
        { "value": "VI", "label": "VI" }, { "value": "FM", "label": "FM" }, { "value": "GU", "label": "GU" }
    ];

    @track
    address = {
        street: '',
        city: '',
        province: '',
        postalCode: '',
        country: 'US',
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