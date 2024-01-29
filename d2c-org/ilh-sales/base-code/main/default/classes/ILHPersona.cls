/***
Copyright: CUNA Mutual Group
Purpose: Determines the persona to use for dispatching services.
1.0 - Rick Baker   - 822/2023  - Created for new D2C Salesfore instance.
***/
public class ILHPersona {
    /***
     * Gets the persona to use in retrieving all relevent concrete service classes to dispatch.
     * @return The calculated persona.
     */
    public static String getPersona (String factory) {
        return new ILHPersona().determinePersona(factory);
    }

    public static String getPersona() {
        return new ILHPersona().determinePersona();
    }

    /***
     * Determines the persona to use in retrieving all relevent concrete service classes to dispatch.
     * @return The calculated persona.
     */
    private String determinePersona (String factory) {
        String thePersona = '';

        switch on factory {
            when 'ILHMarketingHistoryFactory' {
                thePersona = 'ILH_CSMarketingHistory';
            }
            when 'ILHSearchFactory' {
                thePersona = 'ILH_CSConsumerSearch';
            }
            when 'ILHPolicyFactory'{
                thePersona = 'ILH_CSPolicySearch';
            }
            when 'ILHConsumerUpdateFactory'{
                thePersona = 'ILH_CSConsumerUpdate';
            }
            when else {
                thePersona = '';
            }
        }
        return thePersona;
    }

    private String determinePersona() {
        String thePersona = '';
        Id userId = UserInfo.getUserId();

        User u = [SELECT PartnerCode__c FROM User WHERE id =: userId];
        List<PermissionSetAssignment> psas = [SELECT PermissionSetGroup.DeveloperName FROM PermissionSetAssignment WHERE AssigneeId =: userId AND IsActive =: true AND PermissionSetGroupId != null];

        if (psas != null && !psas.isEmpty()) {
            Set<String> psasStrings = new Set<String>();
            for (PermissionSetAssignment psa : psas) {
                psasStrings.add(psa.PermissionSetGroup.DeveloperName);
            }
            List<PersonaAssignment__mdt> pas = [SELECT DeveloperName FROM PersonaAssignment__mdt WHERE PartnerCode__c =: u.PartnerCode__c AND PermissionSetGroup__c	IN: psasStrings];
            if (pas != null && !pas.isEmpty()) {
                thePersona = pas[0].DeveloperName;
            }
        }
        return thePersona;
    }
}