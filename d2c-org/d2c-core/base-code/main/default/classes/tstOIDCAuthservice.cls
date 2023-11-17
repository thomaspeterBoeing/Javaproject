@isTest
public with sharing class tstOIDCAuthservice {
    static testMethod void testGetBearerToken() {				
		API_Endpoint__mdt endpoint = Utilities.getEndpointConfig('OIDCAuthorizeAPI');
		HttpHelper.setMockCalloutIfTest(endpoint);
        OIDCAuthorizeService.getBearerToken();		
	}
}

