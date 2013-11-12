@isTest
public class AffiliationUpdates_Test {

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
        objUser.UserName = 'AffUpdTestAffiliationUpdates@test.com';
        objUser.Division = 'National';
        insert objUser;

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
	        objAccountTeamA.State_Abbreviation__c = 'OR';
	        insert objAccountTeamA;
	        
	        Account objAccountTeamB = new Account();
	        objAccountTeamB.Name = 'HI Team';
	        objAccountTeamB.Type = 'Stand Team';
	        objAccountTeamB.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamB.ParentId = objAccountChapter.Id;
	        objAccountTeamB.State_Abbreviation__c = 'OR';
	        objAccountTeamB.BillingState = 'OR';
	        objAccountTeamB.State_Abbreviation__c = 'OR';
	        insert objAccountTeamB;
	        
	        
	        Contact objContactA = new Contact();
	        objContactA.FirstName = 'A Contact';
	        objContactA.LastName = 'SOQLTest';
	        objContactA.Stand_Office__c = 'OR';
	        insert objContactA;
	        
	        date mDate = date.newInstance(2011, 10, 30);
	        
	        Membership__c objMembershipA = new Membership__c();
            objMembershipA.Contact__c = objContactA.Id;
            objMembershipA.Membership_State__c = 'OR';          
            objMembershipA.Start_Date__c =  System.today().addDays(-750);
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
        
            objMembershipA.Start_Date__c = System.today().addDays(-750);
            objMembershipA.Membership_Action__c = 'Edit';
            update objMembershipA;
            
            Membership_Activity__c mA = [SELECT ID FROM Membership_Activity__c WHERE Membership__c = : objMembershipA.Id];
			mA.Start_Date__c = System.today().addDays(-750);
			update mA;
			
	        Contact c = [SELECT ID FROM Contact WHERE FirstName = 'A Contact'];
        
        	Membership__c m = [SELECT ID, Status2__c, Contact__c FROM membership__c WHERE Contact__c = : objContactA.Id];
	        System.AssertEquals( m.Status2__c, 'Dropped' );

			List <npe5__Affiliation__c> a = [SELECT ID, npe5__contact__c, npe5__Status__c, npe5__EndDate__c FROM npe5__Affiliation__c WHERE npe5__Status__c = 'Active' AND npe5__contact__c = : m.Contact__c];
			System.AssertEquals(a[0].npe5__Status__c, 'Active');
            
	    	AffiliationUpdates affU = new AffiliationUpdates();
    		affU.UpdateAffiliations();
    		
			List <npe5__Affiliation__c> a2 = [SELECT ID, npe5__contact__c, npe5__Status__c, npe5__EndDate__c FROM npe5__Affiliation__c WHERE npe5__Status__c = 'Inactive' AND npe5__contact__c = : m.Contact__c];
    		System.AssertEquals(a2[0].npe5__EndDate__c, System.today());
    		System.AssertEquals(a2[0].npe5__Status__c, 'Inactive');
    		
    		
    		// check to see if this covers all lines of code
    		// write a test class of large number of records to find limit
    		Test.startTest();
			string sch = '0 0 * * 1-12 ? *';
			system.schedule('Affiliation Updates Test',sch,affU);
			Test.stopTest();
        }
    }
}