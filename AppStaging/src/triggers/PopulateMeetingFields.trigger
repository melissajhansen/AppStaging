trigger PopulateMeetingFields on Class__c (before insert, before update) {
    
    Set<ID> idProg = new Set<ID>();
    Map<ID, Cohort__c> idNameProg; 
    
     for(Integer i = 0; i < Trigger.size; i++){
         if(Trigger.new[i].Cohort__c != null){  
              idProg.add(Trigger.new[i].Cohort__c);
          }                   
     }
     if(!Test.isRunningtest()){   
          idNameProg = new Map<ID, Cohort__c>([Select Id, Name From Cohort__c Where Id IN :idProg]);     
          for(Integer i = 0; i < Trigger.size; i++){
                
              if(  Trigger.new[i].Cohort__c != null && 
                     !Trigger.new[i].Name.startsWith(idNameProg.get(Trigger.new[i].Cohort__c).Name)){
                       Trigger.new[i].Name = idNameProg.get(Trigger.new[i].Cohort__c).Name + ' - ' + Trigger.new[i].Name;     
                }                   
          }
    }
 }