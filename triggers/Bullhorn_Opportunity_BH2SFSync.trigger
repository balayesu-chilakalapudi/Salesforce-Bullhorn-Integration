/*
Solution - you need to call bullhorn api and get opportunities from there and store them in a new object called bullhorn_opportunities.
make sure if you call same api again it checks for foreign key and upsert the data.Then we will have a logic to create leads afterwards.
*/

trigger Bullhorn_Opportunity_BH2SFSync on Bullhorn_Opportunity__c (after insert,after update) {
    //set for holding already copied record bullhorn id's
   // Set<String> bhidset=new Set<String>();
    List<Opportunity> opps2create=new List<Opportunity>();
     //map for holding ownername id to map bullhorn owner to sf
    Map<String,Id> ownerNameIdMap=new Map<String,Id>();
    for(User usr:[select Id,firstname,lastname from User where isactive=true and userroleId!=null]){
        ownerNameIdMap.put(usr.firstname+' '+usr.lastname,usr.Id);
    }
    
     //map for holding account id to map bullhorn account to sf contact
    Map<String,Id> accmap=new Map<String,Id>();
    for(Account acc:[select Id,bullhorn_Id__c from Account where bullhorn_Id__c!=null]){
        accmap.put(acc.bullhorn_Id__c,acc.Id);
    }
    
    
    String recruitmentId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Recruitments').getRecordTypeId();
   /* for(Lead le:[select bullhorn_Id__c 
                 from Lead 
                 where bullhorn_Id__c!=null]){
                     if(le.bullhorn_Id__c!='' ||le.bullhorn_Id__c!=null)
                     bhidset.add(le.bullhorn_Id__c);
                 }
    */
    for(Bullhorn_Opportunity__c bhop:trigger.new){
        if((trigger.isinsert || trigger.isupdate)  
           //&& !bhidset.contains(bhle.bullhorn_Id__c)
          ){
              if(bhop.Bullhorn_Owner__c!=null &&
                 ownerNameIdMap.containsKey(bhop.Bullhorn_Owner__c) &&
                accmap.containsKey(bhop.clientcorporation__c)){
            opps2create.add(new Opportunity(name=(bhop.title__c!=null?bhop.title__c:bhop.name),
                                            bullhorn_Id__c=bhop.bullhorn_Id__c,
                                            stagename=bhop.status__c,
                                            closedate=(new Bullhorn_OpportunityHelper().getDateFromTimestamp(bhop)),
                                            ownerId=ownerNameIdMap.get(bhop.Bullhorn_Owner__c),
                                            recordtypeId=recruitmentId,
                                            accountId=accmap.get(bhop.clientCorporation__c)
                                            ));
              }
        }
    }
    if(opps2create.size()>0){
       Database.upsert(opps2create,Opportunity.bullhorn_Id__c,false);
    }
}