trigger LeadTrigger on Lead (before update,after insert,before delete,before insert) {
    if(trigger.isbefore && trigger.isupdate){
LeadHelper.updateStatus(trigger.new);
    LeadHelper.PreventModification(trigger.new);    
}
    if(trigger.isafter && trigger.isinsert){
        LeadHelper.createTask(trigger.new);
    }
    if(trigger.isbefore && trigger.isdelete){
        LeadHelper.preventLeadDeletion(trigger.old);
    }
    if(trigger.isbefore &&(trigger.isinsert || trigger.isupdate)){
   LeadHelper.preventDuplicatesByEmail(trigger.new);
}
}