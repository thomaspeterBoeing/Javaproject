/**********************************************************************************
 * Title:  Rating Filter LWC
 * Date:   Jan 2024
 * 
 * Description:  LWC is for calling and allowing for filtering of elligible product rates
 *               by coverage, product, frequency. 
 * 
 * Details:      This component is the parent to the Rating Matrix LWC  Filtered rates
 *               are loaded into the Rating Matrix.  
 * 
 * Parameters:    coverage = Proposed coverage amount which will be used to filter the rates
 *                by a low and high range for the proposed coverage.c/consumerDetails
 *                
 *                productType = Used to determine what type of product category this will be used
 *                for.  Life, ADD
 * 
 *                opptyId = Id for the opportunity record.  This is passed to the elligible quote service to 
 *                get product and rate info.
 * 
 * Modifications:
 *************************************************************************************/
import { LightningElement,api} from 'lwc';
import getRates from '@salesforce/apex/QuoteServiceController.getRates';

export default class ratingFilter extends LightningElement {
    //Parameters passed into this LWC
    @api coverage;      
    @api productType;  
    @api opptyId
  
    //Error message variables that displayed on page if 
    //service is not working.
    errorLoadingRates = false;
    errorMessage;
    errorTitle; 

    products = [];          //Elligible products section returned in JSON response from getRates
    productList = [];       //Products that are available to be selected in Product Checkbox.
    productChoices = [];    //Products that are selected in Product Checkbox.    
    rates = [];             //Rates from coverage and product info section returned in JSON response from getRates
    filteredRates = [];     //Rates filtered by upper and lower coverage range based on Proposed Coverage field.
    
    coverageError = '';  //Field validation message for Proposed Coverage field.
   
    frequencyChoice = "monthly";   //Frequency option selected on Frequency field.
    spinnerActive = false; 

    billMethodChoice = 'ACH';  //Bill method default choice.  Set as value in Bill Method combo box.
      
    disableBillMethod = true;  //Flag to disable Bill Method combo box.

    frequencyOptions = [
        { 
            value: 'Annual', 
            label: 'Annual'
        },
        {
            value: 'SemiAnnual',
            label: 'Semi-Annual'
        },
        {
            value: 'Quarterly',
            label: 'Quarterly'
        },
        {
            value: 'Monthly',
            label: 'Monthly'
        },
    ];
    billMethodOptions = [
        { 
            value: 'ACH', 
            label: 'ACH'
        },       
        { 
            value: 'CreditCard', 
            label: 'Credit Card'
        },       
        {
            value: 'PAC', 
            label: 'PAC'

        }

    ];
 
    async connectedCallback(){     

        let rates = await this.getAllRates();
       
        //Call to Rating Matrix to setup matrix table
        this.template.querySelector("c-rating-matrix").buildTable(rates,this.productChoices,this.frequencyChoice);

   }

   async getAllRates(){
        this.spinnerActive = true;
        let rateData = await this.fetchAllQuoteData();
   
        //Set Products
        this.products = rateData.eligibleProducts.filter((product) => product.productCategory === this.productType);
        //this.products = rateData.EligibleBillingOptions.filter((product) => product.productCategory === this.productType);
                
        //Set Rates  
        this.rates = this.getEligibleRates(rateData);
        
        //set products options.
        this.productList = this.getProductValues(this.products);

        //Set product choices for checkbox column names 
        this.productChoices = this.getProductChoiceNames(this.products);
     
        //Filter rates by proposed coverage amount.
        this.filteredRates = this.filterProposedCoverage(this.rates,this.coverage,this.productType);  
        
        this.spinnerActive = false;

        return this.filteredRates;

   }
   get productCheckboxLabel(){
    this.disableBillMethod = true;
    let label = 'Eligible Products';
    if(this.productType === 'Life'){
        label = 'Life Eligible Products';
    }
    if(this.productType === 'ADD'){
        this.disableBillMethod = false;
        label = 'AD&D Eligible Products';
    }

    return label;
}
 
   getEligibleRates(rateData){
        let newRates = [];
        for (let index = 0; index < rateData.eligibleRates.length; index++) {
            let rateObj = {coverage : rateData.eligibleRates[index].coverage, ...rateData.eligibleRates[index].productinfo};          
            newRates.push(rateObj)           
        }
        return newRates;        
    }
   
    //gets value field found in the products returned    
    getProductValues(products) {        
        let prods = [];
        for (let index = 0;  index < products.length; ++index){            
            prods.push({
                label: this.products[index].value,
                value: this.products[index].value
           })    
        }
  
        return prods;
    } 

    getProductChoiceNames(products) {
        let prods = [];
        for (let index = 0;  index < products.length; ++index){
            prods.push(products[index].value)               
        }
  
        return prods;
    }   
    
    filterProposedCoverage(data,coverage,productCategory){
        let returndata = [];
        let minCovRange = 0;
        let maxCovRange = 0;
               
        coverage = Number(coverage);


        //Filters so there are 4 rows above and below the proposed coverage amount.
        if(productCategory === 'Life'){
            minCovRange = coverage - 5000;
            maxCovRange = coverage + 5000;
       } else if(productCategory === 'ADD'){
            minCovRange = coverage - 25000;
            maxCovRange = coverage + 25000; 
            console.log('ADD DATA ' + JSON.stringify(data));           
       } 

        returndata = data.filter(rates => { 
                                if(rates.coverage > minCovRange & rates.coverage < maxCovRange)
                                    return rates;
                             }
                   );
        return returndata;
    }
    //Call to Apex class to retreive all Eligible products.
    //This will also retrieve all of the possible coverages and premiums
    //for the products    
    async fetchAllQuoteData() {
         try{
            return await getRates({oppId: this.opptyId, productCategory: this.productType, billingMethodCode: this.billMethodChoice,frequency: this.frequencyChoice});          
        }
        catch (error){
            this.spinnerActive = false;
            this.errorLoadingRates = true;
            this.errorMessage = 'error: ' + JSON.stringify(error);
            this.errorTitle = "Error Loading " + this.productType;
            console.log('error: ' + JSON.stringify(error)); //TODO
        };
    }

    //If payment frequency changes a new call to the quote service is required.
    async handleFrequencyChange(event){
        this.frequencyChoice = event.detail.value.toLowerCase();  
        let rates = await this.getAllRates();  
        this.filteredRates = this.filterProposedCoverage(rates,this.coverage,this.productType);       
        this.template.querySelector("c-rating-matrix").buildTable(this.filteredRates,this.productChoices,this.frequencyChoice);
    }
     //If payment frequency changes a new call to the quote service is required.
     async handleBillMethodChange(event){
        console.log('In handle bill method change ' + event.detail.value);
        
        this.billMethodChoice = event.detail.value;  
        let rates = await this.getAllRates();  
        this.filteredRates = this.filterProposedCoverage(rates,this.coverage,this.productType);       
        this.template.querySelector("c-rating-matrix").buildTable(this.filteredRates,this.productChoices,this.frequencyChoice);
    }


    handleProductSelection(event) {
        this.productChoices = [...event.detail.selected]; 
        this.template.querySelector("c-rating-matrix").buildTable(this.filteredRates,this.productChoices,this.frequencyChoice);
    }

    handleProposedCoverageChange(event) {
        if (isNaN(event.target.value)){
            this.coverageError = 'Coverage must be a number';
        }else{
            this.coverageError = '';
        }
        this.coverage = event.target.value;
        this.filteredRates = this.filterProposedCoverage(this.rates,this.coverage,this.productType);
        this.template.querySelector("c-rating-matrix").buildTable(this.filteredRates,this.productChoices,this.frequencyChoice);
    }
    
    //If enter key is pressed in Proposed Coverage field then 
    handleProposedCoverageKeyPress(event){
        if(event.key === "Enter"){
           this.handleProposedCoverageChange(event);
        }
    }
}