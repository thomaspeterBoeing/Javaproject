trigger ErrorLogTrigger on ExceptionLog__e (after insert) {
    if(Trigger.isAfter && Trigger.isInsert) {
        ErrorLogEventHelper.addErrorToLog(Trigger.new);//Inserting a new Error Log record on the custom object
    }
}