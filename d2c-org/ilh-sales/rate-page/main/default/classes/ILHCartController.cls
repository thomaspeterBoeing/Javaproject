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
            quotes = [SELECT id, Product__r.Name, Product__r.ProductCode, CoverageAmount__c, Premium__c, Status FROM Quote WHERE OpportunityId =: oppId];

            for (Quote q : quotes) {
                ResultsWrapper newWrap = new ResultsWrapper();
                newWrap.quoteId = q.id;
                newWrap.coverage = q?.CoverageAmount__c;
                newWrap.cost = q?.Premium__c;
                newWrap.productName = q?.Product__r?.Name;
                newWrap.productCode = q?.Product__r?.ProductCode;
                newWrap.decision = q?.Status;
                results.add(newWrap);
            }
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while getting quotes in cart', 'ILHCartController.cls', oppId, 'getQuotes', null, null, null);
        }
        
        return results;
    }

    /**
     * Purpose: This method inserts a new quote record on the give opportunity id
     * @param payload : Contains field information to be inserted
     */
    @AuraEnabled
    public static void insertQuote(Map<String, Object> payload) {
        try {
            Quote newQuote = new Quote();
            newQuote = payloadToQuote(payload);
            insert newQuote;
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while adding quote to cart', 'ILHCartController.cls', null, 'insertQuote', null, null, null);
        }
    }

    /**
     * Purpose: This method updates a quote record
     * @param payload : Contains field information to be updated
     */
    @AuraEnabled
    public static void updateQuote(Map<String, Object> payload) {
        try {
            Quote newQuote = new Quote();
            newQuote = payloadToQuote(payload);
            update newQuote;
        } catch (Exception ex) {
            new ErrorLogger(ex, 'An error occured while updating quote', 'ILHCartController.cls', null, 'updateQuote', null, null, null);
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
     * Purpose: This method transforms payload into a quote object
     * @param payload : Payload to transform into a quote object
     * @return : New quote object
     */
    private static Quote payloadToQuote(Map<String, Object> payload) {
        Quote newQuote = new Quote();
        Id productId;
        String quoteId = (String)payload.get('quoteId');
        String costStr = (String)payload.get('cost');
        String coverageStr = (String)payload.get('coverage');
        String productName = (String)payload.get('productName');
        String productCode = (String)payload.get('productCode');
        String oppId = (String)payload.get('oppId');
        String decision = (String)payload.get('decision');
        Decimal cost = costStr != null ? Decimal.valueOf(costStr) : 0;
        Integer coverage = coverageStr != null ? Integer.valueOf(coverageStr) : 0;

        if (String.isNotEmpty(productCode)) {
            List<Product2> product = new List<Product2>();
            product = [SELECT id FROM Product2 WHERE ProductCode =: productCode];
            productId = product[0].id;
        }

        if (String.isNotEmpty(quoteId)) {
            newQuote.id = quoteId;
        }

        newQuote.Name = 'Test';//TODO: What should we set name to?
        newQuote.OpportunityId = oppId;
        newQuote.CoverageAmount__c = coverage;
        newQuote.Premium__c = cost;
        newQuote.Product__c = productId;
        newQuote.Status = decision;
        return newQuote;
    }

    /**
     * Purpose: Inner wrapper class for results
     * TODO: This will need to be to a different class
     */
    public class ResultsWrapper {
        @AuraEnabled
        public String quoteId;
        @AuraEnabled
        public String oppId;
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String productCode;
        @AuraEnabled
        public Decimal coverage;
        @AuraEnabled
        public Decimal cost;
        @AuraEnabled
        public String decision;
    }
}