/**
 * Copyright: TruStage
 * Purpose: Controller for iLHSalesCart LWC
 */
public with sharing class ILHCartController {
    /**
     * Purpose: This method gets quotes related to the given opportunity id
     * @param oppId : Opportunity id to get related quotes
     */
    @AuraEnabled(cacheable=true)
    public static List<ILHQuoteHelper.ResultsWrapper> getQuotes(String oppId) {
        return new ILHQuoteHelper().getQuotes(oppId);
    }

    /**
     * Purpose: This method inserts a new quote record on the give opportunity id
     * @param payload : Contains field information to be inserted
     */
    @AuraEnabled
    public static void insertQuote(Map<String, Object> payload) {
        new ILHQuoteHelper().insertQuote(payload);
    }

    /**
     * Purpose: This method updates quote record from cart
     * @param quotes : Contains quote record from cart that need to be updated
     */
    @AuraEnabled
    public static void updateQuotes(List<Map<String, Object>> quotes) {
        new ILHQuoteHelper().updateQuotes(quotes);
    }

    /**
     * Purpose: This method deletes quote for a given id
     * @param quoteId : Id of quote to delete
     */
    @AuraEnabled
    public static void deleteQuote(String quoteId) {
        new ILHQuoteHelper().deleteQuote(quoteId);
    }

    /**
     * Purpose: Logic for checkout
     */
    @AuraEnabled
    public static void checkout() {
        try {
            System.debug('Cart checkout');
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured during checkout', 'ILHCartController.cls', null, 'checkout', null, null, null);
        }
    }
}