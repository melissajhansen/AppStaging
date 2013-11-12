/*
        Name        :        CheckContact
        Author      :        
        Date        :        22nd August, 2013
        Decription  :        Trigger to check that only one contact cannot be registered for more than one cohort
*/
trigger CheckContact on Registration__c (before insert, before update) {

    Set<String> SetCohort = new Set<String>();
    
        for(Registration__c registration : Trigger.NEW){
            if(Trigger.isInsert){
                if(registration.Contact__c != null ){
                    SetCohort.add(registration.Cohort__c);
                }    
            }
            if(Trigger.isUpdate){               
                    if(registration.Contact__c != null && registration.Contact__c != Trigger.oldMap.get(registration.id).Contact__c){
                        SetCohort.add(registration.Cohort__c);
                }
            }
        }
    
    if(Trigger.isBefore){
        List<Registration__c> lstRegister = [Select id,Contact__c, Cohort__c from Registration__c where Cohort__c in : SetCohort];
        Set<String> conIdSet = new Set<String>();        
        for(Registration__c register : lstRegister){
            conIdSet.add(register.Contact__c);   
        }    
        
        for(Registration__c register : Trigger.NEW){
            if(SetCohort.contains(register.Cohort__c)){
                if(conIdSet.contains(register.Contact__c)){
                       Trigger.New[0].addError('Contact cannot be registered for more than one cohort');                       
                }            
            }        
        }
    }
}