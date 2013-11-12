@isTest
private class TeamCollection_Test {

    static testMethod void getByIdListTest() {
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
        
               
        // ------ Organizer 1 -------------
        Contact organizerRecord = new Contact();
        organizerRecord.FirstName = 'Test Organizer';
        organizerRecord.LastName = 'Test Organizer';
        organizerRecord.RecordTypeId = Schema.Sobjecttype.Contact.RecordTypeInfosByName.get('Organizer').RecordTypeId;
        organizerRecord.Stand_Office__c = 'OR';
        organizerRecord.Acquired_By__c = 'C3 Acquired';
        Insert organizerRecord;
        
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
        
        // ------ Team 2 -------------
        Account teamRecord2 = new Account();
        teamRecord2.Name = 'Test Team2';
        teamRecord2.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Team').RecordTypeId;
        teamRecord2.Organizer__c = organizerRecord.id;
        teamRecord2.Type = 'Stand Team';
        teamRecord2.Acquired_By__c = 'C3 Acquired';
        teamRecord2.ParentId = chapterRecord.Id;
        teamRecord2.State_Abbreviation__c = 'OR';
	    teamRecord2.BillingState = 'OR';
        Insert teamRecord2;
        
        //-----------------Test getByIdList-------------------------------------
        list < string > teamIDList = new list < string > ();
        teamIDList.add(teamRecord.id);
        teamIDList.add(teamRecord2.id);
        
        TeamCollection testTeamCollection = new TeamCollection();
        TeamCollection t = new TeamCollection();
        if (t.getByIdList(teamIDList)) {
        	testTeamCollection = t;
        }
                
        system.AssertEquals (2, testTeamCollection.teams.size());
    }
    
    static testMethod void updateTeamsMemberCountsTest () {
             //Create base objects
		DateTime dT = System.now();
		Date d = date.newinstance(dT.Year(),dT.month(),dT.day());
		
		// ------ STATE -------------
        Account stateOfficeOR = new Account();
        stateOfficeOR.Name = 'Test State';
        stateOfficeOR.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand State').RecordTypeId;
        stateOfficeOR.Type = 'Stand Affiliate State';
        stateOfficeOR.Acquired_By__c = 'C3 Acquired';
        stateOfficeOR.BillingState = 'OR';
        stateOfficeOR.State_Abbreviation__c = 'OR';
        Insert stateOfficeOR;
        
               
        // ------ Organizer 1 -------------
        Contact organizerRecord = new Contact();
        organizerRecord.FirstName = 'Test Organizer';
        organizerRecord.LastName = 'Test Organizer';
        organizerRecord.RecordTypeId = Schema.Sobjecttype.Contact.RecordTypeInfosByName.get('Organizer').RecordTypeId;
        organizerRecord.Stand_Office__c = 'OR';
        organizerRecord.Acquired_By__c = 'C3 Acquired';
        Insert organizerRecord;
        
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
        
		// ------ Member 1 -------------
        Contact memberRecord = new Contact();
        memberRecord.FirstName = 'TestMember';
        memberRecord.LastName = 'TestMember';
        memberRecord.Stand_Office__c = 'OR';
        memberRecord.Acquired_By__c = 'C3 Acquired';
        memberRecord.Membership_Start_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        memberRecord.Membership_Type__c = 'Annual';
        memberRecord.Stand_Team_Affiliation__c = teamRecord.id;
        Insert memberRecord;
        
        // ------ Member 2 -------------
        Contact memberRecord2 = new Contact();
        memberRecord2.FirstName = 'TestMember2';
        memberRecord2.LastName = 'TestMember2';
        memberRecord2.Stand_Office__c = 'OR';
        memberRecord2.Acquired_By__c = 'C3 Acquired';
        memberRecord2.Membership_Start_Date__c = d.addDays(-400);
        memberRecord2.Membership_Type__c = 'Annual';
        memberRecord2.Stand_Team_Affiliation__c = teamRecord.id;
        Insert memberRecord2;
        
        //-----------------Test updateTeamsMemberCounts-------------------------------------
        list < string > teamIdList = new list < string > ();
        teamIdList.add(teamRecord.id);
        
        TeamCollection testTeamCollection = new TeamCollection();
        if (TeamCollection.updateTeamsMemberCounts(teamIdList)) {
        	//hooray
        }
        
        Account testTeam = ([SELECT id, Active_Member_Count__c FROM Account where id =:teamRecord.id]);
        system.AssertEquals (1, testTeam.Active_Member_Count__c);

    }
}