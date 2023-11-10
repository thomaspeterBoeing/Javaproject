/**
 * Copyright: TruStage
 * Purpose: This is service layer of the dependency injection search services.
 *          This is where each concrete search service class will be dispatched
 */
public class ILHSearchService {
    public ILHSearchService() {}

    /**
     * Purpose: The entry point into the dependency injection framework search services.
     * @param kvpSearchCriteria -- The search criteria in the format of a key-value-pair mapping
     * @return Returns an instance ILHConsumerResultsWrapper from various search services.
     */
    public ILHConsumerResultsWrapper runSearch(Map<String, Object> kvpSearchCriteria) {
        return  dispatchSearchServices(kvpSearchCriteria);//We only return one instance of the wrapper the contains merged errors and results from various search services.
    }

    /**
     * Purpose: This method handles the logic for dispatching search services.
     * @param kvpSearchCriteria -- The search criteria in the format of a key-value-pair mapping
     * @return Returns a list of diISearchService instances from various search services.
     */
    private ILHConsumerResultsWrapper dispatchSearchServices(Map<String, Object> kvpSearchCriteria) {
        List<ILHConsumerResultsWrapper> searchResults = new List<ILHConsumerResultsWrapper>();

        //Get all search class instances
        List<ISearchService> classInstances = ILHSearchFactory.getInstances();

        for(ISearchService classInstance : classInstances) {
            //Call the search method from the current class instance, and add it to the list of search results
            searchResults.addAll(((ISearchService)classInstance).search(kvpSearchCriteria));
        }         
        return (new ILHSearchMergeImpl()).mergeResults(searchResults);//We only return one instance of the wrapper the contains merged errors and results from various search services.           
    }
}