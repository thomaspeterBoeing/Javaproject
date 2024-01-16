
/**********************************************************************************
 * Title:  Custom Data Table for ILH Sales LWCs
 * Date:   Dec 2023
 * 
 * Description:  Custom Data Table used when custom data types are required.
 * 
 * Details:      Custom Types
 *                  - cellselect  - Allows for individual cells to be selected in a table.
 *                                  LWC = dataTypeCellSelect
 * 
 * Modifications:
 *************************************************************************************/
import LightningDatatable from 'lightning/datatable';
import DataTypeTableCellSelect from './tablecellselector-template.html';

export default class ilhSalesCustomDataTypes extends LightningDatatable {
 
    static customTypes = {

        cellselector: {
            template: DataTypeTableCellSelect,         
            typeAttributes: ['value','labelkey','labeltype','checkedvariant','uncheckedvariant','checkedicon','uncheckedicon','lockwhenselected', 'cellallignment']            
        }     

    }
}