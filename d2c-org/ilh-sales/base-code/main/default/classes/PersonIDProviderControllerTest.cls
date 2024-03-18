/**

 */
@isTest
private class PersonIDProviderControllerTest {
    @isTest
    static void testGetPersonId() {
        // Test data setup
        Date newDate = Date.newInstance(1979, 9, 7);

        Id objectRecordTypeId = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName = 'PersonAccount' AND SobjectType = 'Account'].id;

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

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', AccountId = accnt.Id, StageName='Qualification', CloseDate = Date.Today());
        insert testOpportunity;

        // Test the getPersonId method for Account
        Test.startTest();
        SObject resultAccount = PersonIDProviderController.getPersonId(accnt.Id);
        system.debug('resultAccount ->' +resultAccount);
        

        // Verify the result
        System.assertEquals(accnt.Id, resultAccount.Id);
        System.assertEquals(accnt.PersonID__pc, resultAccount.get('PersonID__pc'));

        // Test the getPersonId method for Opportunity d
        
        Opportunity resultOpportunity = (Opportunity)PersonIDProviderController.getPersonId(testOpportunity.Id);
        system.debug('resultOpportunity ->' +resultOpportunity);
        system.debug('acc personid' +((Account)resultOpportunity.Account).PersonID__pc);
        

         System.assertEquals(accnt.PersonID__pc, ((Account)resultOpportunity.Account).PersonID__pc);

        Test.stopTest();
    }

    @isTest
    static void testGetObjectType() {
        // Test the getObjectType method for Account
        Test.startTest();
        String objectTypeAccount = PersonIDProviderController.getObjectType('001');
        
        System.assertEquals('Account', objectTypeAccount);

        // Test the getObjectType method for Opportunity
        
        String objectTypeOpportunity = PersonIDProviderController.getObjectType('006');
        Test.stopTest();
        System.assertEquals('Opportunity', objectTypeOpportunity);
    }
}
