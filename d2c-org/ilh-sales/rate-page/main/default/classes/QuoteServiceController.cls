public with sharing class QuoteServiceController {

    @AuraEnabled(cacheable=true)
    public static EligibleProductRateWrapper getRates(Id oppId){
        return (new EligibleRateService()).getRates(oppId);
    }
}