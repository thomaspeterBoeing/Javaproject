/**********************************************************************************
 * Title:  ILHConversionEligibleQuoteFactory
 * Date:   Jan 2024
 * 
 * Description: Constructs instances of concrete classes that implement designated interfaces based off of the calculated persona.  
 * 
 *************************************************************************************/

public  class ILHConversionEligibleQuoteFactory {
    
    /***
    * Gets all concrete class instances that implement interfaces that are designated in the "Interface Implementations" custom metadata.
    * @return All instances of concrete class, each of which implements the interface designated in the "Interface Implementations" custom metadata.
    */
   public static List<IConversionEligible> getInstances() {
       return new ILHConversionEligibleQuoteFactory().constructInstances();
   }

   /***
    * Instantiates and returns all concrete class instances that implement interfaces that are designated in the "Interface Implementations" 
    * custom metadata based on the calculated persona.
    * @return All instances of concrete class, each of which implements the interface designated in the "Interface Implementations" custom metadata.
    */
   private List<IConversionEligible> constructInstances() {
    String persona = new ILHPersona().getPersona();//Get persona
       List<IConversionEligible> classInstances = new List<IConversionEligible>();
       //String persona = ILHPersona.getPersona('ILHProductQuoteFactory');
       //String persona = 'ILH_CSCEQuote';
       //String persona = 'ILHSalesSystemAdmin';

       //Get an instance of the persona from the consumer container
       //DIConsumerContainer__mdt instanceContainer = DIConsumerContainer__mdt.getInstance(persona);
       List<DIConsumerContainer__mdt> instanceContainer = ILHUtilities.getDIConsumerContainer(persona, 'ConversionEligibleQuote');
        
       system.debug('instanceContainer output ->' +instanceContainer);
       // ConversionEligibleQuote	
        //Check if there's containers found and there's dependencies
        if (instanceContainer != null && !instanceContainer.isEmpty() && instanceContainer[0]?.Dependencies__c != null) {
            //Loop through each dependency in the consumer container
            for (String dep : instanceContainer[0].Dependencies__c.split(',')) {
                //Get the instance of the dependency from interface implementations
                InterfaceImplementations__mdt implementation = InterfaceImplementations__mdt.getInstance(dep);

                //Add a new instance of the implementations to the list
                classInstances.add((IConversionEligible)Type.forName(implementation.Implementation__c).newInstance());
            }
        }
       return classInstances;
   }
}