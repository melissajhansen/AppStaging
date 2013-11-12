@isTest
public class OppNoteAttachment_Test {
/*
	public static TestMethod void TestAttachment()
	{
		Profile objProfile = [Select Id from Profile where Name='Standard User'];
        User objUser = new User();
        objUser.Alias = 'TstAttU';
        objUser.CommunityNickname = 'TstAttU';
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
            objContact.FirstName = 'TestNoteAtt';
            objContact.LastName = 'UserNoteAtt';
            objContact.Stand_Employee_User__c = objUser.Id;
            Insert objContact;
        	
   			// ------ Campaign ------------
			Campaign objCampaign = new Campaign ();
			objCampaign.Name = 'Test Campaign1';
			objCampaign.IsActive = True;
			objCampaign.Type = 'Fundraising';
			objCampaign.Entity__c = 'Stand for Children, Inc. (C4)';
			Insert objCampaign;
		
   			// Create an Opportunity
			Opportunity testOpp1 = new Opportunity ();
			testOpp1.Name = 'NoteTestOpportunity1';
			testOpp1.AccountId = objContact.AccountId;
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
			insert testOpp1;
        	
        	Apexpages.StandardController stdController = new Apexpages.StandardController(testOpp1);
        	
        	OppNoteAttachment objOppNoteAtt = new OppNoteAttachment(stdController);
        	
        	objOppNoteAtt.getmyfile();

        	objOppNoteAtt.CancelAttachment();
        	
        	objOppNoteAtt.SaveNoteAttachment();
        }
		
	}
*/
}