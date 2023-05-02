@isTest
public class Bullhorn_TaskForOppSyncTest {
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
        Opportunity opp=new Opportunity();
        opp.StageName='New';
        opp.CloseDate=system.today()+28;
        opp.name='test';
        insert opp;
        
        List<Bullhorn_Task__c> btlist=new List<Bullhorn_Task__c>();
        Bullhorn_Task__c bt=new Bullhorn_Task__c();
        bt.subject__c='test';
        bt.Bullhorn_Id__c='1';
        bt.type__c='Email';
        bt.bullhorn_opportunity_id__c='2';
        bt.Bullhorn_Owner__c=u.FirstName+' '+u.LastName;
        btlist.add(bt);
        
        Bullhorn_Task__c bt2=new Bullhorn_Task__c();
        bt2.subject__c='test2';
        bt2.Bullhorn_Id__c='2';
        bt2.type__c='Email';
        bt2.bullhorn_opportunity_id__c='2';
        bt2.Bullhorn_Owner__c=u.FirstName+' '+u.LastName;
        btlist.add(bt2);
        insert btlist;
        }
    }
}