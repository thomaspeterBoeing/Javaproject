/**********************************************************************************
 * Title:  ILHConversionEligibleQuotes
 * Date:   Jan 2024
 * 
 * Description:  This class being invoked based on implementation defined in custom metadata. 
 * 
 *************************************************************************************/

 public class ILHConversionEligibleQuotes implements IConversionEligible {
    /**
     * This method gets eligible quote from CEQ end point
     * @param rateRequest -- The criteria is in request
     * @return -- Returns a List of search results from external CEQS service
     */
    public ConversionEligibleQuoteWrapper checkEligibility(Map<String, Object> rateRequest) {  
           ConversionEligibleQuoteWrapper results = new ConversionEligibleQuoteWrapper();
                
        // Create request to call CEQ endpoint
        ConversionEligibleQuoteRequest ceqRequest = ILHConversionEligibleQuotehelper.createCEQRequest(rateRequest);
        
        // Call helper method to get eligible quotes
        results = ILHConversionEligibleQuotehelper.getEligibleQuotes(ceqRequest, false); // false indicates not to include quotes node during checking Eligibility
        
        return results;
    }

    public EligibleProductRateWrapper getRates(Map<String, Object> rateRequest) {
        ConversionEligibleQuoteWrapper results = new ConversionEligibleQuoteWrapper();
        Boolean isTermBeingKept = Boolean.valueOf(rateRequest.get('isTermBeingKept'));
                
        // Create request to call CEQ endpoint
        ConversionEligibleQuoteRequest ceqRequest = ILHConversionEligibleQuotehelper.createCEQRequest(rateRequest);
        
        // Call helper method to get eligible quotes
        results = ILHConversionEligibleQuotehelper.getEligibleQuotes(ceqRequest, true); // true indicates to include quotes node when rates need to be shown.

        List<EligibleProductQuoteResult> epqrs = EligibleProductQuoteResult.parse(results, isTermBeingKept);
        EligibleProductRateWrapper wrapper = new EligibleProductRateWrapper(epqrs);
        return wrapper;
    }
}
