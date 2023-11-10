@isTest
public with sharing class ILH_CreateUpdatePersonAccountALFlowTests {

    @TestSetup
    static void loadTestData() {
      //save a person account record
      List<RecordType> results = [SELECT Id FROM RecordType where DeveloperName = 'Consumer'];
      Id paId = (Id) results[0].get('Id');
      Account acct = new Account(FirstName='Bobby', LastName='Brown', RecordTypeID = paId);
      insert acct;
    }

    @isTest 
    static void testRecordWithAccountIDIsUpdated() {

        Integer recordCountBefore;
        Integer recordCountAfter;

        //get count of PersonAccount records
        List<AggregateResult> results = [SELECT count(Id) FROM Account where isPersonAccount = true];
        recordCountBefore = (Integer) results[0].get('expr0');

        //select PersonAccount from database
        Account acId = [SELECT Id FROM Account where Name = 'Bobby Brown'];

        //provide new values with the same AccountID
        string flowVar =    '[{"name": "inputTxt_AccountID","type": "String","value": "' + acId + '"},{"name": "inputTxt_FirstName","type": "String","value": "testFirst"},{"name": "inputTxt_LastName","type": "String","value": "testLast"},{"name": "inputTxt_Gender","type": "String","value": "male"},{"name": "inputDt_BirthDate","type": "Date","value": "01/01/2000"},{"name": "inputTxt_AddressStreet","type": "String","value": "1 Test St"},{"name": "inputTxt_AddressCity","type": "String","value": "testCity"},{"name": "inputTxt_AddressState","type": "String","value": "NY"},{"name": "inputTxt_AddressPostalCode","type": "String","value": "11111"},{"name": "inputTxt_HomePhone","type": "String","value": "1111111111"}]';

		//pass the record to the flow
        test.startTest();
        String outputVar = IlhAutoLaunchFlow.startFlow('ILH_CreateUpdatePersonAccountALF', flowVar, 'outputTxt_AccountId');
        test.stopTest();
       
        //get count of PersonAccount records
        List<AggregateResult> results2 = [SELECT count(Id) FROM Account where isPersonAccount = true];
        recordCountAfter = (Integer) results2[0].get('expr0');

		//assert that record count has not changed
        system.assertEquals(recordCountBefore, recordCountAfter, 'Person Account record count changed when it was expected to remain the same.');

    }

    @isTest 
    static void testRecordWithNoAccountIDIsInserted() {

        Integer recordCountBefore;
        Integer recordCountAfter;

        //get count of PersonAccount records
        List<AggregateResult> results = [SELECT count(Id) FROM Account where isPersonAccount = true];
        recordCountBefore = (Integer) results[0].get('expr0');

        //provide values for a new record
        string flowVar =    '[{"name": "inputTxt_FirstName","type": "String","value": "testFirst"},{"name": "inputTxt_LastName","type": "String","value": "testLast"},{"name": "inputTxt_Gender","type": "String","value": "male"},{"name": "inputDt_BirthDate","type": "Date","value": "01/01/2000"},{"name": "inputTxt_AddressStreet","type": "String","value": "1 Test St"},{"name": "inputTxt_AddressCity","type": "String","value": "testCity"},{"name": "inputTxt_AddressState","type": "String","value": "NY"},{"name": "inputTxt_AddressPostalCode","type": "String","value": "11111"},{"name": "inputTxt_HomePhone","type": "String","value": "1111111111"}]';

		//pass the record to the flow
        test.startTest();
        String outputVar = IlhAutoLaunchFlow.startFlow('ILH_CreateUpdatePersonAccountALF', flowVar, 'outputTxt_AccountId');
        test.stopTest();

        //get count of PersonAccount records
        List<AggregateResult> results2 = [SELECT count(Id) FROM Account where isPersonAccount = true];
        recordCountAfter = (Integer) results2[0].get('expr0'); 

        //assert that record count has increased by 1
        system.assertEquals(recordCountBefore + 1, recordCountAfter, 'Person Account record count was expected to increase by 1 but has not.');

    }
}

        
   