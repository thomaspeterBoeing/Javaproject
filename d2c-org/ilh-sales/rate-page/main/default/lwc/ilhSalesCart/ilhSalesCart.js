import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { MessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import CART_CHANNEL from '@salesforce/messageChannel/Cart__c';
import getQuotes from '@salesforce/apex/ILHCartController.getQuotes';
import deleteQuote from '@salesforce/apex/ILHCartController.deleteQuote';
import insertQuote from '@salesforce/apex/ILHCartController.insertQuote';
import updateQuote from '@salesforce/apex/ILHCartController.updateQuote';
import checkout from '@salesforce/apex/ILHCartController.checkout';
import { reduceErrors } from 'c/ldsUtils';//LWC Reduces one or more LDS errors into a string[] of error messages

export default class ILHSalesCart extends LightningElement {
    @api opportunityId = '006DC00000RKlVCYA1';
    @track cartData = [];
    wiredResult;
    errorMessage = '';
    decision = '';
    showSpinner = true;//Spinner will turn off in getQuotes function
    totalCoverage = 0;
    totalCost = 0;

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
            CART_CHANNEL,
            (message) => this.createquote(message)
        );
    }

    /**
     * Purpose: Calls APEX to find quotes for related opportunity
     */
    @wire(getQuotes, {oppId: '$opportunityId'})
    getQuotes(value) {
        this.wiredResult = value;
        this.errorMessage = '';
        const { data, error } = this.wiredResult;
        if (data) {
            let localList = [...data];
            for (let index = 0; index < localList.length; index++) {
                localList[index] = {
                    ...localList[index], 
                    disableDelete: localList[index]?.decision == null ? false : true
                };
            }
            this.cartData = localList;
            this.calculateTotals();
            this.showSpinner = false;
        }
        else if (error) {
            this.errorMessage = reduceErrors(error);
            this.showSpinner = false;
        }
    }

    /**
     * Purpose: This function creates a new quote object and calls insert quote function
     * @param payload : Payload from a rate that was clicked in matrix
     */
    @api
    createquote(payload) {
        this.insertQuote(this.createQuoteObject(payload));
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
        insertQuote({ payload: newCartItem})
        .then(response => {
            refreshApex(this.wiredResult);
            this.showSpinner = false;
        }).catch(error => {
            this.errorMessage = reduceErrors(error);
            this.showSpinner = false;
        });
    }

    /**
     * Purpose: This function calls APEX to update quote record
     * @param cartItem : Cart item to update
     */
    updateQuote(cartItem) {
        this.showSpinner = true;
        updateQuote({ payload: cartItem })
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

    /**
     * Purpose: This function call APEX checkout method
     */
    handleCheckout() {
        checkout()
        .then(response => {
        }).catch(error => {
            this.errorMessage = reduceErrors(error);
        });
    }

    /**
     * Purpose: This function finds the quote record where the decision was updated, and call updateQutote function
     * @param event : Event from decision picklist
     */
    onDecisionChange(event) {
        let changedObj = this.cartData.find((element) => element.quoteId === event.target.dataset.id);
        changedObj.decision = event.target.value;
        this.updateQuote(this.createQuoteObject(changedObj));
    }

    /**
     * Purpose: This function transforms payload into a cart item object
     * @param payload : Payload to convert to cart item object
     * @returns : Cart item object
     */
    createQuoteObject(payload) {
        let newCartItem = {
            "productCode": payload?.productCode,
            "paymentFrequency": payload?.paymentFrequency,
            "billingMethod": payload?.billingMethod,
            "coverage": payload?.coverage?.toString(),
            "cost": payload?.cost?.toString(),
            "decision": payload?.decision,
            "quoteId": payload?.quoteId,
            "oppId": this?.opportunityId
        };
        return newCartItem;
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