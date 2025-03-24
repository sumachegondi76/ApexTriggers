public class AccountTriggerHandler {
   public static void updaterating(list<account> newlist)
   {
       for(account acc : newlist)
       {
           if(acc.industry != null && acc.Industry == 'media')
           {
               acc.Rating = 'hot';
           }
       }
   }
   public static void createrelatedOpp(list<account> newlist)
   {
       list<opportunity> lstopp = new list<opportunity>();
       for(account acc : newlist)
       {
           opportunity opp = new opportunity();
           opp.name = acc.name;
           opp.AccountId = acc.id;
           opp.StageName = 'prospecting';
           opp.CloseDate = system.today();
           lstopp.add(opp);
       }
       if(!lstopp.isempty())
       {
           insert lstopp;
       }
   }
    public static void updatePhoneDescription(list<account> newlist,map<id,account> oldmap)
    {
       for(account acc : newlist)
       {
           if(oldmap != null && acc.Phone != oldmap.get(acc.id).phone){
               acc.Description = 'phone is modified on account';
           }
       }
    }
    public static void UpdateRelatedoppPhone(list<account> newlist,map<id,account> oldmap)
        {
            map<id,account> accmap = new map<id,account>();
            list<opportunity> opplist = new list<opportunity>();
            for(account acc : newlist){
                if(oldmap != null && acc.phone != oldmap.get(acc.id).phone ){
                    accmap.put(acc.id,acc);
                }
            }
                for(opportunity opp : [select id,Account_phone__c,accountid from opportunity where accountid in : accmap.keySet()])
                    
                {
                    opportunity oppr = new opportunity();
                    if(accmap.containskey(opp.AccountId)){
                        oppr.id = opp.id;
                        oppr.Account_phone__c = accmap.get(opp.AccountId).phone;
                        opplist.add(oppr);
                    }
            }
                if(!opplist.isEmpty()){
                    update opplist;
                }
}
        
    
    public static void updateContacts(list<account> newlist,map<id,account> oldmap)
    {
         map<id,account> maplist = new map<id,account>();
     
        list<contact> lstcon = new list<contact>();
         for(account acc : newlist){
                if(oldmap != null && acc.phone != oldmap.get(acc.id).phone && acc.fax != oldmap.get(acc.id).fax){
                    maplist.put(acc.id,acc);
                }
         }
        for(contact con :  [select id,firstname,phone,fax,accountid from contact where accountid in : maplist.keySet()])
        {
            contact conlist = new contact();
            if(maplist.containskey(con.AccountId))
            {
                conlist.id = con.id;
                conlist.phone = maplist.get(con.accountid).phone;
                conlist.fax = maplist.get(con.AccountId).fax;
                lstcon.add(conlist);
}
        }
        if(!lstcon.isempty()){
            update lstcon;
        }
    }
    public static void preventDelAcc(list<account> lstacc,map<id,account>oldmap){
        map<id,account> accmap = new map<id,account>([select id,(select id from contacts) from account where id in : oldmap.keyset()]);
        for(account acc : lstacc){
            if(accmap.get(acc.id).contacts.size()>0){
                acc.adderror('you cannot authorised to delete this account');
            }
        }
    }
    public static void addRelatedList(list<account> lstacc){
        list<contact> lstcon = new list<contact>();
        list<opportunity>lstopp = new list<opportunity>();
        for(account acc : lstacc){
            contact con = new contact();
            con.lastname = acc.name;
            con.AccountId = acc.id;
            lstcon.add(con);
              insert lstcon;
      
            opportunity opp = new opportunity();
            opp.accountid = acc.id;
            opp.Name = acc.name;
            opp.StageName = 'Prospecting';
            opp.CloseDate = system.today();
            lstopp.add(opp);
        }
     
        insert lstopp;
        
    }
    public static void updateConWebsite(list<Account> lstacc,Map<Id,Account> oldmap){
        list<contact> lstcon = new list<contact>();
        set<id> accid = new set<id>();
        for(account acc :lstacc){
            if(acc.Website != oldmap.get(acc.id).Website){
                accid.add(acc.id);
            }
        }
        for(Account acc : [select id,Website, (select id,Website__c from contacts) from Account where Id in :accid]){
            if(acc.contacts != null){
                for(contact con:acc.contacts){
                    con.Website__c = acc.Website;
                    lstcon.add(con);
                }
            }
        }
            if(!lstcon.isempty()){
                update lstcon;
            
        }
    }
    public static void createContacts(list<Account> lstacc){
        list<contact> lstcon = new list<contact>();
        for(account acc:lstacc){
            if(acc.Contacts_To_Create__c != null){
                for(integer i=0;i<= acc.Contacts_To_Create__c; i++){
                    contact con = new contact();
                    con.LastName = acc.Name;
                    con.AccountId = acc.Id;
                    lstcon.add(con);
                }
            }
        }
        if(!lstcon.isempty()){
            insert lstcon;
        }
    }
     public static void updateConAsync(list<Account> lstacc,map<id,Account> oldmap){
        list<id> accid = new list<id>();
        for(account acc: lstacc){
            if(acc.Industry == 'Biotechnology' && acc.Industry != oldmap.get(acc.id).Industry){
                accid.add(acc.id);
                  
            }
            
        }
         if(!accid.isempty()){
         callAsyncApex(accid);
         }
     
     }     
    @future
    public static void callAsyncApex(list<id> accountids){
        list<contact> conlist = new list<contact>();
        list<contact> lstcon = [select id,leadsource from contact where AccountId In:accountids];
        for(contact con:lstcon){
              Contact updatedContact = new Contact(Id = con.Id, LeadSource = 'Web');
            conlist.add(updatedContact);
        }
        if(!conlist.isempty()){
            update conlist;
        }
    }
    public static void restoreRecords(list<account> lstacc){
     set<id> accid = new set<id>();
        list<account> rstacc = new list<account>();
        for(account acc : lstacc){
            accid.add(acc.id);
        }
        list<account> acclist = [select id,name from account where id in : accid];
        for(account acc : acclist){
            acc.Name = 'Restored'+acc.Name;
            rstacc.add(acc);
        }
        if(!rstacc.isempty()){
            update rstacc;
        }
    }
    public static void beforeInsert(list<account> lstacc){
        map<id,id> accmap = new map<id,id>();
        for(account acc : lstacc){
            accmap.put(acc.id,acc.OwnerId);
        }
        map<id,user> mapuser = new map<id,user>([select id,Name from user where id in : accmap.values()]);
        for(account acc : lstacc){
            acc.Sales_Rep__c = mapuser.get(accmap.get(acc.id)).Name;
                      
                
        }
    }


  
  
   
 //private static Set<Id> processedAccounts = new Set<Id>();

    
 
   



  
   



    

   public static void handleUpdate(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
        // List to store child accounts that need to be updated
        List<Account> childAccountsToUpdate = new List<Account>();

        // Iterate through the updated accounts
        for (Account parentAccount : newAccounts) {
            // Check if the relevant field (replace 'Custom_Field__c' with your actual field name) has changed
            if (parentAccount.Parent_Account__c != oldAccountMap.get(parentAccount.Id).Parent_Account__c) {
                // Query for child accounts related to the parent account
                List<Account> childAccounts = [SELECT Id, Parent_Account__c FROM Account WHERE Parent_Account__c = :parentAccount.Id];

                // Update the child accounts with the same value
                for (Account childAccount : childAccounts) {
                    childAccount.Parent_Account__c = parentAccount.Parent_Account__c;
                    childAccountsToUpdate.add(childAccount);
                }
            }
        }

        // Update the child accounts
        if (!childAccountsToUpdate.isEmpty()) {
            update childAccountsToUpdate;
        }
    }
    public static void clientOpp(list<account> lstacc){
        list<opportunity> lstopp = new list<opportunity>();
        map<id,id> oppmap = new map<id,id>();
        list<account> acclist = new list<account>();
        for(account acc : lstacc){
            opportunity opp = new opportunity();
            opp.Name = acc.Name;
            opp.AccountId = acc.id;
            opp.CloseDate = system.today();
            opp.StageName = 'prospecting';
            lstopp.add(opp);
        }
        if(!lstopp.isempty()){
            insert lstopp;
        }
        for(opportunity opp : lstopp){
            oppmap.put(opp.AccountId,opp.id);
        }
        list<account> lstaccount = [select id, name,Client_Opportunity__c from account where id in :oppmap.keyset()];
        if(!lstaccount.isempty()){
      
        for(account acc :lstaccount){
            acc.Client_Opportunity__c = oppmap.get(acc.id);
            acclist.add(acc);
            
        }
        }
        if(!acclist.isempty()){
            update acclist;
        }
    }
    public static void sendNotification(list<account> lstacc,map<id,account> oldmap){
        Date startDate = System.today()-30;
        set<id> accid = new set<id>();
        for(account acc : lstacc){
            if(acc.AnnualRevenue != null && acc.AnnualRevenue>50000 && acc.CreatedDate > startDate && (oldmap == null || acc.AnnualRevenue != oldmap.get(acc.id).AnnualRevenue)){
              accid.add(acc.OwnerId);  
            }
            map<id,user> usermap = new map<id,user>();
            if(!accid.isempty()){
                usermap = new map<id,user>([select id, name,email from user where id in : accid]);
            }
            list<messaging.singleEmailMessage> emails = new list<messaging.singleEmailMessage>();
            if(!usermap.isempty()){
                for(account acco: lstacc){
                    if(usermap.containskey(acco.OwnerId)){
                        messaging.singleEmailMessage email= new messaging.singleEmailMessage();
                        string[] toadderss = new string[]{usermap.get(acco.OwnerId).email};
                            email.setToAddresses(toadderss);
                        email.setSubject('Account Record Id'+acco.id);
                        email.setplaintextbody('Dear'+usermap.get(acc.OwnerId).Name+',\n\n The revenue for the below mentioned record is: '+
                                              'above 50000\n Annual Revenue: '+acco.AnnualRevenue+'\n RecordId = '+acco.id+'\n Best Regards.');
                                          emails.add(email);
                        messaging.sendEmail(emails);
                    }
                }
            }
        }
    }
    /*public static void populateSalesRepField(list<account> lstacc,map<id,account> oldmap){
        set<id> ownerids = new set<id>();
        for(account acc : lstacc){
            //if(oldmap != null && acc.OwnerId != oldmap.get(acc.id).OwnerId){
            ownerids.add(acc.id);
            }
        //}
        map<id,user> usermap = new map<id,user>([select id,name from user where id in : ownerids]);
        for(account acc : lstacc){
            acc.Sales_Rep__c = usermap.get(acc.OwnerId).name;
        }
        
    }*/
    public static void handleUpdateSalesRep(List<Account> newAccounts, Map<Id, Account> oldMap) {
        Set<Id> ownerIds = new Set<Id>();

        for(Account acc : newAccounts) {
            // If Account Owner is changing or it's a new Account record
            if((acc.OwnerId != oldMap.get(acc.Id).OwnerId) || oldMap.get(acc.Id) == null) {
                ownerIds.add(acc.OwnerId);
            }
        }

        if(!ownerIds.isEmpty()) {
            Map<Id, User> ownerMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :ownerIds]);
            
            for(Account acc : newAccounts) {
                if(ownerMap.containsKey(acc.OwnerId)) {
                    // Update Sales Rep with the new Account Owner's name
                    acc.Sales_Rep__c = ownerMap.get(acc.OwnerId).Name;
                }
            }
        }
    }
    public static void displayCountryOnContact(list<account> lstacc, map<id,account> oldmap){
        set<id> accid = new set<id>();
        list<contact> lstcon = new list<contact>();
        for(account acc : lstacc){
            if(acc.country__c != null && acc.country__c != oldmap.get(acc.id).country__c){
                accid.add(acc.id);
            }
        }
        for(account acc : [select id,name,country__c, (select id,name,Account_country__c from contacts)from account where id in : accid]){
            if(acc.contacts != null){
          
            for(contact con :acc.contacts){
                con.Account_country__c = acc.country__c;
                lstcon.add(con);
            }
            }
        }
        if(!lstcon.isempty()){
            update lstcon;
        }
    }
    public static void createContactsBasedOnLocation(list<account> lstacc){
        list<contact> conlist = new list<contact>();
        for(account acc : lstacc){
            if(acc.NumberofLocations__c != null && acc.NumberofLocations__c>0){
                for(integer i=0;i< acc.NumberofLocations__c;i++){
                    contact con= new contact();
                    con.lastname = 'contact'+i;
                    con.AccountId = acc.id;
                    conlist.add(con);
                }
            }
            
        }
            if(!conlist.isempty()){
                insert conlist;
            }
    }
}