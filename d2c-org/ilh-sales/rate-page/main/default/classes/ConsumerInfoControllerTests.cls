/**
 * Copyright: TruStage
 * Purpose: Unit tests for the ConsumerInfoController class
 */
@isTest
private class ConsumerInfoControllerTests {

    @isTest
    static void getOpportunityFieldsDataTest() {
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id affiliationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Affiliation').getRecordTypeId();

        Account person = new Account (
            FirstName = 'FirstNameTest',
            LastName = 'LastNameTest',
            Gender__pc = 'Male',
            DomicileState__c = 'WI',
            RecordTypeId = personRecordTypeId
        );
        insert person;

        Account affiliation	= new Account (
            Name = 'TestAffiliation',
            RecordTypeId = affiliationRecordTypeId
        );
        insert affiliation;

        Opportunity opp = new Opportunity (
            AccountId = person.id,
            Affiliation__c = affiliation.id,
            Name = 'TestOpp',
            StageName = 'Qualification',
            CloseDate = Date.today(),
            InsurancePurpose__c = 'Undecided',
            HealthAssessment__c = 'No Health Issues',
            TobaccoUse__c = 'No'
        );
        insert opp;

        Opportunity finalOpp = ConsumerInfoController.getOpportunityFieldsData(opp.id);
        Assert.areEqual('Male', finalOpp.Account.Gender__pc);
        Assert.areEqual('FirstNameTest', finalOpp.Account.FirstName);
        Assert.areEqual('LastNameTest', finalOpp.Account.LastName);
        Assert.areEqual('Undecided', finalOpp.InsurancePurpose__c);
        Assert.areEqual('No Health Issues', finalOpp.HealthAssessment__c);
        Assert.areEqual('No', finalOpp.TobaccoUse__c);
        Assert.areEqual('WI', finalOpp.Account.DomicileState__c);
        Assert.areEqual('TestAffiliation', finalOpp.Affiliation__r.Name);

        try {
            finalOpp = ConsumerInfoController.getOpportunityFieldsData(null);
            Assert.fail();
        } catch (Exception ex) {}
    }
}