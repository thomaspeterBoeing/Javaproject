import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { MessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CART_CHANNEL from '@salesforce/messageChannel/Cart__c';
import getQuotes from '@salesforce/apex/ILHCartController.getQuotes';
import deleteQuote from '@salesforce/apex/ILHCartController.deleteQuote';
import insertQuote from '@salesforce/apex/ILHCartController.insertQuote';
import updateQuotes from '@salesforce/apex/ILHCartController.updateQuotes';
import checkout from '@salesforce/apex/ILHCartController.checkout';
import { reduceErrors } from 'c/ldsUtils';//LWC Reduces one or more LDS errors into a string[] of error messages

const QUOTE_OPTIONS = [
    { label: '', value: ''},
    { label: 'Application', value: 'Application'},
    { label: 'Paper Kit', value: 'Paper Kit' },
    { label: 'Email Summary', value: 'Email Summary'},
];

export default class ILHSalesCart extends LightningElement {
    _successMessage = '';

    @track cartData = [];
    @api opptyId;
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
    @wire(getQuotes, {oppId: '$opptyId'})
    getQuotes(value) {
        this.wiredResult = value;
        this.errorMessage = '';
        const { data, error } = this.wiredResult;
        if (data) {
            let localList = [...data];
            for (let index = 0; index < localList.length; index++) {
                let itemDecision = localList[index]?.decision;
                localList[index] = {
                    ...localList[index], 
                    disableDelete: itemDecision == null ? false : true,
                    savedDecision: itemDecision,
                    availableActions: this.disableOptions(QUOTE_OPTIONS, itemDecision)
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
    updateQuotes() {
        this.showSpinner = true;
        updateQuotes({ quotes: this.findQuotesToUpdate() })
        .then(response => {
            const evt = new ShowToastEvent({
                title: 'Success!',
                message: this._successMessage,
                variant: 'success',
                mode: 'dismissible'
            });
            this.dispatchEvent(evt);

            refreshApex(this.wiredResult);
            this.showSpinner = false;
        }).catch(error => {
            this.errorMessage = reduceErrors(error);
            this.showSpinner = false;
        });
    }

    disableOptions(availableOptions, savedDecision) {
        let updatedOptions = [];
        for (let index = 0; index < availableOptions.length; index++) {
            let option = availableOptions[index];
            let disabled = false;
            if(!this.errorsOnPage && ((option.value !== 'Application' && savedDecision === 'Application') || (!option.value && savedDecision))) {
                disabled = true;
            }
            updatedOptions.push({...option, disabled: disabled});
        }
        return updatedOptions;
    }

    findQuotesToUpdate() {
        let newCartItems = [];
        let successDecisions = [];

        for (let index = 0; index < this.cartData.length; index++) {
            let cartItem = this.cartData[index];
            if (this.shouldUpdateQuote(cartItem.decision, cartItem.savedDecision)) {
                newCartItems.push(this.createQuoteObject(cartItem));
                if (cartItem.decision !== 'Application' && !successDecisions.includes(cartItem.decision)) {
                    successDecisions.push(cartItem.decision);
                }
            }
        }
        this.createSuccessMessage(successDecisions)
        return newCartItems;
    }

    createSuccessMessage(successDecisions) {
        this._successMessage = '';
        for (let index = 0; index < successDecisions.length; index++) {
            if (this._successMessage || this._successMessage !== '') {
                this._successMessage += ' and ';
            } 
            this._successMessage += successDecisions[index];
        }
        if (this._successMessage || this._successMessage !== '') {
            this._successMessage += ' requested'
        }
    }

    shouldUpdateQuote(newDecision, savedDecision) {
        if (newDecision !== savedDecision) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * Purpose: This method calculates grand total values
     */
    calculateTotals() {
        this.totalCoverage = 0;
        this.totalCost = 0;
        for(let i = 0; i < this.cartData.length; i++) {
            let currentCartItem = this.cartData[i];
            this.totalCoverage += parseFloat(currentCartItem.coverage);

            if (currentCartItem.decision === 'Application') {
                this.totalCost += parseFloat(currentCartItem.cost);
            }
        }
    }

    /**
     * Purpose: This function call APEX checkout method
     */
    handleCheckout() {
        checkout()
        .then(response => {
            this.updateQuotes();
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
        this.calculateTotals();
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
            "oppId": this?.opptyId
        };
        return newCartItem;
    }

    get errorsOnPage() {
        if (this.errorMessage) {
            return true;
        } else {
            return false;
        }
    }
}