@isTest
public class Bullhorn_Task_BH2SFCopyTest {
	@isTest
    static void test(){
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='tstcx@testorg.com');
        u.UserRoleId=[select Id from userRole limit 1].Id;
        insert u;
        System.runas(u){
        Lead_Round_Robin__c lrr=new Lead_Round_Robin__c();
        lrr.name='Round Robin';
        lrr.NumberOfEmployees__c=6;
        lrr.Round_Robin_Id__c=1;
        insert lrr;
           
        Lead le=new Lead();
        le.Company='test company';
        le.FirstName='test';
        le.lastname='abc';
        le.phone='9484844488';
        le.Email='test@test.com';
        le.bullhorn_Id__c='2';
        le.Created_By_Integration__c=true;
        insert le;
        
        List<Bullhorn_Task__c> btlist=new List<Bullhorn_Task__c>();
        Bullhorn_Task__c bt=new Bullhorn_Task__c();
        bt.subject__c='test';
        bt.Bullhorn_Id__c='1';
        bt.type__c='Email';
        bt.bullhorn_lead_id__c='2';
        bt.Bullhorn_Owner__c=u.FirstName+' '+u.LastName;
        btlist.add(bt);
        
        Bullhorn_Task__c bt2=new Bullhorn_Task__c();
        bt2.subject__c='test2';
        bt2.Bullhorn_Id__c='2';
        bt2.type__c='Email';
        bt2.bullhorn_lead_id__c='2';
        bt2.Bullhorn_Owner__c=u.FirstName+' '+u.LastName;
        btlist.add(bt2);
        insert btlist;
        System.assertEquals(2,[select count() from bullhorn_task__c]);
        }
    }
}