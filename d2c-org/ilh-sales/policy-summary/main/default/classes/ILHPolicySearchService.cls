public without sharing class ILHPolicySearchService {

    public ILHPolicySearchService() {}
    
    public List<ILHPolicyResultsWrapper> runSearch(String SearchCriteria) {
        return  dispatchSearchServices(SearchCriteria);
    }

    /***
     * This method handles the logic for dispatching search services.
     *
     * @param SearchCriteria -- The search criteria in the format of a string
     *
     * @return Returns a list of diISearchService instances from various search services.
     */
    private List<ILHPolicyResultsWrapper> dispatchSearchServices(String SearchCriteria) {
        List<ILHPolicyResultsWrapper> searchResults = new List<ILHPolicyResultsWrapper>();

        //Get all search class instances
        List<IPolicySearch> classInstances = ILHPolicyFactory.getInstances();

        for(IPolicySearch classInstance : classInstances) {
            //Call the search method from the current class instance, and add it to the list of search results
            searchResults.addAll(((IPolicySearch)classInstance).search(SearchCriteria));
        }        
       return searchResults;          
    }
}