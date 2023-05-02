/*
Solution - you need to call bullhorn api and get contacts from there and store them in a new object called bullhorn_clientcontacts.
make sure if you call same api again it checks for foreign key and upsert the data.Then we will have a logic to create leads afterwards.
*/

trigger Bullhorn_Account_BH2SFSync on Bullhorn_ClientCorporation__c (after insert,after update) {
    //set for holding already copied record bullhorn id's
   // Set<String> bhidset=new Set<String>();
    List<Account> accounts2create=new List<Account>();
     //map for holding ownername id to map bullhorn owner to sf
    Map<String,Id> ownerNameIdMap=new Map<String,Id>();
    for(User usr:[select Id,firstname,lastname from User where isactive=true and userroleId!=null]){
        ownerNameIdMap.put(usr.firstname+' '+usr.lastname,usr.Id);
    }
    String recruitmentId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Recruitment').getRecordTypeId();
   /* for(Lead le:[select bullhorn_Id__c 
                 from Lead 
                 where bullhorn_Id__c!=null]){
                     if(le.bullhorn_Id__c!='' ||le.bullhorn_Id__c!=null)
                     bhidset.add(le.bullhorn_Id__c);
                 }
    */
    for(Bullhorn_ClientCorporation__c bhcc:trigger.new){
        if((trigger.isinsert || trigger.isupdate)  
           //&& !bhidset.contains(bhle.bullhorn_Id__c)
          ){
              if(bhcc.Bullhorn_Owner__c!=null &&
                 ownerNameIdMap.containsKey(bhcc.Bullhorn_Owner__c)){
            accounts2create.add(new Account(name=bhcc.name,
                                            bullhorn_Id__c=bhcc.bullhorn_Id__c,
                                            phone=bhcc.phone__c,
                							Bullhorn_address__c=bhcc.address__c,
                                            notes__c=bhcc.notes__c,
                                            ownerId=ownerNameIdMap.get(bhcc.Bullhorn_Owner__c),
                                            recordtypeId=recruitmentId
                                            ));
              }
        }
    }
    System.debug('accounts2create: '+accounts2create.size());
    if(accounts2create.size()>0){
       Database.upsert(accounts2create,Account.bullhorn_Id__c,false);
    }
}