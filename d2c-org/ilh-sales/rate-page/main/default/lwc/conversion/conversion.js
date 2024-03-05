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
import { LightningElement, track,api } from 'lwc';
import checkEligibility from '@salesforce/apex/ConversionEligibleQuoteController.checkEligibility';
import { NavigationMixin } from 'lightning/navigation';
import getRates from '@salesforce/apex/ConversionEligibleQuoteController.getRates';
import searchPolicy from '@salesforce/apex/PolicySummaryController.search';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { reduceErrors } from 'c/ldsUtils';
import policysummary from 'c/policySumSearch';
import PolicyFormat from 'c/policyFormat';

export default class conversion extends NavigationMixin(LightningElement) {
    @api opptyId;
    @api recID;// ='006DS00000LQQTqYAP';
    @api coverage;
    @api optyState;
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
    @track Eligible = false; 
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

    
    handleChangePolicyNumber(event) {
        this.policyNumber = event.target.value;
        this.errorDescription='';
        this.Eligible =false;
        this.showRateMatrix =false;
        this.notEligible =false;
        this.errorResponse =false;
               
    }
    
    handlePolicySummaryClick() {
        console.log('record id here is -> ' +this.recID);
        console.log('opty state is '+this.optyState);
        this.isModalOpen = true;
    }

    // Method to close the modal
    closeModal() {
            this.isModalOpen = false;
    }

    async handleClickCheckEligibility() {
        if (this.policyNumber === null) {
            console.log ('inside if');
            // Show message indicating that policy number is required
            //this.showToast('Error', 'Policy Number is required.', 'error');
            const evt = new ShowToastEvent({
                title: 'Policy Number is required!',
                message: this._successMessage,
                variant: 'error',
                mode: 'dismissible'
            });
            this.dispatchEvent(evt);
           // this.errorResponse =true;
            return;
        }
        
        this.showSpinner = true;
        await this.validateSearch(); // Rename method as appropriate
        
    }

    handleFrequencyChange(event) {
        this.showRateMatrix =false;
        this.selectedPayFrequency = event.detail.value;
    }

    handleConvertingCoverageAmountChange(event) {
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
        this.cancelpolicy        = this.cancelContinueValue === 'Cancel'?false : true
        this.showRateMatrix =false;
    } 

    handleGetRate() {
        this.showSpinner = true;
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
                // Update the results property. will be used if inputs don't change for handleGetRate
                this.results = response;
                console.log ('results from service ' +JSON.stringify(this.results));
                   
                if(this.results != null){  
                    
                    // Additional logic to retrieve and assign values
                    const conversionEligibilityDetails = this.results[0].conversionEligibilityDetails;
                    const currentTermPolicyInfo = this.results[0].currentTermPolicyInfo;
                    
                    this.Eligible = conversionEligibilityDetails.isEligible; // shows rest of the form if policy is eligible
                    if(!this.Eligible){
                        this.errorDescription = conversionEligibilityDetails.isNotEligibleReason[0].errorDescription; // show message from service when not eligible
                        this.notEligible = true;
                    }

                    if(currentTermPolicyInfo){
                        this.convertingcoverageAmount   = currentTermPolicyInfo.coverageAmount;
                        this.currentCoverage            = currentTermPolicyInfo.coverageAmount;
                        this.selectedPayMethod          = currentTermPolicyInfo.paymentMethod;
                        this.selectedPayFrequency       = currentTermPolicyInfo.paymentFrequency;                        ;

                        /*if (this.currentTermPolicyInfo.paymentMethod) {
                            // Filter the payMethodOptions array to include only the selected payment method
                            this.payMethodOptions = this.payMethodOptions.filter(option => option.value === this.currentTermPolicyInfo.paymentMethod);
                        } */
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
                }
            })
            .catch(error => {
                console.error('Error in checkifEligible:', error);
                this.errorMessage = reduceErrors(error);
                this.errorResponse =true;
                this.showSpinner =false;
            });
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
   
    

    createRequestCriteriaMap(){
        return{
            "conversionProductCode"   : '2022 Whole Life Conversion',
            "currentTermCompanyCode"  : this.policyNumber.substring(0,2),
            "currentTermPolicyNumber" : this.policyNumber.substring(2,16),
            "insuredResidentState"    : this.optyState?this.optyState : 'WI',//set to WI if for somereason state is not available.
            // the above 3 are the required fields to be passed in the request for the service
 
            "conversionCoverageAmount": this.convertingcoverageAmount % 1000 === 0 ? null : this.convertingcoverageAmount,
            "isTermBeingKept"         : this.cancelpolicy,
            "channel"                 : "TELEM"
 
        }
       
    }
}
