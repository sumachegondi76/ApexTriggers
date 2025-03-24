public class AccountHandler1 {
  public static void accountRatingHot(List<account> newlist,map<id,account> oldmap)
  {
     
      set<id> accids = new set<id>();
      list<contact> lstcon = new list<contact>();
      for(account acc : newlist)
      {  
          if(acc.rating == 'Hot'&& acc.rating !=oldmap.get(acc.id).rating)
          {
            accids.add(acc.id);
        }
      }
    
          for(Account acc : [select id,rating,(select id,active__c from contacts)from account where id in :accids]){
              if(acc.contacts != null)
              {
                  for(contact con : acc.contacts){
                      con.Active__c = true;
                      lstcon.add(con);
                  }
              }
          }
          if(!lstcon.isempty()){
            update lstcon;
          }
             
          }  
      
    public static void createContactorOpp(list<account>lstacc){
        list<contact>lstcon =new list<contact>();
        list<opportunity> lstopp = new list<opportunity>();
        for(account acc : lstacc){
            if(acc.Contact__c){
                contact con = new contact();
                con.AccountId = acc.id;
                con.LastName = acc.name;
                lstcon.add(con);
           }
            if(acc.Opportunity__c && acc.Active__c == 'Yes'){
                
                opportunity opp = new opportunity();
                opp.AccountId = acc.id;
                opp.StageName = 'prospecting';
                opp.CloseDate = system.today();
                opp.Name = acc.Name;
                lstopp.add(opp);
                
            }
        }
        if(!lstopp.isempty()){
            insert lstopp;
        }
         if(!lstcon.isempty())
         {
            insert lstcon;
         
        }
    }
    public static void updateDescription(list<account> lstacc,map<id,account> oldmap){
        for(account acc : lstacc){
            if(oldmap != null && acc.phone != oldmap.get(acc.id).phone)
            {
                acc.Description = 'phone is updated!Old value'+oldmap.get(acc.id).phone+'newvalue '+acc.Phone;
            }
        }
    }
     public static void copyBilltoShip(list<account>lstacc,map<id,account>oldmap){
        for(account acc : lstacc){
            if((oldmap==null&&acc.CopyBillingToshipping__c)||(acc.CopyBillingToshipping__c &&!oldmap.get(acc.id).CopyBillingToshipping__c)){
            acc.ShippingCity = acc.BillingCity;
            acc.ShippingCountry = acc.BillingCountry;
            acc.ShippingPostalCode = acc.BillingPostalCode;
            acc.ShippingState = acc.BillingState;
            acc.ShippingStreet= acc.BillingStreet;
            }
        }
  }
    public static void updateindustryRating(list<account> lstacc,Map<id,account>oldmap)
    {
        for(account acc: lstacc){
            if(acc.Industry == 'Media' && acc.Industry != oldmap.get(acc.id).industry){
                acc.Rating = 'Hot';
            }
        }
    }
    public static void updateRelatedConts(list<account>lstacc,map<id,account>oldmap){
        list<contact>lstcon = new list<contact>();
        set<id>accids = new set<id>();
        for(account acc : lstacc){
            if(oldmap != null && acc.phone != oldmap.get(acc.id).phone){
                accids.add(acc.id);
            }
        }
        for(Account acc : [select id,phone, (select id,HomePhone from contacts)from account where id in : accids]){
            if(acc.contacts != null){
                for(contact con : acc.contacts){
                    con.HomePhone = acc.Phone;
                    lstcon.add(con);
                }
                
                }
            }
        if(!lstcon.isempty()){
             update lstcon;
        }
    }
    public static void updateContactsMailing(list<account> lstacc,map<id,account>oldmap){
        list<contact> lstcon = new list<contact>();
        set<id> accids = new set<id>();
        for(account acc : lstacc){
            if(oldmap != null && (acc.BillingCity != oldmap.get(acc.id).Billingcity)||(acc.BillingCountry != oldmap.get(acc.id).BillingCountry)||
                            (acc.BillingPostalCode != oldmap.get(acc.id).BillingPostalCode)||(acc.BillingState != oldmap.get(acc.id).BillingState)||
               (acc.BillingStreet != oldmap.get(acc.id).BillingStreet)){
                   accids.add(acc.id);
               }
        }
        for(account acc : [select id,Billingcity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,(select id from contacts)from account where id in : accids]){
            if(acc.contacts != null){
                for(contact con : acc.contacts){
                   con.MailingCity = acc.BillingCity;
                    con.MailingCountry = acc.BillingCountry;
                    con.MailingPostalCode = acc.BillingPostalCode;
                    con.MailingState = acc.BillingState;
                    con.MailingStreet = acc.BillingStreet;
                    lstcon.add(con);
                }
            }
        }
        if(!lstcon.isempty()){
            update lstcon;
        }
    }
    public static void updateOppStage(list<account> lstacc,map<id,Account>oldmap){
        list<opportunity> lstopp = new list<opportunity>();
        set<id> accids = new set<id>();
        for(account acc : lstacc){
            if(acc.Active__c == 'No'&& acc.Active__c != oldmap.get(acc.id).active__c){
                accids.add(acc.id);
                
            }
        }
        for(account acc :[select id,Active__c,(select id,stagename from opportunities)from account where id in : accids]){
            if(acc.opportunities != null){
                for(opportunity opp : acc.opportunities){
                    if(opp.stagename !='closed Won' && opp.Stagename != 'Closed Lost'){
                        opp.StageName = 'Closed Lost';
                        lstopp.add(opp);
                    }
                }
            }
        }
        if(!lstopp.isempty()){
            update lstopp;
        }
    }
    public static void preventDelActiveAcc(list<account> lstacc){
        for(account acc: lstacc){
            if(acc.Active__c == 'Yes'){
                acc.adderror('you cannot delete active accounts');
            }
        }
    }
    public static void preventEditAcc(list<account>lstacc){
        for(account acc : lstacc){
            if(acc.CreatedDate < system.today()-6){
                acc.adderror('you cannon edit the 7 days before record');
            }
        }
    }
    public static void checkProfileForDeletion(list<account> lstacc){
        profile pr = [select id from profile where name = 'system Administrator'];
        for(account acc : lstacc){
            if(userinfo.getProfileId() != pr.id){
                acc.adderror('only sysytem admin can delete account');
            }
        }
    }
    public static void preventDelHasRelatedOpp(list<account> lstacc){
        set<id> accid = new set<id>();
        for(account acc : lstacc){
            accid.add(acc.id);
        }
        for(account acc : [select id,(select id from opportunities)from account where id in : accid]){
            if(acc.opportunities.size()>0){
                acc.adderror('you cannot delete Account where opportunities are available');
            }
        }
    }
    public static void preventDelHasRelatedCase(list<account> lstacc){
        set<id> accid = new set<id>();
        for(account acc : lstacc){
            accid.add(acc.id);
        }
        for(account acc : [select id ,(select id from cases)from account where id in : accid]){
            if(acc.cases.size()>0){
                acc.adderror('you cannot delete Account where cases are available');
            }
        }
    }
    public static void shareAccWithStdUser(list<account> lstacc){
        id stduserid = [select id from profile where name = 'Standard user'].id;
        list<user> lstuser = [select id from user where profileId =:stduserid and isactive = true limit 1];
        list<accountshare> accShare = new list<accountshare>();
        for(account acc : lstacc){
          accountshare accsre = new accountshare();
            accsre.AccountId = acc.id;
            accsre.UserOrGroupId = lstuser[0].id;
            accsre.RowCause = 'Manual';
            accsre.AccountAccessLevel = 'Edit';
            accsre.OpportunityAccessLevel = 'Edit';
            accShare.add(accsre);
        }
        if(!accShare.isempty()){
            insert accShare;
        }
    }
    public static void updatedOwnerOfRelatedCon(list<account> lstacc,map<id,account>oldmap){
        list<contact> lstcon = new list<contact>();
        set<id> accids = new set<id>();
        for(account acc : lstacc){
            if(oldmap != null && acc.OwnerId != oldmap.get(acc.id).ownerid){
                accids.add(acc.id);
            }
        }
        for(Account acc : [select id,ownerid,(select id,ownerid from contacts)from account where id in : accids]){
            if(acc.contacts != null){
                for(contact con : acc.contacts){
                    con.OwnerId = acc.OwnerId;
                    lstcon.add(con);
                }
            }
        }
        if(!lstcon.isempty()){
            update lstcon;
        }
    }
    public static void updateratinghot(list<account> lstacc){
        for(account acc : lstacc){
            if(acc.Industry != null && acc.Industry == 'Media'){
                acc.Rating = 'Hot';
                
            }
        }
    }
    public static void updateAddress(list<account> lstacc){
        for(account acc : lstacc){
            if(acc.CopyBillingToshipping__c && acc.BillingCity != null && acc.BillingCountry != null && acc.BillingState != null && acc.BillingPostalCode != null && acc.BillingStreet != null){
                acc.ShippingCity = acc.BillingCity;
                acc.ShippingCountry = acc.BillingCountry;
                acc.ShippingState=acc.BillingState;
                acc.ShippingPostalCode = acc.BillingPostalCode;
                acc.ShippingStreet = acc.BillingStreet;
            }
        }
    }
    public static void createContact(list<account> lstacc){
        list<contact> lstcon = new list<contact>();
        for(account acc : lstacc){
              contact con = new contact();
               con.FirstName = acc.name;
               con.AccountId = acc.Id;
               con.LastName = acc.name;
               lstcon.add(con);
            
        }
        if(!lstcon.isempty()){
            insert lstcon;
        }
    }
    public static void preventHandler(list<Account> newRecord){
        Map<String,Id> newlist = new Map<String,Id>();
        list<String> oldLists = new list<String>();
        
        for(Account acc:newRecord){
            oldLists.add(acc.Name);
        }
        
        if(!oldLists.isempty()){
            for(Account acc:[select id,name from account where name in:oldLists]){
                newList.put(acc.Name,acc.Id);
            }
        }
        if(!newlist.isempty()){
            for(Account acc:newRecord){
                if(newlist.containsKey(acc.Name)){
                    acc.Adderror('Duplicate Account found with this' +acc.name);
                }
            }
        }
    }
    public static void preventDuplicatesByName(list<account> lstacc){
        set<string> NameSet = new set<string>();
        for(account acc:lstacc){
            if(acc.name != null){
                NameSet.add(acc.name);
            }
        }
        if(!NameSet.isEmpty()){
            map<string,id> existingName = new map<string,id>();
            for(account acc:[select id,name from account where name in : NameSet]){
                existingName.put(acc.name,acc.id);
            }
            for(account acc : lstacc){
                if(acc.name != null && existingName.containskey(acc.name)){
                    acc.adderror('duplicate account found');
                }
            } 
        }
    }
    public static void preventAccountWithContact(list<account> lstacc){
        set<id> accid = new set<id>();
        for(account acc:lstacc){
            accid.add(acc.id);
           
        }
        integer contactCount = [select count() from contact where accountid in:accid];
           if(contactCount > 0){
        for(account acc: lstacc){
         
                acc.adderror('you cannot delete this acccount');
            }
        }
    }
   }