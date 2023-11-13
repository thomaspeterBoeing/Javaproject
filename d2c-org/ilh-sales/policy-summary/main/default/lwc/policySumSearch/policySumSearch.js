import { LightningElement, api, track } from 'lwc';
import searchPolicy from '@salesforce/apex/PolicySummaryController.search';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex  } from '@salesforce/apex';

export default class policySumSearch extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track policyData = [];
    @track isLoading = true;
    personId ='';
    columns = [
      {
        label: 'Policy Number',
        fieldName: 'ProductNumber',
        sortable: true,
        type: 'url | text',
        typeAttributes: {
          label: { fieldName: 'hyperLinkText' },
          target: '_blank',
          typeCondition: (item) => {
                return item.SourceSystemId === 'AD&D' || item.SourceSystemId === 'LifePro';
            }
        },
      },
      { label: 'Product', fieldName: 'SourceSystemProductKey',sortable: true, hideDefaultActions: true },
      //{ label: 'Source System Id', fieldName: 'SourceSystemId' },
      { label: 'Product Relationship', fieldName: 'ProductRelationshipDescription',sortable: true, hideDefaultActions: true },
      { label: 'Status', fieldName: 'Status',sortable: true },
      
    ];


    // Event handler to handle the personidloaded event from personIdProvider
    handlePersonIdLoaded(event) {
      if (event.detail && event.detail.Account && event.detail.Account.PersonID__pc) {
        this.personId = event.detail.Account.PersonID__pc;
        console.log('Person Id ->' +this.personId);
        // use this.personId to fetch policy data
        this.fetchPolicyData(this.personId);
      } else {
          console.log('Person ID is undefined or not available.');
        this.isLoading = false;
        
      }
    }
    

   
  fetchPolicyData(personId) {
    searchPolicy({ SearchCriteria: personId })
      .then(result => {
        console.log('inside fetchPolicyData');
        this.policyData = result.map(item => {
          let typeAttributes = {};
          const isHyperlink = (item) => {
            return item.SourceSystemId === 'LIFEPRO' || item.SourceSystemId === 'AD&D';
            };
            if (isHyperlink(item)) {
            typeAttributes = { label: { fieldName: 'hyperLinkText' }, target: '_blank' };
            }
            
                return {
                  ...item,
                  hyperLinkText: item.ProductNumber.replace('https://', ''),
                  typeAttributes: typeAttributes,
                  typeCondition: isHyperlink
                };
              });
                console.log('returned from service' +JSON.stringify(this.policyData));
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                let errorMessage = reduceErrors(error);	
                console.error("error", errorMessage);	
                this.setErrorMessage('Error occured while calling CPS for Policy search');			
                this.isSearching = false;
            });
    }

      get noPoliciesAvailable() {
        return !this.isLoading && (!this.policyData || this.policyData.length === 0);
    }

    setErrorMessage(strErrorMessage) {
      this.errorMessage = strErrorMessage;
    }

    handleSorting(event) {
      console.log('inside handlesorting')
      this.sortBy        = event.detail.fieldName;
      this.sortDirection = event.detail.sortDirection;

      this.sortData();

      return refreshApex (this.policyData);
  }

  /**
   * This method sorts by the selected column in the data table
    */
    sortData() {
        let parseData = JSON.parse(JSON.stringify(this.policyData));

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
        this.policyData = parseData;
  }


}

