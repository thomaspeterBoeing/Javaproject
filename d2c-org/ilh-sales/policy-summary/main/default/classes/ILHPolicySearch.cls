public  class ILHPolicySearch implements IPolicySearch{
    
    /**
     * This method searches CPS for Policy Summary
     * @param SearchCriteria -- The search criteria in the format of string
     * @return -- Returns a List of search results from CPS
     */
    public List<ILHPolicyResultsWrapper> search(String SearchCriteria) {
        
        List<ILHPolicyResultsWrapper> results = new List<ILHPolicyResultsWrapper>();
                
        //Call CPS for Policy Summary based on the search criteria passed into this method
        PolicySearchRequest searchRequest = ILHPolicySearchHelper.createPolicySearchRequest(SearchCriteria, 1);
        results = ILHPolicySearchHelper.searchCPS(searchRequest);
        
        return results;
    }
}