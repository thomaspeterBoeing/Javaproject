/**
 * Copyright: CUNA Mutual Group
 * Purpose: Constructs instances of concrete classes that implement designated interfaces based off of the calulated persona.
 */
public class ILHSearchFactory {

    /**
     * Purpose: Gets all concrete class instances that implement interfaces that are designated in the "Interface Implementations" custom metadata.
     * @return All instances of concrete class, each of which implements the interface designated in the "Interface Implementations" custom metadata.
     */
    public static List<ISearchService> getInstances() {
        return new ILHSearchFactory().constructInstances();
    }

    /**
     * Purpose: Instantiates and returns all concrete class instances that implement interfaces
     * that are designated in the "Interface Implementations" custom metadata based on the calculated persona.
     * @return All instances of concrete class, each of which implements the interface designated in the "Interface Implementations" custom metadata.
     */
    private List<ISearchService> constructInstances() {
        String persona = new ILHPersona().getPersona();//Get persona
        List<ISearchService> classInstances = new List<ISearchService>();

        //Get containers by persona
        List<DIConsumerContainer__mdt> instanceContainer = ILHUtilities.getDIConsumerContainer(persona, 'ConsumerSearch');
        
        //Check if there's containers found and there's dependencies
        if (instanceContainer != null && !instanceContainer.isEmpty() && instanceContainer[0]?.Dependencies__c != null) {
            //Loop through each dependency in the consumer container
            for (String dep : instanceContainer[0].Dependencies__c.split(',')) {
                //Get the instance of the dependency from interface implementations
                InterfaceImplementations__mdt implementation = InterfaceImplementations__mdt.getInstance(dep);

                //Add a new instance of the implementations to the list
                classInstances.add((ISearchService)Type.forName(implementation.Implementation__c).newInstance());
            }
        }
        return classInstances;
    }
}