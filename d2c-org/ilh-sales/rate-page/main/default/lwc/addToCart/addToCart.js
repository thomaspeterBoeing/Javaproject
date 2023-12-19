import { LightningElement } from 'lwc';

export default class AddToCart extends LightningElement {
    productName = '';
    coverage = 0;
    cost = 0;
    opportunityId = '006DR00000JKEbmYAH';

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
        this.template.querySelector("c-ilh-sales-cart").createquote(payload);
    }
}