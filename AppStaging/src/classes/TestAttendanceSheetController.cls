@isTest
public class TestAttendanceSheetController{
    @isTest
    private static void test(){
        account acc = new account();
        acc.Type = 'School'; 
        acc.name='Test Account';
        insert acc;
        
        acc=[select id,name from account where id=:acc.id];
        system.assert(acc.id!=null);
        
        Course__c crs= new Course__c();
        crs.name='Test Course';
        crs.School_Name__c=acc.id;
        insert crs;
        
        crs=[select id,name from Course__c  where id=:crs.id];
        system.debug(crs.id!=null);
        
        Cohort__c chrt= new Cohort__c();
        chrt.name='Test Cohort';
        chrt.Stand_UP_Course__c=crs.id;
        insert chrt;
        
        chrt=[select id,name from  Cohort__c where id=:chrt.id];
        system.assert(chrt.id!=null);
        
        Class__c cls= new Class__c();
        cls.name='Test Class';
        cls.Date_Time__c=Date.today();
        cls.Cohort__c=chrt.id;
        insert cls;
        
        cls=[select id,name from Class__c where id=:cls.id];
        system.assert(cls.id!=null);
        
        ApexPages.currentPage().getParameters().put('id',cls.id);
        AttendanceSheetController attndsht= new AttendanceSheetController();
        
        
    }
}