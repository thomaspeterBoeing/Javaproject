/**********************************************************************************
 * Title:  Rating Matrix LWC
 * Date:   Jan 2024
 * 
 * Description:  LWC is for displaying a matrix of coverages and product rates. 
 * 
 * Details:      This component creates a grid from rates and products that are passed
 *               to from the parent Rate Filter calling the buildTable method.  
 * 
 * 
 * Modifications:
 *************************************************************************************/

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

        //Creates a message that is published to the Cart Channel.  This channel is listed to by the Rate iLHSaleCart LWC and creates
        //a quote from this message.
        let payload = {
            productCode: value?.productcode,
            paymentFrequency: 'Monthly',
            billingMethod: 'ACH',
            coverage: value?.coverage,
            cost: value?.monthly
        }

        publish(this.MessageContext, CART_CHANNEL, payload);
    
    }
 
       
    

}