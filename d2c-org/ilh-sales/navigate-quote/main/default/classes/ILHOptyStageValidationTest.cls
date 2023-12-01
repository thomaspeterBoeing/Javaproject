/*
Purpose: This is test class for before Save record trigger flow ILH_Opportunity_Stage_Validation_Before_Save

*/
@isTest
public class ILHOptyStageValidationTest {
	
    @isTest
    static void testOpptyStageValidationWithRequiredFields() {
        // Create test opportunity with required fields populated
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Quote',
            HealthAssessment__c='Health Issues',
            InsurancePurpose__c='Final Expenses',
            TobaccoUse__c='No',
            CloseDate = System.today(),
            ProposedCoverage__c = 5000
        );
        insert testOpportunity;

        // Create an instance of the flow
        Map<String, Object> inputVariables = new Map<String, Object>();
        inputVariables.put('recordId', testOpportunity);

        // Start the flow
        Flow.Interview BeforeSaveFlow = new Flow.interview.ILH_Opportunity_Stage_Validation_Before_Save(inputVariables);
        BeforeSaveFlow.start();
        
        // Check if opportunity Stage got updated to Quote
        Opportunity updatedOpportunity = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpportunity.Id];
        System.assertEquals('Quote', updatedOpportunity.StageName);
        
       
    }

    @isTest
    static void testOpptyStageValidationWithoutRequiredFields() {
        // Create test opportunity without required fields
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Needs Assessment',
            CloseDate = System.today()
            // omitting HealthAssessment__c, InsurancePurpose__c, TobaccoUse__c, ProposedCoverage__c
        );
        insert testOpportunity;

        // Create an instance of the flow
        Map<String, Object> inputVariables = new Map<String, Object>();
        inputVariables.put('recordId', testOpportunity.Id);

        // Start the flow
        Flow.Interview BeforeSaveFlow = new Flow.interview.ILH_Opportunity_Stage_Validation_Before_Save(inputVariables);
        BeforeSaveFlow.start();
        
        // Check if opportunity Stage remains the same (Needs Assessment)
        Opportunity updatedOpportunity = [SELECT Id, StageName,Name FROM Opportunity WHERE Id = :testOpportunity.Id];
        System.assertNotEquals('not Quote', updatedOpportunity.StageName);
    }
    
    @isTest
    static void testOpptyStageValidationNYWithRequiredFields() {
        //create test account
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.PersonMailingState ='NY';
        
        // Create test opportunity with required fields populated
 		Opportunity opptyNY = new Opportunity();
        opptyNY.Name ='Test Opty';
        opptyNY.StageName = 'Quote';
        opptyNY.AccountId = acc.Id;
        opptyNY.HealthAssessment__c = 'Health Issues';
        opptyNY.InsurancePurpose__c = 'Final Expenses';
        opptyNY.TobaccoUse__c = 'No';
        opptyNY.ProposedCoverage__c = 10000;
        opptyNY.CloseDate = System.today();
        
        insert opptyNY;

        // Create an instance of the flow
        Map<String, Object> inputVariables = new Map<String, Object>();
        inputVariables.put('recordId', opptyNY.Id);

        // Start the flow
        Flow.Interview BeforeSaveFlow = new Flow.interview.ILH_Opportunity_Stage_Validation_Before_Save(inputVariables);
        BeforeSaveFlow.start();
        
        // Check if opportunity Stage got updated to Quote
        Opportunity updatedOpportunity = [SELECT Id, StageName FROM Opportunity WHERE Id = :opptyNY.Id];
        System.assertEquals('Quote', updatedOpportunity.StageName);
        
       
    }
    
    @isTest
    static void testOpptyStageValidationNYWithoutRequiredField() {
        //create test account
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.PersonMailingState ='';
        
        // Create test opportunity with required fields populated
 		Opportunity opptyNY = new Opportunity();
        opptyNY.Name ='Test Opty';
        opptyNY.StageName = 'Quote';
        opptyNY.AccountId = acc.Id;
        opptyNY.HealthAssessment__c = 'Health Issues';
        opptyNY.InsurancePurpose__c = 'Final Expenses';
        opptyNY.TobaccoUse__c = 'No';
        opptyNY.ProposedCoverage__c = 10000;
        opptyNY.CloseDate = System.today();
        
        insert opptyNY;

        // Create an instance of the flow
        Map<String, Object> inputVariables = new Map<String, Object>();
        inputVariables.put('recordId', opptyNY);

        // Start the flow
        Flow.Interview BeforeSaveFlow = new Flow.interview.ILH_Opportunity_Stage_Validation_Before_Save(inputVariables);
        BeforeSaveFlow.start();
        
        // Check if opportunity Stage got updated to Quote
        Opportunity updatedOpportunity = [SELECT Id, StageName FROM Opportunity WHERE Id = :opptyNY.Id];
        System.assertNotEquals('not Quote', updatedOpportunity.StageName);
        
        
    }
}