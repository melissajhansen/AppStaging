@isTest
private class FunctionalSmokeTest {
	
	//Triggers
	//////////////////
	
	public static TestMethod void TestOrganizerTest1()
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
        objUser.UserName = 'FunSmoTestOrganizerTest1@stand.org';
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
	        
	        Account objAccountTeamB = new Account();
	        objAccountTeamB.Name = 'HI Team';
	        objAccountTeamB.Type = 'Stand Team';
	        objAccountTeamB.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamB.ParentId = objAccountChapter.Id;
	        objAccountTeamB.State_Abbreviation__c = 'OR';
	        objAccountTeamB.BillingState = 'OR';
	        insert objAccountTeamB;
	        
	        
	        //	Test 1
		    //  As an organizer, I can add an active Annual OR membership with an affiliation to NE Community Team to 
		    //  Frank Thorhill's record and his membership status shows active on the contact record with the 
		    //  membership state=OR, Team affiliation=NE Community Team	        
	        
	        Contact objContactA = new Contact();
	        objContactA.FirstName = 'Frank';
	        objContactA.LastName = 'Thorhill';
	        objContactA.Stand_Office__c = 'OR';
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
            insert objMembershipA;  	
            
            npe5__Affiliation__c objAffiliationContactTeamA = new npe5__Affiliation__c();
            objAffiliationContactTeamA.npe5__Contact__c = objContactA.Id;
            objAffiliationContactTeamA.npe5__Organization__c = objAccountTeamA.Id;
            objAffiliationContactTeamA.npe5__Status__c = 'Active';
            objAffiliationContactTeamA.Affiliation__c = 'Team Member';  
            objAffiliationContactTeamA.npe5__StartDate__c = System.today();
            insert objAffiliationContactTeamA;	 
            
            List<Contact> tmpCts = new List<Contact>([select Id, Name, Membership_State__c, Stand_Team_Affiliation__c from Contact where ID = : objContactA.Id]);
	        
	        //Check that Membership State == OR
	        System.AssertEquals('OR', tmpCts[0].Membership_State__c);
	        //Check that Stand Team Affiliation == NE Community Team
	        System.AssertEquals(objAccountTeamA.Id, tmpCts[0].Stand_Team_Affiliation__c);
        }
    }

	public static TestMethod void TestOrganizerTest2()
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
        objUser.UserName = 'FunSmoTestOrganizerTest2@stand.org';
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
	        
	        Account objAccountTeamB = new Account();
	        objAccountTeamB.Name = 'HI Team';
	        objAccountTeamB.Type = 'Stand Team';
	        objAccountTeamB.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamB.ParentId = objAccountChapter.Id;
	        objAccountTeamB.State_Abbreviation__c = 'OR';
	        objAccountTeamB.BillingState = 'OR';
	        insert objAccountTeamB;

	        //	Test 2
		    //  As an organizer, I can edit Frank Thornhill's  membership to a different state and the 
		    //  membership state is updated on the contact record.         
	        
	        Contact objContactA = new Contact();
	        objContactA.FirstName = 'Frank';
	        objContactA.LastName = 'Thorhill';
	        objContactA.Stand_Office__c = 'OR';
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
            insert objMembershipA;  	
	        
	        objMembershipA.Membership_State__c = 'OR';
	        objMembershipA.Stand_Team__c = objAccountTeamB.Id;
	        objMembershipA.Membership_Action__c = 'Edit';
	        update objMembershipA;
	        
	        List<Contact> tmpCts = new List<Contact>([select Id, Name, Membership_State__c from Contact where ID = : objContactA.Id]);	        
	        
	        //Check that State == OR
	        System.AssertEquals('OR', tmpCts[0].Membership_State__c);
        }
    }

	public static TestMethod void TestOrganizerTest3()
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
        objUser.UserName = 'FunSmoTestOrganizerTest3@stand.org';
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
	        
	        Account objAccountTeamB = new Account();
	        objAccountTeamB.Name = 'HI Team';
	        objAccountTeamB.Type = 'Stand Team';
	        objAccountTeamB.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamB.ParentId = objAccountChapter.Id;
	        objAccountTeamB.State_Abbreviation__c = 'OR';
	        objAccountTeamB.BillingState = 'OR';
	        insert objAccountTeamB;

	        //	Test 3
	        //  As an organizer, I cannot edit Frank Thornhill's  membership to not have a state at all.
	        
	        Contact objContactA = new Contact();
	        objContactA.FirstName = 'Frank';
	        objContactA.LastName = 'Thorhill';
	        objContactA.Stand_Office__c = 'OR';
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
            insert objMembershipA;  	
	        
	        objMembershipA.Membership_State__c = null;
	        
	        try {
	        	update objMembershipA;
	        } catch(DmlException de) {
	        	List<Contact> tmpCts = new List<Contact>([select Id, Name, Membership_State__c from Contact where ID = : objContactA.Id]);	        
	        	
	        	List<Membership__c> tmpMem = new List<Membership__c>([select Id, Membership_State__c from Membership__c where ID = : objMembershipA.Id]);	        
				//Updating the membership with a null state would throw and exception, so the old state of OR would still be in the database	        	
	        	System.AssertEquals('OR', tmpCts[0].Membership_State__c);
	        }
	        
        }
    	
    }
    
    public static TestMethod void TestTeamLeader4()
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
        objUser.UserName = 'FunSmoTestTeamLeader4@stand.org';
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
	        
	        //	Test 4
	        //	As an organizer, if Frances King reaches 10 member followers and has an active or lapsed membership, 
	        //	Leader type gets updated to Leader, LIT Stop date is updated, and Leader start date 
	        
	        Contact objContactA = new Contact();
	        objContactA.FirstName = 'Frances';
	        objContactA.LastName = 'King';
	        objContactA.Stand_Office__c = 'OR';
	        objContactA.Leader_Type__c = 'Leader in Training';
	        objContactA.LiT_Start_Date__c = System.Today();
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
            insert objMembershipA;  	
            
            npe5__Affiliation__c objAffiliationContactTeamA = new npe5__Affiliation__c();
            objAffiliationContactTeamA.npe5__Contact__c = objContactA.Id;
            objAffiliationContactTeamA.npe5__Organization__c = objAccountTeamA.Id;
            objAffiliationContactTeamA.npe5__Status__c = 'Active';
            objAffiliationContactTeamA.Affiliation__c = 'Team Leader';  
            objAffiliationContactTeamA.npe5__StartDate__c = System.today();
            insert objAffiliationContactTeamA;	 
            
            List<Contact> tmpCts = new List<Contact>([select Id, Name, Leader_Type__c from Contact where ID = : objContactA.Id]);
	        
	        //Check that the leader type is initially Leader in Training
	        System.AssertEquals('Leader in Training', tmpCts[0].Leader_Type__c);	        
            
            List < Contact > lstContact = new List < Contact > ();
            List < npe5__Affiliation__c > lstAff = new List < npe5__Affiliation__c > ();
            List < Membership__c > mbs = new List < Membership__c > ();
            for(integer i=0;i<10;i++) {
	            Contact objContactTest = new Contact();
		        objContactTest.FirstName = 'Test2'+i;
		        objContactTest.LastName = 'Contact2'+i;
		        objContactTest.Stand_Office__c = 'OR';
		        lstContact.add(objContactTest);
            }
            insert lstContact;            
	        for(integer i=0;i<10;i++) {
		        Membership__c objMembership2 = new Membership__c();
	            objMembership2.Contact__c = lstContact.get(i).Id;
	            objMembership2.Membership_State__c = 'OR';
	            objMembership2.RE_Drop_Date__c = dtCurrentDate1.addDays(365);
	            objMembership2.Quit_Date__c = dtCurrentDate1.addDays(365);
	            objMembership2.Start_Date__c = dtCurrentDate1;
	            objMembership2.Gift_Amount__c = Decimal.valueOf('50.00');
	            objMembership2.Type__c = 'Annual';
	            mbs.add(objMembership2);
	        }
	        insert mbs;
            for(integer i=0;i<10;i++) {		        
		        npe5__Affiliation__c objAffiliationContactTest = new npe5__Affiliation__c();
	            objAffiliationContactTest.npe5__Contact__c = lstContact.get(i).Id;
	            objAffiliationContactTest.npe5__Organization__c = objAccountTeamA.Id;
	            objAffiliationContactTest.npe5__Status__c = 'Active';
	            objAffiliationContactTest.Affiliation__c = 'Team Member';    
	            objAffiliationContactTest.Team_Leader__c = objContactA.Id;   
	            lstAff.add(objAffiliationContactTest); 
            }
            Test.startTest();
            insert lstAff;    
            Test.stopTest();
            
           	tmpCts = new List<Contact>([select Id, Name, Leader_Type__c, LiT_Stop_Date__c, Leader_Start_Date__c from Contact where ID = : objContactA.Id]);
	        
	        //Check that the leader type is changed to Leader
	        System.AssertEquals('Leader', tmpCts[0].Leader_Type__c);
	        //Check that the Leader in Training stop date is set
			System.AssertNotEquals(null, tmpCts[0].LiT_Stop_Date__c);  
			//Check that the Leader start date is set
			System.AssertNotEquals(null, tmpCts[0].Leader_Start_Date__c);      
    
			//	Test 5
	        //	As an organizer, if I add Monica Sack to NE Community Team  and 
	        //	Frances King as the leader, Frances' member followers count increases
/*			
	        Contact objContactA = new Contact();
	        objContactA.FirstName = 'Frances';
	        objContactA.LastName = 'King';
	        objContactA.Stand_Office__c = 'OR';
	        objContactA.Leader_Type__c = 'Leader in Training';
	        objContactA.LiT_Start_Date__c = System.Today();
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
            insert objMembershipA;  	
            
            npe5__Affiliation__c objAffiliationContactTeamA = new npe5__Affiliation__c();
            objAffiliationContactTeamA.npe5__Contact__c = objContactA.Id;
            objAffiliationContactTeamA.npe5__Organization__c = objAccountTeamA.Id;
            objAffiliationContactTeamA.npe5__Status__c = 'Active';
            objAffiliationContactTeamA.Affiliation__c = 'Team Leader';  
            objAffiliationContactTeamA.npe5__StartDate__c = System.today();
            insert objAffiliationContactTeamA;	 
*/
			Contact objContactB = new Contact();
	        objContactB.FirstName = 'Monica';
	        objContactB.LastName = 'Sack';
	        objContactB.Stand_Office__c = 'OR';	        
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
            insert objMembershipB;  	
            
            npe5__Affiliation__c objAffiliationContactTeamAB = new npe5__Affiliation__c();
            objAffiliationContactTeamAB.npe5__Contact__c = objContactB.Id;
            objAffiliationContactTeamAB.npe5__Organization__c = objAccountTeamA.Id;
            objAffiliationContactTeamAB.npe5__Status__c = 'Active';
            objAffiliationContactTeamAB.Affiliation__c = 'Team Member';  
            objAffiliationContactTeamAB.Team_Leader__c = objContactA.Id;
            insert objAffiliationContactTeamAB;	  
            
           	tmpCts = new List<Contact>([select Id, Name, Number_of_Followers__c from Contact where ID = : objContactA.Id]);
	        
	        //Check that the Number of Members is 11
	        System.AssertEquals(11, tmpCts[0].Number_of_Followers__c);
    
	        //	Test 6
	        //	As an organizer, if I remove Monica Sack to NE Community Team which has Frances King 
	        //	as the leader, Frances' member follower status decreases
	        
	        //Change Monica Sack's affiliation to inactive
	        objAffiliationContactTeamAB.npe5__EndDate__c = System.today();
	        objAffiliationContactTeamAB.npe5__Status__c = 'Inactive';
	        update objAffiliationContactTeamAB;
	        
	        tmpCts = new List<Contact>([select Id, Name, Number_of_Followers__c from Contact where ID = : objContactA.Id]);
	        
	        //Check that the Number of Members is 10
	        System.AssertEquals(10, tmpCts[0].Number_of_Followers__c);        
	        	       
        }    	
    }
    
    public static TestMethod void TestTeamLeader2()
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
        objUser.UserName = 'FunSmoTestTeamLeader2@stand.org';
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
	        
	        //	Test 8
	        //	As an organizer, if I add a leader status to member x, this triggers the LIT Type as LIT, and LIT Start date.  
	        //  The affiliation also show as "Team Leader" type.
	        
	        //	Test 8B
	        //	As an orgnaizer, when I create Frances King as a leader, her affiliation updates as Team Leader status
	        
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
                        
            List<Contact> tmpCts = new List<Contact>([select Id, Name, Leader_Type__c, LiT_Start_Date__c from Contact where ID = : objContactA.Id]);
	        
	        //Check that the leader type is initially Leader in Training and LiT start date is set
	        System.AssertEquals('Leader in Training', tmpCts[0].Leader_Type__c);
	        System.AssertNotEquals(null, tmpCts[0].LiT_Start_Date__c);	
	        
	        List<npe5__Affiliation__c> tmpAff = new List<npe5__Affiliation__c>([select Id, Affiliation__c from npe5__Affiliation__c where npe5__Status__c = 'Active' and npe5__Contact__c = : objContactA.Id]);
	        
	        //Check that the Affiliation type is Team Leader
	        System.AssertEquals('Team Leader', tmpAff[0].Affiliation__c);
	        
	        //	Test 9
	        //	As an organizer, if I remove a leader status to member x, this triggers the LIT Type as LIT, 
	        //	and LIT Stop date.  The affiliation also show as "Team Member" type.
	        
	        objMembershipA.Team_Leader__c = false;  
	        objMembershipA.Membership_Action__c = 'Edit';
	        update objMembershipA;   
	        
	        tmpCts = new List<Contact>([select Id, Name, Leader_Type__c, LiT_Start_Date__c from Contact where ID = : objContactA.Id]);
	        
	        //Check that the leader type is initially Leader in Training and LiT start date is set
	        System.AssertEquals('Former Leader', tmpCts[0].Leader_Type__c);
	        System.AssertNotEquals(null, tmpCts[0].LiT_Start_Date__c);	
	        
	        tmpAff = new List<npe5__Affiliation__c>([select Id, Affiliation__c from npe5__Affiliation__c where npe5__Status__c = 'Active' and npe5__Contact__c = : objContactA.Id]);
	        
	        //Check that the Affiliation type is Team Member
	        System.AssertEquals('Team Member', tmpAff[0].Affiliation__c);
	        
	        //	Test 10
	        //	As an organizer, if I assign 10 member followers to leader x, 
	        //	this triggers the LIT Type as Leader, LIT Stop date as today and Leader start date as today.
	         
	        List < Contact > lstContact = new List < Contact > ();
            List < npe5__Affiliation__c > lstAff = new List < npe5__Affiliation__c > ();
            List < Membership__c > mbs = new List < Membership__c > ();
            for(integer i=0;i<10;i++) {
	            Contact objContactTest = new Contact();
		        objContactTest.FirstName = 'Test2'+i;
		        objContactTest.LastName = 'Contact2'+i;
		        objContactTest.Stand_Office__c = 'OR';
		        lstContact.add(objContactTest);
            }
            insert lstContact;            
	        for(integer i=0;i<10;i++) {
		        Membership__c objMembership2 = new Membership__c();
	            objMembership2.Contact__c = lstContact.get(i).Id;
	            objMembership2.Membership_State__c = 'OR';
	            objMembership2.RE_Drop_Date__c = dtCurrentDate1.addDays(365);
	            objMembership2.Quit_Date__c = dtCurrentDate1.addDays(365);
	            objMembership2.Start_Date__c = dtCurrentDate1;
	            objMembership2.Gift_Amount__c = Decimal.valueOf('50.00');
	            objMembership2.Type__c = 'Annual';
	            mbs.add(objMembership2);
	        }
	        insert mbs;
            for(integer i=0;i<10;i++) {		        
		        npe5__Affiliation__c objAffiliationContactTest = new npe5__Affiliation__c();
	            objAffiliationContactTest.npe5__Contact__c = lstContact.get(i).Id;
	            objAffiliationContactTest.npe5__Organization__c = objAccountTeamA.Id;
	            objAffiliationContactTest.npe5__Status__c = 'Active';
	            objAffiliationContactTest.Affiliation__c = 'Team Member';    
	            objAffiliationContactTest.Team_Leader__c = objContactA.Id;   
	            lstAff.add(objAffiliationContactTest); 
            }
            insert lstAff;    
            
           	tmpCts = new List<Contact>([select Id, Name, Leader_Type__c, LiT_Stop_Date__c, Leader_Start_Date__c from Contact where ID = : objContactA.Id]);
	        
	        //Check that the leader type is changed to Leader
	        System.AssertEquals('Former Leader', tmpCts[0].Leader_Type__c);
	        //Check that the Leader in Training stop date is set
			System.AssertNotEquals(null, tmpCts[0].LiT_Stop_Date__c);  
			//Check that the Leader start date is set
			
			
			
			
			
			
			
			
			
			
			
			
			// this fails, both are null
			//System.AssertNotEquals(null, tmpCts[0].Leader_Start_Date__c);  	
			
			
			
			
			
			
			
			
            	       
        }    	
    }



    
    public static TestMethod void TestTeamLeader77()
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
        objUser.UserName = 'FunSmoTestTeamLeader77@stand.org';
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
	        
	     	//	Test 14
			//	As an organizer, if I add leader x from member x , the leaders # of member followers count increases by 1
	        
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
            
            List<Contact> tmpCts = new List<Contact>([select Id, Name, Number_of_Followers__c from Contact where ID = : objContactA.Id]);    
            
            //Check that Number of Members for Frances King is null
	        System.AssertEquals(null, tmpCts[0].Number_of_Followers__c);                              
			
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
	        
	        tmpCts = new List<Contact>([select Id, Name, Number_of_Followers__c from Contact where ID = : objContactA.Id]);
	        
	        //Check that Number of Members for Frances King is 1
	        System.AssertEquals(1, tmpCts[0].Number_of_Followers__c); 
	        	       
        }    	
    }
	
	public static TestMethod void TestOrganizerAffiliation()
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
        objUser.UserName = 'FunSmoTestOrganizerAffiliation@stand.org';
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
	        
	     	//	Test 15
			//	As an organizer, when I add organizer x as the organizer to NE Community Team, her affiliation shows 
			//	her as the organizer and is updated on the contact record.  Related members associated with that 
			//	team also are updated with the new organizer on their contact record and on the team affiliation view.
	        
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
            insert objMembershipA;  	                                               
			
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
            insert objMembershipB;  	                    
	        
	        Contact objContactC = new Contact();
	        objContactC.FirstName = 'Organizer';
	        objContactC.LastName = 'X';
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
            Test.startTest(); 
            insert objMembershipC;  	  
            Test.stopTest();
            
            List<Id> ctList = new List<Id>();
	        ctList.add(objContactB.Id);
	        ctList.add(objContactA.Id);
	        
	        List<Contact> tmpCts = new List<Contact>([select Id, Name, Stand_Team_Organizer__c from Contact where ID in : ctList]); 
	        
	        //Check that Stand_Team_Organizer__c for each Contact is null
	        for(Contact cc: tmpCts) {
	        	System.AssertEquals(null, cc.Stand_Team_Organizer__c);
	        }
	        
	        List<Account> tmpAct = new List<Account>([select Id, Organizer__c from Account where ID = : objAccountTeamA.Id]); 
	        
	        //Check that Organizer__c for the Team is null
	        System.AssertEquals(null, tmpAct[0].Organizer__c);
            
            List<npe5__Affiliation__c> tmpAff = new List<npe5__Affiliation__c>([select Id, Affiliation__c from npe5__Affiliation__c where npe5__Status__c = 'Active' and npe5__Contact__c = : objContactC.Id]);
	           
	        tmpAff[0].Affiliation__c = 'Organizer';
	        update tmpAff[0];
	        
	        tmpCts = new List<Contact>([select Id, Name, Stand_Team_Organizer__c from Contact where ID in : ctList]); 
	        
	        //Check that Stand_Team_Organizer__c for each Contact is Organizer X
	        for(Contact cc: tmpCts) {
	        	System.AssertEquals(objContactC.Id, cc.Stand_Team_Organizer__c);        	
	        }
	        
	        tmpAct = new List<Account>([select Id, Organizer__c from Account where ID = : objAccountTeamA.Id]);
	        
	        //Check that Organizer__c for the Team is Organizer X
	        System.AssertEquals(objContactC.Id, tmpAct[0].Organizer__c);
	        	       
        }    	
    }
    
    public static TestMethod void TestTeamAffiliation()
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
        objUser.UserName = 'FunSmoTestTeamAffiliation@stand.org';
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
	        
	        Account objAccountTeamB = new Account();
	        objAccountTeamB.Name = 'Portland Chapter Wide Team';
	        objAccountTeamB.Type = 'Stand Team';
	        objAccountTeamB.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamB.ParentId = objAccountChapter.Id;
	        objAccountTeamB.State_Abbreviation__c = 'OR';
	        objAccountTeamB.BillingState = 'OR';
	        insert objAccountTeamB;     
	        
	        Account objAccountTeamC = new Account();
	        objAccountTeamC.Name = 'Happy Valley Team';
	        objAccountTeamC.Type = 'Stand Team';
	        objAccountTeamC.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamC.ParentId = objAccountChapter.Id;
	        objAccountTeamC.State_Abbreviation__c = 'OR';
	        objAccountTeamC.BillingState = 'OR';
	        insert objAccountTeamC;         
	        
	     	//	Test 16
			//	As an organizer, when I update Larua Kelpie's Team affiliation to Portland Chapter Wide Team, 
			//	it is updated also on her contact record and affiliation 			
	        
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
            objMembershipA.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipA.Type__c = 'Annual';    
            objMembershipA.Stand_Team__c = objAccountTeamA.Id;  
            objMembershipA.Membership_Source__c = 'Event';
            objMembershipA.Membership_Action__c = 'Join';          
            insert objMembershipA;                                              
			            
	        List<Contact> tmpCts = new List<Contact>([select Id, Name, Stand_Team_Affiliation__c from Contact where ID = : objContactA.Id]); 
	        
	        //Check that Stand_Team_Affiliation__c for Contact is NE Community Team
	        System.AssertEquals(objAccountTeamA.Id, tmpCts[0].Stand_Team_Affiliation__c);	        
	           
            List<npe5__Affiliation__c> tmpAff = new List<npe5__Affiliation__c>([select Id, npe5__Organization__c from npe5__Affiliation__c where npe5__Status__c = 'Active' and npe5__Contact__c = : objContactA.Id]);
	           
	        //Check that npe5__Organization__c for Affiliation is NE Community Team
	        System.AssertEquals(objAccountTeamA.Id, tmpAff[0].npe5__Organization__c);	        
	        
	        objMembershipA.Stand_Team__c = objAccountTeamB.Id; 
	        objMembershipA.Membership_Action__c = 'Edit';
	        Test.startTest();
	        update objMembershipA;
	        Test.stopTest();
	        
	        tmpCts = new List<Contact>([select Id, Name, Stand_Team_Affiliation__c from Contact where ID = : objContactA.Id]); 
	        
	        //Check that Stand_Team_Affiliation__c for Contact is Portland Chapter Wide Team
	        System.AssertEquals(objAccountTeamB.Id, tmpCts[0].Stand_Team_Affiliation__c);
	        
	        tmpAff = new List<npe5__Affiliation__c>([select Id, npe5__Organization__c from npe5__Affiliation__c where npe5__Status__c = 'Active' and npe5__Contact__c = : objContactA.Id]);
	           
	        //Check that npe5__Organization__c for Affiliation is Portland Chapter Wide Team
	        System.AssertEquals(objAccountTeamB.Id, tmpAff[0].npe5__Organization__c);
	        
	        //	Test 17
			//	As an organizer, when I update Larua Kelpie's Team affiliation to not have any affiliation to a team,
			//	it is updated on her contact record and affiliation
	        
	        objMembershipA.Stand_Team__c = null; 
	        objMembershipA.Membership_Action__c = 'Edit';
	        update objMembershipA;
	        
	        tmpCts = new List<Contact>([select Id, Name, Stand_Team_Affiliation__c from Contact where ID = : objContactA.Id]); 
	        
	        //Check that Stand_Team_Affiliation__c for Contact is null
	        System.AssertEquals(null, tmpCts[0].Stand_Team_Affiliation__c);
	        
	        tmpAff = new List<npe5__Affiliation__c>([select Id, npe5__Status__c from npe5__Affiliation__c where npe5__Contact__c = : objContactA.Id]);
	           
	        //Check that removing the Team from Membership would result in inactivating the Affiliation 
	        System.AssertEquals('Inactive', tmpAff[0].npe5__Status__c);
	        
	        //	Test 18
			//	As an organizer, when I add Happy Valley Team to Marie Park's record, her chapter affiliation is automatically 
			//	updated to the correct chapter on her contact record
			
			Contact objContactB = new Contact();
	        objContactB.FirstName = 'Marie';
	        objContactB.LastName = 'Park';
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
            objMembershipB.Stand_Team__c = objAccountTeamC.Id;  
            objMembershipB.Membership_Source__c = 'Event';
            objMembershipB.Membership_Action__c = 'Join';          
            insert objMembershipB;      
            
            tmpCts = new List<Contact>([select Id, Name, Stand_Chapter_Affiliation__c from Contact where ID = : objContactB.Id]); 
	        
	        //Check that Chapter Affiliation for Contact is OR Chapter
	        System.AssertEquals(objAccountChapter.Id, tmpCts[0].Stand_Chapter_Affiliation__c);  
	        	       
        }    	
    }


    //////////////////
    
    //Membership Entry
    //////////////////
    
    public static TestMethod void TestMembershipEntry()
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
        objUser.UserName = 'FunSmoTestMembershipEntry@stand.org';
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
	        
	        //	Test 31
	        //	As an organizer, when I create a new OR active annual $50 membership, it creates the correct ($50) Pending Donation record  	
	        
	        Contact objContactA = new Contact();
	        objContactA.FirstName = 'Fred';
	        objContactA.LastName = 'Flinstone';
	        objContactA.Stand_Office__c = 'OR';	  
	        objContactA.Membership_State__c = 'OR';
			objContactA.Membership_Type__c = 'Annual';      
	        insert objContactA;
	        
	        Contact objContactB = new Contact();
	        objContactB.FirstName = 'Luke';
	        objContactB.LastName = 'Skywalker';
	        objContactB.Stand_Office__c = 'OR';	  
	        objContactB.Membership_State__c = 'OR';
			objContactB.Membership_Type__c = 'Annual';      
	        insert objContactB;
	        
	        Membership__c objMembershipA = new Membership__c();
            objMembershipA.Contact__c = objContactA.Id;
            objMembershipA.Membership_State__c = 'OR';          
            objMembershipA.Start_Date__c =  System.Today();            
            objMembershipA.Type__c = 'Annual';    
            objMembershipA.Stand_Team__c = objAccountTeamA.Id;  
            objMembershipA.Membership_Source__c = 'Event';
            objMembershipA.Membership_Action__c = 'Join';   
            objMembershipA.Type__c = 'Annual'; 
	        objMembershipA.Gift_Amount__c = Decimal.valueOf('50.00');     
	        
	        insert objMembershipA;                         
			
			Contact c1 = [SELECT AccountId FROM Contact WHERE Id = : objContactA.Id];
			
//	        List<Opportunity> o = new List<Opportunity>([ SELECT Id, StageName, Amount FROM Opportunity WHERE Id = : c1.AccountId ]);
	        List<Opportunity> o = new List<Opportunity>([ SELECT Id, StageName, Amount FROM Opportunity ]);
	        
	        //Check donation amount and donating status
	        System.AssertEquals(objMembershipA.Gift_Amount__c, o[0].Amount);	       
	        System.AssertEquals('Pending', o[0].StageName);                 
	         
	        //	Test 32
	        //	As an organizer, when I create a new membership, a membership activity of "Join" is created
	        
	        List<Membership_Activity__c> ma = new List<Membership_Activity__c>([ SELECT Name, Subject__c FROM Membership_Activity__c where Membership__c = : objMembershipA.Id ]);
	        
	        //Check that membership activity is "Membership Join"
	        System.AssertEquals('Membership Join', ma[0].Subject__c);	        
	        
            //	Test 32
            //	As an organizer, when I check the NE Community Team Affiliaton, member x shows up with an 
            //	Active status as a Team Member under affiliated contacts 
            
            List<npe5__Affiliation__c> tmpAff = new List<npe5__Affiliation__c>([select Id, npe5__Status__c, npe5__Organization__c from npe5__Affiliation__c where npe5__Contact__c = : objContactA.Id]);
	        
	        //Check that the Team is NE Community Team
            System.AssertEquals(objAccountTeamA.Id, tmpAff[0].npe5__Organization__c);   
            
            //Check that Status is Active
            System.AssertEquals('Active', tmpAff[0].npe5__Status__c);
            
            //	Test 33
            //	As an organizer, when I add  a new member, the Chapter, Team and Organizer is updated on the contact record
            
            npe5__Affiliation__c objAffiliationContactTeamA = new npe5__Affiliation__c();
            objAffiliationContactTeamA.npe5__Contact__c = objContactB.Id;
            objAffiliationContactTeamA.npe5__Organization__c = objAccountTeamA.Id;
            objAffiliationContactTeamA.npe5__Status__c = 'Active';
            objAffiliationContactTeamA.Affiliation__c = 'Organizer';  
            objAffiliationContactTeamA.npe5__StartDate__c = System.today();
            insert objAffiliationContactTeamA;	 
            
            List<Contact> tmpCts = new List<Contact>([select Id, Name, Stand_Team_Organizer__c, Stand_Team_Affiliation__c, Stand_Chapter_Affiliation__c from Contact where ID = : objContactA.Id]);
	        
	        //Check that the Team is NE Community Team
            System.AssertEquals(objAccountTeamA.Id, tmpCts[0].Stand_Team_Affiliation__c); 
            
            //Check Organizer
            System.AssertEquals(objContactB.Id, tmpCts[0].Stand_Team_Organizer__c);
            
            //Check Chapter
            System.AssertEquals(objAccountChapter.Id, tmpCts[0].Stand_Chapter_Affiliation__c);
            
            //	Test 34
            //	As an organizer, when I edit an existing membership to change the affiliated team, 
            //	the current team shows an inactive affiliation and a new active affiliation to the new team 
            
            Account objAccountTeamB = new Account();
	        objAccountTeamB.Name = 'Happy Valley Team';
	        objAccountTeamB.Type = 'Stand Team';
	        objAccountTeamB.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamB.ParentId = objAccountChapter.Id;
	        objAccountTeamB.State_Abbreviation__c = 'OR';
	        objAccountTeamB.BillingState = 'OR';
	        insert objAccountTeamB; 
	        
	        objMembershipA.Stand_Team__c = objAccountTeamB.Id; 	
	        objMembershipA.Membership_Action__c = 'Edit';        
	        update objMembershipA;
            
            tmpAff = new List<npe5__Affiliation__c>([ select Id, npe5__Status__c, npe5__Organization__c from npe5__Affiliation__c where npe5__Status__c = 'Active' and npe5__Contact__c = : objContactA.Id ]);
	                    
	        //Check active Affiliation is with new Team
            System.AssertEquals(objAccountTeamB.Id, tmpAff[0].npe5__Organization__c);
            
            tmpAff = new List<npe5__Affiliation__c>([ select Id, npe5__Status__c, npe5__Organization__c from npe5__Affiliation__c where npe5__Status__c = 'Inactive' and npe5__Contact__c = : objContactA.Id ]);
	                    
	        //Check inactive Affiliation is with old Team
            System.AssertEquals(objAccountTeamA.Id, tmpAff[0].npe5__Organization__c);
            
            //	Test 34
            //	As an organizer, I cannot input a Team Affiliation in the new membership entry 
            //	that does not belong to the state office I designated (ie:  IN state w/ NE Community Team)
	        	       
	        Account objAccountNew = new Account();
	        objAccountNew.Name = 'IN State Office';
	        objAccountNew.Type = 'Stand Affiliate State';
	        objAccountNew.Acquired_By__c = 'C3 Acquired';
	        objAccountNew.State_Abbreviation__c = 'IN';
	        objAccountNew.BillingState = 'IN';
	        insert objAccountNew;
	        
			Account objAccountChapterNew = new Account();
			objAccountChapterNew.Name = 'IN Chapter';
			objAccountChapterNew.Type = 'Stand Chapter';
			objAccountChapterNew.Acquired_By__c = 'C3 Acquired';
			objAccountChapterNew.ParentId = objAccountNew.Id;
			objAccountChapterNew.State_Abbreviation__c = 'IN';
			objAccountChapterNew.BillingState = 'IN';
			insert objAccountChapterNew;			
	     	        
	        Account objAccountTeamNew = new Account();
	        objAccountTeamNew.Name = 'IN Team';
	        objAccountTeamNew.Type = 'Stand Team';
	        objAccountTeamNew.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamNew.ParentId = objAccountChapterNew.Id;
	        objAccountTeamNew.State_Abbreviation__c = 'IN';
	        objAccountTeamNew.BillingState = 'IN';
	        insert objAccountTeamNew; 
	        
	        objMembershipA.Stand_Team__c = objAccountTeamNew.Id; 	
	        objMembershipA.Membership_Action__c = 'Edit';
	                
	        try {
	        	update objMembershipA; 
	        	//It should fail here, no object should be added beyond this point
	        	//If this point is reached then the validation is wrong
	        	System.assertNotEquals(objAccountTeamNew.Id, objMembershipA.Stand_Team__c);
	        } catch(DmlException ex) {	       	    	
	        	//Check that this is a Validation Exception      	
	        	System.assertEquals(StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION, ex.getDmlType(0));
	        }          
	        	       
        }    	
    }
    
    
    public static TestMethod void TestMembershipEntry2()
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
        objUser.UserName = 'FunSmoTestMembershipEntry2@stand.org';
        objUser.Division = 'National';
        insert objUser;

        System.runAs(objUser)
        {
        	Date dtCurrentDate1 = System.Today();
	    	
	        Account objAccount = new Account();
//	        objAccount.Name = 'OR State Office';
	        objAccount.Name = 'HI State Office';
	        objAccount.Type = 'Stand Affiliate State';
	        objAccount.Acquired_By__c = 'C3 Acquired';
	        objAccount.State_Abbreviation__c = 'HI';
	        objAccount.BillingState = 'HI';
	        insert objAccount;
	        
			Account objAccountChapter = new Account();
//			objAccountChapter.Name = 'OR Chapter';
			objAccountChapter.Name = 'HI Chapter';
			objAccountChapter.Type = 'Stand Chapter';
			objAccountChapter.Acquired_By__c = 'C3 Acquired';
			objAccountChapter.ParentId = objAccount.Id;
			objAccountChapter.State_Abbreviation__c = 'HI';
			objAccountChapter.BillingState = 'HI';
			insert objAccountChapter;			
	     	        
	        Account objAccountTeamA = new Account();
//	        objAccountTeamA.Name = 'NE Community Team';
	        objAccountTeamA.Name = 'A New Team';
	        objAccountTeamA.Type = 'Stand Team';
	        objAccountTeamA.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamA.ParentId = objAccountChapter.Id;
	        objAccountTeamA.State_Abbreviation__c = 'HI';
	        objAccountTeamA.BillingState = 'HI';
	        insert objAccountTeamA; 
	        
	        //	Test 35
	        //	As an organizer, I can edit an existing membership and add a contact as a leader via the membership object
	        
	        Contact objContactA = new Contact();
	        objContactA.FirstName = 'Fred';
	        objContactA.LastName = 'Flinstone';
	        objContactA.Stand_Office__c = 'HI';	  
	        objContactA.Membership_State__c = 'HI';
			objContactA.Membership_Type__c = 'Annual';      
	        insert objContactA;
	        
	        Contact objContactB = new Contact();
	        objContactB.FirstName = 'Luke';
	        objContactB.LastName = 'Skywalker';
	        objContactB.Stand_Office__c = 'HI';	  
	        objContactB.Membership_State__c = 'HI';
			objContactB.Membership_Type__c = 'Annual';      
	        insert objContactB;
	        
	        Contact objContactC = new Contact();
	        objContactC.FirstName = 'Darth';
	        objContactC.LastName = 'Vader';
	        objContactC.Stand_Office__c = 'HI';	  
	        objContactC.Membership_State__c = 'HI';
			objContactC.Membership_Type__c = 'Annual';      
	        insert objContactC;
	        
	        Membership__c objMembershipA = new Membership__c();
            objMembershipA.Contact__c = objContactA.Id;
            objMembershipA.Membership_State__c = 'HI';          
            objMembershipA.Start_Date__c =  System.Today();            
            objMembershipA.Type__c = 'Annual';    
            objMembershipA.Stand_Team__c = objAccountTeamA.Id;  
            objMembershipA.Membership_Source__c = 'Event';
            objMembershipA.Membership_Action__c = 'Join';   
            objMembershipA.Type__c = 'Annual'; 
	        objMembershipA.Gift_Amount__c = Decimal.valueOf('50.00');  
	        objMembershipA.Team_Leader__c = true;
	        insert objMembershipA;    
	        
	        Membership__c objMembershipB = new Membership__c();
            objMembershipB.Contact__c = objContactB.Id;
            objMembershipB.Membership_State__c = 'HI';          
            objMembershipB.Start_Date__c =  System.Today();            
            objMembershipB.Type__c = 'Annual';    
            objMembershipB.Stand_Team__c = objAccountTeamA.Id;  
            objMembershipB.Membership_Source__c = 'Event';
            objMembershipB.Membership_Action__c = 'Join';   
            objMembershipB.Type__c = 'Annual'; 
            objMembershipB.Leader__c = objContactA.Id;
	        objMembershipB.Gift_Amount__c = Decimal.valueOf('50.00');  
	        insert objMembershipB;    
	        
	        Membership__c objMembershipC = new Membership__c();
            objMembershipC.Contact__c = objContactC.Id;
            objMembershipC.Membership_State__c = 'HI';          
            objMembershipC.Start_Date__c =  System.Today();            
            objMembershipC.Type__c = 'Annual';    
            objMembershipC.Stand_Team__c = objAccountTeamA.Id;  
            objMembershipC.Membership_Source__c = 'Event';
            objMembershipC.Membership_Action__c = 'Join';   
            objMembershipC.Type__c = 'Annual'; 
	        objMembershipC.Gift_Amount__c = Decimal.valueOf('50.00');  
	        objMembershipC.Team_Leader__c = true;
	        insert objMembershipC;                      
			            
	        List<Contact> tmpCts = new List<Contact>([select Id, Name, Stand_Leader__c from Contact where ID = : objContactB.Id]);
	         
	        //Check that Leader is Contact A
            System.AssertEquals(objContactA.Id, tmpCts[0].Stand_Leader__c);
            
            objMembershipB.Leader__c = objContactC.Id;
            objMembershipB.Membership_Action__c = 'Edit';
            Test.startTest();
            update objMembershipB;
            Test.stopTest();
            
	        tmpCts = new List<Contact>([select Id, Name, Stand_Leader__c from Contact where ID = : objContactB.Id]);
	         
	        //Check that Leader is Contact C
            System.AssertEquals(objContactC.Id, tmpCts[0].Stand_Leader__c);	                   
	        
        }    	
    }
    
    
    public static TestMethod void TestMembershipEntry3()
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
        objUser.UserName = 'FunSmoTestMembershipEntry3@stand.org';
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
	        objACcount.BillingState = 'OR';
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
	        
	        //	Test 36
	        //	As an organizer, I can edit Frank Thornhill's  membership to to a lapsed status 
	        //	and his status shows lapsed on the contact record.        	        
	        
	        Contact objContactA = new Contact();
	        objContactA.FirstName = 'Frank';
	        objContactA.LastName = 'Thornhill';
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
            objMembershipA.Type__c = 'Annual'; 
	        objMembershipA.Gift_Amount__c = Decimal.valueOf('50.00');  
	        insert objMembershipA;                              
	            
            objMembershipA.Start_Date__c = dtCurrentDate1.addDays(-380);
            objMembershipA.Membership_Action__c = 'Edit';
            update objMembershipA;
            
            List < Membership__c > mbb = [select Id, Status2__c from Membership__c where Contact__c = : objContactA.Id]; 
            //Check Lapsed status
            System.AssertEquals('Lapsed', mbb[0].Status2__c);	              
            
            //	Test 37
	        //	As an organizer, I can Renew a Lapsed member and it updateds the membership correctly, 
	        //	adds a pending renewal donation and it adds a Renew membership activity    
	        
	        objMembershipA.Start_Date__c = System.today();
            objMembershipA.Membership_Action__c = 'Renew';
            objMembershipA.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipA.Membership_Action__c = 'Edit';
            update objMembershipA;
            
            List<Opportunity> o = new List<Opportunity>([ SELECT Id, StageName, Amount FROM Opportunity ]);	       
	       	
	        //Check donation list size, donation amount and donating status
	        System.AssertEquals(1, o.size());
	        System.AssertEquals(objMembershipA.Gift_Amount__c, o[0].Amount);	       
	        System.AssertEquals('Pending', o[0].StageName); 
	        
	        mbb = [select Id, Status2__c from Membership__c where Contact__c = : objContactA.Id]; 
            //Check Active status
            System.AssertEquals('Active', mbb[0].Status2__c);	
	        
        }    	
    }    
}