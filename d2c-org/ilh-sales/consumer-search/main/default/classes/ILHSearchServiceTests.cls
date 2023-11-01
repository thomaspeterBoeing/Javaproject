/**
 * @Author: Bernie Shishaye
 * @Create Time: 2023-09-12 12:49:32
 * @Modified by: Bernie Shishaye
 * @Modified time: 2023-09-12 18:21:42
 * @Description:
 */

@isTest
public class ILHSearchServiceTests {
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
        List<ILHConsumerResultsWrapper> items = ConsumerSearchController.search(kvpSearchCriteria);
        //Verifying search results        
        Assert.IsTrue(items.size()>0, 'Expecting more than 1 result');
    }
}