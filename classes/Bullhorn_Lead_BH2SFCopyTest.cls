@isTest
public class Bullhorn_Lead_BH2SFCopyTest {
  @isTest
    static void test1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='stan', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='tstcxstan@testorg.com');
        u.UserRoleId=[select Id from userRole limit 1].Id;
        u.CommunityNickname='stan';
        insert u;
        System.runas(u){
        Lead_Round_Robin__c lrr=new Lead_Round_Robin__c();
        lrr.name='Round Robin';
        lrr.NumberOfEmployees__c=6;
        lrr.Round_Robin_Id__c=1;
        insert lrr;
        List<Bullhorn_Lead__c> lelist=new List<Bullhorn_Lead__c>();
        Bullhorn_Lead__c le=new Bullhorn_Lead__c();
        le.firstname__c='abc';
        le.lastname__c='def';
        le.phone__c='9847374562';
        le.email__c='test2ab@test.com';
        le.CompanyName__c='abc com te';
        le.bullhorn_owner__c=u.firstname+' '+u.LastName;
        le.Bullhorn_ID__c='1';
        lelist.add(le);
        
/*Bullhorn_Lead__c le2=new Bullhorn_Lead__c();
        le2.firstname__c='gh';
        le2.Bullhorn_ID__c='2';
        le2.lastname__c='ijk';
        le2.phone__c='9847374562';        
        le2.email__c='testab@test.com';
        le2.CompanyName__c='abc com';
        le2.bullhorn_owner__c=u.firstname+' '+u.LastName;
        lelist.add(le2); */
        insert lelist;
        update lelist;  
       // System.assertEquals(2, [select count() from Lead]);
        }
    }
}