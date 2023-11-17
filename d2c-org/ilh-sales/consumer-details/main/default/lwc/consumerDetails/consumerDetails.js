import { LightningElement, api,wire,track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo  } from 'lightning/uiObjectInfoApi';
import ModalLWC from 'c/modalScreenFlow';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import { refreshApex } from '@salesforce/apex';
import { reduceErrors } from 'c/ldsUtils';
 

const FIELDS = ["Account.FirstName","Account.LastName","Account.MiddleName","Account.Suffix","Account.PersonBirthdate","Account.Gender__pc","Account.PersonHomePhone","Account.PersonMobilePhone","Account.PersonEmail",
                "Account.PersonMailingStreet","Account.PersonMailingCity","Account.PersonMailingState","Account.PersonMailingPostalCode","Account.PersonOtherPhone",
                "Account.PersonMailingCountry","Account.Primary_Phone__pc","Account.PersonID__pc"];

export default class consumerDetails extends LightningElement {
   
    @api recordId;
    @track paccountID;
    objectApiName = ACCOUNT_OBJECT;
    isLoaded=false;
   
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
            this.prefphtype=this.account.fields.Primary_Phone__pc.value;
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
            this.isLoaded=false;
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