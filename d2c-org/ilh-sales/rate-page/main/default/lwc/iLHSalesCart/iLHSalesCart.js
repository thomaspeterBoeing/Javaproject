import { LightningElement, wire, track, api } from 'lwc';
import { subscribe, MessageContext, unsubscribe } from 'lightning/messageService';
import RATE_PAGE_CHANNEL from '@salesforce/messageChannel/Rate_Page__c';
import getQuotes from '@salesforce/apex/ILHCartController.getQuotes';
import deleteQuote from '@salesforce/apex/ILHCartController.deleteQuote';
import insertQuote from '@salesforce/apex/ILHCartController.insertQuote';
import { reduceErrors } from 'c/ldsUtils';//LWC Reduces one or more LDS errors into a string[] of error messages

export default class ILHSalesCart extends LightningElement {
    @api recordId;
    decision = '';
    @track cartData = [];
    showSpinner = false;
    totalCoverage = 0;
    totalCost = 0;

    connectedCallback() {
        this.subscribeToMessageChannel(); 
        this.findQuotes();     
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
            cost: message.cost
        };
        this.insertQuote();
    }

    findQuotes() {
        this.showSpinner = true;
        getQuotes({ oppId: this.recordId})
        .then(response => {
            this.cartData = response;
            this.calculateTotals();
            this.showSpinner = false;
        }).catch(error => {
            console.log(reduceErrors(error));
            this.showSpinner = false;
        });
    }

    deleteQuote(event) {
        this.showSpinner = true;
        deleteQuote({ quoteId: event.target.dataset.id})
        .then(response => {
            this.findQuotes();
            this.showSpinner = false;
        }).catch(error => {
            console.log(reduceErrors(error));
            this.showSpinner = false;
        });
    }

    insertQuote() {
        this.showSpinner = true;
        insertQuote({ oppId: this.recordId})
        .then(response => {
            this.findQuotes();
            this.showSpinner = false;
        }).catch(error => {
            console.log(reduceErrors(error));
            this.showSpinner = false;
        });
    }

    calculateTotals() {
        this.totalCoverage = 0;
        this.totalCost = 0;
        for(let i = 0; i < this.cartData.length; i++) {
            this.totalCoverage += parseInt(this.cartData[i].coverage);
            this.totalCost += parseInt(this.cartData[i].cost);
        }
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