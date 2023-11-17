/**********************************************************************************
 * Title:  Consumer Creation and Update LWC
 * Date:   Sept 2023
 * 
 * Description:  LWC is used to allow for other LWC to call for launching 
 *               Auto Launch or Screen Flow to complete the creation or update of 
 *               Person Account.
 * 
 * Details:      Subsribes to Message Channel Consumer Data Message Channel.  When
 *               a message is received this component will determine what flow to call
 *               This component also publishes to Opportunity Data Message Channel 
 *               which will send a message that will be subscribed to from another LWC 
 *               that will apply logic needed to create the opportunity.
 * 
 *               Apex class is called to launch an Auto Launch Flow for creating Person
 *               Account with no user interaction.
 *               Modal LWC is called to launch Screen Flow if user interaction is needed.
 * 
 * Modifications:
 *************************************************************************************/
import { LightningElement, wire } from 'lwc';
import { publish,subscribe, MessageContext, unsubscribe } from 'lightning/messageService';
import CONSUMER_DATA_CHANNEL from '@salesforce/messageChannel/Consumer_Data__c';
import OPPORTUNITY_DATA_CHANNEL from '@salesforce/messageChannel/Opportunity_Data__c';

import ModalLWC from 'c/modalScreenFlow';
import createConsumer from '@salesforce/apex/IlhAutoLaunchFlow.startFlow';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';//LWC Reduces one or more LDS errors into a string[] of error messages

export default class ILHSalesConsumerCreationUpdate extends LightningElement {
    subscription = null;
    errorOccurred = false;             
    connectedCallback() {
        this.subscribeToMessageChannel();       
    }
    
    disconnectedCallback() {
        unsubscribe(this.subscription);      
    }

    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {        
        this.subscription = subscribe(
            this.messageContext,
            CONSUMER_DATA_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

     
    async handleMessage(message) {   
               
        //read message and set flow variables
        const flowInputVars = this.setFlowVariables(message);
        let returnedAccountId;                                                    
        
        //Check if all of the fields required on Person Account are populated. If so
        //Call autolaunch flow.  Otherwise launch screen flow.
        if(this.verifyMandatoryFields(message)){
                returnedAccountId = await this.callAutolaunchFlow(flowInputVars);           
        } else {
                returnedAccountId = await this.openModalFlow(flowInputVars);
        }  
        
        //If an error occurs with the auto launch flow continue with screen flow.
        if(this.errorOccurred){
            returnedAccountId = await this.openModalFlow(flowInputVars);
            this.publishAccountId(returnedAccountId,message.lastName,message.dnis);                  
        } else {
            this.publishAccountId(returnedAccountId,message.lastName,message.dnis); 
        }
    }

    setFlowVariables(message){
        console.log('Message Channel Payload ' + JSON.stringify(message),);

        const flowInputVariables = [
            {
                name: "inputTxt_PersonId",
                type: "String",
                value: this.checkIfNoValue(message.personID),
            },
            {
                name: "inputTxt_AccountId",
                type: "String",
                value: this.checkIfNoValue(message.accountId),
            },
            {
                name: "inputTxt_FirstName",
                type: "String",
                value: this.checkIfNoValue(message.firstName),
            },
            {
                name: "inputTxt_MiddleName",
                type: "String",
                value: this.checkIfNoValue(message.middleName),
            },
            {
                name: "inputTxt_LastName",
                type: "String",
                value: this.checkIfNoValue(message.lastName),
            }, 
            {
                name: "inputTxt_Gender",
                type: "String",
                value: this.checkIfNoValue(message.gender),
            },
            {
                name: "inputTxt_HomePhone",
                type: "String",
                value: this.checkIfNoValue(message.homePhone),
            },
            {
                name: "inputTxt_MobilePhone",
                type: "String",
                value: this.checkIfNoValue(message.mobile),
            },
            {
                name: "inputTxt_WorkPhone",
                type: "String",
                value: this.checkIfNoValue(message.workPhone),
            },
            {
                name: "inputTxt_Email",
                type: "String",
                value: this.checkIfNoValue(message.email),
            },
            {
                name: "inputDt_BirthDate",
                type: "Date",
                value: message.birthDate,
            },    
            {
                name: "inputTxt_AddressCity",
                type: "String",
                value: this.checkIfNoValue(message.mailingCity),
            },   
            {
                name: "inputTxt_AddressState",
                type: "String",
                value: this.checkIfNoValue(message.mailingState),
            },   
            {
                name: "inputTxt_AddressStreet",
                type: "String",
                value: this.checkIfNoValue(message.mailingStreet),
            },    
            {
                name: "inputTxt_AddressPostalCode",
                type: "String",
                value: this.checkIfNoValue(message.mailingPostalCode),
            }            
        ]  
 
        return flowInputVariables;
    }

    
    async callAutolaunchFlow(flowInputVars){
        let returnedAccountId = "";
        try{           
            returnedAccountId = await createConsumer(
                {
                    flowAPIName:    "ILH_CreateUpdatePersonAccountALF",
                    flowVar:        JSON.stringify(flowInputVars),
                    outputVar:      "outputTxt_AccountId"                
                });
        }  catch(error) {
            let errorMessage = reduceErrors(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'ERROR:  '  + errorMessage,
                    variant: 'error',
                }),
            );
            this.errorOccurred = true;
        }    
        return returnedAccountId;     
    }
    // Verify that mandatory fields have valid values
    verifyMandatoryFields(message){
         
                     
        return (  this.validateBirthDate(message.birthDate) &&
                  this.validateGender(message.gender) &&
                  this.validateStringValue(message.firstName) &&
                  this.validateStringValue(message.lastName) &&
                  this.validateStringValue(message.mailingCity) &&
                  this.validateState(message.mailingState) &&
                  this.validateStringValue(message.mailingStreet) &&
                  this.validateStringValue(message.mailingPostalCode) &&
                  this.validatePhones(message.homePhone,message.workPhone,message.mobile)
               
              )
        }

    //If variable does not contain a value then set to empty string.
    checkIfNoValue(value){       
        let returnValue;
            if(!value){ returnValue = ""
        } else {
             returnValue = value
        }           
        return returnValue;   
    }
    
    validateBirthDate(value){
        const oldDate = new Date('1900-01-01');
        const birthDate = new Date(value);
        let returnValue = false;
        if(birthDate.getTime() >  oldDate.getTime()){
            returnValue = true;
        } 
        return returnValue;
    }
    
    //Validate that the value does not equal empty string
    validateStringValue(value){ 
        let returnValue = false;      
        if(value !== ""){
            returnValue = true;
        }
        return returnValue;

    }
  
    validateGender(value){
        let returnValue = false;
        if(value){
            if(value.toLowerCase() == 'male' || value.toLowerCase() == 'female'){
                returnValue = true;
            }
        }
        return returnValue;
    }

    validateState(value){
        let returnValue = false;
        const States = [ 'AL', 'AK', 'AS', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FM', 'FL', 'GA', 'GU', 'HI', 'ID', 'IL', 'IN', 
                 'IA', 'KS', 'KY', 'LA', 'ME', 'MH', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 
                 'NY', 'NC', 'ND', 'MP', 'OH', 'OK', 'OR', 'PW', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VI', 
                 'VA', 'WA', 'WV', 'WI', 'WY' ];
        if(value){
        
            if( States.includes(value.toUpperCase())){                
                returnValue = true;
            }
        }
        return returnValue;
    }
    
    validatePhones(home,work,mobile){
        let returnValue = false;
                     
        if(this.validateSinglePhone(home) || this.validateSinglePhone(work) || this.validateSinglePhone(mobile))
        {  
            returnValue = true;
        }
        return returnValue;
    }    

    validateSinglePhone(value){
        let returnValue = false;
        if (value){
            value = value.replace(/[^0-9]/g, '');
     
            if(value.length == 10) {
            returnValue = true;
            } 
        }
        return returnValue;
    }

    //Opens the modal lwc which launches Screen Flow
    //Returns Output variable from the sreen flow when it
    //has been completed.
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
    // Publish Message for Opportunity Data.  This message is subscribed to by components that 
    // create the Opportunity assigning the Person Account that was created in this component.    
    publishAccountId(accId,lastName,dnis){        
           const payload = {
                                accountId: accId,
                                lastName: lastName,
                                dnis: dnis 
                            };

        publish(this.messageContext, OPPORTUNITY_DATA_CHANNEL, payload);       
    }
   

}