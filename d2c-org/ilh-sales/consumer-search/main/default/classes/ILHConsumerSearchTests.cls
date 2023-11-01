/**
 * @Author: Bernie Shishaye
 * @Create Time: 2023-09-12 12:49:32
 * @Modified by: Bernie Shishaye
 * @Modified time: 2023-09-12 18:18:49
 * @Description: Unit Tests
 */
@isTest
public class ILHConsumerSearchTests {

    @testSetup static void setup() {
        Date newDate = Date.newInstance(1979, 09, 07);

        Id objectRecordTypeId = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'].id;
        // Create common test accounts
        Account accnt = new Account(
            FirstName = 'Test',
            LastName = 'User',
            PersonMailingCity = 'Madison',
            PersonMailingState = 'WI',
            PersonMailingPostalCode = '537194031',
            PersonMobilePhone = '6109210331',
            PersonHomePhone = '6109210331',
            PersonBirthdate = newDate,
            PersonID__pc = '2000000081816',
            PersonMailingStreet = '3901 MAMMOTH TRL',
            RecordTypeId = objectRecordTypeId
        );
        insert accnt;
    }

    @isTest
    private static void searchTest () {
        Map<String, Object> kvpSearchCriteria = new Map<String, Object> {
            'ssn' => '111111111'
        };

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('mock_ConsumerProfileSearchResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        Test.setMock(HttpCalloutMock.class, mock);
        MockMetadataUtils.insert_custom_metadata_mock();

        Test.startTest();
        List<ILHConsumerResultsWrapper> resultsWrapper = (new ILHConsumerSearch()).search(kvpSearchCriteria);
        Assert.areEqual(3, resultsWrapper.size());
    }
}