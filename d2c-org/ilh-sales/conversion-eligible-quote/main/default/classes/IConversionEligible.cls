/**********************************************************************************
 * Title:  Conversion Eligible Quote Service Interface
 * Date:   Jan 2024
 * 
 * Description:  This is the interface for Conversion Eligible Quote Service.  
 *  
 * Details    :  The interface definition that all concrete search service classes will implement         
 * Modifications:
 *************************************************************************************/
public interface IConversionEligible {
/***
     * The entry point into the dependency injection framework.
     *
     * @param quoteRequest -- request in the format of a key-value-pair mapping
     *
     * @return Returns an instance of ConversionEligibleRateWrapper class
     */
    List<ConversionEligibleQuoteWrapper> getQuoteResponse(Map<String, Object> quoteRequest);
}