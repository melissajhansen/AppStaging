@isTest
public class ContactTriggerTest {
	
	// Test Class for Contact_Trigger
	// -------------------------------
	// 8/20/12 - SKT created
	
	public static TestMethod void ContactTriggerProspectTest() {
    	// create the contact to find
    	Contact c = new Contact ();
    	c.FirstName = 'Tester';
    	c.LastName = 'Contact1';
    	c.email = 'test@stand.org';
    	c.Prospect_Priority__c = '';
    	c.Prospect_Status__c = '';
    	
    	insert c;
    	
    	// fetch c back
	    List < Contact > clist = new List < Contact > ( [ SELECT ID, AccountId, npe01__Organization_Type__c FROM Contact WHERE Id = : c.id ] );
    	
    	// update the prospecting data
    	c.Prospect_Priority__c = 'High';
    	c.Prospect_Status__c = 'Inactive';
    	c.Prospect_Classification__c = 'AZ Prospect';
    	
    	update c;
    	
    	// check the contact for correct org type
    	
    	System.debug ( 'ACCOUNT 1 ===========================>  ' +  clist[0].npe01__Organization_Type__c );
    	System.debug ( 'ACCOUNT 1 ===========================>  ' +  clist[0].AccountId );
    	
    	// check associated account
    	List < Account > a = new List < Account > ( [ SELECT ID, Prospect_Priority__c, Prospect_Status__c FROM Account WHERE Id = : clist[0].AccountId ] );
    	
    	System.AssertEquals ( 'High', a[0].Prospect_Priority__c );
    	System.AssertEquals ( 'Inactive', a[0].Prospect_Status__c );
 
    }
    
    public static TestMethod void ContactTriggerProspectInsertTest() {
    	// create the contact to find
    	Contact c = new Contact ();
    	c.FirstName = 'Tester';
    	c.LastName = 'ContactInsert';
    	c.email = 'test-insert@stand.org';
    	c.Prospect_Priority__c = 'High';
    	c.Prospect_Status__c = '';
    	
    	insert c;
    	
    	// fetch c back
	    List < Contact > clist = new List < Contact > ( [ SELECT ID, AccountId, Prospect_Priority__c, Prospect_Status__c, npe01__Organization_Type__c FROM Contact WHERE Id = : c.id ] );
    
    	// check associated account
    	List < Account > a = new List < Account > ( [ SELECT ID, Prospect_Priority__c, Prospect_Status__c FROM Account WHERE Id = : clist[0].AccountId ] );
    	
    	System.AssertEquals ( a[0].Prospect_Priority__c, clist[0].Prospect_Priority__c );
    }
    
    public static TestMethod void ContactTriggerOwnerTest() {
    	
    	Profile objProfile = [Select Id from Profile where Name='Galaxy Basic Restricted'];
        User objUser = new User();
        objUser.Alias = 'TstClsU';
        objUser.CommunityNickname = 'TstClsU';
        objUser.Email = 'testuser@stand.org';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.FirstName = 'TestClass';
        objUser.LocaleSidKey = 'en_US';
        objUser.LastName = 'User';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.ProfileId = objProfile.Id;
        objUser.TimeZoneSidKey = 'America/Los_Angeles';
        objUser.UserName = 'CTtestuser@stand.org';
        objUser.Division = 'National';
        
        User objUser2 = new User();
        objUser2.Alias = 'TstClsU3';
        objUser2.CommunityNickname = 'TstClsU33';
        objUser2.Email = 'testuser33@stand.org';
        objUser2.EmailEncodingKey = 'UTF-8';
        objUser2.FirstName = 'TestClass33';
        objUser2.LocaleSidKey = 'en_US';
        objUser2.LastName = 'User33';
        objUser2.LanguageLocaleKey = 'en_US';
        objUser2.ProfileId = objProfile.Id;
        objUser2.TimeZoneSidKey = 'America/Los_Angeles';
        objUser2.UserName = 'CTtestuser33@stand.org';
        objUser2.Division = 'National';
        
        Insert objUser2;
		
		ID accountID; 
		ID cID;
		
        System.runAs(objUser)
        {
    	
	    	// create the contact 
	    	Contact c = new Contact ();
	    	c.FirstName = 'Tester';
	    	c.LastName = 'Contact1';
	    	c.email = 'test@stand.org';
	    	c.acquired_by__c = 'C3';
	    	c.leadSource = 'Web';
	    	c.stand_office__c = 'AZ';
	    	c.Prospect_Priority__c = '';
	    	c.Prospect_Status__c = '';
	    	insert c;
	    	
	    	cID = c.id;
	    	
	    	List < Contact > clist = new List < Contact > ( [ SELECT ID, OwnerId, AccountId, npe01__Organization_Type__c FROM Contact WHERE Id = : cID ] );
	    	
	    	Contact cobj = clist[0];
	    	accountId = cobj.accountId;
	    	
	    	// update the owner
	    	cobj.OwnerId = objUser2.Id;
	    	
	    	update cobj;
	    	
	    	
        }
        
        System.runAs( objUser2 ) {
			// fetch c back
	    	List < Contact > clist = new List < Contact > ( [ SELECT ID, AccountId, npe01__Organization_Type__c FROM Contact WHERE Id = : cid ] );
	    	
	    	// check associated account
	    	List < Account > a = new List < Account > ( [ SELECT ID, OwnerId FROM Account WHERE Id = : clist[0].accountId ] );
	    	
	    	System.AssertEquals ( objUser2.Id, a[0].OwnerId );
        }
 
    }
}