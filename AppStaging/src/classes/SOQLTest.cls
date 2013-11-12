@isTest
public with sharing class SOQLTest {

	// basic test to create contact	
	public static TestMethod void TestContact()
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
        objUser.UserName = 'SOQTesTestContact@test.com';
        objUser.Division = 'National';
        insert objUser;

        System.runAs(objUser)
        {
        	
        	Date dtCurrentDate1 = System.Today();
	    	
	        Account objAccount = new Account();
	        objAccount.Name = 'OR State Office';
	        objAccount.Type = 'Stand Affiliate State';
	        objAccount.Acquired_By__c = 'C3 Acquired';
	        objAccount.BillingState = 'OR';
	        objAccount.State_Abbreviation__c = 'OR';
	        Insert objAccount;
	        
			Account objAccountChapter = new Account();
			objAccountChapter.Name = 'OR Chapter';
			objAccountChapter.Type = 'Stand Chapter';
			objAccountChapter.Acquired_By__c = 'C3 Acquired';
			objAccountChapter.ParentId = objAccount.Id;
			objAccountChapter.BillingState = 'OR';
			objAccountChapter.State_Abbreviation__c = 'OR';
			Insert objAccountChapter;			
	     	        
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
	        
	        
	        Contact objContactA = new Contact();
	        objContactA.FirstName = 'A Contact';
	        objContactA.LastName = 'SOQLTest';
	        objContactA.Stand_Office__c = 'OR';
	        insert objContactA;
	        
	        
	        Membership__c objMembershipA = new Membership__c();
            objMembershipA.Contact__c = objContactA.Id;
            objMembershipA.Membership_State__c = 'OR';          
            objMembershipA.Start_Date__c =  System.Today();
            objMembershipA.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipA.Type__c = 'Annual';    
            objMembershipA.Stand_Team__c = objAccountTeamA.Id;  
            objMembershipA.Membership_Source__c = 'Web';
            objMembershipA.Membership_Action__c = 'Join';      
            insert objMembershipA;  	
            
            npe5__Affiliation__c objAffiliationContactTeamA = new npe5__Affiliation__c();
            objAffiliationContactTeamA.npe5__Contact__c = objContactA.Id;
            objAffiliationContactTeamA.npe5__Organization__c = objAccountTeamA.Id;
            objAffiliationContactTeamA.npe5__Status__c = 'Active';
            objAffiliationContactTeamA.Affiliation__c = 'Team Member';  
            objAffiliationContactTeamA.npe5__StartDate__c = System.today();
            insert objAffiliationContactTeamA;	 
            
            objAffiliationContactTeamA.Affiliation__c = 'Team Member';
            update objAffiliationContactTeamA;
            
            // uncommented from here down
            /*
            List<Contact> tmpCts = new List<Contact>([select Id, Name, Membership_State__c, Stand_Team_Affiliation__c from Contact where ID = : objContactA.Id]);
	        
	        //Check that Membership State == OR
	        System.AssertEquals('OR', tmpCts[0].Membership_State__c);
	        //Check that Stand Team Affiliation == NE Community Team
	        System.AssertEquals(objAccountTeamA.Id, tmpCts[0].Stand_Team_Affiliation__c);
	        
	        //	Test 2
		    //  As an organizer, I can edit Frank Thornhill's  membership to a different state and the 
		    //  membership state is updated on the contact record.         
	        
	        objMembershipA.Membership_State__c = 'HI';
	        objMembershipA.Stand_Team__c = objAccountTeamB.Id;
	        update objMembershipA;
	        
	        tmpCts = new List<Contact>([select Id, Name, Membership_State__c from Contact where ID = : objContactA.Id]);	        
	        
	        //Check that State == HI
	        System.AssertEquals('HI', tmpCts[0].Membership_State__c);
	        
	        //	Test 3
	        //  As an organizer, I cannot edit Frank Thornhill's  membership to not have a state at all.
	        
	        objMembershipA.Membership_State__c = null;
	        
	        try {
	        	update objMembershipA;
	        } catch(DmlException de) {
	        	List<Membership__c> tmpMem = new List<Membership__c>([select Id, Membership_State__c from Membership__c where ID = : objMembershipA.Id]);	        
				//Updating the membership with a null state would throw and exception, so the old state of HI would still be in the database	        	
	        	System.AssertEquals('HI', tmpCts[0].Membership_State__c);
	        }
	        
	        //	Test 4
	        //	As an organizer, if Frances King reaches 10 member followers and has an active or lapsed membership, 
	        //	Leader type gets updated to Leader, LIT Stop date is updated, and Leader start date 
	        */
        }
    	
    }

}