/**********************************************************************************
 * Title:  iLHSalesConsumerInfo
 * Date:   Dec 2023
 * 
 * Description:  This LWC's purpose is to display opportunity information in the Rate screen
 *               
 * Modifications:
 *************************************************************************************/
import { LightningElement, api, track, wire } from 'lwc';
import getOpportunityFieldsData from '@salesforce/apex/ConsumerInfoController.getOpportunityFieldsData';
import { reduceErrors } from 'c/ldsUtils';
import { CurrentPageReference } from 'lightning/navigation';

export default class ILHSalesConsumerInfo extends LightningElement {
    @api opportunityId;

    errorMessage;
    @track opportunity = true;
    @track cardTitle = 'Consumer Info';
    @track cardClass = 'slds-card'; 
    @track expandCollapseIcon = 'utility:chevronup'; // this goes with UI/UX design suggestion
    @track expandCollapseAltText = 'Collapse';

    // Store the opportunity data when loaded
    originalOpportunity;
    
    // use data from app page url to get recordId
    @track currentPageReference;
    @wire(CurrentPageReference)
    
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }

    get recordId() {
        return this.currentPageReference?.state?.c__recordId; // this could possibly change if we choose to use LWC instead of Rate Page
    }

    connectedCallback() {
        this.getOpportunityFields();
        // Set the cardClass to expanded by default
        this.cardClass = 'slds-card';

    }  

    /**
     * Purpose: This function gets opportunity fields
     */
    getOpportunityFields() {
        getOpportunityFieldsData({opportunityId : this.recordId}).then(data => {
            this.originalOpportunity = data;
            this.opportunity = data;	
        }).catch(error => {
            this.errorMessage = reduceErrors(error);
        });
    }

    toggleCardVisibility() {
        // Toggle the cardClass to control the styling
        this.cardClass = this.cardClass.includes('slds-is-collapsed') ? 'slds-card' : 'slds-card slds-is-collapsed';

        // Update the card title and icon based on the cardClass
        this.cardTitle = this.cardClass.includes('slds-is-collapsed') ? 'Consumer Info (Collapsed)' : 'Consumer Info';
        this.expandCollapseIcon = this.cardClass.includes('slds-is-collapsed') ? 'utility:chevrondown' : 'utility:chevronup';
        this.expandCollapseAltText = this.cardClass.includes('slds-is-collapsed') ? 'Expand' : 'Collapse';

         // If collapsing, hide the card body
        if (this.cardClass.includes('slds-is-collapsed')) {
            this.opportunity = false;
            } else {
            this.opportunity = { ...this.originalOpportunity }
            }

     }
    
    /**
     * Getters
     */
    get fullName() {
        let retStr = '';
        if(this.opportunity) {
            if(this.opportunity?.Account?.Salutation) {
                retStr += ' ' + this.opportunity.Account.Salutation;
            }
            if(this.opportunity?.Account?.FirstName) {
                retStr += ' ' + this.opportunity.Account.FirstName;
            }
            if(this.opportunity?.Account?.MiddleName) {
                retStr += ' ' + this.opportunity.Account.MiddleName;
            }
            if(this.opportunity?.Account?.LastName) {
                retStr += ' ' + this.opportunity.Account.LastName;
            }
            if(this.opportunity?.Account?.Suffix) {
                retStr += ' ' + this.opportunity.Account.Suffix;
            }
        }
        return retStr;
    }

    get accountGender() {
        return this.opportunity?.Account?.Gender__pc;
    }
    
    get accountAge() {
        return this.opportunity?.Account?.Age__pc;
    }

    get insurancePurpose() {
        return this.opportunity?.InsurancePurpose__c;
    }

    get healthAssessment() {
        return this.opportunity?.HealthAssessment__c;
    }

    get tobaccoUse() {
        return this.opportunity?.TobaccoUse__c;
    }

    get affiliation() {
        return this.opportunity?.Affiliation__r?.Name;
    }

    get proposedAmount() {
        return this.opportunity?.ProposedCoverage__c;
    }

    get accountState() {
        return this.opportunity?.Account?.DomicileState__c;
    }
}

