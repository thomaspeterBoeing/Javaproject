/***
Copyright: CUNA Mutual Group
Purpose: Lightning Web Component controller.
1.1 - Rick Baker   - 8/3/2023  - Created for new D2C Salesfore instance.
***/
import { LightningElement, api, track } from 'lwc';
import getMarketHistory from '@salesforce/apex/MarketingHistoryController.getMarketHistory';
import { reduceErrors } from 'c/ldsUtils';//LWC Reduces one or more LDS errors into a string[] of error messages

// Record field names
const constFNMailingDate = 'mailingDate';

// Sort directions
const constSortDirAsc = 'asc';
const constSortDirDesc = 'desc';

// Define columns
const columns = [
    { label: "Mailing Date",      fieldName: "mailingDate",      sortable: true,  type: "date-local", editable: false, hideDefaultActions: true, 
      typeAttributes: {day : "2-digit", month : "2-digit", year : "numeric"}
    },
    { label: "Offer Description", fieldName: "offerDescription", sortable: false, type: "text", editable: false, hideDefaultActions: true, initialWidth: 300},
    { label: "Campaign Product",  fieldName: "campaignProduct",  sortable: true,  type: "text", editable: false, hideDefaultActions: true },
    { label: "Channel Code",      fieldName: "channelCode",      sortable: false, type: "text", editable: false, hideDefaultActions: true },
    { label: "Source ID",         fieldName: "sourceId",         sortable: false, type: "text", editable: false, hideDefaultActions: true },
    { label: "Credit Union",      fieldName: "creditUnion",      sortable: true,  type: "text", editable: false, hideDefaultActions: true },
    { label: "Contract Number",   fieldName: "contractNumber",   sortable: true,  type: "text", editable: false, hideDefaultActions: true }
];

export default class MarketingHistory extends LightningElement {
    @track tableData = [];
    @track columns = columns;
    @track sortBy = constFNMailingDate;
    @track sortDirection = constSortDirDesc;
    @api recordId;

    errorMessage = undefined;
    showSpinner = false;
    showNoResultsMessage = false;
    personId = '';

    /**
     * Purpose: This method gets person id from the related Person Account person id, then passes the person id to pullMarketingHistory funtion
     * @param event : Event from person Id Provider component 
     */
    handlePersonIdLoaded(event) {
        this.personId = event?.detail?.Account?.PersonID__pc ? event?.detail?.Account?.PersonID__pc : event?.detail?.PersonID__pc;
        this.pullMarketingHistory(this.personId);
    }

    /***
     * Purpose: Pulls contact marketing history by personId and sorts the initial data by mailingDate in descending order.c/consumerDetails
     * @param personId -- The string representation of the contact's personId.
     */
    pullMarketingHistory(personId) {
        this.showSpinner   = true;
        this.sortDirection = constSortDirAsc;

        getMarketHistory({ kvpSearchCriteria: {personId: personId}})
        .then(response => {
            console.log(JSON.stringify(response, null, 4));
            this.tableData = response;
            this.showSpinner = false;
            this.showNoResultsMessage = this?.tableData?.length === 0 ? true : false;
            this.sortData();
        }).catch(error => {
            let errorMessage = reduceErrors(error);
            this.errorMessage = errorMessage;
            this.showSpinner = false;
        });
    }

    /***
     * Purpose: This event is sent from the datatable LWC when the user clicks on a column title that is configured to be sortable.
     * @param event : Event from table column
     */
    handleSortDataTable(event) {
        this.sortBy        = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;

        this.sortData();
    }

    /**
     * Purpose: This method sorts by the selected column in the data table
     * @return : Sort direction
     */
    sortData() {
        let parseData = JSON.parse(JSON.stringify(this.tableData));

        // Return the value stored in the field
        let keyValue = (sorter) => {
            return sorter[this.sortBy];
        };

        // cheking reverse direction
        let isReverse = this.sortDirection === 'asc' ? 1: -1;

        //sorting table data
        parseData.sort((thisElement, thatElement) => {
            thisElement = keyValue(thisElement) ? keyValue(thisElement) : '';
            thatElement = keyValue(thatElement) ? keyValue(thatElement) : '';
            // sorting values based on direction
            return isReverse * ((thisElement > thatElement) - (thatElement > thisElement));
        });
        this.tableData = parseData;
    }
    
    /**
     * Purpose: This function controls the height of the datatable based on the number of records in the table.
     * Once the table exceeds 5 records, the table will no longer grow in height and will display a vertical scrollbar.
     * @return : Style class to apply to wrapper styles
     */
    get wrapperStyles() {
        let style = "slds-p-horizontal_small slds-table_col-bordered slds-table_bordered";

        if (this.tableData.length == 0) {         // Set the maximum height for no records
            style += " height-2";
        }  else if (this.tableData.length == 1) { // Set the maximum height for 1 record
            style += " height-5"
        }  else if (this.tableData.length == 2) { // Set the maximum height for 2 records
            style += " height-7"
        }  else if (this.tableData.length == 3) { // Set the maximum height for 3 records
            style += " height-8"
        }  else if (this.tableData.length == 4) { // Set the maximum height for 4 records
            style += " height-10"
        }  else if (this.tableData.length >= 5) { // Set the maximum height for 5 or more records
            style += " height-12"
        } 
        return style  // Don't set any height (table will not be displayed)
    }
}