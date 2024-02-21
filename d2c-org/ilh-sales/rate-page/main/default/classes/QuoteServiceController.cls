public with sharing class QuoteServiceController {

    @AuraEnabled(cacheable=true)
    public static EligibleProductRateWrapper getRates(Map<String, Object> requestMap){
        return (new EligibleRateService()).getRates(requestMap);
    }
}