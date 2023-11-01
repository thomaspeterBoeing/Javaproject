
/**********************************************************************************
 * Title:  Policy Format Modal
 * Date:   Sept 2023
 * 
 * Description:  This LWC will show all the Policy Formats for Consumer Search.   
 * 
 * Details:      Wiki page to display all the available formats for Policy Numbers 
 *          
 * Modifications:
 *************************************************************************************/

import LightningModal from 'lightning/modal';

export default class PolicyFormat extends LightningModal {
    activeSections = ['ADD', 'Life70','LifeProf2f','LifeProDirect'];
    activeSectionsMessage = '';

    handleClose() {
        this.close('okay');
    }
}