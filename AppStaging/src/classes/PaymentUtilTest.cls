@isTest
public class PaymentUtilTest {
	
	public static TestMethod void PaymentCnPTest() {
	
		// create base objects
		DateTime dt = System.now ();
		Date mDate = date.newInstance ( dt.year(), dt.month(), dt.day() );
		String test_Name 	= 'TEST-CNP-CQ-Loader-1';
		String occupation_Value = 'Organizer';
		String employerName_value = 'Stand for Children';
		String employerAddress_value = '123 Main';
		String campaign_Value = 'Test Campaign1';
		
		// ------ Contact -------------
		Contact objContact = new Contact();
    	objContact.FirstName = 'Tester1';
    	objContact.LastName = 'Contact1';
    	objContact.email = 'test1@stand.org';
    	objContact.MailingStreet = '123 Main';
    	objContact.MailingCity = 'Springfield';
    	objContact.MailingState = 'OR';
    	objContact.MailingPostalCode = '97213';
		objContact.Anonymous_Donor__c = true;
		insert objContact;
        
        Contact c1 = [select ID, Name, MailingStreet, AccountID from Contact where ID =: objContact.ID];
        Account a1 = [SELECT ID, Name, BillingStreet FROM Account where ID =: c1.AccountId];
        
        //system.assertequals(a1.BillingStreet, c1.MailingStreet);
        //system.assertequals(a1.Name, c1.Name);
        
               
		// ------ Campaign ------------
		Campaign objCampaign = new Campaign ();
		objCampaign.Name = 'Test Campaign1';
		objCampaign.IsActive = True;
		objCampaign.Type = 'Fundraising';
		objCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		insert objCampaign;
		
		// Create a CnP Transaction
		CnP_PaaS__CnP_Transaction__c objCPTrans1 = new CnP_PaaS__CnP_Transaction__c ();
		objCPTrans1.Name = test_Name;
		objCPTrans1.CnP_PaaS__Contact__c = objContact.ID;
		objCPTrans1.CnP_PaaS__Account__c = c1.AccountId;
		objCPTrans1.CnP_PaaS__AutorizationCode__c = '12345';
		objCPTrans1.CnP_PaaS__Amount__c = 50;
		objCPTrans1.CnP_paas__tracker__c = 'test';
		objCPTrans1.CnP_PaaS__Credit_Card_Name__c = 'VISA';
		objCPTrans1.CnP_PaaS__TotalDue__c = 50;
		objCPTrans1.CnP_PaaS__TransactionDate__c = dt;
		objCPTrans1.CnP_PaaS__TransactionTimeZone__c = dt;
		objCPTrans1.cnp_paas__cardexpiration__c = '02/2015';
		objCPTrans1.cnp_paas__cnp_account_id__c = 'Stand For Children';		
		objCPTrans1.cnp_paas__creditcard4x4__c = 'xxxx xxxx xxxx 1111';		
		objCPTrans1.cnp_paas__email__c = 'test1@stand.org';		
		objCPTrans1.cnp_paas__name_on_card__c = 'Melissa Prcic';
		objCPTrans1.cnp_paas__paymenttype__c = 'Credit Card';

		insert objCPTrans1;
		
		//Create custom questions for CnP Transaction
		CnP_PaaS__Custom_Question__c cq = new CnP_PaaS__Custom_Question__c ();
		cq.Name = test_Name;
		cq.CnP_PaaS__Answer__c = occupation_Value;
		cq.CnP_PaaS__Custom_Question__c = 'Occupation'; 
		insert cq;
		
		cq = new CnP_PaaS__Custom_Question__c ();
		cq.Name = test_Name;
		cq.CnP_PaaS__Answer__c = employerName_value;
		cq.CnP_PaaS__Custom_Question__c = 'Employer Name'; 
		insert cq;
		
		cq = new CnP_PaaS__Custom_Question__c ();
		cq.Name = test_Name;
		cq.CnP_PaaS__Answer__c = employerAddress_value;
		cq.CnP_PaaS__Custom_Question__c = 'Employer Address'; 
		insert cq;
		
		System.assertequals(objCPTrans1.CnP_PaaS__TotalDue__c, 50);
		
		//Create a Corresponding Opportunity (cannot Automatically generate Opp from C&P Trans outside of UI)
		Opportunity testOpp1= new Opportunity ();
		testOpp1.Name = 'TestOpportunity1';
		testOpp1.AccountId = c1.AccountId;
		testOpp1.Giver_Type__c = 'Business/Org';
		testOpp1.CampaignId = objCampaign.Id;
		testOpp1.StageName = 'C&P Received';
		testOpp1.CloseDate = mDate;
		testOpp1.Entity_Committed__c = 'Stand for Children, Inc. (C4)';
		testOpp1.Community_Committed__c = 'OR';
		testOpp1.Fund_Committed__c = 'Membership';
		testOpp1.Fiscal_Year_Designation__c = 'FY12';
		testOpp1.Amount = 50;
		testOpp1.CnP_PaaS__CnP_OrderNumber__c = objCPTrans1.ID;
		Insert testOpp1;
		
		
		// reloading the opportunity, check to make sure that we have only one record
		List < Opportunity > checkOpportunity = new List < Opportunity > ([SELECT ID, CnP_PaaS__CnP_OrderNumber__c FROM Opportunity WHERE CnP_PaaS__CnP_OrderNumber__c =: objCPTrans1.ID]);
		System.assertequals( 1, checkOpportunity.size() );
		
		// reloading the payment, check to make sure that we have only one record
		List <npe01__OppPayment__c> checkPayment = new List < npe01__OppPayment__c > ([SELECT ID, Authorization_Code__c, Cardholder_Name__c, PAC_Occupation__c, PAC_Employer_Name__c, PAC_Employer_Address__c, Gift_Portal__c, Card_Type__c, npe01__Payment_Method__c, PAC_Donor_Name__c, PAC_Donor_Address__c FROM npe01__OppPayment__c WHERE npe01__Opportunity__c =: checkOpportunity[0].Id]);
		System.assertequals( 1, checkPayment.size() );
		
		// checking that CnP data made it to the payment
		System.assertequals(objCPTrans1.CnP_PaaS__AutorizationCode__c, checkPayment[0].Authorization_Code__c);
		System.assertequals(checkPayment[0].Cardholder_Name__c, 'Melissa Prcic');
		System.assertequals(checkPayment[0].PAC_Occupation__c, occupation_Value);
		System.assertequals(checkPayment[0].PAC_Employer_Name__c, employerName_value);
		System.assertequals(checkPayment[0].PAC_Employer_Address__c, employerAddress_value);
		System.assertequals(checkPayment[0].Gift_Portal__c, 'Web');
		System.assertequals(checkPayment[0].Card_Type__c, 'VISA');
		System.assertequals(checkPayment[0].npe01__Payment_Method__c, 'Credit Card');
		//System.assertequals(checkPayment[0].PAC_Donor_Name__c, 'Tester1 Contact1');
		//System.assertequals(checkPayment[0].PAC_Donor_Address__c, '123 Main, Springfield, OR, 97213');
	}

	static testMethod void DatetoMonthStringTest () {
	
		// create base objects
		DateTime dt = System.now ();
		Date mDate = date.newInstance ( dt.year(), dt.month(), dt.day() );
		String test_Name 	= 'TEST-CNP-CQ-Loader-1';
		String occupation_Value = 'Organizer';
		String employerName_value = 'Stand for Children';
		String employerAddress_value = '123 Main';
		String campaign_Value = 'Test Campaign1';
		
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
		objCampaign.Name = 'Test Campaign1';
		objCampaign.IsActive = True;
		objCampaign.Type = 'Fundraising';
		objCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		insert objCampaign;
		
		/*
		for (Integer i=1; i <11; i++) {
			CnP_PaaS__CnP_Transaction__c objCPTrans = new CnP_PaaS__CnP_Transaction__c(Name = 'test_Name' + i);
			objCPTrans.CnP_PaaS__Contact__c = objContact.ID;
			objCPTrans.CnP_PaaS__Account__c = c1.AccountId;
			objCPTrans.CnP_PaaS__AutorizationCode__c = '12345';
			objCPTrans.CnP_PaaS__TotalDue__c = 50;
			objCPTrans.CnP_PaaS__TransactionDate__c = dt;
			objCPTrans.CnP_PaaS__TransactionTimeZone__c = dt;
			objCPTrans.cnp_paas__cardexpiration__c = '0'+i+'/2015';
			objCPTrans.cnp_paas__email__c = 'test1@stand.org';		
			insert objCPTrans;
			
			//Create a Corresponding Opportunity (cannot Automatically generate Opp from C&P Trans outside of UI)
			Opportunity testOpp= new Opportunity (Name = 'TestOpportunity' + i);
			testOpp.AccountId = c1.AccountId;
			testOpp.Giver_Type__c = 'Business/Org';
			testOpp.CampaignId = objCampaign.Id;
			testOpp.StageName = 'C&P Received';
			testOpp.CloseDate = mDate;
			testOpp.Entity_Committed__c = 'Stand for Children, Inc. (C4)';
			testOpp.Community_Committed__c = 'OR';
			testOpp.Fund_Committed__c = 'Membership';
			testOpp.Fiscal_Year_Designation__c = 'FY12';
			testOpp.Amount = 50;
			testOpp.CnP_PaaS__CnP_OrderNumber__c = objCPTrans.ID;
			Insert testOpp;
		}
		*/		
	}

	public static TestMethod void DatetoMonthStringTest2() {
		String monthTest;
		String monthResponse;
		for ( integer i = 1; i <= 12; i++ ) {
			if ( i < 10 ) {
				monthTest = '0' + i + '/0' + i + '/0' + i;
			} else {
				monthTest = i + '/' + i + '/' + i;
			}
			monthResponse = PaymentUtil.DatetoMonthString(monthTest);
		}
	}
	
}