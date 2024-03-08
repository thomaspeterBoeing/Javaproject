/**********************************************************************************
 * Title:  PersonID Provider Controller
 * Date:   Nov 2023
 * 
 * Description:  Apex Class to query for PersonID from multiple objects   
 * 
 * Details:      Takes record Id and ObjectAPIName. 
 *               returns PersonId.
 *                 
 *          
 * Modifications: 11/08/23 - removed ObjectApiName as a Param and added getObjectType for getPersonId()
 *              : 11/09/23 - returning rec in place of string for getPersonId()
 *************************************************************************************/
public with sharing class PersonIDProviderController {
    
    @AuraEnabled(cacheable=true)
    public static SObject getPersonId(String recordId) {
               
        SObject rec;
        String objectType = getObjectType(recordId);

        try {
            if(objectType !=null){
                if (objectType == 'Account') {
                     rec = [SELECT ID,PersonID__pc FROM Account WHERE Id = :recordId LIMIT 1];
                } else if (objectType == 'Opportunity') {
                     rec = [SELECT AccountId, Account.PersonID__pc, Account.Gender__pc FROM Opportunity WHERE Id = :recordId LIMIT 1];
                }
            }
        }catch(Exception ex) {
            new ErrorLogger(ex, 'An error occured while fetching PersonId.', 'PersonIDProviderController.cls', null, 'getPersonId', null, null, null);
        }

        return rec;
    }

    public static String getObjectType(String recordId) {
        String objectType;

        try {
            Schema.DescribeSObjectResult describeResult = Schema.sObjectType.Account;
            if (recordId.startsWith(describeResult.getKeyPrefix())) {
                objectType = 'Account';
            } else {
                describeResult = Schema.sObjectType.Opportunity;
                if (recordId.startsWith(describeResult.getKeyPrefix())) {
                    objectType = 'Opportunity';
                }
            }
        }catch(Exception ex) {
            new ErrorLogger(ex, 'An error occured while finding object.', 'PersonIDProviderController.cls', null, 'getObjectType', null, null, null);
        }

        return objectType;
    }
}