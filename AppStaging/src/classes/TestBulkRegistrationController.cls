/**
            Name           : TestBulkRegistrationController
            Author         : 
            Date           : 24/08/2013    
            Description    : This is test class for class BulkRegistrationController
*/
@isTest
public class TestBulkRegistrationController{
    @isTest
    public static void test(){
        Account Acc = new Account(name='test', type = 'School');
        insert Acc;
        
        Course__c course = new Course__c(name='testcourse',School_Name__c=Acc.id);
        insert course;
        
        Cohort__c cohort = new Cohort__c(name='testCohort',Stand_UP_Course__c=course.id);
        insert cohort;
        Contact con1 = new Contact(lastname='testContact1',LeadSource='Stand Up');
        insert con1;

        Contact con2= new Contact(lastname='testContact2',LeadSource='Stand Up');
        insert con2;
        Registration__c register = new Registration__c();
        register.cohort__c=cohort.id;
        register.contact__c=con1.id;
        insert register;
        ApexPages.currentPage().getparameters().put('id',cohort.id);
        BulkRegistrationController testObj=new BulkRegistrationController();
        testObj.selectedIndex=0;
        testObj.modelList[0].field='LastName';
        testObj.changeOperatorList();
        testObj.modelList[0].operator='startswith';
        testObj.modelList[0].value='t';
        testObj.modelList[1].field='LastName';
        testObj.changeOperatorList();
        testObj.modelList[1].operator='contains';
        testObj.modelList[1].value='es';
        testObj.modelList[2].field='none';
        testObj.modelList[3].field='none';
        testObj.modelList[4].field='none';
        testObj.filterContact();
        for(BulkRegistrationController.ContactModel cm : testObj.conList){
            cm.check=true;
        }
        System.assertequals(testObj.conList[0].con.lastname,'testContact2');
        testObj.aaTOCohort();
           
    }
}