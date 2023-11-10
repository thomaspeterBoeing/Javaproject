/**
 * Copyright: TruStage
 * Purpose: The interface definition that all concrete search service classes will implement.
 */
public interface ISearchService {
    /***
     * Purpose: The entry point into the dependency injection framework search services.
     * @param kvpSearchCriteria -- The search criteria in the format of a key-value-pair mapping
     * @return Returns an instance list of ILHConsumerResultsWrapper contain classes
     */
    List<ILHConsumerResultsWrapper> search (Map<String, Object> kvpSearchCriteria);
}