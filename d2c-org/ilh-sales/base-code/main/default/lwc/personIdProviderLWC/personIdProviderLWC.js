/**********************************************************************************
 * Title:  personIdProvider LWC
 * Date:   Nov 2023
 * 
 * Description:  This LWC's purpose is to provide personId. This LWC does not need to be placed in record page
 *               and does not have a layout  
 *               
 * Details:      Refer this LWC in other LWC's html where personID needs to be retrieved.
 *               For eg: <c-person-id-provider record-id={recordId} object-api-name={objectApiName}
 *               onpersonidloaded={handlePersonIdLoaded}></c-person-id-provider>
 *               Use handle events to get the PersonId.
 *               
 *          
 * Modifications:
 *************************************************************************************/
import { LightningElement, api } from 'lwc';
import getPersonId from '@salesforce/apex/PersonIDProviderController.getPersonId';
import { reduceErrors } from 'c/ldsUtils';

export default class personIdProviderLWC extends LightningElement {
    @api recordId;
    @api objectApiName;
    personId;

    connectedCallback() {
        this.fetchPersonId(this.recordId);
        
        console.log('record from personIdprovider ->' +this.recordId);
        
    }

    fetchPersonId(recordId) {
        getPersonId({ recordId })
            .then(result => {
                this.personId = result;
                this.dispatchEvent(new CustomEvent('personidloaded', { detail: result }));
            })
            .catch(error => {
                let errorMessage = reduceErrors(error);	
                console.error("error", errorMessage);	
                this.setErrorMessage('Error occured while fetching Person Id');			
                this.isSearching = false;
            });
    }

    setErrorMessage(strErrorMessage) {
        this.errorMessage = strErrorMessage;
      }

}