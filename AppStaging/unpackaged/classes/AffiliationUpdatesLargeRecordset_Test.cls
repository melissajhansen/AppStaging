@isTest
public class AffiliationUpdatesLargeRecordset_Test {

    public static TestMethod void TestAffiliationUpdates() {
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
        objUser.UserName = 'AffUpdLarTestAffiliationUpdates@test.com';
        objUser.Division = 'National';
        Insert objUser;

        System.runAs(objUser)
        {
	        Account objAccount = new Account();
	        objAccount.Name = 'OR State Office';
	        objAccount.Type = 'Stand Affiliate State';
	        objAccount.Acquired_By__c = 'C3 Acquired';
	        objAccount.State_Abbreviation__c = 'OR';
	        objAccount.BillingState = 'OR';
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
	        
	        
	       	// create contacts
	        List < Contact > cList = new List < Contact > ();
	        List<Contact> cList1 = new List <Contact>();
	        integer x;
	        Contact cl;
	        for ( x = 0 ; x < 1500 ; x++ ) {
	        	cl = new Contact();
            	cl.FirstName = 'Test';
            	cl.LastName = 'Follower ' + x;
            	cl.Stand_Office__c = 'OR';
            	clist.add(cl);	
            	cList1.add(cl);
	        }
	        
	        insert clist1;

	        List < Contact > cList2 = new List < Contact > ();
	        for ( x = 0 ; x < 1000 ; x++ ) {
	        	cl = new Contact();
            	cl.FirstName = 'Test';
            	cl.LastName = 'Follower ' + x;
            	cl.Stand_Office__c = 'OR';
            	clist2.add(cl);	
            	clist.add(cl);
	        }
	        
	        insert clist2;

	        List < Contact > cList3 = new List < Contact > ();
/*	        for ( x = 0 ; x < 1000 ; x++ ) {
	        	cl = new Contact();
            	cl.FirstName = 'Test';
            	cl.LastName = 'Follower ' + x;
            	cl.Stand_Office__c = 'HI';
            	clist3.add(cl);	
            	clist.add(cl);
	        }
*/	        
//	        insert clist3;
	        
	        // create memberships
	        List <Membership__c> mList = new List <Membership__c>();
	        List <Membership__c> mList1 = new List <Membership__c>();
	        Membership__c mm;
	        for ( Contact cm : cList1 ) {
				mm = new Membership__c();
				mm.Contact__c = cm.Id;
            	mm.Membership_State__c = 'OR';
            	mm.Type__c = 'Sustaining';
           		mm.Membership_Source__c = 'Mail';
           		mm.Gift_Amount__c = Decimal.valueOf('50.00');
           		mm.Stand_Chapter__c = objAccountChapter.Id;
            	mm.Stand_Team__c = objAccountTeamB.Id;
           		mm.Start_Date__c = System.today().addDays(-750);
           		
           		mList.add(mm);
           		mList1.add(mm);
	        }	

			insert mList1;	

	        // create memberships
	        List <Membership__c> mList2 = new List <Membership__c>();
	        for ( Contact cm : cList2 ) {
				mm = new Membership__c();
				mm.Contact__c = cm.Id;
            	mm.Membership_State__c = 'OR';
            	mm.Type__c = 'Sustaining';
           		mm.Membership_Source__c = 'Mail';
           		mm.Gift_Amount__c = Decimal.valueOf('50.00');
           		mm.Stand_Chapter__c = objAccountChapter.Id;
            	mm.Stand_Team__c = objAccountTeamB.Id;
           		mm.Start_Date__c = System.today().addDays(-750);
           		
           		mList.add(mm);
           		mList2.add(mm);
	        }	

			insert mList2;	

	        // create memberships
	        List <Membership__c> mList3 = new List <Membership__c>();
	        for ( Contact cm : cList3 ) {
				mm = new Membership__c();
				mm.Contact__c = cm.Id;
            	mm.Membership_State__c = 'OR';
            	mm.Type__c = 'Sustaining';
           		mm.Membership_Source__c = 'Mail';
           		mm.Gift_Amount__c = Decimal.valueOf('50.00');
           		mm.Stand_Chapter__c = objAccountChapter.Id;
            	mm.Stand_Team__c = objAccountTeamB.Id;
           		mm.Start_Date__c = System.today().addDays(-750);
           		
           		mList.add(mm);
           		mList3.add(mm);
	        }	

			insert mList3;	
			
			// update Membership Activities
            List <Membership_Activity__c> mA = new List<Membership_Activity__c> ([SELECT ID FROM Membership_Activity__c WHERE Membership__c in : mList]);
			for (Membership_Activity__c m : mA) {
				m.Start_Date__c = System.today().addDays(-750);
				update m;
			}            
			
//	        Contact c = [SELECT ID FROM Contact WHERE FirstName = 'A Contact'];
        
//        	Membership__c m = [SELECT ID, Status2__c, Contact__c FROM membership__c WHERE Contact__c = : objContactA.Id];
//	        System.AssertEquals( m.Status2__c, 'Dropped' );

			List <npe5__Affiliation__c> a = [SELECT ID, npe5__contact__c, npe5__Status__c, npe5__EndDate__c FROM npe5__Affiliation__c WHERE npe5__Status__c = 'Active' AND npe5__contact__c in : cList];
//			System.AssertEquals(a[0].npe5__Status__c, 'Active');
            
	    	AffiliationUpdates affU = new AffiliationUpdates();
    		affU.UpdateAffiliations();
    		
			List <npe5__Affiliation__c> a2 = [SELECT ID, npe5__contact__c, npe5__Status__c, npe5__EndDate__c FROM npe5__Affiliation__c WHERE npe5__Status__c = 'Inactive' AND npe5__contact__c in : cList];
	   		System.AssertEquals(a.size(), a2.size());
//    		System.AssertEquals(a2[0].npe5__Status__c, 'Inactive');
    		
    		
    		// check to see if this covers all lines of code
    		// write a test class of large number of records to find limit
//    		Test.startTest();
//			string sch = '0 0 * * 1-12 ? *';
//			system.schedule('Affiliation Updates 1',sch,affU);
//			Test.stopTest();
        }
    }
}