public with sharing class QuoteServiceController {

    @AuraEnabled(cacheable=true)
    public static EligibleProductRateWrapper getRates(Id oppId,String productCategory,String frequency,String billingMethodCode){
        return (new EligibleRateService()).getRates(oppId,productCategory,frequency,billingMethodCode);
    }
}