@isTest
public with sharing class tstOIDCAuthservice {
    static testMethod void testGetBearerToken() {				
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockOidcGetBearerToken');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock); 
        MockMetadataUtils.insert_custom_metadata_mock();
		APIEnvironmentSFOrgID__mdt apiEvt = new APIEnvironmentSFOrgID__mdt();
		apiEvt.Environment__c='Dev';
		OrgId__c=        UserInfo.getOrganizationId();   
		insert apiEvt;
		API_Endpoint__mdt apiEnd = new API_Endpoint__mdt();
		apiEnd.MasterLabel= 'Dev';
        apiEnd.Client_Id__c=    '123456789';
        apiEnd.Client_Secret__c='Secret';
        apiEnd.Service_Method__c='OIDCAuthorizeAPI';
        apiEnd.ServiceName__c='OIDCAuthorizeAPI';
        apiEnd.Named_Credential__c='endpoint';
        apiEnd.Timeout__c='3';
        apiEnd.Method__c='CPS_Search';
        apiEnd.ContentType__c=  'application/json';
        insert apiEnd;
        OIDCAuthorizeService.getBearerToken();		
	}
}

