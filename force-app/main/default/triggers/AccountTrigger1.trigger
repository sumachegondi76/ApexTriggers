trigger AccountTrigger1 on Account (before insert,before update,before delete) {
    if(trigger.isbefore && (trigger.isinsert||trigger.isupdate)){
   AccountHandler1.preventDuplicatesByName(Trigger.new);
}
    if(trigger.isbefore && trigger.isdelete){
        AccountHandler1.preventAccountWithContact(trigger.old);
    }
}