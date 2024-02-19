/**
 * @description       : Test class for ILHMarketingHistoryFactory
 * @last modified on  : 02-16-2024
 **/
@isTest
private with sharing class ILHMarketingHistoryFactoryTests {

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
    static void testNoPersonaDefined() {
        Test.startTest();
        User nopersonUser = [SELECT Id FROM User WHERE Alias = 'noperson' LIMIT 1];
        System.runAs(nopersonUser) {
            List<IMarketingHistoryService> historyServices = ILHMarketingHistoryFactory.getInstances();
            Assert.areEqual(0, historyServices.size(), 'No persona found for no persona user');
        }
        Test.stopTest();
    }

    @isTest
    static void testILHSalesRetentionAgentPersona() {
        Test.startTest();
        User standardUser = [SELECT Id FROM User WHERE Alias = 'standu' LIMIT 1];
        System.runAs(standardUser) {
            List<IMarketingHistoryService> historyServices = ILHMarketingHistoryFactory.getInstances();
            Assert.areNotEqual(0, historyServices.size(), 'Persona found for standard user');
        }
        Test.stopTest();
    }

    @isTest
    static void testILHSalesSystemAdminPersona() {
        Test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Alias = 'adminu' LIMIT 1];
        System.runAs(adminUser) {
            List<IMarketingHistoryService> historyServices = ILHMarketingHistoryFactory.getInstances();
            Assert.areNotEqual(0, historyServices.size(), 'Persona found for standard user');
        }
        Test.stopTest();
    }
}