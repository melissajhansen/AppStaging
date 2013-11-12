@isTest

// 8/6/13 - MP Removed Tests within Default Owner testing & Add Stand Office Testing that verified Case Creation since we no longer generate Cases when those functions fail.

private class ContactUtilsTest {
	
    
    public static TestMethod void TestUpdateCityState1() {
    	// Test Contact with Street and Zip
    	Contact c1 = new Contact ();
    	c1.FirstName = 'Tester1';
    	c1.LastName = 'Contact1';
    	c1.email = 'test1@stand.org';
		c1.MailingPostalCode = '01072';
		c1.MailingStreet = '50 Leverett Rd';
		Test.StartTest();
		
		insert c1;
		
		List <Contact> cList = new List <Contact>();
		cList.add(c1);
		ContactUtils.zipToCityState(cList, null);
		
		Test.StopTest();
		
		Contact c = ([SELECT ID, MailingStreet, MailingCity, MailingState, MailingPostalCode, State_Senate_District__c, State_House_District__c FROM Contact WHERE ID =: c1.ID]);
    	System.AssertEquals(c.MailingCity, 'Shutesbury');
    	System.AssertEquals(c.MailingState, 'MA');
    	System.AssertEquals(c.State_Senate_District__c, 'Hampshire, Franklin and Worcester');
    	System.AssertEquals(c.State_House_District__c, 'First Franklin');
    }

    public static TestMethod void TestUpdateCityState2() {
    	// Test Contact with Zip, City and State
    	Contact c2 = new Contact ();
    	c2.FirstName = 'Tester2';
    	c2.LastName = 'Contact2';
    	c2.email = 'test2@stand.org';
		c2.MailingPostalCode = '01072';
		c2.MailingCity = 'Shutesbury';
		c2.MailingState = 'MA';
		Test.StartTest();

		insert c2;

		List <Contact> cList = new List <Contact>();
		cList.add(c2);
		ContactUtils.zipToCityState(cList, null);

		Test.StopTest();
		    	
		Contact c = ([SELECT ID, MailingStreet, MailingCity, MailingState, MailingPostalCode, State_Senate_District__c, State_House_District__c FROM Contact WHERE ID =: c2.ID]);
    	System.AssertEquals(c.MailingCity, 'Shutesbury');
    	System.AssertEquals(c.MailingState, 'MA');
    	System.AssertEquals(c.State_Senate_District__c, 'Hampshire, Franklin and Worcester');
    	System.AssertEquals(c.State_House_District__c, 'First Franklin');
    }

    public static TestMethod void TestUpdateCityState3() {
    	// Test Contact with City and State
    	Contact c3 = new Contact ();
    	c3.FirstName = 'Tester2';
    	c3.LastName = 'Contact2';
    	c3.email = 'test2@stand.org';
		//c3.MailingPostalCode = '01072';
		c3.MailingCity = 'Shutesbury';
		c3.MailingState = 'MA';
		Test.StartTest();

		insert c3;

		List <Contact> cList = new List <Contact>();
		cList.add(c3);
		ContactUtils.zipToCityState(cList, null);

		Test.StopTest();
		    	
		Contact c = ([SELECT ID, MailingStreet, MailingCity, MailingState, MailingPostalCode, State_Senate_District__c, State_House_District__c FROM Contact WHERE ID =: c3.ID]);
    	System.AssertEquals(c.MailingCity, 'Shutesbury');
    	System.AssertEquals(c.MailingState, 'MA');
    	//System.AssertEquals(c.State_Senate_District__c, 'Hampshire, Franklin and Worcester');
    	//System.AssertEquals(c.State_House_District__c, 'First Franklin');
    }


    public static TestMethod void TestUpdateCityState4() {
    	// test multiple contacts with zip
    	Contact c3 = new Contact ();
    	c3.FirstName = 'Tester2';
    	c3.LastName = 'Contact2';
    	c3.email = 'test2@stand.org';
		c3.MailingPostalCode = '01072';
		
    	Contact c4 = new Contact ();
    	c4.FirstName = 'Tester2';
    	c4.LastName = 'Contact2';
    	c4.email = 'test2@stand.org';
		c4.MailingPostalCode = '01072';

		List <Contact> cList = new List <Contact> ();
		cList.add(c3);
		cList.add(c4);
		
		Test.StartTest();

		insert cList;

		List <Contact> cList2 = new List <Contact>();
		cList2.add(c3);
		cList2.add(c4);
		ContactUtils.zipToCityState(cList2, null);

		Test.StopTest();
		    	
		Contact c3Test = ([SELECT ID, MailingStreet, MailingCity, MailingState, MailingPostalCode, State_Senate_District__c, State_House_District__c FROM Contact WHERE ID =: c3.ID]);
		Contact c4Test = ([SELECT ID, MailingStreet, MailingCity, MailingState, MailingPostalCode, State_Senate_District__c, State_House_District__c FROM Contact WHERE ID =: c4.ID]);
    	System.AssertEquals(c3Test.MailingCity, 'Shutesbury');
    	System.AssertEquals(c3Test.MailingState, 'MA');
    	System.AssertEquals(c3Test.State_Senate_District__c, 'Hampshire, Franklin and Worcester');
    	System.AssertEquals(c3Test.State_House_District__c, 'First Franklin');

    	System.AssertEquals(c4Test.MailingCity, 'Shutesbury');
    	System.AssertEquals(c4Test.MailingState, 'MA');
    	System.AssertEquals(c4Test.State_Senate_District__c, 'Hampshire, Franklin and Worcester');
    	System.AssertEquals(c4Test.State_House_District__c, 'First Franklin');

    }

	public static TestMethod void TestfullStateToAbbrev() {
		String fullState;
		fullState = 'Alabama';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Alaska';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Arizona';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Arkansas';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'California';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Colorado';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Connecticut';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Delaware';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Florida';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Georgia';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Hawaii';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Idaho';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Illinois';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Indiana';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Iowa';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Kansas';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Kentucky';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Louisiana';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Maine';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Maryland';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Massachusetts';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Michigan';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Minnesota';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Mississippi';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Missouri';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Montana';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Nebraska';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Nevada';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'New Hampshire';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'New Jersey';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'New Mexico';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'New York';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'North Carolina';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'North Dakota';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Ohio';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Oklahoma';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Oregon';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Pennsylvania';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Rhode Island';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'South Carolina';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'South Dakota';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Tennessee';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Texas';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Utah';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Vermont';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Virginia';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Washington';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'West Virginia';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Wisconsin';
		ContactUtils.fullStateToAbbrev(fullState);
		fullState = 'Wyoming';
		ContactUtils.fullStateToAbbrev(fullState);
	}


    public static TestMethod void ContactToAccountTest() {
    	
    	//Create Test Contact with Fields to update on Account
    	Contact c1 = new Contact ();
    	c1.FirstName = 'Tester1';
    	c1.LastName = 'Contact1';
    	c1.email = 'test1@stand.org';
		c1.MailingPostalCode = '01072';
		c1.MailingCity = 'Shutesbury';
		c1.MailingState = 'MA';
		c1.Prospect_Priority__c = 'High';
		c1.Prospect_Status__c = 'Non-qualified Prospect';
		c1.Prospect_Classification__c = 'MA Prospect';
		c1.Stand_Office__c = 'MA';
		c1.Boards_Involvement__c = 'Test Board';
		c1.Estimated_Capacity__c = 50;
		c1.Funding_Program_Interests__c = 'Growth Campaign';
		c1.Other_Funding_Interests__c = 'Test Interests';
		c1.Philanthropic_Giving_History__c = 'Test History';
		c1.Political_Giving_History__c = 'Test History';
		c1.Prospect_Classification__c = 'MA Prospect';
		
		insert c1;
		
		//Check for correct values on new Contact/Account
		Contact c = ([SELECT ID, AccountId, Prospect_Priority__c, Prospect_Status__c, Stand_Office__c FROM Contact WHERE ID =: c1.ID]);
		Account a = ([SELECT ID, Prospect_Priority__c, Prospect_Status__c,OneToOneContactStandOffice__c, Boards_Involvement__c, Estimated_Capacity__c, Funding_Program_Interests__c, Other_Funding_Interests__c, Philanthropic_Giving_History__c, Political_Giving_History__c, Prospect_Classification__c FROM Account WHERE ID =: c.AccountID]);
    	System.AssertEquals(a.Prospect_Priority__c, 'High');
    	System.AssertEquals(a.Prospect_Status__c, 'Non-qualified Prospect');
    	System.AssertEquals(a.OneToOneContactStandOffice__c, 'MA');
    	System.AssertEquals(a.Boards_Involvement__c, 'Test Board');
    	System.AssertEquals(a.Estimated_Capacity__c, 50);
    	System.AssertEquals(a.Funding_Program_Interests__c, 'Growth Campaign');
    	System.AssertEquals(a.Other_Funding_Interests__c, 'Test Interests');
    	System.AssertEquals(a.Philanthropic_Giving_History__c, 'Test History');
    	System.AssertEquals(a.Political_Giving_History__c, 'Test History');
    	System.AssertEquals(a.Prospect_Classification__c, 'MA Prospect');
		
		//Change the values on the contact
		c1.Prospect_Priority__c = 'Medium';
		c1.Prospect_Status__c = 'Active Prospect';
		c1.Stand_Office__c = 'OR';
		c1.Boards_Involvement__c = 'Test Board2';
		c1.Estimated_Capacity__c = 75;
		c1.Funding_Program_Interests__c = 'Growth Campaign2';
		c1.Other_Funding_Interests__c = 'Test Interests2';
		c1.Philanthropic_Giving_History__c = 'Test History2';
		c1.Political_Giving_History__c = 'Test History2';
		c1.Prospect_Classification__c = 'OR Prospect';
		
		update c1;

		Account a2 = ([SELECT ID, Prospect_Priority__c, Prospect_Status__c,OneToOneContactStandOffice__c, Boards_Involvement__c, Estimated_Capacity__c, Funding_Program_Interests__c, Other_Funding_Interests__c, Philanthropic_Giving_History__c, Political_Giving_History__c, Prospect_Classification__c FROM Account WHERE ID =: c.AccountID]);
				    	
		//Check for correct values on updated contact/account
    	System.AssertEquals(a2.Prospect_Priority__c, 'Medium');
    	System.AssertEquals(a2.Prospect_Status__c, 'Active Prospect');
    	System.AssertEquals(a2.OneToOneContactStandOffice__c, 'OR');
    	System.AssertEquals(a2.Boards_Involvement__c, 'Test Board2');
    	System.AssertEquals(a2.Estimated_Capacity__c, 75);
    	System.AssertEquals(a2.Funding_Program_Interests__c, 'Growth Campaign2');
    	System.AssertEquals(a2.Other_Funding_Interests__c, 'Test Interests2');
    	System.AssertEquals(a2.Philanthropic_Giving_History__c, 'Test History2');
    	System.AssertEquals(a2.Political_Giving_History__c, 'Test History2');
    	System.AssertEquals(a2.Prospect_Classification__c, 'OR Prospect');

    }



    
    public static TestMethod void TestAssignDefaultOwnerInsert () {
    	// create user to run the operation
    	Profile oProfileUser = [Select Id from Profile where Name='Standard User'];
    	Profile oProfileAdmin = [Select Id from Profile where Name='Stand Admin Users'];
    	
        User u1 = new User();
        u1.Alias = 'dacco';
        u1.CommunityNickname = 'ownerTestDeveloper';
        u1.Email = 'sfdev@stand.org';
        u1.EmailEncodingKey = 'UTF-8';
        u1.FirstName = 'Developer';
        u1.LocaleSidKey = 'en_US';
        u1.LastName = 'Account';
        u1.LanguageLocaleKey = 'en_US';
        u1.ProfileId = oProfileAdmin.Id;
        
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.UserName = 'ownerTestDeveloper@stand.org.qa';
        u1.Division = 'National';
       
        insert u1;
        User daccoUser = ([SELECT ID, Name from User Where ID =:u1.id]);
                
    	// Create a user to be the owner
    	User uOwner = new User();
        uOwner.Alias = 'TO1';
        uOwner.CommunityNickname = 'TestOwner';
        uOwner.Email = 'testowner1@stand.org';
        uOwner.EmailEncodingKey = 'UTF-8';
        uOwner.FirstName = 'Test';
        uOwner.LocaleSidKey = 'en_US';
        uOwner.LastName = 'Owner';
        uOwner.LanguageLocaleKey = 'en_US';
        uOwner.ProfileId = oProfileUser.Id;
        
        uOwner.TimeZoneSidKey = 'America/Los_Angeles';
        uOwner.UserName = 'testowner1@stand.org';
        uOwner.Division = 'National';
        
    	uOwner.Default_State_Owner__c = 'test';
    	
    	insert uOwner;
    	User ownerUser = ([SELECT ID, Name from User Where ID =:uOwner.ID]);
    	
    	
    	System.runAs ( u1 ) {
    		// create the contact as dacco, simulating a web inserted Contact
	    	Contact c = new Contact ();
	    	c.FirstName = 'Test';
	    	c.LastName = 'Contact';
	    	c.MailingState = 'test';
	    	c.email = 'test@stand.org';
	    	c.Stand_Office__c = 'test';
	    	
	    	insert c;
	    	
	    	// reload the contact
			Contact cAssert = [ SELECT ID, ownerID FROM Contact WHERE ID =: c.ID ];
			
			// check that the owner is uOwner
			System.assertEquals ( ownerUser.ID, cAssert.ownerID );
						
    	}
    	
    }
    
    
	public static TestMethod void TestAssignStandOfficeDefaultOwnerUpdate () {
    	Test.StartTest();
    	// create user to run the operation
   	
        User daccoUser = ([SELECT ID, Alias, Name from User Where Alias =:'dacco']);

    	//Select User from the Database for testing
    	User uOwner = ([SELECT ID, Name, Default_State_Owner__c From User Where Default_State_Owner__c =:'MA']);
    	
    	System.runAs ( daccoUser ) {
    		// create the contact as dacco, simulating a web inserted Contact
	    	Contact c = new Contact ();
	    	c.FirstName = 'Test';
	    	c.LastName = 'Contact';
	    	c.MailingPostalCode = '01072';
	    	c.email = 'test@stand.org';
	    	
	    	insert c;
	    	
	    	List < Contact > cList = new List < Contact > ();
	    	cList.add(c);
	    	
	    	//ContactUtils cUtil = new ContactUtils ();
	    	ContactUtils.zipToCityState(cList, null);
	    	//cUtil.AssignDefaultOwnerOnUpdate (cList);
	    	
			Test.StopTest();
			// check that the owner is uOwner
			// reload the contact
			Contact cAssert = [ SELECT ID, Stand_Office__c, MailingState, ownerID FROM Contact WHERE ID =: c.ID ];
			System.assertEquals ( uOwner.ID, cAssert.ownerID );
			System.assertEquals ( 'MA', cAssert.Stand_Office__c);
    	}
    	
    }    
     public static TestMethod void TestAssignDefaultOwner_NoOwnerFound () {
    	// create user to run the operation
    	Profile oProfileUser = [Select Id from Profile where Name='Standard User'];
    	Profile oProfileAdmin = [Select Id from Profile where Name='Stand Admin Users'];
    	
        User u1 = new User();
        u1.Alias = 'dacco';
        u1.CommunityNickname = 'ownerTestDeveloper2';
        u1.Email = 'sfdev@stand.org';
        u1.EmailEncodingKey = 'UTF-8';
        u1.FirstName = 'Developer2';
        u1.LocaleSidKey = 'en_US';
        u1.LastName = 'Account';
        u1.LanguageLocaleKey = 'en_US';
        u1.ProfileId = oProfileAdmin.Id;
        
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        u1.UserName = 'ownerTestDeveloper2@stand.org.qa';
        u1.Division = 'National';
       
        insert u1;
        
    	// Create a user to be the owner, but use a different state to cause a failure
    	User uOwner = new User();
        uOwner.Alias = 'TO2';
        uOwner.CommunityNickname = 'TestOwner2';
        uOwner.Email = 'testowner2@stand.org';
        uOwner.EmailEncodingKey = 'UTF-8';
        uOwner.FirstName = 'Test';
        uOwner.LocaleSidKey = 'en_US';
        uOwner.LastName = 'Owner';
        uOwner.LanguageLocaleKey = 'en_US';
        uOwner.ProfileId = oProfileUser.Id;
        
        uOwner.TimeZoneSidKey = 'America/Los_Angeles';
        uOwner.UserName = 'testowner2@stand.org';
        uOwner.Division = 'National';
        
    	uOwner.Default_State_Owner__c = 'ZZ';
    	
    	insert uOwner;
    	
    	system.debug('**************************************************uOwnerID'+uOwner.Id);
    	system.debug('**************************************************u1ID'+u1.Id);
    	
    	System.runAs ( u1 ) {
    		// create the contact with a non-matching stand state
	    	Contact c = new Contact ();
	    	c.FirstName = 'Test';
	    	c.LastName = 'Contact';
	    	c.email = 'test@stand.org';
	    	c.Stand_Office__c = 'HI';
	    	
	    	insert c;
	    	
	    	// reload the contact
			Contact cAssert = [ SELECT ID, ownerID FROM Contact WHERE ID =: c.ID ];
			system.debug('**************************************************ContactOwnerID'+cAssert.ownerID);
			
			// 
			
			// check that the owner is u1
			System.assertEquals ( u1.Id, cAssert.ownerID );
			
    	}
    	
    }
    
    	public static TestMethod void TestAddStandOffice() {
    	
    	// select user to run the operation
        User daccoUser = ([SELECT ID, Alias, Name from User Where Alias =:'dacco']);
    	
    	System.runAs ( daccoUser ) {
    		// create the contact as dacco, simulating a web inserted Contact
	    	Contact c = new Contact ();
	    	c.FirstName = 'Test';
	    	c.LastName = 'Contact';
	    	c.MailingPostalCode = '97213';
	    	c.MailingState = 'OR';
	    	c.MailingCity = 'Portland';
	    	c.email = 'test@stand.org';
	    	
	    	insert c;
	    	
	    	// reload the contact as a list
			List < Contact > cAssertList = new List < Contact > ([ SELECT ID, Stand_Office__c, ownerID FROM Contact WHERE ID =: c.ID ]);
			
			ContactUtils cUtil = new ContactUtils ();
			cUtil.AddStandOffice ( cAssertList );
			cUtil.AssignDefaultOwnerOnUpdate ( cAssertList );
			system.debug('********************************************************OwnerofTestContact'+cAssertList[0].ownerID);
			system.debug('******************************************************standofficevalueatendoftest'+cAssertList[0].Stand_Office__c);
			
			//Check that the Stand Office was filled in correctly
			//Reload the contact
			Contact cAssert = ([SELECT ID, Stand_Office__c FROM Contact WHERE ID =: c.ID]);
			system.assertEquals ('OR', cAssert.Stand_Office__c);		
    	}
    	
    }   
     
}