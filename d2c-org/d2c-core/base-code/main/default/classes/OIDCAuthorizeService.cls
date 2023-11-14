public with sharing class OIDCAuthorizeService {
    public final static string ENDPOINT_OIDC_AUTHORIZE = 'OIDCAuthorizeAPI';
    public static OIDCAuthorizeResponse getBearerToken() {
        API_Endpoint__mdt endPoint= Utilities.getEndPointConfig(ENDPOINT_OIDC_AUTHORIZE);
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        String strTokenType;
        Integer expiresIn;  
        // Form the request for callout to OIDC Webservice
        httpReq.setHeader('Content-Type', endPoint.ContentType__c);

        if((endpoint.Named_Credential__c != null) && (endpoint.Named_Credential__c != '')) {
            httpReq.setEndpoint('callout:'+endpoint.Named_Credential__c+endPoint.Service_Method__c);
        }
        else{
            httpReq.setEndpoint('callout:APIConnectOIDCNamedCredential'+endPoint.Service_Method__c);
        }
        httpReq.setTimeout(Integer.valueOf(endPoint.Timeout__c));
        httpReq.setMethod(endpoint.Method__c);
        //httpReq.setHeader('X-IBM-Client-Secret', endPoint.Client_Secret__c); 
        httpReq.setHeader('X-IBM-Client-Id', endPoint.Client_Id__c); 
        String username = '{!$Credential.UserName}';
        String password = '{!$Credential.Password}';
        httpReq.setBody('grant_type=password&scope=openid+profile+address+email&username='+username+'&password='+password);
        //System.debug('@@ Request Body:-'+httpReq.getBody());
        // Make the webservice call and store the response
        HttpResponse httpResp = new Http().send(httpReq);
        return new OIDCAuthorizeResponse(httpResp);
    }
    public class OIDCAuthorizeResponse{
       @AuraEnabled public String jwToken;
       @AuraEnabled public String tokenType;
       @AuraEnabled public Integer expiresIn;
        public OIDCAuthorizeResponse(HttpResponse response){
            // Parse the response to get the access token
            System.JSONParser parser = JSON.createParser(response.getBody());
            while (parser.nextToken() != null) {
                if(parser.getCurrentToken()== JSONToken.FIELD_NAME){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'access_token'){
                        this.JWToken = parser.getText();
                    } else if(fieldName == 'expires_in') {
                        this.expiresIn = parser.getIntegerValue(); 
                    } else if(fieldName == 'token_type') {
                        this.tokenType = parser.getText();  
                    }
                }
            }
        }
        
    }
}