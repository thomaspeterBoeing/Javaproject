/**
*****************************************************************************************************
Apex Class Name    : ErrorLogger
Created Date       : September 26, 2023
@description       : The purpose of this class is to consume an error and create a new exception log
@author            : Adam Perschke-Ely
Modification Log:
Ver   Date         Author                               Modification
1.0   09-26-2023   Adam Perschke-Ely                   Initial Version
*****************************************************************************************************
*/
public with sharing class ErrorLogger {
    private static final Boolean ERROR_LOGS_ENABLED = Boolean.valueOf(System.Label.EnableErrorLogs);

	@InvocableVariable
	public String processName;
	@InvocableVariable
	public String recordId;
	@InvocableVariable
	public String operation;
	@InvocableVariable
	public String requestData;
	@InvocableVariable
	public String serviceName;
	@InvocableVariable
	public String errorDescription;
	@InvocableVariable
	public String stackTrace;
	@InvocableVariable
	public String typeOfError;
	private Exception ex;
	private String strErrorMsg;
	private Integer responseCode;

	/**
	 * Default constructor
	 */
	public ErrorLogger() {}

	/**
    ***************************************************************************************************************************************
	@author         : Adam Perschke-Ely
    @description    : This method maps input values to variables.
	@param ex : Exception from where error originated.
    @param processName   : Indicates where the error originated.
	@param strErrorMsg   : Detailed description of error.
	@param recordId   : Id of record that triggered the error.
	@param operation : Type of operation that was preformed when the error occurred.
	@param requestData : Data that was entered by user when the error occurred.
	@param serviceName : Name of the service that was called when the error occurred.
	@param responseCode : Status from callout.
    ***************************************************************************************************************************************
    */
	public ErrorLogger(Exception ex, String strErrorMsg, string processName, string recordId, String operation, String requestData, String serviceName, 
						Integer responseCode) {
		this.ex = ex;
		this.strErrorMsg = strErrorMsg;
		this.processName = processName;
		this.recordId = recordId;
		this.operation = operation;
		this.requestData = requestData;
		this.serviceName = serviceName;
		this.responseCode = responseCode;
		this.errorDescription = ex?.getMessage();
		this.stackTrace = ex?.getStackTraceString();
		this.typeOfError = ex?.getTypeName();
		this.publishException();
	}

	/**
    ***************************************************************************************************************************************
    @Method Name    : handleError
    @author         : Adam Perschke-Ely
    @description    : This method accepts error log information from a flow.
	@param logs : List of error logs from flow. Should only be one record.
    ***************************************************************************************************************************************
    */
	@InvocableMethod(label='Handle Errors')
	public static void handleError(List<ErrorLogger> logs) {
		logs[0].publishException();
	}

	/**
    ***************************************************************************************************************************************
    @Method Name    : publishException
    @author         : Adam Perschke-Ely
    @description    : This method publishes an exception record. ErrorLogEventHandler will create the error log record on the custom object
    ***************************************************************************************************************************************
    */
	public void publishException() {
		if((String.isNotEmpty(processName) || String.isNotEmpty(recordId) || String.isNotEmpty(operation) || String.isNotEmpty(requestData) || 
			String.isNotEmpty(serviceName) || String.isNotEmpty(errorDescription) || String.isNotEmpty(stackTrace) || String.isNotEmpty(typeOfError) || 
			responseCode != null) && ERROR_LOGS_ENABLED) {
			ExceptionLog__e logRecord = new ExceptionLog__e();
			
			logRecord.ErrorDescription__c = errorDescription;
			logRecord.ProcessName__c = processName;
			logRecord.ReferenceID__c = recordId;
			logRecord.CurrentUser__c = UserInfo.getUserId();
			logRecord.Operation__c = operation;
			//logRecord.RequestData__c = requestData;TODO: Will enable once we decide on a way to remove sensive data from the request.
			logRecord.ServiceName__c = serviceName;
			logRecord.StackTrace__c	= stackTrace;
			logRecord.TypeOfError__c = typeOfError;
			logRecord.ResponseCode__c = responseCode;
			
			eventBus.publish(logRecord);
		}

		// If the error is set to an error that is already thrown it will not be displayed again.
		if(String.isNotEmpty(strErrorMsg)) {
			throw new handleCaughtErrorException(strErrorMsg);
		}
    }

	/** instance of a new exception for use within this class only **/
	public class handleCaughtErrorException extends Exception {} 
}