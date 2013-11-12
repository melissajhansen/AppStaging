@isTest
private class StandWebService_Test {

	public static Integer FirstLapsePeriod = 30;
	public static Integer SecondLapsePeriod = 7;
	public static Integer ThirdlapsePeriod = -7;

	public static TestMethod void TestMemberRequest()
	{
		// create new instance of the data to be passed to the web service
		StandWebService.MemberRequestInfo mR1 = new StandWebService.MemberRequestInfo();
		
		// create a new instance of the web service call
		StandWebService.MemberRequestInfoResponse mriR = new StandWebService.MemberRequestInfoResponse();
		
		// Test 1
		// token/contact found, active
		// no membership gift
	
        Contact objContactA = new Contact();
        objContactA.FirstName = 'MemberRequest';
        objContactA.LastName = 'Contact 1';
        objContactA.Stand_Office__c = 'OR';
        insert objContactA;

        Membership__c objMembershipA = new Membership__c();
        objMembershipA.Contact__c = objContactA.Id;
        objMembershipA.Membership_State__c = 'OR';          
        objMembershipA.Start_Date__c =  System.today();
        //objMembershipA.Gift_Amount__c = Decimal.valueOf('4.00');
        //objMembershipA.Type__c = 'Annual';    
        objMembershipA.Membership_Source__c = 'Web';
        objMembershipA.Membership_Action__c = 'Join';      
        insert objMembershipA; 
        
        objMembershipA.Start_Date__c =  System.today().addDays(FirstLapsePeriod-365);
        objMembershipA.Membership_Action__c = 'Edit';      
        update objMembershipA; 
        
        Contact objContactA1 = [SELECT Id, AccountId, Last_Membership_Gift_Amount__c FROM Contact WHERE Id =: objContactA.Id];
        System.AssertEquals(objContactA1.Last_Membership_Gift_Amount__c, 0);
        
		//mR1.token = objMembershipA.Id;
		Token t = new Token();
		Token.TokenCreateData TCD = new Token.TokenCreateData();
//		mR1.token = t.create(objMembershipA.Id, 'MemRenewLink');
		TCD = t.create(objMembershipA.Id, 'MemRenewLink');
		mR1.token = TCD.Token;
		String encodedToken = EncodingUtil.urlEncode(mR1.token, 'UTF-8');
		mR1.token = encodedToken;
		mriR = StandWebService.memberRequestTest(mR1);


		// Test 2
		// token/contact not found
		mR1.token = '12345';
		encodedToken = EncodingUtil.urlEncode(mR1.token, 'UTF-8');
		mR1.token = encodedToken;
		mriR = StandWebService.memberRequestTest(mR1);

		// Test 4
		// MemberComplete
		// revoke response = true
		// create new instance of the data to be passed to the web service
		StandWebService.MemberCompleteInfo mC1 = new StandWebService.MemberCompleteInfo();
		
		// create a new instance of the web service call
		StandWebService.MemberCompleteInfoResponse mciR = new StandWebService.MemberCompleteInfoResponse();

		TCD = new Token.TokenCreateData();
//		mC1.token = t.create(objMembershipA.Id, 'MemRenewLink');
		TCD = t.create(objMembershipA.Id, 'MemRenewLink');
		mC1.token = TCD.Token;
		encodedToken = EncodingUtil.urlEncode(mC1.token, 'UTF-8');
		mC1.token = encodedToken;

		// create the EmailQueue object
		EmailQueue__c e = new EmailQueue__c();
		e.Contact__c = objContactA.Id;
		e.EmailType__c = 'Single Lapsing Member Email';
		e.Name = objContactA.Name + ' Lapsing Email';
		e.To__c = 'SFDCTesting@stand.org';
		e.Subject__c = 'Your Membership Matters';
		String mToken = '';
		e.Body__c = '<span style=\'font-size:10.0pt;font-family:"News Gothic","sans-serif";color:black\'>Dear ' + objContactA.Name + '<br><br>It\'s time to renew your Stand for Children membership.  <b><a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">Renew your membership now</a>.</b><br><br>Your support over the past year resulted in tremendous gains in education for students across the country. We trained over 400 parents last semester to become more involved in their child\'s academics. We empowered thousands more to lobby at the district and state level in support of better public schools. Alongside our members, we’ve fought tirelessly for policies that improve education for <b>every child</b> in <b>every classroom.</b><br><br><b>You play an important role in this work - please <a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">renew your membership now</a>.</b><br><br>Together we can have a unified voice that will change the landscape of education for an entire generation of students. Thank you for your continued support.<br><br>Standing with You,<br><br><br>Simone Coker<br>Membership Associate<br><br><i>Your membership contribution is not tax-deductible. For more information or for questions about your membership, call us at (503) 308-7292 or email <a href="mailto:membership@stand.org">membership@stand.org</a>.</i>';		
		e.Token__c = TCD.TokenId;
		insert e;

		mciR = StandWebService.memberCompleteTest(mC1);


	}

	public static TestMethod void TestMemberRequest1() {
		// create new instance of the data to be passed to the web service
		StandWebService.MemberRequestInfo mR1 = new StandWebService.MemberRequestInfo();
		
		// create a new instance of the web service call
		StandWebService.MemberRequestInfoResponse mriR = new StandWebService.MemberRequestInfoResponse();

		// Test 3
		// token/contact found
		// has membership gift
        Contact objContactB = new Contact();
        objContactB.FirstName = 'MemberRequest';
        objContactB.LastName = 'Contact 2';
        objContactB.Stand_Office__c = 'OR';
        insert objContactB;
        
        Membership__c objMembershipB = new Membership__c();
        objMembershipB.Contact__c = objContactB.Id;
        objMembershipB.Membership_State__c = 'OR';          
        objMembershipB.Start_Date__c =  System.today();
        objMembershipB.Gift_Amount__c = Decimal.valueOf('50.00');
        objMembershipB.Type__c = 'Annual';    
        objMembershipB.Membership_Source__c = 'Event';
        objMembershipB.Membership_Action__c = 'Join';      
        insert objMembershipB;  	
        
        objMembershipB.Start_Date__c =  System.today().addDays(SecondLapsePeriod-365);
        objMembershipB.Membership_Action__c = 'Edit';      
        update objMembershipB; 
        
        Campaign objCampaign = new Campaign ();
		objCampaign.Name = 'Test Campaign1';
		objCampaign.IsActive = True;
		objCampaign.Type = 'Fundraising';
		objCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
		insert objCampaign;
        
		Contact objContactB1 = [SELECT Id, AccountId, Last_Membership_Gift_Amount__c FROM Contact WHERE Id =: objContactB.Id];
		
		Opportunity testOpp1 = [SELECT Id FROM Opportunity WHERE AccountId =: objContactB1.AccountId];
		
		npe01__OppPayment__c objPaymentA = [SELECT Id FROM npe01__OppPayment__c WHERE npe01__Opportunity__c = : testOpp1.Id];
		
		Gift_Batch__c objGiftBatch = [SELECT Id FROM Gift_Batch__c LIMIT 1];
		
		objPaymentA.Gift_Portal__c = 'Web';
		objPaymentA.Community__c = 'Boston';
		objPaymentA.Gift_Batches__c = objGiftBatch.Id;
		update objPaymentA;
		
		testOpp1.CampaignId = objCampaign.Id;
		testOpp1.Community_Committed__c = 'OR';
		testOpp1.StageName = 'Received';
		update testOpp1;
		
		Contact objContactB2 = [SELECT Id, AccountId, Last_Membership_Gift_Amount__c FROM Contact WHERE Id =: objContactB.Id];
		System.assertEquals(objContactB2.Last_Membership_Gift_Amount__c, 50);
		
		Token t = new Token();
		//mR1.token = objMembershipB.Id;
		Token.TokenCreateData TCD = new Token.TokenCreateData();
//		mR1.token = t.create(objMembershipB.Id, 'MemRenewLink');
		TCD = t.create(objMembershipB.Id, 'MemRenewLink');
		mR1.token = TCD.Token;
		String encodedToken = EncodingUtil.urlEncode(mR1.token, 'UTF-8');
		mR1.token = encodedToken;
		mriR = StandWebService.memberRequestTest(mR1);
		
	}

	public static TestMethod void TestMemberRequest2()
	{
		// create new instance of the data to be passed to the web service
		StandWebService.MemberRequestInfo mR1 = new StandWebService.MemberRequestInfo();
		
		// create a new instance of the web service call
		StandWebService.MemberRequestInfoResponse mriR = new StandWebService.MemberRequestInfoResponse();
		
		// create new instance of the data to be passed to the web service
		StandWebService.MemberCompleteInfo mC1 = new StandWebService.MemberCompleteInfo();
		
		// create a new instance of the web service call
		StandWebService.MemberCompleteInfoResponse mciR = new StandWebService.MemberCompleteInfoResponse();
		
		Token t = new Token();
		String encodedToken;
		
		// Test 5
		// Lapsed membership
		Contact objContactC = new Contact();
        objContactC.FirstName = 'MemberRequest';
        objContactC.LastName = 'Contact 5';
        objContactC.Stand_Office__c = 'OR';
        insert objContactC;

        Membership__c objMembershipC = new Membership__c();
        objMembershipC.Contact__c = objContactC.Id;
        objMembershipC.Membership_State__c = 'OR';          
        objMembershipC.Start_Date__c =  System.today();
        //objMembershipA.Gift_Amount__c = Decimal.valueOf('4.00');
        //objMembershipA.Type__c = 'Annual';    
        objMembershipC.Membership_Source__c = 'Web';
        objMembershipC.Membership_Action__c = 'Join';      
        insert objMembershipC; 
        
        objMembershipC.Start_Date__c =  System.today().addDays(-368);
        objMembershipC.Membership_Action__c = 'Edit';      
        update objMembershipC; 
        
        Token.TokenCreateData TCD = new Token.TokenCreateData();
//		mR1.token = t.create(objMembershipC.Id, 'MemRenewLink');
		TCD = t.create(objMembershipC.Id, 'MemRenewLink');
		mR1.token = TCD.Token;
		encodedToken = EncodingUtil.urlEncode(mR1.token, 'UTF-8');
		mR1.token = encodedToken;

		// create the EmailQueue object
		EmailQueue__c e = new EmailQueue__c();
		e.Contact__c = objContactC.Id;
		e.EmailType__c = 'Single Lapsing Member Email';
		e.Name = objContactC.Name + ' Lapsing Email';
		e.To__c = 'SFDCTesting@stand.org';
		e.Subject__c = 'Your Membership Matters';
		String mToken = '';
		e.Body__c = '<span style=\'font-size:10.0pt;font-family:"News Gothic","sans-serif";color:black\'>Dear ' + objContactC.Name + '<br><br>It\'s time to renew your Stand for Children membership.  <b><a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">Renew your membership now</a>.</b><br><br>Your support over the past year resulted in tremendous gains in education for students across the country. We trained over 400 parents last semester to become more involved in their child\'s academics. We empowered thousands more to lobby at the district and state level in support of better public schools. Alongside our members, we’ve fought tirelessly for policies that improve education for <b>every child</b> in <b>every classroom.</b><br><br><b>You play an important role in this work - please <a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">renew your membership now</a>.</b><br><br>Together we can have a unified voice that will change the landscape of education for an entire generation of students. Thank you for your continued support.<br><br>Standing with You,<br><br><br>Simone Coker<br>Membership Associate<br><br><i>Your membership contribution is not tax-deductible. For more information or for questions about your membership, call us at (503) 308-7292 or email <a href="mailto:membership@stand.org">membership@stand.org</a>.</i>';		
		e.Token__c = TCD.TokenId;
		insert e;

		mriR = StandWebService.memberRequestTest(mR1);


		// Test 6
		// Active membership, but outside lapse period (45 days)
		Contact objContactD = new Contact();
        objContactD.FirstName = 'MemberRequest';
        objContactD.LastName = 'Contact 6';
        objContactD.Stand_Office__c = 'OR';
        insert objContactD;

        Membership__c objMembershipD = new Membership__c();
        objMembershipD.Contact__c = objContactD.Id;
        objMembershipD.Membership_State__c = 'OR';          
        objMembershipD.Start_Date__c =  System.today();
        //objMembershipA.Gift_Amount__c = Decimal.valueOf('4.00');
        //objMembershipA.Type__c = 'Annual';    
        objMembershipD.Membership_Source__c = 'Web';
        objMembershipD.Membership_Action__c = 'Join';      
        insert objMembershipD; 
        
        objMembershipD.Start_Date__c =  System.today().addDays(-310);
        objMembershipD.Membership_Action__c = 'Edit';      
        update objMembershipD; 
        
        TCD = new Token.TokenCreateData();
//		mR1.token = t.create(objMembershipD.Id, 'MemRenewLink');
		TCD = t.create(objMembershipD.Id, 'MemRenewLink');
		mR1.token = TCD.Token;
		encodedToken = EncodingUtil.urlEncode(mR1.token, 'UTF-8');
		mR1.token = encodedToken;
		
		// create the EmailQueue object
		e = new EmailQueue__c();
		e.Contact__c = objContactD.Id;
		e.EmailType__c = 'Single Lapsing Member Email';
		e.Name = objContactD.Name + ' Lapsing Email';
		e.To__c = 'SFDCTesting@stand.org';
		e.Subject__c = 'Your Membership Matters';
		mToken = '';
		e.Body__c = '<span style=\'font-size:10.0pt;font-family:"News Gothic","sans-serif";color:black\'>Dear ' + objContactD.Name + '<br><br>It\'s time to renew your Stand for Children membership.  <b><a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">Renew your membership now</a>.</b><br><br>Your support over the past year resulted in tremendous gains in education for students across the country. We trained over 400 parents last semester to become more involved in their child\'s academics. We empowered thousands more to lobby at the district and state level in support of better public schools. Alongside our members, we’ve fought tirelessly for policies that improve education for <b>every child</b> in <b>every classroom.</b><br><br><b>You play an important role in this work - please <a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">renew your membership now</a>.</b><br><br>Together we can have a unified voice that will change the landscape of education for an entire generation of students. Thank you for your continued support.<br><br>Standing with You,<br><br><br>Simone Coker<br>Membership Associate<br><br><i>Your membership contribution is not tax-deductible. For more information or for questions about your membership, call us at (503) 308-7292 or email <a href="mailto:membership@stand.org">membership@stand.org</a>.</i>';		
		e.Token__c = TCD.TokenId;
		insert e;

		mriR = StandWebService.memberRequestTest(mR1);
		


		// Test 7
		// Active membership, token used
		Contact objContactE = new Contact();
        objContactE.FirstName = 'MemberRequest';
        objContactE.LastName = 'Contact 7';
        objContactE.Stand_Office__c = 'OR';
        insert objContactE;

        Membership__c objMembershipE = new Membership__c();
        objMembershipE.Contact__c = objContactE.Id;
        objMembershipE.Membership_State__c = 'OR';          
        objMembershipE.Start_Date__c =  System.today();
        //objMembershipA.Gift_Amount__c = Decimal.valueOf('4.00');
        //objMembershipA.Type__c = 'Annual';    
        objMembershipE.Membership_Source__c = 'Web';
        objMembershipE.Membership_Action__c = 'Join';      
        insert objMembershipE; 
        
        objMembershipE.Start_Date__c =  System.today().addDays(-355);
        objMembershipE.Membership_Action__c = 'Edit';      
        update objMembershipE; 
        
		TCD = new Token.TokenCreateData();
//		mR1.token = t.create(objMembershipE.Id, 'MemRenewLink');
		TCD = t.create(objMembershipE.Id, 'MemRenewLink');
		mR1.token = TCD.Token;
		encodedToken = EncodingUtil.urlEncode(mR1.token, 'UTF-8');
		mR1.token = encodedToken;
		
		// create the EmailQueue object
		e = new EmailQueue__c();
		e.Contact__c = objContactE.Id;
		e.EmailType__c = 'Single Lapsing Member Email';
		e.Name = objContactE.Name + ' Lapsing Email';
		e.To__c = 'SFDCTesting@stand.org';
		e.Subject__c = 'Your Membership Matters';
		mToken = '';
		e.Body__c = '<span style=\'font-size:10.0pt;font-family:"News Gothic","sans-serif";color:black\'>Dear ' + objContactE.Name + '<br><br>It\'s time to renew your Stand for Children membership.  <b><a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">Renew your membership now</a>.</b><br><br>Your support over the past year resulted in tremendous gains in education for students across the country. We trained over 400 parents last semester to become more involved in their child\'s academics. We empowered thousands more to lobby at the district and state level in support of better public schools. Alongside our members, we’ve fought tirelessly for policies that improve education for <b>every child</b> in <b>every classroom.</b><br><br><b>You play an important role in this work - please <a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">renew your membership now</a>.</b><br><br>Together we can have a unified voice that will change the landscape of education for an entire generation of students. Thank you for your continued support.<br><br>Standing with You,<br><br><br>Simone Coker<br>Membership Associate<br><br><i>Your membership contribution is not tax-deductible. For more information or for questions about your membership, call us at (503) 308-7292 or email <a href="mailto:membership@stand.org">membership@stand.org</a>.</i>';		
		e.Token__c = TCD.TokenId;
		insert e;
		
		
		mriR = StandWebService.memberRequestTest(mR1);

		
		mC1.token = mR1.token;
		mciR = StandWebService.memberCompleteTest(mC1);
		
		mriR = StandWebService.memberRequestTest(mR1);
	}
	

	public static TestMethod void TestMemberRequest3() {
		// create new instance of the data to be passed to the web service
		StandWebService.MemberRequestInfo mR1 = new StandWebService.MemberRequestInfo();
		
		// create a new instance of the web service call
		StandWebService.MemberRequestInfoResponse mriR = new StandWebService.MemberRequestInfoResponse();
		
		// create new instance of the data to be passed to the web service
		StandWebService.MemberCompleteInfo mC1 = new StandWebService.MemberCompleteInfo();
		
		// create a new instance of the web service call
		StandWebService.MemberCompleteInfoResponse mciR = new StandWebService.MemberCompleteInfoResponse();
		
		Token t = new Token();
		String encodedToken;


		// Test 8
		// Lapsed membership, token used
		Contact objContactF = new Contact();
        objContactF.FirstName = 'MemberRequest';
        objContactF.LastName = 'Contact 8';
        objContactF.Stand_Office__c = 'OR';
        insert objContactF;

        Membership__c objMembershipF = new Membership__c();
        objMembershipF.Contact__c = objContactF.Id;
        objMembershipF.Membership_State__c = 'OR';          
        objMembershipF.Start_Date__c =  System.today();
        //objMembershipA.Gift_Amount__c = Decimal.valueOf('4.00');
        //objMembershipA.Type__c = 'Annual';    
        objMembershipF.Membership_Source__c = 'Web';
        objMembershipF.Membership_Action__c = 'Join';      
        insert objMembershipF; 
        
        objMembershipF.Start_Date__c =  System.today().addDays(-375);
        objMembershipF.Membership_Action__c = 'Edit';      
        update objMembershipF; 
        
        Token.TokenCreateData TCD = new Token.TokenCreateData();
//		mR1.token = t.create(objMembershipF.Id, 'MemRenewLink');
		TCD = t.create(objMembershipF.Id, 'MemRenewLink');
		mR1.token = TCD.Token;
		encodedToken = EncodingUtil.urlEncode(mR1.token, 'UTF-8');
		mR1.token = encodedToken;
		
		// create the EmailQueue object
		EmailQueue__c e = new EmailQueue__c();
		e.Contact__c = objContactF.Id;
		e.EmailType__c = 'Single Lapsing Member Email';
		e.Name = objContactF.Name + ' Lapsing Email';
		e.To__c = 'SFDCTesting@stand.org';
		e.Subject__c = 'Your Membership Matters';
		String mToken = '';
		e.Body__c = '<span style=\'font-size:10.0pt;font-family:"News Gothic","sans-serif";color:black\'>Dear ' + objContactF.Name + '<br><br>It\'s time to renew your Stand for Children membership.  <b><a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">Renew your membership now</a>.</b><br><br>Your support over the past year resulted in tremendous gains in education for students across the country. We trained over 400 parents last semester to become more involved in their child\'s academics. We empowered thousands more to lobby at the district and state level in support of better public schools. Alongside our members, we’ve fought tirelessly for policies that improve education for <b>every child</b> in <b>every classroom.</b><br><br><b>You play an important role in this work - please <a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">renew your membership now</a>.</b><br><br>Together we can have a unified voice that will change the landscape of education for an entire generation of students. Thank you for your continued support.<br><br>Standing with You,<br><br><br>Simone Coker<br>Membership Associate<br><br><i>Your membership contribution is not tax-deductible. For more information or for questions about your membership, call us at (503) 308-7292 or email <a href="mailto:membership@stand.org">membership@stand.org</a>.</i>';		
		e.Token__c = TCD.TokenId;
		insert e;

		
		mriR = StandWebService.memberRequestTest(mR1);


		mC1.token = mR1.token;
		mciR = StandWebService.memberCompleteTest(mC1);
		
		mriR = StandWebService.memberRequestTest(mR1);


		// Test 9
		// Renewed membership, token used
		Contact objContactG = new Contact();
        objContactG.FirstName = 'MemberRequest';
        objContactG.LastName = 'Contact 9';
        objContactG.Stand_Office__c = 'OR';
        insert objContactG;

        Membership__c objMembershipG = new Membership__c();
        objMembershipG.Contact__c = objContactG.Id;
        objMembershipG.Membership_State__c = 'OR';          
        objMembershipG.Start_Date__c =  System.today();
        //objMembershipA.Gift_Amount__c = Decimal.valueOf('4.00');
        //objMembershipA.Type__c = 'Annual';    
        objMembershipG.Membership_Source__c = 'Web';
        objMembershipG.Membership_Action__c = 'Join';      
        insert objMembershipG; 
        
        objMembershipG.Start_Date__c =  System.today().addDays(-310);
        objMembershipG.Membership_Action__c = 'Edit';      
        update objMembershipG; 
        
        TCD = new Token.TokenCreateData();
//		mR1.token = t.create(objMembershipG.Id, 'MemRenewLink');
		TCD = t.create(objMembershipG.Id, 'MemRenewLink');
		mR1.token = TCD.Token;
		encodedToken = EncodingUtil.urlEncode(mR1.token, 'UTF-8');
		mR1.token = encodedToken;
		
		// create the EmailQueue object
		e = new EmailQueue__c();
		e.Contact__c = objContactG.Id;
		e.EmailType__c = 'Single Lapsing Member Email';
		e.Name = objContactG.Name + ' Lapsing Email';
		e.To__c = 'SFDCTesting@stand.org';
		e.Subject__c = 'Your Membership Matters';
		mToken = '';
		e.Body__c = '<span style=\'font-size:10.0pt;font-family:"News Gothic","sans-serif";color:black\'>Dear ' + objContactG.Name + '<br><br>It\'s time to renew your Stand for Children membership.  <b><a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">Renew your membership now</a>.</b><br><br>Your support over the past year resulted in tremendous gains in education for students across the country. We trained over 400 parents last semester to become more involved in their child\'s academics. We empowered thousands more to lobby at the district and state level in support of better public schools. Alongside our members, we’ve fought tirelessly for policies that improve education for <b>every child</b> in <b>every classroom.</b><br><br><b>You play an important role in this work - please <a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">renew your membership now</a>.</b><br><br>Together we can have a unified voice that will change the landscape of education for an entire generation of students. Thank you for your continued support.<br><br>Standing with You,<br><br><br>Simone Coker<br>Membership Associate<br><br><i>Your membership contribution is not tax-deductible. For more information or for questions about your membership, call us at (503) 308-7292 or email <a href="mailto:membership@stand.org">membership@stand.org</a>.</i>';		
		e.Token__c = TCD.TokenId;
		insert e;

		
		mriR = StandWebService.memberRequestTest(mR1);


		mC1.token = mR1.token;
		mciR = StandWebService.memberCompleteTest(mC1);
		
		mriR = StandWebService.memberRequestTest(mR1);

		// Test 10
		// Active membership, token revoked or expired
		Contact objContactH = new Contact();
        objContactH.FirstName = 'MemberRequest';
        objContactH.LastName = 'Contact 10';
        objContactH.Stand_Office__c = 'OR';
        insert objContactH;

        Membership__c objMembershipH = new Membership__c();
        objMembershipH.Contact__c = objContactH.Id;
        objMembershipH.Membership_State__c = 'OR';          
        objMembershipH.Start_Date__c =  System.today();
        //objMembershipA.Gift_Amount__c = Decimal.valueOf('4.00');
        //objMembershipA.Type__c = 'Annual';    
        objMembershipH.Membership_Source__c = 'Web';
        objMembershipH.Membership_Action__c = 'Join';      
        insert objMembershipH; 
        
        objMembershipH.Start_Date__c =  System.today().addDays(-355);
        objMembershipH.Membership_Action__c = 'Edit';      
        update objMembershipH; 
        
		TCD = new Token.TokenCreateData();
//		mR1.token = t.create(objMembershipH.Id, 'MemRenewLink');
		TCD = t.create(objMembershipH.Id, 'MemRenewLink');
		mR1.token = TCD.Token;
		encodedToken = EncodingUtil.urlEncode(mR1.token, 'UTF-8');
		mR1.token = encodedToken;
		
		Token__c tR = [SELECT ID FROM Token__c WHERE ObjectID__c = : objMembershipH.Id];
		tR.Status__c = 'Expired';
		update tR;
		
		// create the EmailQueue object
		e = new EmailQueue__c();
		e.Contact__c = objContactH.Id;
		e.EmailType__c = 'Single Lapsing Member Email';
		e.Name = objContactH.Name + ' Lapsing Email';
		e.To__c = 'SFDCTesting@stand.org';
		e.Subject__c = 'Your Membership Matters';
		mToken = '';
		e.Body__c = '<span style=\'font-size:10.0pt;font-family:"News Gothic","sans-serif";color:black\'>Dear ' + objContactH.Name + '<br><br>It\'s time to renew your Stand for Children membership.  <b><a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">Renew your membership now</a>.</b><br><br>Your support over the past year resulted in tremendous gains in education for students across the country. We trained over 400 parents last semester to become more involved in their child\'s academics. We empowered thousands more to lobby at the district and state level in support of better public schools. Alongside our members, we’ve fought tirelessly for policies that improve education for <b>every child</b> in <b>every classroom.</b><br><br><b>You play an important role in this work - please <a href="http://renewaltest.stand.org/' + 'Oregon' + '/renew?token=' + mToken + '">renew your membership now</a>.</b><br><br>Together we can have a unified voice that will change the landscape of education for an entire generation of students. Thank you for your continued support.<br><br>Standing with You,<br><br><br>Simone Coker<br>Membership Associate<br><br><i>Your membership contribution is not tax-deductible. For more information or for questions about your membership, call us at (503) 308-7292 or email <a href="mailto:membership@stand.org">membership@stand.org</a>.</i>';		
		e.Token__c = TCD.TokenId;
		insert e;
		
		
		mriR = StandWebService.memberRequestTest(mR1);
		
		// test 11
		// revoke fails, Active membership
		delete tR;
		
		mC1.token = mR1.token;
		mciR = StandWebService.memberCompleteTest(mC1);
	}

	public static TestMethod void TestMemberRequest4() {
		// create new instance of the data to be passed to the web service
		StandWebService.MemberRequestInfo mR1 = new StandWebService.MemberRequestInfo();
		
		// create a new instance of the web service call
		StandWebService.MemberRequestInfoResponse mriR = new StandWebService.MemberRequestInfoResponse();
		
		// create new instance of the data to be passed to the web service
		StandWebService.MemberCompleteInfo mC1 = new StandWebService.MemberCompleteInfo();
		
		// create a new instance of the web service call
		StandWebService.MemberCompleteInfoResponse mciR = new StandWebService.MemberCompleteInfoResponse();
		
		Token t = new Token();
		String encodedToken;

		// Test 12
		// Lapsed membership, token revoked or expired
		Contact objContactI = new Contact();
        objContactI.FirstName = 'MemberRequest';
        objContactI.LastName = 'Contact 11';
        objContactI.Stand_Office__c = 'OR';
        insert objContactI;

        Membership__c objMembershipI = new Membership__c();
        objMembershipI.Contact__c = objContactI.Id;
        objMembershipI.Membership_State__c = 'OR';          
        objMembershipI.Start_Date__c =  System.today();
        //objMembershipA.Gift_Amount__c = Decimal.valueOf('4.00');
        //objMembershipA.Type__c = 'Annual';    
        objMembershipI.Membership_Source__c = 'Web';
        objMembershipI.Membership_Action__c = 'Join';      
        insert objMembershipI; 
        
        objMembershipI.Start_Date__c =  System.today().addDays(-375);
        objMembershipI.Membership_Action__c = 'Edit';      
        update objMembershipI; 
        
        Token.TokenCreateData TCD = new Token.TokenCreateData();
//		mR1.token = t.create(objMembershipI.Id, 'MemRenewLink');
		TCD = t.create(objMembershipI.Id, 'MemRenewLink');
		mR1.token = TCD.Token;
		encodedToken = EncodingUtil.urlEncode(mR1.token, 'UTF-8');
		mR1.token = encodedToken;
		
		Token__c tR = [SELECT ID FROM Token__c WHERE ObjectID__c = : objMembershipI.Id];
		tR.Status__c = 'Expired';
		update tR;

		
		mriR = StandWebService.memberRequestTest(mR1);

		// test 13
		// revoke fails, Lapsed membership
		delete tR;
		
		mC1.token = mR1.token;
		mciR = StandWebService.memberCompleteTest(mC1);


		// Test 14
		// Renewed membership, token revoked or expired
		Contact objContactJ = new Contact();
        objContactJ.FirstName = 'MemberRequest';
        objContactJ.LastName = 'Contact 9';
        objContactJ.Stand_Office__c = 'OR';
        insert objContactJ;

        Membership__c objMembershipJ = new Membership__c();
        objMembershipJ.Contact__c = objContactJ.Id;
        objMembershipJ.Membership_State__c = 'OR';          
        objMembershipJ.Start_Date__c =  System.today();
        //objMembershipA.Gift_Amount__c = Decimal.valueOf('4.00');
        //objMembershipA.Type__c = 'Annual';    
        objMembershipJ.Membership_Source__c = 'Web';
        objMembershipJ.Membership_Action__c = 'Join';      
        insert objMembershipJ; 
        
        objMembershipJ.Start_Date__c =  System.today().addDays(-310);
        objMembershipJ.Membership_Action__c = 'Edit';      
        update objMembershipJ; 
        
        TCD = new Token.TokenCreateData();
//		mR1.token = t.create(objMembershipJ.Id, 'MemRenewLink');
		TCD = t.create(objMembershipJ.Id, 'MemRenewLink');
		mR1.token = TCD.Token;
		encodedToken = EncodingUtil.urlEncode(mR1.token, 'UTF-8');
		mR1.token = encodedToken;
		
		tR = [SELECT ID FROM Token__c WHERE ObjectID__c = : objMembershipJ.Id];
		tR.Status__c = 'Expired';
		update tR;
		
		mriR = StandWebService.memberRequestTest(mR1);

		// test 15
		// revoke fails, Renewed membership
		delete tR;
		
		mC1.token = mR1.token;
		mciR = StandWebService.memberCompleteTest(mC1);

	}

}