trigger AccountTrigger on Account (before insert,after insert,before update,after update,before delete,after undelete)
{
   if(trigger.isinsert)
   {
       if(trigger.isbefore)
   {
       AccountTriggerHandler.updaterating(trigger.new);
       AccountTriggerHandler.beforeInsert(trigger.new);
      // AccountTriggerHandler.handleUpdateSalesRep(trigger.new,null);
   }
       
           
       
   else if(trigger.isafter) 
   {
      // AccountTriggerHandler.createrelatedOpp(trigger.new);
       AccountTriggerHandler.createContacts(trigger.new);
      //    AccountTriggerHandler.handleInsert(Trigger.new, Trigger.oldMap);
         AccountTriggerHandler.clientOpp(Trigger.new);
       AccountTriggerHandler.sendNotification(Trigger.new,null);
       AccountTriggerHandler.createContactsBasedOnLocation(trigger.new);
   }
        else if(trigger.isafter) 
   {
       AccountTriggerHandler.addRelatedList(trigger.new);
     
   }
       
   }
    if(trigger.isupdate)
      {
       if(trigger.isbefore)
   {
       AccountTriggerHandler.updatePhoneDescription(trigger.new,trigger.oldmap);
     AccountTriggerHandler.handleUpdateSalesRep(trigger.new,trigger.oldMap);
    
   }
     if(trigger.isafter) 
   {
       AccountTriggerHandler.updateConWebsite(trigger.new,trigger.oldmap);
       AccountTriggerHandler.UpdateRelatedoppPhone(trigger.new,trigger.oldmap);
       AccountTriggerHandler.updateContacts(trigger.new,trigger.oldmap);
        AccountTriggerHandler.updateConAsync(trigger.new,trigger.oldmap);  
      //  AccountTriggerHandler.handleUpdate(Trigger.new, Trigger.oldMap);
      //AccountTriggerHandler.sendNotification(Trigger.new,Trigger.oldmap);
       AccountTriggerHandler.displayCountryOnContact(trigger.new,trigger.oldmap);
      
   }   
   
}
    if(trigger.isbefore && trigger.isdelete){
       
           // AccountTriggerHandler.preventDelAcc(trigger.old,trigger.oldmap);
        
    }
    if(trigger.isafter)
   {
       if(trigger.isundelete)
   {
       AccountTriggerHandler.restoreRecords(trigger.new);
   }
       
   }         
}