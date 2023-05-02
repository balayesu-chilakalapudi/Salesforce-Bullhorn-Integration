/*
Solution - you need to call bullhorn api and get contacts from there and store them in a new object called bullhorn_clientcontacts.
make sure if you call same api again it checks for foreign key and upsert the data.Then we will have a logic to create leads afterwards.
*/

trigger Bullhorn_ClientContact_BH2SFSync on Bullhorn_ClientContact__c (after insert,after update) {
    //set for holding already copied record bullhorn id's
   // Set<String> bhidset=new Set<String>();
    List<Contact> contacts2create=new List<Contact>();
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
    
    String recruitmentId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Recruitments').getRecordTypeId();
   /* for(Lead le:[select bullhorn_Id__c 
                 from Lead 
                 where bullhorn_Id__c!=null]){
                     if(le.bullhorn_Id__c!='' ||le.bullhorn_Id__c!=null)
                     bhidset.add(le.bullhorn_Id__c);
                 }
    */
    for(Bullhorn_ClientContact__c bhcc:trigger.new){
        if((trigger.isinsert || trigger.isupdate)  
           //&& !bhidset.contains(bhle.bullhorn_Id__c)
          ){
              if(bhcc.Bullhorn_Owner__c!=null &&
                 ownerNameIdMap.containsKey(bhcc.Bullhorn_Owner__c) &&
                bhcc.clientCorporation__c!=null &&
                accmap.containsKey(bhcc.clientcorporation__c)){
            contacts2create.add(new Contact(
                                            bullhorn_Id__c=bhcc.bullhorn_Id__c,
                                            phone=bhcc.phone__c,
                                            email=bhcc.email__c,
                                            lastname=bhcc.lastname__c,
                                            firstname=bhcc.firstname__c,
                							fax=bhcc.fax__c,
                							Bullhorn_address__c=bhcc.address__c,
                                            ownerId=ownerNameIdMap.get(bhcc.Bullhorn_Owner__c),
                							recordtypeId=recruitmentId,
                							accountId=accmap.get(bhcc.clientCorporation__c)
                                            ));
              }
        }
    }
    System.debug('contacts2create: '+contacts2create);
    if(contacts2create.size()>0){
       List<Database.upsertResult> uResults=Database.upsert(contacts2create,Contact.bullhorn_Id__c,false);
        System.debug('uResults: '+uResults);
    }
}