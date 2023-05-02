/*
Solution - you need to call bullhorn api and get leads from there and store them in a new object called bullhorn_leads.
make sure if you call same api again it checks for foreign key and upsert the data.Then we will have a logic to create leads afterwards.
*/

trigger Bullhorn_Lead_BH2SFCopy on Bullhorn_Lead__c (after insert,after update) {
    //set for holding already copied record bullhorn id's
   // Set<String> bhidset=new Set<String>();
    List<Lead> leads2create=new List<Lead>();
    //map for holding ownername id to map bullhorn owner to sf
    Map<String,Id> ownerNameIdMap=new Map<String,Id>();
    for(User usr:[select Id,firstname,lastname from User where isactive=true and userroleId!=null]){
        ownerNameIdMap.put(usr.firstname+' '+usr.lastname,usr.Id);
    }
    String recruitmentId=Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Recruitments').getRecordTypeId();
   /* for(Lead le:[select bullhorn_Id__c 
                 from Lead 
                 where bullhorn_Id__c!=null]){
                     if(le.bullhorn_Id__c!='' ||le.bullhorn_Id__c!=null)
                     bhidset.add(le.bullhorn_Id__c);
                 }
    */
    for(Bullhorn_Lead__c bhle:trigger.new){
        if((trigger.isinsert || trigger.isupdate)  
           //&& !bhidset.contains(bhle.bullhorn_Id__c)
          ){
              if(bhle.bullhorn_owner__c!=null &&
                 ownerNameIdMap.containsKey(bhle.bullhorn_owner__c)){
            leads2create.add(new Lead(firstname=bhle.firstname__c,
                                     lastname=(bhle.lastname__c!=null?bhle.lastname__c:bhle.companyName__c),
                                     phone=bhle.phone__c,
                                     email=bhle.email__c,
                                     bullhorn_Id__c=bhle.Bullhorn_ID__c,
                                     recordtypeId=recruitmentId,
                                     company=(bhle.companyName__c==null?(bhle.Firstname__c+' '+bhle.Lastname__c):bhle.companyName__c),
                                     Bullhorn_Campaign_Source__c=bhle.campaignSource__c,
                                     fax=bhle.fax__c,
                                     Bullhorn_Lead_Address__c=bhle.Address__c,
                                     ownerId=ownerNameIdMap.get(bhle.bullhorn_owner__c),
                                     Created_By_Integration__c=true));
              }
        }
    }
    if(leads2create.size()>0){
         LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
       Database.upsert(leads2create,Lead.bullhorn_Id__c,false);
        for(Lead le:leads2create){
            if(le.Id!=null &&
              !le.IsConverted){
                Lead myLead = le;
                
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(myLead.id);
                
               // LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                try{
                	Database.LeadConvertResult lcr = Database.convertLead(lc);
                }catch(Exception ex){
                    system.debug('exception: '+ex);
                }
            }
        }
    }
}