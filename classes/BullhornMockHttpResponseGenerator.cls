@isTest
global class BullhornMockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
      
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"bar","refresh_token":"abc","BHRestToken":"234","restUrl":"https://auth.bullhorn.com/resff"}');
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
      
}