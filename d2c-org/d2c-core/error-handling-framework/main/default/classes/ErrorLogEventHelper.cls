/**
************************************************************************
Apex Class Name    : ErrorLogEventHelper
Created Date       : September 26, 2023
@description       : This class is helper class for the ErrorLogTrigger
@author            : Adam Perschke-Ely
Modification Log:
Ver   Date         Author                               Modification
1.0   09-26-2023   Adam Perschke-Ely                   Initial Version
************************************************************************
*/
public with sharing class ErrorLogEventHelper {
    /**
    ***********************************************************************************************
    @Method Name    : addErrorToLog
    @author         : Adam Perschke-Ely
    @description    : This method maps exception log to error log object, then inserts the records
    @param errors   : List of Exception Logs from ErrorLogTrigger
    ***********************************************************************************************
    */
    public static void addErrorToLog(List<ExceptionLog__e> errors) {
        List<ErrorLog__c> logs = new List<ErrorLog__c>();
        for(ExceptionLog__e error : errors) {
            //Map Exception log to Error Log custom object
            ErrorLog__c logRecord = new ErrorLog__c();
            logRecord.ErrorDescription__c = error.ErrorDescription__c;
            logRecord.ProcessName__c = error.ProcessName__c;
            logRecord.ReferenceID__c = error.ReferenceID__c;
            logRecord.CurrentUser__c = error.CurrentUser__c;
            logRecord.Operation__c = error.Operation__c;
            logRecord.RequestData__c = error.RequestData__c;
            logRecord.ServiceName__c = error.ServiceName__c;
            logRecord.StackTrace__c	= error.StackTrace__c;
            logRecord.TypeOfError__c = error.TypeOfError__c;
            logRecord.ResponseCode__c = error.ResponseCode__c;
            logs.add(logRecord);
        }
        
        //If there's any logs, then insert them
        if(!logs?.isEmpty()) {
            insert logs;
        }
    }
}