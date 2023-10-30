@isTest
public with sharing class ErrorLogEventHelperTests {
    
    @isTest
    static void addErrorToLogTest() {
        ExceptionLog__e logRecord = new ExceptionLog__e();
			
		logRecord.ErrorDescription__c = 'Test Description';
		logRecord.ProcessName__c = 'ErrorLogEventHelperTests';
		logRecord.ReferenceID__c = '11111111111111';
		logRecord.CurrentUser__c = UserInfo.getUserId();
		logRecord.Operation__c = 'Inserting Account Records';
		logRecord.RequestData__c = 'Test Request Data';
		logRecord.ServiceName__c = 'Some_Service';
		logRecord.StackTrace__c	= 'Test Stack Trace';
		logRecord.TypeOfError__c = 'Test Type Of Error';

        Test.startTest();
		eventBus.publish(logRecord);
        Test.stopTest();

        ErrorLog__c[] errorLog = [SELECT id, ErrorDescription__c, ProcessName__c, ReferenceID__c, CurrentUser__c, Operation__c, RequestData__c,
                                ServiceName__c, StackTrace__c, TypeOfError__c FROM ErrorLog__c];

        Assert.areEqual(1, errorLog.size(), 'Error log has been inserted');
        Assert.areEqual('Test Description', errorLog[0].ErrorDescription__c, 'Error description has been mapped');
        Assert.areEqual('ErrorLogEventHelperTests', errorLog[0].ProcessName__c, 'Process Name has been mapped');
        Assert.areEqual('11111111111111', errorLog[0].ReferenceID__c, 'Reference Id has been mapped');
        Assert.areEqual(UserInfo.getUserId(), errorLog[0].CurrentUser__c, 'Current User has been mapped');
        Assert.areEqual('Inserting Account Records', errorLog[0].Operation__c, 'Operation has been mapped');
        Assert.areEqual('Test Request Data', errorLog[0].RequestData__c, 'Request Data has been mapped');
        Assert.areEqual('Some_Service', errorLog[0].ServiceName__c, 'Service Name has been mapped');
        Assert.areEqual('Test Stack Trace', errorLog[0].StackTrace__c, 'Stack Trace has been mapped');
        Assert.areEqual('Test Type Of Error', errorLog[0].TypeOfError__c, 'Type Of Error has been mapped');
    }
}