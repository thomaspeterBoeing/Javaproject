import { LightningElement, api } from 'lwc';
import getOpportunityFieldsData from '@salesforce/apex/ConsumerInfoController.getOpportunityFieldsData';
import { reduceErrors } from 'c/ldsUtils';

export default class ILHSalesConsumerInfo extends LightningElement {
    @api opportunityId = '006DS00000LZR0VYAX';

    errorMessage = undefined;
    accountName;
    insurancePurpose;
    healthAssessment;
    tobaccoUse;
    affiliation;
    proposedAmount;
    accountState;
    opportunity;

    connectedCallback() {
        this.getOpportunityFields();
    }  

    getOpportunityFields() {
        getOpportunityFieldsData({opportunityId : this.opportunityId}).then(data =>{				
			this.opportunity = data;	
		}).catch(error =>{
			this.errorMessage = reduceErrors(error);
		});
    }
    
    get fullName() {
        let retStr = '';
        if(this.opportunity) {
            if(this.opportunity.Account.Salutation) {
                retStr += ' ' + this.opportunity.Account.Salutation;
            }
            if(this.opportunity.Account.FirstName) {
                retStr += ' ' + this.opportunity.Account.FirstName;
            }
            if(this.opportunity.Account.MiddleName) {
                retStr += ' ' + this.opportunity.Account.MiddleName;
            }
            if(this.opportunity.Account.LastName) {
                retStr += ' ' + this.opportunity.Account.LastName;
            }
            if(this.opportunity.Account.Suffix) {
                retStr += ' ' + this.opportunity.Account.Suffix;
            }
        }
        return retStr;
    }

    get accountGender() {
        return this.opportunity ? this.opportunity.Account.Gender__pc : '';
    }
    
    get accountAge() {
        return this.opportunity ? this.opportunity.Account.Age__pc : '';
    }

    get insurancePurpose() {
        return this.opportunity ? this.opportunity.InsurancePurpose__c : '';
    }

    get healthAssessment() {
        return this.opportunity ? this.opportunity.HealthAssessment__c : '';
    }

    get tobaccoUse() {
        return this.opportunity ? this.opportunity.TobaccoUse__c : '';
    }

    get affiliation() {
        return this.opportunity ? this.opportunity.Affiliation__r.Name : '';
    }

    get proposedAmount() {
        return this.opportunity ? this.opportunity.Amount : '';
    }

    get accountState() {
        return this.opportunity ? this.opportunity.Account.DomicileState__c : '';
    }
}

