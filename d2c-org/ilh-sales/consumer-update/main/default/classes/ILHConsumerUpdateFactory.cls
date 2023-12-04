/**
 * Copyright: TruStage
 * Purpose: Constructs instances of concrete classes that implement designated interfaces based off of the calulated persona.
 */
public class ILHConsumerUpdateFactory {

    /**
     * Purpose: Gets all concrete class instances that implement interfaces that are designated in the "Interface Implementations" custom metadata.
     * @return All instances of concrete class, each of which implements the interface designated in the "Interface Implementations" custom metadata.
     */
    public static List<IConsumerUpdateService> getInstances() {
        return new ILHConsumerUpdateFactory().constructInstances();
    }

    /**
     * Purpose: Instantiates and returns all concrete class instances that implement interfaces
     * that are designated in the "Interface Implementations" custom metadata based on the calculated persona.
     * @return All instances of concrete class, each of which implements the interface designated in the "Interface Implementations" custom metadata.
     */
    private List<IConsumerUpdateService> constructInstances() {
        String persona = ILHPersona.getPersona('ILHConsumerUpdateFactory');
        List<IConsumerUpdateService> classInstances = new List<IConsumerUpdateService>();

        //Get an instance of the persona from the consumer container
        DIConsumerContainer__mdt instanceContainer = DIConsumerContainer__mdt.getInstance(persona);

        //Loop through each dependency in the consumer container
        for (String dep : instanceContainer.Dependencies__c.split(',')) {
            //Get the instance of the dependency from interface implementations
            InterfaceImplementations__mdt implementation = InterfaceImplementations__mdt.getInstance(dep);

            //Add a new instance of the implementations to the list
            classInstances.add((IConsumerUpdateService)Type.forName(implementation.Implementation__c).newInstance());
        }
        return classInstances;
    }
}