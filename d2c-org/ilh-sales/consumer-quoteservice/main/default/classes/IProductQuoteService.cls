/***
Copyright: CUNA Mutual Group
Purpose: The interface definition that all concrete product quote service classes will implement.
1.0 - Adam Perschke-Ely   - 12/29/2023  - Created for new D2C Salesfore instance.
***/
public interface IProductQuoteService {
    /***
     * The entry point into the dependency injection framework product quote services.
     * @param rateRequest -- Rate request in the format of a key-value-pair mapping
     * @return Returns an instance of the RateQuoteDataGrid class
     */
    
    ConsumerEligibleQuoteResponse.QuoteResponse getQuoteResponse(Map<String, Object> productRequest);
}