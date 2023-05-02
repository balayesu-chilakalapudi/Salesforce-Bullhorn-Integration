/*
update bullhorn contacts(clientcontacts) one by one for syncing BH contacts to salesforce contacts 
this is written due to future call collision between Bullhorn and MYOB
*/
global class BullhornContactSyncBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful, Schedulable {
    global void scheduleMe() { 
        String CRON_Label=System.Label.BullhornContactSyncBatch;       
        if(!Test.isRunningTest()){
            system.schedule('BullhornContactSyncBatch', CRON_Label, new BullhornContactSyncBatch());  
        }
    }
    global void execute(SchedulableContext sc){
        BullhornContactSyncBatch batch=new BullhornContactSyncBatch();
        if(!Test.isRunningTest()){
        	Id batchprocessid=Database.executeBatch(batch,1); 
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select Id from Bullhorn_clientcontact__c';       
        System.debug('query: '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Bullhorn_clientcontact__c> scope) {        
        System.enqueueJob(new QueueClass(scope));
    }   
    global void finish(Database.BatchableContext BC) {     
        System.debug('batch completed');
    }
    public class QueueClass implements Queueable {
    List<Bullhorn_clientcontact__c> records;
    public QueueClass(List<Bullhorn_clientcontact__c> records) {
        this.records = records;
    }
    public void execute(QueueableContext context) {
         update records;
        System.debug('Records updated successfully.');
    }
}
}