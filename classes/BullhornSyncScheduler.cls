global class BullhornSyncScheduler implements Database.AllowsCallouts,Database.Stateful, Schedulable {
	global void scheduleMe() {    
        String CRON_Label= System.Label.BullhornSyncScheduler;
        if(!Test.isRunningTest()){
        	system.schedule('BullhornSyncScheduler', CRON_Label, new BullhornSyncScheduler());   
        }
    }
    
    global void execute(SchedulableContext sc){
        syncLeads();
        syncLeadTasks();
        syncupOpportunities();
        syncOpportunityTasks();        
        syncupAccounts();
        syncupContacts();
    }
    
    @future(callout=true)
    global static void syncLeads(){
        BullhornToSFDataloader.saveBHLeadsToSFLeads(); 
    }
    
    @future(callout=true)
    global static void syncLeadTasks(){
        BullhornToSFDataloader.getLeadTasks(); 
    }
    
    // 30 July 2019, James Franklin, opportunity sync        
    @future(callout=true)
    global static void syncupOpportunities(){
        BullhornToSFOpportunitySync.syncOpportunities();
    }
    
    @future(callout=true)
    global static void syncOpportunityTasks(){
        BullhornToSFOpportunitySync.getOpportunityTasks();
    }
    
    @future(callout=true)
    global static void syncupAccounts(){
        BullhornToSFAccountSync.syncAccounts();
    }
    
    @future(callout=true)
    global static void syncupContacts(){
        BullhornToSFContactSync.syncContacts();
    }
}