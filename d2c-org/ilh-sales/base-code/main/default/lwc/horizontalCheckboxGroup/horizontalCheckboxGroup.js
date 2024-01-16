/*
This component is used to create a horizontal checkbox group.  

 <c-horizontal-checkbox-group  
        name="checkboxGroup"
        label="Checkbox Group"
        options={options}
        value={value}
        onchange={handleChange}>
  </c-horizontal-checkbox-group>    

*/
import { LightningElement, api } from 'lwc';

export default class HorizontalCheckboxGroup extends LightningElement {
    _selectedValues = [];
    _options = [];
    @api name;
    @api label;
   
    @api set options(value) {
      //value must be populated otherwise iterator failure in for each loop.
      if(value){    
        this._options = [...value];               
        this.trackSelected();
      }
    }
    get options() {
      return [...this._options];
    }

    @api set value(value) { 
      this._selectedValues = [...value];
      this.trackSelected();
    }

    get value() {
      return [...this._selectedValues];
    }
    
    //Creates new array including value to track if checkbox has been selected.
    //Each time a checkbox is selected this method is called.
    trackSelected() {   
     this._options = this._options.map(element => ({...element, checked: this._selectedValues.includes(element.value)}));  
                                
    }

    selectHandler() {
        
      this._selectedValues = [...this.template.querySelectorAll('input')]
        .filter(element => element.checked)
        .map(element => element.value);     
      this.trackSelected();

      this.dispatchEvent(
        new CustomEvent('change', { detail: {selected: [...this._selectedValues]}})
      );
    }
  }