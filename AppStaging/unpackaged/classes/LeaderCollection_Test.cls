@isTest
private class LeaderCollection_Test {

    static testMethod void getTests() {
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
        
         // ------ Member 2 -------------
        Contact testMember2 = new Contact();
        testMember2.FirstName = 'Test';
        testMember2.LastName = 'Member2';
        testMember2.Stand_Office__c = 'OR';
        testMember2.Acquired_By__c = 'C3 Acquired';
        testMember2.membership_start_date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        testMember2.Stand_Team_Affiliation__c = teamRecord.Id;
        testMember2.Membership_Type__c = 'Annual';
        testMember2.Stand_Leader__c = testLeader.id;
        Insert testMember2;
		
		
		// ------ Leader 2 -------------
        Contact alternateLeader = new Contact();
        alternateLeader.FirstName = 'Alternate';
        alternateLeader.LastName = 'Leader';
        alternateLeader.Stand_Office__c = 'OR';
        alternateLeader.Acquired_By__c = 'C3 Acquired';
        alternateLeader.membership_start_date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        alternateLeader.Stand_Team_Affiliation__c = teamRecord.Id;
        alternateLeader.Membership_Type__c = 'Annual';
        alternateLeader.LiT_Start_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        alternateLeader.Leader_Type__c = 'Leader in Training';
        Insert alternateLeader;
        
        // ------ Member 3 -------------
        Contact testMember3 = new Contact();
        testMember3.FirstName = 'Test';
        testMember3.LastName = 'Member3';
        testMember3.Stand_Office__c = 'OR';
        testMember3.Acquired_By__c = 'C3 Acquired';
        testMember3.membership_start_date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        testMember3.Stand_Team_Affiliation__c = teamRecord.Id;
        testMember3.Membership_Type__c = 'Annual';
        testMember3.Stand_Leader__c = alternateLeader.id;
        Insert testMember3;
        
        
        //--------------------getLeadersByTeamIdTest-------------------------------
        LeaderCollection testCollection = new LeaderCollection();
        
        LeaderCollection ldrC = new LeaderCollection();
        if (ldrC.getLeadersByTeamId(teamRecord.id)) {
        	testCollection = ldrC;
        }
        
        system.assertEquals(2, testCollection.Leaders.size());
        
        //--------------------getLeadersByTeamIdListTest-------------------------------
        list < string > teamIds = new list < string >();
        teamIds.add(teamRecord.id);
        
		LeaderCollection testCollection2 = new LeaderCollection();       
        LeaderCollection ldrC2 = new LeaderCollection();
        if (ldrC2.getLeadersByTeamIdList(teamIds)) {
        	testCollection2 = ldrC2;
        }
        
        system.assertEquals (2, testCollection2.Leaders.size());
        
	}
	
	static testMethod void updateLeaderMemberCountsTest() {
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
        
         // ------ Member 2 -------------
        Contact testMember2 = new Contact();
        testMember2.FirstName = 'Test';
        testMember2.LastName = 'Member2';
        testMember2.Stand_Office__c = 'OR';
        testMember2.Acquired_By__c = 'C3 Acquired';
        testMember2.membership_start_date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        testMember2.Stand_Team_Affiliation__c = teamRecord.Id;
        testMember2.Membership_Type__c = 'Annual';
        testMember2.Stand_Leader__c = testLeader.id;
        Insert testMember2;
		
		
		// ------ Leader 2 -------------
        Contact alternateLeader = new Contact();
        alternateLeader.FirstName = 'Alternate';
        alternateLeader.LastName = 'Leader';
        alternateLeader.Stand_Office__c = 'OR';
        alternateLeader.Acquired_By__c = 'C3 Acquired';
        alternateLeader.membership_start_date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        alternateLeader.Stand_Team_Affiliation__c = teamRecord.Id;
        alternateLeader.Membership_Type__c = 'Annual';
        alternateLeader.LiT_Start_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        alternateLeader.Leader_Type__c = 'Leader in Training';
        Insert alternateLeader;
        
        // ------ Member 3 -------------
        Contact testMember3 = new Contact();
        testMember3.FirstName = 'Test';
        testMember3.LastName = 'Member3';
        testMember3.Stand_Office__c = 'OR';
        testMember3.Acquired_By__c = 'C3 Acquired';
        testMember3.membership_start_date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        testMember3.Stand_Team_Affiliation__c = teamRecord.Id;
        testMember3.Membership_Type__c = 'Annual';
        testMember3.Stand_Leader__c = alternateLeader.id;
        Insert testMember3;
        
        
        //--------------------updateLeaderMemberCountsTest-------------------------------
		list < string > leaderIds = new list < string >();
        leaderIds.add(testLeader.id);
        leaderIds.add(alternateLeader.id);
        
        if (LeaderCollection.updateLeaderMemberCounts(leaderIds)) {
        	//hooray
        }
        
        Contact checkLeaderMemCounts = ([SELECT id, Active_Member_Count__c FROM Contact WHERE id =:testLeader.id]);
        
        system.AssertEquals (2, checkLeaderMemCounts.Active_Member_Count__c);
        
	}

}