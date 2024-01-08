/***
Copyright: TruStage
Purpose: This is service layer of the dependency injection product quote services. This is where each concrete product quote service class will be dispatched.
1.0 - Adam Perschke-Ely   - 11/2/2023  - Created for new D2C Salesfore instance.
***/
public class ILHProductQuoteService {
    public ILHProductQuoteService() {}

   

    public ConsumerEligibleQuoteResponse.QuoteResponse getAvailableProducts(Map<String, Object> productRequest){
        return dispatchAvailableProductServices(productRequest);
    }

    /***
     * This method handles the logic for dispatching product quote rate services.
     * @param rateRequest -- Rate request in the format of a key-value-pair mapping
     * @return Returns an instance of the RateQuoteDataGrid.
     */
    
     private ConsumerEligibleQuoteResponse.QuoteResponse dispatchAvailableProductServices(Map<String, Object> rateRequest) {
        ConsumerEligibleQuoteResponse.QuoteResponse results=new ConsumerEligibleQuoteResponse.QuoteResponse();

        //Get all search class instances
        List<IProductQuoteService> classInstances = ILHProductQuoteFactory.getInstances();

        for(IProductQuoteService classInstance : classInstances) {
            //Call the getRates method from the current class instance, and assign it to the grid
            results = ((IProductQuoteService)classInstance).getQuoteResponse(rateRequest);
        }        
        return results;           
    }

    
    
   
}