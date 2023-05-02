/*
Opportunities in BH = Opportunities in SF
*/
public class BullhornToSFOpportunitySync {
    public static void syncOpportunities(){        
        Bullhorn__c bh=Bullhorn__c.getValues('tokens');
        String BhRestToken=bh.BhRestToken__c;
        String restUrl=bh.restUrl__c;  
        String ClientID=bh.ClientID__c;
        
        if(BhRestToken!=null &&
           restUrl!=null){
               //set for holding existing records based on bullhorn Id
               /* Set<String> bullhornIdset=new Set<String>();
for(Bullhorn_Lead__c bh:[select bullhorn_Id__c 
from bullhorn_lead__c 
where bullhorn_Id__c!=null
order by createddate desc
limit 50000]){
bullhornIdset.add(bh.bullhorn_Id__c);
}
if(bullhornIdset.isEmpty()){
bullhornIdset.add('0'); 
}  
*/
               
               
               
               // Http http = new Http();
               HttpRequest req = new HttpRequest();
               String tokenurl=restUrl+'query/Opportunity?fields=id,address,clientCorporation,estimatedEndDate,owner,campaignSource,dealValue,description,effectiveDate,expectedFee,isOpen,lead,source,status,title,type,yearsRequired,dateAdded&orderBy=dateAdded&count=500&start=0&BhRestToken='+BhRestToken;        
               System.debug('tokenurl: '+tokenurl);      
               
               /*
String bullhornIdset_str=String.valueOf(bullhornIdset);        
//replace { with {
if(bullhornIdset_str.contains('{')){
bullhornIdset_str=bullhornIdset_str.replace('{','(');
}   
//replace } with )
if(bullhornIdset_str.contains('}')){
bullhornIdset_str=bullhornIdset_str.replace('}',')');
}
*/
               
               String wclause='{"where": "id IS NOT NULL"}';   
               //AND id NOT IN '+bullhornIdset_str+'
               //  existing id set removed due to inability of where caluse to parse many id list
               // external id is taking care of duplicate id list
               
               System.debug('wclause: '+wclause);
               req.setBody(wclause);
               req.setEndpoint(tokenurl);
               req.setMethod('POST');        
               req.setTimeout(60*1000);
               
               //  req.setHeader('x-myobapi-key', ClientID);
               //  req.setHeader('Accept', 'application/json');
               // req.setHeader('x-myobapi-version', 'v0');
               
               Http h = new Http();
               String resp;
               HttpResponse res = h.send(req);
               resp = res.getBody();
               
               System.debug(' bullhorn opportunity list::: ' + resp);        
               
               OpportunityRespData respd;
               try{
                   respd= (OpportunityRespData)JSON.deserialize(resp, OpportunityRespData.class);
               }catch(Exception ex){
                   System.debug('Exception: '+ex);
               }
               if(respd!=null && 
                  respd.data!=null){
                      System.debug('data list size: '+respd.data.size());
                      
                      List<Bullhorn_Opportunity__c> bhopportunities=new List<Bullhorn_Opportunity__c>();
                      for(BHOpportunity b:respd.data){
                          if(b.owner!=null){
                          bhopportunities.add(new Bullhorn_Opportunity__c(
                              name=(b.campaignSource!=null)?b.campaignSource:b.id,
                              bullhorn_Id__c=b.id,
                              campaignSource__c=b.campaignSource,
                              dealValue__c=b.dealValue,
                              description__c=b.description,

                              effectiveDate__c=b.effectiveDate,
                              estimatedEndDate__c=b.estimatedEndDate,
                              expectedFee__c=b.expectedFee,
                              isOpen__c=b.isOpen,
                              lead__c=(b.lead!=null)?b.lead.id:null,
                              source__c=b.source,
                              status__c=b.status,
                              title__c=b.title,
                              type__c=b.type,
                              yearsRequired__c=b.yearsRequired,
                              bullhorn_owner__c=(b.owner.firstname+' '+b.owner.lastname),
                              dateAdded__c=b.dateAdded,
                              clientCorporation__c=b.clientCorporation.id,
                              address__c=getAddress(b.address.address1+','+b.address.address2+','+b.address.city+','+b.address.state+','+b.address.zip+','+b.address.countryID+','+b.address.countryName+','+b.address.countryCode)
                          ));
                          }
                      }
                      if(bhopportunities.size()>0){
                          Database.upsert(bhopportunities,Bullhorn_Opportunity__c.bullhorn_Id__c,false); 
                      }
                  }else{
                      System.debug('no response data ');
                  }                
           }
    }
    //remove blanks spaces
    public static String getAddress(String addr){
        String result=addr;
        if(result!=null){
            if(result.contains('null')){
                result=result.replace('null',''); 
            }
            if(result.contains(',,')){
                result=result.replace(',,','');
            }
            if(result.startsWith(',')){
                result=result.removeStart(',');
            }
            result=result.trim();
        }
        return result;
    }
    public class OpportunityRespData{
        public String start;
        public String count;
        public List<BHOpportunity> data;        
    }
    public class TaskRespData{
        public String start;
        public String count;
        public List<BHTask> data;        
    }
    public class BHOpportunity{        
        public String id;
        public Address address;
        public String campaignSource;
        public String dealValue;
        public String description;
        public String effectiveDate;
        public String estimatedEndDate;
        public String expectedFee;
        public String isOpen;
        public BHLead lead;
        public String source;
        public String status;
        public String title;
        public String type;
        public String yearsRequired;
        public String dateAdded;
        public BHOwner owner;
        public BHClientCorporation clientCorporation;
    }
    
    public class BHLead{
        public String id;
        public String firstname;
        public String lastname;
        public String email;
        public String phone;
        public String campaignSource;
        public String status;
        public Address address;
        public String companyName;
        public String fax;
        public String leadSource;
        public String clientContact;
    }
    
    public class Address{
        public String address1;
        public String address2;
        public String city;
        public String state;
        public String zip;
        public String countryID;
        public String countryName;
        public String countryCode;
    }
    public class BHTask{
        public String id;
        public String subject;
        public String type;
        public BHOpportunity opportunity;
        public String candidate;
        public String description;
        public String dateBegin;
        public String dateCompleted;
        public String dateEnd;
        public String isCompleted;
        public BHOwner owner;
    }
    public class BHOwner{
        public String id;
        public String firstname;
        public String lastname;
    }
    public class BHClientCorporation{
        public String id;
        public String name;
    }  
    
     //get Lead Email, Tasks
    public static void getOpportunityTasks(){       
        Bullhorn__c bh=Bullhorn__c.getValues('tokens');
        String access_token=bh.access_token__c;
        String refresh_token=bh.refresh_token__c;
        String BhRestToken=bh.BhRestToken__c;
        String restUrl=bh.restUrl__c;  
        String ClientID=bh.ClientID__c;
        
        if(BhRestToken!=null &&
           restUrl!=null){                
               // Http http = new Http();
               HttpRequest req = new HttpRequest();
               String tokenurl=restUrl+'query/Task?fields=id,candidate,opportunity,type,owner,subject,clientContact,dateBegin,dateCompleted,dateEnd,description,isCompleted&orderBy=dateAdded&count=500&start=0&BhRestToken='+BhRestToken;        
               System.debug('tokenurl: '+tokenurl);      
               
               String wclause='{"where": "opportunity IS NOT NULL"}';   
               
               System.debug('wclause: '+wclause);
               req.setBody(wclause);
               req.setEndpoint(tokenurl);
               req.setMethod('POST');        
               req.setTimeout(60*1000);
               
               //  req.setHeader('x-myobapi-key', ClientID);
               //  req.setHeader('Accept', 'application/json');
               // req.setHeader('x-myobapi-version', 'v0');
               
               Http h = new Http();
               String resp;
               HttpResponse res = h.send(req);
               resp = res.getBody();
               
               System.debug(' bullhorn lead task list::: ' + resp);        
               
               TaskRespData respd;
               try{
                   respd= (TaskRespData)JSON.deserialize(resp, TaskRespData.class);
               }catch(Exception ex){
                   System.debug('Exception: '+ex);
               }
               if(respd!=null && 
                  respd.data!=null){
                      System.debug('data list size: '+respd.data.size());
                      
                      List<Bullhorn_Task__c> bhtasks=new List<Bullhorn_Task__c>();
                      for(BHTask b:respd.data){
                          if(b.opportunity!=null && b.opportunity.id!=null && b.owner!=null){
                          bhtasks.add(new Bullhorn_Task__c(
                              name=b.subject,
                              bullhorn_id__c=b.id,
                              subject__c=b.subject,
                              type__c=b.type,
                              bullhorn_opportunity_id__c=b.opportunity.id,
                              dateBegin__c=b.dateBegin,
                              dateCompleted__c=b.dateCompleted,
                              dateEnd__c=b.dateEnd,
                              description__c=b.description,
                              candidate__c=b.candidate,
                              isCompleted__c=b.isCompleted,
                              bullhorn_owner__c=(b.owner.firstname+' '+b.owner.lastname)
                          ));
                          }
                      }
                      if(bhtasks.size()>0){
                          Database.upsert(bhtasks, Bullhorn_Task__c.bullhorn_Id__c,false);
                      }
                  }else{
                      System.debug('no response data ');
                  }  
           }
    }
}