/**
 * Copyright: TruStage
 * Purpose: Unit tests for ILHSearchHelper class
 */
@isTest
public class ILHSearchHelperTests {
  @testSetup
  static void setup() {
    Date newDate = Date.newInstance(1979, 9, 7);

    Id objectRecordTypeId = [
      SELECT id, DeveloperName
      FROM RecordType
      WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'
    ]
    .id;

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
  public static void createCPSSearchRequestTest() {
    Map<String, Object> kvpSearchCriteria = new Map<String, Object>();
    kvpSearchCriteria.put('firstName', 'First');
    kvpSearchCriteria.put('lastName', 'Last');
    kvpSearchCriteria.put('phoneNumber', '(111) 111-1111');
    kvpSearchCriteria.put('city', 'Madison');
    kvpSearchCriteria.put('zipCode', '53718');
    kvpSearchCriteria.put('state', 'WI');
    kvpSearchCriteria.put('ssn', '111111111');
    kvpSearchCriteria.put('policyNumber', '1111');
    kvpSearchCriteria.put('dateOfBirth', '1/1/2023');

    ConsumerProfileServiceRequest request = ILHSearchHelper.createCPSSearchRequest(
      kvpSearchCriteria,
      10
    );

    Assert.areEqual(
      'First',
      request.SearchConsumerProfile.PersonName.FirstName
    );
    Assert.areEqual('Last', request.SearchConsumerProfile.PersonName.LastName);
    Assert.areEqual('1111111111', request.SearchConsumerProfile.PhoneNumber);
    Assert.areEqual(
      'Madison',
      request.SearchConsumerProfile.CommonAddress.City
    );
    Assert.areEqual(
      '53718',
      request.SearchConsumerProfile.CommonAddress.PostalCode
    );
    Assert.areEqual(
      'WI',
      request.SearchConsumerProfile.CommonAddress.StateProvince
    );
    Assert.areEqual('111111111', request.SearchConsumerProfile.TaxId);
    Assert.areEqual(
      '1111',
      request.SearchConsumerProfile.SimpleProductSummary.ProductNumber
    );
    Assert.areEqual(
      Date.newInstance(2023, 1, 1),
      request.SearchConsumerProfile.BirthDate
    );
  }

  @isTest
  public static void createSearchCriteriaTest() {
    Map<String, Object> kvpSearchCriteria = new Map<String, Object>();
    kvpSearchCriteria.put('firstName', 'First');
    kvpSearchCriteria.put('lastName', 'Last');
    kvpSearchCriteria.put('phoneNumber', '(111) 111-1111');
    kvpSearchCriteria.put('city', 'Madison');
    kvpSearchCriteria.put('zipCode', '53718');
    kvpSearchCriteria.put('state', 'WI');
    kvpSearchCriteria.put('ssn', '1111');
    kvpSearchCriteria.put('policyNumber', '1111');
    kvpSearchCriteria.put('dateOfBirth', '1/1/2023');

    ConsumerProfileServiceRequest.SearchCriteria criteria = ILHSearchHelper.createSearchCriteria(
      kvpSearchCriteria
    );

    Assert.areEqual('First', criteria.firstName);
    Assert.areEqual('Last', criteria.lastName);
    Assert.areEqual('(111) 111-1111', criteria.phoneNumber);
    Assert.areEqual('Madison', criteria.city);
    Assert.areEqual('53718', criteria.zipCode);
    Assert.areEqual('WI', criteria.state);
    Assert.areEqual('1111', criteria.ssn);
    Assert.areEqual('1111', criteria.policyNumber);
    Assert.areEqual('1/1/2023', criteria.dateOfBirth);
  }

  @isTest
  public static void searchCPSTest() {
    //Creating a succesful mock response
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource('mock_ConsumerProfileSearchResponse');
    mock.setStatusCode(200);
    mock.setHeader('Content-Type', 'application/json');
    Test.setMock(HttpCalloutMock.class, mock);

    //Creating initial search criteria for request
    Map<String, Object> kvpSearchCriteria = new Map<String, Object>();
    kvpSearchCriteria.put('firstName', 'Brad');
    kvpSearchCriteria.put('lastName', 'Wegner');
    kvpSearchCriteria.put('phoneNumber', '(610) 921-0331');
    kvpSearchCriteria.put('state', 'WI');
    kvpSearchCriteria.put('ssn', '1111');
    kvpSearchCriteria.put('policyNumber', '1111');
    kvpSearchCriteria.put('dateOfBirth', '09/05/1979');

    Test.startTest();
    ConsumerProfileServiceRequest searchRequest = ILHSearchHelper.createCPSSearchRequest(
      kvpSearchCriteria,
      10
    );
    ILHConsumerResultsWrapper wrapper = ILHSearchHelper.searchCPS(
      searchRequest
    );
    Assert.areEqual(2, wrapper.results.size());

    Assert.areEqual('Brad', wrapper.results[0].firstName);
    Assert.areEqual('Wegner', wrapper.results[0].lastName);
    Assert.areEqual('2000000081816', wrapper.results[0].personId);
    Assert.areEqual(
      Date.newInstance(1979, 9, 5),
      wrapper.results[0].dateOfBirth
    );
    Assert.areEqual('Female', wrapper.results[0].gender);
    Assert.areEqual('6109210331', wrapper.results[0].homePhone);
    Assert.areEqual('14154496368111111', wrapper.results[0].workPhone);
    Assert.areEqual('MADISON', wrapper.results[0].city);
    Assert.areEqual('537194031', wrapper.results[0].postalCode);
    Assert.areEqual('WI', wrapper.results[0].stateProvince);

    //Sending a null request to search
    Assert.areEqual(
      null,
      ILHSearchHelper.searchCPS(null),
      'Expecting null result since we passed in a null value'
    );
  }

  @isTest
  private static void SFSearchTest() {
    Map<String, Object> kvpSearchCriteria = new Map<String, Object>();

    Test.startTest();
    ILHConsumerResultsWrapper sfResultsWrapper = new ILHConsumerResultsWrapper();
    ILHConsumerResultsWrapper contactPersonWrapper = new ILHConsumerResultsWrapper();
    List<ILHConsumerResultsWrapper> contactPersonList;

    List<Account> allAccounts = new List<Account>([SELECT id FROM Account]);
    Assert.areEqual(
      1,
      allAccounts.size(),
      'There is a total of 1 test account'
    );

    //Testing Combination 1
    ILHConsumerResultsWrapper.SearchResult serviceResult = new ILHConsumerResultsWrapper.SearchResult();
    serviceResult.personId = '2000000081816';
    serviceResult.sourceSystemKeys = new List<String>{ allAccounts[0].id };
    contactPersonWrapper.results.add(serviceResult);
    contactPersonList = new List<ILHConsumerResultsWrapper>{
      contactPersonWrapper
    };

    kvpSearchCriteria = new Map<String, Object>{ 'ssn' => '111111111' };
    sfResultsWrapper = ILHSearchHelper.searchSF(
      kvpSearchCriteria,
      contactPersonList
    );
    Assert.areEqual(1, sfResultsWrapper.results.size());
    Assert.areEqual(
      allAccounts[0].id,
      sfResultsWrapper.results[0].sourceSystemKeys[0]
    );

    //Testing Combination 2
    kvpSearchCriteria = new Map<String, Object>{ 'policyNumber' => '11111111' };
    sfResultsWrapper = ILHSearchHelper.searchSF(
      kvpSearchCriteria,
      contactPersonList
    );
    Assert.areEqual(1, sfResultsWrapper.results.size());
    Assert.areEqual(
      allAccounts[0].id,
      sfResultsWrapper.results[0].sourceSystemKeys[0]
    );

    //Testing Combination 3
    kvpSearchCriteria = new Map<String, Object>{
      'firstName' => 'Test',
      'phoneNumber' => '6109210331',
      'dateOfBirth' => '1979-09-07',
      'city' => 'Madison',
      'state' => 'WI'
    };
    sfResultsWrapper = ILHSearchHelper.searchSF(
      kvpSearchCriteria,
      contactPersonList
    );
    Assert.areEqual(1, sfResultsWrapper.results.size());
    Assert.areEqual(
      allAccounts[0].id,
      sfResultsWrapper.results[0].sourceSystemKeys[0]
    );

    //Testing Combination 4
    kvpSearchCriteria = new Map<String, Object>{
      'phoneNumber' => '6109210331',
      'dateOfBirth' => '1979-09-07',
      'city' => 'Madison',
      'state' => 'WI'
    };
    sfResultsWrapper = ILHSearchHelper.searchSF(
      kvpSearchCriteria,
      contactPersonList
    );
    Assert.areEqual(1, sfResultsWrapper.results.size());
    Assert.areEqual(
      allAccounts[0].id,
      sfResultsWrapper.results[0].sourceSystemKeys[0]
    );

    //Testing Combination 5
    kvpSearchCriteria = new Map<String, Object>{
      'firstName' => 'Test',
      'lastName' => 'User',
      'dateOfBirth' => '1979-09-07',
      'city' => 'Madison',
      'state' => 'WI',
      'zipCode' => '53719'
    };
    sfResultsWrapper = ILHSearchHelper.searchSF(
      kvpSearchCriteria,
      contactPersonList
    );
    Assert.areEqual(1, sfResultsWrapper.results.size());
    Assert.areEqual(
      allAccounts[0].id,
      sfResultsWrapper.results[0].sourceSystemKeys[0]
    );

    //Testing Combination 6
    kvpSearchCriteria = new Map<String, Object>{
      'firstName' => 'Test*',
      'lastName' => 'User*',
      'state' => 'WI',
      'dateOfBirth' => '1979-09-07'
    };
    sfResultsWrapper = ILHSearchHelper.searchSF(
      kvpSearchCriteria,
      contactPersonList
    );
    Assert.areEqual(1, sfResultsWrapper.results.size());
    Assert.areEqual(
      allAccounts[0].id,
      sfResultsWrapper.results[0].sourceSystemKeys[0]
    );

    //Making sure we don't have any error with an empty request
    kvpSearchCriteria = new Map<String, Object>{};
    sfResultsWrapper = ILHSearchHelper.searchSF(
      kvpSearchCriteria,
      contactPersonList
    );
    Assert.areEqual(null, sfResultsWrapper);

    kvpSearchCriteria = new Map<String, Object>{
      'firstName' => 'Test',
      'lastName' => 'User',
      'dateOfBirth' => '1979-09'
    };
    sfResultsWrapper = ILHSearchHelper.searchSF(
      kvpSearchCriteria,
      contactPersonList
    );
    Assert.areEqual(
      null,
      sfResultsWrapper,
      'There should be no results since there\'s invalid input'
    );

    kvpSearchCriteria = new Map<String, Object>{
      'firstName' => null,
      'lastName' => null,
      'dateOfBirth' => null,
      'ssn' => null,
      'policyNumber' => null,
      'phoneNumber' => null,
      'zipCode' => null,
      'city' => null,
      'state' => null
    };
    sfResultsWrapper = ILHSearchHelper.searchSF(
      kvpSearchCriteria,
      contactPersonList
    );
    Assert.areEqual(
      null,
      sfResultsWrapper,
      'There should be no results since there\'s null input values'
    );

    kvpSearchCriteria = new Map<String, Object>{ 'policyNumber' => '11111111' };
    contactPersonList = new List<ILHConsumerResultsWrapper>();

    sfResultsWrapper = ILHSearchHelper.searchSF(
      kvpSearchCriteria,
      contactPersonList
    );
    Assert.areEqual(
      0,
      sfResultsWrapper.results.size(),
      'No results due to no data in contact person list'
    );

    kvpSearchCriteria = new Map<String, Object>{ 'ssn' => '111111111' };

    sfResultsWrapper = ILHSearchHelper.searchSF(
      kvpSearchCriteria,
      contactPersonList
    );
    Assert.areEqual(
      0,
      sfResultsWrapper.results.size(),
      'No results due to no data in contact person list'
    );
  }
}
