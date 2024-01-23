/*
Comments go here
*/
import { LightningElement,api} from 'lwc';
import getRates from '@salesforce/apex/QuoteServiceController.getRates';

export default class ratingFilter extends LightningElement {

    @api coverage;
    @api productType;
    @api opptyId
  
    errorLoadingRates = false;
    errorMessage;
    errorTitle; 

    _products = [];
    _rates;  
    _filteredRates;
    _value = [];
    coverageError = '';
     value;
    _frequencyChoice = "monthly"; 
    spinnerActive = false; 

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
 
    async connectedCallback(){  
        console.log('Connected CallBack ratingFilter coverage ' + JSON.stringify(this.coverage));
        console.log('Connected CallBack ratingFilter + productType ' + JSON.stringify(this.productType));
        console.log('Connected CallBack ratingFilter + opptyId ' + JSON.stringify(this.opptyId));

        this.spinnerActive = true;
       
        await this.fetchAllQuoteData();

        console.log('Connected CallBack ratingFilter Products ' + JSON.stringify(this._products));
        console.log('Connected CallBack ratingFilter coverage ' + JSON.stringify(this._rates));
        
        console.log()
              
        let newRates = [];
        for (let index = 0; index < this._rates.length; index++) {//UPDATED
            let rateObj = {coverage : this._rates[index].coverage, ...this._rates[index].productinfo};          
            newRates.push(rateObj);            
        }
        this._rates = [...newRates];
        this._filteredRates = this.filterProposedCoverage(newRates,this.coverage);
                
       this.template.querySelector("c-rating-matrix").buildTable(this._filteredRates,this.productLabels,this._frequencyChoice);
  
       
       this._value = this.productLabels;
       this.spinnerActive = false;
   }
   
    filterProposedCoverage(data,coverage){
        let returndata = [];
        coverage = Number(coverage);
        returndata = data.filter(rates => { 
                                if(rates.coverage > coverage - 6000 & rates.coverage < coverage +6000)
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
           let tempArray = await getRates({oppId: this.opptyId});
           this._products = tempArray.eligibleProducts.filter((product) => product.productCategory === this.productType);   
           this._rates = tempArray.eligibleRates;
        }
        catch (error){
            this.spinnerActive = false;
            this.errorLoadingRates = true;
            this.errorMessage = 'error: ' + JSON.stringify(error);
            this.errorTitle = "Error Loading " + this.productType;
            console.log('error: ' + JSON.stringify(error)); //TODO
        };
    }
    

    get values() {
       let valueArray = []; 
        if(this._products){
            const len = this._products.length;
            
            for (let index = 0;  index < len; ++index){
                valueArray.push(this._products[index].value);                
                
            }
        }
        return valueArray;
    }

    //Label for the Product checkboxes
    get hcbLabel(){
        let label = 'Eligible Products';
        if(this.productType === 'Life'){
            label = 'Life Eligible Products';
        }
        if(this.productType === 'ADD'){
            label = 'AD&D Eligible Products';
        }

        return label;
    }

    get productlist() {
        const len = this._products.length;
        
        let prods = [];
    


        for (let index = 0;  index < len; ++index){
           prods.push({
                label: this._products[index].value,
                value: this._products[index].value
           })
        
        }
              
        return prods

    }
    get productLabels() {
        const len = this._products.length;

        let prods = [];
        for (let index = 0;  index < len; ++index){
            prods.push(this._products[index].value);                
        }
  
        return prods;
    }

    get proposedCoverage() {
        return this.coverage;
    }
    handleFrequencyChange(event){
        this._frequencyChoice = event.detail.value.toLowerCase(); 
        
        this.template.querySelector("c-rating-matrix").buildTable(this._filteredRates,this._value,this._frequencyChoice);

    }

   handleProductSelection(event) {
        this._value = [...event.detail.selected]; 

        this.template.querySelector("c-rating-matrix").buildTable(this._filteredRates,this._value,this._frequencyChoice);

    }
    handleProposedCoverageChange(event) {
        if (isNaN(event.target.value)){
            this.coverageError = 'Coverage must be a number';
        }else{
            this.coverageError = '';
        }

        this._filteredRates = this.filterProposedCoverage(this._rates,event.target.value);
        this.template.querySelector("c-rating-matrix").buildTable(this._filteredRates,this._value,this._frequencyChoice);
    }

    handleProposedCoverageKeyPress(event){
        if(event.key === "Enter"){
           this.handleProposedCoverageChange(event);
        }
    }
}