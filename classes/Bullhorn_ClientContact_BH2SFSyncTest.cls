@isTest
public class Bullhorn_ClientContact_BH2SFSyncTest {
  @isTest
    static void test1(){       
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing211', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='tstcx11@testorg.com');
        u.UserRoleId=[select Id from userRole limit 1].Id;
        insert u;    
        
        System.runas(u){
        account acc=new account();
        acc.bullhorn_Id__c='1';
        acc.name='test345';
        insert acc;            
        List<Bullhorn_ClientContact__c> lelist=new List<Bullhorn_ClientContact__c>();
        Bullhorn_ClientContact__c le=new Bullhorn_ClientContact__c();
        le.name='test';
        le.Address__c='test';
        le.status__c='New';
        le.Bullhorn_Owner__c=u.FirstName+' '+u.LastName;
        le.firstname__c='test1';
        le.lastName__c='test1';
        le.email__c='test@abc.com';
        le.phone__c='8973456754';
        le.Bullhorn_ID__c='1';
        le.clientCorporation__c='1';
        lelist.add(le);        
        Bullhorn_ClientContact__c le2=new Bullhorn_ClientContact__c();
        le2.name='abc';
        le2.address__c='2';
        le2.firstname__c='test2';
        le2.lastName__c='test2';
        le2.email__c='test2@abc.com';
        le2.phone__c='5434567812';
        le2.status__c='New';
        le2.Bullhorn_Owner__c=u.FirstName+' '+u.LastName;
        le2.Bullhorn_ID__c='2';
        le2.clientCorporation__c='1';
        lelist.add(le2);
        insert lelist;
        update lelist; 
        System.assertEquals(2, [select count() from contact]);
        }
    }
}