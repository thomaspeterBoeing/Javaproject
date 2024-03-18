/**********************************************************************************
 * Title:  ILHConversionEligibleQuoteService
 * Date:   Jan 2024
 * 
 * Description:  This is service layer of the dependency injection Conversion Eligible quote services. This is where each concrete Conversion Eligible quote service class will be dispatched.
 * 
 *************************************************************************************/
public class ILHConversionEligibleQuoteService {
    public ILHConversionEligibleQuoteService() {}

    public List<ConversionEligibleQuoteWrapper> checkEligibility(Map<String, Object> quoteRequest){
        List<ConversionEligibleQuoteWrapper> results = new List<ConversionEligibleQuoteWrapper>();

        // Get all search class instances
        List<IConversionEligible> classInstances = ILHConversionEligibleQuoteFactory.getInstances();

        for (IConversionEligible classInstance : classInstances) {
            // Call the checkEligibility method from the current class instance, and add the results to the list
            results.add(((IConversionEligible) classInstance).checkEligibility(quoteRequest));
        }
        system.debug('results from ILHConversionEligibleQuoteService' +results );

        return results;
    }

    public List<EligibleProductRateWrapper> getRates(Map<String, Object> quoteRequest){
        List<EligibleProductRateWrapper> wrapper = new List<EligibleProductRateWrapper>();

        // Get all search class instances
        List<IConversionEligible> classInstances = ILHConversionEligibleQuoteFactory.getInstances();

        for (IConversionEligible classInstance : classInstances) {
            // Call the getRates method from the current class instance, and add the results to the list
            wrapper.add(((IConversionEligible) classInstance).getRates(quoteRequest));
        }
        return wrapper;
    }
}
