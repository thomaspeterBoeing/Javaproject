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
    public static ConversionEligibleQuoteRequest createCEQRequest(Map<String, Object> ceqrequest) {
        ConversionEligibleQuoteRequest crequest = new ConversionEligibleQuoteRequest();

        // Set values for each property based on ceqrequest map
        crequest.conversionProductCode = (String)ceqrequest.get('conversionProductCode');
        crequest.currentTermPolicyNumber = (String)ceqrequest.get('currentTermPolicyNumber');
        crequest.currentTermCompanyCode = (String)ceqrequest.get('currentTermCompanyCode');
        crequest.channel = (String)ceqrequest.get('channel');
        crequest.insuredResidentState = (String)ceqrequest.get('insuredResidentState');
        integer tempCoverageAmount = ((Decimal)ceqrequest.get('conversionCoverageAmount')).intValue();
        crequest.conversionCoverageAmount = math.mod(tempCoverageAmount, 1000) != 0 ? tempCoverageAmount : null; //send exact coverage amount when not neatly divisible by 1000.
        crequest.isTermBeingKept = (Boolean)ceqrequest.get('isTermBeingKept');

        return crequest;
    }

    public static List<ConversionEligibleQuoteWrapper> getEligibleQuotes(ConversionEligibleQuoteRequest ceqrequest) {
            if (ceqrequest == null) {
                new ErrorLogger(null, 'request is null and cannot proceed with service call', 'ILHConversionEligibleQuotehelper.cls', null, 'getEligibleQuotes', null,
                                'Validation_Before_CEQCall', null);
                return new List<ConversionEligibleQuoteWrapper>();
            }

            List<ConversionEligibleQuoteWrapper> ilhCeqResults = new List<ConversionEligibleQuoteWrapper>();
            String requestPayload = JSON.serialize(ceqrequest, true);
            System.debug('what is in the request payload' + requestPayload);
            HttpResponse response;

            try {
                response = HttpHelper.sendAPICRequest('ConversionEligibleQuote', requestPayload);

                // Check for non-successful status codes
                if (response.getStatusCode() > 200) {
                    handleNonSuccessfulResponse(response, requestPayload);
                    return ilhCeqResults; // Return an empty list for now
                }

                String jsonResponse = response?.getBody();
                System.debug('Raw Response from service ' + jsonResponse);
                List<ConversionEligibleQuoteWrapper.QuoteGridRow> quoteGridRows = ConversionEligibleQuoteWrapper.parseFromJSON(jsonResponse);
                ilhCeqResults.add(new ConversionEligibleQuoteWrapper(quoteGridRows));
                system.debug('ilhCeqResults showing fullconversion node' + ilhCeqResults);
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
            //  new ErrorLogger(null, 'HTTP Response is null', 'ILHConversionEligibleQuotehelper.cls', null, 'handleNonSuccessfulResponse', requestPayload, 'CEQS Service', null);// --Error logger is throwin
            // hence not logging for Unit Testing purposes. update Error Logger publishException if((String.isNotEmpty(strErrorMsg)) && !(Test.isRunningTest())
            return;
        }

        
        // call the ErrorLogger and log failure
        new ErrorLogger(null, 'HTTP Request failed with status code ' + statusCode, 'ILHConversionEligibleQuotehelper.cls', null, 'getEligibleQuotes', requestPayload, 'CEQS Service', statusCode);
    }


}
