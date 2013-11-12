public class AttendanceSheetController{
    public list<Class_Attendee__c> AttEmptyList{get;set;}
    public Class__c classDetail{get;set;}
    public List<Contact> contacts  {get;set;}
    
    public AttendanceSheetController(){
        Id classId = ApexPages.currentPage().getParameters().get('id');  
        classDetail = [select name, date__c,cohort__c, cohort__r.name from class__c where id =: classId limit 1];
        if(classDetail.Cohort__c != null){
             contacts = [ Select Id, FirstName, LastName,Phone,Is_Leader__c,Stand_Member__c,Membership_Start_Date__c,LiT_Start_Date__c    
                          From Contact
                          where Id IN (Select Contact__c From Registration__c where Cohort__c = :classDetail.Cohort__c) order by LastName ];
             System.debug('###contacts---'+ contacts.size());          
        }          
        AttEmptyList = new list<Class_Attendee__c>();
        AttEmptyList.add(new Class_Attendee__c());
        AttEmptyList.add(new Class_Attendee__c());
        AttEmptyList.add(new Class_Attendee__c());
        AttEmptyList.add(new Class_Attendee__c());
        AttEmptyList.add(new Class_Attendee__c());       
       
    }
}