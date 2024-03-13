import { createElement } from 'lwc';
import IlhCartUtil from 'c/ilhCartUtil';
import { publish } from 'lightning/messageService';
import CART_CHANNEL from '@salesforce/messageChannel/Cart__c';

describe('c-ilh-cart-util', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('Cart channel should be published with correct payload', () => {
        const RATE_OBJECT = {
            paymentFrequency: 'monthly',
            billingMethod:  'ACH',
            rateInfo: {
                annual: 81,
                coverage: 45000,
                monthly: 6.75,
                productcode: "2018 ADD Family Contrib",
                productlabel: "ADD Family Contrib",
                quarterly: 20.25,
                semiannual: 40.5
            }
        };

        const PAYLOAD = {
            productCode: RATE_OBJECT.rateInfo.productcode,
            paymentFrequency: 'Monthly',
            billingMethod: RATE_OBJECT.billingMethod,
            coverage: RATE_OBJECT.rateInfo.coverage,
            cost: RATE_OBJECT.rateInfo.monthly
        };

        // Arrange
        const element = createElement('c-ilh-cart-util', {//Create cart until
            is: IlhCartUtil
        });

        document.body.appendChild(element);//Add cart util component to page

        element.publishCartMessage(RATE_OBJECT);

        expect(publish).toHaveBeenCalledWith(undefined, CART_CHANNEL, PAYLOAD);// Was publish called and was it called with the correct params?
    });
});