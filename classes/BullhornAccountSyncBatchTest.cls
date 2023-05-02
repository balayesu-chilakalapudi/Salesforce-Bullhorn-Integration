@isTest
public class BullhornAccountSyncBatchTest {
	@isTest
    static void test1(){
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
        BullhornAccountSyncBatch batch=new BullhornAccountSyncBatch();
        batch.scheduleMe();
        batch.execute(null);
        Database.executeBatch(batch);
        System.assertEquals(2,[select count() from bullhorn_clientcorporation__c]);
    }
}