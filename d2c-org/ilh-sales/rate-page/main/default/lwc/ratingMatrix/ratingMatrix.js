/*
Comments go here
*/

import { LightningElement,api,track } from 'lwc';

export default class RatingMatrix extends LightningElement {
    @track rateData = [];
    rateColumns =[];
    subscription = null;
    payload;

  
    @api buildTable(rates,products,frequency){
        this.rateColumns = []; 
        let columns = [];       
        const len = products.length;
     
        columns.push(
            {label: 'Coverage', fieldName: 'coverage', type :'currency' }
        )
        for (let index = 0;  index < len; ++index){                

            columns.push(
                {
                    label: products[index], type :'cellselector',                             
                        typeAttributes: {                                
                            value: {fieldName: products[index]},   
                            labelkey: frequency,
                            labeltype: "currency",
                            checkedvariant: "brand-outline",
                            uncheckedvariant: "base",
                            checkedicon: "action:approval",
                            uncheckedicon: "",
                            lockwhenselected: false,
                            cellallignment: "left"
                        }})

                  
        }

        this.rateColumns = [...this.rateColumns,...columns];
        console.log('Rate Columns = ' + JSON.stringify(this.rateColumns));

        let newRates = [];
        for (let index = 0; index < rates.length; index++) {//UPDATED
            let rateObj = {coverage : rates[index].coverage, ...rates[index].productinfo};
            newRates.push(rateObj);
        }
        this.rateData = [...newRates];//UPDATED

        return "Complete";
    }

  
    @api filterTable(product){           
            this.rateColumns = [...this.rateColumns].filter(col => col.fieldName == product);
          
    }
       
    handleRateSelection(event) {
    
        //const checked = {"checked": true};   
        const value = {...event.detail.value};
        let rates = this.rateData;
        const len = rates.length;

        for (let i = 0; i < len; i++) {

            //strict equality operator (===) does not work
            //for comparison .  
            if (rates[i].coverage == value.coverage){           
                rates[i][value.productcode] = {...value};
                    
                this.rateData = rates;
                break;
            
            }
        } 
    
    }
 
       
    

      // console.log('In Rate Selection Handler: ' + JSON.stringify(event.detail.value));
      // console.log('In Rate Selection Handler Product: ' + event.detail.value.productcode);
       






       //console.log("value: " + event.detail.value);
       //console.log('In Rate Selection Handler: ' + JSON.stringify(event.detail.value));
       //console.log(JSON.parse((event.detail.value).premium));
       //const jsonValue = event.detail.value;
            
       /*this.payload.premium = jsonValue.premium;
       this.payload.coverage = jsonValue.coverage;
       this.payload.productcode = jsonValue.productcode;
       this.payload.frequency = jsonValue.frequency;
       console.log('Payload set in parent: ' + this.payload);*/
       //this.payload = jsonValue;
       //this.template.querySelector("c-cart-test").createquote();
       

    

}