import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import CART_CHANNEL from '@salesforce/messageChannel/Cart__c';

const FREQUENCY_TRANSLATION = {
    monthly: 'Monthly',
    semiannual: 'Semi-Annual',
    quarterly: 'Quarterly',
    annual: 'Annual'
};
export default class IlhCartUtil extends LightningElement {
    @wire(MessageContext)
    MessageContext;

   /**
    * Creates a message that is published to the Cart Channel.  This channel is listed to by the Rate iLHSaleCart LWC and creates a quote from this message.
    * @param {*} messageObj
    */
    @api publishCartMessage(messageObj) {
        let frequency = messageObj?.paymentFrequency?.toLowerCase();
        let rateInfo = messageObj?.rateInfo;
        let payload = {
            productCode: rateInfo?.productcode,
            paymentFrequency: FREQUENCY_TRANSLATION[frequency],
            billingMethod: messageObj?.billingMethod,
            coverage: rateInfo?.coverage,
            cost: rateInfo[frequency],
            underwritingClass: messageObj?.uwClass,
            underwritingClassCode: messageObj?.uwClassCode
        }
        publish(this.MessageContext, CART_CHANNEL, payload);
    }
}