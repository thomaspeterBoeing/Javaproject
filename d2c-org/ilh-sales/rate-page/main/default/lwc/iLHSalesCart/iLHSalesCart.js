import { LightningElement, wire, track, api } from 'lwc';
import { subscribe, MessageContext, unsubscribe } from 'lightning/messageService';
import { refreshApex } from '@salesforce/apex';
import RATE_PAGE_CHANNEL from '@salesforce/messageChannel/Rate_Page__c';
import getQuotes from '@salesforce/apex/ILHCartController.getQuotes';
import deleteQuote from '@salesforce/apex/ILHCartController.deleteQuote';
import insertQuote from '@salesforce/apex/ILHCartController.insertQuote';
import checkout from '@salesforce/apex/ILHCartController.checkout';
import { reduceErrors } from 'c/ldsUtils';//LWC Reduces one or more LDS errors into a string[] of error messages

export default class ILHSalesCart extends LightningElement {
    @api opportunityId = '006DR00000JKEbmYAH';
    @track cartData = [];
    wiredResult;
    errorMessage = '';
    decision = '';
    showSpinner = true;//Spinner will turn off in getQuotes function
    totalCoverage = 0;
    totalCost = 0;

    /**
	 * Purpose: This function gets called when component is connected to page
	 */
    connectedCallback() {
        this.subscribeToMessageChannel(); 
    }
    
    /**
	 * Purpose: This function gets called when component is disconnected from page
	 */
    disconnectedCallback() {
        unsubscribe(this.subscription);      
    }

    /**
	 * Purpose: Wiring message context
	 */
    @wire(MessageContext)
    messageContext;

    /**
     * Purpose: Calls APEX to find quotes for related opportunity
     */
    @wire(getQuotes, {oppId: '$opportunityId'})
    getQuotes(value) {
        this.wiredResult = value;
        const { data, error } = this.wiredResult;
        if (data) { 
            this.cartData = data;
            this.calculateTotals();
            this.showSpinner = false;
        }
        else if (error) {
            this.errorMessage = reduceErrors(error);
            this.showSpinner = false;
        }
    }

    /**
     * Purpose: This function subscribes to rate page message channel
     */
    subscribeToMessageChannel() {        
        this.subscription = subscribe(
            this.messageContext,
            RATE_PAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    /**
     * Purpose: This function creates a new quote object and calls insert quote function
     * @param message : Message that was sent to rate page message channel
     */
    handleMessage(message) {
        let newCartItem = {
            productName: message.productName,
            coverage: message.coverage,
            cost: message.cost
        };
        this.insertQuote(newCartItem);
    }

    /**
     * Purpose: Calls APEX to delete quote record for related quote id
     * @param event : Event from remove button
     */
    deleteQuote(event) {
        this.showSpinner = true;
        deleteQuote({ quoteId: event.target.dataset.id})
        .then(response => {
            refreshApex(this.wiredResult);
            this.showSpinner = false;
        }).catch(error => {
            this.errorMessage = reduceErrors(error);
            this.showSpinner = false;
        });
    }

    /**
     * Purpose: This function calls APEX to create a new quote record
     * @param newCartItem : New cart item object to insert
     */
    insertQuote(newCartItem) {
        this.showSpinner = true;
        insertQuote({ oppId: this.opportunityId})
        .then(response => {
            refreshApex(this.wiredResult);
            this.showSpinner = false;
        }).catch(error => {
            this.errorMessage = reduceErrors(error);
            this.showSpinner = false;
        });
    }

    /**
     * Purpose: This method calculates grand total values
     */
    calculateTotals() {
        this.totalCoverage = 0;
        this.totalCost = 0;
        for(let i = 0; i < this.cartData.length; i++) {
            this.totalCoverage += parseInt(this.cartData[i].coverage);
            this.totalCost += parseInt(this.cartData[i].cost);
        }
    }

    handleCheckout() {
        checkout()
        .then(response => {
        }).catch(error => {
            this.errorMessage = reduceErrors(error);
        });
    }

    /**
     * Purpose: Getting decision options to display in picklists for each quote record in the cart
     * TODO: This will be moved to an APEX class where it will return option based on product and state
     */
    get decisionOptions() {
        return [
            { label: '', value: '' },
            { label: 'Application', value: 'Application' },
            { label: 'Paper Kit', value: 'Paper Kit' },
            { label: 'Email Summary', value: 'Email Summary' },
        ];
    }
}