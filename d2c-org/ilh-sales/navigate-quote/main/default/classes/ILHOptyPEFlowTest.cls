/*
Purpose: This is test class for after Save record trigger flow ILH_Publish_Opportunity_Stage_PE

*/
@isTest
public class ILHOptyPEFlowTest {

    @isTest
    static void PublishPlatformEvtTest() {
        // Create a test Opportunity record
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Quote',
            HealthAssessment__c='Health Issues',
            InsurancePurpose__c='Final Expenses',
            TobaccoUse__c='No',
            CloseDate = system.today(),
            ProposedCoverage__c =123
           
        );
        insert testOpportunity;
        
        // Convert Opportunity instance to JSON string
        // String opportunityJson = JSON.serialize(testOpportunity);
       
        // Create an instance of the flow
        Map<String, Object> inputVariables = new Map<String, Object>();
        inputVariables.put('recordId', testOpportunity);
        
        // Instantiate the flow and set input variables
        Flow.Interview OptyPEFlow = new Flow.interview.ILH_Publish_Opportunity_Stage_PE(inputVariables);
              
        // Start the flow
        Test.startTest();
        OptyPEFlow.start();
        Test.stopTest();

        // Assert that the Platform Event was created
		// have not figured a way to validate that PE was created. 
    }
}