/**
 * Copyright: TruStage
 * Purpose: Unit tests for ConsumerSearchController class
 */
@isTest
public class ConsumerSearchControllerTests {
    static final String SAMPLE_PERSON_ID = '2000000081816';
    @isTest
    public static void searchTest(){
        //Creating a succesful mock response
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('mock_ConsumerProfileSearchResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock); 
        MockMetadataUtils.insert_custom_metadata_mock();
        //Creating initial search criteria for request
        Map<String, Object> kvpSearchCriteria = new Map<String, Object>();
        kvpSearchCriteria.put('firstName','First');
        kvpSearchCriteria.put('lastName','Last');
        kvpSearchCriteria.put('phoneNumber','(111) 111-1111');
        kvpSearchCriteria.put('state', 'NC');
        kvpSearchCriteria.put('ssn','1111');
        kvpSearchCriteria.put('policyNumber','1111');
        kvpSearchCriteria.put('dateOfBirth','1/1/2023');
        
        Test.startTest();
        ILHConsumerResultsWrapper wrapper = ConsumerSearchController.search(kvpSearchCriteria);
        //Verifying search results        
        Assert.IsTrue(wrapper.results.size()>0);
        Boolean isPersonIdInSearch = false;
        for(ILHConsumerResultsWrapper.SearchResult item: wrapper.results){
          if(item.personId==SAMPLE_PERSON_ID) 
            isPersonIdInSearch=true;
        }
        Assert.isTrue(isPersonIdInSearch);
    }

    @isTest
    public static void checkPhoneExclusionFlag_Test(){        
        string phone='(123) 1231234';
        Boolean ret = ConsumerSearchController.checkPhoneExclusionFlag(phone);
        Assert.isFalse(ret);
    }
}