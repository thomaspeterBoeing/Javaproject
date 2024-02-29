/**
 * Copyright: TruStage
 * Purpose: Used in LWC.
 * Request object to interact with the Conversion Eligible Quote service.
 */
public with sharing class ConversionEligibleQuoteController {
    /**
    * Purpose: ConversionEligible - Search by providing Policy number.
    * @param kvpRequestCriteria : Criteria to search CEQS
    * @return : An instance of the ConversionEligibleQuoteWrapper class with results.
   */
   @AuraEnabled
   public static list<ConversionEligibleQuoteWrapper> search(Map<String, Object> kvpRequestCriteria) {   
    //system.debug (new ILHConversionEligibleQuoteService().getEligibleRates(kvpRequestCriteria));   
       return (new ILHConversionEligibleQuoteService()).getEligibleRates(kvpRequestCriteria);
   }

}