/**
 * Rate Page LWC to retrieve recordID or any other fields from opportunity. 
 * Was developed for POC purposes. This does not have to go in any page.
 **/
import { LightningElement, wire, track,api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class IlhOpportunityInfo extends LightningElement {
 
    @track currentPageReference;
    @wire(CurrentPageReference)
    
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }

  
    get recordId() {
        return this.currentPageReference?.state?.c__recordId;
    }

    get stage() {
        return this.currentPageReference?.state?.c__stage;
    }

    get coverage() {
        return this.currentPageReference?.state?.c__coverage;
       
    }
  
}
