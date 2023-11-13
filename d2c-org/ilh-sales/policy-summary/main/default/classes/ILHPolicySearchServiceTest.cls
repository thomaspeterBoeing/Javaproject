@isTest
public with sharing class ILHPolicySearchServiceTest {
    static final String SAMPLE_PERSON_ID = '3000002675906';
    @isTest
    public static void searchTest(){
        //Creating a succesful mock response
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_PolicySummaryResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock); 
        MockMetadataUtils.insert_custom_metadata_mock();

        //Creating initial search criteria for request
        String SearchCriteria = '3000002675906';
        
        Test.startTest();
        List<ILHPolicyResultsWrapper> items = PolicySummaryController.search(SearchCriteria);
        //Verifying search results        
        Assert.IsTrue(items.size()>0);
    }
}