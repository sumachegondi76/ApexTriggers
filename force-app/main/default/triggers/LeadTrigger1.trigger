trigger LeadTrigger1 on Lead (after insert) {
  if(trigger.isafter && trigger.isinsert){

LeadClass.CreateTaskOnLead(trigger.new);
}

}