@isTest
public with sharing class ContactRelationship_Test {
  public static TestMethod void TestRelationship()
    {
    	/*
	    Profile objProfile = [Select Id from Profile where Name='Standard User'];
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
	    objUser.UserName = 'testclassuser@test.com';
	    objUser.Division = 'National';
	    Insert objUser;
	    System.runAs(objUser)
	    {
	        
	        Contact objContact = new Contact();
	        objContact.FirstName = 'Test';
	        objContact.LastName = 'User';
	        objContact.Stand_Employee_User__c = objUser.Id;
	        Insert objContact;
	        
	        Apexpages.StandardController stdController = new Apexpages.StandardController(objContact);
	        
	        // ------ STATE -------------
	        Account objAccount = new Account();
	        objAccount.Name = 'Test State';
	        objAccount.Type = 'Stand Affiliate State';
	        objAccount.Acquired_By__c = 'C3 Acquired';
	        objAccount.State_Abbreviation__c = 'HI';
	        Insert objAccount;
	        
	        // ------ Chapter 1 -------------
	        Account objAccountChapter1 = new Account();
	        objAccountChapter1.Name = 'Test Chapter1';
	        objAccountChapter1.Type = 'Stand Chapter';
	        objAccountChapter1.Acquired_By__c = 'C3 Acquired';
	        objAccountChapter1.ParentId = objAccount.Id;
	        Insert objAccountChapter1;
	        
	        // ------ Chapter 2 -------------
	        Account objAccountChapter2 = new Account();
	        objAccountChapter2.Name = 'Test Chapter2';
	        objAccountChapter2.Type = 'Stand Chapter';
	        objAccountChapter2.Acquired_By__c = 'C3 Acquired';
	        objAccountChapter2.ParentId = objAccount.Id;
	        Insert objAccountChapter2;
	        
	        // ------ Team 1-1 -------------
	        Account objAccountTeam11 = new Account();
	        objAccountTeam11.Name = 'Test Team11';
	        objAccountTeam11.Type = 'Stand Team';
	        objAccountTeam11.Acquired_By__c = 'C3 Acquired';
	        objAccountTeam11.ParentId = objAccountChapter1.Id;
	        Insert objAccountTeam11;
	        
	        // ------ Team 1-2 -------------
	        Account objAccountTeam12 = new Account();
	        objAccountTeam12.Name = 'Test Team12';
	        objAccountTeam12.Type = 'Stand Team';
	        objAccountTeam12.Acquired_By__c = 'C3 Acquired';
	        objAccountTeam12.ParentId = objAccountChapter1.Id;
	        Insert objAccountTeam12;
	        
	        // ------ Team 2-1 -------------
	        Account objAccountTeam21 = new Account();
	        objAccountTeam21.Name = 'Test Team21';
	        objAccountTeam21.Type = 'Stand Team';
	        objAccountTeam21.Acquired_By__c = 'C3 Acquired';
	        objAccountTeam21.ParentId = objAccountChapter2.Id;
	        Insert objAccountTeam21;
	        
	        // ------ Team 2-2 -------------
	        Account objAccountTeam22 = new Account();
	        objAccountTeam22.Name = 'Test Team22';
	        objAccountTeam22.Type = 'Stand Team';
	        objAccountTeam22.Acquired_By__c = 'C3 Acquired';
	        objAccountTeam22.ParentId = objAccountChapter2.Id;
	        Insert objAccountTeam22;
	        
	        // ------ Contact 1 -------------
	        Contact objContactChapter1 = new Contact();
	        objContactChapter1.FirstName = 'Test';
	        objContactChapter1.LastName = 'Contact Chapter1';
	        objContactChapter1.Stand_Office__c = 'HI';
	        //objContactChapter1.Stand_Chapter_Affiliation__c = objAccountChapter1.Id;
	        Insert objContactChapter1;
	        
	        npe5__Affiliation__c objAffiliationContactChapter1 = new npe5__Affiliation__c();
	        objAffiliationContactChapter1.npe5__Contact__c = objContactChapter1.Id;
	        objAffiliationContactChapter1.npe5__Organization__c = objAccountChapter1.Id;
	        objAffiliationContactChapter1.npe5__Status__c = 'Active';
	        objAffiliationContactChapter1.Affiliation__c = 'Chapter Contact';
	        Insert objAffiliationContactChapter1;
	        
	        // ------ Contact 1-1 -------------
            Contact objContactTeam11 = new Contact();
            objContactTeam11.FirstName = 'Test';
            objContactTeam11.LastName = 'Contact Team11';
            objContactTeam11.Stand_Office__c = 'HI';
            //objContactChapter1.Stand_Chapter_Affiliation__c = objAccountChapter1.Id;
            //objContactChapter1.Stand_Team_Affiliation__c = objAccountTeam11.Id;
            Insert objContactTeam11;
            
            npe5__Affiliation__c objAffiliationContactTeam11 = new npe5__Affiliation__c();
            objAffiliationContactTeam11.npe5__Contact__c = objContactTeam11.Id;
            objAffiliationContactTeam11.npe5__Organization__c = objAccountTeam11.Id;
            objAffiliationContactTeam11.npe5__Status__c = 'Active';
            objAffiliationContactTeam11.Affiliation__c = 'Team Member';
            Insert objAffiliationContactTeam11;
            
            npe5__Affiliation__c objAffiliationContactChapter11 = new npe5__Affiliation__c();
            objAffiliationContactChapter11.npe5__Contact__c = objContactTeam11.Id;
            objAffiliationContactChapter11.npe5__Organization__c = objAccountChapter1.Id;
            objAffiliationContactChapter11.npe5__Status__c = 'Active';
            objAffiliationContactChapter11.Affiliation__c = 'Chapter Contact';
            Insert objAffiliationContactChapter11;
            
            Membership__c objMembership11 = new Membership__c();
            objMembership11.Contact__c = objContactTeam11.Id;
            objMembership11.Membership_State__c = 'HI';
            Date dtCurrentDate11 = System.Today();
            objMembership11.RE_Drop_Date__c = dtCurrentDate11.addDays(365);
            objMembership11.Quit_Date__c = dtCurrentDate11.addDays(365);
            objMembership11.Start_Date__c = System.Today();
            Insert objMembership11;
	        
	        // ------ Contact 1-2 -------------
            Contact objContactTeam12 = new Contact();
            objContactTeam12.FirstName = 'Test';
            objContactTeam12.LastName = 'Contact Team12 Leader';
            objContactTeam12.Stand_Office__c = 'HI';
            objContactTeam12.Stand_Chapter_Affiliation__c = objAccountChapter1.Id;
            objContactTeam12.Stand_Team_Affiliation__c = objAccountTeam12.Id;
            
            Insert objContactTeam12;
            
            npe5__Affiliation__c objAffiliationContactTeam12 = new npe5__Affiliation__c();
            objAffiliationContactTeam12.npe5__Contact__c = objContactTeam12.Id;
            objAffiliationContactTeam12.npe5__Organization__c = objAccountTeam12.Id;
            objAffiliationContactTeam12.npe5__Status__c = 'Active';
            objAffiliationContactTeam12.Affiliation__c = 'Team Member';
            Insert objAffiliationContactTeam12;
            
            npe5__Affiliation__c objAffiliationContactChapter12 = new npe5__Affiliation__c();
            objAffiliationContactChapter12.npe5__Contact__c = objContactTeam12.Id;
            objAffiliationContactChapter12.npe5__Organization__c = objAccountChapter1.Id;
            objAffiliationContactChapter12.npe5__Status__c = 'Active';
            objAffiliationContactChapter12.Affiliation__c = 'Chapter Contact';
            Insert objAffiliationContactChapter12;
            
           	Membership__c objMembership12 = new Membership__c();
            objMembership12.Contact__c = objContactTeam12.Id;
            objMembership12.Membership_State__c = 'HI';
            Date dtCurrentDate12 = System.Today();
            objMembership12.RE_Drop_Date__c = dtCurrentDate12.addDays(365);
            objMembership12.Quit_Date__c = dtCurrentDate12.addDays(365);
            objMembership12.Start_Date__c = System.Today();
            Insert objMembership12;
            
            // build the relationship
            npe4__Relationship__c objRelationship12 = new npe4__Relationship__c ();
            objRelationship12.npe4__Contact__c = objContactTeam11.Id;
            objRelationship12.npe4__RelatedContact__c = objContactTeam12.id;
            objRelationship12.npe4__Status__c = 'Active';
            objRelationship12.ContactRelationship__c = 'Leader';
            Insert objRelationship12;
	        
	        // Start the test - #1 - Check to see that the relationship is there
	        Contact c1 = [ SELECT id, Stand_Leader__c FROM Contact WHERE id = : objContactTeam11.Id ];
	        
	        System.AssertEquals( c1.Stand_Leader__c, objContactTeam12.Id );
	        
	      	// Test #2 - update to inactive
	      	objRelationship12.End_Date__c = dtCurrentDate12.addDays(-365);
	        //update objRelationship12;
	        
	        //c1 = [ SELECT id, Stand_Leader__c FROM Contact WHERE id = : objContactTeam11.Id ];
	        
	        //System.AssertEquals( c1.Stand_Leader__c, null );
	        
	        // Test #3 - back to inactive
	      	//objRelationship12.End_Date__c = null;
	        //update objRelationship12;
	        
	        //c1 = [ SELECT id, Stand_Leader__c FROM Contact WHERE id = : objContactTeam11.Id ];
	        
	        //System.AssertEquals( c1.Stand_Leader__c, objContactTeam12.Id );
	        
	        //Test #4 - delete
	      	
	        delete objRelationship12;
	        
	        c1 = [ SELECT id, Stand_Leader__c FROM Contact WHERE id = : objContactTeam11.Id ];
	        
	        System.AssertEquals( c1.Stand_Leader__c, null );
	        
	        
	          
	    }
	    */
    }
}