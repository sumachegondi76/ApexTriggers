trigger Accounthandlertrigger on Account (after insert) {
    if(trigger.isafter){
         if(trigger.isinsert){
    
        Accounthandlertrigger.createContact(trigger.new);
         }    
}
}