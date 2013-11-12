@isTest
private class CnP_Custom_Question_Loader_TestSuite {
	
	static testMethod void verify_CnP_Custom_Question_Loader_Single () {
		
		String test_Name 	= 'TEST-CNP-CQ-Loader-1';
		String entity_Value = 'C4';
		String community_Value = 'OR';
		String fund_Value = '2010';
		DateTime dt_Now 	= System.now ();
		Date d_Now 			= Date.newInstance( dt_Now.year (), dt_Now.month (), dt_Now.day () );
		
		// create a CnP transaction and custom questions
		CnP_PaaS__CnP_Transaction__c t = new CnP_PaaS__CnP_Transaction__c ();
		t.Name = test_Name;
		t.CnP_PaaS__TotalDue__c = 25.00;
		t.CnP_PaaS__TransactionDate__c = dt_Now;
		t.CnP_PaaS__TransactionTimeZone__c = dt_Now;
		insert t;

		CnP_PaaS__Custom_Question__c cq = new CnP_PaaS__Custom_Question__c ();
		cq.Name = test_Name;
		cq.CnP_PaaS__Answer__c = entity_Value;
		cq.CnP_PaaS__Custom_Question__c = 'Entity'; 
		insert cq;
		
		cq = new CnP_PaaS__Custom_Question__c ();
		cq.Name = test_Name;
		cq.CnP_PaaS__Answer__c = community_value;
		cq.CnP_PaaS__Custom_Question__c = 'Community'; 
		insert cq;
		
		cq = new CnP_PaaS__Custom_Question__c ();
		cq.Name = test_Name;
		cq.CnP_PaaS__Answer__c = fund_value;
		cq.CnP_PaaS__Custom_Question__c = 'Fund'; 
		insert cq;
		
		// link up the opportunity and save
		Opportunity o = new Opportunity ();
		o.Name = test_name;
		o.StageName = 'Closed Won';
		o.CloseDate = d_Now;
		o.CnP_PaaS__CnP_OrderNumber__c = t.ID;
		o.Amount = 10;
		o.Entity_Committed__c = 'OR PAC';
		o.Fund_Committed__c = 'General Fund';
		o.Community_Committed__c = 'Hillsboro';
		
		// start trigger test - insert the Opportunity
		test.startTest();
		
		insert o;
		
		test.stopTest();
		
		// review data values
		o = [ SELECT ID, entity_committed__c, community_committed__c, fund_committed__c FROM Opportunity WHERE Name = : test_name ];
		System.assertEquals ( entity_Value, o.entity_committed__c );
		System.assertEquals ( community_Value, o.community_committed__c );
		System.assertEquals ( fund_Value, o.fund_committed__c );
		
	}
	
	static testMethod void verify_CnP_Custom_Question_Loader_Bulk () {
		
		// test data and variables
		String test_Name = 'TEST-CNP-CQ-Loader-';
		String entity_Value = 'C4';
		String community_Value = 'OR';
		String fund_Value = '2010';
		DateTime dt_Now = System.now ();
		Date d_Now = Date.newInstance( dt_Now.year (), dt_Now.month (), dt_Now.day () );
		
		// test objects
		CnP_PaaS__CnP_Transaction__c t;
		CnP_PaaS__Custom_Question__c cq;
		Opportunity o;
		list <Opportunity> opps = new list <Opportunity> ();
		
		// create a CnP transaction and custom questions in bulk
		for ( Integer i = 0; i < 15; i++ ) {
			t = new CnP_PaaS__CnP_Transaction__c ();
			t.Name = test_Name + i;
			t.CnP_PaaS__TotalDue__c = 25.00;
			t.CnP_PaaS__TransactionDate__c = dt_Now;
			t.CnP_PaaS__TransactionTimeZone__c = dt_Now;
			insert t;
			
			cq = new CnP_PaaS__Custom_Question__c ();
			cq.Name = test_Name + i;
			cq.CnP_PaaS__Answer__c = entity_Value;
			cq.CnP_PaaS__Custom_Question__c = 'Entity'; 
			insert cq;
			
			cq = new CnP_PaaS__Custom_Question__c ();
			cq.Name = test_Name + i;
			cq.CnP_PaaS__Answer__c = community_value;
			cq.CnP_PaaS__Custom_Question__c = 'Community'; 
			insert cq;
			
			cq = new CnP_PaaS__Custom_Question__c ();
			cq.Name = test_Name + i;
			cq.CnP_PaaS__Answer__c = fund_value;
			cq.CnP_PaaS__Custom_Question__c = 'Fund'; 
			insert cq;
			
			// link up the opportunity
			o = new Opportunity ();
			o.Name = test_name + i;
			o.StageName = 'Closed Won';
			o.CloseDate = d_Now;
			o.CnP_PaaS__CnP_OrderNumber__c = t.ID;
			o.Amount = 10;
			o.Entity_Committed__c = 'OR PAC';
			o.Fund_Committed__c = 'General Fund';
			o.Community_Committed__c = 'Hillsboro';
			
			opps.add ( o );
			
		}
		
		
		// start trigger test - insert the Opportunity
		test.startTest();
		
		insert opps;
		
		test.stopTest();

		// review data values
		list <Opportunity> inserted_Opps = [ SELECT ID, entity_committed__c, community_committed__c, fund_committed__c FROM Opportunity WHERE ID IN : opps ];
		for (Opportunity eval_opp : inserted_Opps ) {
			System.assertEquals ( entity_Value, eval_opp.entity_committed__c );
			System.assertEquals ( community_Value, eval_opp.community_committed__c );
			System.assertEquals ( fund_Value, eval_opp.fund_committed__c );
		}
		
	}
	
	// Test Case to test to ensure that if no CnP record exists that nothing bad happens
	static testMethod void verify_CnP_Custom_Question_No_Records () {
		
		// setup date variables (FUTURE: move this into a utility function)
		DateTime dt_Now 	= System.now ();
		Date d_Now 			= Date.newInstance( dt_Now.year (), dt_Now.month (), dt_Now.day () );
		
		// create the opporunity - test case, no CNP records
		Opportunity o = new Opportunity ();
		
		o.Name = 'TEST-NO-CNP-RECORDS';
		o.StageName = 'Closed Won';
		o.CloseDate = d_Now;
		o.Amount = 10;
		o.Entity_Committed__c = 'OR PAC';
		o.Fund_Committed__c = 'General Fund';
		o.Community_Committed__c = 'Hillsboro';
		
		insert o;

	}	
	
	// Test Case to test to ensure that if no CnP custom questions exist that nothing bad happens
	static testMethod void verify_CnP_Custom_Question_No_Questions () {
		
		String test_Name 	= 'TEST-CNP-CQ-NO-QUESTIONS-1';
		DateTime dt_Now 	= System.now ();
		Date d_Now 			= Date.newInstance( dt_Now.year (), dt_Now.month (), dt_Now.day () );
		
		// create a CnP transaction and custom questions
		CnP_PaaS__CnP_Transaction__c t = new CnP_PaaS__CnP_Transaction__c ();
		t.Name = test_Name;
		t.CnP_PaaS__TotalDue__c = 25.00;
		t.CnP_PaaS__TransactionDate__c = dt_Now;
		t.CnP_PaaS__TransactionTimeZone__c = dt_Now;
		insert t;
		
		// create the opporunity - test case, no CNP records
		Opportunity o = new Opportunity ();
		
		o.Name = 'TEST-NO-CNP-RECORDS';
		o.StageName = 'Closed Won';
		o.CloseDate = d_Now;
		o.CnP_PaaS__CnP_OrderNumber__c = t.ID;
		o.Amount = 10;
		o.Entity_Committed__c = 'OR PAC';
		o.Fund_Committed__c = 'General Fund';
		o.Community_Committed__c = 'Hillsboro';
		insert o;

	}	
	
}