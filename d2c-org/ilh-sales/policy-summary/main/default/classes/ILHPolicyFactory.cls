public with sharing class ILHPolicyFactory {
    /***
     * Gets all concrete class instances that implement interfaces that are
     * designated in the "Interface Implementations" custom metadata.
     *
     * @return All instances of concrete class, each of which implements the
     *         interface designated in the "Interface Implementations" custom metadata.
     */
    public static List<IPolicySearch> getInstances() {
        return new ILHPolicyFactory().constructInstances();
    }

    /***
     * Instantiates and returns all concrete class instances that implement interfaces
     * that are designated in the "Interface Implementations" custom metadata based on the
     * calculated persona.
     *
     * @return All instances of concrete class, each of which implements the
     *         interface designated in the "Interface Implementations" custom metadata.
     */
    private List<IPolicySearch> constructInstances() {

        List<IPolicySearch> classInstances = new List<IPolicySearch>();
        String persona = new ILHPersona().getPersona();//Get persona

        //Get an instance of the persona from the consumer container
        List<DIConsumerContainer__mdt> instanceContainer = ILHUtilities.getDIConsumerContainer(persona, 'PolicySummary');
        
        //Check if there's containers found and there's dependencies
        if (instanceContainer != null && !instanceContainer.isEmpty() && instanceContainer[0]?.Dependencies__c != null) {
            //Loop through each dependency in the consumer container
            for (String dep : instanceContainer[0].Dependencies__c.split(',')) {
                //Get the instance of the dependency from interface implementations
                InterfaceImplementations__mdt implementation = InterfaceImplementations__mdt.getInstance(dep);

                //Add a new instance of the implementations to the list
                classInstances.add((IPolicySearch)Type.forName(implementation.Implementation__c).newInstance());
            }
        }
        return classInstances;
    }
}