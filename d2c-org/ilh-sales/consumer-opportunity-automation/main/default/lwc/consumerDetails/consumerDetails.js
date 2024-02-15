import { LightningElement, api,wire,track} from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo  } from 'lightning/uiObjectInfoApi';
import ModalLWC from 'c/modalScreenFlow';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import CONSUMER_OPTY_CHANGES_CHANNEL from '@salesforce/messageChannel/ConsumerOpportunityUpdatesData__c';
import TOBACCO_USE from '@salesforce/schema/Opportunity.TobaccoUse__c';
import STATE from '@salesforce/schema/Opportunity.Account.PersonMailingState';
import DOB from '@salesforce/schema/Opportunity.Account.PersonBirthdate';
import AFFILIATION from '@salesforce/schema/opportunity.Affiliation__c';
import { publish, MessageContext } from 'lightning/messageService';
import { refreshApex } from '@salesforce/apex';
import { reduceErrors } from 'c/ldsUtils';
 

const FIELDS = ["Account.FirstName","Account.LastName","Account.MiddleName","Account.Suffix","Account.PersonBirthdate","Account.Gender__pc","Account.PersonHomePhone","Account.PersonMobilePhone","Account.PersonEmail",
                "Account.PersonMailingStreet","Account.PersonMailingCity","Account.PersonMailingState","Account.PersonMailingPostalCode","Account.PersonOtherPhone",
                "Account.PersonMailingCountry","Account.PersonID__pc"];


export default class consumerDetails extends LightningElement {
   
    @api recordId;
    @track paccountID;
    objectApiName = ACCOUNT_OBJECT;
    isLoaded=false;
    datachanged =false;
    tobaccoUse =null;
    dob;
    state;
    priorTobaccoUse =null;
    priordob;
    priorstate;
    prioraffiliation;
   
   @track fname;
   @track lname;
   @track middlename;
   @track suffix;
   @track dob;
   @track homeph;
   @track mobph;
   @track gender;
   @track mstreet;
   @track mcity;
   @track zipcode;
   @track mstate;
   @track mcountry;
   @track email;
   @track workph;
   @track prefphtype;
   @track personid;
   @track tobaccoUse;
   @track state;
   @track dob;
   @track affiliation;

   
   @wire(MessageContext)
   messageContext;

   @wire(getRecord,{recordId : '$recordId', fields: [TOBACCO_USE, STATE , DOB, AFFILIATION]})
   wiredOpportunity({error, data}){
   
        if(data){
            this.tobaccoUse =getFieldValue(data, TOBACCO_USE );
            this.dob        =getFieldValue(data, DOB);
            this.state      =getFieldValue(data,STATE);
            this.affiliation=getFieldValue(data, AFFILIATION);
            
            if ((this.tobaccoUse !==null && this.tobaccoUse !== this.priorTobaccoUse) || this.state !== this.priorState || this.dob !== this.priorDob || this.affiliation !== this.prioraffiliation) {
                this.priorTobaccoUse = this.tobaccoUse;
                this.priorState = this.state;
                this.priorDob = this.dob;
                this.prioraffiliation =this.affiliation;
                this.datachanged =true;
                
                this.publishConsOptychanged(this.recordId, this.datachanged)
            }
            
        }
        else if (error) {
            // Handle error
        }

   }

   publishConsOptychanged(recordId, datachanged){
        const newMessage ={
            recordId,
            datachanged,
        };
        publish(this.messageContext, CONSUMER_OPTY_CHANGES_CHANNEL, newMessage);

   }

   @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
   objectInfo;
   account;
   errorMessage='';
   handlePersonIdLoaded(event) {
       this.paccountID = event.detail.AccountId; // assign value from the event that gets preloaded
   }

   
   @wire(getRecord, { recordId:'$paccountID' , fields: FIELDS })
   loadRecord({ data, error }) {
        if (data) {
            this.account = data;
            
            this.fname =this.account.fields.FirstName.value;
            this.lname=this.account.fields.LastName.value;
            this.middlename=this.account.fields.MiddleName.value;
            this.suffix=this.account.fields.Suffix.value;
            this.dob=this.account.fields.PersonBirthdate.value;
            this.homeph=this.account.fields.PersonHomePhone.value;
            this.mobph=this.account.fields.PersonMobilePhone.value;
            this.workph=this.account.fields.PersonOtherPhone.value;
            this.gender=this.account.fields.Gender__pc.value;
            this.mstreet=this.account.fields.PersonMailingStreet.value;
            this.mcity=this.account.fields.PersonMailingCity.value;
            this.zipcode=this.account.fields.PersonMailingPostalCode.value;
            this.mstate=this.account.fields.PersonMailingState.value;
            this.mcountry=this.account.fields.PersonMailingCountry.value;
            this.email=this.account.fields.PersonEmail.value;

            this.personid=this.account.fields.PersonID__pc.value;
                // Initialize other fields as needed
        } else if (error) {
            // Handle error
        }
    }
   
    @wire(getRecord, { recordId: '$paccountID', fields: ['Account.Id'] })
    paccount;

      
    checkIfNoValue(value){
        let returnValue;
            if(!value){ returnValue = ""
        } else {
             returnValue = value
        }
            
        return returnValue;   
    }
    handleonload(){
        this.isLoaded=true;
        this.priordob =this.dob;
        this.priorstate =this.state;

    }
    setFlowVariables(){
        const flowInputVariables = [
            {
                name: "inputTxt_PersonId",
                type: "String",
                value: this.checkIfNoValue(this.personid),
            },
            {
                name: "inputTxt_AccountId",
                type: "String",
                value: this.checkIfNoValue(this.paccountID),
            },
            {
                name: "inputTxt_FirstName",
                type: "String",
                value: this.checkIfNoValue(this.fname),
            },
            {
                name: "inputTxt_LastName",
                type: "String",
                value: this.checkIfNoValue(this.lname),
            }, 
            {
                name: "inputTxt_MiddleName",
                type: "String",
                value: this.checkIfNoValue(this.middlename),
            }, 
            {
                name: "inputTxt_Suffix",
                type: "String",
                value: this.checkIfNoValue(this.suffix),
            }, 
            {
                name: "inputTxt_Gender",
                type: "String",
                value: this.checkIfNoValue(this.gender),
            },
            {
                name: "inputTxt_HomePhone",
                type: "String",
                value: this.checkIfNoValue(this.homeph),
            },
            {
                name: "inputTxt_MobilePhone",
                type: "String",
                value: this.checkIfNoValue(this.mobph),
            },
            {
                name: "inputTxt_WorkPhone",
                type: "String",
                value: this.checkIfNoValue(this.workph),
            },
            {
                name: "inputDt_BirthDate",
                type: "Date",
                value: this.dob,
            },    
            {
                name: "inputTxt_Email",
                type: "String",
                value: this.checkIfNoValue(this.email),
            },    
            {
                name: "inputTxt_AddressCity",
                type: "String",
                value: this.checkIfNoValue(this.mcity),
            },   
            {
                name: "inputTxt_AddressState",
                type: "String",
                value: this.checkIfNoValue(this.mstate),
            },   
            {
                name: "inputTxt_AddressStreet",
                type: "String",
                value: this.checkIfNoValue(this.mstreet),
            },    
            {
                name: "inputTxt_AddressPostalCode",
                type: "String",
                value: this.checkIfNoValue(this.zipcode),
            }            
        ]  
      
        return flowInputVariables;
    }

   async callScrflow(){
       
        try{
            const flowInputVars = this.setFlowVariables();
            var returnedAccountId;  
            returnedAccountId = await this.openModalFlow(flowInputVars);
        
        }catch(error){

        }finally{
            this.paccountID=returnedAccountId;
            refreshApex(this.paccount);
            
        }
    }


    async openModalFlow(flowInputVars) {    
        let returnValue;
      
        const outputVars = await ModalLWC.open({
            size: 'medium',            
            modalTitle: 'Complete Consumer',
            flowAPIName: 'ILH_CreateUpdatePersonAccountScrF',     
            flowInputVariables: flowInputVars,
        });
        
            for (let i = 0; i < outputVars.length; i++) {     
              //Check output parameters from Flow for outputTxt_AccountId        
              if (outputVars[i].name == "outputTxt_AccountId") {
                 returnValue = outputVars[i].value;
              } 
            }       
            return returnValue;
          
    }

    isNullOrBlank(value) {
		return ((typeof value === 'undefined') || (value == null) || (value === ''));
	}

}