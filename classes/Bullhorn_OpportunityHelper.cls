public class Bullhorn_OpportunityHelper {
    public Date getDateFromTimestamp(Bullhorn_Opportunity__c p_bhop){
        Date result=null;
        if(p_bhop.estimatedEndDate__c!=null){
        	DateTime eed=DateTime.newInstance(Long.valueOf(p_bhop.estimatedEndDate__c));
            result=date.newinstance(eed.year(), eed.month(), eed.day());
        }else{
        	DateTime efd=DateTime.newInstance(Long.valueOf(p_bhop.effectiveDate__c));
            result=date.newinstance(efd.year(), efd.month(), efd.day());
        }
        return result;
    }
}