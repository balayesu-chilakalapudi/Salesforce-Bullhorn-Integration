@isTest
public class BullhornToSFAccountSyncTest {
    @isTest
    static void test1(){
         Bullhorn__c bh=new Bullhorn__c();
        bh.name='tokens';
        bh.ClientID__c='test';
        bh.ClientSecret__c='test';
        bh.APIUsername__c='test';
        bh.APIPassword__c='test';
        bh.BhRestToken__c='test';
        bh.restUrl__c='test';
        insert bh;    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BHDataMockHttpResponseGenerator());
        BullhornToSFAccountSync.syncAccounts();
        Test.stopTest();
    }
}