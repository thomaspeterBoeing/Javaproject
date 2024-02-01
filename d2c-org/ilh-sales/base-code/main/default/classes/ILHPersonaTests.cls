/**
 * Copyright: TruStage
 * Purpose: Unit tests for ILHPersona class
 */
@isTest
private class ILHPersonaTests {

    @testSetup
    public static void setupUsers() {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Profile adminUserProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        User standardUser = new User(Alias = 'standu', Email='teststandarduser@test.com', PartnerCode__c = 'CC Retention',
            EmailEncodingKey='UTF-8', FirstName='Standard', LastName='User', LanguageLocaleKey='en_US', Persona__c = 'Agent',
            LocaleSidKey='en_US', ProfileId = standardUserProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standardUser@teststandarduser.com');
        insert standardUser;

        User adminUser = new User(Alias = 'adminu', Email='testadminuser@test.com', Persona__c = 'System Admin',
            EmailEncodingKey='UTF-8', FirstName='Admin', LastName='User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = adminUserProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testadminuser@testadminuser.com');
        insert adminUser;

        User noPersonaUser = new User(Alias = 'noperson', Email='testnopersona@test.com', EmailEncodingKey='UTF-8', FirstName='No', LastName='Persona',
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = adminUserProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='nopersona@testadminuser.com');
        insert noPersonaUser;
    }

    @isTest
    static void getPersonaTest() {
        User standardUser = [SELECT id FROM User WHERE FirstName =: 'Standard' AND LastName =: 'User'];
        User adminUser = [SELECT id FROM User WHERE FirstName =: 'Admin' AND LastName =: 'User'];
        User noPersonaUser = [SELECT id FROM User WHERE FirstName =: 'No' AND LastName =: 'Persona'];

        System.runAs(standardUser) {
            Assert.areEqual('ILHSalesRetentionAgent', new ILHPersona().getPersona(), 'Persona is retention agent');
        }

        System.runAs(adminUser) {
            Assert.areEqual('ILHSalesSystemAdmin', new ILHPersona().getPersona(), 'Persona is system admin');
        }

        Assert.areEqual('', new ILHPersona(noPersonaUser.id).getPersona(), 'No Persona found');
    }
}