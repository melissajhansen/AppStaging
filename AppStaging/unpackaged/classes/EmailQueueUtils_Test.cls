@isTest
public class EmailQueueUtils_Test {

    public static TestMethod void TestNewTasksEmailQueueUtils() {
    	Profile objProfile = [Select Id from Profile where Name='System Administrator'];
    	// user to run New Tasks part of code in EmailQueueUtils
        User objUser = new User();
        objUser.Alias = 'User123';
        objUser.CommunityNickname = 'User123';
        objUser.Email = 'UserNewTasks@test.com';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.FirstName = 'UserNewTasks';
        objUser.LocaleSidKey = 'en_US';
        objUser.LastName = 'User';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.ProfileId = objProfile.Id;
        objUser.TimeZoneSidKey = 'America/Los_Angeles';
        objUser.UserName = 'EmailQueueUtilsNew@stand.org';
        objUser.Division = 'National';
        objUser.EmailNotificationOfTasks__c = true;
        objUser.EmailNotificationCC__c = 'rbowen@stand.org';
        insert objUser;

       	Contact objContactA = new Contact();
        objContactA.FirstName = 'EmailQueueUtils';
   	    objContactA.LastName = 'TestContact 1';
       	objContactA.Stand_Office__c = 'OR';
       	insert objContactA;
        	
       	// new task with a Contact
		Task t = new Task();
		t.OwnerId = objUser.Id;
		t.Subject = 'This is a test task 1';
		t.ActivityDate = System.today().addDays(-5);
		t.Status = 'Not Started';
		t.Priority = 'Normal';
		t.WhoId = objContactA.Id;
		insert t;

		// new task without a Contact
		t = new Task();
		t.OwnerId = objUser.Id;
		t.Subject = 'This is a test task 2';
		t.ActivityDate = System.today().addDays(-5);
		t.Status = 'Not Started';
		t.Priority = 'Normal';
		insert t;
			
		Test.startTest();
		EmailQueueUtils e = new EmailQueueUtils();
		e.sweepTasks();
		e.sweepEmailQueue();
		string sch = '0 0 * * 1-12 ? *';
		system.schedule('EmailQueueUtils Test',sch,e);
		Test.stopTest();
    }

    public static TestMethod void TestOverdueTasksEmailQueueUtils() {
    	Profile objProfile = [Select Id from Profile where Name='System Administrator'];
    	// user to run Overdue Tasks part of code in EmailQueueUtils
        User objUser = new User();
        objUser.Alias = 'User321';
        objUser.CommunityNickname = 'User321';
        objUser.Email = 'UserOverdueTasks@test.com';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.FirstName = 'UserOverdueTasks';
        objUser.LocaleSidKey = 'en_US';
        objUser.LastName = 'User';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.ProfileId = objProfile.Id;
        objUser.TimeZoneSidKey = 'America/Los_Angeles';
        objUser.UserName = 'EmailQueueUtilsUpd@stand.org';
        objUser.Division = 'National';
        objUser.EmailNotificationOfTasks__c = true;
        objUser.EmailNotificationCC__c = 'rbowen@stand.org';
        insert objUser;

       	Contact objContactA = new Contact();
        objContactA.FirstName = 'EmailQueueUtils';
   	    objContactA.LastName = 'TestContact 1';
       	objContactA.Stand_Office__c = 'OR';
       	insert objContactA;
        
        // overdue not started task with Contact
		Task t = new Task();
		t.OwnerId = objUser.Id;
		t.Subject = 'This is a test task 1';
		t.ActivityDate = System.today().addDays(-5);
		t.Status = 'Not Started';
		t.Priority = 'Normal';
		t.WhoId = objContactA.Id;
		insert t;

		// overdue not started task without Contact
		t = new Task();
		t.OwnerId = objUser.Id;
		t.Subject = 'This is a test task 1';
		t.ActivityDate = System.today().addDays(-5);
		t.Status = 'Not Started';
		t.Priority = 'Normal';
		insert t;
			
		Test.startTest();
		EmailQueueUtils e = new EmailQueueUtils();
		e.sweepTasks();
		e.sweepEmailQueue();
		string sch = '0 0 * * 1-12 ? *';
		system.schedule('EmailQueueUtils Test',sch,e);
		Test.stopTest();
    }

}