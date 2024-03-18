/**********************************************************************************
 * Title:  Conversion LWC
 * Date:   March 2024
 * 
 * Description:  LWC is to check conversion eligibility and provide input to show conversion product rates 
 *               in rating matrix.
 * 
 * Details:      This component also serves as a parent to the Rating Matrix LWC.  Filtered rates
 *               are loaded into the Rating Matrix.  
 * 
 * Parameters:   See createRequestCriteriaMap()
 * 
 * Modifications:
 *************************************************************************************/
import { LightningElement, wire, track, api } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import DOB from '@salesforce/schema/Opportunity.Account.PersonBirthdate';
import FNAME from '@salesforce/schema/Opportunity.Account.FirstName';
import checkEligibility from '@salesforce/apex/ConversionEligibleQuoteController.checkEligibility';
import { NavigationMixin } from 'lightning/navigation';
import getRates from '@salesforce/apex/ConversionEligibleQuoteController.getRates';
import { reduceErrors } from 'c/ldsUtils';
import CONSUMERCHECK from '@salesforce/label/c.ConsumerCheck';
import SPECIALHANDLING from '@salesforce/label/c.SpecialHandling';
import ADBORWAIVERRIDER from '@salesforce/label/c.ADBorWaiverRider';


export default class conversion extends NavigationMixin(LightningElement) {
    @api opptyId;
    @api coverage;
    @api optyState;
    @api objectApiName;
    conversionTypeOptions = [
        { value:'Term Insurance Policy', label:'Term Insurance Policy' },
        { value:'Other Insured Rider', label:'Other Insured Rider' },
        { value:'Term Insurance Rider', label: 'Term Insurance Rider' },
        { value: 'Child Insurance Rider', label:'Child Insurance Rider' },
        { value: 'Spouse Insurance Rider', label:'Spouse Insurance Rider' },
        { value: 'Guaranteed Insurability Rider', label:'Guaranteed Insurability Rider' },
        { value: 'Employee Group', label:'Employee Group' }
    ];
    selectedConversionType = 'Term Insurance Policy';
    policyNumber =null;
    eligible = false; 
    continueADBorWaiver = false;
    cancelContinueOptions = [
        { label: 'Cancel', value: 'cancel' },
        { label: 'Continue', value: 'continue' }
    ];
    cancelContinueValue = 'cancel';
    payFrequencyOptions = [
        { value: 'Monthly', label: 'Monthly' },
        { value: 'quarterly', label: 'Quarterly' },
        { value: 'annual', label: 'Annual' },
        { value: 'SemiAnnual', label: 'Semi-Annual' } 
                
    ];
    payMethodOptions = [
        { value: 'ACH/PAC', label: 'ACH/PAC' },
        { value: 'DirectBill', label: 'Direct Bill' },
        { value: 'CreditCard', label: 'Credit Card' }
    ];
    
    effectiveDate ='';
    currentCoverage ='';
    underwritingClassOptions = []; // options are dynamically populated from the service
    convertingcoverageAmount =0;
    underwritingClassCode;
    selectedunderwritingClass ='';
    adbWaiverRiderChecked = false;
    selectedPayMethod ='';
    selectedPayFrequency ='';
    showSpinner = false;
    errorDescription ='';
    noContent =false;
    errorResponse =false; 
    errorMessage ='';
    notEligible =false;
    cancelpolicy =false;
    results = [];
    isModalOpen =false
    showRateMatrix =false;

    @wire(getRecord,{recordId : '$opptyId', fields: [DOB, FNAME]})
    wiredOpportunity({error, data}){
    
         if(data){
             this.dob           =getFieldValue(data, DOB);
             this.fname         =getFieldValue(data, FNAME);
                         
          }
         else if (error) {
            console.log('Error in  wiredOpportunity: = ' + reduceErrors(error));
            this.errorMessage = reduceErrors(error);
            
         }
 
    }
    // Event handler to handle the preloaded event from personIdProvider component. this fires on navigation to conversion tab.
    handlePreLoadedInfo(event) {
        if (event.detail && event.detail.Account && event.detail.Account.Gender__pc) {
            this.gender = event.detail.Account.Gender__pc;
            console.log('Gender from provider component is ->' +this.gender);
            
        } else {
            console.log('Gender is undefined or not available.');
            this.isLoading = false;
            
        }
    }

    
    handleChangePolicyNumber(event) {
        this.policyNumber = event.target.value;
        // resetting to clear messages and hide sections.
        this.errorDescription='';
        this.errorResponse=false;
        this.eligible =false;
        this.showRateMatrix =false;
        this.notEligible =false;
        this.noContent =false;
               
    }

    //If enter key is pressed in PolicyNumber field then 
    handlePolicyNumnberKeyPress(event){
        if(event.key === "Enter"){
           this.handleClickCheckEligibility(event);
        }
    }
    
    async handlePolicySummaryClick() {
        this.isModalOpen = true;
        
    }

    // Method to close the modal
    closeModal() {
            this.isModalOpen = false;
    }

    async handleClickCheckEligibility() {
        // resetting to clear messages and hide sections.
        this.errorResponse =false;
        this.convertingcoverageAmount = null;
        this.rateerrormessages='';
        this.showSubsequentSections = true;
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
    
    handleADBWaiverChange(event) {
        this.adbWaiverRiderChecked = event.target.checked;
        
        if (this.adbWaiverRiderChecked) {
            // Display message
            this.ADBmessage = ADBORWAIVERRIDER;

            // Hide subsequent sections
            this.showSubsequentSections = false;
            this.showRateMatrix =false;
        } else {
            // Clear message
            this.ADBmessage = '';

            // Show subsequent sections
            this.showSubsequentSections = true;
        }
    }

    handleFrequencyChange(event) {
        this.showRateMatrix =false;
        this.selectedPayFrequency = event.detail.value;
    }

    handlePaymentMethodChange(event) {
        this.showRateMatrix =false;
        this.selectedPayMethod = event.detail.value;
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

    }

    handleCancelContinueChange(event) {
        this.cancelContinueValue = event.detail.value;
        this.cancelpolicy        = this.cancelContinueValue === 'cancel'?false : true
        this.rateerrormessages='';
        this.showRateMatrix =false;
    } 

    handleGetRate() {
        this.rateerrormessages='';
        this.errorResponse=false;
        this.showSpinner = true;
                
        if (this.convertingcoverageAmount === "") {
            this.rateerrormessages = "Enter a valid converting coverage amount ";
            this.ratevalidation =true;
            this.showSpinner = false;
            //this.notEligible =true;
            return;
        }
        
        const conversionEligibilityDetails = this.getConversionEligibilityDetails();
        // Determine which conversion details to use based on this.cancelpolicy
        const conversionDetails = this.cancelpolicy ? conversionEligibilityDetails.partialConversion : conversionEligibilityDetails.fullConversion;
        
        // Extract max and min coverage amounts based on the chosen conversion details
        const maxCoverageAmount = parseFloat(conversionDetails.coverageAmounts.maximumCoverageAmount);
        const minCoverageAmount = parseFloat(conversionDetails.coverageAmounts.minimumCoverageAmount);

        // Convert string values to numbers for comparison
        const coverageAmount = parseFloat(this.convertingcoverageAmount);

        // max coverage rule
        if (!this.cancelpolicy && coverageAmount > maxCoverageAmount) { //policy is being canceled
            
            this.rateerrormessages = "Coverage Amount cannot exceed the total coverage available " +this.formatNumberWithCommas(maxCoverageAmount);
            this.ratevalidation = true;
            this.showSpinner = false;
            this.convertingcoverageAmountinput = null;
            return;
        }else if (this.cancelpolicy && coverageAmount > maxCoverageAmount) { //Policy is being continued
            
            this.rateerrormessages = "Coverage Amount cannot exceed the total coverage available " + this.formatNumberWithCommas(maxCoverageAmount);
            this.ratevalidation = true;
            this.showSpinner = false;
            this.convertingcoverageAmountinput = null;
            return;

        }

        // min coverage rule
        if (this.cancelpolicy && coverageAmount < minCoverageAmount || !this.cancelpolicy && coverageAmount < minCoverageAmount )  {
            
            this.rateerrormessages = "Coverage Amount is below the minimum coverage " +this.formatNumberWithCommas(minCoverageAmount);
            this.ratevalidation = true;
            this.showSpinner = false;
            this.convertingcoverageAmountinput = null;
            return;
        }
      
        this.showRateMatrix =true;
        // apex call to get rates           
        getRates({kvpRequestCriteria: this.createRequestCriteriaMap()})
        .then(response => {
            console.log('Request Criteria Map:', JSON.stringify(this.createRequestCriteriaMap()));
            
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
            console.log('Error in Get Rate = ' + reduceErrors(error));
            this.errorMessage = reduceErrors(error);
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

        return returndata;
    }

    async validateSearch(){ 
        if(this.policyNumber != null){
            this.policyNumber =this.policyNumber.trim();
            await this.checkifEligible(); // method that calls apex to see if request returns a valid response
        }
        
    }

    async checkifEligible(){
        this.errorMessage = '';
        this.eligible = false;
        this.showRateMatrix = false;
        this.cancelpolicy = true; // setting to get full and partial conversion nodes.
        
        // Log the request criteria map before sending the request
        console.log('Request Criteria Map:', JSON.stringify(this.createRequestCriteriaMap(),null,4));
    
        checkEligibility({kvpRequestCriteria: this.createRequestCriteriaMap()})
            .then(response => {
                              
                // Check if the response is an array containing an empty object
                if (response && Array.isArray(response) && response.length === 1 && Object.keys(response[0]).length === 0) { // this is to handle [{}] from service
                    console.log('No content available from the service');
                    this.noContent = true;
                    this.showSpinner = false;
                    return;
                }
                this.results = response;
                if(this.results != null){  
                    
                    // Additional logic to retrieve and assign values
                    const conversionEligibilityDetails = this.results[0].conversionEligibilityDetails;
                    const currentTermPolicyInfo = this.results[0].currentTermPolicyInfo;
                    
                    this.eligible = conversionEligibilityDetails.isEligible; // shows rest of the form if policy is eligible. if not eligible and has a reason from service display reason.

                    if(!this.eligible){
                        this.errorDescription = conversionEligibilityDetails.isNotEligibleReason?.[0]?.errorDescription; // show message from service when not eligible
                        this.notEligible = true;
                    }
                    // Salesforce internal rules 
                    
                    // Rule 1: Check if this.fname, this.gender, and this.dob are not equal to the corresponding fields from the service
                    if (
                        this.fname !== currentTermPolicyInfo.insured.name.firstName ||
                        this.gender !== currentTermPolicyInfo.insured.gender ||
                        this.dob !== currentTermPolicyInfo.insured.birthDate 
                    ) {
                        this.errorDescription = CONSUMERCHECK;
                        this.notEligible = true;
                        this.eligible = false;
                        this.showSpinner = false;
                        return; // Prevent further execution of the code
                    }

                    // Rule 2: Check if specialHandlingCode === 'X'
                    if (currentTermPolicyInfo.specialHandlingCode !== 'X') {
                        this.errorDescription = SPECIALHANDLING;
                        this.notEligible = true;
                        this.eligible = false;
                        this.showSpinner = false;
                        return; // Prevent further execution of the code
                    }

                    // If none of the rules are satisfied, proceed further with the code execution

                    if(currentTermPolicyInfo ){
                        this.convertingcoverageAmount   = currentTermPolicyInfo.coverageAmount;
                        this.currentCoverage            = this.formatNumberWithCommas(currentTermPolicyInfo.coverageAmount);
                        this.selectedPayMethod          = currentTermPolicyInfo.paymentMethod;
                        this.selectedPayFrequency       = currentTermPolicyInfo.paymentFrequency;
                    }
               
                    
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
                   
                    this.showSpinner = false;
                    this.cancelpolicy = false; //resetting after eligibility check is done and have the entire payload on checkEligibility
                }
            })
            .catch(error => {
                console.log('Error in checkifEligible = ' + reduceErrors(error));
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

    /**
     * Handles cell section event from cell selector component
     * @param {*} event Cell selection event
     */
    handleRateSelection(event) {
        const value = {...event.detail.value};//Value of cell that was selected
        const billingMethodLabel =  this.payMethodOptions.find((billMethod) => billMethod.value === this.selectedPayMethod)?.label;//Get label from billing method options
        let rateObj = {
            paymentFrequency: this.selectedPayFrequency,
            billingMethod:  billingMethodLabel,
            rateInfo: value,
            uwClass: this.underwritingClass,
            uwClassCode: this.underwritingClassCode
        }
        this.template.querySelector("c-ilh-cart-util").publishCartMessage(rateObj);//Call cart util to publish cart message
    }
}
