/***
Copyright: TruStage
Purpose: This is service layer of the dependency injection marketing services. This is where each concrete marketing service class will be dispatched.
1.0 - Adam Perschke-Ely   - 11/2/2023  - Created for new D2C Salesfore instance.
***/
public class ILHMarketingHistoryService {
    public ILHMarketingHistoryService() {}

    /***
     * The entry point into the dependency injection framework marketing services.
     * @param kvpSearchCriteria -- The search criteria in the format of a key-value-pair mapping
     * @return Returns a list of MarketingService instances from various marketing services.
     */
    public List<ILHMarketingHistoryResultsWrapper> getMarketHistory(Map<String, Object> kvpSearchCriteria) {
        return  dispatchHistoryServices(kvpSearchCriteria);
    }

    /***
     * This method handles the logic for dispatching marketing services.
     * @param kvpSearchCriteria -- The search criteria in the format of a key-value-pair mapping
     * @return Returns a list of IMarketingService instances from various search services.
     */
    private List<ILHMarketingHistoryResultsWrapper> dispatchHistoryServices(Map<String, Object> kvpSearchCriteria) {
        List<ILHMarketingHistoryResultsWrapper> searchResults = new List<ILHMarketingHistoryResultsWrapper>();

        //Get all search class instances
        List<IMarketingHistoryService> classInstances = ILHMarketingHistoryFactory.getInstances();

        for(IMarketingHistoryService classInstance : classInstances) {
            //Call the search history method from the current class instance, and add it to the list of results
            searchResults.addAll(((IMarketingHistoryService)classInstance).getMarketHistory(kvpSearchCriteria));
        }        
        return searchResults;           
    }
}