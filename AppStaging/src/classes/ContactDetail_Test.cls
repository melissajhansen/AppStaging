@isTest
public class ContactDetail_Test {

	public static TestMethod void TestContactDetail() {
    	Contact objContact = new Contact();
        Apexpages.StandardController stdController = new Apexpages.StandardController(objContact);
        ContactSearch objContactSearch = new ContactSearch(stdController);
        
        List<selectOption> lstStates = objContactSearch.getStateList;

        System.AssertEquals(objContactSearch.strSortField, 'Name');
        System.AssertEquals(objContactSearch.strSortDirection, 'Asc');
        
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 0);
        
        objContact = new Contact();
        objContact.FirstName = 'TestFirstName1';
        objContact.LastName = 'TestLastName1';
        objContact.MailingCity = 'TestCity1';
        if (lstStates.size() > 1)
            objContact.MailingState = lstStates[1].getLabel();
        objContact.Email = 'testemail1@test.com';
        objContact.Phone = '11111';
        objContact.MobilePhone = '22222';
        objContact.HomePhone = '33333';
        objContact.OtherPhone = '44444';
        objContact.MailingPostalCode = '121212';
        objContact.DoNotCall = true;
        objContact.Do_Not_Text__c = true;
        objContact.HasOptedOutOfEmail = true;
        objContact.Do_Not_Contact__c = 'Test';
        objContact.RecordTypeId = [SELECT ID, SobjectType, Name FROM RecordType WHERE Name = 'VIP Contact' AND SobjectType = 'Contact' LIMIT 1].ID;
        Insert objContact;
        
        objContactSearch.strFirstName = 'TestFirstName1';
   	    objContactSearch.SetSearchVariables();
	}
	
	public static TestMethod void TestContactDetail2() {
        Profile objProfile = [Select Id from Profile where Name='Galaxy Basic Restricted'];
        User objUser = new User();
        objUser.Alias = 'TstClsU';
        objUser.CommunityNickname = 'TstClsU';
        objUser.Email = 'testclassuser@test.com';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.FirstName = 'TestClass';
        objUser.LocaleSidKey = 'en_US';
        objUser.LastName = 'User';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.ProfileId = objProfile.Id;
        objUser.TimeZoneSidKey = 'America/Los_Angeles';
        objUser.UserName = 'CDetTestContactDetail2@test.com';
        objUser.Division = 'National';
        insert objUser;

        System.runAs(objUser)
        {
	    	Contact objContact = new Contact();
    	    Apexpages.StandardController stdController = new Apexpages.StandardController(objContact);
        	ContactSearch objContactSearch = new ContactSearch(stdController);
        
	        List<selectOption> lstStates = objContactSearch.getStateList;

    	    System.AssertEquals(objContactSearch.strSortField, 'Name');
        	System.AssertEquals(objContactSearch.strSortDirection, 'Asc');
        
	        objContactSearch.SetSearchVariables();
    	    System.AssertEquals(objContactSearch.ContactDisplay.size(), 0);
        
	        objContact = new Contact();
    	    objContact.FirstName = 'TestFirstName1';
        	objContact.LastName = 'TestLastName1';
	        objContact.MailingCity = 'TestCity1';
    	    if (lstStates.size() > 1)
        	    objContact.MailingState = lstStates[1].getLabel();
	        objContact.Email = 'testemail1@test.com';
    	    objContact.Phone = '11111';
        	objContact.MobilePhone = '22222';
	        objContact.HomePhone = '33333';
    	    objContact.OtherPhone = '44444';
        	objContact.MailingPostalCode = '121212';
	        objContact.DoNotCall = true;
    	    objContact.Do_Not_Text__c = true;
        	objContact.HasOptedOutOfEmail = true;
	        objContact.Do_Not_Contact__c = 'Test';
    	    objContact.RecordTypeId = [SELECT ID, SobjectType, Name FROM RecordType WHERE Name = 'VIP Contact' AND SobjectType = 'Contact' LIMIT 1].ID;
        	Insert objContact;
        
	        objContactSearch.strFirstName = 'TestFirstName1';
    	    objContactSearch.SetSearchVariables();
        }
		
	}
	
}