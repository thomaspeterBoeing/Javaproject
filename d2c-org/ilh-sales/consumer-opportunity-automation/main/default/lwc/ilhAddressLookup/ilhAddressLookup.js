import { LightningElement,api,track,wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import DOMICILESTATE_FIELD from "@salesforce/schema/Account.DomicileState__c";

export default class IlhAddressLookup extends LightningElement {

    @api txt_Street;
    @api txt_City;
    @api txt_State;
    @api txt_Zip;
    @api txt_Country;
    stateOptions = [];

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
/*        const inputFields = this.template.querySelectorAll('lightning-input-address');
        const validity = {
            isValid: true,
            errorMessage: 'Please fill the required fields!'
        };
        inputFields.forEach(inputField => {
            if(inputField.checkValidity()) {
                inputField.setCustomValidityForField("Complete this field.", [inputField.name]);
                validity.isValid = true;
            } else {
                validity.isValid = false;
            }
        });
        return validity;
*/


        const address = this.template.querySelector('lightning-input-address');
        //Country Field Validation
        var country = address.country;
        if (!country) {
            address.setCustomValidityForField("Complete this field.", "country");
        } else {
            address.setCustomValidityForField("", "country"); //Reset previously set message
        }

        return address.reportValidity();    

    }

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;
    
    @wire(getPicklistValues, { recordTypeId: "$objectInfo.data.defaultRecordTypeId", fieldApiName: DOMICILESTATE_FIELD })
        getResults({error, data}){
            if(data){	
                this.stateOptions =[...data.values];
            }
            else if (error) {
                console.log("error", error);          
            }
        }

    handleChange(event) {
        this.txt_Street = event.detail.street;
        this.txt_City = event.detail.city;
        this.txt_State = event.detail.province;
        this.txt_Zip = this.formatPostalCode(event.target.postalCode);
        this.address.postalCode = this.txt_Zip;
        this.txt_Country = event.detail.country;
    }

    /**
	 * Purpose: This function formats a postal code
	 * @param strPostalCode : Postal code to format
	 * @returns : Formatted postal code
	 */
	formatPostalCode(strPostalCode) {
		let pcout = "";

		if (strPostalCode != null) {
			strPostalCode = strPostalCode.replace(this.specialCharacters, "");
			for (let i = 0; i < strPostalCode.length; i++) {				
				if (i === 5 && strPostalCode.length !== 5) {
					pcout += "-";
				}
                if (pcout.length <= 9) {
                    pcout += strPostalCode[i];
                }
			}
		}
		return pcout;
	}

    /**
	 * Purpose: This function returns a string of special characters
	 * @return : String of special characters
	 */
	get specialCharacters() {
		return /[-\(\)\s\*A-Z]/g; // removes extra characters user might type in field
	}
}