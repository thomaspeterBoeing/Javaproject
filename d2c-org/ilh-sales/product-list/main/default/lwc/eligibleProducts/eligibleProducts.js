import { LightningElement, wire, api } from 'lwc';
import getEligibleQuotes from '@salesforce/apex/ProductListController.getEligibleQuotes';
import getOpportunity from '@salesforce/apex/ProductListController.getOpportunity';
import { reduceErrors } from 'c/ldsUtils';//LWC Reduces one or more LDS errors into a string[] of error messages
import CONSUMER_OPTY_CHANGES_CHANNEL from '@salesforce/messageChannel/ConsumerOpportunityUpdatesData__c';
import { subscribe, MessageContext, APPLICATION_SCOPE,unsubscribe } from 'lightning/messageService';

const columns = [    
    { label: 'Product Code', fieldName: 'insuranceProductCode' },
    { label: 'Characteristics', fieldName: 'prodCharecteristics' }
];

export default class EligibleProducts extends LightningElement {
    @api recordId;
    @wire(MessageContext)
    messageContext;
    results = [];
    columns = columns;    
    opp;
    showSpinner = false;
    errorMessage = undefined;
    subscription;
    

    
   
    connectedCallback(){
        this.subscribetomessagechannel();      
    }

    subscribetomessagechannel(){
        this.count =0;
        this.subscription = subscribe(
            this.messageContext, 
            CONSUMER_OPTY_CHANGES_CHANNEL,
            (message) => this.handleOptyFieldChange(message),
            {scope: APPLICATION_SCOPE}
        );
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
    }

    handleOptyFieldChange(message){
         if(message.datachanged  && message.recordId) {
            // Throttle getOpportunity by introducing a slight delay
            if (!this.throttledGetOpportunity) {
                this.throttledGetOpportunity = true;

                // Call getOpportunity after a short delay to avoid multiple calls (100 ms was too small. 400 worked just fine. setting this to a round half a second)
                setTimeout(() => {
                    this.getOpportunity();
                    this.throttledGetOpportunity = false; // Reset the flag after the delay
                }, 500);
            }
        }

    }

    getProductData(req){
        let contractNumber = this.opp.Affiliation__r && this.opp.Affiliation__r.ContractNumberUnformatted__c ? this.opp.Affiliation__r.ContractNumberUnformatted__c : '';
        
        // Check if contractNumber is null
        if (!contractNumber) {
            this.errorMessage = "Affiliation cannot be blank. Please populate Affiliation.";
            this.results=[];
            this.showSpinner = false;
            return; // Stop further execution
        }

        getEligibleQuotes({requestObj: req}).then(data=> {            
            this.results=[];
            this.errorMessage ='';

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
    }

    getOpportunity(){
        this.showSpinner = true;
        getOpportunity({oppoId: this.recordId})
        .then(data=> {
            this.opp = data;
            if (!this.isInitialLoad) {
                this.subscribetomessagechannel(); // Subscribe to the message channel if not the initial load
            }
            this.isInitialLoad = false; // Set flag to false after initial load
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
        let contractNumber = opp.Affiliation__r && opp.Affiliation__r.ContractNumberUnformatted__c? opp.Affiliation__r.ContractNumberUnformatted__c : '';
        console.log('curredate'+currdate);
        let req = {
            "gender": opp.Account.Gender__pc =="Female"?0:1,
            "residentState":opp.Account.PersonMailingState,
            "postalCode":opp.Account.BillingPostalCode,
            "issueAge": opp.Account.Age__pc.toString(),
            "birthDate":opp.Account.PersonBirthdate,
            "requestingSystemName":"sforcecs",
            "contractNumber": contractNumber,
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