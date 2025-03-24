trigger OpportunityTrigger1 on Opportunity (before insert,before update) {
    
    if(Trigger.isbefore){
        if((Trigger.isinsert || Trigger.isupdate) && Trigger.isbefore){
            OpportunityHandler.preventOppClosed(trigger.new);
        }
    }
}