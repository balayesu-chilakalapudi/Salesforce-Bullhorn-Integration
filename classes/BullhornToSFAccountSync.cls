/*
ClientContacts in BH = Contacts in SF
*/
public class BullhornToSFAccountSync {
    public static void syncAccounts(){        
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
               String tokenurl=restUrl+'query/ClientCorporation?fields=id,name,address,numEmployees,notes,numOffices,phone,status&orderBy=dateAdded&count=500&start=0&BhRestToken='+BhRestToken;        
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
               
               System.debug(' bullhorn contact list::: ' + resp);        
               
               AccountRespData respd;
               try{
                   respd= (AccountRespData)JSON.deserialize(resp, AccountRespData.class);
               }catch(Exception ex){
                   System.debug('Exception: '+ex);
               }
               if(respd!=null && 
                  respd.data!=null){
                      System.debug('data list size: '+respd.data.size());
                      
                      List<Bullhorn_ClientCorporation__c> bhaccounts=new List<Bullhorn_ClientCorporation__c>();
                      for(BHAccount b:respd.data){
                         // if(b.owner!=null){                 
                          bhaccounts.add(new Bullhorn_ClientCorporation__c(
                              name=b.name,
                              bullhorn_Id__c=b.id,
                              numEmployees__c=b.numEmployees,
                              notes__c=b.notes,
                              numOffices__c=b.numOffices,
                              phone__c=b.phone,
                              status__c=b.status,
                              bullhorn_owner__c=System.Label.Bullhorn_ClientCorporation_Owner_Name,
                              address__c=getAddress(b.address.address1+','+b.address.address2+','+b.address.city+','+b.address.state+','+b.address.zip+','+b.address.countryID+','+b.address.countryName+','+b.address.countryCode)
                          ));
                        //  }
                      }
                      if(bhaccounts.size()>0){
                          Database.upsert(bhaccounts,Bullhorn_ClientCorporation__c.bullhorn_Id__c,false); 
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
    public class AccountRespData{
        public String start;
        public String count;
        public List<BHAccount> data;        
    }
   
    public class BHAccount{     
        public String id;
        public String name;
        public Address address;
        public String numEmployees;
        public String notes;
        public String numOffices;
        public String phone;
        public String status;
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
    
    public class BHOwner{
        public String id;
        public String firstname;
        public String lastname;
    }  
}