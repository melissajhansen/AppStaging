@isTest
private class Team_Test {

    static testMethod void teamTest() {
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
        
        // ------ Organizer 2 -------------
        Contact organizerRecord2 = new Contact();
        organizerRecord2.FirstName = 'Test Organizer2';
        organizerRecord2.LastName = 'Test Organizer2';
        organizerRecord2.RecordTypeId = Schema.Sobjecttype.Contact.RecordTypeInfosByName.get('Organizer').RecordTypeId;
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
        
        Team testTeam = new Team();
        Team t = new Team();
        if (t.getById(teamRecord.id)) {
        	testTeam = t;
        }
        
        system.AssertEquals (teamRecord.id, testTeam.id);
        
        //-----------------Test create-------------------------------------
        
        testTeam.team_name = 'Test TeamCreate';
        testTeam.chapter_id = chapterRecord.id;
        testTeam.organizer_id = organizerRecord.id;
	    
	    if (testTeam.create()) {
	    	//hooray
	    }
	    
	    Account testCreate = ([SELECT id, Name FROM Account WHERE Name =:testTeam.team_name]);
	    system.AssertEquals ('Test TeamCreate', testCreate.Name);
	    
	    //-----------------Test changeChapter-------------------------------------
	    
	    testTeam.chapter_id = chapterRecord2.id;
	    
		if (testTeam.changeChapter()) {
			//hooray
		}
	    
	    Account testTeamChangedChapter = ([SELECT id, RecordTypeId, Organizer__c, ParentId FROM Account WHERE id=:testTeam.id]);
	    system.AssertEquals (ChapterRecord2.id, testTeamChangedChapter.ParentId);
	    system.AssertEquals (organizerRecord2.id, testTeamChangedChapter.Organizer__c);
	    
	    //-----------------Test deactivate-------------------------------------
	    
	  	if ( testTeam.deactivate()) {
	  		//hooray
	  	}
	  	
	  	Account testDeactivate = ([SELECT id, Type, Organizer__c FROM Account WHERE ID=:testTeam.id]);
	  	system.AssertEquals ('Former Stand Team', testDeactivate.type);
        
    }
}