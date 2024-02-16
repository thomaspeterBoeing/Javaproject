/**
 * @description       : 
 * @last modified on  : 02-16-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ILHConsumerUpdateFactory {

    /**
     * Purpose: Gets all concrete class instances that implement interfaces that are
     * designated in the "Interface Implementations" custom metadata.
     * @return All instances of concrete class, each of which implements the
     *         interface designated in the "Interface Implementations" custom metadata.
     */
    public static List<IConsumerUpdateService> getInstances(Id commitUser) {
        return new ILHConsumerUpdateFactory().constructInstances(commitUser);
    }

    /**
     * Purpose: Instantiates and returns all concrete class instances that implement interfaces
     * that are designated in the "Interface Implementations" custom metadata based on the
     * calculated persona.
     * @return All instances of concrete class, each of which implements the
     *         interface designated in the "Interface Implementations" custom metadata.
     */
    private List<IConsumerUpdateService> constructInstances(Id commitUser) {
        // String persona = ILHPersona.getPersona('ILHConsumerUpdateFactory');
        String persona = new ILHPersona(commitUser).getPersona(); // Get persona
        List<IConsumerUpdateService> classInstances = new List<IConsumerUpdateService>();

        // Get containers by persona
        List<DIConsumerContainer__mdt> instanceContainer = ILHUtilities.getDIConsumerContainer(persona, 'ConsumerUpdate');

        // Check if there's containers found and there's dependencies
        if (instanceContainer != null && !instanceContainer.isEmpty() && instanceContainer[0]?.Dependencies__c != null) {
            // Loop through each dependency in the consumer container
            for (String dep : instanceContainer[0].Dependencies__c.split(',')) {
                // Get the instance of the dependency from interface implementations
                InterfaceImplementations__mdt implementation = InterfaceImplementations__mdt.getInstance(dep);

                // Add a new instance of the implementations to the list
                classInstances.add((IConsumerUpdateService) Type.forName(implementation.Implementation__c).newInstance());
            }
        }
        return classInstances;
    }
}