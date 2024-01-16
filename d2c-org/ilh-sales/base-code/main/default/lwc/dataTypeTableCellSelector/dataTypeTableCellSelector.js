/**********************************************************************************
 * Title:  Data Type for custom data tables.  Table Cell Select
 * Date:   Dec 2024
 * 
 * Description:  Data Type that will allow for a cell in a table to be selected.  
 *               The value of the cell is then passed back to the calling component.
 *               The individual cell is selectable by using a button in each cell to 
 *               display the value.
 * 
 * Details:      Type Attributes included
 *                  - value     - Contains the values you want to retrieve.
 *                                 This must be a json object.  A field for indicating if the cell is selected will be added to this
 *                                 object and will be returned. This is required when a table is rerendered so cells 
 *                                 checked display correctly in the correct columns.
 *                  - labelkey   - The key for the json value which contains the label which will appear in the table cell.
 *                  - checkedvariant - variant setting in the button indicating an item has been selected.
 *                  - uncheckedvariant - variant setting in the button that indicates the item has not been selected. 
 *                  - checkedicon - icon that will display when item is selected
 *                  - uncheckedicon - icon that will display if not selected   
 *                  - lockedwhenselected - boolean  when true the selected cell can not be unselected.
 *                 
 *              Values returned
 *                  - value that was passed in.
 * 
 * 
 *              
 * 
 * Modifications:
 *************************************************************************************/
import { LightningElement, api, track } from 'lwc';

export default class DataTypeTableCellSelector extends LightningElement {
    //Type Attributes
    @api value;
    @api labelkey;
    @api labeltype;
    @api checkedvariant;
    @api checkedicon;
    @api uncheckedvariant;
    @api uncheckedicon;
    @api lockwhenselected;
    @api cellallignment;
    
    // Toggle for selected and unselected.
    selected = false; 

  connectedCallback(){
   
    if(this.value){
      //Set all records to not checked.
      if(this?.value?.checked){//UPDATED
      //do nothing if this value is found and set to true.  
      }else{
        const checked = {"checked": false};  
        this.value = {...this.value,...checked};
      }
    }

  }  

   renderedCallback(){
    
    let button = this.template.querySelector('lightning-button');
    if(this?.value?.checked){//UPDATED
      
      button.iconName = this.checkedicon;
      button.variant = this.checkedvariant;
    } else  {
      button.iconName = this.uncheckedicon;
      button.variant = this.uncheckedvariant;
    }
  }

  get label(){
    let labelValue; 
    let returnValue = "";
   
    if (this.value){
      
      labelValue = this.value[this.labelkey];  //TODO  Handle if value can not be found.
      //console.log('Label Value in Cell Selector ' + labelValue);
      
      //Format label for the Label Type that was indicated.
      //**Currency is only value currently required.
      if (this.labeltype.toLowerCase() === 'currency'){
        returnValue = "$" + Number(labelValue).toFixed(2);
      }else{
        returnValue = labelValue;
      }
  
    }else{
      returnValue = "--";
    }
    return returnValue;
   }
   
  get allignment(){
    let style;
    switch(this.cellallignment.toLowerCase()){
      case "right":
          style = "slds-float_right";
          break;
      case "left":
          style = "slds-float_left";
          break;
      case "center":
        style = "slds-align_absolute-center";
          break;    
      default:
          style = "slds-float_left";          
    }
    return style;
  }

  onClick(event) {
       //To change values in object it must be cloned.
       let _value = {...this.value};
       this.selected = _value.checked;
  
       //toggle on click.  If lockwhenselected is set then
       //do not toggle after cell is selected.
       if(this.label = '--'){
        //do nothing.  
       }else{
        if (this.lockwhenselected){
            this.selected = true; 

          } else {
            this.selected = !this.selected;
        } 
          
          if (this.selected){                                       
            event.target.variant = this.checkedvariant; 
            event.target.iconName = this.checkedicon;
        
          }else {
            event.target.variant = this.uncheckedvariant;  
            event.target.iconName = this.uncheckedicon;    
            
          }
      }
       
        _value.checked = this.selected;
        //Assign from clone.  
        this.value = {..._value};

        this.dispatchEvent(new CustomEvent('cellselect', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
               value: this.value
            }
        }));
}}
