@isTest
public class BullhornConnectorTest {
	@isTest
    static void test1(){ 
        Bullhorn__c bh=new Bullhorn__c();
        bh.name='tokens';
        bh.ClientID__c='test';
        bh.ClientSecret__c='test';
        bh.APIUsername__c='test';
        bh.APIPassword__c='test';
        insert bh;        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BullhornMockHttpResponseGenerator());
        	new BullhornConnector().BullhornAuth();
        	BullhornConnector.AccessToken();
        	BullhornConnector.getActiveAccessTokenWithRefreshToken();  
        Test.stopTest();
    }
    @isTest
    static void test2(){        
        Bullhorn__c bh=new Bullhorn__c();
        bh.name='tokens';
        bh.ClientID__c='test';
        bh.ClientSecret__c='test';
        bh.APIUsername__c='test';
        bh.APIPassword__c='test';
        bh.refresh_token__c='test';
        bh.access_token__c='test';
        insert bh;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BullhornMockHttpResponseGenerator());
        	BullhornConnector.loginTotheRESTAPI();
        Test.stopTest();
    }
}