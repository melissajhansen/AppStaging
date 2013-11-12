/*
        Name        :        TestTriggerPopulateAttendee
        Author      :        
        Date        :        22nd August, 2013
        Description :        Test Class to test trigger on Class_Attendee Object
*/
@isTest
public class TestTriggerPopulateAttendee{
    @isTest
    private static void test(){
        Account Act = new Account(Name='test1');
        Act.Type = 'School';
        insert Act;

        List<Contact> lstcon = new List<Contact>();
        Contact con1 = new Contact(lastname='testContact1');
        lstcon.add(con1);

        Contact con2= new Contact(lastname='testContact2');
        lstcon.add(con2);
        
        Contact con3= new Contact(lastname='testContact3');
        lstcon.add(con3);
        
        insert lstcon;

        Course__c course = new Course__c(name='testcourse',School_Name__c = Act.id);
        insert course;
        
        Cohort__c cohort = new Cohort__c(name='testCohort',Stand_UP_Course__c=course.id);
        insert cohort;

        List<Class__c> lstclass = new List<Class__c>();        
        Class__c clas1 = new Class__c(name='testclass1',cohort__c=cohort.id,Date_Time__c=Date.today());
        lstclass.add(clas1);
        
        Class__c clas2 = new Class__c(name='testclass2',cohort__c=cohort.id,Date_Time__c=Date.today());
        lstclass.add(clas2);
        insert lstclass;
        
        List<Class_Attendee__c> lstAttendee = new List<Class_Attendee__c>();
        Class_Attendee__c attendee1 = new Class_Attendee__c(Attended__c=true,Contact__c=con1.id,class_name__c=clas1.id);
        lstAttendee.add(attendee1);        
        Class_Attendee__c attendee2 = new Class_Attendee__c(Attended__c=true,Contact__c=con2.id,class_name__c=clas1.id);        
        lstAttendee.add(attendee2);    
        insert lstAttendee;
        
                
        attendee1.Contact__c = con2.Id;
        update attendee1; 
        
        delete attendee1;
        
        Cohort__c newCohort = new Cohort__c(id=cohort.id);
        //System.assertequals(newCohort.Number_of_Attendees__c , 2);    
        
    }
}