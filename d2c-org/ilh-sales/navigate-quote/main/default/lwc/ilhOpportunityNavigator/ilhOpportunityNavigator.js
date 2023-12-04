/**********************************************************************************
 * Title:  ilhOpportunityNavigator
 * Date:   Nov 2023
 * 
 * Description:  This LWC's purpose is to navigate to Rate Page post subscribing to messages from OpportunityStageChanged__c
 *               
 * Modifications:
 *************************************************************************************/
import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { subscribe, MessageContext, APPLICATION_SCOPE,unsubscribe } from 'lightning/messageService';
import STAGE_FIELD from '@salesforce/schema/Opportunity.StageName';
import OPPORTUNITY_STAGE_CHANGED_CHANNEL from '@salesforce/messageChannel/OpportunityStageChanged__c';
import { NavigationMixin } from 'lightning/navigation';

export default class OpportunityNavigator extends NavigationMixin(LightningElement) {
    @api recordId; // Opportunity record Id

    @wire(MessageContext)
    messageContext;

    subscription;
    showSpinner = false;
    stage; 


    connectedCallback() {
        // Subscribe to the OpportunityStageChanged message channel
        this.subscription = subscribe(
            this.messageContext,
            OPPORTUNITY_STAGE_CHANGED_CHANNEL,
            (message) => this.handleOpportunityStageChange(message),
            { scope: APPLICATION_SCOPE }
        );
        
    }

     @wire(getRecord, { recordId: '$recordId', fields: [STAGE_FIELD] })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.stage = getFieldValue(data, STAGE_FIELD);
                       
        } else if (error) {
            // Log error
            // For the timebeing add console.log here for troubleshooting until we figure out how to log UI errors.
        }
    }

    handleOpportunityStageChange(message) {
        // Check if the Opportunity Id from the message matches the current Opportunity Id
        if (message.stage === this.stage && message.recordId === this.recordId) {
            // Navigate to the app page
            this.navigateToAppPage();
        } else {
            // do nothing
        }
    }

    navigateToAppPage() {
        // Implement the logic to redirect to the app page
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'ILH_Sales_Consumer_Search', // Replace with Rate/Quote or whatever gets decided
            },
        }).then(() => {
           
        });
    }

    navigateToObjectHome() {
        // Navigate to the Lead object home page //this can be removed later as this merely shows possibility of navigation.
        this[NavigationMixin.Navigate]({
          type: "standard__objectPage",
          attributes: {
            objectApiName: "Lead",
            actionName: "home",
          },
        });
      }

    disconnectedCallback() {
        if (this.subscription) {
            this.subscription = null;
        }
      }
}
