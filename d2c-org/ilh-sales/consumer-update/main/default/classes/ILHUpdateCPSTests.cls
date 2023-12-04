/**
 * Copyright: TruStage
 * Purpose: Unit tests for ILHUpdateCPS class
 */
@isTest
public class ILHUpdateCPSTests {
    @isTest
    public static void sendUpdateTest(){
        Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
        ILHUpdateCPS updateCPS = new ILHUpdateCPS();
        Map<String, Object> kvp = new Map<String, Object>();
        kvp.put('account', new Account());
        updateCPS.sendUpdate(kvp);

        Account acc = new Account();
        acc.ContractNumberUnformatted__c = '11111';
        acc.FirstName = 'Test';
        acc.LastName = 'Test';
        acc.Suffix = 'Jr';
        acc.MiddleName = 'Test';
        acc.PersonBirthDate = Date.newInstance(2023, 01, 01);
        acc.Gender__pc = 'Male';
        acc.PersonMobilePhone = '1111111111';
        acc.PersonHomePhone = '2222222222';
        acc.PersonOtherPhone = '3333333333';
        acc.PersonMailingCity = 'Madison';
        acc.PersonMailingStreet = '123 Main Street, Apt #123';
        acc.PersonMailingState = 'WI';
        acc.PersonMailingPostalCode = '11111';
        acc.PersonID__pc = '1234';
        acc.RecordTypeId = consumerRecordTypeId;
        insert acc;
        acc = [SELECT id, ContractNumberUnformatted__c, FirstName, LastName, Suffix,  MiddleName, PersonBirthDate, Gender__pc, PersonMobilePhone, PersonHomePhone,
            PersonOtherPhone, PersonMailingCity, PersonMailingStreet, PersonMailingState, PersonMailingPostalCode, PersonID__pc FROM Account WHERE id =: acc.id];
        kvp.put('account', acc);
        updateCPS.sendUpdate(kvp);

        acc.Gender__pc = 'Female';
        kvp.put('account', acc);
        updateCPS.sendUpdate(kvp);

        kvp = new Map<String, Object>();
        kvp.put('acc', acc);
        updateCPS.sendUpdate(kvp);
    }
}