@RestResource(urlMapping='/apex/BullhornPage')
global class BullhornService {
    @HttpGet
    global static void doGet() {
        System.debug('>> BullhornService >>');
        String authcode=RestContext.request.params.get('code');
        Bullhornconnector.code=authcode;
        BullhornConnector.AccessToken();
    }
}