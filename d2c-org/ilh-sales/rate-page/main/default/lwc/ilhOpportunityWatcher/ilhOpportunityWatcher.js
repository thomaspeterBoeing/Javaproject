/**********************************************************************************
 * Title:  ilhOpportunityWatcher
 * Date:   Nov 2023
 * 
 * Description:  This LWC's purpose is to listen to platform event and publish to lightning message channel.
 *               
 * Modifications:
 *************************************************************************************/
import { LightningElement, wire, api } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import OPPORTUNITY_STAGE_CHANGED_CHANNEL from '@salesforce/messageChannel/OpportunityStageChanged__c';
import { reduceErrors } from 'c/ldsUtils';//LWC Reduces one or more LDS errors into a string[] of error messages
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

// Importing the EMP API from lightning-emp-api module to subscribe to platform event Opportunity_Stage__e	
import { subscribe, onError } from 'lightning/empApi';

export default class OpportunityWatcher extends LightningElement {
    @api recordId; // Opportunity record Id
    

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        
        this.registerRecordEventListener();
    }

    registerRecordEventListener() {
        const currentRecordId = this.recordId;

        // Specify the channel for the platform event
        const channel = '/event/Opportunity_Stage__e';

        // Callback function for handling received platform events
        const handlePlatformEvent = (response) => {
            // Ensure the message is not processed more than once
            if (!response.data.payload.processed && response.data.payload.OpportunityId__c === currentRecordId) {
                // Mark the message as processed
                response.data.payload.processed = true;
                // Extract the relevant information and publish to OPPORTUNITY_STAGE_CHANGED_CHANNEL               
                if (response.data.payload.Stage__c === 'Quote') {
                    this.publishOpportunityStageChanged(response.data.payload.OpportunityId__c, 'Quote');
                    // tried navigation from here like shown below. navigation mixin does not work. So we need the ilhOpportunityNavigator LWC
                    //this.navigateToAppPage(); commented this out for now.
                    
                }
            }
        };

        // Subscribe to the platform event channel
        subscribe(channel, -1, handlePlatformEvent)
            .then(response => {
                
            })
            .catch(error => {
                // Add console.log if at all there is a need to look for subscription errors.
                console.log('Error Subscribing to Platform Event' +error);
            });

        // Handle errors
        onError(error => {
            //let errorMessage =reduceErrors(error); // For the commenting this out.  add console.log here for troubleshooting until we figure out how to log UI errors.
            /* this.dispatchEvent(  // this toast message helps to see if at all there is an error message in subcription before going into console logs. For now commenting this out
           // as this is not required. Can be permanently deleted in the future.
                new ShowToastEvent({
                    title: 'Error Subscribing to Platform Event',
                    message: 'ERROR:  '  + errorMessage,
                    variant: 'error',
                }),
            );*/
        });
    }

    handleLaunch(){
        this.publishOpportunityStageChanged(this.recordId,'Quote');

    }

    publishOpportunityStageChanged(recordId, stage) {
        const newMessage = {
            recordId,
            stage,
        };
        publish(this.messageContext, OPPORTUNITY_STAGE_CHANGED_CHANNEL, newMessage);
        
    }

    disconnectedCallback() {
        // Note: The 'unsubscribe' method is not available in the 'lightning-emp-api' module
    }

    
  
    navigateToAppPage() {
        // Implement the logic to redirect to the app page
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'ILH_Sales_Consumer_Search', // Replace with Rate/Quote or whatever gets decided
            },
        }).then(() => {
            // Hide the spinner after navigation is complete
            this.showSpinner = false;
        });
    }
}
