/*
update bullhorn accounts(clientcorporation) one by one for syncing BH accounts to salesforce accounts 
this is written due to future call collision between Bullhorn and MYOB
*/
global class BullhornAccountSyncBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful, Schedulable {
    global void scheduleMe() { 
        String CRON_Label=System.Label.BullhornAccountSyncBatch;       
        if(!Test.isRunningTest()){
            system.schedule('BullhornAccountSyncBatch', CRON_Label, new BullhornAccountSyncBatch());  
        }
    }
    global void execute(SchedulableContext sc){
        BullhornAccountSyncBatch batch=new BullhornAccountSyncBatch();
        if(!Test.isRunningTest()){
            Id batchprocessid=Database.executeBatch(batch,1); 
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select Id from Bullhorn_clientcorporation__c';       
        System.debug('query: '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Bullhorn_clientcorporation__c> scope) {
        System.enqueueJob(new QueueClass(scope));
    }   
    global void finish(Database.BatchableContext BC) {     
        System.debug('batch completed');
    }
    public class QueueClass implements Queueable {
        List<Bullhorn_clientcorporation__c> records;
        public QueueClass(List<Bullhorn_clientcorporation__c> records) {
            this.records = records;
        }
        public void execute(QueueableContext context) {
            update records;
            System.debug('Records updated successfully.');
        }
    }
}