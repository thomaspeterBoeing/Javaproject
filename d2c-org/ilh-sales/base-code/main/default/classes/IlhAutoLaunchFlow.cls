/***********************************************************************************
 * Created: Sept 2023
 * 
 * Description:
 * This class is called from LWC and is used to launch an autolaunced flow. 
 * 
 * Input Parameter:     String  Flow API Name
 *                      String  Flow Variables  - JSON serialized string that contains 
 *                                                  flow input variables.
 *                      String  Output Variable Name  - Only one variable can be returned 
 * 
 * Output Parameter: String value.   
 *   
*****************************************************************************************/
public class IlhAutoLaunchFlow {
        
    //Structure for deserializing the flow input variable string.
    public class FlowInputVariable {
        public String name;
        public String type;
        public String value; 
    }

    @AuraEnabled    
    public static String startFlow(String flowAPIName,String flowVar,String outputVar ){
        String returnValue = '';    
    
        Map<String, object> flowInputParams = new Map<String, object>();
        system.debug('Flow Input Var: ' + flowVar);

        try{
            //Deserialized using FlowInputVariable class
            List <FlowInputVariable> fvs = (List<FlowInputVariable>)JSON.deserializeStrict(FlowVar, List<FlowInputVariable>.class);

            //The variable that is received from LWC contains Name, Type, and Value of each input flow variable.
            //For autolaunched flow input variable it requires name and value only.  
            for(FlowInputVariable fv : fvs) {
                flowInputParams.put(fv.name,fv.value);
            }
       
            Flow.Interview autoLaunchflow = Flow.Interview.createInterview(flowAPIName, flowInputParams);
            autoLaunchflow.start();

            //Output variable which is the record id that was created or updated from flow is returned to LWC. 
            if (outputVar != Null && outputVar != '' ){
                returnValue = String.valueOf(autoLaunchflow.getVariableValue(outputVar));
            }
                
        } catch(Exception e) {
            system.debug('Error ' + e);
            String errorMsg = e.getMessage();
            new ErrorLogger(e, errorMsg, 'IlhAutoLaunchFlow.cls', null, 'Create Auto Launch Flow', String.valueOf(flowInputParams), null, null);
        }
        return returnValue;
    }
}