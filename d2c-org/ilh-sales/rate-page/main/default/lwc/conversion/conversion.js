/**********************************************************************************
 * Title:  Conversion LWC
 * Date:   March 2024
 * 
 * Description:  LWC is to check conversion eligibility and provide input to show conversion product rates 
 *               in rating matrix
 * 
 * Details:      This component also serves as a parent to the Rating Matrix LWC.  Filtered rates
 *               are loaded into the Rating Matrix.  
 * 
 * Parameters:   See createRequestCriteriaMap()
 * 
 * Modifications:
 *************************************************************************************/
import { LightningElement, wire, track, api } from 'lwc';
import { getFieldValue, getRecord, getObjectInfo   } from 'lightning/uiRecordApi';
import DOB from '@salesforce/schema/Opportunity.Account.PersonBirthdate';
import FNAME from '@salesforce/schema/Opportunity.Account.FirstName';
import CONTACTID from '@salesforce/schema/Opportunity.Account.PersonContactId';
import checkEligibility from '@salesforce/apex/ConversionEligibleQuoteController.checkEligibility';
import { NavigationMixin } from 'lightning/navigation';
import getRates from '@salesforce/apex/ConversionEligibleQuoteController.getRates';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { reduceErrors } from 'c/ldsUtils';
import policysummary from 'c/policySumSearch'; // remove this
import PolicyFormat from 'c/policyFormat'; // remove this

export default class conversion extends NavigationMixin(LightningElement) {
    @api opptyId;
    @api coverage;
    @api optyState;
    @api objectApiName;
    @track conversionTypeOptions = [
        { value:'Term Insurance Policy', label:'Term Insurance Policy' },
        { value:'Other Insured Rider', label:'Other Insured Rider' },
        { value:'Term Insurance Rider', label: 'Term Insurance Rider' },
        { value: 'Child Insurance Rider', label:'Child Insurance Rider' },
        { value: 'Spouse Insurance Rider', label:'Spouse Insurance Rider' },
        { value: 'Guaranteed Insurability Rider', label:'Guaranteed Insurability Rider' },
        { value: 'Employee Group', label:'Employee Group' }
    ];
    @track selectedConversionType = 'Term Insurance Policy';
    @track policyNumber =null;
    @track eligible = false; 
    @track continueADBorWaiver = false;
    @track cancelContinueOptions = [
        { label: 'Cancel', value: 'cancel' },
        { label: 'Continue', value: 'continue' }
    ];
    @track cancelContinueValue = 'cancel';
    @track payFrequencyOptions = [
        { value: 'annual', label: 'Annual' },
        { value: 'semiannual', label: 'Semi-Annual' },
        { value: 'quarterly', label: 'Quarterly' },
        { value: 'Monthly', label: 'Monthly' }
    ];
    @track payMethodOptions = [
        { value: 'ACH/PAC', label: 'ACH/PAC' },
        { value: 'DirectBill', label: 'Direct Bill' },
        { value: 'CreditCard', label: 'Credit Card' }
    ];
    //@track paymentMethod ='';
    @track effectiveDate ='';
    @track currentCoverage ='';
    @track underwritingClassOptions = []; // options are dynamically populated from the service
    @track convertingcoverageAmount ='';
    @track underwritingClassCode;
    @track selectedunderwritingClass ='';
    userenteredconvertingcoverageAmount ='';
    selectedPayMethod ='';
    selectedPayFrequency ='';
    @track showSpinner = false;
    errorDescription ='';
    errorResponse =false; 
    //covAmtError ='';
    errorMessage ='';
    notEligible =false;
    cancelpolicy =false;
    results = [];
    isModalOpen =false
    showRateMatrix =false;

    /*handleChange(event) {  //might be needed if at some point service would accept conversion type.
        this.selectedConversionType = event.detail.value;
    }*/

   /* async openPolicy() { // this doesn't work for policysummary
        await policysummary.open({        
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            content: 'Passed into content api',
        });
    }*/

    /*@wire(getObjectInfo, { objectApiName: Account})
    acc;

    get fields()
    {
        return [this.acc.data.fields.gender__pc];
    }*/
    //GENDERFIELD ="Opportunity.Account.Gender__pc";

    @wire(getRecord,{recordId : '$opptyId', fields: [DOB, FNAME, CONTACTID/*, GENDERFIELD*/]})
    wiredOpportunity({error, data}){
    
         if(data){
            console.log('inside wiredOpportunity ' +JSON.stringify(data));
             this.dob           =getFieldValue(data, DOB);
             this.fname         =getFieldValue(data, FNAME);
             //this.gender        =getFieldValue(data, GENDER);
             this.contactId     =getFieldValue(data, CONTACTID);
             console.log ('Date of Birth is ' +this.dob);
             console.log ('First Name is ' +this.fname);
             //console.log ('Gender is ' +this.gender);
             console.log ('contact id is ' +this.contactId);
            
         }
         else if (error) {
            //console.error('Error fetching data:', error.data.body);
             // Handle error
         }
 
    }


    // Event handler to handle the preloaded event from personIdProvider component. this fires on navigation to conversion tab.
    handlePreLoadedInfo(event) {
        console.log('is handlePreLoadedInfo even firing');
        if (event.detail && event.detail.Account && event.detail.Account.Gender__pc) {
            this.gender = event.detail.Account.Gender__pc;
            console.log('Gender from provider component is ->' +this.gender);
            // use this.personId to fetch policy data
            //this.fetchPolicyData(this.personId);
        } else {
            console.log('Gender is undefined or not available.');
            this.isLoading = false;
            
        }
    }

    
    handleChangePolicyNumber(event) {
        this.policyNumber = event.target.value;
        console.log('inside handleChangePolicyNumber '+this.policyNumber);
        this.errorDescription='';
        this.eligible =false;
        this.showRateMatrix =false;
        this.notEligible =false;
        this.errorResponse =false;
               
    }
    
    async handlePolicySummaryClick() {
        console.log('record id here is -> ' +this.recID);
        console.log('opty state is '+this.optyState);
        this.isModalOpen = true;
        let temp = await this.template.querySelector('div[class^=slds-modal');//.classList.remove('slds-truncate');
        console.log ('value of temp ' +temp);

    }

    // Method to close the modal
    closeModal() {
            this.isModalOpen = false;
    }

    async handleClickCheckEligibility() {
        this.convertingcoverageAmount = null;
        // Check if policyNumber is null or not within the required length
        if (this.policyNumber ===null || this.policyNumber.length < 3 || this.policyNumber.length > 16) {
            this.errorDescription = "Enter a valid Policy Number between 3-16 characters";
            this.notEligible =true;
            return;
        }
        
        // Proceed with the search
        this.showSpinner = true;
        await this.validateSearch(); // Rename method as appropriate
    }
    

    handleFrequencyChange(event) {
        this.showRateMatrix =false;
        this.selectedPayFrequency = event.detail.value;
    }

    handleConvertingCoverageAmountChange(event) {
        this.rateerrormessages='';
        this.showRateMatrix =false;
        const input = event.target;
        const value = input.value;
   
        // Remove non-numeric characters from the input value
        const sanitizedValue = value.replace(/\D/g, '');
   
        // Update the input value with the sanitized value
        input.value = sanitizedValue;
   
        // Update the component property with the sanitized value
        this.convertingcoverageAmount = sanitizedValue;
        this.userenteredconvertingcoverageAmount = sanitizedValue;

    }

    handleCancelContinueChange(event) {
        console.log('inside handleCancelContinueChange');
        this.cancelContinueValue = event.detail.value;
        this.cancelpolicy        = this.cancelContinueValue === 'cancel'?false : true
        console.log('value of Cancel/Continue Term radiobutton '+this.cancelpolicy);
        this.showRateMatrix =false;
    } 

    handleGetRate() {
        this.rateerrormessages='';
        this.showSpinner = true;
        
        const conversionEligibilityDetails = this.getConversionEligibilityDetails();
        console.log('before coverage rule');

        // Convert string values to numbers for comparison
        const userEnteredCoverageAmount = parseFloat(this.userenteredconvertingcoverageAmount);
        console.log('userEnteredCoverageAmount after parseFloat '+userEnteredCoverageAmount);
        const maxCoverageAmount = parseFloat(conversionEligibilityDetails.fullConversion.coverageAmounts.maximumCoverageAmount);
        console.log('maxCoverageAmount after parseFloat  ' +maxCoverageAmount);
        
        // Convert string values to numbers for  comparison
        const minCoverageAmount = parseFloat(conversionEligibilityDetails.fullConversion.coverageAmounts.minimumCoverageAmount);
        

        // max coverage rule
        if (!this.cancelpolicy && userEnteredCoverageAmount > maxCoverageAmount) { //policy is being canceled
            console.log('inside  max coverage rule');
            this.rateerrormessages = "Coverage Amount cannot exceed the total coverage available " +this.formatNumberWithCommas(maxCoverageAmount);
            this.ratevalidation = true;
            this.showSpinner = false;
            this.convertingcoverageAmountinput = null;
            return;
        }else if (this.cancelpolicy && userEnteredCoverageAmount > maxCoverageAmount-minCoverageAmount) { //Policy is being continued
            console.log('inside else if of max coverage rule');
            this.rateerrormessages = "Coverage Amount cannot exceed the total coverage available " + this.formatNumberWithCommas(maxCoverageAmount-minCoverageAmount);
            this.ratevalidation = true;
            this.showSpinner = false;
            this.convertingcoverageAmountinput = null;
            return;

        }

        // min coverage rule2
        if (this.cancelpolicy && userEnteredCoverageAmount < minCoverageAmount || !this.cancelpolicy && userEnteredCoverageAmount < minCoverageAmount )  {
            console.log('inside min coverage rule');
            this.rateerrormessages = "Coverage Amount is below the minimum coverage " +this.formatNumberWithCommas(minCoverageAmount);
            this.ratevalidation = true;
            this.showSpinner = false;
            this.convertingcoverageAmountinput = null;
            return;
        }

        
        this.showRateMatrix =true;
            console.log('value of showRateMatrix ' +this.showRateMatrix);
        getRates({kvpRequestCriteria: this.createRequestCriteriaMap()})
        .then(response => {
            console.log('Request Criteria Map:', JSON.stringify(this.createRequestCriteriaMap()));
            console.log('handleGetRate response ' +JSON.stringify(response));
            let eligibleRates = [];
            let productChoices = [];
            for (const result of response) {
                for (const product of result.eligibleProducts) {
                    if (!productChoices.includes(product.productName)) {
                        productChoices.push(product.productName);
                    }
                }
                for (const rate of result.eligibleRates) {
                    let rateObj = {coverage : rate.coverage, ...rate.productinfo};          
                    eligibleRates.push(rateObj);
                }
            }
            let filteredRates = this.filterProposedCoverage(eligibleRates);
            this.template.querySelector("c-rating-matrix").buildTable(filteredRates,productChoices,this.selectedPayFrequency.toLowerCase());
            this.showSpinner =false;
            
        })
        .catch(error => {
            this.errorMessage = reduceErrors(error);
            console.log('this.errorMessage : ' + this.errorMessage);
            this.errorResponse =true;
            this.showSpinner =false;
        });
    }

    filterProposedCoverage(data){
        let returndata = [];
        let minCovRange = 0;
        let maxCovRange = 0;
               
        let coverage = Number(this.convertingcoverageAmount);


        //Filters so there are 4 rows above and below the proposed coverage amount.
        minCovRange = coverage - 25000;
        maxCovRange = coverage + 25000;

        console.log(minCovRange);
        console.log(maxCovRange);

        returndata = data.filter(rates => { 
                                if(rates.coverage >= minCovRange & rates.coverage <= maxCovRange)
                                    return rates;
                             }
                   );

        console.log(JSON.stringify(returndata, null, 4));
        return returndata;
    }

    async validateSearch(){ // rename method as appropriate
        console.log('inside ValidateSearch on Click of checkEligibility button ' +this.policyNumber);
        if(this.policyNumber != null){
            this.policyNumber =this.policyNumber.trim();
            await this.checkifEligible(); // method that calls apex to see if request returns a valid response
        }
        
    }

    async checkifEligible(){
        this.errorMessage = ''
        
        // Log the request criteria map before sending the request
        console.log('Request Criteria Map:', JSON.stringify(this.createRequestCriteriaMap()));
    
        checkEligibility({kvpRequestCriteria: this.createRequestCriteriaMap()})
            .then(response => {
                  
                // Check if there are any errors in the response
                if(response && response.error) {
                    console.error('Error in response:', response.error);
                    return;
                }
                this.results = response;
                console.log ('results from service ' +JSON.stringify(this.results));
                   
                if(this.results != null){  
                    
                    // Additional logic to retrieve and assign values
                    const conversionEligibilityDetails = this.results[0].conversionEligibilityDetails;
                    //this.convEligibilityDetails = conversionEligibilityDetails;
                    const currentTermPolicyInfo = this.results[0].currentTermPolicyInfo;
                    
                    this.eligible = conversionEligibilityDetails.isEligible; // shows rest of the form if policy is eligible. if not eligible and has a reason from service display reason.
                    //this.Eligible = conversionEligibilityDetails.isEligible;

                    if(!this.eligible){
                        this.errorDescription = conversionEligibilityDetails.isNotEligibleReason[0].errorDescription; // show message from service when not eligible
                        this.notEligible = true;
                    }
                    // Salesforce internal rules 
                    
                    // Rule 1: Check if this.fname, this.gender, and this.dob are not equal to the corresponding fields from the service
                    console.log('this.fname:', this.fname);
                    console.log('this.gender:', this.gender);
                    console.log('this.dob:', this.dob);
                    console.log('currentTermPolicyInfo.owner.person.insured.name.firstName:', currentTermPolicyInfo.insured.name.firstName);
                    console.log('currentTermPolicyInfo.insured.gender:', currentTermPolicyInfo.insured.gender);
                    console.log('currentTermPolicyInfo.insured.birthdate:', currentTermPolicyInfo.insured.birthDate);
                    if (
                        this.fname !== currentTermPolicyInfo.insured.name.firstName ||
                        this.gender !== currentTermPolicyInfo.insured.gender ||
                        this.dob !== currentTermPolicyInfo.insured.birthDate 
                    ) {
                        this.errorDescription = 'One or more of the following data fields do not match information on the existing policy: First Name, Date of Birth, or Gender. Contact Customer Care to correct prior to processing Conversion';
                        this.notEligible = true;
                        this.eligible = false;
                        this.showSpinner = false;
                        return; // Prevent further execution of the code
                    }

                    // Rule 2: Check if specialHandlingCode === 'X'
                    if (currentTermPolicyInfo.specialHandlingCode !== 'X') {
                        this.errorDescription = 'Special handling code is not X. Proceed with Paper Kit ';
                        this.notEligible = true;
                        this.eligible = false;
                        this.showSpinner = false;
                        return; // Prevent further execution of the code
                    }

                    // If none of the rules are satisfied, proceed further with the code execution

                    if(currentTermPolicyInfo ){
                        this.convertingcoverageAmount   = currentTermPolicyInfo.coverageAmount;
                        this.userenteredconvertingcoverageAmount            = currentTermPolicyInfo.coverageAmount;
                        this.currentCoverage            = this.formatNumberWithCommas(currentTermPolicyInfo.coverageAmount);
                        console.log('value of original convertingcoverageAmount ' +this.userenteredconvertingcoverageAmount);
                        this.selectedPayMethod          = currentTermPolicyInfo.paymentMethod;
                        this.selectedPayFrequency       = currentTermPolicyInfo.paymentFrequency;                        ;

                        /*if (this.currentTermPolicyInfo.paymentMethod) {
                            // Filter the payMethodOptions array to include only the selected payment method
                            this.payMethodOptions = this.payMethodOptions.filter(option => option.value === this.currentTermPolicyInfo.paymentMethod);
                        } */
                    }/*else {
                        this.errorDescription = 'Product 2022 Whole Life Conversion is not Quotable. Send a paper kit if appropriate ';
                        this.Eligible = false;
                        this.notEligible = true;
                        
                    }*/
               
                    
                    if(conversionEligibilityDetails) {
                        this.effectiveDate                  = this.formatDate(conversionEligibilityDetails.primaryConversionDate);
                        this.underwritingClassCode          = conversionEligibilityDetails.underwritingClassCode//'S';
                        this.underwritingClass              = conversionEligibilityDetails.underwritingClass; 
                        this.selectedunderwritingClass      = (this.underwritingClassCode + '-' + this.underwritingClass);
                        
                        // Construct label and value for the combobox option
                        const optionLabel = `${this.underwritingClassCode}-${this.underwritingClass}`;
                        const optionValue = `${this.underwritingClassCode}-${this.underwritingClass}`;

                        // Check if the option already exists in the options array
                        const existingOptionIndex = this.underwritingClassOptions.findIndex(option => option.value === optionValue);

                        // If the option doesn't exist, add it to the options array
                        if (existingOptionIndex === -1) {
                            this.underwritingClassOptions.push({ label: optionLabel, value: optionValue });
                        }
                                             
                    }
                    
                        /*this.currentCoverageFormatted = this.currentCoverage.toLocaleString();
                        console.log('value of  currentCoverageFormatted ' +this.currentCoverageFormatted);*/
                    
                    this.showSpinner = false;
                }
            })
            .catch(error => {
                console.error('Error in checkifEligible:', error);
                this.errorMessage = reduceErrors(error);
                this.errorResponse =true;
                this.eligible =false;
                this.showSpinner =false;
            });
    }

    // Method to retrieve conversionEligibilityDetails
    getConversionEligibilityDetails() {
    
        if (this.results && this.results.length > 0) {
            return this.results[0].conversionEligibilityDetails;
        } else {
            // Handle case where conversionEligibilityDetails is not available
            return null;
        }
    }
    
    formatDate(dateString) {
		// Convert dateString to a Date object in UTC timezone
		const date = new Date(dateString);
	
		// Extract year, month, and day components from the UTC date
		const year = date.getUTCFullYear();
		const month = date.getUTCMonth() + 1; // Months are zero-based, so add 1
		const day = date.getUTCDate();
	
		// Ensure month and day are formatted with leading zeros if necessary
		const formattedMonth = String(month).padStart(2, '0');
		const formattedDay = String(day).padStart(2, '0');
	
		// Return the formatted date string in MM/DD/YYYY format
		return `${formattedMonth}/${formattedDay}/${year}`;
	}

  
    // Function to format number with commas
    formatNumberWithCommas(number) {
        return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
    

    createRequestCriteriaMap(){
        return{
            "conversionProductCode"   : '2022 Whole Life Conversion',
            "currentTermCompanyCode"  : this.policyNumber.substring(0,2),
            "currentTermPolicyNumber" : this.policyNumber.substring(2,16),
            "insuredResidentState"    : this.optyState?this.optyState : 'WI',//set to WI if for somereason state is not available.
            // the above 4 are the required fields to be passed in the request for the service
 
            "conversionCoverageAmount": this.convertingcoverageAmount % 1000 === 0 ? null : this.convertingcoverageAmount,
            "isTermBeingKept"         : this.cancelpolicy,
            "channel"                 : "TELEM"
 
        }
       
    }
}
