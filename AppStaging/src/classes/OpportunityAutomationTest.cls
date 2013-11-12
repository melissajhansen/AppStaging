@isTest
private class OpportunityAutomationTest {
	
	static testMethod void OpportunityLastMemGiftTest () {

		User objUser = [SELECT ID FROM User WHERE Name = 'Melissa Prcic'];
		System.runAs(objUser)
		{

		// create base objects
				
		// ------ Account -------------
        Account objAccount = new Account();
        objAccount.Name = 'Test Account1';
        objAccount.Type = 'Business';
        objAccount.Acquired_By__c = 'C3 Acquired';
        objAccount.State_Abbreviation__c = 'HI';
        Insert objAccount;
        
		// ------ Campaign ------------
		Campaign objCampaign = new Campaign ();
		objCampaign.Name = 'Test Campaign1';
		objCampaign.IsActive = True;
		objCampaign.Type = 'Fundraising';
		objCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		Insert objCampaign;
		
		// Create an Opportunity
		Opportunity testOpp1 = new Opportunity ();
		testOpp1.Name = 'TestOpportunity1';
		testOpp1.AccountId = objAccount.Id;
		testOpp1.Giver_Type__c = 'Business/Org';
		testOpp1.CampaignId = objCampaign.Id;
		testOpp1.StageName = 'Received';
		testOpp1.CloseDate = date.newInstance (2012,12,23);
		testOpp1.Entity_Committed__c = 'Stand for Children, Inc. (C4)';
		testOpp1.Community_Committed__c = 'OR';
		testOpp1.Fund_Committed__c = 'Membership';
		testOpp1.Fiscal_Year_Designation__c = 'FY12';
		testOpp1.Amount = 50;
		Insert testOpp1;
		Opportunity checkOpportunity1 = [SELECT AccountId, Fund_Committed__c, IsWon FROM Opportunity WHERE ID =: testOpp1.ID];
		System.debug ( ' --------------------------------- ');
		System.debug ( checkOpportunity1.accountID );
		System.debug ( checkOpportunity1.Fund_Committed__c );
		System.debug ( checkOpportunity1.IsWon );
		System.debug ( objAccount.Id );
		
		// Check to see if Account has the new value as Last Membership Gift Amount
		Account checkAccount1 = [SELECT Last_Membership_Gift_Amount__c FROM Account WHERE ID =: objAccount.ID];
		System.assertequals(testOpp1.Amount, checkAccount1.Last_Membership_Gift_Amount__c);
				
		// Create an Opportunity
		Opportunity testOpp2 = new Opportunity ();
		testOpp2.Name = 'TestOpportunity2';
		testOpp2.AccountId = objAccount.Id;
		testOpp2.Giver_Type__c = 'Business/Org';
		testOpp2.CampaignId = objCampaign.Id;
		testOpp2.StageName = 'Received';
		testOpp2.CloseDate = date.newInstance (2012,12,28);
		testOpp2.Entity_Committed__c = 'Stand for Children, Inc. (C4)';
		testOpp2.Community_Committed__c = 'OR';
		testOpp2.Fund_Committed__c = 'Membership';
		testOpp2.Fiscal_Year_Designation__c = 'FY12';
		testOpp2.Amount = 75;
		Insert testOpp2;
		
		// Check to see if Account has the new value as Last Membership Gift Amount
		checkAccount1 = [SELECT Last_Membership_Gift_Amount__c FROM Account WHERE ID =: objAccount.ID];
		System.assertequals(testOpp2.Amount, checkAccount1.Last_Membership_Gift_Amount__c);
		
		// Update an Opportunity
		testOpp2.Fund_Committed__c = 'General Fund';
		Update testOpp2;
		
		//Check to see if Last Mem Gift Amount has reverted to the Amount from Test Opp1
		checkAccount1 = [SELECT Last_Membership_Gift_Amount__c FROM Account WHERE ID =: objAccount.ID];
		System.assertequals (testOpp1.Amount, checkAccount1.Last_Membership_Gift_Amount__c);
		
		//Delete the First Opportunity and check for LastMemGiftAmt = NULL
		Delete testOpp1;
		
		//Check to see if LastMeme GIft amount is null
		checkAccount1 = [SELECT Last_Membership_Gift_Amount__c FROM Account WHERE ID =: objAccount.ID];
		System.assertequals (0, checkAccount1.Last_Membership_Gift_Amount__c);
	
		}
	
	}
	
	static testMethod void CustomQuestionLoaderTest () {

		
		// create base objects
		DateTime dt = System.now ();
		Date mDate = date.newInstance ( dt.year(), dt.month(), dt.day() );
		String test_Name = 'TEST-CNP-CQ-Loader-1';
		String entity_Value = 'Stand for Children, Inc. (C4)';
		String community_Value = 'Oregon General';
		String fund_Value = 'Membership';
		String campaign_Value = 'Test Campaign 1';
	
		// ------ Contact -------------
		Contact objContact = new Contact();
    	objContact.FirstName = 'Tester1';
    	objContact.LastName = 'Contact1';
    	objContact.email = 'test1@stand.org';
		objContact.MailingPostalCode = '01072';
		objContact.Anonymous_Donor__c = true;
		insert objContact;
        
        Contact c1 = [select ID, AccountID from Contact where ID =: objContact.ID];
               
		// ------ Campaign ------------
		Campaign objCampaign = new Campaign ();
		objCampaign.Name = 'Test Campaign 1';
		objCampaign.IsActive = True;
		objCampaign.Type = 'Fundraising';
		objCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		insert objCampaign;
        
		// create a CnP transaction and custom questions
		CnP_PaaS__CnP_Transaction__c t = new CnP_PaaS__CnP_Transaction__c ();
		t.Name = test_Name;
		t.CnP_PaaS__Contact__c = objContact.ID;
		t.CnP_PaaS__Account__c = c1.AccountId;
		t.cnp_paas__email__c = 'test1@stand.org';
		t.CnP_PaaS__TotalDue__c = 25.00;
		t.CnP_PaaS__TransactionDate__c = dt;
		t.CnP_PaaS__TransactionTimeZone__c = dt;
		insert t;

		CnP_PaaS__Custom_Question__c cq = new CnP_PaaS__Custom_Question__c ();
		cq.Name = test_Name;
		cq.CnP_PaaS__Answer__c = entity_Value;
		cq.CnP_PaaS__Custom_Question__c = 'Entity'; 
		insert cq;
		
		cq = new CnP_PaaS__Custom_Question__c ();
		cq.Name = test_Name;
		cq.CnP_PaaS__Answer__c = community_Value;
		cq.CnP_PaaS__Custom_Question__c = 'Community'; 
		insert cq;
		
		cq = new CnP_PaaS__Custom_Question__c ();
		cq.Name = test_Name;
		cq.CnP_PaaS__Answer__c = fund_Value;
		cq.CnP_PaaS__Custom_Question__c = 'Fund'; 
		insert cq;
				
		cq = new CnP_PaaS__Custom_Question__c ();
		cq.Name = test_Name;
		cq.CnP_PaaS__Answer__c = campaign_Value;
		cq.CnP_PaaS__Custom_Question__c = 'Campaign'; 
		insert cq;
				
		//Create a Corresponding Opportunity (cannot Automatically generate Opp from C&P Trans outside of UI)
		Opportunity testOpp1 = new Opportunity ();
		testOpp1.Name = 'TestOpportunity1';
		testOpp1.AccountId = c1.AccountId;
		testOpp1.Giver_Type__c = 'Business/Org';
		//testOpp1.CampaignId = objCampaign.Id;
		testOpp1.StageName = 'Received';
		testOpp1.CloseDate = date.newInstance (2012,12,23);
		//testOpp1.Entity_Committed__c = 'Stand for Children, Inc. (C4)';
		//testOpp1.Community_Committed__c = 'Oregon General';
		//testOpp1.Fund_Committed__c = 'Membership';
		testOpp1.Fiscal_Year_Designation__c = 'FY12';
		testOpp1.Amount = 50;
		testOpp1.CnP_PaaS__CnP_OrderNumber__c = t.ID;
		Insert testOpp1;
		
				
		// reloading the opportunity, check to make sure that we have only one record
		List < Opportunity > checkOpportunity = new List < Opportunity > ([SELECT ID, CnP_PaaS__CnP_OrderNumber__c, Community_Committed__c, Entity_Committed__c, Fund_Committed__c, CampaignID, Giver_Type__c FROM Opportunity WHERE CnP_PaaS__CnP_OrderNumber__c =: t.ID]);
		System.assertequals( 1, checkOpportunity.size() );
	
		//Check that the Custom Questions filled in the corresponding Opportunity fields correctly
		System.assertequals(community_Value, checkOpportunity[0].Community_Committed__c);
		System.assertequals(entity_Value, checkOpportunity[0].Entity_Committed__c);
		System.assertequals(fund_Value, checkOpportunity[0].Fund_Committed__c);
		System.assertequals('Individual', checkOpportunity[0].Giver_Type__c);
		System.assertequals(objCampaign.Id, checkOpportunity[0].CampaignId);
		
	}
	
	static testMethod void ZeroClosedLostGiftsTest () {

		// create base objects
				
		// ------ Account -------------
        Account objAccount = new Account();
        objAccount.Name = 'Test Account1';
        objAccount.Type = 'Business';
        objAccount.Acquired_By__c = 'C3 Acquired';
        objAccount.State_Abbreviation__c = 'HI';
        Insert objAccount;
        
		// ------ Campaign ------------
		Campaign objCampaign = new Campaign ();
		objCampaign.Name = 'Test Campaign1';
		objCampaign.IsActive = True;
		objCampaign.Type = 'Fundraising';
		objCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		Insert objCampaign;
		
		// Create an Opportunity
		Opportunity testOpp = new Opportunity ();
		testOpp.Name = 'TestOpportunity1';
		testOpp.AccountId = objAccount.Id;
		testOpp.Giver_Type__c = 'Business/Org';
		testOpp.CampaignId = objCampaign.Id;
		testOpp.StageName = 'Closed Lost';
		testOpp.CloseDate = date.newInstance (2012,12,23);
		testOpp.Entity_Committed__c = 'Stand for Children, Inc. (C4)';
		testOpp.Community_Committed__c = 'OR';
		testOpp.Fund_Committed__c = 'Membership';
		testOpp.Fiscal_Year_Designation__c = 'FY12';
		testOpp.Amount = 50;
		Insert testOpp;
		Opportunity checkOpportunity = [SELECT AccountId, Fund_Committed__c, IsWon FROM Opportunity WHERE ID =: testOpp.ID];
			

		// Check to see if Account is Zero after Insert with Closed Lost Stage
		checkOpportunity = [SELECT AccountId, Fund_Committed__c, IsWon, Amount FROM Opportunity WHERE ID =: testOpp.ID];
		System.assertequals(checkOpportunity.Amount, 0);
		
		//Change the Opportunity back to Closed-Won With a Positive amount to set up for udpate test
		testOpp.StageName = 'Closed Won';
		testOpp.Amount = 50;
		update testOpp;
		
		//Verify the Amount is now Positive
		checkOpportunity = [SELECT AccountId, Fund_Committed__c, IsWon, Amount FROM Opportunity WHERE ID =: testOpp.ID];
		system.assertequals(checkOpportunity.Amount, 50);
		
		
		//Change the Opportunity to Closed Lost and verify amount set back to 0 after update
		testOpp.StageName = 'Closed Lost';
		update testOpp;
		
		//Verify the Amount is now Zero
		checkOpportunity = [SELECT AccountId, Fund_Committed__c, IsWon, Amount FROM Opportunity WHERE ID =: testOpp.ID];
		system.assertequals(checkOpportunity.Amount, 0);
		
	}
	
		static testMethod void PaymentCheckboxOverrideTest () {

		// create base objects
				
		// ------ Account -------------
        Account objAccount = new Account();
        objAccount.Name = 'Test Account1';
        objAccount.Type = 'Business';
        objAccount.Acquired_By__c = 'C3 Acquired';
        objAccount.State_Abbreviation__c = 'HI';
        Insert objAccount;
        
		// ------ Campaign ------------
		Campaign objCampaign = new Campaign ();
		objCampaign.Name = 'Test Campaign1';
		objCampaign.IsActive = True;
		objCampaign.Type = 'Fundraising';
		objCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		Insert objCampaign;
		
		// Create an Opportunity with Opportunity Record Type
		Opportunity testOpp = new Opportunity ();
		testOpp.Name = 'TestOpportunity1';
		testOpp.RecordTypeId = '012E0000000MEz3';
		testOpp.AccountId = objAccount.Id;
		testOpp.Giver_Type__c = 'Business/Org';
		testOpp.CampaignId = objCampaign.Id;
		testOpp.StageName = 'Closed Won';
		testOpp.CloseDate = date.newInstance (2012,12,23);
		testOpp.Entity_Committed__c = 'Stand for Children, Inc. (C4)';
		testOpp.Community_Committed__c = 'OR';
		testOpp.Fund_Committed__c = 'Membership';
		testOpp.Fiscal_Year_Designation__c = 'FY12';
		testOpp.Amount = 50;
		Insert testOpp;
		Opportunity checkOpportunity = [SELECT AccountId, npe01__Do_Not_Automatically_Create_Payment__c, Do_Not_Auto_Create_Payment_Opp_Override__c, Fund_Committed__c, IsWon FROM Opportunity WHERE ID =: testOpp.ID];
		

		// Verify the NPSP Override Ceckbox has been checked by default
		System.assertequals(true, checkOpportunity.npe01__Do_Not_Automatically_Create_Payment__c);
		
		
		//Update the custom override checkbox and verify that the NPSP box has been updated as well.
		testOpp.Do_Not_Auto_Create_Payment_Opp_Override__c = false;
		update testOpp;
		
		checkOpportunity = [SELECT AccountId, npe01__Do_Not_Automatically_Create_Payment__c, Do_Not_Auto_Create_Payment_Opp_Override__c, Fund_Committed__c, IsWon FROM Opportunity WHERE ID =: testOpp.ID];
		System.assertequals(false, checkOpportunity.Do_Not_Auto_Create_Payment_Opp_Override__c);
		System.assertequals(false, checkOpportunity.npe01__Do_Not_Automatically_Create_Payment__c);
		
		// Create an Opportunity with Simple Record Type
		Opportunity testDon = new Opportunity ();
		testDon.Name = 'TestOpportunity1';
		testDon.AccountId = objAccount.Id;
		testDon.Giver_Type__c = 'Business/Org';
		testDon.CampaignId = objCampaign.Id;
		testDon.StageName = 'Closed Won';
		testDon.CloseDate = date.newInstance (2012,12,23);
		testDon.Entity_Committed__c = 'Stand for Children, Inc. (C4)';
		testDon.Community_Committed__c = 'OR';
		testDon.Fund_Committed__c = 'Membership';
		testDon.Fiscal_Year_Designation__c = 'FY12';
		testDon.Amount = 50;
		Insert testDon;
		Opportunity checkSimpleDonation = [SELECT AccountId, npe01__Do_Not_Automatically_Create_Payment__c, Do_Not_Auto_Create_Payment_Opp_Override__c, Fund_Committed__c, IsWon FROM Opportunity WHERE ID =: testDon.ID];
		
		// Verify that NPSP Override Ceckbox has NOT been checked by default for simple donation
		System.assertequals(false, checkSimpleDonation.npe01__Do_Not_Automatically_Create_Payment__c);

		
	}
	
	static testMethod void CampaignLostCountTest () {

		// create base objects
				
		// ------ Account -------------
        Account objAccount = new Account();
        objAccount.Name = 'Test Account1';
        objAccount.Type = 'Business';
        objAccount.Acquired_By__c = 'C3 Acquired';
        objAccount.State_Abbreviation__c = 'HI';
        Insert objAccount;
        
		// ------ Campaigns ------------
		Campaign objCampaign = new Campaign ();
		objCampaign.Name = 'Test Campaign1';
		objCampaign.IsActive = True;
		objCampaign.Type = 'Fundraising';
		objCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		Insert objCampaign;
		
		Campaign objCampaign2 = new Campaign ();
		objCampaign2.Name = 'Test Campaign2';
		objCampaign2.IsActive = True;
		objCampaign2.Type = 'Fundraising';
		objCampaign2.Entity__c = 'Stand for Children, Inc. (C4)';
		Insert objCampaign2;
		Campaign checkParCampaign = [SELECT ID FROM Campaign WHERE ID =: objCampaign2.ID];
		
		//update the first campaign to make the second campaign its parent
		objCampaign.ParentId = checkParCampaign.Id;
		Update objCampaign;
		
		// Create an Opportunity
		Opportunity testOpp = new Opportunity ();
		testOpp.Name = 'TestOpportunity1';
		testOpp.AccountId = objAccount.Id;
		testOpp.Giver_Type__c = 'Business/Org';
		testOpp.CampaignId = objCampaign.Id;
		testOpp.StageName = 'Closed Lost';
		testOpp.CloseDate = date.newInstance (2012,12,23);
		testOpp.Entity_Committed__c = 'Stand for Children, Inc. (C4)';
		testOpp.Community_Committed__c = 'OR';
		testOpp.Fund_Committed__c = 'Membership';
		testOpp.Fiscal_Year_Designation__c = 'FY12';
		testOpp.Amount = 50;
		Insert testOpp;
		Opportunity checkOpportunity = [SELECT AccountId, Fund_Committed__c, IsWon FROM Opportunity WHERE ID =: testOpp.ID];
			
		//Start the test, resets governor limits
		test.startTest();
		
		// Check to see if Campaign ClosedLost Count is now 1//and the Parent Campaign Count child & Hierarchy Counts are correct
		Campaign checkCampaign = [SELECT ID, Total_Closed_Lost_Donations__c FROM Campaign WHERE ID =: objCampaign.ID];
		checkParCampaign = [SELECT ID, Total_Closed_Lost_Donations_in_Hierarchy__c, Total_Closed_Lost_Donations_in_Children__c FROM Campaign Where ID =:objCampaign2.ID];
		System.assertequals(1, checkCampaign.Total_Closed_Lost_Donations__c);
		System.assertequals (1, checkParCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals (1, checkParCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		system.debug ('**********************************TotalClosedLostDonations'+checkCampaign.Total_Closed_Lost_Donations__c);
		
		//Change the Opportunity back to Closed-Won With a Positive amount to set up for udpate test
		testOpp.StageName = 'Closed Won';
		testOpp.Amount = 50;
		update testOpp;
		
		//Verify that the Campaign Closed Lost Count is now 0 
		checkCampaign = [SELECT ID, Total_Closed_Lost_Donations__c FROM Campaign WHERE ID =: objCampaign.ID];
		checkParCampaign = [SELECT ID, Total_Closed_Lost_Donations_in_Hierarchy__c, Total_Closed_Lost_Donations_in_Children__c FROM Campaign Where ID =:objCampaign2.ID];
		system.assertequals (0, checkCampaign.Total_Closed_Lost_Donations__c);
		System.assertequals (0, checkParCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals (0, checkParCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		
		testOpp.StageName = 'Closed Lost';
		testOpp.Amount = 50;
		update testOpp;
		
		//Change the Opportunity to Closed Lost and verify count is set back to 1 after update
		checkCampaign = [SELECT ID, Total_Closed_Lost_Donations__c FROM Campaign WHERE ID =: objCampaign.ID];
		checkParCampaign = [SELECT ID, Total_Closed_Lost_Donations_in_Hierarchy__c, Total_Closed_Lost_Donations_in_Children__c FROM Campaign Where ID =:objCampaign2.ID];
		System.assertequals(1, checkCampaign.Total_Closed_Lost_Donations__c);
		System.assertequals (1, checkParCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals (1, checkParCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		
		//Change the Campaign Hierarchy and check the Parent Campaign Counts
		objCampaign.ParentId = null;
		Update objCampaign;
		checkParCampaign = [SELECT ID, Total_Closed_Lost_Donations_in_Hierarchy__c, Total_Closed_Lost_Donations_in_Children__c FROM Campaign Where ID =:objCampaign2.ID];
		System.assertequals (0, checkParCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals (0, checkParCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		
		//Delete the Opportunity and verify count is back to zero
		delete testOpp;
		checkCampaign = [SELECT ID, Total_Closed_Lost_Donations__c FROM Campaign WHERE ID =: objCampaign.ID];
		checkParCampaign = [SELECT ID, Total_Closed_Lost_Donations_in_Hierarchy__c, Total_Closed_Lost_Donations_in_Children__c FROM Campaign Where ID =:objCampaign2.ID];
		System.assertequals(0, checkCampaign.Total_Closed_Lost_Donations__c);
		System.assertequals (0, checkParCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals (0, checkParCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		
		//Stop the test, changes limit context back 
		test.stopTest();
		
		
	}
		
}