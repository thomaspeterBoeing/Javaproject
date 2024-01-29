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

        User standardUser = new User(Alias = 'standu', Email='teststandarduser@test.com', PartnerCode__c = 'CSR',
            EmailEncodingKey='UTF-8', FirstName='Standard', LastName='User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardUserProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standardUser@teststandarduser.com');
        insert standardUser;

        User adminUser = new User(Alias = 'adminu', Email='testadminuser@test.com',
            EmailEncodingKey='UTF-8', FirstName='Admin', LastName='User', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = adminUserProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testadminuser@testadminuser.com');
        insert adminUser;

        PermissionSetGroup pgSalesAgent = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'ILHSalesAgentRole'];
        PermissionSetAssignment psaSalesAgent = new PermissionSetAssignment();
        psaSalesAgent.AssigneeId= standardUser.id;
        psaSalesAgent.PermissionSetGroupId = pgSalesAgent.id;
        insert psaSalesAgent;

        PermissionSetGroup pgAdmin = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'ILHSalesAdminRole'];
        PermissionSetAssignment psaAdmin = new PermissionSetAssignment();
        psaAdmin.AssigneeId= adminUser.id;
        psaAdmin.PermissionSetGroupId = pgAdmin.id;
        insert psaAdmin;
    }

    @isTest
    static void getPersonaTest() {
        User standardUser = [SELECT id FROM User WHERE FirstName =: 'Standard' AND LastName =: 'User'];
        User adminUser = [SELECT id FROM User WHERE FirstName =: 'Admin' AND LastName =: 'User'];

        System.runAs(standardUser) {
            Assert.areEqual('ILHSalesRetentionAgent', ILHPersona.getPersona());
        }

        System.runAs(adminUser) {
            Assert.areEqual('ILHSalesSystemAdmin', ILHPersona.getPersona());
        }
    }
}