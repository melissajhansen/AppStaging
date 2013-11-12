@isTest
public class NoteAttachment_Test {

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
        objUser.UserName = 'NotAttTestAttachment@test.com';
        objUser.Division = 'National';
        insert objUser;

        System.runAs(objUser)
        {
        	Contact objContact = new Contact();
            objContact.FirstName = 'TestNoteAtt';
            objContact.LastName = 'UserNoteAtt';
            objContact.Stand_Employee_User__c = objUser.Id;
            Insert objContact;
        	
        	Apexpages.StandardController stdController = new Apexpages.StandardController(objContact);
        	
        	NoteAttachment objNoteAtt = new NoteAttachment(stdController);
        	
        	objNoteAtt.getmyfile();
        	
        	objNoteAtt.CancelAttachment();
        	
        	objNoteAtt.SaveNoteAttachment();
        }
		
	}
}