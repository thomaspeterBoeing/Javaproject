public with sharing class HttpHelper {
    public static HTTPResponse sendAPICRequest(String endPointKey, String requestString) {
        API_Endpoint__mdt endpoint = Utilities.getEndpointConfig(endPointKey);
		String URI = '';
		
		if((endpoint.Named_Credential__c != null) && (endpoint.Named_Credential__c != '')) {
			URI += 'callout:' + endpoint.Named_Credential__c;
		}

		URI += endpoint.Service_Method__c+endpoint.Client_Id__c;

        HttpRequest httpRequestObject = new HttpRequest();
        httpRequestObject.setTimeout(Integer.valueOf(endpoint.Timeout__c));
        httpRequestObject.setMethod(endpoint.Method__c);
		httpRequestObject.setHeader('Content-Type', endpoint.ContentType__c);
		
		if(endpoint.isOIDCSecured__c) {
			httpRequestObject.setHeader('Authorization', 'Bearer '+ Utilities.getBearerToken());
		}
        
        if((requestString != null) && (requestString != '')){
            if(endpoint.Method__c == 'GET') {
                URI += '&' + requestString;
            } else {
                httpRequestObject.setBody(requestString);
            }
        }
        
        httpRequestObject.setEndpoint(URI);
        
        if(endpoint.Type__c == 'SOAP') {
            httpRequestObject.setHeader('SOAPAction', endpoint.SOAP_Method__c);
        }
        
        return new System.Http().send(httpRequestObject);
    }

    /**
     * This method overrides the previous sendAPICRequest, and is used for newer GET requests
     * Use sendAPICRequest(String endPointKey, String requestString) for POST requests
     * For this method the API Endpoint metadata records must include the index values that you passing through the parameterValues
     * Example: 
     * Service Method = /personid/{0} 
     * parmeterValues = {'123456'}
     * URI = /personid/123456
     * @param endPointKey -- Name of the service that you are requestion data from. This should be the value on the ServiceName on API Enpoint records
     * @param parameterValues -- Values of the indexes that you want to replace within the URI
     */
    public static HTTPResponse sendAPICRequest(String endPointKey, String[] parameterValues) {
        API_Endpoint__mdt endpoint = Utilities.getEndpointConfig(endPointKey);
		String URI = '';
		
		if((endpoint.Named_Credential__c != null) && (endpoint.Named_Credential__c != '')) {
			URI += 'callout:' + endpoint.Named_Credential__c;
		}

		URI += endpoint.Service_Method__c+endpoint.Client_Id__c;

        HttpRequest httpRequestObject = new HttpRequest();
        httpRequestObject.setTimeout(Integer.valueOf(endpoint.Timeout__c));
        httpRequestObject.setMethod(endpoint.Method__c);
		httpRequestObject.setHeader('Content-Type', endpoint.ContentType__c);
		
		if(endpoint.isOIDCSecured__c) {
			httpRequestObject.setHeader('Authorization', 'Bearer '+ Utilities.getBearerToken());
		}
        
        URI = String.format(URI, parameterValues);  
        httpRequestObject.setEndpoint(URI);
        
        if(endpoint.Type__c == 'SOAP') {
            httpRequestObject.setHeader('SOAPAction', endpoint.SOAP_Method__c);
        }
        
        return new System.Http().send(httpRequestObject);
    }
    
    public static Boolean setMockCalloutIfTest(API_Endpoint__mdt endpoint) {
        return setMockCalloutIfTest(endpoint,200,endpoint.Mock_Response_Static_Resource__c);
    }
    
    public static Boolean setMockCalloutIfTest(API_Endpoint__mdt endpoint, Integer httpStatusCode, String mockResponseStaticResource) {
        Boolean isMockCallSet = false;

        if (Test.isRunningTest()) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource(mockResponseStaticResource);
            mock.setStatusCode(httpStatusCode);
            mock.setHeader('Content-Type', endpoint.ContentType__c);
            Test.setMock(HttpCalloutMock.class, mock); //  Setup to call mock web service when method called from test 
            isMockCallSet = true;
        }

        return isMockCallSet;
    }
}