import { LightningElement, wire, track } from 'lwc';
import { subscribe, MessageContext, unsubscribe } from 'lightning/messageService';
import RATE_PAGE_CHANNEL from '@salesforce/messageChannel/Rate_Page__c';

const columns = [      
    {label: 'Product Name', fieldName: 'productName', type: 'text', sortable: true},
    {label: 'Coverage', fieldName: 'coverage', type: 'currency', sortable: true},
    {label: 'Premium', fieldName: 'premium', type: 'currency', sortable: true},
    {
        type:"button",
        fixedWidth: 150,
        typeAttributes: {
            label: 'Remove',
            name: 'remove',
            variant: 'brand'
        }
    }
];

const cartData = [
    {
        id: '1234',
        productName: 'AD&D Basic',
        coverage: 2000,
        premium: 0
    }
]
export default class ILHSalesCart extends LightningElement {
    decision = '';
    columns = columns;
    @track cartData = [];
    totalCoverage = 0;
    totalPremium = 0;

    connectedCallback() {
        this.subscribeToMessageChannel();       
    }
    
    disconnectedCallback() {
        unsubscribe(this.subscription);      
    }

    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {        
        this.subscription = subscribe(
            this.messageContext,
            RATE_PAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        let newCartItem = {
            id: "ci" + this.cartData.length + 1,
            productName: message.productName,
            coverage: message.coverage,
            premium: message.premium
        };
        this.cartData.push(newCartItem);
        this.calculateTotals();
    }

    calculateTotals() {
        this.totalCoverage = 0;
        this.totalPremium = 0;
        for(let i = 0; i < this.cartData.length; i++) {
            this.totalCoverage += parseInt(this.cartData[i].coverage);
            this.totalPremium += parseInt(this.cartData[i].premium);
        }
    }

    handleRemoveItem(event) {
        this.cartData = this.cartData.filter(row => row.id !== event.target.dataset.id);
        this.calculateTotals();
    }

    get decisionOptions() {
        return [
            { label: '', value: '' },
            { label: 'Application', value: 'Application' },
            { label: 'Paper Kit', value: 'Paper Kit' },
            { label: 'Email Summary', value: 'Email Summary' },
        ];
    }
}