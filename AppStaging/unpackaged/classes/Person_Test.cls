@isTest  ( SeeAllData = true) 
private class Person_Test {
	
	static testMethod void getByIdTest(){
		//Create base objects
		DateTime dT = System.now();
		
		// ------ STATE -------------
        Account stateOfficeOR = new Account();
        stateOfficeOR.Name = 'Test State';
        stateOfficeOR.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand State').RecordTypeId;
        stateOfficeOR.Type = 'Stand Affiliate State';
        stateOfficeOR.Acquired_By__c = 'C3 Acquired';
        stateOfficeOR.BillingState = 'OR';
        stateOfficeOR.State_Abbreviation__c = 'OR';
        Insert stateOfficeOR;
        
        // ------ Chapter 1 -------------
        Account chapterRecord = new Account();
        chapterRecord.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Chapter').RecordTypeId;
        chapterRecord.Name = 'Test Chapter1';
        chapterRecord.Type = 'Stand Chapter';
        chapterRecord.Acquired_By__c = 'C3 Acquired';
        chapterRecord.ParentId = stateOfficeOR.Id;
        chapterRecord.BillingState = 'OR';
        chapterRecord.State_Abbreviation__c = 'OR';
        Insert chapterRecord;
        
        // ------ Team 1 -------------
        Account teamRecord = new Account();
        teamRecord.Name = 'Test Team1';
        teamRecord.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Team').RecordTypeId;
        teamRecord.Type = 'Stand Team';
        teamRecord.Acquired_By__c = 'C3 Acquired';
        teamRecord.ParentId = chapterRecord.Id;
        teamRecord.State_Abbreviation__c = 'OR';
	    teamRecord.BillingState = 'OR';
        Insert teamRecord;
        
        // ------ Contact 1 -------------
        Contact contactRecord = new Contact();
        contactRecord.FirstName = 'Test';
        contactRecord.LastName = 'Contact Chapter1';
        contactRecord.Stand_Office__c = 'OR';
        contactRecord.Acquired_By__c = 'C3 Acquired';
        Insert contactRecord;
        
        // ------ Person 1 -------------
        Person p = new Person();
        if (p.getByID(contactRecord.id)){
        	//yay
        }
	}
	
	static testMethod void createEditPersonTest(){
		
        // ------ Person 1 -------------
        Person p = new Person();
        
        p.first_name = 'TestCreatePerson';
		p.last_name = 'TestCreatePerson';
		p.mailing_address_street = '3037 SE Belmont';
		p.mailing_address_city = 'Portland';
		p.mailing_address_state = 'OR';
		p.mailing_address_zip= '97214';
		list < string > sList = new list < string > {'interestA', 'interestB'};
		
		p.activist_interests_list = sList;
		
		p.create();
		
        Contact checkCreatePerson = ([SELECT id, FirstName FROM Contact WHERE id=:p.id]);
        system.AssertEquals ('TestCreatePerson', checkCreatePerson.FirstName);
        
        p.first_name = 'UpdatedTestPerson';
        p.last_name = 'UpdatedTestPerson';
		p.mailing_address_street = '';
		p.mailing_address_city = '';
		p.mailing_address_state = '';
		p.mailing_address_zip = '';
		p.personal_email = '';
		p.preferred_email_type = '';
		p.work_email = '';
		p.alternate_email = '';
		p.preferred_phone_type = '';
		p.home_phone = '';
		p.work_phone = '';
		p.mobile_phone = '';
		p.preferred_language = '';
		p.other_activist_interests = '';
		p.other_involvement_preferences = '';
		p.educator_status = '';
		p.educator_type = '';
		p.organizer_notes = '';
		p.is_sms_opted_in = true;
		p.is_parent = false;
		p.activist_interests_list = null;
		p.involvement_preferences_list = null;
        p.is_community_member = true;
        
        p.edit();
        
        Contact checkEditPerson = ([SELECT id, FirstName FROM Contact WHERE id=: p.id]);
        system.AssertEquals ('UpdatedTestPerson', checkEditPerson.FirstName);
        
	}


	
	static testMethod void CreateRenewQuitTest() {
		//Create base objects
		DateTime dT = System.now();
		Date d = date.newinstance(dT.Year(),dT.month(),dT.day());
		double donationA = 50.00;
		
		// ------ STATE -------------
        Account stateOfficeOR = new Account();
        stateOfficeOR.Name = 'Test State';
        stateOfficeOR.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand State').RecordTypeId;
        stateOfficeOR.Type = 'Stand Affiliate State';
        stateOfficeOR.Acquired_By__c = 'C3 Acquired';
        stateOfficeOR.BillingState = 'OR';
        stateOfficeOR.State_Abbreviation__c = 'OR';
        Insert stateOfficeOR;
        
        // ------ Chapter 1 -------------
        Account chapterRecord = new Account();
        chapterRecord.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Chapter').RecordTypeId;
        chapterRecord.Name = 'Test Chapter1';
        chapterRecord.Type = 'Stand Chapter';
        chapterRecord.Acquired_By__c = 'C3 Acquired';
        chapterRecord.ParentId = stateOfficeOR.Id;
        chapterRecord.BillingState = 'OR';
        chapterRecord.State_Abbreviation__c = 'OR';
        Insert chapterRecord;
        
        // ------ Team 1 -------------
        Account teamRecord = new Account();
        teamRecord.Name = 'Test Team1';
        teamRecord.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Team').RecordTypeId;
        teamRecord.Type = 'Stand Team';
        teamRecord.Acquired_By__c = 'C3 Acquired';
        teamRecord.ParentId = chapterRecord.Id;
        teamRecord.State_Abbreviation__c = 'OR';
	    teamRecord.BillingState = 'OR';
        Insert teamRecord;
        
		// ------ Leader 1 -------------
        Contact leaderRecord = new Contact();
        leaderRecord.FirstName = 'Test';
        leaderRecord.LastName = 'Contact Chapter1';
        leaderRecord.Stand_Office__c = 'OR';
        leaderRecord.Acquired_By__c = 'C3 Acquired';
        Insert leaderRecord;       
       
      // ------ Person 1 -------------
        Person p = new Person();
       
        
        p.first_name = 'TestCreatePerson';
		p.last_name = 'TestCreatePerson';
		p.mailing_address_street = '3037 SE Belmont';
		p.mailing_address_city = 'Portland';
		p.mailing_address_state = 'OR';
		p.mailing_address_zip= '97214';
		list < string > sList = new list < string > {'interestA', 'interestB'};
		
		p.activist_interests_list = sList;
		
		//Person p2 = new Person();
		p.create();
		p.membership = new Person.Membership();
		
        Contact checkCreatePerson = ([SELECT id, FirstName FROM Contact WHERE id=:p.id]);
        system.AssertEquals ('TestCreatePerson', checkCreatePerson.FirstName);
        
        p.membership.membership_start_date = d;
        p.membership.membership_state = 'OR';
        p.membership.team_id = teamRecord.id;
        p.membership.membership_type= 'Annual';
        
       	
		//---------------CC Transaction
		CCInterface cc = new CCInterface ();

		cc.cardHolderFirstName = 'Tester';
		cc.cardHolderLastName = 'Smith123';
		cc.cardHolderNameOnCard = 'Tester Judy';
		cc.cardNumber = '4111111111111111';
		cc.cv2 = '111';
		cc.expirationDate = '09/17';
		cc.ipAddress = '50.1.1.1';
		cc.donationAmount = donationA;
		cc.campaignName = '';
		cc.recurringPayment = false;       
        
        Person p3 = new Person();
        p3.Membership = new Person.Membership();
        if (p3.Membership.create(p, cc)) {
        	//success
        }
        
        Contact newMemContact = ([SELECT id, Membership_Status__c FROM Contact Where id=:p.id]);
        system.AssertEquals ('Active', newMemContact.Membership_Status__c);
        
        newMemContact.Membership_Start_Date__c = d.addDays(-400);
        update newMemContact;
        
        Person renewMember = new Person();
        
        Person per = new Person();
        if (per.getbyId(newMemContact.id)){
        	renewMember = per;
        }
        
        renewMember.Membership.last_membership_renewal_date = d;
        
        person p4 = new Person();
        p4.Membership = new Person.Membership();
        if (p4.Membership.renew(renewMember, cc)) {
        	//success
        }
        
		
	}
	
}