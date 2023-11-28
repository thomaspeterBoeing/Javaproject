/**********************************************************************************
 * Title:  Opportunity Creation and Update LWC
 * Date:   Sept 2023
 * 
 * Description:  LWC is used to allow for other LWC to call for launching 
 *               Auto Launch to creation or update an Opportunity.  Once the opportunity is 
 *               found or created the LWC will navigate to that record.
 * 
 * Details:      Subsribes to Message Opportunity Data Message Channel.  When
 *               a message is received this component will call the Opportunity Flow.
 *               The flow LWC will then look for the output vairable from the flow to 
 *               to get the Id of the Opportunity record and then navigate to that record.
 *          
 * Modifications:
 *************************************************************************************/
import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, MessageContext, unsubscribe } from 'lightning/messageService';
import OPPORTUNITY_DATA_CHANNEL from '@salesforce/messageChannel/Opportunity_Data__c';
import opportunityFlow from '@salesforce/apex/IlhAutoLaunchFlow.startFlow';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';//LWC Reduces one or more LDS errors into a string[] of error messages

export default class IlhOpportunityCreateAndUpdate extends NavigationMixin(LightningElement)  {
    subscription = null;
    spinnerActive = false;
    
    connectedCallback(){
        
        this.subscribeToMessageChannel();

    }

    disconnectedCallback() {
        this.spinnerActive = false;
        unsubscribe(this.subscription);      
    }

    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {
        
        this.subscription = subscribe(
          this.messageContext,
          OPPORTUNITY_DATA_CHANNEL,
          (message) => this.handleMessage(message)
        );
    }

    async handleMessage(message) {

        this.callAutolaunchFlow(this.setFlowVariables(message));
          
    }

    setFlowVariables(message){
   
     const flowInputVariables = [
           
            {
                name: "inputTxt_AccountId",
                type: "String",
                value: this.checkIfNoValue(message.accountId),
            }, 
            {
                name: "inputTxt_LastName",
                type: "String",
                value: this.checkIfNoValue(message.lastName),
            },
            {
                name: "inputTxt_dnis",
                type: "String",
                value: this.checkIfNoValue(message.dnis),
            }           
           
        ]  
        return flowInputVariables;
    }
    
    callAutolaunchFlow(flowInputVars){
        //Spinner will be active until navigated off page 
        this.spinnerActive = true;

        opportunityFlow(
            {
                flowAPIName: 'ILH_OpportunityCreationUpdate',
                flowVar:    JSON.stringify(flowInputVars),
                outputVar:  'outputTxt_OpportunityId'        
            
            })
           .then(result=> {                       
                   this.navigateToOpportunity(result);
                                
                })
            .catch(error=> {
                    this.spinnerActive = false;
                    let errorMessage = reduceErrors(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: 'ERROR:  '  + errorMessage,
                            variant: 'error',
                        }),
                    );
            });                  
    }

    checkIfNoValue(value){
        let returnValue;
            if(!value){ returnValue = ""
        } else {
             returnValue = value
        }
            
        return returnValue;   
    }

    navigateToOpportunity(opptyId) {
        this.spinnerActive = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: opptyId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }

}