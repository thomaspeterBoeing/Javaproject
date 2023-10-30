@isTest
public with sharing class ErrorLoggerTests {
    
    @isTest
    static void publishExceptionTest() {
        try {
            Account acc = new Account(id = '111111111111');
            update acc;
            Assert.fail('Failed while updating Account');
        } catch(Exception ex) {
            try {
                new ErrorLogger(ex, 'Error Occured', 'ErrorLoggerTests', '11111111111111', 'Updating Account', 'Test Request Data', 'Some_Service', 200);
            } catch(Exception e) {}            
        }
    }

    @isTest
    static void publishExceptionFlowTest() {
        try {
            Account acc = new Account(id = '111111111111');
            update acc;
            Assert.fail('Failed while updating Account');
        } catch(Exception ex) {
            try {
                List<ErrorLogger> logs = new List<ErrorLogger>();
                ErrorLogger log = new ErrorLogger();
                log.operation = 'Updating Account';
                log.processName = 'ErrorLoggerTests';
                log.recordId ='11111111111111';
                logs.add(log);
                ErrorLogger.handleError(logs);
            } catch(Exception e) {}            
        }
    }
}