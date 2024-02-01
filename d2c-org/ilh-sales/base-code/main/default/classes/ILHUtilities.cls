/**
 * Copyright: TruStage
 * Purpose: This class contains ILH Utility methods
 */
public with sharing class ILHUtilities {
    /**
     * Purpose: This method removes service user ids from a list of ids
     * @param userIds -- Ids of users 
     * @return -- Set of ids that don't contain service user ids
     */
    public static Set<Id> removeServiceUsersFromList(List<Id> userIds) {
        Set<Id> nonServiceIds = new Set<Id>();
        if (userIds != null && !userIds.isEmpty()) {
            Map<Id, User> userMap = new Map<Id, User>([SELECT id FROM User WHERE id IN: userIds AND (NOT Name LIKE: '%Service%')]);
            if (userMap != null && !userMap.isEmpty()) {
                nonServiceIds = userMap.keySet();
            }
        }
        return nonServiceIds;
    }

    /**
     * Purpose: This method get DI Consumer containers by persona
     * @param persona Name of persona to search on
     * @return List of containers
     */
    public static List<DIConsumerContainer__mdt> getDIConsumerContainer(String persona, String factory) {
        List<DIConsumerContainer__mdt> containers = new List<DIConsumerContainer__mdt>();

        try {
            containers = [SELECT MasterLabel, DeveloperName, Dependencies__c, Persona__c FROM DIConsumerContainer__mdt WHERE Persona__c =: persona AND MasterLabel =: factory];
        } catch (Exception ex) {
            new ErrorLogger(ex, null, 'ILHUtilities.cls', null, 'getDIConsumerContainer', null, null, null);
        }
        return containers;
    }
}