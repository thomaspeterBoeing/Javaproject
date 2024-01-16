import { LightningElement,wire,track } from 'lwc';
//import getProducts from '@salesforce/apex/QuoteServiceController.getEligibleProducts';
import getRates from '@salesforce/apex/QuoteServiceController.getRates';

export default class ratingFilter extends LightningElement {

    _products = [];
    _rates;
    _value = [];
   
    freqValue = "";
    value;
    isLoaded;
    _ProductArray;
    _frequencyChoice = "monthly"; 

  
    /*
        */

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


        await this.fetchAllQuoteData();

        console.log('Filter -  Products ' + JSON.stringify(this._products));
        console.log('Filter -  Rates ' + JSON.stringify(this._rates));

         
        const status = this.template.querySelector("c-rating-matrix").buildTable(this.filterProposedCoverage(this._rates),this.productLabels,this._frequencyChoice);
        this._value = this.productLabels;
   }
   
    filterProposedCoverage(data){


        //Not currently working.  Just passing value through without filtering.  
        


        const coverage = 100000;
        let returndata = [];
        returndata = data.filter(rates => { 
                                if(rates.coverage > coverage)
                                    return rates;
                             }
                   );

        
        console.log('Data filtered for Proposed Coverage ' + JSON.stringify(data));
        return data;
    }
     


    //Call to Apex class to retreive all Eligible products.
    //This will also retrieve all of the possible coverages and premiums
    //for the products
    async fetchAllQuoteData() {
        //console.log("In Fetch All Quote Data");
        try{
            let tempArray = await getRates({oppId: '0060400000BdEvYAAV'});
            this._products = tempArray.eligibleProducts.filter((product) => product.productCategory === 'Life');           
            this._rates = tempArray.eligibleRates;

            console.log('Temp Array = ' + JSON.stringify(tempArray));
            console.log('Rates = ' + JSON.stringify(this._rates));
        }catch (error) {
            console.log('error: ' + JSON.stringify(error));  //TODO
        }finally {
            this.isLoaded = true;
        };
    }
        
      
    get options() {       
        return this._ProductArray;
    }
    get values() {
       let valueArray = []; 
        if(this._products){
            const len = this._products.length;
            
            for (let index = 0;  index < len; ++index){
                valueArray.push(this._products[index].value);                
                
            }
        }
        console.log('ValueArray = ' + JSON.stringify(valueArray));
        return valueArray;
    }
    get selectedValues() {
        return this._value.join(',');
    }

    get productlist() {
        console.log('Product List ' + JSON.stringify(this._products));
       return this._products;
        
    }
    get productLabels() {
        const len = this._products.length;
        console.log('length of products ' + len);
        let prods = [];
        for (let index = 0;  index < len; ++index){
            prods.push(this._products[index].value);                
        }
  
        return prods;
    }
    handleFrequencyChange(event){
        this._frequencyChoice = event.detail.value.toLowerCase(); 
        
        this.template.querySelector("c-rating-matrix").buildTable(this._rates,this._value,this._frequencyChoice);



    }

    async handleProductSelection(event) {
        this._value = [...event.detail.selected]; 
        console.log(' handleproductselection value ' + JSON.stringify(this._value)); 
             
        let status;
       
        this.template.querySelector("c-rating-matrix").buildTable(this._rates,this._value,this._frequencyChoice);
        
        
        
    }
}