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
    public static List<ResultsWrapper> getQuotes(String oppId) {
        List<Quote> quotes = new List<Quote>();
        List<ResultsWrapper> results = new List<ResultsWrapper>();

        try {
            quotes = [SELECT id FROM Quote WHERE OpportunityId =: oppId];

            for (Integer i = 0; i < quotes.size(); i++) {
                ResultsWrapper newWrap = new ResultsWrapper();
                newWrap.id = quotes[i].id;
                newWrap.coverage = i;
                newWrap.cost = i;
                newWrap.productName = 'Test' + i;
                results.add(newWrap);
            }
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while getting quotes in cart', 'ILHCartController.cls', oppId, 'getQuotes', null, null, null);
        }
        
        return results;
    }

    /**
     * Purpose: This method inserts a new quote record on the give opportunity id
     * @param oppId : Id of opportunity that a quote will be inserted on
     */
    @AuraEnabled
    public static void insertQuote(String oppId) {
        try {
            Quote newQuote = new Quote();
            newQuote.Name = 'Test';
            newQuote.OpportunityId = oppId;
            insert newQuote;
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while adding quote to cart', 'ILHCartController.cls', oppId, 'insertQuote', null, null, null);
        }
        
    }

    /**
     * Purpose: This method deletes quote for a given id
     * @param quoteId : Id of quote to delete
     */
    @AuraEnabled
    public static void deleteQuote(String quoteId) {
        try {
            delete [SELECT id FROM Quote WHERE id =: quoteId];  
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while removing quote from cart', 'ILHCartController.cls', quoteId, 'deleteQuote', null, null, null);
        }
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

    /**
     * Purpose: Inner wrapper class for results
     * TODO: This will need to be to a different class
     */
    public class ResultsWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public Integer coverage;
        @AuraEnabled
        public Integer cost;
    }
}