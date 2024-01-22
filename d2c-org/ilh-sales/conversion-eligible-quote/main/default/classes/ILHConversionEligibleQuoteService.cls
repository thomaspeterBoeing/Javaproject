/**********************************************************************************
 * Title:  ILHConversionEligibleQuoteService
 * Date:   Jan 2024
 * 
 * Description:  This is service layer of the dependency injection Conversion Eligible quote services. This is where each concrete Conversion Eligible quote service class will be dispatched.
 * 
 *************************************************************************************/
public class ILHConversionEligibleQuoteService {
    public ILHConversionEligibleQuoteService() {}

    public List<ConversionEligibleQuoteWrapper> getEligibleRates(Map<String, Object> quoteRequest){
        return dispatchCEQServices(quoteRequest); // CEQ here stands for -> Conversion Eligible Quote
    }

    /***
     * This method handles the logic for dispatching Conversion Eligible rate services.
     * @param rateRequest -- Rate request in the format of a Map
     * @return Returns an instance of the ConversionEligibleQuoteWrapper.
     */
    private List<ConversionEligibleQuoteWrapper> dispatchCEQServices(Map<String, Object> rateRequest) {
        List<ConversionEligibleQuoteWrapper> results = new List<ConversionEligibleQuoteWrapper>();

        // Get all search class instances
        List<IConversionEligible> classInstances = ILHConversionEligibleQuoteFactory.getInstances();

        for (IConversionEligible classInstance : classInstances) {
            // Call the getRates method from the current class instance, and add the results to the list
            results.addAll(((IConversionEligible) classInstance).getQuoteResponse(rateRequest));
        }

        return results;
    }
}
