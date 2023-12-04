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
}