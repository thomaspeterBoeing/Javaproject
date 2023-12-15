import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import RATE_PAGE_CHANNEL from '@salesforce/messageChannel/Rate_Page__c';

export default class AddToCart extends LightningElement {
    productName = '';
    coverage = 0;
    cost = 0;

    @wire(MessageContext)
    MessageContext;

    handleProductNameChange(event) {
        this.productName = event.detail.value;
    }

    handleCoverageChange(event) {
        this.coverage = event.detail.value;
    }

    handleCostChange(event) {
        this.cost = event.detail.value;
    }

    addToCart() {
        let payload = {
            productName: this.productName,
            coverage: this.coverage,
            cost: this.cost
        };
        publish(this.MessageContext, RATE_PAGE_CHANNEL, payload);
    }
}