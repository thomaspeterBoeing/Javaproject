/*
Comments go here
*/

import { LightningElement,api,wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import CART_CHANNEL from '@salesforce/messageChannel/Cart__c';

export default class RatingMatrix extends LightningElement {
        
    rateData = [];
    rateColumns =[];
    subscription = null;
    payload;
      
    /**
	    * Purpose: Wiring message context
    */
    @wire(MessageContext)
    MessageContext;


   @api buildTable(rates,products,frequency){
        this.rateData = [...rates];
        this.rateColumns = []; 
        let columns = [];       
        const len = products.length;

         
        columns.push(
            {label: 'Coverage', fieldName: 'coverage', type :'currency', cellAttributes: { alignment: 'left' } }
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
                            lockwhenselected: true,
                            cellallignment: "left"
                        }})

                  
        }

        this.rateColumns = [...this.rateColumns,...columns];

    }

  
    @api filterTable(product){           
            this.rateColumns = [...this.rateColumns].filter(col => col.fieldName == product);
          
    }
       
    handleRateSelection(event) {
         
        const value = {...event.detail.value};
        let rates = this.rateData;
        const len = rates.length;
    

        for (let i = 0; i < len; i++) {

  
            //Updating the rateDate with the checked indicator.  Required when 
            //filtering products so checks display correctly in the grid.
            if (rates[i].coverage == value.coverage){           
                rates[i][value.productlabel] = {...value};
                    
                this.rateData = rates;
                break;
            
            }
        } 
        let payload = {
            productCode: value?.productcode,
            paymentFrequency: 'Monthly',
            billingMethod: 'ACH',
            coverage: value?.coverage,
            cost: value?.monthly
        }

        console.log('Payload = ' + JSON.stringify(payload));
        publish(this.MessageContext, CART_CHANNEL, payload);
    
    }
 
       
    

}