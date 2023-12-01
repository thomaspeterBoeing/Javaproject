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
}