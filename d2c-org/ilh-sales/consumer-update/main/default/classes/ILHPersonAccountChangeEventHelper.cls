/**
 * Copyright: TruStage
 * Purpose: This class is called when an Account or Contact is created or updated.  Then we send the Person Account to the MDM to update.
 */
public class ILHPersonAccountChangeEventHelper {
    private static final Boolean CONSUMER_UPDATE_ENABLED = Boolean.valueOf(System.Label.EnableConsumerUpdate);
    private static final List<String> ACCOUNT_TRIGGERED_FIELDS = new List<String>{
        'Name.FirstName', 'Name.LastName', 'Name.Suffix', 'Name.MiddleName', 'PersonBirthdate', 'PersonHomePhone', 'PersonOtherPhone', 
        'PersonMailingAddress.City', 'PersonMailingAddress.Street', 'PersonMailingAddress.State', 'PersonMailingAddress.PostalCode', 
        'ContractNumberUnformatted__c', 'Gender__pc', 'PersonID__pc'
    };

    /**
     * Purpose: This method gets called after an Account is created or updated
     * @param changedAccounts -- Account records that were update
     */
    public static void accountUpdate(List<AccountChangeEvent> changedAccounts) {
        if (CONSUMER_UPDATE_ENABLED) {
            Set<String> updatedAccountIds = new Set<String>();
            Map<String, String> accountUserIdMap = new Map<String, String>();

            for (AccountChangeEvent ace : changedAccounts) {
                EventBus.ChangeEventHeader header = ace.ChangeEventHeader;
                if (header != null) {
                    Boolean updateConsumer = false;

                    if (header.changetype.equalsIgnoreCase('CREATE')) {//Only update consumer if record is a new Account
                        updateConsumer = true;
                    }

                    if (header?.changedfields != null && !header?.changedfields?.isEmpty() && header.changetype.equalsIgnoreCase('UPDATE')) {
                        for (String cf : header.changedfields) {
                            //If record was updated and the field that was updated is in the list of triggered fields.
                            if (ACCOUNT_TRIGGERED_FIELDS.contains(cf) && !updateConsumer) {
                                updateConsumer = true;
                                break;//Break loop.  We found a field that was updated.  No point in continuing to check.
                            }
                        }
                    }

                    if (updateConsumer && header?.recordids != null && !header?.recordids.isEmpty()) {
                        for (String accId : header.recordids) {
                            accountUserIdMap.put(accId, header.commituser);//Account id, user that updated account
                        }
                    }
                }
            }
            Set<String> accIds = accountUserIdMap.keySet();
            List<Account> accountsToUpdate = changedEventToAccount(accIds);//Get Person Account record to update
            if (accountsToUpdate != null && !accountsToUpdate.isEmpty()) {
                for (Account acc : accountsToUpdate) {
                    Map<String, Object> kvp = new Map<String, Object>{'account' => acc};
                    kvp.put('commituser', accountUserIdMap.get(acc.id));
                    new ILHConsumerUpdateService().sendUpdate(kvp);
                }
            }
        }
    }
    
    /**
     * Purpose: This method queries the record that was updated
     * @param recordIds -- Ids from the record that was updated
     * @return -- Account record that was updated
     */
    @TestVisible 
    private static List<Account> changedEventToAccount(Set<String> recordIds) {
        List<Account> personAccounts = new List<Account>();
        if (recordIds != null && !recordIds.isEmpty()) {
            Id consumerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consumer').getRecordTypeId();
            try {
                personAccounts = [SELECT Id, ContractNumberUnformatted__c, FirstName, LastName, Suffix, MiddleName, PersonBirthdate, Gender__pc, 
                                PersonHomePhone, PersonOtherPhone, PersonMailingCity, PersonMailingStreet, PersonMailingState, PersonMailingPostalCode, PersonID__pc 
                                FROM Account WHERE id IN: recordIds AND RecordTypeId =: consumerRecordTypeId];
            } catch (Exception ex) {
                new ErrorLogger(ex, null, 'ILHPersonAccountChangeEventHelper.cls', null, 'changedEventToAccount', null, 'CPS_Update', null);
            }
        } 
        return personAccounts;
    }
}