import { LightningElement,api,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { setTabLabel,setTabIcon,EnclosingTabId } from 'lightning/platformWorkspaceApi';

export default class IlhSalesRatePage extends LightningElement {
    coverage = null;
    recID=null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
        this.coverage = currentPageReference.state?.c__coverage;
        this.recID = currentPageReference.state?.c__recordId;
       }
    }

    //Change name of console tab.
    @wire(EnclosingTabId) enclosingTabId;
    
    connectedCallback(){
        console.log("Parameters in ilh sales rate page = ");
        console.log('Coverage = ' + this.coverage);
        console.log('rec id = ' + this.recID);
        setTabLabel(this.enclosingTabId, "Rates");
        setTabIcon(this.enclosingTabId, "action:quote");
    }



    


    
}