public class MeetingAttendanceController {
    
    public class SelecTableAtendee {
        
        private Contact contact = null;
        private String reason = null;
        
        private Boolean selectedAttended = false;
        private Boolean selectedDrop = false;
        private ID id = null;
        
        public SelecTableAtendee(Contact con, ID id) {
            this.contact = con;  
            this.id = id;
        }
        
        public Contact getContact() {
            return contact;    
        }
        
        public void setContact(Contact con) {
            this.contact = con;
        }
        
        public String getReason() {
            return reason;
        }
        
        public void setReason(String reason) {
            this.reason = reason;
        }
        
        public Boolean getSelectedAttended() {
            return selectedAttended;
        }
        
        public void setSelectedAttended(Boolean s) {
            this.selectedAttended = s;
        }
        
        public Boolean getSelectedDrop() {
            return selectedDrop;
        }
        
        public void setSelectedDrop(Boolean s) {
            this.selectedDrop = s;
        }
        
        public ID getId() {
            return id;    
        }
    }
    
    public class MyException extends Exception {} 
        
    private List<SelecTableAtendee> listAttendees = null;
    private final ApexPages.StandardController theController;
    private Class__c meeting;
    private Map<ID, Class_Attendee__c> listExistMeetingAttendee = new Map<ID, Class_Attendee__c>(); // <Contact__c.Id,Meeting_Attendee__c>
    private Boolean validDateTime = True; 
    
    public MeetingAttendanceController(ApexPages.StandardController stdcontroller) {
            
        theController = stdController;
        meeting = [SELECT Id, Name, Cohort__c, Description__c,  Date__c, Date_Time__c FROM Class__c WHERE Id = :theController.getId()];
        if((meeting.Date__c) <= Date.today()){
        
            validDateTime = True;          
            List<Contact> contacts = [ Select Id, FirstName, LastName,Phone,Name From Contact where Id IN (Select Contact__c From Registration__c where Cohort__c = :meeting.Cohort__c) order By LastName];
            List<Contact> contactsDrop = [ Select Id, FirstName, LastName, Phone, Name From Contact where Id IN (Select Contact__c From Registration__c where Cohort__c = :meeting.Cohort__c)];
            for(Class_Attendee__c meet: [Select Id, Contact__c, Attended__c  From Class_Attendee__c WHERE Class_Name__c = :theController.getId()]){
                 listExistMeetingAttendee.put(meet.Contact__c, meet);            
            }                    
            if(contacts.size() > 0){                
                listAttendees = new List<SelecTableAtendee>();
                ID id;
                for (Contact contact : contacts) { // No Drop                    
                    SelecTableAtendee contactSelection;
                    if(!listExistMeetingAttendee.isEmpty() && listExistMeetingAttendee.containsKey(contact.Id)){
                        Class_Attendee__c meet = listExistMeetingAttendee.get(contact.Id);
                        contactSelection = new SelecTableAtendee(contact, meet.Id);
                        //contactSelection.setReason(meet.Reason_if_not_Attended__c);
                        contactSelection.setSelectedAttended(meet.Attended__c);
                    }else{
                        contactSelection = new SelecTableAtendee(contact, null);
                    }   
                    listAttendees.add(contactSelection);
                }
            }
                
            if(contacts.size() > 0){    
                for (Contact contact : contactsDrop) { // Drop              
                    SelecTableAtendee contactSelection;         
                    if(!listExistMeetingAttendee.isEmpty() && listExistMeetingAttendee.containsKey(contact.Id)){
                        Class_Attendee__c meet = listExistMeetingAttendee.get(contact.Id);
                        contactSelection = new SelecTableAtendee(contact, meet.Id);
                       // contactSelection.setReason(meet.Reason_if_not_Attended__c);
                        contactSelection.setSelectedAttended(meet.Attended__c);
                        contactSelection.setSelectedDrop(True);
 //--------------       listAttendees.add(contactSelection);
                    }               
                }
            }
        }else{
            validDateTime = False;
        }   
    }

    public Boolean getValidDateTime() {       
        return validDateTime;
    }
    
    public List<SelecTableAtendee> getListAttendees() {       
        return listAttendees;
    }
    
    public void setListContact(List<SelecTableAtendee> s) {
        listAttendees = s;
    }
    
    public Class__c getMeeting(){
        return meeting;
    }
    
    public PageReference SaveAttendance() {
        
        PageReference newPage = null;
        
        List<ID> enrollmentDropContact = new List<ID>();
        List<ID> enrollmentUndoDropContact = new List<ID>();
        List<Registration__c> enrollmentDrop = new List<Registration__c>();     

        List<Class_Attendee__c> newMeetingAttendee = new List<Class_Attendee__c>();
        List<Class_Attendee__c> upMeetingAttendee = new List<Class_Attendee__c>();
    
        Contact contact = null;
        Registration__c enrollment = null;
        
        try {
            
            for (SelecTableAtendee con: listAttendees){
                
                Class_Attendee__c newA, upA;                
                if(con.getId() <> null){                    
                    upA = new Class_Attendee__c(Id=con.getId());
                    
                   // upA.Reason_if_not_Attended__c = con.getReason();
                    upA.Class_Name__c = meeting.Id;
                    upA.Date__c = System.today();
                    upA.Contact__c = con.getContact().Id;
                    upA.Attended__c = con.getSelectedAttended();
                    
                    upMeetingAttendee.add(upA);
                }else{
                    newA = new Class_Attendee__c(
                                                   // Reason_if_not_Attended__c = con.getReason(),
                                                    Class_Name__c = meeting.Id,
                                                    Date__c = System.today(),
                                                    Contact__c = con.getContact().Id,
                                                    Attended__c = con.getSelectedAttended());
                    newMeetingAttendee.add(newA);
                }
         
                if(con.getSelectedDrop()){                  
                    enrollmentDropContact.add(con.getContact().Id);                 
                }else{
                    enrollmentUndoDropContact.add(con.getContact().Id);
                }
                
            }
           
            if(!newMeetingAttendee.isEmpty()){              
                insert newMeetingAttendee;
            }
            
            if(!upMeetingAttendee.isEmpty()){               
                update upMeetingAttendee;
            }
  
            Double NumberOfMeeting = 0; 
            Double NumberOfMeetingAttendees = 0;
            
            for(Class__c meet : [Select Id, ( Select Id From Meeting_Attendees__r Where Attended__c = true) From Class__c Where Cohort__c =:meeting.Cohort__c And Date_Time__c <=: Date.today()]){
                NumberOfMeeting += 1;
                NumberOfMeetingAttendees += meet.Meeting_Attendees__r.size();
            }   
            
            if(NumberOfMeeting > 0){  
                Cohort__c program = new Cohort__c(Id = meeting.Cohort__c);
                update program;  
            }
            
            newPage = null;
            
            String newPageUrl = '/'+ meeting.Id;
            newPage = new PageReference(newPageUrl);
            newPage.setRedirect(true);  
         }catch(System.Exception e){
            ApexPages.addMessages(e);
        }           
        return newPage;
    }
    
    static testMethod void MeetingAttendanceController_Test() {
        
        Account Acc = new Account(name='test', type = 'School');
        insert Acc;
        
        Course__c course = new Course__c(name='testcourse',School_Name__c=Acc.id);
        insert course;      
        
        Cohort__c pro1 = new Cohort__c(Name= 'Program1_Test', Stand_UP_Course__c=course.id);
        insert pro1;
  
        Class__c meeting1 = new Class__c(Name = 'Meeting1_Test', Cohort__c = pro1.Id, Date__c = Date.today());
        insert meeting1;

        Class__c meeting2 = new Class__c(Name = 'Meeting2_Test', Cohort__c = pro1.Id, Date__c = Date.today());
        insert meeting2;       
        
        Contact con1 = new Contact(LastName = 'Test1', FirstName = 'Contact1_Test');
        insert con1;
        
        Contact con2 = new Contact(LastName = 'Test2', FirstName = 'Contact2_Test');
        insert con2;
        
        Contact con3 = new Contact(LastName = 'Test3', FirstName = 'Contact3_Test');
        insert con3;
        
        Contact con4 = new Contact(LastName = 'Test4', FirstName = 'Contact4_Test');
        insert con4;
                
        Class_Attendee__c clsattendee1 = new Class_Attendee__c(Class_Name__c = meeting1.Id, Contact__c = con1.Id);
        insert clsattendee1;
        
        Class_Attendee__c clsattendee2 = new Class_Attendee__c(Class_Name__c = meeting2.Id, Contact__c = con2.Id);
        insert clsattendee2;
                         
        Registration__c enroll1 = new Registration__c( Contact__c = con1.Id, Cohort__c = pro1.Id);
        insert enroll1;
        
        Registration__c enroll2 = new Registration__c( Contact__c = con2.Id, Cohort__c = pro1.Id);
        insert enroll2;
                               
        ApexPages.StandardController sc = new ApexPages.StandardController(meeting1);
        MeetingAttendanceController controller = new MeetingAttendanceController(sc);   
        
        PageReference pageRef;
        SelecTableAtendee atendee;
        
        try{            
            atendee = controller.getListAttendees().get(0);
            atendee.setSelectedAttended(true);
            atendee.setReason('...');            
            pageRef = controller.SaveAttendance();
        }catch(Exception e){
            // Test the exception lines
        }
        
        try{            
            atendee = controller.getListAttendees().get(0);
            atendee.setSelectedAttended(false);
            atendee.setReason('');            
            pageRef = controller.SaveAttendance();
        }catch(Exception e){
            // Test the exception lines
        }
        
        try{            
            List<SelecTableAtendee> attendees = controller.getListAttendees();
            attendees.get(0).setSelectedAttended(false);
            attendees.get(0).setReason('...');
            attendees.get(0).setSelectedDrop(true);
            controller.setListContact(attendees);
            pageRef = controller.SaveAttendance();
        }catch(Exception e){
            // Test the exception lines
        }
        
        // Contact 1
        System.assertEquals(2,controller.getListAttendees().size());
        atendee = controller.getListAttendees().get(0);
        atendee.setSelectedAttended(true);
        controller.getListAttendees().add(0, atendee);
        
        // Contact 2
        atendee = controller.getListAttendees().get(1);
        atendee.setSelectedDrop(true);
        atendee.setReason('Test Reason');
        controller.getListAttendees().add(1, atendee);
        
        pageRef = controller.SaveAttendance();
        
        sc = new ApexPages.StandardController(meeting2);
        controller = new MeetingAttendanceController(sc);   
        
        // Meeting 2    
        atendee = controller.getListAttendees().get(0);
        atendee.setSelectedAttended(true);
        atendee.setContact(atendee.getContact());
        controller.getListAttendees().add(0, atendee);
        
        
        //Test extra lines
        controller.setListContact(controller.getListAttendees());
        controller.getMeeting();
        pageRef = controller.SaveAttendance();  
        
        // Meeting 1
        Registration__c enroll3 = new Registration__c( Contact__c = con3.Id, Cohort__c = pro1.Id);
         insert enroll3;
        
    /*    sc = new ApexPages.StandardController(meeting1);
        controller = new MeetingAttendanceController(sc);   
                
        System.assertEquals(3,controller.getListAttendees().size());
        atendee = controller.getListAttendees().get(0);
        atendee.setSelectedAttended(true);
        atendee.setContact(atendee.getContact());
        controller.getListAttendees().add(0, atendee);
        
        atendee = controller.getListAttendees().get(1);
        atendee.setSelectedDrop(true);
        atendee.setSelectedAttended(true);
        atendee.setContact(atendee.getContact());
        controller.getListAttendees().add(1, atendee);
        
        pageRef = controller.SaveAttendance();
        
        meeting1.Date_Time__c = Date.today();
        update meeting1;
        sc = new ApexPages.StandardController(meeting1);
        controller = new MeetingAttendanceController(sc);   
        
        
        meeting1.Date_Time__c = Date.today();
        update meeting1;
        
        sc = new ApexPages.StandardController(meeting1);
        controller = new MeetingAttendanceController(sc);        
        
        atendee = controller.getListAttendees().get(0);
        atendee.setSelectedDrop(true);
        atendee.setSelectedAttended(true);
        atendee = controller.getListAttendees().get(1);
        atendee.setSelectedDrop(true);
        atendee.setSelectedAttended(true);
        atendee = controller.getListAttendees().get(2);
        atendee.setSelectedDrop(true);
        atendee.setSelectedAttended(true);
        pageRef = controller.SaveAttendance();
        
        sc = new ApexPages.StandardController(meeting1);
        controller = new MeetingAttendanceController(sc);     */   
        
        atendee = controller.getListAttendees().get(0);
        atendee.setSelectedDrop(false);
        atendee.setSelectedAttended(true);
        atendee = controller.getListAttendees().get(1);
        atendee.setSelectedDrop(false);
        atendee.setSelectedAttended(true);
        atendee = controller.getListAttendees().get(2);
        atendee.setSelectedDrop(false);
        atendee.setSelectedAttended(true);
        pageRef = controller.SaveAttendance();
                
        controller.getValidDateTime();
        
    }
    
}