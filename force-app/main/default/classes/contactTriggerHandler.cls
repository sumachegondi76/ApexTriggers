public class contactTriggerHandler {
   public static void countContacts(list<contact> newcontact,list<contact> oldcontact)
   {
       set<id> conAccIds = new set<id>();
       
       try{
           if(newcontact != null){
               for(contact con : newcontact){
                   if(con.accountid != null){
                      conAccIds.add(con.accountid); 
                   }
                           }
           }
           if(oldcontact != null){
               for(contact con : oldcontact){
                   if(con.accountid != null){
                       conAccIds.add(con.accountid);
                   }
               }
           }
           list<account> acclist = [select id,contact_count__c,(select id from contacts)from account where id in : conAccIds];
           
           if(acclist != null){
               for(account acc:acclist){
                   acc.contact_count__c = acc.contacts.size();
               }
           }
           if(acclist.isEmpty()){
               update acclist;
           }
       }
       catch(exception ex){
           system.debug('get message'+ex.getMessage());
       }
   }
  /*  public static void notExceedlimit(list<contact> lstcon)
    {
        
        
       integer contactcount = [select count() from contact];
        if(contactcount > 50){
            for(contact con : lstcon){
                con.adderror('cannot have more than 50 contacts');
            }
        }
      
    }*/
    
    public static void notMore1(list<contact> conlist)
    {
        set<id> accid = new set<id>();
        for(contact con : conlist){
            if(con.accountid != null){
                accid.add(con.accountid);
            }
        }
        list<account> lstacc = [select id,name,(select id from contacts) from account where id in : accid];
        map<id,integer> accmap = new map<id,integer>();
        
        for(account acc : lstacc){
            list<contact> lstcon = acc.contacts;
            accmap.put(acc.id,lstcon.size());
        }
        for(contact c : conlist){
            id parentid = c.AccountId;
            if(parentid != null){
                integer count = accmap.get(parentid);
                if(count >= 1){
                    c.adderror('NOT MORE THAN ONE CONTACT');
                }
            }
        }
    }
    public static void countingmethod(list<contact> lstcon, Boolean suretodelete)
    {
        map<id,list<contact>> mapofContacts = new map<id,list<contact>>();
        for(contact con : lstcon){
            if(con.accountid != null){
                if(!mapofContacts.containskey(con.accountid)){
                    mapofContacts.put(con.accountid,new list<contact>());
                }
                mapofContacts.get(con.accountid).add(con);
            }
        }
        if(mapofContacts.size()>0){
            list<account> lstacc = [select id,name,contact_count__c from account where id in : mapofContacts.keyset()];
            for(account acc : lstacc){
                if(acc.contact_count__c == null){
                    acc.contact_count__c = mapofContacts.get(acc.id).size();
                }
                else if(suretodelete){
                    acc.contact_count__c = acc.contact_count__c - mapofContacts.get(acc.id).size();
                }
                else{
                    acc.contact_count__c = acc.contact_count__c + mapofContacts.get(acc.id).size();
                }
                
            }
            update lstacc;
        }
    }
    public static void associateAccount(list<contact> lstcon){
        for(contact con : lstcon){
            if(con.AccountId == null){
                con.adderror('contact should be assoociated with account');
            }
        }
    }
    public static void preventMatchingRecords(list<contact> lstcon){
        list<contact> existingrds = [select id,Phone,Email,LastName from contact limit 50000];
        for(contact con:lstcon){
            for(contact excon : existingrds){
            if(con.Phone == excon.Phone && con.Email == excon.Email && con.LastName == excon.LastName){
                con.adderror('Duplicates found');
            }
}
        }
    }
     public static void shareRecord(list<contact> lstcon){
        list<contactshare> lstshre = new list<contactshare>();
        id coninnoPubGrp = [select id,name from Group where name='Contact innovators' limit 1].id;
        for(contact con:lstcon){
            contactshare consre = new contactshare();
            consre.ContactAccessLevel='Edit';
            consre.contactid= con.id;
            consre.rowcause = 'Manual';
            consre.userorGroupId = coninnoPubGrp;
            lstshre.add(consre);
        }
        if(!lstshre.isempty()){
            insert lstshre;
          }
    }
    public static void checkduplicates(list<contact> lstcon,map<id,contact> oldmap){
        list<contact> conlist = [select id,firstname,lastname,email,phone from contact where (email != null or phone !=null)];
        map<string,contact> emailmap = new map<string,contact>();
        map<string,contact> phonemap = new map<string,contact>();
        
        for(contact con : conlist){
            emailmap.put(con.Email,con);
            phonemap.put(con.Phone,con);
        }
        for(contact con: lstcon){
            if((con.email != null && emailmap.containsKey(con.Email))||
               (con.email != null && emailmap.containsKey(con.Email)&&con.Email != oldmap.get(con.id).Email)){
                con.Email.adderror('duplicate email found');
            }
        
        if((con.Phone != null && phonemap.containsKey(con.Phone))||
            (con.Phone != null && phonemap.containsKey(con.Phone) && con.Phone != oldmap.get(con.id).phone)){
                con.Phone.adderror('duplicate phone found');
            } 
        }
    }
            public static void contactCountOnAccount(list<contact> lstcon)   
            {
                set<id> accid = new set<id>();
                for(contact con:lstcon){
                    if(con.accountid !=null){
                        accid.add(con.AccountId);
                    }
                }
                list<account> lstacc = [select id,name,contact_count__c ,(select id from contacts)from account];
                for(account acc : lstacc){
                    acc.contact_count__c = acc.contacts.size();
                }
                update lstacc;
            }
    public static void handleMainContactField(list<contact> conlist,map<id,contact> oldmap){
        set<id> idset = new set<id>();
        for(contact con:conlist){
            if((oldmap == null || oldmap.get(con.id).Main_Contact__c != con.Main_Contact__c)&&con.Main_Contact__c){
                idset.add(con.AccountId);
            }
        }
        list<contact> lstcon = [select id,accountid,Main_Contact__c from contact where AccountId in : idset and Main_Contact__c = true];
        if(lstcon.size()>0){
            for(contact con:conlist){
                if(con.Main_Contact__c){
                    con.adderror('you already have 1 main contact for this account');
                }
            }
        }
    }
    
    public static void preventInsertionMethod(list<contact> newRecord){
        set<id> accountIds = new set<id>();
        if(!newRecord.isEmpty()){
            for(contact con:newRecord){
                if(con.AccountId != null){
                    accountIds.add(con.AccountId);
                }
            }
        }
        Map<id,Integer> contactCounts = new Map<id,integer>();
        if(!accountIds.isempty()){
            for(AggregateResult aggre:[select count(id) TotalCount,AccountId from contact where AccountId in:accountIds group by AccountId]){
                contactCounts.put((Id)aggre.get('AccountId'),(integer)aggre.get('TotalCount'));
            }
        }
        for(Contact con:newRecord){
            if(con.AccountId != null && contactCounts.containsKey(con.AccountId)&&contactCounts.get(con.AccountId)>=2){
                con.Adderror('cannot insert record. The limit of 2 contacts per Account has been reached.');
            }
        }
    }
    public static void updateIndustryAccount(list<contact> lstcon){
        set<id>accid = new set<id>();
        for(contact con : lstcon){
            if(con.accountid != null){
                accid.add(con.accountid);
            }
        }
        map<id,account> accountmap = new map<id,account>([select id,industry from account where id in:accid]);
        for(contact con:lstcon){
            if(con.accountid != null && accountmap.containskey(con.AccountId)){
                con.Industry__c = accountmap.get(con.AccountId).industry;
            }
        }
    }
    public static void updateAccountMailingAddress(list<contact> lstcon){
        set<id> accid = new set<id>();
        for(contact con:lstcon){
            if(con.accountid != null){
                accid.add(con.accountid);
            }
        }
        map<id,account> accountmap = new map<id,account>([select id,BillingCountry,billingcity,billingstate,billingpostalcode,billingstreet from account where id in:accid]);
        for(contact con:lstcon){
            if(con.accountid != null && accountmap.containskey(con.accountid)){
                account acc = accountmap.get(con.accountid);
                con.MailingCountry = acc.BillingCountry;
                con.MailingCity=acc.BillingCity;
                con.MailingPostalCode = acc.BillingPostalCode;
                con.Mailingstreet = acc.BillingStreet;
                con.MailingState = acc.BillingState;
                
            }
                
        }
    }
    public static void countContactsOnAccount(list<contact> lstcon,map<id,contact>oldmap){
        set<id> accids = new set<id>();
        if(lstcon != null){
            for(contact con : lstcon){
                if(con.AccountId != null){
                    accids.add(con.accountid);
                }
            }
        }
        if(oldmap != null){
            for(contact con : oldmap.values()){
                if(con.AccountId != null){
                    accids.add(con.accountid);
                }
            }
        }
        Map<Id,Account> updateToAccount = new map<Id,Account>([select id, Total_contacts__c from account where id in : accids]);
        for(id accid : accids){
            integer count = [select count() from contact where accountid =: accid];
            if(updateToAccount.containskey(accid)){
                updateToAccount.get(accid).Total_contacts__c=count;
                
            }
        }
        if(!updateToAccount.isempty()){
            update updateToAccount.values();
        }
    }
           }