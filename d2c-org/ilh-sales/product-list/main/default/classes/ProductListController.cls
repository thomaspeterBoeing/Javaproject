public with sharing class ProductListController {
    @AuraEnabled
    public static List<ProductQuoteResult> getEligibleQuotes(Map<String, Object> requestObj) {
      
      String reqString = JSON.serialize(requestObj, true);   
      
      ConsumerEligibleQuoteResponse.QuoteResponse response=new ILHProductQuoteService().getAvailableProducts(requestObj);
      List<ProductQuoteResult> pqrlst = new list<ProductQuoteResult>();
     
      for(ConsumerEligibleQuoteResponse.ProductQuotes pr:response.productQuotes ){
         if(pr.insuranceProductDetails!=null && pr.InsuranceProductDetails.returnFlag){
             pqrlst.add(new ProductQuoteResult(pr));
         }
      }
      pqrlst = ProductListRulesHelper.applyProductRules(pqrlst);
      return pqrlst ;
    }

    @AuraEnabled
    public static Opportunity getOpportunity(String oppoId) {  
      Opportunity opp = new Opportunity();
      try {
         opp = [SELECT Id, Name,TobaccoUse__c, AccountId,Account.ContractNumberUnformatted__c, Account.ContractNumberFormatted__c, Account.PersonMailingState, Account.Gender__pc	,Account.DomicileState__c, Account.BillingPostalCode,  Account.Age__pc,Account.PersonBirthDate, Affiliation__r.ContractNumberUnformatted__c From Opportunity WHERE Id=:oppoId];
      } catch(Exception ex) {
         new ErrorLogger(ex, 'An error occured while getting opportunity.', 'ProductListController.cls', oppoId, 'Get Opportunity', null, null, null);     
      }  
      return opp;
    }

    
}