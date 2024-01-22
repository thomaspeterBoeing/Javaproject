import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
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

export default class ILHSalesCart extends NavigationMixin(LightningElement) {
    _successMessage = '';
    _wiredResult;
    _cartDataCopy = [];

    @track cartData = [];
    @api opptyId;
    errorMessage = '';
    showSpinner = true;//Spinner will turn off in getQuotes function
    totalCoverage = 0;
    totalCost = 0;

    /**
     * Purpose: Gets called when component is connected to page
     */
    connectedCallback() {
        this.subscribeToMessageChannel();       
    }
    
    /**
     * Purpose: Gets called when component is disconnected from page
     */
    disconnectedCallback() {
        unsubscribe(this.subscription);      
    }

    @wire(MessageContext)
    messageContext;
    
    /**
     * Purpose: Subscribes to cart channel message channel
     */
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
        this._wiredResult = value;
        this.errorMessage = '';
        const { data, error } = this._wiredResult;
        if (data) {
            let localList = [...data];
            for (let index = 0; index < localList.length; index++) {
                let itemAction = localList[index]?.action;
                let copiedObj = this._cartDataCopy.find((element) => element?.quoteId === localList[index]?.quoteId);
                localList[index] = {
                    ...localList[index],
                    action:  !itemAction || itemAction === '' ? copiedObj?.action : itemAction,//If action from SF is blank, then take action from copied object
                    disableDelete: itemAction == null ? false : true,//If true, the delete button will be disabled for this cart item
                    savedAction: itemAction,//Saved action indicates the action saved in SF
                    availableActions: this.disableOptions(QUOTE_OPTIONS, itemAction)//Actions available in the UI for this cart item
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
    @api createquote(payload) {
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
            this._cartDataCopy = this.cartData;//Create copy before delete
            refreshApex(this._wiredResult);//Refresh cart data
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
            this._cartDataCopy = this.cartData;//Create copy before insert
            refreshApex(this._wiredResult);//Refresh cart data
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
    updateQuotes(quotesToUpdate) {
        if (quotesToUpdate && quotesToUpdate.length > 0) {
            this.showSpinner = true;
            updateQuotes({ quotes: quotesToUpdate })
            .then(response => {
                //If success, then show message
                const evt = new ShowToastEvent({
                    title: 'Success!',
                    message: this._successMessage,
                    variant: 'success',
                    mode: 'dismissible'
                });
                this.dispatchEvent(evt);
                this._cartDataCopy = this.cartData;//Create copy before update
                refreshApex(this._wiredResult);//Refresh cart data
                this.showSpinner = false;
            }).catch(error => {
                this.errorMessage = reduceErrors(error);
                this.showSpinner = false;
            });
        }
    }

    /**
     * Purpose: This function dis
     * @param {*} availableActions : Actions that are available for current quote
     * @param {*} savedAction : Quote action saved in SF
     * @returns : Quote actions after determining if there were any to be disabled
     */
    disableOptions(availableActions, savedAction) {
        let updatedOptions = [];
        for (let index = 0; index < availableActions.length; index++) {
            let option = availableActions[index];
            let disabled = false;
            //Disable other actions if saved action is Application.  If action is Paper Kit or Email Summary, then disable blank option
            if(!this.errorsOnPage && ((option.value !== 'Application' && savedAction === 'Application') || (!option.value && savedAction))) {
                disabled = true;
            }
            updatedOptions.push({...option, disabled: disabled});
        }
        return updatedOptions;
    }

    /**
     * Purpose: Dertimes quotes to update in SF
     * @returns : Cart items to update
     */
    findQuotesToUpdate() {
        let newCartItems = [];
        let successActions = [];

        for (let index = 0; index < this.cartData.length; index++) {
            let cartItem = this.cartData[index];
            if (this.shouldUpdateQuote(cartItem.action, cartItem.savedAction)) {
                newCartItems.push(this.createQuoteObject(cartItem));
                //We don't show succes message for Application action
                if (cartItem.action !== 'Application' && !successActions.includes(cartItem.action)) {
                    successActions.push(cartItem.action);
                }
            }
        }
        this.createSuccessMessage(successActions)
        return newCartItems;
    }

    /**
     * Purpose: Creates a success message for actions selected
     * @param {*} successActions : Actions the display in success message
     */
    createSuccessMessage(successActions) {
        this._successMessage = '';
        let successActionLength = successActions.length;
        for (let index = 0; index < successActionLength; index++) {
            if (this._successMessage || this._successMessage !== '') {
                //If action list is greater than 2 and the current element is not the second to last element, then append a comma.  Otherwise append "and"
                this._successMessage += successActionLength > 2 && index !== successActionLength - 2 ? ', ' : ' and ';
            } 
            //Append action name to message
            this._successMessage += successActions[index];
        }

        //Add "Requested" at the end of message
        if (this._successMessage || this._successMessage !== '') {
            this._successMessage += ' requested'
        }
    }

    /**
     * Purpose: Determines if a quote record should update or not based on action
     * @param {*} newAction : Action selected from cart UI
     * @param {*} savedAction : Action saved on quote record in SF
     * @returns : True if new action is different from the one saved within SF
     */
    shouldUpdateQuote(newAction, savedAction) {
        return newAction !== savedAction ? true : false;
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

            //Only add cost to total if action is Application
            if (currentCartItem.action === 'Application') {
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
            let quotesToUpdate = this.findQuotesToUpdate();
            this.updateQuotes(quotesToUpdate);
            this.launchCartActions(quotesToUpdate);
        }).catch(error => {
            this.errorMessage = reduceErrors(error);
        });
    }

    /**
     * Purpose: Launches cart actions
     * @param {*} quotesToLaunch : Quotes to launch in new screen
     */
    launchCartActions(quotesToLaunch) {
        for (let index = 0; index < quotesToLaunch.length; index++) {
            let currentCart = quotesToLaunch[index];
            if (currentCart.action === 'Application') {
                //Launch Eapp
                /*this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Account',
                        actionName: 'home',
                    },
                });*/
            }
        }
    }

    /**
     * Purpose: This function finds the quote record where the action was updated, and call updateQutotes function
     * @param {*} event : Event from action picklist
     */
    onActionChange(event) {
        let changedObj = this.cartData.find((element) => element.quoteId === event.target.dataset.id);
        changedObj.action = event.target.value;
        this.calculateTotals();
    }

    /**
     * Purpose: This function transforms payload into a cart item object
     * @param {*} payload : Payload to convert to cart item object
     * @returns : Cart item object
     */
    createQuoteObject(payload) {
        let newCartItem = {
            "productCode": payload?.productCode,
            "paymentFrequency": payload?.paymentFrequency,
            "billingMethod": payload?.billingMethod,
            "coverage": payload?.coverage?.toString(),
            "cost": payload?.cost?.toString(),
            "action": payload?.action,
            "quoteId": payload?.quoteId,
            "oppId": this?.opptyId
        };
        return newCartItem;
    }

    /**
     * Purpose: Returns true if there's any errors on the page
     */
    get errorsOnPage() {
        return this.errorMessage ? true : false;
    }
}