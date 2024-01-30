/***
Copyright: CUNA Mutual Group
Purpose: Determines the persona to use for dispatching services.
1.0 - Rick Baker   - 822/2023  - Created for new D2C Salesfore instance.
***/
public class ILHPersona {
    private Id currentUserId;//Id of user running current operation

    /**
     * Purpose: Constructor that sets currentUserId to id from argument
     */
    public ILHPersona(Id userId) {
        currentUserId = userId;
    }

    /**
     * Purpose: Default constructor.  Set user id to current user id.
     */
    public ILHPersona() {
        currentUserId = UserInfo.getUserId();
    }

    /***
     * Gets the persona to use in retrieving all relevent concrete service classes to dispatch.
     * @return The calculated persona.
     */
    public static String getPersona (String factory) {
        return new ILHPersona().determinePersona(factory);
    }

    /***
     * Gets the persona to use in retrieving all relevent concrete service classes to dispatch.
     * @return The calculated persona.
     */
    public String getPersona() {
        return determinePersona();
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

    /***
     * Determines the persona to use in retrieving all relevent concrete service classes to dispatch.
     * @return The calculated persona.
     */
    private String determinePersona() {
        String thePersona = '';

        //Find current user information
        User currentUser = [SELECT PartnerCode__c FROM User WHERE id =: currentUserId];

        //Get permission set group assignments based on current user id
        List<PermissionSetAssignment> psas = [SELECT PermissionSetGroup.DeveloperName FROM PermissionSetAssignment WHERE AssigneeId =: currentUserId AND IsActive =: true AND PermissionSetGroupId != null];

        if (psas != null && !psas.isEmpty()) {
            Set<String> psasStrings = new Set<String>();
            for (PermissionSetAssignment psa : psas) {
                psasStrings.add(psa.PermissionSetGroup.DeveloperName);
            }

            //Find personas based on user partner code and which permission set groups they're assigned to
            List<PersonaAssignment__mdt> personas = [SELECT DeveloperName FROM PersonaAssignment__mdt WHERE PartnerCode__c =: currentUser.PartnerCode__c AND PermissionSetGroup__c IN: psasStrings];
            if (personas != null && !personas.isEmpty()) {
                thePersona = personas[0].DeveloperName;//Persona is equal to first developer name
            }
        }
        return thePersona;
    }
}