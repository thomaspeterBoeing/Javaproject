/**
 * Copyright: TruStage
 * Purpose: Unit tests for ILHPersonAccountChangeEventHelper class
 */
@isTest
public class ILHPersonAccountChangeEventHelperTests {

    @testSetup static void setup() {
        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User serviceUser = new User(Alias = 'standt', Email='testservice@test.com', 
            EmailEncodingKey='UTF-8', FirstName='Test', LastName='Service', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = adminProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testservice@testservice.com');

        User standardUser = new User(Alias = 'standu', Email='teststandarduser@test.com', 
            EmailEncodingKey='UTF-8', FirstName='Standard', LastName='User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardUserProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standardUser@teststandarduser.com');
        insert serviceUser;
        insert standardUser;    
        
        Account standardAccount = new Account (
            firstName = 'Standard',
            lastName = 'Account',
            RecordTypeId = consumerRecordTypeId
        );
        insert standardAccount;
        Account serviceAccount = new Account (
            firstName = 'Service',
            lastName = 'Account'
        );
        insert serviceAccount;
    }

    @isTest
    public static void createAccountTest() {
        Test.enableChangeDataCapture();
        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        Account acc = [SELECT id, Gender__pc FROM Account WHERE Name = 'Standard Account'];
        Test.getEventBus().deliver();

        acc.Gender__pc = 'Male';
        update acc;
        Test.getEventBus().deliver();
    }

    @isTest
    public static void changedEventToAccountTest() {
        List<Account> accounts = new List<Account>();
        Set<String> recordIds = new Set<String>();
        Account standardAccount = [SELECT id FROM Account WHERE Name = 'Standard Account'];
        Account serviceAccount = [SELECT id FROM Account WHERE Name = 'Service Account'];

        Test.startTest();
        recordIds.add(standardAccount.id);
        recordIds.add(serviceAccount.id);
        accounts = ILHPersonAccountChangeEventHelper.changedEventToAccount(recordIds);
        Assert.areEqual(1, accounts.size());
        Assert.areEqual(standardAccount.id, accounts[0].id);
    }
}