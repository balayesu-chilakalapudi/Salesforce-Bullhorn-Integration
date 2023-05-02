/*
we need to build a scheduler
that will run and get all data from bullhorn 
and record it in a new object 
or perhaps 
we dont need new object
lets directly insert it in lead 
along with child objects 
*/
global class BullhornTokenScheduler implements Database.AllowsCallouts,Database.Stateful, Schedulable {
    global void scheduleMe() {        
        String CRON_Label= System.Label.BullhornTokenScheduler;
        if(!Test.isRunningTest()){
        	system.schedule('BullhornTokenScheduler', CRON_Label, new BullhornTokenScheduler());  
        }
    }
    global void execute(SchedulableContext sc){
     	getToken();   
    }
    @future(Callout=true)
    global static void getToken(){
        BullhornConnector.getActiveAccessTokenWithRefreshToken();
    }
}