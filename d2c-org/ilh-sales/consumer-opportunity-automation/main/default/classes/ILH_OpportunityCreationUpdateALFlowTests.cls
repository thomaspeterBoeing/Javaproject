/***
Copyright: TruStage
Purpose: Provides unit testing and code coverage for ILH_OpportunityCreationUpdate flow.
1.0 - Scott Martin - 11/13/2023  - Created for new D2C Salesfore instance.
2.0 - Mike Tierman - 3/6/2024 - Added coverage for Task, Campaign and Campaign Member.
***/
@isTest
public with sharing class ILH_OpportunityCreationUpdateALFlowTests {

    @TestSetup
    static void loadTestData() {
      //save a person account record
      List<RecordType> results = [SELECT Id FROM RecordType where DeveloperName = 'Consumer'];
      Id paId = (Id) results[0].get('Id');
      Account acct = new Account(FirstName='Bobby', LastName='Brown', RecordTypeID = paId);
      insert acct;
    }

    @isTest 
    static void testRecordIsInserted() {
        //Opportunity is created
        //No Campaign is found 

        Integer recordCountBefore;
        Integer recordCountAfter;

        //select PersonAccount from database
        Account persAcc = [SELECT Id FROM Account where Name = 'Bobby Brown'];

        //get count of Opportunity records with same Account ID
        List<AggregateResult> results = [SELECT count(Id) FROM Opportunity where AccountId = :persAcc.Id];
        recordCountBefore = (Integer) results[0].get('expr0');
        
        //provide value for a new Opportunity record
        string flowVar =    '[{"name": "inputTxt_AccountId","type": "String","value": "' + persAcc.Id + '"}]';

        //pass the record to the flow
        test.startTest();
        String outputVar = IlhAutoLaunchFlow.startFlow('ILH_OpportunityCreationUpdate', flowVar, 'outputTxt_OpportunityId');
        test.stopTest();

        //get count of Opportunity records with same Account ID
        List<AggregateResult> results2 = [SELECT count(Id) FROM Opportunity where AccountId = :persAcc.Id];
        recordCountAfter = (Integer) results2[0].get('expr0');

        //assert that record exists
        system.assertEquals(recordCountBefore + 1, recordCountAfter, 'Opportunity record was expected to be created but was not.');

    }
    
    @isTest 
    static void testBadRecordIsHandled() {

        Integer recordCountBefore;
        Integer recordCountAfter;

        //get count of ErrorLog records
        List<AggregateResult> results = [SELECT count(Id) FROM ErrorLog__c];
        recordCountBefore = (Integer) results[0].get('expr0');

        //select PersonAccount from database
        String acId = 'XXXYYYZZZ';

        //provide values for a new Opportunity record
        string flowVar =    '[{"name": "inputTxt_AccountId","type": "String","value": "' + acId + '"},{"name": "closeDate","type": "Date","value": "2000-01-01"}]';

        //pass the record to the flow
        test.startTest();
        String outputVar = IlhAutoLaunchFlow.startFlow('ILH_OpportunityCreationUpdate', flowVar, 'outputTxt_OpportunityId');
        test.stopTest();

        //get count of ErrorLog records
        List<AggregateResult> results2 = [SELECT count(Id) FROM ErrorLog__c];
        recordCountAfter = (Integer) results2[0].get('expr0');

		    //assert that an ErrorLog record was created
        System.assertEquals(recordCountBefore + 1, recordCountAfter, 'Error Log record count was expected to increase by 1 but has not.');


    }
    @isTest 
    static void testCreateCallTask() {
       
        //select PersonAccount from database
        Account persAcc = [SELECT Id FROM Account where Name = 'Bobby Brown'];
        Contact cnt = [SELECT Id FROM Contact WHERE AccountId = :persAcc.Id LIMIT 1];

         //provide value for a new Opportunity record
        string flowVar =    '[{"name": "inputTxt_AccountId","type": "String","value": "' + persAcc.Id + '"}]';

        //pass the record to the flow
        test.startTest();
            String outputVar = IlhAutoLaunchFlow.startFlow('ILH_OpportunityCreationUpdate', flowVar, 'outputTxt_OpportunityId');
        test.stopTest();

        system.debug('Output Var = ' + outputVar);

       
        Task callTask = [SELECT Id FROM Task WHERE  WhatID = :outputVar AND WhoId = :cnt.Id AND Status = 'In Progress' LIMIT 1];
        
        system.debug('Contact ID ' + cnt.Id);
          
        System.Assert.isNotNull(callTask.Id, 'No Call Task was created');

    }
    // Test for Campaign 
    @isTest 
    static void testCampaign() {
        //Test Campaign and Campaign Member Assignment
       
        //select PersonAccount from database
        Account persAcc = [SELECT Id FROM Account where Name = 'Bobby Brown'];
        Contact cnt = [SELECT Id FROM Contact WHERE AccountId = :persAcc.Id LIMIT 1];

        List<RecordType> results = [SELECT Id FROM RecordType where DeveloperName = 'ILHSalesMarketing'];
        Id rId = (Id) results[0].get('Id');
        Campaign cmp = new Campaign(
                    Name='TestCampaign', 
                    Status='In Progress',
                    IsActive=true,
                    StartDate=date.today(),
                    EndDate=date.today().addMonths(3),
                    Persona__c='Retention',
                    RecordTypeID = rId);
        insert cmp;
        
         //provide value for a new Opportunity record
        string flowVar =    '[{"name": "inputTxt_AccountId","type": "String","value": "' + persAcc.Id + '"}]';

        //pass the record to the flow
        test.startTest();
            String outputVar = IlhAutoLaunchFlow.startFlow('ILH_OpportunityCreationUpdate', flowVar, 'outputTxt_OpportunityId');
        test.stopTest();

        system.debug('Output Var = ' + outputVar);

        //system.debug('Contact ID ' + cnt.Id);
        Opportunity oppty = [SELECT CampaignId FROM Opportunity WHERE Id = :outputVar];
        CampaignMember cmpMember = [SELECT Id FROM CampaignMember WHERE CampaignId = :cmp.Id AND ContactId = :cnt.Id ];
   
        System.assertEquals(oppty.CampaignId,cmp.Id, 'Campaign not updated on Opportunity');
        System.Assert.isNotNull(cmpMember.Id, 'Campaign Member not created');
        

    }
    
    // Test contact being added twice to campaign.
    // This should ignore 2nd contact and create opportunity.
    @isTest 
    static void testDuplicateCampaignMember() {
              
        //select PersonAccount from database
        Account persAcc = [SELECT Id FROM Account where Name = 'Bobby Brown'];
        Contact cnt = [SELECT Id FROM Contact WHERE AccountId = :persAcc.Id LIMIT 1];

        List<RecordType> results = [SELECT Id FROM RecordType where DeveloperName = 'ILHSalesMarketing'];
        Id rId = (Id) results[0].get('Id');
        Campaign cmp = new Campaign(
                    Name='TestCampaign', 
                    Status='In Progress',
                    IsActive=true,
                    StartDate=date.today(),
                    EndDate=date.today().addMonths(3),
                    Persona__c='Retention',
                    RecordTypeID = rId);
        insert cmp;
        
         //provide value for a new Opportunity record
        string flowVar =    '[{"name": "inputTxt_AccountId","type": "String","value": "' + persAcc.Id + '"}]';

        //pass the record to the flow
        test.startTest();
            String outputVar = IlhAutoLaunchFlow.startFlow('ILH_OpportunityCreationUpdate', flowVar, 'outputTxt_OpportunityId');
            String outputVar2 = IlhAutoLaunchFlow.startFlow('ILH_OpportunityCreationUpdate', flowVar, 'outputTxt_OpportunityId');
        test.stopTest();

        //system.debug('Contact ID ' + cnt.Id);
        
        
   
        System.Assert.isNotNull(outputVar2, 'Opportunity not created');
        

    }
    }