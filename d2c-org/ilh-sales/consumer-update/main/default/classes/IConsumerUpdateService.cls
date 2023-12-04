/**
 * Copyright: TruStage
 * Purpose: The interface definition that all concrete consumer update service classes will implement.
 */
public interface IConsumerUpdateService {
    /***
     * Purpose: The entry point into the dependency injection framework consumer update services.
     * @param kvp -- Kvp information that needs to updated in the MDM
     */
    void sendUpdate (Map<String, Object> kvp);
}