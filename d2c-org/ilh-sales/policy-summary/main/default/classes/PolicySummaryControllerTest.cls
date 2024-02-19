@isTest
public with sharing class PolicySummaryControllerTest {
    static final String SAMPLE_PRODUCTNUMBER = '51LC0234688';
    @testSetup 
    public static void setupUsers() {
        Profile adminUserProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User adminUser = new User(Alias = 'adminu', Email='testadminuser@test.com', Persona__c = 'System Admin',
            EmailEncodingKey='UTF-8', FirstName='Admin', LastName='User', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = adminUserProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testadminuser@testadminuser.com');
        insert adminUser;
    }

    @isTest
    public static void searchTest(){
        User adminUser = [SELECT Id FROM User WHERE Alias = 'adminu' LIMIT 1];
        System.runAs(adminUser) {
            //Creating a succesful mock response
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('Mock_PolicySummaryResponse');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock); 
            
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
    
}