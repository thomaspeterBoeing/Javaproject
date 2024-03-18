/**********************************************************************************
 * Title:  ILH Sales Rate Page LWC
 * Date:   Jan 2024
 * 
 * Description:  LWC used to display components for Rate Page
 * 
 * Details:      This component is the parent several components used for creating quotes.
 * 
 * Parameters:    coverage = Proposed coverage amount which will be used to filter the rates
 *                by a low and high range for the proposed coverage.c/consumerDetails
 * 
 *                opptyId = Id for the opportunity record.  This is passed to the elligible quote service to 
 *                get product and rate info.
 * 
 * Modifications:
 *************************************************************************************/
import { LightningElement,api,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { setTabLabel,setTabIcon,EnclosingTabId } from 'lightning/platformWorkspaceApi';

export default class IlhSalesRatePage extends LightningElement {
    coverage = null;
    recID=null;
    optyState=null;
    highResolution = true;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
        
        this.coverage = currentPageReference.state?.c__coverage;
        this.recID = currentPageReference.state?.c__recordId;
        this.optyState = currentPageReference.state?.c__optyState;
       }
    }

    //Change name of console tab.
    @wire(EnclosingTabId) enclosingTabId;
    
    connectedCallback(){     
        
        setTabLabel(this.enclosingTabId, "Rates");
        setTabIcon(this.enclosingTabId, "action:quote");
        
    }


    
}