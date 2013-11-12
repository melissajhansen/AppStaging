/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *

 */
@isTest
private class TaskUtil_Test {

    static testMethod void NewStaffTask_Test() {
        // create base objects
		DateTime dt = System.now ();
		Date mDate = date.newInstance ( dt.year(), dt.month(), dt.day() );
		
		//Get IDs for Role and Profile
		UserRole objRole = [Select Id from UserRole where Name='MA Staff'];
		Profile objProfile = [Select Id from Profile where Name='Development Users VIP'];
		
       // ------ User A -------------
        User objUserA = new User();
        objUserA.FirstName = 'TestUserA';
        objUserA.LastName = 'TestUserA';
        objUserA.Alias = 'UserA';
        objUserA.Email = 'UserA@UserA.com';
        objUserA.Username = 'UserA@UserA.com';
        objUserA.CommunityNickname = 'TestUserA';
        objUserA.UserRoleID = objRole.ID;
        objUserA.IsActive = true;
        objUserA.ProfileId = objProfile.ID;
        objUserA.EmailEncodingKey = 'UTF-8';
        objUserA.TimeZoneSidKey = 'America/Los_Angeles';
        objUserA.LanguageLocaleKey = 'en_US';
        objUserA.LocaleSidKey = 'en_US';
        objUserA.Division = 'MA';
        Insert objUserA;
        
       
        // ------ User B -------------
        User objUserB = new User();
        objUserB.FirstName = 'TestUserB';
        objUserB.LastName = 'TestUserB';
        objUserB.Alias = 'UserB';
        objUserB.Email = 'UserB@UserB.com';
        objUserB.Username = 'UserB@UserB.com';
        objUserB.CommunityNickname = 'TestUserB';
        objUserB.UserRoleID = objRole.ID;
        objUserB.IsActive = true;
        objUserB.ProfileId = objProfile.ID;
        objUserB.EmailEncodingKey = 'UTF-8';
        objUserB.TimeZoneSidKey = 'America/Los_Angeles';
        objUserB.LanguageLocaleKey = 'en_US';
        objUserB.LocaleSidKey = 'en_US';
        objUserB.Division = 'MA';
        objUserB.Default_Task_Assignee__c = objUserA.ID;
        Insert objUserB;
        
	    system.runas(objUserB){
	        
	        // ------ Contact 1 -------------
	        Contact objContact1 = new Contact();
	        objContact1.FirstName = 'Test';
	        objContact1.LastName = 'Contact';
	        objContact1.Acquired_By__c = 'C3 Acquired';
	        objContact1.LeadSource = 'Donor';
	        objContact1.Stand_Office__c = 'MA';
	        Insert objContact1;
	        
	        // ------ Contact 2 -------------
	        Contact objContact2 = new Contact();
	        objContact2.FirstName = 'Test';
	        objContact2.LastName = 'Contact';
	       	objContact2.Acquired_By__c = 'C3 Acquired';
	        objContact2.LeadSource = 'Donor';
	        objContact2.Stand_Office__c = 'MA';
	        Insert objContact2;
	        
	        // -------Task 1 Incomplete to Start-----------------
	        Task objTask1 = new Task();
	        objTask1.OwnerId = objUserB.ID;
	        objTask1.RecordTypeID = '012E0000000MEz4';
	       	objTask1.Subject = 'Solicitation';
			objTask1.Type = 'Other';
			objTask1.WhoId = objContact1.ID;
			objTask1.ActivityDate = mDate;
			objTask1.Status = 'Not Started';
			objTask1.Outcomes__c = 'Sample Text';
			objTask1.Staff_to_Follow_up__c = true;
			Insert objTask1;
			
			// -------Task 2 - Complete to Start, generates a new Staff Task with Insert-----------------
			//Task Owner is UserA, who does not have a default Assignee, therefor the followup task will also be assigned to UserA
	        Task objTask2 = new Task();
	        objTask2.OwnerId = objUserB.ID;
	        objTask2.RecordTypeID = '012E0000000MEz4';
	       	objTask2.Subject = 'Solicitation';
			objTask2.Type = 'Other';
			objTask2.WhoId = objContact2.ID;
			objTask2.ActivityDate = mDate;
			objTask2.Status = 'Completed';
			objTask2.Outcomes__c = 'Sample Text';
			objTask2.Staff_to_Follow_up__c = true;
			Insert objTask2;
			
			// Update Task 1 to generate a new Staff Task on Update----------------	
			
			objTask1.Status = 'Completed';
			Update objTask1;

			//Check to see if Task 1 Generated a follow-up Task after the update, verify that UserA was assigned the task
			Task checkTask3 = [SELECT WhoID, OwnerID, Subject FROM Task Where WhoID =: objContact1.ID AND Subject ='Follow-up Actions'];
			System.assertequals (checkTask3.OwnerId, objUserA.ID);
			
			//Check to see if Task 2 Generated a follow-up Task, verify that UserA was assigned the task
			Task checkTask4 = [SELECT WhoID, OwnerID, Subject FROM Task Where WhoID =: objContact2.ID AND Subject ='Follow-up Actions'];
			System.assertequals (checkTask4.OwnerId, objUserA.ID);	
			
	        }
	}
}