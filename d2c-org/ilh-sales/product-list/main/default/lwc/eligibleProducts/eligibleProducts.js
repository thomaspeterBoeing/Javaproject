import { LightningElement, wire, api } from 'lwc';
import getEligibleQuotes from '@salesforce/apex/ProductListController.getEligibleQuotes';
import getOpportunity from '@salesforce/apex/ProductListController.getOpportunity';
import { reduceErrors } from 'c/ldsUtils';//LWC Reduces one or more LDS errors into a string[] of error messages

/*
import { subscribe, MessageContext, unsubscribe } from 'lightning/messageService';
import PRODUCT_DATA_CHANNEL from '@salesforce/messageChannel/Product_Data__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';
*/


const columns = [    
    { label: 'Product Code', fieldName: 'insuranceProductCode' },
    { label: 'Characteristics', fieldName: 'prodCharecteristics' }
];

export default class EligibleProducts extends LightningElement {
    @api recordId;
    results = [];
    columns = columns;    
    opp;
    showSpinner = false;
    errorMessage = undefined;

    connectedCallback(){        
        this.getOpportunity();
    }

    getProductData(req){
        console.log('Request in Product List = '+ JSON.stringify(req));
        getEligibleQuotes({requestObj: req}).then(data=> {            
            this.results=[];
            for(let index=0; index<data.length;index++){
                console.log(data[index]);
               //if(data[index].quotable == 'Y'){
                 data[index].productId = index+1;
                 this.results.push(data[index]);
               //}
            }
            this.showSpinner = false;            
           }).catch(err=>{
            let errorMessage = reduceErrors(err);
            this.errorMessage = errorMessage;
            this.showSpinner = false;
        });

        console.log('Results from getting product data = ' + this.results);
    }

    getOpportunity(){
        this.showSpinner = true;
        getOpportunity({oppoId: this.recordId})
        .then(data=> {
            this.opp = data;
            let req = this.createRequest(data);            
            this.getProductData(req);
        })
        .catch(err=>{
            let errorMessage = reduceErrors(err);
            this.errorMessage = errorMessage;
            this.showSpinner = false;
        });
    }

    createRequest(opp){
        
       
        var currdate=new Date().toISOString().slice(0, 10);
        console.log('curredate'+currdate);
        let req = {
            "gender": opp.Account.Gender__pc =="Female"?0:1,
            "residentState": "WI",
            "postalCode":opp.Account.BillingPostalCode,
            "issueAge": opp.Account.Age__pc.toString(),
            "birthDate":opp.Account.PersonBirthdate,
            "requestingSystemName":"sforcecs",
            "contractNumber": "04500218",
            "organizationId":"",
            "asOfDate": currdate,
            "coverageInterval": 1000,
            "minCoverage": 1000,
            "maxCoverage": 500000,
            "tobaccoUse": opp.TobaccoUse__c=="Yes"? 1: 0,
            "channel":"Telem"
        }
      return req;
    }
}