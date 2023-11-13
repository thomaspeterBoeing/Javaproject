@isTest
public with sharing class PolicySummaryControllerTest {
    static final String SAMPLE_PRODUCTNUMBER = '51LC0234688';
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
        Boolean isProductNumberInSearch = false;
        for(ILHPolicyResultsWrapper item: items){
          if(item.ProductNumber==SAMPLE_PRODUCTNUMBER) 
          isProductNumberInSearch=true;
        }
        Assert.isTrue(isProductNumberInSearch); // one column is good for unit testing
        
    }
    
}