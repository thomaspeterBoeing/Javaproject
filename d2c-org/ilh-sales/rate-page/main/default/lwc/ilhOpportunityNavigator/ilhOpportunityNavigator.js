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
import PROPOSED_COVERAGE_FIELD from '@salesforce/schema/Opportunity.ProposedCoverage__c';
import OPPORTUNITY_STAGE_CHANGED_CHANNEL from '@salesforce/messageChannel/OpportunityStageChanged__c';
import { NavigationMixin } from 'lightning/navigation';
import { reduceErrors } from 'c/ldsUtils';//LWC Reduces one or more LDS errors into a string[] of error messages


export default class OpportunityNavigator extends NavigationMixin(LightningElement) {
    @api recordId; // Opportunity record Id

    @wire(MessageContext)
    messageContext;

    subscription;
    showSpinner = false;
    stage; 
    coverage;


    connectedCallback() {
        console.log('inside connectedcallback of');
        // Subscribe to the OpportunityStageChanged message channel
        this.subscription = subscribe(
            this.messageContext,
            OPPORTUNITY_STAGE_CHANGED_CHANNEL,
            (message) => this.handleOpportunityStageChange(message),
            { scope: APPLICATION_SCOPE }
        );
        console.log('stage change received' +JSON.stringify(this.subscription));
    }

     @wire(getRecord, { recordId: '$recordId', fields: [STAGE_FIELD, PROPOSED_COVERAGE_FIELD] })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.stage = getFieldValue(data, STAGE_FIELD);
            this.coverage =getFieldValue(data,PROPOSED_COVERAGE_FIELD);
            console.log('stage->' +this.stage); 
            console.log('coverage->' +this.coverage);           
          
        } else if (error) {
            // Log error
            // For the timebeing add console.log here for troubleshooting until we figure out how to log UI errors.
        }
    }


    // Update handleOpportunityStageChange method to help in navigating to Rate Page
    handleOpportunityStageChange(message) {
        console.log('inside navigator handleOpportunityStageChange ');
        if (message.stage === this.stage && message.recordId === this.recordId) {
            
            console.log('inside if of handleOpportunityStageChange');
            //navigate to Rate Page
            this.navigateToRatePage();
            
        }
    }


    navigateToRatePage() {
        // View a Lightning App Page.
        console.log('inside navigateToRatePage');
        //console.log('record id is ->' + this.recordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                //recordId:this.recordId,
                apiName: 'Rate', // Replace with Rate/Quote or whatever gets decided
            },
            state:{
                c__recordId :this.recordId,
                c__stage    :this.stage,
                c__coverage :this.coverage
            }
        }).then(() => {
           
            
        });
    }
 


}
