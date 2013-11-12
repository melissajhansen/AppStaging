@isTest
private class FunctionalSmokeTest3 {

	public static TestMethod void howManyTriggersTest() {
//	    Account objAccountTeamA = new Account([SELECT Id FROM Account WHERE Name = : 'NE Community Team']);

		Contact objContactA = new Contact();
	    objContactA.FirstName = 'Test';
	    objContactA.LastName = 'Contact 1';
	    objContactA.Stand_Office__c = 'OR';
	    insert objContactA;

	    Membership__c objMembershipA = new Membership__c();
        objMembershipA.Contact__c = objContactA.Id;
        objMembershipA.Membership_State__c = 'OR';          
        objMembershipA.Start_Date__c =  System.Today();
        objMembershipA.Gift_Amount__c = Decimal.valueOf('50.00');
        objMembershipA.Type__c = 'Annual';    
//        objMembershipA.Stand_Team__c = objAccountTeamA.Id;  
        objMembershipA.Membership_Source__c = 'Web';
        objMembershipA.Membership_Action__c = 'Join';      
        insert objMembershipA;  	

	}

    //////////////////
    
    //Validations
    //////////////////
    
    public static TestMethod void TestValidations()
    {
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
        objUser.UserName = 'FunSmo3TestValidations@stand.org';
        objUser.Division = 'National';
        insert objUser;

        System.runAs(objUser)
        {
        	Date dtCurrentDate1 = System.Today();
	    	
	        Account objAccount = new Account();
	        objAccount.Name = 'OR State Office';
	        objAccount.Type = 'Stand Affiliate State';
	        objAccount.Acquired_By__c = 'C3 Acquired';
	        objAccount.State_Abbreviation__c = 'OR';
	        objAccount.BillingState = 'OR';
	        insert objAccount;
	        
			Account objAccountChapter = new Account();
			objAccountChapter.Name = 'OR Chapter';
			objAccountChapter.Type = 'Stand Chapter';
			objAccountChapter.Acquired_By__c = 'C3 Acquired';
			objAccountChapter.ParentId = objAccount.Id;
			objAccountChapter.State_Abbreviation__c = 'OR';
			objAccountChapter.BillingState = 'OR';
			insert objAccountChapter;			
	     	        
	        Account objAccountTeamA = new Account();
	        objAccountTeamA.Name = 'NE Community Team';
	        objAccountTeamA.Type = 'Stand Team';
	        objAccountTeamA.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamA.ParentId = objAccountChapter.Id;
	        objAccountTeamA.State_Abbreviation__c = 'OR';
	        objAccountTeamA.BillingState = 'OR';
	        insert objAccountTeamA;                   
	        
	     	//	Test 19
			//	If Gift Type = Annual or Sustaining and user tries to save withour entering an gift amount, validation error happens 			
	        
	        Contact objContactA = new Contact();
	        objContactA.FirstName = 'Larua';
	        objContactA.LastName = 'Kelpie';
	        objContactA.Stand_Office__c = 'OR';	  
	        objContactA.Membership_State__c = 'OR';
			objContactA.Membership_Type__c = 'Annual';      
	        insert objContactA;
	        
	        Membership__c objMembershipA = new Membership__c();
            objMembershipA.Contact__c = objContactA.Id;
            objMembershipA.Membership_State__c = 'OR';          
            objMembershipA.Start_Date__c =  System.Today();            
            objMembershipA.Type__c = 'Annual';    
            objMembershipA.Stand_Team__c = objAccountTeamA.Id;  
            objMembershipA.Membership_Source__c = 'Event';
            objMembershipA.Membership_Action__c = 'Join';                         
            
            try {
	        	insert objMembershipA; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertEquals(null, objMembershipA.Id);
	        } catch(DmlException ex) {	        	  
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }                                     
			 
			//	Test 20  
			//	If Gift Type = Annual or Sustaining and user tries to save with $0 in the gift amount, 
			//	validation error happens
			
			objMembershipA.Gift_Amount__c = Decimal.valueOf('0.00');
			
			try {
	        	insert objMembershipA; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertEquals(null, objMembershipA.Id);
	        } catch(DmlException ex) {	       	    	
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }  
			
			//	Test 21
			//	If Gift Type = Complimentary and someone tries to enter a gift amount above $0, validation error happens.
			
	        objMembershipA.Type__c = 'Complimentary'; 
	        objMembershipA.Gift_Amount__c = Decimal.valueOf('5.00');
			
			try {
	        	insert objMembershipA; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertEquals(null, objMembershipA.Id);
	        } catch(DmlException ex) {	       	    	
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }  
	        
	        //	Test 22
	        //	If Leader Type is "Leader In Training" and LiT Start Date is empty: 
	        //	error "You cannot set the Leader Type to Leader In Training until you enter a Leader in Training Start Date"
	        
	        Contact objContactB = new Contact();
	        objContactB.FirstName = 'Fred';
	        objContactB.LastName = 'Flinstone';
	        objContactB.Stand_Office__c = 'OR';	  
	        objContactB.Membership_State__c = 'OR';
			objContactB.Membership_Type__c = 'Annual';  
			objContactB.Leader_Type__c = 'Leader in Training';
			objContactB.LiT_Start_Date__c = null;			   
	        
	        try {
	        	insert objContactB; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertEquals(null, objContactB.Id);
	        } catch(DmlException ex) {	       	    	
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }  
	        
	        //	Test 23
	        //	If Leader Type is "Leader" and Leader Start Date is empty:  
	        //	error "You cannot set the Leader Type to Leader until you enter a Leader Start Date"
	        
	        objContactB.Leader_Type__c = 'Leader';
	        objContactB.Leader_Start_Date__c = null;
	        
	        try {
	        	insert objContactB; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertEquals(null, objContactB.Id);
	        } catch(DmlException ex) {	       	    	
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }  
	        
	        //	Test 24
	        //	If Leader Start Date is empty and Leader Stop Date is NOT empty: 
	        //	error "You cannot enter a Leader Stop Date without a Leader Start Date"	        
	        
	        objContactB.Leader_Type__c = 'Leader';
	        objContactB.Leader_Stop_Date__c = System.today();
	        objContactB.Leader_Start_Date__c = null;
	        
	        try {
	        	insert objContactB; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertEquals(null, objContactB.Id);
	        } catch(DmlException ex) {	       	    	
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }  
	        
	        //	Test 25
	        //	If Leader Type is "Leader In Training" or is empty and Leader Start Date is NOT empty: 
	        //	error "You cannot enter a Leader Start Date until the Leader Type is set to Leader"        
	        
	        //Setting Leader Type to Leader in Training
	        objContactB.Leader_Type__c = 'Leader in Training';
	        objContactB.Leader_Stop_Date__c = null;
	        objContactB.Leader_Start_Date__c = System.today();
	        
	        try {
	        	insert objContactB; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertEquals(null, objContactB.Id);
	        } catch(DmlException ex) {	       	    	
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }  
	        
	        //Setting Leader Type to empty
	        objContactB.Leader_Type__c = null;
	        objContactB.Leader_Stop_Date__c = null;
	        objContactB.Leader_Start_Date__c = System.today();
	        
	        try {
	        	insert objContactB; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertEquals(null, objContactB.Id);
	        } catch(DmlException ex) {	       	    	
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }  
	        
	        //	Test 26
	        //	If Leader Type is empty and LiT Start Date is NOT empty: 
	        //	error "You cannot enter a Leader In Training Start Date until the Leader Type is set to Leader in Training"
	        
	        objContactB.Leader_Type__c = null;
	        objContactB.LiT_Stop_Date__c = null;
	        objContactB.LiT_Start_Date__c = System.today();
	        
	        try {
	        	insert objContactB; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertEquals(null, objContactB.Id);
	        } catch(DmlException ex) {	       	    	
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }  
	        
	        //	Test 30
	        //	If LiT Start Date is empty and LiT Stop Date is NOT empty: 
	        //	error "You cannot enter a LiT Stop Date without a LiT Start Date."
	        
	        objContactB.Leader_Type__c = 'Leader in Training';
	        objContactB.LiT_Stop_Date__c = System.today();
	        objContactB.LiT_Start_Date__c = null;
	        
	        try {
	        	insert objContactB; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertEquals(null, objContactB.Id);
	        } catch(DmlException ex) {	       	    	
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }  
	        	        
	        //	Test 27
	        //	As an organizer, if I try to add another membership to active member x, 
	        //	I get a validation error that says I cannot add the membership.
	        
	        objMembershipA.Type__c = 'Annual'; 
	        objMembershipA.Gift_Amount__c = Decimal.valueOf('50.00');
	        
	        insert objMembershipA;
	        
	        //ContactA belongs to MembershipA now
	        //Now try assigning ContactA to MemberhipB
	        
	        Membership__c objMembershipB = new Membership__c();
            objMembershipB.Contact__c = objContactA.Id;
            objMembershipB.Membership_State__c = 'OR';          
            objMembershipB.Start_Date__c =  System.Today();            
            objMembershipB.Type__c = 'Annual';    
            objMembershipB.Stand_Team__c = objAccountTeamA.Id;  
            objMembershipB.Membership_Source__c = 'Event';
            objMembershipB.Membership_Action__c = 'Join'; 
            objMembershipB.Type__c = 'Annual'; 
	        objMembershipB.Gift_Amount__c = Decimal.valueOf('50.00');
	        
	        try {
	        	insert objMembershipB; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertEquals(null, objMembershipB.Id);
	        } catch(DmlException ex) {	       	    	
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }  
	        
	        //	Test 28
	        //	As an organizer, If I edit or create a membership and input a leader in the leader field 
	        //	and that member is not a leader, I get a validation error. 
	        
	        Contact objContactD = new Contact();
	        objContactD.FirstName = 'NonLeader';
	        objContactD.LastName = 'New';
	        objContactD.Stand_Office__c = 'OR';	  
	        objContactD.Membership_State__c = 'OR';
			objContactD.Membership_Type__c = 'Annual';  
			insert objContactD;
			
			objMembershipA.Leader__c = objContactD.Id;
			objMembershipA.Membership_Action__c = 'Edit';		
			
			try {
	        	update objMembershipA; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertNotEquals(null, objMembershipA.Leader__c);
	        } catch(DmlException ex) {	       	    	
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }  
	        
	        //	Test 29
	        //	As an organizer, If I edit or create a membership and input a leader in the leader field that is a leader, 
	        //	BUT not a leader of that team (so a leader that is on another team), I get a validation 
	        
	        //	Create another Team and a new Leader
	        
	        Account objAccountTeamB = new Account();
	        objAccountTeamB.Name = 'Happy Valley Team';
	        objAccountTeamB.Type = 'Stand Team';
	        objAccountTeamB.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamB.ParentId = objAccountChapter.Id;
	        objAccountTeamB.State_Abbreviation__c = 'OR';
	        objAccountTeamB.BillingState = 'OR';
	        insert objAccountTeamB; 
	        
	        Contact objContactC = new Contact();
	        objContactC.FirstName = 'Leader';
	        objContactC.LastName = 'FromAnotherTeam';
	        objContactC.Stand_Office__c = 'OR';	  
	        objContactC.Membership_State__c = 'OR';
			objContactC.Membership_Type__c = 'Annual';      
	        insert objContactC;
	        
	        Membership__c objMembershipC = new Membership__c();
            objMembershipC.Contact__c = objContactC.Id;
            objMembershipC.Membership_State__c = 'OR';          
            objMembershipC.Start_Date__c =  System.Today();            
            objMembershipC.Type__c = 'Annual';    
            objMembershipC.Stand_Team__c = objAccountTeamB.Id;  
            objMembershipC.Membership_Source__c = 'Event';
            objMembershipC.Membership_Action__c = 'Join';    
            objMembershipC.Type__c = 'Annual'; 
	        objMembershipC.Gift_Amount__c = Decimal.valueOf('50.00');  
	        objMembershipC.Team_Leader__c = true;
	        insert objMembershipC;
	        
	        List<Contact> tmpCts = new List<Contact>([select Id, Name, Leader_Type__c, LiT_Start_Date__c from Contact where ID = : objContactC.Id]);
	        
	        //Check that the leader type is Leader in Training and LiT start date is set
	        System.AssertEquals('Leader in Training', tmpCts[0].Leader_Type__c);
	        System.AssertNotEquals(null, tmpCts[0].LiT_Start_Date__c);	
	        
	        objMembershipA.Leader__c = objContactC.Id;
	        objMembershipA.Membership_Action__c = 'Edit';
	        
	        try {
	        	update objMembershipA; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertNotEquals(null, objMembershipA.Leader__c);
	        } catch(DmlException ex) {	       	    	
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }  
	        	       
        }    	
    }

    //////////////////

    public static TestMethod void TestTeamLeader3()
    {
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
        objUser.UserName = 'FunSmo3TestTeamLeader3@stand.org';
        objUser.Division = 'National';
        insert objUser;

        System.runAs(objUser)
        {
        	Date dtCurrentDate1 = System.Today();
	    	
	        Account objAccount = new Account();
	        objAccount.Name = 'OR State Office';
	        objAccount.Type = 'Stand Affiliate State';
	        objAccount.Acquired_By__c = 'C3 Acquired';
	        objAccount.State_Abbreviation__c = 'OR';
	        objAccount.BillingState = 'OR';
	        insert objAccount;
	        
			Account objAccountChapter = new Account();
			objAccountChapter.Name = 'OR Chapter';
			objAccountChapter.Type = 'Stand Chapter';
			objAccountChapter.Acquired_By__c = 'C3 Acquired';
			objAccountChapter.ParentId = objAccount.Id;
			objAccountChapter.State_Abbreviation__c = 'OR';
			objAccountChapter.BillingState = 'OR';
			insert objAccountChapter;			
	     	        
	        Account objAccountTeamA = new Account();
	        objAccountTeamA.Name = 'NE Community Team';
	        objAccountTeamA.Type = 'Stand Team';
	        objAccountTeamA.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamA.ParentId = objAccountChapter.Id;
	        objAccountTeamA.State_Abbreviation__c = 'OR';
	        objAccountTeamA.BillingState = 'OR';
	        insert objAccountTeamA;             
	        
	     	//	Test 11
			//	As an organizer, if I edit member Emily Merrill's leader to Frances Moyle, it correctly 
			//	updates in her contact record and updates her affiliations correctly showing her leader as Frances Moyle	
	        
	        Contact objContactA = new Contact();
	        objContactA.FirstName = 'Frances';
	        objContactA.LastName = 'King';
	        objContactA.Stand_Office__c = 'OR';	  
	        objContactA.Membership_State__c = 'OR';
			objContactA.Membership_Type__c = 'Annual';      
	        insert objContactA;
	        
	        Membership__c objMembershipA = new Membership__c();
            objMembershipA.Contact__c = objContactA.Id;
            objMembershipA.Membership_State__c = 'OR';          
            objMembershipA.Start_Date__c =  System.Today();
            objMembershipA.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipA.Type__c = 'Annual';    
            objMembershipA.Stand_Team__c = objAccountTeamA.Id;  
            objMembershipA.Membership_Source__c = 'Event';
            objMembershipA.Membership_Action__c = 'Join';          
            objMembershipA.Team_Leader__c = true;
            insert objMembershipA;  	                                  
			
			Contact objContactC = new Contact();
	        objContactC.FirstName = 'Frances';
	        objContactC.LastName = 'Moyle';
	        objContactC.Stand_Office__c = 'OR';	  
	        objContactC.Membership_State__c = 'OR';
			objContactC.Membership_Type__c = 'Annual';      
	        insert objContactC;
	        
	        Membership__c objMembershipC = new Membership__c();
            objMembershipC.Contact__c = objContactC.Id;
            objMembershipC.Membership_State__c = 'OR';          
            objMembershipC.Start_Date__c =  System.Today();
            objMembershipC.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipC.Type__c = 'Annual';    
            objMembershipC.Stand_Team__c = objAccountTeamA.Id;  
            objMembershipC.Membership_Source__c = 'Event';
            objMembershipC.Membership_Action__c = 'Join';          
            objMembershipC.Team_Leader__c = true;
            insert objMembershipC;  		 
			
			Contact objContactB = new Contact();
	        objContactB.FirstName = 'Emily';
	        objContactB.LastName = 'Merrill';
	        objContactB.Stand_Office__c = 'OR';	  
	        objContactB.Membership_State__c = 'OR';
			objContactB.Membership_Type__c = 'Annual';   

	        insert objContactB;
	        
	        Membership__c objMembershipB = new Membership__c();
            objMembershipB.Contact__c = objContactB.Id;
            objMembershipB.Membership_State__c = 'OR';          
            objMembershipB.Start_Date__c =  System.Today();
            objMembershipB.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipB.Type__c = 'Annual';    
            objMembershipB.Stand_Team__c = objAccountTeamA.Id;  
            objMembershipB.Membership_Source__c = 'Event';
            objMembershipB.Membership_Action__c = 'Join';    
            objMembershipB.Leader__c = objContactA.Id;      
            insert objMembershipB;  	
            
            List<npe5__Affiliation__c> tmpAff = new List<npe5__Affiliation__c>([select Id, Team_Leader__c from npe5__Affiliation__c where npe5__Status__c = 'Active' and npe5__Contact__c = : objContactB.Id]);
	        
	        //Check that the original Leader is Frances King
            System.AssertEquals(objContactA.Id, tmpAff[0].Team_Leader__c);   
            
            List<Contact> tmpCts = new List<Contact>([select Id, Name, Stand_Leader__c from Contact where ID = : objContactB.Id]);
	        
            //Check that the original Leader is Frances King
	        System.AssertEquals(objContactA.Id, tmpCts[0].Stand_Leader__c);
/*	        
	        objMembershipB.Leader__c = objContactC.Id;
	        objMembershipB.Membership_Action__c = 'Edit';
	        update objMembershipB;

			Test.startTest();	        
	        tmpAff = new List<npe5__Affiliation__c>([select Id, Team_Leader__c from npe5__Affiliation__c where npe5__Status__c = 'Active' and npe5__Contact__c = : objContactB.Id]);
	        Test.stopTest();
	        
	        //Check that the new Leader is Frances Moyle
            System.AssertEquals(objContactC.Id, tmpAff[0].Team_Leader__c);   
            
            tmpCts = new List<Contact>([select Id, Name, Stand_Leader__c from Contact where ID = : objContactB.Id]);
	        
            //Check that the new Leader is Frances Moyle
	        System.AssertEquals(objContactC.Id, tmpCts[0].Stand_Leader__c);        
	        
	        //	Test 12
	        //	As an organizer, if I remove leader x from member x , the leaders # of member followers count decreases by 1    
	        
	        tmpCts = new List<Contact>([select Id, Name, Number_of_Followers__c from Contact where ID = : objContactC.Id]);
	        
	        //Check that Number of Members for Frances Moyle is 1
	        System.AssertEquals(1, tmpCts[0].Number_of_Followers__c);  
*/       	       
        }    	
    }

}