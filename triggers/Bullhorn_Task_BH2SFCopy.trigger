/*
Copying emails, calls from bullhorn_task__c to lead childs
*/
trigger Bullhorn_Task_BH2SFCopy on Bullhorn_Task__c (after insert,after update) {
	//set for holding already copied record bullhorn id's
    //Set<String> bhidset=new Set<String>();
    List<Task> tasks2create=new List<Task>();
    Map<String,Id> bhleadmap=new Map<String,Id>();
    Set<String> bhleadidset=new Set<String>();
    for(Bullhorn_task__c bt:trigger.new){
        if(bt.bullhorn_lead_id__c!=null && bt.bullhorn_lead_id__c!=''){
            bhleadidset.add(bt.bullhorn_lead_id__c);
        }
    } 
    //prepare map for holding lead id
    for(Lead le:[select Id,bullhorn_Id__c from Lead where bullhorn_Id__c IN:bhleadidset]){
        bhleadmap.put(le.bullhorn_Id__c,le.Id);
    }
    
    //map for holding ownername id to map bullhorn owner to sf
    Map<String,Id> ownerNameIdMap=new Map<String,Id>();
    for(User usr:[select Id,firstname,lastname from User where isactive=true and userroleId!=null]){
        ownerNameIdMap.put(usr.firstname+' '+usr.lastname,usr.Id);
    }
    
    //place existing tasks in bhidset
   /* for(Task ts:[select bullhorn_Id__c 
                 from Task 
                 where bullhorn_Id__c!=null]){
                     if(ts.bullhorn_Id__c!='' ||ts.bullhorn_Id__c!=null)
                     bhidset.add(ts.bullhorn_Id__c);
                 }*/
    
    for(Bullhorn_Task__c bhts:trigger.new){
        if((trigger.isinsert || trigger.isupdate) //&& !bhidset.contains(bhts.bullhorn_Id__c)
          ){
              if(bhts.bullhorn_owner__c!=null &&
                 ownerNameIdMap.containsKey(bhts.bullhorn_owner__c)){
            tasks2create.add(new Task(bullhorn_Id__c=bhts.bullhorn_Id__c,
                                      subject=bhts.subject__c,
                                     whoId=bhleadmap.get(bhts.bullhorn_Lead_Id__c),
                                      Bullhorn_Type__c=bhts.type__c,
                                      ownerId=ownerNameIdMap.get(bhts.bullhorn_owner__c)
                                     )
                             );
              }
        }
    }
    if(tasks2create.size()>0){
        Database.upsert(tasks2create,Task.bullhorn_Id__c,false);
    }
}