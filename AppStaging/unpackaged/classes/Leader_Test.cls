@isTest
private class Leader_Test {
	
		static testMethod void getMethodsTest() {
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
        contactRecord.Membership_Start_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        contactRecord.LiT_Start_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        contactRecord.Stand_Team_Affiliation__c = teamRecord.id;
        contactRecord.Leader_Type__c = 'Leader in Training';
        
        Insert contactRecord;
        
        // ------ Person 1 -------------
        Person leaderPerson = new Person();
        Person p = new Person();
        if (p.getByID(contactRecord.id)){
        	leaderPerson = p;
        }
        
		Leader leader = new Leader();
		if (leader.getById(leaderPerson.id)) {
			//hooray
		}

	}
	
	static testMethod void changeTeamTest() {
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
        
        // ------ Team 2 -------------
        Account teamRecord2 = new Account();
        teamRecord2.Name = 'Test Team1';
        teamRecord2.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Team').RecordTypeId;
        teamRecord2.Type = 'Stand Team';
        teamRecord2.Acquired_By__c = 'C3 Acquired';
        teamRecord2.ParentId = chapterRecord.Id;
        teamRecord2.State_Abbreviation__c = 'OR';
	    teamRecord2.BillingState = 'OR';
        Insert teamRecord2;
        
        // ------ Contact 1 -------------
        Contact leaderContact = new Contact();
        leaderContact.FirstName = 'Test';
        leaderContact.LastName = 'Contact Chapter1';
        leaderContact.Stand_Office__c = 'OR';
        leaderContact.Acquired_By__c = 'C3 Acquired';
        leaderContact.Membership_Start_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        leaderContact.LiT_Start_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        leaderContact.Stand_Team_Affiliation__c = teamRecord.id;
        leaderContact.Leader_Type__c = 'Leader in Training';
        Insert leaderContact;
		
		//Load Up Leader
		Leader leader = new Leader();
		leader.getById(leaderContact.id);       
        
             
        leader.leader.Membership.team_id = teamRecord2.id;
        
		leader.changeTeam();
        
        Contact leaderNewTeamCheck = ([SELECT id, Stand_Team_Affiliation__c FROM Contact WHERE ID =:leaderContact.id]);
        system.AssertEquals(teamRecord2.id, leaderNewTeamCheck.Stand_Team_Affiliation__c );
        
		leader.endLeadership();
        
        Contact leaderEndedCheck = ([SELECT id, Leader_Type__c FROM Contact WHERE Id=:leaderContact.id]);
        system.AssertEquals ('Former Leader', leaderEndedCheck.Leader_Type__c);
		
	}
	
	static testMethod void updateLeaderCountsTest() {
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
       
        // ------ Member 1 -------------
        Contact memberRecord = new Contact();
        memberRecord.FirstName = 'Test';
        memberRecord.LastName = 'Contact Chapter1';
        memberRecord.Stand_Office__c = 'OR';
        memberRecord.Acquired_By__c = 'C3 Acquired';
        memberRecord.Stand_Leader__c = leaderRecord.id;
        memberRecord.Membership_Start_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        memberRecord.Membership_Type__c = 'Annual';
        memberRecord.Stand_Team_Affiliation__c = teamRecord.id;
        Insert memberRecord;
        
        // ------ Member 2 -------------
        Contact memberRecord2 = new Contact();
        memberRecord2.FirstName = 'Test';
        memberRecord2.LastName = 'Contact Chapter1';
        memberRecord2.Stand_Office__c = 'OR';
        memberRecord2.Acquired_By__c = 'C3 Acquired';
        memberRecord2.Stand_Leader__c = leaderRecord.id;
        memberRecord2.Membership_Start_Date__c = d.addDays(-400);
        memberRecord2.Membership_Type__c = 'Annual';
        memberRecord2.Stand_Team_Affiliation__c = teamRecord.id;
        Insert memberRecord2;
		
		Contact lapsed = ([SELECT id, Membership_Status__c, Membership_Start_Date__C, Membership_Expiration__C FROM Contact WHERE Id=:memberREcord2.id]);
		system.debug('status'+lapsed.Membership_Status__c);
		system.debug('startdate'+lapsed.Membership_Start_Date__C);
		system.debug('Expiration'+lapsed.Membership_Expiration__C);
		
		Contact Active = ([SELECT id, Membership_Status__c, Membership_Start_Date__C, Membership_Expiration__C, Stand_Leader__c FROM Contact WHERE Id=:memberRecord.id]);
		system.debug('status'+Active.Membership_Status__c);
		system.debug('startdate'+Active.Membership_Start_Date__C);
		system.debug('Expiration'+Active.Membership_Expiration__C);
		system.debug('Leader'+Active.Stand_Leader__c);
		
		if (Leader.updateLeaderMemberCounts(leaderRecord.id)) {
			//super
		}
		
		Contact updatedLeaderContact = ([SELECT id, Active_Member_Count__c FROM Contact WHERE id=:leaderRecord.id]);
		system.AssertEquals(1, updatedLeaderContact.Active_Member_Count__c);	
		
	}
	
		static testMethod void endLeaderTest() {
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
        
		// ------ Leader 1 -------------
        Contact testLeader = new Contact();
        testLeader.FirstName = 'Test';
        testLeader.LastName = 'Leader';
        testLeader.Stand_Office__c = 'OR';
        testLeader.Acquired_By__c = 'C3 Acquired';
        testLeader.membership_start_date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        testLeader.Stand_Team_Affiliation__c = teamRecord.Id;
        testLeader.Membership_Type__c = 'Annual';
        testLeader.LiT_Start_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        testLeader.Leader_Type__c = 'Leader in Training';
        Insert testLeader;
        
        
 		// ------ Member 1 -------------
        Contact testMember = new Contact();
        testMember.FirstName = 'Test';
        testMember.LastName = 'Member';
        testMember.Stand_Office__c = 'OR';
        testMember.Acquired_By__c = 'C3 Acquired';
        testMember.membership_start_date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        testMember.Stand_Team_Affiliation__c = teamRecord.Id;
        testMember.Membership_Type__c = 'Annual';
        testMember.Stand_Leader__c = testLeader.id;
        Insert testMember;
        
      	Leader leader = new Leader();
		if (leader.getById(testLeader.id)) {
			//hooray
		}

        if (leader.endLeadership()) {
        	//hooray
        }
        
        Contact leaderEnd = ([SELECT id, Leader_Type__c FROM Contact WHERE id =:testLeader.id]);
        system.AssertEquals( 'Former Leader', leaderEnd.Leader_Type__c );

	}

}