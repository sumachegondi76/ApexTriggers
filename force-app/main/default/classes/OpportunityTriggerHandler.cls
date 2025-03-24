public class OpportunityTriggerHandler {
   public static void preventDeletionOfWonDeals(list<Opportunity> oppList)
   {
       for(Opportunity opp : oppList)
       {
           if(opp.StageName == 'Closed Won')
           {
               opp.adderror('you cannot delete won deals');
           }
       }
   }
    public static void orderCreatedIfClosedWon(list<Opportunity> oppList){
        list<order> ordList = new list<order>();
        for(Opportunity opp : oppList)
        {
            if(opp.StageName == 'Closed Won')
            {
                order ord = new order();
                ord.AccountId = opp.AccountId;
                ord.EffectiveDate = system.today();
                ord.Status = 'Draft';
                
                ordList.add(ord);
            }
            
        }
        insert ordList;
    }
    public static void notmore1(list<opportunity> lstopp){
      set<id> accid = new set<id>();
        for(opportunity opp : lstopp){
            if(opp.accountid != null){
                accid.add(opp.accountid);
            }
        }
        list<account> lstacc = [select id,name ,(select id, name from opportunities) from account where id in : accid];
        map<id,integer> accmap = new map<id,integer>();
        for(account acc : lstacc){
            list<opportunity> opplist = acc.opportunities;
            accmap.put(acc.id,opplist.size());
        }
        for(opportunity opp : lstopp){
            id parentid = opp.AccountId;
            if(parentid != null){
                integer count = accmap.get(parentid);
                if(count >= 1){
            opp.adderror('not more than one opportunity');
        
            }
        }
        
        }
    }
    public static void poulateAmount(list<opportunity>opplist){
        list<account> lstacc = new list<account>();
        for(opportunity opp : opplist){
            account acc =new account();
            acc.id = opp.AccountId;
            acc.RecentOppAmount__c =opp.Amount;
            lstacc.add(acc);
        }
        if(!lstacc.isempty()){
            update lstacc;
        }
    }
    public static void updateDesc(list<opportunity> lstopp,map<id,opportunity>oldmap){
        for(opportunity opp : lstopp){
            if(oldmap != null && opp.StageName != oldmap.get(opp.id).stagename)
            {
                if(opp.StageName == 'Closed Won'){
                    opp.Description = 'opportunitty is closed won';
                }
                else if(opp.StageName == 'Closed Lost'){
                    opp.Description = 'opportunitty is closed lost';
                }
                else{
                    opp.Description = 'opportunitty is open';
                }
            }
        }
    }
    public static void createTask(list<opportunity>lstopp,map<id,opportunity>oldmap){
        list<task> lsttask = new list<task>();
        for(opportunity opp : lstopp){
            if(opp.StageName != oldmap.get(opp.id).stagename){
                task ta = new task();
                ta.WhatId = opp.id;
                ta.Status = 'Not Started';
                ta.Priority = 'Normal';
                ta.Subject = 'Email';
                ta.OwnerId = UserInfo.getUserId();
                
                    lsttask.add(ta);
            }
        }
        if(!lsttask.isempty()){
            update lsttask;
        }
    }
    public static void validateAmount(list<opportunity> lstopp){
        for(opportunity opp : lstopp){
            if(opp.amount == null){
                opp.adderror('amount cannot be null');
            }
        }
    }
    public static void populateCloseReason(list<opportunity> lstopp,map<id,opportunity> oldmap){
        for(opportunity opp : lstopp){
            if(opp.StageName == 'Closed Lost'&& opp.StageName != oldmap.get(opp.id).stagename && opp.Closed_Lost_reason__c == null){
                opp.adderror('please populate closed lost reason');
            }
        }
    }
    public static void checkProfileForDeletion(list<opportunity> lstopp){
        profile pr = [select id from profile where name = 'system Administrator'];
        for(opportunity opp : lstopp){
            if(opp.StageName == 'Closed Won'|| opp.StageName == 'Closed Lost'){
                if(userinfo.getProfileId() != pr.id){
                    opp.adderror('only system admin can delete this record');
                }
            }
        }
    }
    public static void populateAmountOnAccount(list<opportunity> opplist,map<id,opportunity>oldmap){
        set<id> accids = new set<id>();
        for(opportunity opp : opplist){
            if(oldmap != null){
                if(opp.AccountId != null && opp.amount != null && opp.amount != oldmap.get(opp.id).amount){
                   accids.add(opp.AccountId); 
                }
            }
            else{
                if(opp.AccountId != null && opp.amount != null){
                    accids.add(opp.AccountId);  
                }
                   
            }
        }
      
    
    list<account> acclist = [select id,annualrevenue,(select id,amount from opportunities)from account where id in : accids];
        if(!acclist.isempty()){
        for(account acc : acclist){
            decimal total = 0;
            for(opportunity opp : acc.opportunities){
                total = total+opp.Amount;
            }
            acc.AnnualRevenue = total;
        }

        }
    if(!acclist.isEmpty()){
        update acclist;
    }
}
    public static void updatehotopp(list<opportunity> lstopp){
        for(opportunity opp : lstopp){
            if(opp.Amount != null && opp.Amount > 100000){
                opp.Description = 'Hot Opportunity';
            }
        } 
    }
    public static void populateAmount(list<Opportunity> lstopp){
        list<account> lstacc =new list<account>();
        for(opportunity opp : lstopp){
            account acc = new account();
            acc.RecentOppAmount__c = opp.Amount;
            acc.id = opp.AccountId;
            lstacc.add(acc);
        }
    
    if(!lstacc.isempty()){
         update lstacc;
    }
   
    } 
    public static void createTask(list<opportunity> lstopp){
        list<Task> lsttask = new list<task>();
        list<id> lstid = new list<id>();
        list<OpportunityTeamMember> deleterecs = new list<OpportunityTeamMember>();
        for(opportunity oppo: lstopp){
            lstid.add(oppo.id);
        }
        list<OpportunityTeamMember> teammember = [select id,opportunityid from OpportunityTeamMember where opportunityid in:lstid];
        for(opportunity opp : lstopp){
            if(opp.StageName == 'Closed Won'){
                task ta = new task();
                ta.OwnerId = opp.OwnerId;
                ta.Priority = 'High';
                ta.Description = 'please split amount amongst the team members';
                ta.Status = 'Not Started';
                ta.Subject = 'Split revenue';
                ta.WhatId = opp.Id;
                lsttask.add(ta);
            }
            else if(opp.StageName == 'Closed Lost'){
                for(OpportunityTeamMember oppmem :teammember){
                    if(oppmem.opportunityid == opp.id){
                    deleterecs.add(oppmem);
                }
                }
            }
        }
        if(!lsttask.isempty()){
            insert lsttask;
        }
        if(!deleterecs.isempty()){
            delete deleterecs;
        }
    }
    public static void updateAmount(list<opportunity> lstopp,Map<Id,opportunity> oldmap){
        for(opportunity opp : lstopp){
            if(opp.StageName != oldmap.get(opp.id).StageName){
                opp.Amount= opp.Probability * opp.ExpectedRevenue;
            }
        }
    }
    
    public static void addUserRoles(list<opportunity> lstopp, map<id,opportunity> oldmap){
        list<opportunityTeamMember> opplist = new list<opportunityTeamMember>();
        list<user> lstuser = [select id, UserRole.Name from user where isActive = true And UserRole.Name = 'opportunists'];
        for(opportunity opp : lstopp){
            if(opp.StageName == 'Needs Analysis' && opp.StageName != oldmap.get(opp.id).StageName){
                for(user us : lstuser){
                    OpportunityTeamMember oppteam = new OpportunityTeamMember();
                    oppteam.opportunityId = opp.id;
                    oppteam.OpportunityAccessLevel = 'Edit';
                    oppteam.UserId = us.id;
                    opplist.add(oppteam);
                }
            }
        }
        if(!opplist.isempty()){
            insert opplist;
        }
    }
    public static void createTaskWhenStageChange(list<opportunity> lstopp,map<id,opportunity> oldmap){
        list<task> tasklist = new list<task>();
        for(opportunity opp : lstopp){
            if(opp.stageName != oldmap.get(opp.id).StageName){
                if(opp.StageName == 'Qualification' && oldmap.get(opp.id).StageName == 'Perception Analysis'||opp.StageName == 'Prospecting' && oldmap.get(opp.id).StageName == 'Perception Analysis'){
                    Task ta = new Task();
                    ta.Priority = 'High';
                    ta.WhatId = opp.id;
                    ta.ReminderDateTime = system.today()+1;
                    ta.IsReminderSet = true;
                    tasklist.add(ta);
                }
            }
        }
        if(!tasklist.isempty()){
            insert tasklist;
        }
    }
   
   
  public static void validateCloseDate(List<Opportunity> opps,map<id,Opportunity> oldmap) {
        for(Opportunity opp : opps) {
       
            
            if((oldmap == null )|| (opp.CloseDate != oldmap.get(opp.id).CloseDate)){
              if(opp.CloseDate != null && opp.CloseDate < Date.today().addDays(-30))
              {
                opp.addError('Close Date cannot be more than 30 days in the past.');
            }
                 }
            
        }
    }

  

    
    public static void sendEmailToOwner(List<Opportunity> lstopp,map<id,opportunity> oldmap){
        set<id> closedId = new set<Id>();
        for(opportunity opp : lstopp){
            if(opp.StageName == 'Closed Won' && opp.StageName != oldmap.get(opp.id).StageName){
                closedId.add(opp.id);
            }
                
        }
        if(!closedId.isempty()){
            handleClosedWonOpportunities(closedId);
        }                           
            }
    
   @future
    public static void handleClosedWonOpportunities(Set<Id> opportunityIds) {
        // Query the necessary fields from the Opportunity
        List<Opportunity> opportunities = [SELECT Id, Name, CloseDate, Amount, OwnerId, Owner.Email
                                          FROM Opportunity
                                          WHERE Id IN :opportunityIds
                                          AND StageName = 'Closed Won'
                                          LIMIT 200];

        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

        for (Opportunity opp : opportunities) {
            // Create the email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{opp.Owner.Email});
            email.setSubject('Opportunity Closed-Won Notification: ' + opp.Name);

            // Include Opportunity details in the email body
            String emailBody = 'Opportunity Name: ' + opp.Name + '\n' +
                               'Close Date: ' + opp.CloseDate + '\n' +
                               'Amount: $' + opp.Amount + '\n' +
                               'Opportunity Link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id;

            email.setPlainTextBody(emailBody);
            emailMessages.add(email);
        }

        // Send the email messages
        if (!emailMessages.isEmpty()) {
            Messaging.sendEmail(emailMessages);
        }
    }
    /*public static void updateOppAmountOnAccount(list<opportunity> lstopp,map<id,opportunity> oldmap){
        set<id> accid = new set<id>();
        map<id,list<opportunity>> accoppmap = new map<id,list<opportunity>>();
        for(opportunity opp : lstopp){
            if(opp.accountid != null){
                accid.add(opp.AccountId);
                if(!accoppmap.containskey(opp.AccountId)){
                    accoppmap.put(opp.AccountId,new list<opportunity>());
                }
                accoppmap.get(opp.AccountId).add(opp);
            }
        }
        list<account> accountsToUpdate = [select id,Total_opportunities__c from account where id in : accid];
        for(account acc : accountsToUpdate){
            list<opportunity> opplist = accoppmap.get(acc.id);
            Decimal totalOppAmount = 0;
            
            for(opportunity opp : opplist){
                if(opp.Amount != null){
                    totalOppAmount += opp.Amount;
                }
            }
            acc.Total_opportunities__c = totalOppAmount;
        }
        update accountsToUpdate; 
    }*/
    
    public static void updateAccountOpportunityAmount(List<Opportunity> oppList) {
        Set<Id> accountIdsToUpdate = new Set<Id>();
        Map<Id, Decimal> accountTotalAmountMap = new Map<Id, Decimal>();

        for (Opportunity opp : oppList) {
            if (opp.AccountId != null && opp.Amount != null) {
                accountIdsToUpdate.add(opp.AccountId);
                if (!accountTotalAmountMap.containsKey(opp.AccountId)) {
                    accountTotalAmountMap.put(opp.AccountId, 0);
                }
                accountTotalAmountMap.put(opp.AccountId, accountTotalAmountMap.get(opp.AccountId) + opp.Amount);
            }
        }

        List<Account> accountsToUpdate = [SELECT Id, Total_opportunities__c FROM Account WHERE Id IN :accountIdsToUpdate];
        for (Account acc : accountsToUpdate) {
            if (accountTotalAmountMap.containsKey(acc.Id)) {
                acc.Total_opportunities__c = accountTotalAmountMap.get(acc.Id);
            }
        }

        update accountsToUpdate;
    }
    public static void updateAmountOnAccount(list<opportunity> newopps,map<id,opportunity> oldmapopps){
        set<id> accountids = new set<id>();
        if(newopps != null){
            for(opportunity opp:newopps){
                if(opp.AccountId != null){
                    accountids.add(opp.AccountId);
                }
            }
        }
        if(oldmapopps != null){
            for(opportunity opp:oldmapopps.values()){
                if(opp.AccountId != null){
                    accountids.add(opp.AccountId);
                }
            }
        }
        if(!accountids.isempty()){
            map<id,decimal> TotalAmountOnAccount = new map<id,decimal>();
            for(aggregateresult ar:[select accountid,sum(amount)totalamount from opportunity where accountid in: accountids group by accountid]){
                TotalAmountOnAccount.put((id)ar.get('accountid'),(decimal)ar.get('totalamount'));
            }
            list<account> accountsToUpdate = new list<account>();
            for(Id accid : accountids){
                account acc = new account(id=accid);
                acc.annualrevenue = TotalAmountOnAccount.containskey(acc.id)?TotalAmountOnAccount.get(acc.id):0;
                accountsToUpdate.add(acc);
            }
            
        
        if(!accountsToUpdate.isempty()){
            update accountsToUpdate;
        }
        }
    }
    public static void sendEmailAlert(list<opportunity> lstopp){
        list<Messaging.SingleEmailMessage> lstemail = new list<Messaging.SingleEmailMessage>();
        for(opportunity opp : lstopp){
            if(opp.StageName == 'Closed Lost'){
                messaging.singleemailmessage email= new messaging.singleemailmessage();
                email.settoaddresses(new string[]{'sumachegondi76@gmail.com'});
                email.setsubject('opportunity lost:'+opp.name);
                email.setplaintextbody('This opportunity is closed lost'+opp.name);
                lstemail.add(email);
            }
        }
        if(!lstemail.isempty()){
            messaging.sendemail(lstemail);
        }
    }
}