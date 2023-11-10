/***
Copyright: CUNA Mutual Group
Purpose: The interface definition that all concrete marketing history service classes will implement.
1.0 - Adam Perschke-Ely   - 11/2/2023  - Created for new D2C Salesfore instance.
***/
public interface IMarketingHistoryService {
    /***
     * The entry point into the dependency injection framework marketing history services.
     * @param kvpSearchCriteria -- The search criteria in the format of a key-value-pair mapping
     * @return Returns an instance list of MarketingHistoryResponse contain classes
     */
    List<ILHMarketingHistoryResultsWrapper> getMarketHistory(Map<String, Object> kvpSearchCriteria);
}