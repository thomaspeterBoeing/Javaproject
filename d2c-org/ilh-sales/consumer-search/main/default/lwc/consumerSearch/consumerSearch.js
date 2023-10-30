/**********************************************************************************
 * Title:  Consumer Search LWC
 * Date:   Sept 2023
 * 
 * Description:  LWC has two sections: criteria and search results  
 *               For Sutherland users the search will happen on page load based on query parameters  
 * 
 * Details:      This LWC is bringing data from CPS and Salesforce. On click of a record,
 *               Navigate to another LWC (Person Account) to upsert. The two LWC are communicating via lightning messaging service.
 *               Sutherland exprience- search on page load.
 *               Some phone numbers are tied to tons of records and we have a configuration to track these hence  
 *               We can exclude from searches.
 *          
 * Modifications:
 *************************************************************************************/

import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import search from '@salesforce/apex/ConsumerSearchController.search';
import checkPhoneExclusionFlag from '@salesforce/apex/ConsumerSearchController.checkPhoneExclusionFlag';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import ACCOUNT_OBJECT from '@salesforce/schema/Account';

import DOMICILESTATE_FIELD from "@salesforce/schema/Account.DomicileState__c";
import PolicyFormat from 'c/policyFormat';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { publish, MessageContext } from 'lightning/messageService';
import CONSUMER_DATA_CHANNEL from '@salesforce/messageChannel/Consumer_Data__c';
import { reduceErrors } from 'c/ldsUtils';//LWC Reduces one or more LDS errors into a string[] of error messages

const SUTHERLAND = 'Sutherland';

export default class ConsumerSearch extends NavigationMixin(LightningElement) {
	@track dateOfBirth = null;
	@track searchResults = [];
	@track errorMessage = null;
	@track prepopSearchCriteria = null;
	showNew=false;
    ssn = null;
	policyNumber = null;
	firstName = null;
	lastName = null;
	state = null;
	stateOptions;
	city = null;
	postalCode = null;
	phone = null;
    isSearching = false;
	initialRender = true;	
    seachHelpClass = "slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-fall-into-ground slds-hide";
	sortedColumn = 'fullName';
    sortedDirection = 'asc';
	ani="";
	dnis="";
	sggid="";
	partner = "";
	isPhoneExcluded = false;	

	validSearchCombinations = [
		['ssn'],
		['policyNumber'],
		['phone', 'firstName'],
		['phone', 'lastName'],
		['phone', 'postalCode'],
		['phone'],
		['firstName', 'lastName', 'postalCode'],
		['firstName', 'lastName', 'dateOfBirth']
	];

	connectedCallback() {      		
		if(this.currentPageReference) {
			this.ani = this.currentPageReference.state?.c__ani;
          	this.dnis = this.currentPageReference.state?.c__dnis;
          	this.sggid = this.currentPageReference.state?.c__sggid;	
          	this.partner = this.currentPageReference.state?.c__lob;	
		  	this.phone = this.formatPhone(this.ani);

		  if(this.phone){		  
		    checkPhoneExclusionFlag({phoneNumber: this.ani}).then(result=> {					
			this.isPhoneExcluded = result;
			if(!this.isPhoneExcluded && this.partner == SUTHERLAND){
			   this.initialRender = false;	
		       this.setSearchResults();	
			}
			else{
				this.phone = "";				
				this.dispatchEvent(new ShowToastEvent({					
					message: "Phone Number is not searchable!",
					variant: "warning",
				}));
			}
		  }).catch(err=>{
			  let errorMessage = reduceErrors(err);
			  this.setErrorMessage(errorMessage);	
		  });
		}	
       }
	}

	@wire(MessageContext)
    MessageContext;

	@wire(CurrentPageReference)
    currentPageReference;

	@wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
	objectInfo;

	@wire(getPicklistValues, { recordTypeId: "$objectInfo.data.defaultRecordTypeId", fieldApiName: DOMICILESTATE_FIELD })
    getResults({error, data}){
		if(data){				
			this.stateOptions =[...[{state:""}],...data.values];
		}
	}

	toggleSearchHelp(){
		this.seachHelpClass = this.seachHelpClass == 'slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-fall-into-ground slds-hide' ? "slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-rise-from-ground" : "slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-fall-into-ground slds-hide";
	}

	clickRequest(evt) {			
		let pId = evt.target.dataset.name;				
		let currentItem = this.searchResults.find(x=>x.personId==pId);		
		let payload = {
			personID: currentItem.personId,
			firstName: currentItem.firstName,
			lastName: currentItem.lastName,
			homePhone: currentItem.homePhone,
			workPhone: currentItem.workPhone,
			mobile: currentItem.mobilePhone,
			gender: currentItem.gender,
			birthDate: currentItem.birthDate,
			mailingStreet: currentItem.street,
			mailingCity: currentItem.city,
			mailingState: currentItem.state,
			mailingPostalCode: currentItem.zipcode				
        };			
        publish(this.MessageContext, CONSUMER_DATA_CHANNEL, payload);		
	}

	async openPolicyFormat() {
        await PolicyFormat.open({        
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            content: 'Passed into content api',
        });
    }


	changeCaseNumber(event) {
		this.policyNumber = event.target.value.replace(/[\s]/g,'');
		event.target.value = this.policyNumber; // Needed since @tracked doesn't seem to work correctly if space is the last character typed
	}

	changeFirstName(event) {
		this.firstName = event.target.value.replace(/[\s]*/,'');		
		event.target.value = this.firstName; // Needed since @tracked doesn't seem to work correctly if space is the last character typed
	}

	changeLastName(event) {
		this.lastName = event.target.value.replace(/[\s]*/,'');
		event.target.value = this.lastName; // Needed since @tracked doesn't seem to work correctly if space is the last character typed
	}

	changeSSN(event) {
		this.ssn = this.formatSSN(event.target.value);
	}

	changeDateOfBirth(event) {
		this.dateOfBirth = event.target.value;
	}
	
	changeState(event) {
		this.state = event.target.value;				
	}

	changePostalCode(event) {
		this.postalCode = this.formatPostalCode(event.target.value); // Needed since @tracked doesn't seem to work correctly if space is the last character typed
	}

	changePhone(event) {
		this.phone = this.formatPhone(event.target.value);		
	}

	keyUpSearch(event) {
		if (event.keyCode === 13) { // keyCode 13 is the 'Enter' key
			this.routineSearch();
		}
	}

	clickClear() {		
		this.routineClear();
	}

	clickSearch() {		
		this.routineSearch();
	}
	
	sortRecs( event ) {
        let colName = event.target.name;   		
        if ( this.sortedColumn === colName ) {
            this.sortedDirection = ( this.sortedDirection === 'asc' ? 'desc' : 'asc' );
        }
        else {
            this.sortedDirection = 'asc';
        }
        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;
        this.sortedColumn = colName;

		let parser = (v) => v;
  
		if(colName=='dateOfBirth') {
			parser = (v) => (v && new Date(v));
		}

        // sort the data
        this.searchResults = this.searchResults.sort((a,b) => {	
			if(colName=='dateOfBirth')	{
				a = parser(a[colName]); 
				b = parser(b[colName]);				
			} else{
				a = a[colName] ? a[colName].toLowerCase() : ''; // Handle null values
				b = b[colName] ? b[colName].toLowerCase() : '';            
			}
			return a > b ? 1 * isReverse : -1 * isReverse;
        });
    }

	/* Sub-orchestration */
	routineClear() {
		this.clearSearchResults();
		this.clearInputs();
		this.clearErrors();
	}

	routineSearch() {		
		this.showNew = true;
		if(this.firstName != null) {
			this.firstName = this.firstName.trim();
		}
		if(this.lastName != null) {
			this.lastName = this.lastName.trim();
		}
		if(!this.checkValidSearchCombination()) {	
			if(this.checkValidInputFields()) {
				this.setErrorMessage("Invalid Search Combination");
			}
		} else {			
			this.clearSearchResults();
			this.clearErrors();
			this.isSearching = true;			
			this.setSearchResults();
		}
	}

	setSearchResults(){				
		search({kvpSearchCriteria : this.createSearchCriteriaMap()}).then(response =>{				
			this.searchResults = this.formatSearchResults(response);				
			this.isSearching = false;
			if(this.searchResults.length === 0) {
				this.setErrorMessage('No search results found. Please verify search criteria, and proceed with creating a new consumer as needed.');			
			}
			else if(this.searchResults.length >= 10) {
				this.searchResults = this.searchResults.slice(0, 10);
				this.setErrorMessage('10 or more records found. Please refine your search criteria.');
			}			
		}).catch(error =>{
			let errorMessage = reduceErrors(error);
			this.setErrorMessage(errorMessage);
			this.isSearching = false;
		});
	}
	/* Helpers */
	isNullOrBlank(value) {
		return ((value == null) || (value === ''));
	}

	isSearchInputEmpty() {
		let isEmpty = true;
		isEmpty = isEmpty && (this.isNullOrBlank(this.ssn));
		isEmpty = isEmpty && (this.isNullOrBlank(this.policyNumber));
		isEmpty = isEmpty && (this.isNullOrBlank(this.firstName));
		isEmpty = isEmpty && (this.isNullOrBlank(this.lastName));
		isEmpty = isEmpty && (this.isNullOrBlank(this.dateOfBirth));
		isEmpty = isEmpty && (this.isNullOrBlank(this.state));
		isEmpty = isEmpty && (this.isNullOrBlank(this.postalCode));
		isEmpty = isEmpty && (this.isNullOrBlank(this.phone));

		return isEmpty;
	}

	prepopulateSearchCriteria() {
		if(this.prepopSearchCriteria != null) {
			if((this.prepopSearchCriteria.ssn != null) && (this.prepopSearchCriteria.ssn.length == 9)) {
				this.ssn = this.prepopSearchCriteria.ssn;
			}
			this.policyNumber		= this.prepopSearchCriteria.policyNumber;
			this.firstName		= this.prepopSearchCriteria.firstName;
			this.lastName		= this.prepopSearchCriteria.lastName;
			this.dateOfBirth	= this.prepopSearchCriteria.dateOfBirth;
			this.state			= this.prepopSearchCriteria.state;
			this.postalCode		= this.prepopSearchCriteria.postalCode;
			this.phone			= this.prepopSearchCriteria.phone;
		}
	}

	formatPhone(strPhone) {
		let phoneOut = "";

		if (strPhone != null) {
			strPhone = strPhone.replace(this.specialCharacters, "");

			for (let i = 0; i < strPhone.length; i++) {
				if(i === 0) {
					phoneOut += "("
				} else if (i === 3) {
					phoneOut += ") ";
				} else if (i === 6) {
					phoneOut += "-";
				}
				phoneOut += strPhone[i];
			}
		}

		return phoneOut;
	}

	formatSSN(strSSN) {
		let ssnout = "";

		if (strSSN != null) {
			strSSN = strSSN.replace(this.specialCharacters, "");

			for (let i = 0; i < strSSN.length; i++) {				
				if (i === 3) {
					ssnout += "-";
				} else if (i === 5) {
					ssnout += "-";
				}
				ssnout += strSSN[i];
			}
		}
		return ssnout;
	}

	formatPostalCode(strPostalCode) {
		let pcout = "";

		if (strPostalCode != null) {
			strPostalCode = strPostalCode.replace(this.specialCharacters, "");
			for (let i = 0; i < strPostalCode.length; i++) {				
				if (i === 5 && strPostalCode.length !== 5) {
					pcout += "-";
				}
				pcout += strPostalCode[i];
			}
		}
		return pcout;
	}

	dateToString(dte) {
		return dte != null ? dte.toString() : dte;
	}

	formatSearchResults(results) {
		let newResults = [];	

		for(let result of results) {		
			let newResult = [];									
			newResult.fullName = result.firstName +' '+result.lastName+(result.nameSuffix? ' '+result.nameSuffix:'');
			newResult.firstName = result.firstName;
			newResult.lastName = result.lastName;
			newResult.nameSuffix = result.nameSuffix;
			newResult.ssnLast4 = result.SSNLast4;
			newResult.dateOfBirth = result.dateOfBirth;
			newResult.state = result.stateProvince;
			newResult.street=result?.addressLines != null ? result?.addressLines[0] : null;
			newResult.city = result.city;
			newResult.postalCode = this.formatPostalCode(result.postalCode);
			newResult.gender = result.gender;
			newResult.homePhone = this.formatPhone(result.homePhone);
			newResult.workPhone = this.formatPhone(result.workPhone);
			newResult.mobilePhone = this.formatPhone(result.mobilePhone);
			newResults.push(newResult);
		}
		return newResults;
	}

	createSearchCriteriaMap() {
		// Constructs and return a PrivacyRequestHelper.search object using the search input fields
		return {
			"ssn" 			: this.ssn,
			"policyNumber" 	: this.policyNumber,
			"firstName" 	: this.firstName,
			"lastName" 		: this.lastName,
			"dateOfBirth" 	: this.dateToString(this.dateOfBirth),
			"state" 		: this.state,
			"zipCode" 		: this.postalCode,
			"phoneNumber" 	: this.phone
		}		
	}

	checkValidSearchCombination() {
		let hasValidCombo = false;
		let comboList = this.validSearchCombinations;
		for(let combo of comboList) {
			if (this.checkCombo(combo)) {
				hasValidCombo = true;
				break;
			}
		}		
		return hasValidCombo;
	}

	checkCombo(combo) {
		let isValidCombo = true;
		for(let fieldName of combo) {
			let input = this.getInputFromName(fieldName);
			if((input.value == null) || (input.value === '') || !input.checkValidity()) {
				isValidCombo = false;
				break;
			}
		}
		return isValidCombo;
	}

	createNew(event){
		const payload = {
            firstName: this.firstName,
            lastName: this.lastName,
            homePhone: this.phone,
            gender: this.gender
        };		
        publish(this.MessageContext, CONSUMER_DATA_CHANNEL, payload);
	}

	checkValidInputFields() {
		let valid = true;
		valid &= this.checkLightningInput('phone');
		valid &= this.checkLightningInput('ssn');
		valid &= this.checkLightningInput('dateOfBirth');
		valid &= this.checkLightningInput('policyNumber');
		valid &= this.checkLightningInput('firstName');
		valid &= this.checkLightningInput('lastName');
		valid &= this.checkLightningInput('state');
		valid &= this.checkLightningInput('postalCode');
		return valid;
	}

	checkLightningInput(inputName) {
		let isValid = false;
		let inputFieldToValidate = this.getInputFromName(inputName);        
		if(inputFieldToValidate != null) {
			inputFieldToValidate.showHelpMessageIfInvalid();			
			isValid = inputFieldToValidate.checkValidity();				
		}
		return isValid;
	}

	getInputFromName(inputName) {
		let inputFields = this.template.querySelectorAll("lightning-input, lightning-combobox"); // For some reason using an attribute selector on name doesn't work...
		let inputFieldToReturn = null;

		for(let field of inputFields) {
			if(field.name === inputName) {
				inputFieldToReturn = field;
			}
		}
		return inputFieldToReturn;
	}


	clearSearchResults() {
		this.searchResults = [];
	}

	clearInputs() {
		this.ssn = null;
		this.policyNumber = null;
		this.firstName = null;
		this.lastName = null;
		this.dateOfBirth = null;
		this.state = null;
		this.postalCode = null;
		this.phone = null;
		this.showNew =false;
		this.checkValidInputFields(); // this tells the all inputs' validity object to reset
	}

	clearErrors() {
		this.errorMessage = null;
	}

	setErrorMessage(strErrorMessage) {
		this.errorMessage = strErrorMessage;
	}

	@api
	get prepopulationSearchCriteria() {
		return this.prepopSearchCriteria;
	}

	set prepopulationSearchCriteria(value) {
		this.prepopSearchCriteria = value;
		this.routineClear();
		this.prepopulateSearchCriteria();
		if(!this.isSearchInputEmpty()) {
			this.routineSearch();
		}
	}

	get specialCharacters() {
		return /[-\(\)\s\*A-Z]/g; // removes extra characters user might type in field
	}
}