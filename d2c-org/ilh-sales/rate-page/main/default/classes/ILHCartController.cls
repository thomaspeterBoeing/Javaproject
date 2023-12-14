public with sharing class ILHCartController {
    @AuraEnabled
    public static List<ResultsWrapper> getQuotes(String oppId) {
        List<Quote> quotes = new List<Quote>();
        List<ResultsWrapper> results = new List<ResultsWrapper>();

        quotes = [SELECT id FROM Quote WHERE OpportunityId =: oppId];

        for (Integer i = 0; i < quotes.size(); i++) {
            ResultsWrapper newWrap = new ResultsWrapper();
            newWrap.id = quotes[i].id;
            newWrap.coverage = i;
            newWrap.cost = i;
            newWrap.productName = 'Test' + i;
            results.add(newWrap);
        }
        return results;
    }

    @AuraEnabled
    public static void insertQuote(String oppId) {
        Quote newQuote = new Quote();
        newQuote.Name = 'Test';
        newQuote.OpportunityId = oppId;
        insert newQuote;
    }

    @AuraEnabled
    public static void deleteQuote(String quoteId) {
        delete [SELECT id FROM Quote WHERE id =: quoteId];
    }

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