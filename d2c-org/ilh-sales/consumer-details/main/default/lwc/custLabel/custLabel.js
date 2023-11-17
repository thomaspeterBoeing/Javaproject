import { LightningElement, api,wire,track} from 'lwc';
import getAllRecords from '@salesforce/apex/ILHCustLabel.getAllRecords';
import { reduceErrors } from 'c/ldsUtils';//LWC Reduces one or more LDS errors into a string[] of error messages

export default class CustLabel extends LightningElement {

    mdtobject='API_Endpoint__mdt';

    @wire(getAllRecords, { mdtobj: "$mdtobject" })
    accounts;
  
}