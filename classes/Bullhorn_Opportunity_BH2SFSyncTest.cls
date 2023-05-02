@isTest
public class Bullhorn_Opportunity_BH2SFSyncTest {
  @isTest
    static void test1(){       
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='tstcx@testorg.com');
        u.UserRoleId=[select Id from userRole limit 1].Id;
        insert u;
        System.runas(u){
        account acc=new account();
        acc.bullhorn_Id__c='1';
        acc.name='test345';
        insert acc;      
        List<Bullhorn_Opportunity__c> lelist=new List<Bullhorn_Opportunity__c>();
        Bullhorn_Opportunity__c le=new Bullhorn_Opportunity__c();
        le.name='test';
        le.title__c='test';
        le.Address__c='test';
        le.status__c='New';
        le.estimatedEndDate__c='1540291894000';
        le.effectiveDate__c='1540291894000';
        le.Bullhorn_Owner__c=u.FirstName+' '+u.LastName;
        le.clientCorporation__c='1';
        le.Bullhorn_ID__c='1';
        lelist.add(le);
        
        Bullhorn_Opportunity__c le2=new Bullhorn_Opportunity__c();
        le2.name='abc';
        le2.address__c='2';        
        le2.status__c='New';
        le2.estimatedEndDate__c='1540291894000';
        le2.effectiveDate__c='1540291894000';
        le2.Bullhorn_Owner__c=u.FirstName+' '+u.LastName;
        le2.Bullhorn_ID__c='2';
        le2.clientCorporation__c='1';
        lelist.add(le2);
        insert lelist;
        update lelist;
        System.assertEquals(2, [select count() from Opportunity]);
        }
    }
}