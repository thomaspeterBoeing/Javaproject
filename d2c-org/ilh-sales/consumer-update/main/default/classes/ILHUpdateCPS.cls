/**
 * Copyright: TruStage
 * Purpose: This class sends Person Account record to CPS to update
 */
public class ILHUpdateCPS implements IConsumerUpdateService {
    /**
     * Purpose: This method sends Person Account information to CPS to update
     * @param kvp -- Kvp information that needs to updated in the MDM
     */
    public void sendUpdate(Map<String, Object> kvp) {
        //Create request payload
        String requestPayload = '';

        try {
            Account acc = (Account) kvp.get('account');
            ConsumerProfileUpdateRequest cpsRequest = new ConsumerProfileUpdateRequest(acc);
            requestPayload = JSON.serialize(cpsRequest, true);
            callCPS(requestPayload);
        } catch (Exception ex) {
            new ErrorLogger(ex, null, 'ILHUpdateCPS.cls', null, 'sendUpdate', requestPayload, null, null);
        }
    }

    @future (callout=true)
    private static void callCPS(String requestPayload) {
        HttpResponse response;
        try {
            response = HttpHelper.sendAPICRequest('CPS_Update', requestPayload);
        } catch (Exception ex) {
            new ErrorLogger(ex, null, 'ILHUpdateCPS.cls', null, 'callCPS', requestPayload, 'CPS_Update', response?.getStatusCode());
        }
    }
}