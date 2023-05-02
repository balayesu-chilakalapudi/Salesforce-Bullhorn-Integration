public class BullhornConnector {
       
    // Unique label for the first request
    public static String requestLabel1;
    // Unique label for the second request
    public static String requestLabel2;
    // Result of first callout
    public static String result1 {get;set;}
    // Result of second callout
    public static String result2 {get;set;}
    
    public static String access_token{get;set;}    
    public static String refresh_token{get;set;}
    
    //Fetched from URL
    public static String code ;
    
    public BullhornConnector()
    {   
        code = ApexPages.currentPage().getParameters().get('code') ;
        System.debug('code: '+code);
        //Get the access token once we have code
        if(code != '' && code != null)
        {
            AccessToken() ;
        }
    }
    
    public PageReference BullhornAuth()
    { 
        Bullhorn__c bh=Bullhorn__c.getValues('tokens');
        String access_token=bh.access_token__c;
        String refresh_token=bh.refresh_token__c;
        String ClientID=bh.ClientID__c;
        String ClientSecret=bh.ClientSecret__c;
        String APIUsername=bh.APIUsername__c;
        String APIPassword=bh.APIPassword__c;
        
        String RedirectURI='https://lightning-sandbox--lightning--c.cs72.visual.force.com/apex/BullhornPage';
        //Authenticating
        String aurl='https://auth.bullhornstaffing.com/oauth/authorize?client_id='+ClientID+'&response_type=code&username='+APIUsername+'&password='+APIPassword+'&action=Login&state=MyTest&redirect_uri='+RedirectURI;
        System.debug('aurl: '+aurl);
        PageReference pg = new PageReference(aurl);            
        return pg ;
    }
    
    public static void AccessToken() 
    {   
        Bullhorn__c bh=Bullhorn__c.getValues('tokens');
        String access_token=bh.access_token__c;
        String refresh_token=bh.refresh_token__c;
        String ClientID=bh.ClientID__c;
        String ClientSecret=bh.ClientSecret__c;
        
        System.debug(' >> AccessToken() >>');
        System.debug('code: '+code);
        System.debug('ClientId: '+ClientID);
        System.debug('ClientSecret: '+ClientSecret);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String RedirectURI='https://lightning-sandbox--lightning--c.cs72.visual.force.com/apex/BullhornPage';
        
        String tokenurl='https://auth.bullhornstaffing.com/oauth/token?grant_type=authorization_code&code='+code+'&client_id='+ClientID+'&client_secret='+ClientSecret+'&redirect_uri='+RedirectURI;
        // String params=
        System.debug('tokenurl: '+tokenurl);
        // System.debug('params:'+params);
        
        req.setEndpoint(tokenurl);
        req.setMethod('POST');        
        req.setTimeout(60*1000);
        // req.setBody(params);
        
        req.setHeader('x-myobapi-key', ClientID);
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-myobapi-version', 'v0');
        
        
        Blob headerValue = Blob.valueOf(ClientID + ':' + RedirectURI);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        //  req.setHeader('Authorization', authorizationHeader);
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        
        System.debug(' You can parse the response to get the authorization code ::: ' + resp);
         access_token='';
         refresh_token='';
        //parse the access token
        JSONParser parser = JSON.createParser(resp);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                // System.debug('fieldName: '+fieldName+'=> '+parser.getText());
                if(fieldName == 'access_token') {
                    access_token = parser.getText();
                } 
                if(fieldName == 'refresh_token') {
                    refresh_token = parser.getText();
                } 
            }
        }
       
    }
    
    //access token will expire after 10 mins
    // The refresh token has no expiration date/time, but it does expire when a new access token and refresh token are generated
    
    // access_token: 60:24e8adc4-1cf0-4669-b599-36538aee1a51
    // refresh_token: 60:358deab9-2c64-4d51-b956-2db98a3ce78b
    
    
    public static void getActiveAccessTokenWithRefreshToken() {
        Bullhorn__c bh=Bullhorn__c.getValues('tokens');
        String access_token=bh.access_token__c;
        String refresh_token=bh.refresh_token__c;
        String ClientID=bh.ClientID__c;
        String ClientSecret=bh.ClientSecret__c;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String tokenurl='https://auth.bullhornstaffing.com/oauth/token?grant_type=refresh_token&refresh_token='+refresh_token+'&client_id='+ClientID+'&client_secret='+ClientSecret;
        System.debug('tokenurl: '+tokenurl);
        
        req.setEndpoint(tokenurl);
        req.setMethod('POST');        
        req.setTimeout(60*1000);
        
        req.setHeader('x-myobapi-key', ClientID);
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-myobapi-version', 'v0');
        
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        
        System.debug(' You can parse the response to get the authorization code ::: ' + resp);  
        if(resp.contains('access_token') &&
           resp.contains('refresh_token')){           
               //parse the access token
               JSONParser parser = JSON.createParser(resp);
               while (parser.nextToken() != null) {
                   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                       String fieldName = parser.getText();
                       parser.nextToken();
                       // System.debug('fieldName: '+fieldName+'=> '+parser.getText());
                       if(fieldName == 'access_token') {
                           access_token = parser.getText();
                       } 
                       if(fieldName == 'refresh_token') {
                           refresh_token = parser.getText();
                       } 
                   }
               }
               
               bh.access_token__c=access_token;
               bh.refresh_token__c=refresh_token;
               update bh;
           }else{
               System.debug('invalid response');
               bh.access_token__c=null;
               bh.refresh_token__c=null;
               update bh;
           }
        
    }   
    
    
    public static void loginTotheRESTAPI(){
        Bullhorn__c bh=Bullhorn__c.getValues('tokens');
        String access_token=bh.access_token__c;
        String refresh_token=bh.refresh_token__c;
        String BhRestToken=bh.BhRestToken__c;
        String restUrl=bh.restUrl__c;
        String ClientID=bh.ClientID__c;
        
        if(access_token!=null &&
           refresh_token!=null){
               Http http = new Http();
               HttpRequest req = new HttpRequest();
               String tokenurl='https://rest.bullhornstaffing.com/rest-services/login?version=*&access_token='+access_token;
               System.debug('tokenurl: '+tokenurl);
               
               req.setEndpoint(tokenurl);
               req.setMethod('POST');        
               req.setTimeout(60*1000);
               
               req.setHeader('x-myobapi-key', ClientID);
               req.setHeader('Accept', 'application/json');
               req.setHeader('x-myobapi-version', 'v0'); 
               
               Http h = new Http();
               String resp;
               HttpResponse res = h.send(req);
               resp = res.getBody();
               
               System.debug(' You can parse the response to get the authorization code ::: ' + resp);  
               if(resp.contains('BhRestToken') &&
                  resp.contains('restUrl')){
                      //parse the access token
                      JSONParser parser = JSON.createParser(resp);
                      while (parser.nextToken() != null) {
                          if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                              String fieldName = parser.getText();
                              parser.nextToken();
                              // System.debug('fieldName: '+fieldName+'=> '+parser.getText());
                              if(fieldName == 'BhRestToken') {
                                  BhRestToken = parser.getText();
                              } 
                              if(fieldName == 'restUrl') {
                                  restUrl = parser.getText();
                              } 
                          }
                      }
                      //  System.debug('BhRestToken: '+BhRestToken);
                      //  System.debug('restUrl: '+restUrl);
                      
                      bh.BhRestToken__c=BhRestToken;
                      bh.restUrl__c=restUrl;
                      update bh;
                  }else{
                      System.debug('invalid response');
                      bh.BhRestToken__c=null;
                      bh.restUrl__c=null;
                      update bh;
                  }                  
           } 
    }
     
}