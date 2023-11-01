/***
Copyright: CUNA Mutual Group
Purpose: Determines the persona to use for dispatching search services.
         An agorithm needs to be developed for determine the persona.
1.0 - Rick Baker   - 822/2023  - Created for new D2C Salesfore instance.
***/
public with sharing class ILHPersona {

    // *** For debugging and unit testing only - remove when finished ***
    @testVisible
    public static String thePersona = 'ILH_CSConsumerSearch';
    // *** For debugging and unit testing only - remove when finished ***

    /***
     * Gets the persona to use in retrieving all relevent concrete service classes to dispatch.
     *
     * @return The calculated persona.
     */
    public static String getPersona () {

        return new ILHPersona().determinePersona();
    }

    /***
     * Determines the persona to use in retrieving all relevent concrete service classes to dispatch.
     *
     * @return The calculated persona.
     */
    private String determinePersona () {

        // TODO: Develop the algorithm for determine the persona.

        return thePersona;
    }
}