/**********************************************************************************
 * Title:  ILHConversionEligibleQuotehelper
 * Date:   Jan 2024
 * 
 * Description:  Apex Class to interact with ConversionEligibleQuote endpoint  
 * 
 * Details:      Create CESRequest. 
 *               Calls 	ConversionEligibleQuote Service.
 *                
 *          
 * Modifications:
 *************************************************************************************/
public with sharing class ILHConversionEligibleQuotehelper {
    public static ConversionEligibleQuoteRequest createCEQRequest(Map<String, Object> kvpRequestCriteria) {
        ConversionEligibleQuoteRequest ceqr = createRequest(kvpRequestCriteria);
        return ceqr;
    }

    public static ConversionEligibleQuoteRequest createRequest(Map<String, Object> kvpRequestCriteria) {
        String criteriaString = JSON.serialize(kvpRequestCriteria);
        return (ConversionEligibleQuoteRequest) JSON.deserialize(criteriaString, ConversionEligibleQuoteRequest.class);

    }

    public static ConversionEligibleQuoteWrapper getEligibleQuotes(ConversionEligibleQuoteRequest ceqrequest, Boolean includeQuotes) {
            if (ceqrequest == null) {
                new ErrorLogger(null, 'request is null and cannot proceed with service call', 'ILHConversionEligibleQuotehelper.cls', null, 'getEligibleQuotes', null,
                                'Validation_Before_CEQCall', null);
                return new ConversionEligibleQuoteWrapper();
            }
            ConversionEligibleQuoteWrapper ilhCeqResults = new ConversionEligibleQuoteWrapper();

            //Create request payload
            String requestPayload = JSON.serialize(ceqrequest, true);
            System.debug('request payload' + requestPayload);
            HttpResponse response;

            try {
                response = HttpHelper.sendAPICRequest('ConversionEligibleQuote', requestPayload);

                if(response.getStatusCode() == 200){ 
                String jsonResponse = response?.getBody();
                //System.debug('raw response from service ' + jsonResponse);
                ilhCeqResults =ConversionEligibleQuoteWrapper.parseFromJSON(jsonResponse, includeQuotes);
                }else if (response.getStatusCode() == 204) {
                    // If the response is 204 (No Content), return an empty result
                    System.debug('No content available from the service');
                }    
                else {  // Check for non-successful status codes
                    handleNonSuccessfulResponse(response, requestPayload);
                    return ilhCeqResults; // Return an empty list for now
                }
            } catch (Exception ex) {
                new ErrorLogger(ex, 'An error occurred while calling CEQS Service.', 'ILHConversionEligibleQuotehelper.cls', null, 'CEQS Service', requestPayload,
                                'ConversionEligibleQuote', response?.getStatusCode());
            }
            return ilhCeqResults;
    }

    @TestVisible 
    private static void handleNonSuccessfulResponse(HttpResponse response, String requestPayload) {
        Integer statusCode = response.getStatusCode();
        String responseBody = response.getBody(); // do we want to log this as well?

        // Unit Testing StatusCode =500
        if (statusCode == 500) {
            // Log a message
            system.debug('Unit Testing 500 scenario');
              new ErrorLogger(null, 'HTTP Response is null', 'ILHConversionEligibleQuotehelper.cls', null, 'handleNonSuccessfulResponse', requestPayload, 'CEQS Service', null); 
            return;
        }

        
        // call the ErrorLogger and log failure
        new ErrorLogger(null, 'HTTP Request failed with status code ' + statusCode, 'ILHConversionEligibleQuotehelper.cls', null, 'getEligibleQuotes', requestPayload, 'CEQS Service', statusCode);
    }


}
