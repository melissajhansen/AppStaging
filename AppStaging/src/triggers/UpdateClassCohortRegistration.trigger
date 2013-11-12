trigger UpdateClassCohortRegistration on Class_Attendee__c (after insert,after delete,after update) {
    Set<String>classSet=new Set<String>();
    Set<String>contactIds=new Set<String>();
    Set<String>cohortIds=new Set<String>();
    if(Trigger.isDelete){
        for(Class_Attendee__c attendee : Trigger.old){
            if(attendee.Class_Name__c!=null)
               classSet.add(attendee.Class_Name__c);
            if(attendee.Contact__c!=null)           
               contactIds.add(attendee.Contact__c);
        }
    }else{
        for(Class_Attendee__c attendee : Trigger.New){
            if(attendee.Contact__c!=null){           
               contactIds.add(attendee.Contact__c);
               if(Trigger.isUpdate && attendee.Contact__c != Trigger.oldmap.get(attendee.id).Contact__c){
                        if(Trigger.oldmap.get(attendee.id).Contact__c!=null){
                           contactIds.add(attendee.Contact__c);
                       } 
                    }
            }
            if(attendee.Class_Name__c!=null && attendee.Attended__c==true){
                 classSet.add(attendee.Class_Name__c);
                    if(Trigger.isUpdate && attendee.Class_Name__c != Trigger.oldmap.get(attendee.id).Class_Name__c){
                        if(Trigger.oldmap.get(attendee.id).Class_Name__c!=null){
                           classSet.add(Trigger.oldmap.get(attendee.id).Class_Name__c);
                       } 
                    }
              }
        }
    }
    
    if(classSet.size()>0){
        //Map<id,Class__c> classMap=new Map<id,Class__c>(select id,Count_of_Attendees__c from Class__c where id in : classSet);
       
        List<Class__c> classList=[Select Id,Count_of_Attendees__c,Cohort__c,(Select Id, Attended__c From Meeting_Attendees__r where Attended__c = true ) From Class__c where id in :classSet];
        for(Class__c cls : classList){
            cls.Count_of_Attendees__c=cls.Meeting_Attendees__r.size();  
           /* if(cls.Cohort__c != null){
                cohortIds.add(cls.Cohort__c);
            }   */       
        }
        update classList;
        
    }
    if(contactIds.size()>0){        
        Map<String,Contact> contactMap=new Map<String,Contact>([Select Id,(Select id,Class_Name__r.Cohort__c From Meeting_Attendees__r where  Attended__c= true ) From Contact where id in :contactIds]);
        List<Registration__c> regList=[select id,Contact__c,Count_of_Classes_Attended__c,Cohort__c from Registration__c where Contact__c in : contactIds];
        for(Registration__c reg : regList){
            integer count = 0;
            integer countgrdt  = 0;
            Contact con = contactMap.get(reg.Contact__c);
            if(con != null){
                for(Class_Attendee__c catt : con.Meeting_Attendees__r){
                    if(catt.Class_Name__r.Cohort__c == reg.Cohort__c){
                        count++;
                    }
                }                
            }
            if(reg.Cohort__c != null){
                cohortIds.add(reg.Cohort__c);
            }                         
            reg.Count_of_Classes_Attended__c=count;
        }
        update regList;
   
        //count cohort grdtuests..
        if(cohortIds.size()>0){
            List<Cohort__c> cohortlst = [select id,Number_of_Graduates__c,Number_with_Perfect_Attendance__c,(Select Count_of_Classes_Attended__c From Enrollments__r) from Cohort__c where id IN : cohortIds];            
            for(Cohort__c c : cohortlst){
                integer count = 0;
                integer countperfect = 0;
                if(c.Enrollments__r != null){                    
                    for(Registration__c rg : c.Enrollments__r){
                        if(rg.Count_of_Classes_Attended__c >=5)
                            count++;
                        if(rg.Count_of_Classes_Attended__c >=8)
                            countperfect++;
                    }                    
                }
                c.Number_of_Graduates__c = count;
                c.Number_with_Perfect_Attendance__c = countperfect;
            }
            if(cohortlst.size()>0)
                update cohortlst;
        }
        
    }
    
}