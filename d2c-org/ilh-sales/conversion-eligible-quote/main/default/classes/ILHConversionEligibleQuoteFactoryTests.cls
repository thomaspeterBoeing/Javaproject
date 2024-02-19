/**
 * @description       : Test class for ILHConversionEligibleQuoteFactory
 * @last modified on  : 02-18-2024
 **/
@isTest
private with sharing class ILHConversionEligibleQuoteFactoryTests {

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
            List<IConversionEligible> eligibilityServices = ILHConversionEligibleQuoteFactory.getInstances();
            System.assertEquals(0, eligibilityServices.size(), 'No persona found for no persona user');
        }
        Test.stopTest();
    }

    @isTest
    static void testILHSalesRetentionAgentPersona() {
        Test.startTest();
        User standardUser = [SELECT Id FROM User WHERE Alias = 'standu' LIMIT 1];
        System.runAs(standardUser) {
            List<IConversionEligible> eligibilityServices = ILHConversionEligibleQuoteFactory.getInstances();
            System.assertEquals(1, eligibilityServices.size(), 'Persona found for standard user');
        }
        Test.stopTest();
    }

    @isTest
    static void testILHSalesSystemAdminPersona() {
        Test.startTest();
        User adminUser = [SELECT Id FROM User WHERE Alias = 'adminu' LIMIT 1];
        System.runAs(adminUser) {
            List<IConversionEligible> eligibilityServices = ILHConversionEligibleQuoteFactory.getInstances();
            System.assertEquals(1, eligibilityServices.size(), 'Persona found for standard user');
        }
        Test.stopTest();
    }
}