@isTest
private class Organizer_Test {

    static testMethod void organizerTest() {
        //Create base objects
		DateTime dT = System.now();
		Profile objProfile = [Select Id from Profile where Name='Galaxy Basic Restricted'];
		string organizerRecordTypeID = Schema.Sobjecttype.Contact.RecordTypeInfosByName.get('Organizer').RecordTypeId;
		string defaultRecordTypeID = Schema.Sobjecttype.Contact.RecordTypeInfosByName.get('Non-VIP Contact').RecordTypeId;
		
		
		// ------ STATE -------------
        Account stateOfficeOR = new Account();
        stateOfficeOR.Name = 'Test State';
        stateOfficeOR.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand State').RecordTypeId;
        stateOfficeOR.Type = 'Stand Affiliate State';
        stateOfficeOR.Acquired_By__c = 'C3 Acquired';
        stateOfficeOR.BillingState = 'OR';
        stateOfficeOR.State_Abbreviation__c = 'OR';
        Insert stateOfficeOR;
        
        //------- Organizer1 User Record -----------
        
        User organizerUserRecord = new User();
        organizerUserRecord.FirstName = 'Test Organizer';
        organizerUserRecord.LastName = 'Test Organzier';
        organizerUserRecord.alias = 'Torg';
        organizerUserRecord.email = 'test@stand.org';
        organizerUserRecord.CommunityNickname = 'org';
        organizerUserRecord.EmailEncodingKey = 'UTF-8';
        organizerUserRecord.LocaleSidKey = 'en_US';
        organizerUserRecord.TimeZoneSidKey = 'America/Los_Angeles';
        organizerUserRecord.LanguageLocaleKey = 'en_US';
        organizerUserRecord.ProfileId = objProfile.Id;
        organizerUserRecord.UserName = 'test@stand.org.orgapp';
        organizerUserRecord.Division = 'OR';
        insert organizerUserRecord;
        
        
        //------- Organizer2 User Record -----------
        
        User organizerUserRecord2 = new User();
        organizerUserRecord2.FirstName = 'Test Organizer2';
        organizerUserRecord2.LastName = 'Test Organizer2';
        organizerUserRecord2.alias = 'Torg2';
        organizerUserRecord2.email = 'test@stand.org';
        organizerUserRecord2.CommunityNickname = 'org2';
        organizerUserRecord2.EmailEncodingKey = 'UTF-8';
        organizerUserRecord2.TimeZoneSidKey = 'America/Los_Angeles';
        organizerUserRecord2.LocaleSidKey = 'en_US';
        organizerUserRecord2.LanguageLocaleKey = 'en_US';
        organizerUserRecord2.ProfileId = objProfile.Id;
        organizerUserRecord2.UserName = 'test2@stand.org.orgapp';
        organizerUserRecord2.Division = 'OR';
        insert organizerUserRecord2;
        
               
        // ------ Organizer 1 -------------
        Contact organizerRecord = new Contact();
        organizerRecord.Linked_User__c = organizerUserRecord.id;
        organizerRecord.FirstName = 'Test Organizer';
        organizerRecord.LastName = 'Test Organizer';
        organizerRecord.RecordTypeId = Schema.Sobjecttype.Contact.RecordTypeInfosByName.get('Organizer').RecordTypeId;
        organizerRecord.Stand_Office__c = 'OR';
        organizerRecord.Acquired_By__c = 'C3 Acquired';
        Insert organizerRecord;
        
        // ------ Organizer 2 -------------
        Contact organizerRecord2 = new Contact();
        organizerRecord2.FirstName = 'Test Organizer2';
        organizerRecord2.LastName = 'Test Organizer2';
        organizerRecord2.Stand_Office__c = 'OR';
        organizerRecord2.Acquired_By__c = 'C3 Acquired';
        Insert organizerRecord2;
        
         // ------ Chapter 1 -------------
        Account chapterRecord = new Account();
        chapterRecord.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Chapter').RecordTypeId;
        chapterRecord.Name = 'Test Chapter1';
        chapterRecord.Type = 'Stand Chapter';
        chapterRecord.Organizer__c = organizerRecord.id;
        chapterRecord.Acquired_By__c = 'C3 Acquired';
        chapterRecord.ParentId = stateOfficeOR.Id;
        chapterRecord.BillingState = 'OR';
        chapterRecord.State_Abbreviation__c = 'OR';
        Insert chapterRecord;
        
        // ------ Chapter 2 -------------
        Account chapterRecord2 = new Account();
        chapterRecord2.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Chapter').RecordTypeId;
        chapterRecord2.Name = 'Test Chapter2';
        chapterRecord2.Type = 'Stand Chapter';
        chapterRecord2.Organizer__c = organizerRecord2.id;
        chapterRecord2.Acquired_By__c = 'C3 Acquired';
        chapterRecord2.ParentId = stateOfficeOR.Id;
        chapterRecord2.BillingState = 'OR';
        chapterRecord2.State_Abbreviation__c = 'OR';
        Insert chapterRecord2;
        
        // ------ Team 1 -------------
        Account teamRecord = new Account();
        teamRecord.Name = 'Test Team1';
        teamRecord.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Team').RecordTypeId;
        teamRecord.Organizer__c = organizerRecord.id;
        teamRecord.Type = 'Stand Team';
        teamRecord.Acquired_By__c = 'C3 Acquired';
        teamRecord.ParentId = chapterRecord.Id;
        teamRecord.State_Abbreviation__c = 'OR';
	    teamRecord.BillingState = 'OR';
        Insert teamRecord;
        
		//-----------------Test getById-------------------------------------
		
		Organizer testOrganizer = new Organizer();
		if (testOrganizer.getByUserId(organizerUserRecord.id)) {
		}
       
		system.AssertEquals (testOrganizer.first_name, 'Test Organizer');
        
        //-----------------Test create-------------------------------------
     	
     	Organizer createdOrganizer = new Organizer();
     	createdOrganizer.getByContactId(organizerRecord2.id);
    	createdOrganizer.create();
        
        Contact newOrgContact = ([SELECT id, RecordTypeId FROM Contact WHERE id=:organizerRecord2.id]);
        system.AssertEquals (organizerRecordTypeID, newOrgContact.RecordTypeId);
        
        //-----------------Test deactivate-------------------------------------
     	
     	//In the wild, users are required to reassign Chapters & teams from the organizer to be deactivated first.
     	chapterRecord2.Organizer__c = organizerRecord.id;
     	update chapterRecord2;
     	
        if ( createdOrganizer.deactivate()) {
        	//hooray
        }
        
        Contact deactivatedOrganizer = ([SELECT id, RecordTypeId FROM Contact WHERE id=:organizerRecord2.Id]);
        system.AssertEquals (defaultRecordTypeID, deactivatedOrganizer.RecordTypeId);
    }
}