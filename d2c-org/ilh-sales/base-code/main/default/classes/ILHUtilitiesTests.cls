/**
 * Copyright: TruStage
 * Purpose: Unit tests for ILHUtilities class
 */
@isTest
public class ILHUtilitiesTests {
    @isTest
    public static void removeServiceUsersFromListTest() {
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

        Test.startTest();
        Set<Id> userIds = ILHUtilities.removeServiceUsersFromList(new List<Id>{serviceUser.id, standardUser.id});
        Assert.areEqual(1, userIds.size());
        Assert.areEqual(standardUser.id, userIds.iterator().next(), 'Standard user id is the only id in the list');
    }
}