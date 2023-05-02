@isTest
public class Bullhorn_Account_BH2SFSyncTest {
  @isTest
    static void test1(){       
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='tstcx@testorg.com');
        u.UserRoleId=[select Id from userRole limit 1].Id;
        String accowner=system.label.Bullhorn_ClientCorporation_Owner_Name;
        if(accowner!=null &&
           accowner.contains(' ')){
       		u.firstname=accowner.substringBefore(' ');
        	u.LastName=accowner.substringAfter(' ');
        }
        insert u;
        System.runas(u){
        List<Bullhorn_ClientCorporation__c> lelist=new List<Bullhorn_ClientCorporation__c>();
        Bullhorn_ClientCorporation__c le=new Bullhorn_ClientCorporation__c();
        le.name='test';
        le.Address__c='test';
        le.status__c='New';
        le.Bullhorn_Owner__c=system.label.Bullhorn_ClientCorporation_Owner_Name;
        le.phone__c='8973456754';
        le.Bullhorn_ID__c='1';
        lelist.add(le);        
        Bullhorn_ClientCorporation__c le2=new Bullhorn_ClientCorporation__c();
        le2.name='abc';
        le2.address__c='2';
        le2.phone__c='5434567812';
        le2.status__c='New';
        le2.Bullhorn_Owner__c=system.label.Bullhorn_ClientCorporation_Owner_Name;
        le2.Bullhorn_ID__c='2';
        lelist.add(le2);
        insert lelist;
        update lelist;
        System.assertEquals(2, [select count() from Account]);
        }
    }
}