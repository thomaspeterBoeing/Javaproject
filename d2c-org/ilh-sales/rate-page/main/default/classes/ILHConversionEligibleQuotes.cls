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
    public ConversionEligibleQuoteWrapper getQuoteResponse(Map<String, Object> rateRequest) {  
           ConversionEligibleQuoteWrapper results = new ConversionEligibleQuoteWrapper();
                
        // Create request to call CEQ endpoint
        ConversionEligibleQuoteRequest ceqRequest = ILHConversionEligibleQuotehelper.createCEQRequest(rateRequest);
        
        // Call helper method to get eligible quotes
        results = ILHConversionEligibleQuotehelper.getEligibleQuotes(ceqRequest);
        
        return results;
    }
}
