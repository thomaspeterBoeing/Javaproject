public without sharing class Utilities {
    public static API_Endpoint__mdt getEndpointConfig(String serviceName) {
        // Get environment Organization id
        String orgId = UserInfo.getOrganizationId(); 
        
        // Get appropriate environment name from custom metadata table
        APIEnvironmentSFOrgID__mdt envt = new APIEnvironmentSFOrgID__mdt();
        API_Endpoint__mdt output = new API_Endpoint__mdt();
        
        envt = [Select Environment__c From APIEnvironmentSFOrgID__mdt Where OrgId__c =: orgId Limit 1];
        output = [Select Id, Client_Id__c, Client_Secret__c, Service_Method__c, Timeout__c, Method__c, Mock_Response_Static_Resource__c, ContentType__c, Type__c, SOAP_Method__c, isOIDCSecured__c, Named_Credential__c from  API_Endpoint__mdt where MasterLabel =:envt.Environment__c AND ServiceName__c =:serviceName and is_Active__c=true limit 1];
    
        return output;
    }

    public static String getBearerToken() {
        String strJWToken = (String)Cache.Org.get('local.sales.JWAToken');
        //System.debug('## Check Token Value:-'+strJWToken);       
        if(String.isNotEmpty(strJWToken)) {
            System.debug('## No need to fetch the token.'); 
            return strJWToken;
        }
        else {     
           
            strJWToken = OIDCAuthorizeService.getBearerToken().jwToken;
             
            if(Test.isRunningTest()) {
                strJWToken = '123456789';
            }
            // System.debug('@@ Partitiona Name:- '+Cache.Org.getName() +' - '+ Cache.Org.getPartition(Cache.Org.getName()));
            Cache.Org.put('local.sales.JWAToken', strJWToken, 1500, Cache.Visibility.ALL, false);
            // System.debug('@@ Cache: - '+Cache.Org.get('local.sales.JWAToken'));       
            return strJWToken;
        } 
    }

    public static String formatPhone(String strPhone) {
        string nonDigits = '[^0-9]';
        string phoneDigits = '';

        // remove all non numeric
        if(strPhone != null && strPhone != ''){
            phoneDigits = strPhone.replaceAll(nonDigits,'');

            // 10 digit: reformat
            if (phoneDigits != null && phoneDigits.length() == 10){
                return '(' + phoneDigits.substring(0,3) + ') ' + phoneDigits.substring(3,6) + '-' + phoneDigits.substring(6,10);
            }
            // 11 digit: if starts with 1, format as 10 digit
            if (phoneDigits != null && phoneDigits.length() == 11) {
                if (phoneDigits.substring(0,1) == '1') {
                    return  '(' + phoneDigits.substring(1,4) + ') ' + phoneDigits.substring(4,7) + '-' + phoneDigits.substring(7,11);
                }
            }
        }

        // if it isn't a 10 or 11 digit number, return the original because
        // it may contain an extension or special information
        return(strPhone);
    }

    /**
     * This method removes all formatting from the phone number that is passed into the method
     */
    public static String removeAllPhoneFormatting(String phoneNumber) {
        return phoneNumber.replace('-','').replace('(','').replace(')','').replace(' ','');
    }

    public static String DateFormatSwitchMMDDYYYTtoYYYYMMDD(String strDate) {   
        String strDateToReturn = null;
            
        if(strDate != null) {
            if(strDate.countMatches('/')==2) {
                String[] strDateSplit = strDate.split('/');
                
                if((strDateSplit[0].length() > 0) && (strDateSplit[0].length() <= 2) && (strDateSplit[1].length() > 0) && (strDateSplit[1].length() <= 2) && (strDateSplit[2].length() == 4)) {
                    strDateToReturn = '';
                    
                    // Year
                    strDateToReturn +=strDateSplit[2] + '-';
                    
                    // Month
                    if(strDateSplit[0].length()==1) {
                        strDateToReturn += '0';
                    }
                    strDateToReturn +=strDateSplit[0] + '-';
                    
                    // Day
                    if(strDateSplit[1].length()==1) {
                        strDateToReturn += '0';
                    }
                    strDateToReturn +=strDateSplit[1];
                }
            } else if(strDate.countMatches('-') == 2) {
                strDateToReturn = strDate;
            }
        }
        return strDateToReturn;     
    }
}