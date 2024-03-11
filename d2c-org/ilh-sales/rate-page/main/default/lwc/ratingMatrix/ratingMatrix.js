/**********************************************************************************
 * Title:  Rating Matrix LWC
 * Date:   Jan 2024
 * 
 * Description:  LWC is for displaying a matrix of coverages and product rates. 
 * 
 * Details:      This component creates a grid from rates and products that are passed
 *               to from the parent Rate Filter calling the buildTable method.  
 * 
 * 
 * Modifications:
 *************************************************************************************/

import { LightningElement, api } from 'lwc';
export default class RatingMatrix extends LightningElement {
    rateData = [];
    rateColumns = [];
    payload;

    @api buildTable(rates, products, frequency) {
        this.rateData = [...rates];
        this.rateColumns = [];
        let columns = [];
        const len = products?.length;

        if (products != null && products?.length > 0) {
            columns.push(
                { label: 'Coverage', fieldName: 'coverage', type: 'currency', cellAttributes: { alignment: 'left' } }
            );

            for (let index = 0; index < len; ++index) {
                columns.push({
                    label: products[index], type: 'cellselector',
                    typeAttributes: {
                        value: { fieldName: products[index] },
                        labelkey: frequency,
                        labeltype: "currency",
                        checkedvariant: "brand-outline",
                        uncheckedvariant: "base",
                        checkedicon: "action:approval",
                        uncheckedicon: "",
                        lockwhenselected: true,
                        cellallignment: "left"
                    }
                });
            }
            this.rateColumns = [...this.rateColumns, ...columns];
        }
    }

    handleRateSelection(event) {
        const value = { ...event.detail.value };
        let rates = this.rateData;
        const len = rates?.length;

        for (let i = 0; i < len; i++) {
            //Updating the rateDate with the checked indicator.  Required when 
            //filtering products so checks display correctly in the grid.
            if (rates[i].coverage == value.coverage) {
                rates[i][value.productlabel] = { ...value };

                this.rateData = rates;
                break;
            }
        }
    }
}