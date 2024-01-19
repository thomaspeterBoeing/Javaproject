import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class IlhSalesRatePage extends LightningElement {
    recID=null;
   
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.recID = currentPageReference.state?.c__recordId;
          console.log('recid--'+this.recID);
       }
    }
}