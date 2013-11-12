@isTest
private class OpportunityAutomation_Test2 {
	
	static testMethod void TestAnonGifts1 () {
		// single Contact test
		// ------ Contact -------------
		Contact objContact = new Contact();
    	objContact.FirstName = 'Tester1';
    	objContact.LastName = 'Contact1';
    	objContact.email = 'test1@stand.org';
		objContact.MailingPostalCode = '01072';
		objContact.Anonymous_Donor__c = true;
		insert objContact;
        
        Contact c1 = [select ID, AccountId from Contact where ID =: objContact.ID];
       
		// ------ Campaign ------------
		Campaign objCampaign = new Campaign ();
		objCampaign.Name = 'Test Campaign1';
		objCampaign.IsActive = True;
		objCampaign.Type = 'Fundraising';
		objCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		insert objCampaign;
		
		// Create an Opportunity
		Opportunity testOpp1 = new Opportunity ();
		testOpp1.Name = 'TestOpportunity1';
		testOpp1.AccountId = c1.AccountId;
		testOpp1.Giver_Type__c = 'Individual';
		testOpp1.RecordType = [ select Id from RecordType where Name = 'Simple Donation' and SobjectType = 'Opportunity' ];
		testOpp1.CampaignId = objCampaign.Id;
		testOpp1.StageName = 'Active-Medium';
		testOpp1.CloseDate = date.newInstance (2012,12,23);
		testOpp1.Entity_Committed__c = 'Stand for Children, Inc. (C4)';
		testOpp1.Community_Committed__c = 'MA';
		testOpp1.Community_Planned__c = 'Massachusetts General';
		testOpp1.Fund_Committed__c = 'Membership';
		testOpp1.Fiscal_Year_Designation__c = 'FY12';
		testOpp1.Amount = 50;
		Test.startTest();
		insert testOpp1;
		Test.stopTest();
		
		List <Opportunity> oList = ([SELECT ID, Name, AccountId, Anonymous__c FROM Opportunity WHERE AccountId =: c1.AccountId]);
		for (Opportunity o : oList) {
			System.assertEquals (o.ID, testOpp1.ID);
			System.assertEquals (o.Name, testOpp1.Name);
			System.assertEquals (o.AccountId, testOpp1.AccountId);
			System.assertEquals (o.Anonymous__c, true);
		}
		
		Contact checkContact1 = [SELECT Anonymous_Donor__c FROM Contact WHERE ID =: objContact.ID];
		System.assertEquals(objContact.Anonymous_Donor__c, checkContact1.Anonymous_Donor__c);
	}


	static testMethod void TestAnonGifts2 () {
		// single Organization test
		// ------ Account -------------
        Account objAccount = new Account();
        objAccount.Name = 'Test Account1';
        objAccount.Type = 'Business';
        objAccount.Acquired_By__c = 'C3 Acquired';
        objAccount.State_Abbreviation__c = 'HI';
        objAccount.Anonymous_Org_Donor__c = true;
        insert objAccount;
        
		// ------ Campaign ------------
		Campaign objCampaign = new Campaign ();
		objCampaign.Name = 'Test Campaign1';
		objCampaign.IsActive = True;
		objCampaign.Type = 'Fundraising';
		objCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		insert objCampaign;
		
		// Create an Opportunity
		Opportunity testOpp2 = new Opportunity ();
		testOpp2.Name = 'TestOpportunity1';
		testOpp2.AccountId = objAccount.Id;
		testOpp2.Giver_Type__c = 'Business/Org';
		testOpp2.CampaignId = objCampaign.Id;
		testOpp2.StageName = 'Received';
		testOpp2.CloseDate = date.newInstance (2012,12,23);
		testOpp2.Entity_Committed__c = 'Stand for Children, Inc. (C4)';
		testOpp2.Community_Committed__c = 'OR';
		testOpp2.Fund_Committed__c = 'Membership';
		testOpp2.Fiscal_Year_Designation__c = 'FY12';
		testOpp2.Amount = 50;
		Test.StartTest();
		insert testOpp2;
		Test.StopTest();
		
		List <Opportunity> oList2 = ([SELECT ID, Name, AccountId, Anonymous__c FROM Opportunity WHERE AccountId =: objAccount.Id]);
		for (Opportunity o : oList2) {
			System.assertEquals (o.ID, testOpp2.ID);
			System.assertEquals (o.Name, testOpp2.Name);
			System.assertEquals (o.AccountId, testOpp2.AccountId);
			System.assertEquals (o.Anonymous__c, true);
		}
		
		Account checkAccount1 = [SELECT Anonymous_Org_Donor__c FROM Account WHERE ID =: objAccount.ID];
		System.assertEquals(objAccount.Anonymous_Org_Donor__c, checkAccount1.Anonymous_Org_Donor__c);


	}
}