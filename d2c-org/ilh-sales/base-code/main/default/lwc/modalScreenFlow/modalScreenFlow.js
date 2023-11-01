/************************************************************************************** 
Reusable Modal LWC component for opening screen flows in modal window. 
LWC component that calls this should pass the following variables

            size: (large, medium, small or full)            
            modalTitle: This will be displayed on top of the modal window,
            flowAPIName: api name of the flow,     
            flowInputVariables: list of input variables in flow.  
            
         example: 
            
            this.outputvar = await ModalLWC.open({
                size: 'large',            
                modalTitle: 'Test Screen Flow LWC',
                flowAPIName: 'Test_Screen_Flow',     
                flowInputVariables: [
                    {
                        name: "InputA",
                        type: "String",
                        value: "ValueA",
                    },
                    {
                        name: "InputB",
                        type: "String",
                        value: "ValueB",
                    },
                ]
            });  
            const outputVariables = this.outputvar;
                for(let i = 0; i < outputVariables.length; i++) {
                    const outputVar = outputVariables[i];
                    if(outputVar.name == 'OutputC'){
                        this.result = outputVar.value;                    
                    }
                }
        }

    ****************************************************************************************/

import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ModalScreenFlow extends LightningModal{
    @api modalTitle;
    @api flowAPIName;
    @api flowInputVariables;    
   
    // When Screen Flow is finished modal window will close
    // Output variables will be passed to calling LWC
	handleFlowStatusChange(event){
        
		if (event.detail.status === "FINISHED"){
            
            this.close(event.detail.outputVariables);
        }
    }    
           
}