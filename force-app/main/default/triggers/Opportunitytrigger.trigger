trigger Opportunitytrigger on Opportunity (before delete,after insert,before insert,before update,after update,after delete,after undelete) {
 /* if(trigger.isbefore || trigger.isdelete)
  {
      OpportunityTriggerHandler.preventDeletionOfWonDeals(trigger.old);
  }*/
    if(trigger.isafter || trigger.isinsert)
    {
        //OpportunityTriggerHandler.orderCreatedIfClosedWon(trigger.new);
        
      
    }
    /*if(trigger.isbefore || trigger.isinsert)
    {
        OpportunityTriggerHandler.notmore1(trigger.new);
    }*/
    /*if(trigger.isafter)
    {
        if(trigger.isinsert){
            OpportunityTriggerHandler.poulateAmount(trigger.new);
        }
    }*/
   /* if(trigger.isbefore)
    {
        if(trigger.isupdate){
            OpportunityTriggerHandler.updateDesc(trigger.new,trigger.oldmap);
             
           
        }
    }*/
   if(trigger.isafter)
    {
        if(trigger.isupdate){
            //OpportunityTriggerHandler.createTask(trigger.new,trigger.oldmap);
 OpportunityTriggerHandler.addUserRoles(trigger.new,trigger.oldmap);
            //OpportunityTriggerHandler.sendEmailToOwner(trigger.new,trigger.oldmap);
            OpportunityTriggerHandler.sendEmailAlert(trigger.new);
        }
    }
       if(trigger.isbefore)
    {
        if(trigger.isinsert){
            //OpportunityTriggerHandler.validateAmount(trigger.new);
            //OpportunityTriggerHandler.validateCloseDate(trigger.new,null);
        }
    }
       if(trigger.isbefore)
    {
        if(trigger.isupdate){
           //OpportunityTriggerHandler.populateCloseReason(trigger.new,trigger.oldmap);
           // OpportunityTriggerHandler.updateAmount(trigger.new,trigger.oldmap);
           // OpportunityTriggerHandler.validateCloseDate(trigger.new,trigger.oldmap);
        }
    }
      if(trigger.isbefore)
    {
        if(trigger.isdelete){
           // OpportunityTriggerHandler.checkProfileForDeletion(trigger.old);
        }
    }
     if(trigger.isafter)
    {
        if(trigger.isinsert ||trigger.isupdate || trigger.isdelete || trigger.isundelete ){
            //OpportunityTriggerHandler.populateAmountOnAccount(trigger.new,trigger.oldmap);
            //OpportunityTriggerHandler.createTask(trigger.new);
          //OpportunityTriggerHandler.createTaskWhenStageChange(trigger.new,trigger.oldmap);
            //else if(trigger.isdelete)
            //OpportunityTriggerHandler.populateAmountOnAccount(trigger.old);
            //OpportunityTriggerHandler.updateAccountOpportunityAmount(trigger.new);
           // OpportunityTriggerHandler.updateAmountOnAccount(trigger.new,trigger.oldmap);
        }
        
    }
    
}