/*
            Name        :        TestTriggerCheckContact
            Author      :
            Date        :        22nd August, 2013
            Description :        Test Class to test Trigger on Registration Object
    

*/
@isTest
public class TestTriggerCheckContact{

    @isTest
    private static void test(){
        Account Act = new Account(name='test', type = 'School');
        insert Act;
        
        Course__c course = new Course__c(name='testcourse',School_Name__c=Act.id);
        insert course;
        
        Cohort__c cohort = new Cohort__c(name='testCohort',Stand_UP_Course__c=course.id);
        insert cohort;
  
        Contact con1 = new Contact(lastname='testContact1');
        insert con1;
        
        Contact con2= new Contact(lastname='testContact2');
        insert con2;
                      
        Registration__c register = new Registration__c(cohort__c=cohort.id, contact__c=con1.id,Count_of_Classes_Attended__c = 1);
        insert register;
        
        List<Registration__c> lstRegister=[select id from Registration__c where id =: register.id];
        System.assertequals(lstRegister[0].id,register.id);        
       // List<Cohort__c> lstCohort = [select Attendees_Converted_to_Leaders__c from Cohort__c where id =: cohort.id];
       // System.assertequals(lstCohort[0].Attendees_Converted_to_Leaders__c, 0);        
        
        register.Contact__c=con2.id;
        update register;
          
        lstRegister=[select contact__c from Registration__c where id =: register.id];
        
        System.assertequals(lstRegister[0].contact__c,register.contact__c);        
        
        delete register;
    }
}