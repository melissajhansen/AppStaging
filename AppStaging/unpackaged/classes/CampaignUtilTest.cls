@isTest
private class CampaignUtilTest {

    static testMethod void CampaignUtilTest() {
        
        // create base objects
        
        // ------ Account -------------
        Account objAccount = new Account();
        objAccount.Name = 'Test Account1';
        objAccount.Type = 'Business';
        objAccount.Acquired_By__c = 'C3 Acquired';
        objAccount.State_Abbreviation__c = 'HI';
        Insert objAccount;
        
        // ------ Campaigns ------------
		Campaign childCampaign = new Campaign ();
		childCampaign.Name = 'Child Campaign';
		childCampaign.IsActive = True;
		childCampaign.Type = 'Fundraising';
		childCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		Insert childCampaign;
		Campaign checkChildCampaign = [SELECT ID FROM Campaign WHERE ID =: childCampaign.ID];
		
		Campaign parentCampaign = new Campaign ();
		parentCampaign.Name = 'Parent Campaign';
		parentCampaign.IsActive = True;
		parentCampaign.Type = 'Fundraising';
		parentCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		Insert parentCampaign;
		Campaign checkParCampaign = [SELECT ID FROM Campaign WHERE ID =: parentCampaign.ID];
		
		/*Campaign grandParentCampaign = new Campaign ();
		grandParentCampaign.Name = 'Grand Parent Campaign';
		grandParentCampaign.IsActive = True;
		grandParentCampaign.Type = 'Fundraising';
		grandParentCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		Insert grandParentCampaign;
		Campaign checkGrandParentCampaign = [SELECT ID FROM Campaign WHERE ID =: grandParentCampaign.ID];
		
		Campaign greatGrandParentCampaign = new Campaign ();
		greatGrandParentCampaign.Name = 'Great Grand Parent Campaign';
		greatGrandParentCampaign.IsActive = True;
		greatGrandParentCampaign.Type = 'Fundraising';
		greatGrandParentCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		Insert greatGrandParentCampaign;
		Campaign checkGreatGrandParentCampaign = [SELECT ID FROM Campaign WHERE ID =: greatGrandParentCampaign.ID];
		
		Campaign greatGreatGrandParentCampaign = new Campaign ();
		greatGreatGrandParentCampaign.Name = 'Great Great Grand Parent Campaign';
		greatGreatGrandParentCampaign.IsActive = True;
		greatGreatGrandParentCampaign.Type = 'Fundraising';
		greatGreatGrandParentCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		Insert greatGreatGrandParentCampaign;
		Campaign checkGreatGreatGrandParentCampaign = [SELECT ID FROM Campaign WHERE ID =: greatGreatGrandParentCampaign.ID];
		
		*/
		// Create an Opportunity
		Opportunity testOpp = new Opportunity ();
		testOpp.Name = 'TestOpportunity1';
		testOpp.AccountId = objAccount.Id;
		testOpp.Giver_Type__c = 'Business/Org';
		testOpp.CampaignId = checkChildCampaign.Id;
		testOpp.StageName = 'Closed Lost';
		testOpp.CloseDate = date.newInstance (2012,12,23);
		testOpp.Entity_Committed__c = 'Stand for Children, Inc. (C4)';
		testOpp.Community_Committed__c = 'OR';
		testOpp.Fund_Committed__c = 'Membership';
		testOpp.Fiscal_Year_Designation__c = 'FY12';
		testOpp.Amount = 50;
		Insert testOpp;
		Opportunity checkOpportunity = [SELECT AccountId, Fund_Committed__c, IsWon FROM Opportunity WHERE ID =: testOpp.ID];
		
		try {
			delete childCampaign;
		} catch (DMLException e){}
	/*	
		//Start the test, resets governor limits
		test.startTest();
		
		//Set the campaign Hierarchy
		childCampaign.ParentID = checkParCampaign.Id;
		update childCampaign;
		parentCampaign.ParentID = checkGrandParentCampaign.Id;
		
		//Stop the test, changes limit context back 
		test.stopTest();

		update parentCampaign;
		grandParentCampaign.ParentID = checkGreatGrandParentCampaign.Id;
		update grandParentCampaign;
		greatGrandParentCampaign.ParentID = checkGreatGreatGrandParentCampaign.Id;
		update greatGrandParentCampaign;
		
		// Check to see if Campaign ClosedLost Count is now 1 and the Parent Campaign and up all have Count child counts that are correct
		System.assertequals(1, childCampaign.Total_Closed_Lost_Donations__c);
		System.assertequals(1, checkParCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals(1, checkParCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		System.assertequals(1, checkGrandParentCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals(1, checkGrandParentCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		System.assertequals(1, checkGreatGrandParentCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals(1, checkGreatGrandParentCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		System.assertequals(1, checkGreatGreatGrandParentCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals(1, checkGreatGreatGrandParentCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);

		
		/*
		//Change the stage to Closed Won and check the relevant fields
		testOpp.StageName = 'Closed Won';
		update testOpp;
		
		System.assertequals(0, childCampaign.Total_Closed_Lost_Donations__c);
		System.assertequals(0, checkParCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals(0, checkParCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		System.assertequals(0, checkGrandParentCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals(0, checkGrandParentCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		System.assertequals(0, checkGreatGrandParentCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals(0, checkGreatGrandParentCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		System.assertequals(0, checkGreatGreatGrandParentCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals(0, checkGreatGreatGrandParentCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		
		//Set the stage back to ClosedLost Change the Campaign Hierarchy and Check the numbers
		testOpp.StageName = 'Closed Lost';
		update testOpp;
		
		childCampaign.ParentID = null;
		update childCampaign;
		
		System.assertequals(1, childCampaign.Total_Closed_Lost_Donations__c);
		System.assertequals(0, checkParCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals(0, checkParCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		System.assertequals(0, checkGrandParentCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals(0, checkGrandParentCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		System.assertequals(0, checkGreatGrandParentCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals(0, checkGreatGrandParentCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
		System.assertequals(0, checkGreatGreatGrandParentCampaign.Total_Closed_Lost_Donations_in_Children__c);
		System.assertequals(0, checkGreatGreatGrandParentCampaign.Total_Closed_Lost_Donations_in_Hierarchy__c);
        */
    }
}