@isTest

public class SustainerAutoRenewJob_Test {

	// Test #1 - Base case - Membership Renew Single Record
	// 1. Create a Membership, back dated to 365s prior
	// 2. Set their Recurring Gift Status to active
	// 3. Run the batch job
	// 4. Validate that new Membership Activity is set
	
	public static TestMethod void AutoRenew_Single_Record_Test () {
		// create base objects
		DateTime dt = System.now ();
		Date mDate = date.newInstance ( dt.year(), dt.month(), dt.day() );
		Date mBackDate = mDate.addYears ( -1 ).addDays ( 1 );
		
		// ------ STATE -------------
        Account objState = new Account();
        objState.Name = 'Test State';
        objState.Type = 'Stand Affiliate State';
        objState.Acquired_By__c = 'C3 Acquired';
        objState.State_Abbreviation__c = 'HI';
        objState.BillingState = 'HI';
        Insert objState;
        
        // ------ Chapter 1 -------------
        Account objChapter = new Account();
        objChapter.Name = 'Test Chapter1';
        objChapter.Type = 'Stand Chapter';
        objChapter.Acquired_By__c = 'C3 Acquired';
        objChapter.ParentId = objState.Id;
        objChapter.State_Abbreviation__c = 'HI';
        objChapter.BillingState = 'HI';
        Insert objChapter;
        
        // ------ Team 1-1 -------------
        Account objTeam1 = new Account();
        objTeam1.Name = 'Test Team11';
        objTeam1.Type = 'Stand Team';
        objTeam1.Acquired_By__c = 'C3 Acquired';
        objTeam1.ParentId = objChapter.Id;
        objTeam1.State_Abbreviation__c = 'HI';
	    objTeam1.BillingState = 'HI';
        Insert objTeam1;
        
         // ------ Contact 1 -------------
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact Chapter1';
        objContact.Stand_Office__c = 'HI';
        objContact.Recurring_Gift_Status__c = 'Active';
        Insert objContact;
        
        // create new membership (Join)
		Membership__c objMember = new Membership__c();
		objMember.Contact__c = objContact.Id;
		objMember.Membership_Action__c = 'Join';
		objMember.Membership_Source__c = 'Web';
		objMember.Membership_State__c = 'HI';
		objMember.Stand_Team__c = objTeam1.Id;
		objMember.Type__c = 'Sustaining';
		objMember.Gift_Amount__c = 25;	
		Insert objMember;
		
		Id idMember = objMember.Id;
		
		// back date the join so it expires tomorrow
		objMember.Membership_Action__c = 'Edit';
		objMember.Start_Date__c = mBackDate;
		
		update objMember;
		
		Membership_Activity__c ma = [ SELECT ID, start_date__c FROM Membership_Activity__c WHERE Membership__c =: idMember ];
		
		ma.start_date__c = mBackDate;
    	update ma;
    	
    	// check to see that the membership is still active and backdated to expire tomorrow
    	objMember = [ SELECT ID, Status2__c, Expiration_Date__c, Last_Renewal_Or_Join_Date__c FROM Membership__c WHERE ID =: idMember ];
    	
		System.assertEquals ( 'Active', objMember.Status2__c );
		System.assertEquals ( mDate.addDays ( 1 ), objMember.Expiration_Date__c );
		
		// run the update
		SustainerAutoRenewJob oSA = new SustainerAutoRenewJob ();
		oSA.renewSustainers();
		
		// reload the membership and check the date
		objMember = [ SELECT ID, Status2__c, Expiration_Date__c, Last_Renewal_Or_Join_Date__c FROM Membership__c WHERE ID =: idMember ];
    	
    	// check all Membership Activity Records - confirm that we have two now
    	List < Membership_Activity__c > listMa = new List < Membership_Activity__c > ( [ SELECT ID, start_date__c, subject__c FROM Membership_Activity__c WHERE Membership__c =: IdMember ] );
		
		System.assertEquals ( 2, listMa.size() );
		System.assertEquals ( 'Membership Auto Renewal', listMa[1].subject__c );
		
		System.assertEquals ( mDate.addYears ( 1 ), objMember.Expiration_Date__c );
    	
	}
	
	// Test #2 - Base case - Membership Renew Multiple Record
	// 1. Create two Memberships, back dated to 365s prior
	// 2. Set their Recurring Gift Status to active
	// 3. Run the batch job
	// 4. Validate that memberships are now active

	// TODO, expand this test after we refactor Membership to remove limits

	public static TestMethod void AutoRenew_Multiple_Record_Test () {
		// create base objects
		DateTime dt = System.now ();
		Date mDate = date.newInstance ( dt.year(), dt.month(), dt.day() );
		Date mBackDate = mDate.addYears ( -1 ).addDays ( 1 );

		
		// ------ STATE -------------
        Account objState = new Account();
        objState.Name = 'Test State';
        objState.Type = 'Stand Affiliate State';
        objState.Acquired_By__c = 'C3 Acquired';
        objState.State_Abbreviation__c = 'HI';
        objState.BillingState = 'HI';
        Insert objState;
        
        // ------ Chapter 1 -------------
        Account objChapter = new Account();
        objChapter.Name = 'Test Chapter1';
        objChapter.Type = 'Stand Chapter';
        objChapter.Acquired_By__c = 'C3 Acquired';
        objChapter.ParentId = objState.Id;
        objChapter.State_Abbreviation__c = 'HI';
        objChapter.BillingState = 'HI';
        Insert objChapter;
        
        // ------ Team 1-1 -------------
        Account objTeam1 = new Account();
        objTeam1.Name = 'Test Team11';
        objTeam1.Type = 'Stand Team';
        objTeam1.Acquired_By__c = 'C3 Acquired';
        objTeam1.ParentId = objChapter.Id;
        objTeam1.State_Abbreviation__c = 'HI';
	    objTeam1.BillingState = 'HI';
        Insert objTeam1;
        
        // ------ Contact 1 --------------------------------------------------
        Contact objContact1 = new Contact();
        objContact1.FirstName = 'Test';
        objContact1.LastName = 'Contact Chapter1';
        objContact1.Stand_Office__c = 'HI';
        objContact1.Recurring_Gift_Status__c = 'Active';
        Insert objContact1;
        
        // create new membership (Join)
		Membership__c objMember1 = new Membership__c();
		objMember1.Contact__c = objContact1.Id;
		objMember1.Membership_Action__c = 'Join';
		objMember1.Membership_Source__c = 'Web';
		objMember1.Membership_State__c = 'HI';
		objMember1.Stand_Team__c = objTeam1.Id;
		objMember1.Type__c = 'Sustaining';
		objMember1.Gift_Amount__c = 25;	
		Insert objMember1;
		
		// ------ Contact 2 --------------------------------------------------
        Contact objContact2 = new Contact();
        objContact2.FirstName = 'Test';
        objContact2.LastName = 'Contact Chapter2';
        objContact2.Stand_Office__c = 'HI';
        objContact2.Recurring_Gift_Status__c = 'Active';
        Insert objContact2;
        
        // create new membership (Join)
		Membership__c objMember2 = new Membership__c();
		objMember2.Contact__c = objContact2.Id;
		objMember2.Membership_Action__c = 'Join';
		objMember2.Membership_Source__c = 'Web';
		objMember2.Membership_State__c = 'HI';
		objMember2.Stand_Team__c = objTeam1.Id;
		objMember2.Type__c = 'Sustaining';
		objMember2.Gift_Amount__c = 25;	
		Insert objMember2;
		
		Id idMember1 = objMember1.Id;
		Id idMember2 = objMember2.Id;
		
		// MEMBERSHIP #1 -- back date the join so it expires tomorrow
		objMember1.Membership_Action__c = 'Edit';
		objMember1.Start_Date__c = mBackDate;
		
		update objMember1;
		
		Membership_Activity__c ma = [ SELECT ID, start_date__c FROM Membership_Activity__c WHERE Membership__c =: idMember1 ];
		
		ma.start_date__c = mBackDate;
    	update ma;
    	
    	// check to see that the membership is still active and backdated to expire tomorrow
    	objMember1 = [ SELECT ID, Status2__c, Expiration_Date__c, Last_Renewal_Or_Join_Date__c FROM Membership__c WHERE ID =: idMember1 ];
    	
		System.assertEquals ( 'Active', objMember1.Status2__c );
		System.assertEquals ( mDate.addDays ( 1 ), objMember1.Expiration_Date__c );
		
		// MEMBERSHIP #2 -- back date the join so it is lapsed
		objMember2.Membership_Action__c = 'Edit';
		objMember2.Start_Date__c = mBackDate.addDays (-30 );
		
		update objMember2;
		
		ma = [ SELECT ID, start_date__c FROM Membership_Activity__c WHERE Membership__c =: idMember2 ];
		
		ma.start_date__c = mBackDate.addDays (-30 );
    	update ma;
    	
    	// check to see that the membership is lapsed
    	objMember2 = [ SELECT ID, Status2__c, Expiration_Date__c, Last_Renewal_Or_Join_Date__c FROM Membership__c WHERE ID =: idMember2 ];
    	
		System.assertEquals ( 'Lapsed', objMember2.Status2__c );
		
	}

	// Test #3 - Exception case - Membership date is too early
	// 1. Create 1 Membership, dated less than 365 days prior
	// 2. Set their Recurring Gift Status to active
	// 3. Run the batch job
	// 4. Validate that membership is still active

	public static TestMethod void AutoRenew_No_Run_Too_Early_Test () {
		
		// create base objects
		DateTime dt = System.now ();
		Date mDate = date.newInstance ( dt.year(), dt.month(), dt.day() );
		Date mBackDate = mDate.addYears ( -1 ).addDays ( 30 );
		
		// ------ STATE -------------
        Account objState = new Account();
        objState.Name = 'Test State';
        objState.Type = 'Stand Affiliate State';
        objState.Acquired_By__c = 'C3 Acquired';
        objState.State_Abbreviation__c = 'HI';
        objState.BillingState = 'HI';
        Insert objState;
        
        // ------ Chapter 1 -------------
        Account objChapter = new Account();
        objChapter.Name = 'Test Chapter1';
        objChapter.Type = 'Stand Chapter';
        objChapter.Acquired_By__c = 'C3 Acquired';
        objChapter.ParentId = objState.Id;
        objChapter.State_Abbreviation__c = 'HI';
        objChapter.BillingState = 'HI';
        Insert objChapter;
        
        // ------ Team 1-1 -------------
        Account objTeam1 = new Account();
        objTeam1.Name = 'Test Team11';
        objTeam1.Type = 'Stand Team';
        objTeam1.Acquired_By__c = 'C3 Acquired';
        objTeam1.ParentId = objChapter.Id;
        objTeam1.State_Abbreviation__c = 'HI';
	    objTeam1.BillingState = 'HI';
        Insert objTeam1;
        
         // ------ Contact 1 -------------
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact Chapter1';
        objContact.Stand_Office__c = 'HI';
        objContact.Recurring_Gift_Status__c = 'Active';
        Insert objContact;
        
        // create new membership (Join)
		Membership__c objMember = new Membership__c();
		objMember.Contact__c = objContact.Id;
		objMember.Membership_Action__c = 'Join';
		objMember.Membership_Source__c = 'Web';
		objMember.Membership_State__c = 'HI';
		objMember.Stand_Team__c = objTeam1.Id;
		objMember.Type__c = 'Sustaining';
		objMember.Gift_Amount__c = 25;	
		Insert objMember;
		
		Id idMember = objMember.Id;
		
		// back date the join so it expires tomorrow
		objMember.Membership_Action__c = 'Edit';
		objMember.Start_Date__c = mBackDate;
		
		update objMember;
		
		Membership_Activity__c ma = [ SELECT ID, start_date__c FROM Membership_Activity__c WHERE Membership__c =: idMember ];
		
		ma.start_date__c = mBackDate;
    	update ma;
    	
    	// check to see that the membership is still active 
    	objMember = [ SELECT ID, Status2__c, Expiration_Date__c, Last_Renewal_Or_Join_Date__c FROM Membership__c WHERE ID =: idMember ];
    	Date mCheckDate = objMember.Expiration_Date__c;
    	
		System.assertEquals ( 'Active', objMember.Status2__c );
		
		// run the update
		SustainerAutoRenewJob oSA = new SustainerAutoRenewJob ();
		oSA.renewSustainers();
		
		// reload the membership and check the date
		objMember = [ SELECT ID, Status2__c, Expiration_Date__c, Last_Renewal_Or_Join_Date__c FROM Membership__c WHERE ID =: idMember ];
    	
    	// check all Membership Activity Records - confirm that we only have one
    	List < Membership_Activity__c > listMa = new List < Membership_Activity__c > ( [ SELECT ID, start_date__c, subject__c FROM Membership_Activity__c WHERE Membership__c =: IdMember ] );
		
		System.assertEquals ( 1, listMa.size() );
		System.assertEquals ( mCheckDate, objMember.Expiration_Date__c );
		
	}
	
	// Test #4 - Exception case - Membership Renew Gift Invalid
	// 1. Create 1 Membership, dated more than 365 days prior
	// 2. Set their Recurring Gift Status to something other than "Active"
	// 3. Run the batch job
	// 4. Validate that membership is still lapsed
	
	public static TestMethod void AutoRenew_No_Run_Invalid_Gift_Test () {
		// create base objects
		DateTime dt = System.now ();
		Date mDate = date.newInstance ( dt.year(), dt.month(), dt.day() );
		Date mBackDate = mDate.addYears ( -1 ).addDays ( -30 );
		
		// ------ STATE -------------
        Account objState = new Account();
        objState.Name = 'Test State';
        objState.Type = 'Stand Affiliate State';
        objState.Acquired_By__c = 'C3 Acquired';
        objState.State_Abbreviation__c = 'HI';
        objState.BillingState = 'HI';
        Insert objState;
        
        // ------ Chapter 1 -------------
        Account objChapter = new Account();
        objChapter.Name = 'Test Chapter1';
        objChapter.Type = 'Stand Chapter';
        objChapter.Acquired_By__c = 'C3 Acquired';
        objChapter.ParentId = objState.Id;
        objChapter.State_Abbreviation__c = 'HI';
        objChapter.BillingState = 'HI';
        Insert objChapter;
        
        // ------ Team 1-1 -------------
        Account objTeam1 = new Account();
        objTeam1.Name = 'Test Team11';
        objTeam1.Type = 'Stand Team';
        objTeam1.Acquired_By__c = 'C3 Acquired';
        objTeam1.ParentId = objChapter.Id;
        objTeam1.State_Abbreviation__c = 'HI';
	    objTeam1.BillingState = 'HI';
        Insert objTeam1;
        
         // ------ Contact 1 ------------- (NOTE: No Recurring_Gift Active HERE )
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact Chapter1';
        objContact.Stand_Office__c = 'HI';
        Insert objContact;
        
        // create new membership (Join)
		Membership__c objMember = new Membership__c();
		objMember.Contact__c = objContact.Id;
		objMember.Membership_Action__c = 'Join';
		objMember.Membership_Source__c = 'Web';
		objMember.Membership_State__c = 'HI';
		objMember.Stand_Team__c = objTeam1.Id;
		objMember.Type__c = 'Sustaining';
		objMember.Gift_Amount__c = 25;	
		Insert objMember;
		
		Id idMember = objMember.Id;
		
		// back date the join so it expires tomorrow
		objMember.Membership_Action__c = 'Edit';
		objMember.Start_Date__c = mBackDate;
		
		update objMember;
		
		Membership_Activity__c ma = [ SELECT ID, start_date__c FROM Membership_Activity__c WHERE Membership__c =: idMember ];
		
		ma.start_date__c = mBackDate;
    	update ma;
    	
    	// check to see that the membership is lapsed
    	objMember = [ SELECT ID, Status2__c, Expiration_Date__c, Last_Renewal_Or_Join_Date__c FROM Membership__c WHERE ID =: idMember ];
    	Date mCheckDate = objMember.Expiration_Date__c;
    	
		System.assertEquals ( 'Lapsed', objMember.Status2__c );
		
		// run the update
		SustainerAutoRenewJob oSA = new SustainerAutoRenewJob ();
		oSA.renewSustainers();
		
		// reload the membership and check that it's still lapsed
		objMember = [ SELECT ID, Status2__c, Expiration_Date__c, Last_Renewal_Or_Join_Date__c FROM Membership__c WHERE ID =: idMember ];
    	
    	// check all Membership Activity Records - confirm that we only have one
    	List < Membership_Activity__c > listMa = new List < Membership_Activity__c > ( [ SELECT ID, start_date__c, subject__c FROM Membership_Activity__c WHERE Membership__c =: IdMember ] );
		
		System.assertEquals ( 1, listMa.size() );
		System.assertEquals ( 'Lapsed', objMember.Status2__c );
		
		
	}
	
	// Test #6 - Load Test
	// 1. Create a 150 Memberships - all dated 365 from current date
	// 2. Set Recurring Gift status to active
	// 3. Run automation
	// 4. Make sure that all 150 memberships are now active
	
	public static TestMethod void AutoRenew_Load_Test () {
		// create base objects
		DateTime dt = System.now ();
		Date mDate = date.newInstance ( dt.year(), dt.month(), dt.day() );
		Date mBackDate = mDate.addYears ( -1 ).addDays ( -30 );
		Integer iLoop = 50;
		
		// ------ STATE -------------
        Account objState = new Account();
        objState.Name = 'Test State';
        objState.Type = 'Stand Affiliate State';
        objState.Acquired_By__c = 'C3 Acquired';
        objState.State_Abbreviation__c = 'HI';
        objState.BillingState = 'HI';
        Insert objState;
        
        // ------ Chapter 1 -------------
        Account objChapter = new Account();
        objChapter.Name = 'Test Chapter1';
        objChapter.Type = 'Stand Chapter';
        objChapter.Acquired_By__c = 'C3 Acquired';
        objChapter.ParentId = objState.Id;
        objChapter.State_Abbreviation__c = 'HI';
        objChapter.BillingState = 'HI';
        Insert objChapter;
        
        // ------ Team 1-1 -------------
        Account objTeam1 = new Account();
        objTeam1.Name = 'Test Team11';
        objTeam1.Type = 'Stand Team';
        objTeam1.Acquired_By__c = 'C3 Acquired';
        objTeam1.ParentId = objChapter.Id;
        objTeam1.State_Abbreviation__c = 'HI';
	    objTeam1.BillingState = 'HI';
        Insert objTeam1;
        
        // create list of contacts
        List < Contact > listContacts = new List < Contact > ();
        Contact objContact;
        
        for ( integer i = 0; i < iLoop; i++ ) {
        	objContact = new Contact ();
        	objContact.FirstName = 'Test';
        	objContact.LastName = 'Contact Chapter ' + i;
        	objContact.Stand_Office__c = 'HI';
        	objContact.Recurring_Gift_Status__c = 'Active';
        	listContacts.add ( objContact );
        }
        
        insert listContacts;
        
        List < Membership__c > listMemberships = new List < Membership__c > ();
        Membership__c objMember;
        
        for ( integer i = 0; i < iLoop; i++ ) {
        	objMember = new Membership__c ();
        	objMember.Contact__c = listContacts[i].Id;
			objMember.Membership_Action__c = 'Join';
			objMember.Membership_Source__c = 'Web';
			objMember.Membership_State__c = 'HI';
			objMember.Stand_Team__c = objTeam1.Id;
			objMember.Type__c = 'Sustaining';
			objMember.Gift_Amount__c = 25;	
			objMember.Start_Date__c = mBackDate;
        }
        
        insert listMemberships;
      
		// run the update
		Test.startTest();
		
		// check that the memberships are backdated
		List < Membership__c > listNewMemberships = new List < Membership__c > ( [ SELECT ID, Expiration_Date__c, Status2__c FROM Membership__c WHERE ID IN : listMemberships ] );
		for ( Membership__c m : listNewMemberships ) {
			System.assertEquals ( mDate.addDays ( 1 ), m.Expiration_Date__c );
		}
		
		SustainerAutoRenewJob oSA = new SustainerAutoRenewJob ();
		oSA.renewSustainers();
		
		// check to make sure that these all have new expiration dates
		List < Membership__c > listNewMemberships2 = new List < Membership__c > ( [ SELECT ID, Expiration_Date__c, Status2__c FROM Membership__c WHERE ID IN : listMemberships ] );
		for ( Membership__c m : listNewMemberships2 ) {
			System.assertEquals ( mDate.addYears ( 1 ), m.Expiration_Date__c );
		}
		
		Test.stopTest();
	}

	// Test #7 - Scheduling of the APEX Job
	// 1.  Schedule the job
	
	public static TestMethod void AutoRenew_Schedule () {
	
		SustainerAutoRenewJob oSJ = new SustainerAutoRenewJob ();
		// check to see if this covers all lines of code
		Test.startTest();
		string sch = '0 0 * * 1-12 ? *';
		system.schedule( 'Batch Scheduler 123 TEST', sch, oSJ );
		Test.stopTest();
	}
	
	// Test #8 - Exception case - Triggering DML Exception
	// 1. Create a Membership, back dated to 365s prior
	// 2. Set their Recurring Gift Status to active
	// 3. Turn on ReadOnly Mode
	// 4. Run the batch job
	// 5. Validate that nothing happened
	
	public static TestMethod void AutoRenew_DML_Exception_Test () {
		// create base objects
		DateTime dt = System.now ();
		Date mDate = date.newInstance ( dt.year(), dt.month(), dt.day() );
		Date mBackDate = mDate.addYears ( -1 ).addDays ( 1 );
		
		// ------ STATE -------------
        Account objState = new Account();
        objState.Name = 'Test State';
        objState.Type = 'Stand Affiliate State';
        objState.Acquired_By__c = 'C3 Acquired';
        objState.State_Abbreviation__c = 'HI';
        objState.BillingState = 'HI';
        Insert objState;
        
        // ------ Chapter 1 -------------
        Account objChapter = new Account();
        objChapter.Name = 'Test Chapter1';
        objChapter.Type = 'Stand Chapter';
        objChapter.Acquired_By__c = 'C3 Acquired';
        objChapter.ParentId = objState.Id;
        objChapter.State_Abbreviation__c = 'HI';
        objChapter.BillingState = 'HI';
        Insert objChapter;
        
        // ------ Team 1-1 -------------
        Account objTeam1 = new Account();
        objTeam1.Name = 'Test Team11';
        objTeam1.Type = 'Stand Team';
        objTeam1.Acquired_By__c = 'C3 Acquired';
        objTeam1.ParentId = objChapter.Id;
        objTeam1.State_Abbreviation__c = 'HI';
	    objTeam1.BillingState = 'HI';
        Insert objTeam1;
        
         // ------ Contact 1 -------------
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact Chapter1';
        objContact.Stand_Office__c = 'HI';
        objContact.Recurring_Gift_Status__c = 'Active';
        Insert objContact;
        
        // create new membership (Join)
		Membership__c objMember = new Membership__c();
		objMember.Contact__c = objContact.Id;
		objMember.Membership_Action__c = 'Join';
		objMember.Membership_Source__c = 'Web';
		objMember.Membership_State__c = 'HI';
		objMember.Stand_Team__c = objTeam1.Id;
		objMember.Type__c = 'Sustaining';
		objMember.Gift_Amount__c = 25;	
		Insert objMember;
		
		Id idMember = objMember.Id;
		
		// back date the join so it expires tomorrow
		objMember.Membership_Action__c = 'Edit';
		objMember.Start_Date__c = mBackDate;
		
		update objMember;
		
		Membership_Activity__c ma = [ SELECT ID, start_date__c FROM Membership_Activity__c WHERE Membership__c =: idMember ];
		
		ma.start_date__c = mBackDate;
    	update ma;
    	
    	// check to see that the membership is still active and backdated to expire tomorrow
    	objMember = [ SELECT ID, Status2__c, Expiration_Date__c, Last_Renewal_Or_Join_Date__c FROM Membership__c WHERE ID =: idMember ];
    	
		System.assertEquals ( 'Active', objMember.Status2__c );
		System.assertEquals ( mDate.addDays ( 1 ), objMember.Expiration_Date__c );
		
		// run the update
		SustainerAutoRenewJob oSA = new SustainerAutoRenewJob ();
		
		// test DML error
        Test.setReadOnlyApplicationMode( true );
        
		oSA.renewSustainers();
		
		Test.setReadOnlyApplicationMode( false );
		
		// reload the membership and check the date
		objMember = [ SELECT ID, Status2__c, Expiration_Date__c, Last_Renewal_Or_Join_Date__c FROM Membership__c WHERE ID =: idMember ];
    	
    	// check all Membership Activity Records - confirm that we have one
    	List < Membership_Activity__c > listMa = new List < Membership_Activity__c > ( [ SELECT ID, start_date__c, subject__c FROM Membership_Activity__c WHERE Membership__c =: IdMember ] );
		
		System.assertEquals ( 1, listMa.size() );
		System.assertEquals ( mDate.addDays ( 1 ), objMember.Expiration_Date__c );
    	
	}
}