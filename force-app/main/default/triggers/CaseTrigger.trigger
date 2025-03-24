trigger CaseTrigger on Case (before insert,after insert,before delete) {
    if(trigger.isbefore){
        if(trigger.isinsert){
             system.debug('updateCaseTrigger');
            CaseTriggerHandler.updateCaseTrigger(trigger.new);
                system.debug('updatePriority');
            CaseTriggerHandler.updatePriority(trigger.new);
        
        }
    }
        //if(trigger.isafter){
           // CaseTriggerHandler.latestCaseNum(trigger.new);
        
    //}
    if(trigger.isbefore){
        if(trigger.isdelete){
        //    contactTriggerHandler.preventDeleteOtherUsers(trigger.old);
        }
    }
}