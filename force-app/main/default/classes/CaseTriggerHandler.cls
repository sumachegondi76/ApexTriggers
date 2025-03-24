public class CaseTriggerHandler {
    public static void updateCaseTrigger(List<case> caseList){
        for(case ca : caseList){
            if(ca.Origin == 'Email')
            {
                ca.Status = 'New';  
                ca.Priority = 'Medium';
            }
        }
    }
    public static void latestCaseNum(list<case> lstcase){
       list<account> lstacc = new list<account>();
        for(case ca : lstcase){
            account acc = new account();
            acc.Latest_case_number__c = ca.CaseNumber;
            acc.Id = ca.AccountId;
            lstacc.add(acc);
        }
        if(!lstacc.isempty()){
            update lstacc;
        }
    }

  public static void updatePriority(list<Case> lstcase){
        for(case ca: lstcase){
            if(ca.Origin == 'Phone'){
                ca.Priority = 'High';
            }
            else{
                ca.Priority = 'Low';
            }
        }
    }
    public static void preventDeleteOtherUsers(list<Case> lstcase){
        id currentuser = UserInfo.getProfileId();
        id sysadmin = [select id,Name from Profile where name='System Administrator'].id;
        for(case ca:lstcase){
            if(sysadmin != currentuser){
                ca.adderror('you cannot delete the record');
                }
        }
    }
    
}