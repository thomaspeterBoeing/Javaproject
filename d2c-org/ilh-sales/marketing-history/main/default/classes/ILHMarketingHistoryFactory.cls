/***
Copyright: TruStage
Purpose: Constructs instances of concrete classes that implement designated interfaces based off of the calulated persona.
1.0 - Adam Perschke-Ely   - 11/2/2023  - Created for new D2C Salesfore instance.
***/
public class ILHMarketingHistoryFactory {

    /***
     * Gets all concrete class instances that implement interfaces that are designated in the "Interface Implementations" custom metadata.
     * @return All instances of concrete class, each of which implements the interface designated in the "Interface Implementations" custom metadata.
     */
    public static List<IMarketingHistoryService> getInstances() {
        return new ILHMarketingHistoryFactory().constructInstances();
    }

    /***
     * Instantiates and returns all concrete class instances that implement interfaces that are designated in the "Interface Implementations" 
     * custom metadata based on the calculated persona.
     * @return All instances of concrete class, each of which implements the interface designated in the "Interface Implementations" custom metadata.
     */
    private List<IMarketingHistoryService> constructInstances() {
        List<IMarketingHistoryService> classInstances = new List<IMarketingHistoryService>();
        String persona = ILHPersona.getPersona(this);

        //Get an instance of the persona from the consumer container
        DIConsumerContainer__mdt instanceContainer = DIConsumerContainer__mdt.getInstance(persona);

        //Loop through each dependency in the consumer container
        for (String dep : instanceContainer.Dependencies__c.split(',')) {
            //Get the instance of the dependency from interface implementations
            InterfaceImplementations__mdt implementation = InterfaceImplementations__mdt.getInstance(dep);

            //Add a new instance of the implementations to the list
            classInstances.add((IMarketingHistoryService)Type.forName(implementation.Implementation__c).newInstance());
        }
        return classInstances;
    }
}