/**
 * Copyright: TruStage
 * Purpose: LWC has two sections: criteria and search results  
 *          For Sutherland users the search will happen on page load based on query parameters  
 * Details: This LWC is bringing data from CPS and Salesforce. On click of a record,
 *          Navigate to another LWC (Person Account) to upsert. The two LWC are communicating via lightning messaging service.
 *          Sutherland exprience- search on page load.
 *          Some phone numbers are tied to tons of records and we have a configuration to track these hence  
 *          We can exclude from searches.
 */
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
	@track errors = [];
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

	fieldNames = ['phone', 'ssn', 'dateOfBirth', 'policyNumber', 'firstName', 'lastName', 'state', 'postalCode'];
	
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

	/**
	 * Purpose: This function gets called when component is connected to page
	 */
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

	/**
	 * Purpose: Wiring message context
	 */
	@wire(MessageContext)
    MessageContext;

	/**
	 * Purpose: Getting reference from page
	 */
	@wire(CurrentPageReference)
    currentPageReference;

	/**
	 * Purpose: Getting object info from account object
	 */
	@wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
	objectInfo;

	@wire(getPicklistValues, { recordTypeId: "$objectInfo.data.defaultRecordTypeId", fieldApiName: DOMICILESTATE_FIELD })
    getResults({error, data}){
		if(data){				
			this.stateOptions =[...[{state:""}],...data.values];
		}
	}

	/**
	 * Purpose: Setting classes for search help
	 */
	toggleSearchHelp(){
		this.seachHelpClass = this.seachHelpClass == 'slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-fall-into-ground slds-hide' ? "slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-rise-from-ground" : "slds-popover slds-popover_tooltip slds-nubbin_bottom-left slds-fall-into-ground slds-hide";
	}

	/**
	 * Purpose: This function is called when the user clicks on a search result.
	 * Then we put the result in a object to the auto launch flow.
	 */
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
			birthDate: currentItem.dateOfBirth,
			mailingStreet: currentItem?.addressLines != null ? currentItem?.addressLines[0] : null,
			mailingCity: currentItem.city,
			mailingState: currentItem.stateProvince,
			mailingPostalCode: currentItem.postalCode				
        };			
        publish(this.MessageContext, CONSUMER_DATA_CHANNEL, payload);		
	}

	/**
	 * Purpose: This function is called when the user clicks on the policy format button
	 * Then the function proceeds to open the policy format in a modal window
	 */
	async openPolicyFormat() {
        await PolicyFormat.open({        
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            content: 'Passed into content api',
        });
    }

	/**
	 * Purpose: This function is called when the policy number field is changed in search
	 * Then set the policy number property
	 * @param event : Event from policy number field
	 */
	changePolicyNumber(event) {
		this.policyNumber = event.target.value.replace(/[\s]/g,'');
		event.target.value = this.policyNumber; // Needed since @tracked doesn't seem to work correctly if space is the last character typed
	}

	/**
	 * Purpose: This function is called when the first name field is changed in search
	 * Then set the first name property
	 * @param event : Event from first name field
	 */
	changeFirstName(event) {
		this.firstName = event.target.value.replace(/[\s]*/,'');		
		event.target.value = this.firstName; // Needed since @tracked doesn't seem to work correctly if space is the last character typed
	}

	/**
	 * Purpose: This function is called when the last name field is changed in search
	 * Then set the last name property
	 * @param event : Event from last name field
	 */
	changeLastName(event) {
		this.lastName = event.target.value.replace(/[\s]*/,'');
		event.target.value = this.lastName; // Needed since @tracked doesn't seem to work correctly if space is the last character typed
	}

	/**
	 * Purpose: This function is called when the ssn field is changed in search
	 * Then set the ssn property
	 * @param event : Event from ssn field
	 */
	changeSSN(event) {
		this.ssn = this.formatSSN(event.target.value);
	}

	/**
	 * Purpose: This function is called when the date of birth field is changed in search
	 * Then set the date of birth property
	 * @param event : Event from date of birth field
	 */
	changeDateOfBirth(event) {
		this.dateOfBirth = event.target.value;
	}
	
	/**
	 * Purpose: This function is called when the state field is changed in search
	 * Then set the state property
	 * @param event : Event from state field
	 */
	changeState(event) {
		this.state = event.target.value;				
	}

	/**
	 * Purpose: This function is called when the postal code field is changed in search
	 * Then set the postal code property
	 * @param event : Event from postal code field
	 */
	changePostalCode(event) {
		this.postalCode = this.formatPostalCode(event.target.value); // Needed since @tracked doesn't seem to work correctly if space is the last character typed
	}

	/**
	 * Purpose: This function is called when the phone field is changed in search
	 * Then set the phone property
	 * @param event : Event from phone field
	 */
	changePhone(event) {
		this.phone = this.formatPhone(event.target.value);		
	}

	/**
	 * Purpose: This function is called when the user presses the enter key within the form
	 * Then we search for consumers 
	 * @param event : Event from form
	 */
	keyUpSearch(event) {
		if (event.keyCode === 13) { // keyCode 13 is the 'Enter' key
			this.routineSearch();
		}
	}

	/**
	 * Purpose: This function is called when the user clicks the Clear button
	 */
	clickClear() {		
		this.routineClear();
	}

	/**
	 * Purpose: This function is called when the user clicks the search button
	 */
	clickSearch() {		
		this.routineSearch();
	}
	
	/**
	 * Purpose: This function is called when the user sorts on a column from search results
	 */
	sortRecs(event) {
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

	/**
	 * Purpose: This function calls other funtion to clear search results, clear input fields, and clear errors
	 */
	routineClear() {
		this.clearSearchResults();
		this.clearInputs();
		this.clearErrors();
	}

	/**
	 * Purpose: This funtion calls another function to do the searching if input fields are valid
	 */
	routineSearch() {		
		if(this.firstName != null) {
			this.firstName = this.firstName.trim();
		}
		if(this.lastName != null) {
			this.lastName = this.lastName.trim();
		}
		if(!this.checkValidInputFields()) {//Don't continue searching if there's invalid fields
			return;
		}
		if(!this.checkValidSearchCombination()) {
			this.clearErrors();//Clear all prior errors
			this.setErrorMessage("Invalid Search Combination");
		} else {			
			this.clearSearchResults();
			this.clearErrors();
			this.isSearching = true;			
			this.setSearchResults();
			this.showNew = true;
		}
	}

	/**
	 * Purpose: This function calls backend search methods to get consumer search results
	 */
	setSearchResults(){				
		search({kvpSearchCriteria : this.createSearchCriteriaMap()}).then(response =>{				
			this.searchResults = this.formatSearchResults(response.results);				
			this.isSearching = false;

			if(response.errors != null && response.errors.length > 0) {
				this.handleMultipleErrors(response.errors);
			} else {
				if(this.searchResults.length === 0) {
					this.setErrorMessage('No search results found. Please verify search criteria, and proceed with creating a new consumer as needed.');			
				}
				else if(this.searchResults.length >= 10) {
					this.searchResults = this.searchResults.slice(0, 10);
					this.setErrorMessage('10 or more records found. Please refine your search criteria.');
				}
			}		
		}).catch(error =>{
			let errorMessage = reduceErrors(error);
			this.setErrorMessage(errorMessage);
			this.isSearching = false;
		});
	}

	/**
	 * Purpose: This function set error messages for each error
	 * @param errors : An array of errors from search services 
	 */
	handleMultipleErrors(errors) {
		for(let i = 0; i < errors.length; i++) {
			this.setErrorMessage(errors[i]);
		}
	}

	/**
	 * Purpose: This function checks if a field value is null or blank
	 * @param value : Field input value
	 * @returns : True if field value is blank or null
	 */
	isNullOrBlank(value) {
		return ((value == null) || (value === ''));
	}

	/**
	 * Purpose: Checks if input fields are blank or empty
	 * @returns : True if any input field is blank or empty
	 */
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

	/**
	 * Purpose: This function prepopulates search criteia
	 */
	prepopulateSearchCriteria() {
		if(this.prepopSearchCriteria != null) {
			if((this.prepopSearchCriteria.ssn != null) && (this.prepopSearchCriteria.ssn.length == 9)) {
				this.ssn = this.prepopSearchCriteria.ssn;
			}
			this.policyNumber	= this.prepopSearchCriteria.policyNumber;
			this.firstName		= this.prepopSearchCriteria.firstName;
			this.lastName		= this.prepopSearchCriteria.lastName;
			this.dateOfBirth	= this.prepopSearchCriteria.dateOfBirth;
			this.state			= this.prepopSearchCriteria.state;
			this.postalCode		= this.prepopSearchCriteria.postalCode;
			this.phone			= this.prepopSearchCriteria.phone;
		}
	}

	/**
	 * Purpose: This function formats a phone numbers
	 * @param strPhone : Phone number to format
	 * @returns : Formatted phone number
	 */
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

	/**
	 * Purpose: This function formats a SSN
	 * @param strSSN : SSN to format
	 * @returns : Formatted SSN
	 */
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
				pcout += strPostalCode[i];
			}
		}
		return pcout;
	}

	/**
	 * Purpose: This method converts a date value to string
	 * @param dte : Date to convert to string
	 * @returns : Date value as string
	 */
	dateToString(dte) {
		return dte != null ? dte.toString() : dte;
	}

	/**
	 * Purpose: Formats search results
	 * @param results : Consumer search results to map to new results
	 * @returns : Formatted search results
	 */
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

	/**
	 * Purpose: Constructs and return a PrivacyRequestHelper.search object using the search input fields
	 * @returns : A search criteria object
	 */
	createSearchCriteriaMap() {
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

	/**
	 * Purpose: This function checks if search input values are a vaild search combination
	 * @returns : True if search input values are a valid search combination
	 */
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

	/**
	 * Purpose: This function checks if search combinations are valid
	 * @param combo : Search combination
	 * @returns : True is search combination is valid
	 */
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

	/**
	 * Purpose: This function creates a payload to send to message channel that is picked up by auto launch flow
	 * @param event : Event from New button
	 */
	createNew(event){
		const payload = {
            firstName: this.firstName,
            lastName: this.lastName,
            homePhone: this.homePhone,
            gender: this.gender,
			mailingPostalCode: this.postalCode,
			birthDate: this.dateOfBirth
        };		
        publish(this.MessageContext, CONSUMER_DATA_CHANNEL, payload);
	}

	/**
	 * Purpose: This function checks if input fields are valid
	 * @returns : True if input fields are valid
	 */
	checkValidInputFields() {
		let valid = true;
		for (let index = 0; index < this.fieldNames.length; index++) {
			valid &= this.checkLightningInput(this.fieldNames[index]);
		}
		return valid;
	}

	/**
	 * Purpose: This function checks if specified field is valid
	 * @param inputName : Name of field to check if value is valid
	 * @returns : True if input field value is valid
	 */
	checkLightningInput(inputName) {
		let isValid = false;
		let inputFieldToValidate = this.getInputFromName(inputName);        
		if(inputFieldToValidate != null) {
			inputFieldToValidate.showHelpMessageIfInvalid();			
			isValid = inputFieldToValidate.checkValidity();				
		}
		return isValid;
	}

	/**
	 * Purpose: This function gets input field value from specified field
	 * @param inputName : Input name to get input value for
	 * @returns : Input field value
	 */
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

	/**
	 * Purpose: This function clears search results
	 */
	clearSearchResults() {
		this.searchResults = [];
	}

	/**
	 * Purpose: This function clears search inputs
	 */
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

	/**
	 * Purpose: This function clears all errors
	 */
	clearErrors() {
		this.errors = [];
		this.clearFieldLevelErrors();
	}

	/**
	 * Purpose: This function clears field level errors.  These are errors that appear beneath an input field.
	 */
	clearFieldLevelErrors() {
		for (let index = 0; index < this.fieldNames.length; index++) {
			let inputFieldToValidate = this.getInputFromName(this.fieldNames[index]);        
			if (inputFieldToValidate != null && !inputFieldToValidate.checkValidity()) {
				inputFieldToValidate.value = '';
				inputFieldToValidate.reportValidity();				
			}
		}
	}

	/**
	 * Purpose: This function push an error message to a list of error messages
	 * @param strErrorMessage : Error message to set
	 */
	setErrorMessage(strErrorMessage) {
		let errorId = 'error' + (this.errors != null ? this.errors.length + 1 : 0);
		let errorObj = {
			id: errorId,
			message : strErrorMessage
		}
		this.errors.push(errorObj);
	}

	/**
	 * Purpose: This function returns prepop search criteria
	 * @return : Prepop search criteria
	 */
	@api
	get prepopulationSearchCriteria() {
		return this.prepopSearchCriteria;
	}

	/**
	 * Purpose: This function sets prepop search criteria
	 * @param value : Value to set in prepop search criteria
	 */
	set prepopulationSearchCriteria(value) {
		this.prepopSearchCriteria = value;
		this.routineClear();
		this.prepopulateSearchCriteria();
		if(!this.isSearchInputEmpty()) {
			this.routineSearch();
		}
	}

	/**
	 * Purpose: This function returns a string of special characters
	 * @return : String of special characters
	 */
	get specialCharacters() {
		return /[-\(\)\s\*A-Z]/g; // removes extra characters user might type in field
	}
}