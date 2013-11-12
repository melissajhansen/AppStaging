/*
        Name        :        PopulateAttendee 
        Author      :
        Date        :        21st August, 2013
        Desciption  :        Trigger to populate Number of Attendee field with count of unique Contacts in Class_Attendee Object
*/

trigger PopulateAttendee on Class_Attendee__c (after insert,after update ) {
    Set<String> setClass = new Set<String>();
    
    for(Class_Attendee__c  attendee : Trigger.NEW){
        if(Trigger.isInsert){
            if(attendee.Class_Name__c != null && attendee.Attended__c == true){
                setClass.add(attendee.Class_Name__c);
            }
        }
        if(Trigger.isUpdate){
            if(attendee.Class_Name__c != null || attendee.Class_Name__c != Trigger.oldMap.get(attendee.id).Class_Name__c){
                setClass.add(attendee.Class_Name__c);
            }
        }
    }

    if(setClass.size() > 0){
        Map<String,Class__c> mapClass = new Map<String,Class__c> ([select id, Cohort__r.id from Class__c where id in : setClass]);
        Set<String> setCohort = new Set<String>();
        if(mapClass.size() > 0){
            for(Class__c clas : mapClass.values()){
                setCohort.add(clas.Cohort__r.id);
            }
            
            if(setCohort.size() > 0){    
         
                Map<String,Set<String>> mapContact = new Map<String,Set<String>>();            
                List<Class_Attendee__c> lstAttendee = [select id,class_name__r.cohort__c,contact__c from Class_Attendee__c where Attended__c = true and class_name__r.Cohort__c in : setCohort];                            

                for(Class_Attendee__c attendee : lstAttendee){
                    Set<String> tSet = mapContact.get(attendee.class_name__r.cohort__c);
                    if(tSet == null)
                        tSet=new Set<String>();
                    
                    tSet.add(attendee.contact__c);
                    mapContact.put(attendee.class_name__r.cohort__c, tSet);
                }
                List<Cohort__c> lstCohort = new List<Cohort__c>();
                for(String cohort : mapContact.keyset()){
                    Set<String> setContact=mapContact.get(cohort);
                    Cohort__c newCohort= new Cohort__c(id=cohort,Number_of_Attendees__c=setContact.size());
                    lstCohort.add(newCohort);
                }
                update lstCohort;
            }
        }  
    }      
}