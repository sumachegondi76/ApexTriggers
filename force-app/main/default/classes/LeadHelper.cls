public class LeadHelper
{
 public static void createlead()
 {
   
    
     for(integer counter=1;counter<=151;counter++)
     {
    
     lead le = new lead();
         le.industry = 'banking';
         le.firstName = 'sia';
         le.LastName = 'dil';
         le.Status = 'high';
         le.AnnualRevenue = 889798;
         le.Company = 'tcs';
         insert le;
         if(le.id != null)
         {
             system.debug('lead record is..'+le.id);
         }
     
     }
 }
    public static void updateStatus(list<lead> lstlead){
        for(lead le : lstlead){
            le.Status = 'Working-Contacted';
            if(le.Industry == 'Healthcare'){
                le.LeadSource = 'Purchased List';
                le.SICCode__c = '1100';
                le.Primary__c = 'Yes';
            }
        }
    }
    public static void createTask(list<lead> lstlead){
         list<Task> lsttask = new list<task>();
        for(lead le : lstlead){
             task ta = new task();
                ta.OwnerId = le.OwnerId;
                ta.Priority = 'High';
                ta.Description = 'Follow up the new lead';
                ta.Status = 'Not Started';
                ta.Subject = 'Split revenue';
                ta.WhoId = le.Id;
                lsttask.add(ta);
        }
        if(!lsttask.isempty()){
            insert lsttask;
        }
    }
    public static void preventLeadDeletion(list<lead> lstlead){
        for(lead le : lstlead){
            system.debug('inside for');
            if(le.Status == 'Working-Contacted'){
                system.debug('inside if');
                le.adderror('you cannot delete the lead record');
            }
        }
    }
    public static void PreventModification(list<lead> lstlead){
        for(lead le : lstlead){
            if(le.CreatedDate <= system.today()-8){
                le.adderror('you cannot modified this record');
            }
        }
    }
    public static void preventDuplicatesByEmail(list<lead> lstlead){
     set<string> emailset =new set<string>();
        for(lead le : lstlead){
            if(le.Email != null){
                emailset.add(le.email);
            }
        }
        if(!emailset.isempty()){
            map<string,id> existingmap = new map<string,id>();
            for(lead le : [select id,email from lead where email in : emailset]){
                existingmap.put(le.email,le.id);
            }
        
        for(lead le : lstlead){
            if(le.email != null && existingmap.containskey(le.email)){
                le.adderror('duplicate record found');
            }
        }
        }
    }        }