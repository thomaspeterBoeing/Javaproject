/***
Copyright: CUNA Mutual Group
Purpose: Determines the persona to use for dispatching services.
1.0 - Rick Baker   - 822/2023  - Created for new D2C Salesfore instance.
***/
public with sharing class ILHPersona {
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
    public String getPersona() {
        return determinePersona();
    }

    /***
     * Determines the persona to use in retrieving all relevent concrete service classes to dispatch.
     * @return The calculated persona.
     */
    private String determinePersona() {
        String thePersona = '';
        List<PersonaAssignment__mdt> persona = new List<PersonaAssignment__mdt>();
        User currentUser = new User();

        //Find current user information
        try {
            if (Schema.sObjectType.User.isAccessible()) {
                currentUser = [SELECT Name, PartnerCode__c, Persona__c FROM User WHERE id =: currentUserId]; 
            }
            if (currentUser != null) {
                persona = [SELECT DeveloperName FROM PersonaAssignment__mdt WHERE PartnerCode__c =: currentUser.PartnerCode__c AND UserPersona__c =: currentUser.Persona__c];
            }
        } catch (Exception ex) {
            new ErrorLogger(ex, null, 'ILHPersona.cls', currentUserId, 'determinePersona', null, null, null);
        }
        
        if (persona != null && !persona.isEmpty()) {
            thePersona = persona[0].DeveloperName;
        } else {//Log an error if no persona was found
            String errorMessage = 'No persona found for User: ' + currentUser.Name;
            new ErrorLogger(new ErrorLogger.handleCaughtErrorException(errorMessage), null, 'ILHPersona.cls', currentUserId, 'Persona Assignment', null, null, null);
        }
        return thePersona;
    }
}