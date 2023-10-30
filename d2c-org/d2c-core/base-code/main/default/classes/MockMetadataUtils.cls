public class MockMetadataUtils {
    
    public static List<APIEnvironmentSFOrgID__mdt> apiEvts = new List<APIEnvironmentSFOrgID__mdt>();
    public static List<API_Endpoint__mdt> apiEndPts = new List<API_Endpoint__mdt>();
    public static List<NonSearchableNumber__mdt> excludedNums = new List<NonSearchableNumber__mdt>();

    @TestVisible
    public static void insert_custom_metadata_mock(){
	
        APIEnvironmentSFOrgID__mdt apiEvt = new APIEnvironmentSFOrgID__mdt();
        Map<String,Object> fields = (Map<String, Object>) 
            JSON.deserializeUntyped(JSON.serializePretty(apiEvt));
        fields.put(
            APIEnvironmentSFOrgID__mdt.Environment__c.getDescribe().getName(),
            'Dev'
        );
        fields.put(
            APIEnvironmentSFOrgID__mdt.OrgId__c.getDescribe().getName(),
            UserInfo.getOrganizationId()
        );
        apiEvt = (APIEnvironmentSFOrgID__mdt) 
            JSON.deserialize(JSON.serialize(fields), APIEnvironmentSFOrgID__mdt.class);
        
        API_Endpoint__mdt apiEnd = new API_Endpoint__mdt();
        Map<String,Object> fields2 = (Map<String, Object>) 
            JSON.deserializeUntyped(JSON.serializePretty(apiEnd));
        fields2.put(
            API_Endpoint__mdt.MasterLabel.getDescribe().getName(),
            'Dev'
        );
        fields2.put(
            API_Endpoint__mdt.Client_Id__c.getDescribe().getName(),
            '123456789'
        );
          fields2.put(
            API_Endpoint__mdt.Client_Secret__c.getDescribe().getName(),
            'Secret'
        );
        
        fields2.put(
            API_Endpoint__mdt.Service_Method__c.getDescribe().getName(),
            'CPS_Search'
        );
        fields2.put(
            API_Endpoint__mdt.ServiceName__c.getDescribe().getName(),
            'CPS_Search'
        );
        fields2.put(
            API_Endpoint__mdt.Named_Credential__c.getDescribe().getName(),
            'endpoint'
        );
         fields2.put(
            API_Endpoint__mdt.Timeout__c.getDescribe().getName(),
            '3'
        );
        fields2.put(
            API_Endpoint__mdt.Method__c.getDescribe().getName(),
            'CPS_Search'
        );
        fields2.put(
            API_Endpoint__mdt.ContentType__c.getDescribe().getName(),
            'application/json'
        );
        
         apiEnd = (API_Endpoint__mdt) 
            JSON.deserialize(JSON.serialize(fields2), API_Endpoint__mdt.class);
        
        NonSearchableNumber__mdt excludedNum = new NonSearchableNumber__mdt();
        Map<String,Object> fields3 = (Map<String, Object>) 
            JSON.deserializeUntyped(JSON.serializePretty(excludedNum));
        fields3.put(
            NonSearchableNumber__mdt.DeveloperName.getDescribe().getName(),
            'X1231231234'
        );

        fields3.put(
            NonSearchableNumber__mdt.MasterLabel.getDescribe().getName(),
            '1231231234'
        );

        fields3.put(
            NonSearchableNumber__mdt.ExcludedNumber__c.getDescribe().getName(),
            '1231231234'
        );

        excludedNum = (NonSearchableNumber__mdt) 
            JSON.deserialize(JSON.serialize(fields3), NonSearchableNumber__mdt.class);
        
        MockMetadataUtils.apiEvts.add(apiEvt);
        MockMetadataUtils.apiEndPts.add(apiEnd);
        MockMetadataUtils.excludedNums.add(excludedNum);
        
    }
}