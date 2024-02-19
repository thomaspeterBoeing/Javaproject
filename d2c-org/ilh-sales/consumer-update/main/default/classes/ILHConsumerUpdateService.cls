/**
 * Copyright: TruStage
 * Purpose: This is service layer of the dependency injection consumer update services.
 *          This is where each concrete consumer update service class will be dispatched
 */
public class ILHConsumerUpdateService {
    public ILHConsumerUpdateService() {}

    /**
     * Purpose: The entry point into the dependency injection framework consumer update services.
     * @param kvp -- Kvp information that needs to updated in the MDM
     */
    public void sendUpdate(Map<String, Object> kvp) {
        dispatchConsumerUpdateServices(kvp);
    }

    /**
     * Purpose: This method handles the logic for dispatching consumer update services.
     * @param kvp -- Kvp information that needs to updated in the MDM
     */
    private void dispatchConsumerUpdateServices(Map<String, Object> kvp) {
        //Get all consumer update class instances
        Id commitUser = (Id) kvp.get('commituser');
        List<IConsumerUpdateService> classInstances = ILHConsumerUpdateFactory.getInstances(commitUser);

        for(IConsumerUpdateService classInstance : classInstances) {
            ((IConsumerUpdateService)classInstance).sendUpdate(kvp);
        }        
    }
}