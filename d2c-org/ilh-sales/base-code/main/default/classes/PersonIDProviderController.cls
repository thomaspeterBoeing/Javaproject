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
 * Modifications:
 *************************************************************************************/
public with sharing class PersonIDProviderController {
    
    @AuraEnabled(cacheable=true)
    public static String getPersonId(String recordId, String objectApiName) {
        string personId;

        try {
            if (objectApiName == 'Account') {
                personId = [SELECT PersonID__pc FROM Account WHERE Id = :recordId LIMIT 1].PersonID__pc;
            } else if (objectApiName == 'Opportunity') {
                personId = [SELECT Account.PersonID__pc FROM Opportunity WHERE Id = :recordId LIMIT 1].Account.PersonID__pc;
            }
        }catch(Exception ex) {
            new ErrorLogger(ex, 'An error occured while fetching PersonId.', 'PersonIDProviderController.cls', null, 'getPersonId', null, null, null);
        }

        return personId;
    }
}