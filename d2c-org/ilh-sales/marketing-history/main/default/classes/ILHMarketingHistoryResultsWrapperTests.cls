/***
Copyright: TruStage
Purpose: Provides unit testing and code coverage for ILHMarketingHistoryResultsWrapper class.
1.0 - Adam Perschke-Ely - 11/2/2023  - Created for new D2C Salesfore instance.
***/
@isTest
public class ILHMarketingHistoryResultsWrapperTests {

    @testSetup static void setupAccounts() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        Id objectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Affiliation').getRecordTypeId();
        Account acc1 = new Account(Name = 'CU 1', ContractNumberUnformatted__c = '11111111', RecordTypeId = objectRecordTypeId);
        Account acc2 = new Account(Name = 'CU 2', ContractNumberUnformatted__c = '22222222', RecordTypeId = objectRecordTypeId); 
        Account acc3 = new Account(Name = 'CU 3', ContractNumberUnformatted__c = '33333333', RecordTypeId = objectRecordTypeId); 
        Account acc4 = new Account(Name = 'CU 4', ContractNumberUnformatted__c = '44444444', RecordTypeId = objectRecordTypeId); 
        testAccts.add(acc1);
        testAccts.add(acc2);
        testAccts.add(acc3);
        testAccts.add(acc4);
        insert testAccts;
    }

    @isTest
    private static void filterResultsTest() {
        ILHMarketingHistoryResultsWrapper result1 = new ILHMarketingHistoryResultsWrapper();
        result1.mailingDate = Date.newInstance(2022, 01, 01);

        ILHMarketingHistoryResultsWrapper result2 = new ILHMarketingHistoryResultsWrapper();
        result2.mailingDate = Date.newInstance(3023, 01, 01);

        List<ILHMarketingHistoryResultsWrapper> results = new List<ILHMarketingHistoryResultsWrapper>{result1, result2};
        results = ILHMarketingHistoryResultsWrapper.filterResults(results);
        Test.startTest();
        Assert.areEqual(1, results.size());
    }

    @isTest
    private static void findCreditUnionsTest() {
        ILHMarketingHistoryResultsWrapper result1 = new ILHMarketingHistoryResultsWrapper();
        result1.contractNumber = '11111111';

        ILHMarketingHistoryResultsWrapper result2 = new ILHMarketingHistoryResultsWrapper();
        result2.contractNumber = '22222222';

        ILHMarketingHistoryResultsWrapper result3 = new ILHMarketingHistoryResultsWrapper();
        result3.contractNumber = '33333333';

        ILHMarketingHistoryResultsWrapper result4 = new ILHMarketingHistoryResultsWrapper();
        result4.contractNumber = '44444444';

        List<ILHMarketingHistoryResultsWrapper> results = new List<ILHMarketingHistoryResultsWrapper>{result1, result2, result3, result4};
        results = ILHMarketingHistoryResultsWrapper.findCreditUnions(results);
        Test.startTest();
        Assert.areEqual(4, results.size());
        Assert.areEqual('CU 1', results[0].creditUnion);
        Assert.areEqual('CU 2', results[1].creditUnion);
        Assert.areEqual('CU 3', results[2].creditUnion);
        Assert.areEqual('CU 4', results[3].creditUnion);
    }
}