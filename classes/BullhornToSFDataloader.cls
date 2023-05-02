/*
Leads in BH = Leads in SF ( leads created in bullhorn should be created in SF) and this is recruiting system 
Opportunities in BH = Opportunities in SF
Contacts in BH = Contacts in SF
Jobs in BH = Cases in SF
*/


public class BullhornToSFDataloader {
    public static void saveBHLeadsToSFLeads(){        
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
               String tokenurl=restUrl+'query/Lead?fields=id,firstName,lastName,owner,email,phone,address,campaignSource,companyName,fax,leadSource,status,dateAdded&orderBy=dateAdded&count=500&start=0&BhRestToken='+BhRestToken;        
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
               
               String wclause='{"where": "status<>\'Converted\'"}';   
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
               
               System.debug(' bullhorn lead list::: ' + resp);        
               
               LeadRespData respd;
               try{
                   respd= (LeadRespData)JSON.deserialize(resp, LeadRespData.class);
               }catch(Exception ex){
                   System.debug('Exception: '+ex);
               }
               if(respd!=null && 
                  respd.data!=null){
                      System.debug('data list size: '+respd.data.size());
                      
                      List<Bullhorn_Lead__c> bhleads=new List<Bullhorn_Lead__c>();
                      for(BHLead b:respd.data){
                          if(b.owner!=null){
                          bhleads.add(new Bullhorn_Lead__c(
                              name=b.firstname+' '+b.lastname,
                              bullhorn_Id__c=b.id,
                              firstname__c=b.firstname,
                              lastname__c=b.lastname,
                              email__c=b.email,
                              phone__c=b.phone,
                              campaignSource__c=b.campaignSource,
                              companyName__c=b.companyName,
                              fax__c=b.fax,
                              leadsource__c=b.leadSource,
                              status__c=b.status,
                              bullhorn_owner__c=(b.owner.firstname+' '+b.owner.lastname),
                              address__c=getAddress(b.address.address1+','+b.address.address2+','+b.address.city+','+b.address.state+','+b.address.zip+','+b.address.countryID+','+b.address.countryName+','+b.address.countryCode)
                          ));
                          }
                      }
                      if(bhleads.size()>0){
                          Database.upsert(bhleads,Bullhorn_Lead__c.bullhorn_Id__c,false); 
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
    public class LeadRespData{
        public String start;
        public String count;
        public List<BHLead> data;        
    }
    public class TaskRespData{
        public String start;
        public String count;
        public List<BHTask> data;        
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
        public BHOwner owner;
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
        public BHLead lead;
        public String candidate;
        public String description;
        public String dateBegin;
        public String dateCompleted;
        public String dateEnd;
        public String isCompleted;
        public String clientContact;
        public BHOwner owner;
    }
    //get Lead Email, Tasks
    public static void getLeadTasks(){       
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
               String tokenurl=restUrl+'query/Task?fields=id,candidate,lead,owner,type,subject,clientContact,dateBegin,dateCompleted,dateEnd,description,isCompleted&orderBy=dateAdded&count=500&start=0&BhRestToken='+BhRestToken;        
               System.debug('tokenurl: '+tokenurl);      
               
               String wclause='{"where": "lead IS NOT NULL"}';   
               
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
                          if(b.owner!=null){
                          bhtasks.add(new Bullhorn_Task__c(
                              name=b.subject,
                              bullhorn_id__c=b.id,
                              subject__c=b.subject,
                              type__c=b.type,
                              bullhorn_lead_id__c=b.lead.id,
                              dateBegin__c=b.dateBegin,
                              dateCompleted__c=b.dateCompleted,
                              dateEnd__c=b.dateEnd,
                              clientContact__c=b.clientContact,
                              description__c=b.description,
                              candidate__c=b.candidate,
                              isCompleted__c=b.isCompleted,
                              bullhorn_Owner__c=(b.owner.firstname+' '+b.owner.lastname)
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
    public class BHOwner{
        public String id;
       	public String firstname;
        public String lastname;
    }
}