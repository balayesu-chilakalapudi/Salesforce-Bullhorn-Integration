global class BullhornLoginScheduler implements Database.AllowsCallouts,Database.Stateful, Schedulable {
	global void scheduleMe() {    
        String CRON_Label= System.Label.BullhornLoginScheduler;
        if(!Test.isRunningTest()){
        	system.schedule('BullhornLoginScheduler', CRON_Label, new BullhornLoginScheduler());  
        }
    }
    global void execute(SchedulableContext sc){
        getLogin();
    }
    @future(callout=true)
    global static void getLogin(){        
        BullhornConnector.loginTotheRESTAPI();
    }
}