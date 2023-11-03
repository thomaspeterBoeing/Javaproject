import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { FlowNavigationNextEvent} from 'lightning/flowSupport';
export default class IlhFlowFooter extends LightningElement {
    @api availableActions = [];
    handleNext() {
        if (this.availableActions.find((action) => action === 'NEXT')) {
            // navigate to the next screen
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
    handleCancel() {
        window.close();
        //this.dispatchEvent(new CloseActionScreenEvent());
    }
}