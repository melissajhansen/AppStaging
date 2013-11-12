@isTest
private class PersonCollection_Test {

		static testMethod void createEditChangePeopleTest() {
		
		Person p1 = new Person();
		p1.first_name = 'BulkPersonInsertA';
		p1.last_name = 'BulkPersonInsertA';
		p1.mailing_address_state = 'OR';
		p1.is_parent = true;
		p1.mailing_address_zip = '97214';
		
		Person p2 = new Person();
		p2.first_name = 'BulkPersonInsertB';
		p2.last_name = 'BulkPersonInsertB';
		p2.mailing_address_state = 'OR';
		p2.is_parent = true;
		p2.mailing_address_zip = '97214';
		
		//Initialize a new PersonCollection and add our people
		PersonCollection pc = new PersonCollection();
		pc.people = new list < Person >();
		
		pc.people.add(p1);
		pc.people.add(p2);
		
		//call up a new instance of PersonCollection and invoke create
		pc.create();
		
		//Asserts to check the create
		contact checkInsertA = ([SELECT ID, FirstName FROM Contact WHERE FirstName =:p1.first_name]);
		system.AssertEquals ('BulkPersonInsertA', checkInsertA.FirstName);
		
		contact checkInsertB = ([SELECT ID, FirstName FROM Contact WHERE FirstName =:p2.first_name]);
		system.AssertEquals ('BulkPersonInsertB', checkInsertB.FirstName);
		
		/*//Create a list to hold the person IDs for out newly inserted people
		list < string > personIds = new list < string >();
		personIds.add(checkInsertA.id);
		personIds.add(checkInsertB.id);
		
		//create a list for our inserted Persons, and get by IdList so we can make updates
		PersonCollection insertedPersons = new PersonCollection();
		
		PersonCollection pc3 = new PersonCollection();
		
		if (pc3.getByIdList(personIds)) {
			insertedPersons = pc3;
		}*/
		
		//Update some field values
		
		pc.people[0].first_name = 'BulkPersonUpdateA';
		pc.people[1].first_name = 'BulkPersonUpdateB';
		
		//Call the edit method and check results
		pc.edit();
		
		system.debug ('***********************pc.people[0]FirstName'+pc.people[0].first_name);
		system.debug ('***********************pc.people[1]FirstName'+pc.people[1].first_name);
		
		contact checkUpdate = ([SELECT ID, FirstName FROM Contact WHERE FirstName =:'BulkPersonUpdateA']);
		system.AssertEquals ('BulkPersonUpdateA', checkUpdate.FirstName);
				
	}
	
	static testMethod void changeLeaderTeamTest() {
		DateTime dT = System.now();
		
		// ------ STATE -------------
        Account objState = new Account();
        objState.Name = 'Test State';
        objState.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand State').RecordTypeId;
        objState.Type = 'Stand Affiliate State';
        objState.Acquired_By__c = 'C3 Acquired';
        objState.BillingState = 'OR';
        objState.State_Abbreviation__c = 'OR';
        Insert objState;
        
        // ------ Chapter 1 -------------
        Account objChapter = new Account();
        objChapter.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Chapter').RecordTypeId;
        objChapter.Name = 'Test Chapter1';
        objChapter.Type = 'Stand Chapter';
        objChapter.Acquired_By__c = 'C3 Acquired';
        objChapter.ParentId = objState.Id;
        objChapter.BillingState = 'OR';
        objChapter.State_Abbreviation__c = 'OR';
        Insert objChapter;
        
        // ------ Team 1 -------------
        Account objTeam1 = new Account();
        objTeam1.Name = 'Test Team1';
        objTeam1.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Team').RecordTypeId;
        objTeam1.Type = 'Stand Team';
        objTeam1.Acquired_By__c = 'C3 Acquired';
        objTeam1.ParentId = objChapter.Id;
        objTeam1.State_Abbreviation__c = 'OR';
	    objTeam1.BillingState = 'OR';
        Insert objTeam1;
        
        // ------ Team 2 -------------
        Account objTeam2 = new Account();
        objTeam2.Name = 'Test Team2';
        objTeam2.RecordTypeId = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Team').RecordTypeId;
        objTeam2.Type = 'Stand Team';
        objTeam2.Acquired_By__c = 'C3 Acquired';
        objTeam2.ParentId = objChapter.Id;
        objTeam2.State_Abbreviation__c = 'OR';
	    objTeam2.BillingState = 'OR';
        Insert objTeam2;
        
        // ------ Contact 1 -------------
        Contact testMember = new Contact();
        testMember.FirstName = 'Test';
        testMember.LastName = 'Member';
        testMember.Stand_Office__c = 'OR';
        testMember.Acquired_By__c = 'C3 Acquired';
        testMember.membership_start_date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        testMember.Stand_Team_Affiliation__c = objTeam1.Id;
        testMember.Membership_Type__c = 'Annual';
        Insert testMember;
        
         // ------ Contact 2 -------------
        Contact testLeader = new Contact();
        testLeader.FirstName = 'Test';
        testLeader.LastName = 'Leader';
        testLeader.Stand_Office__c = 'OR';
        testLeader.Acquired_By__c = 'C3 Acquired';
        testLeader.membership_start_date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        testLeader.Stand_Team_Affiliation__c = objTeam1.Id;
        testLeader.Membership_Type__c = 'Annual';
        testLeader.LiT_Start_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        testLeader.Leader_Type__c = 'Leader in Training';
        Insert testLeader;
        
        Contact alternateLeader = new Contact();
        alternateLeader.FirstName = 'Alternate';
        alternateLeader.LastName = 'Leader';
        alternateLeader.Stand_Office__c = 'OR';
        alternateLeader.Acquired_By__c = 'C3 Acquired';
        alternateLeader.membership_start_date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        alternateLeader.Stand_Team_Affiliation__c = objTeam2.Id;
        alternateLeader.Membership_Type__c = 'Annual';
        alternateLeader.LiT_Start_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
        alternateLeader.Leader_Type__c = 'Leader in Training';
        Insert alternateLeader;
        
        // ------ Person 1 -------------
        Person testMemPerson = new Person();
        testMemPerson.getById(testMember.id);

        // ------ Person 2 -------------
        Person testLdrPerson = new Person();
        testLdrPerson.getByID(testLeader.id);
		
		//-----------------Test changeLeader-------------------------------------
		testMemPerson.Membership.leader_id = testLeader.id;
		  
        PersonCollection pc = new PersonCollection();
        pc.people = new list < Person >();
        pc.people.add(testMemPerson);
        pc.people.add(testLdrPerson);
        
        pc.changeLeader();
        
        Contact checkLeader = ([SELECT ID, Stand_Leader__c FROM Contact WHERE ID =:testMember.id]);
        system.AssertEquals (testLeader.id, checkLeader.Stand_Leader__c);
        
        //-----------------Test changeTeam-------------------------------------
        testMemPerson.Membership.team_id = objTeam2.id;
        testMemPerson.Membership.leader_id = alternateLeader.id;
        
        PersonCollection testTeamChangePC = new PersonCollection();
        testTeamChangePC.People = new list < Person >();
        
        testTeamChangePC.People.add(testMemPerson);
        
        PersonCollection ppl2 = new PersonCollection();
        ppl2.changeTeam(testTeamChangePC);
        
        Contact checkTeam = ([SELECT ID, Stand_Leader__c, Stand_Team_Affiliation__c FROM Contact WHERE ID =:testMember.id]);
        system.AssertEquals (objTeam2.id, checkTeam.Stand_Team_Affiliation__c); 
        
        
        
        //-----------------Test removeLeaderFromMembers-------------------------------------
       	list < string > leaderIds = new list < string >();
       	leaderIds.add(testLeader.id); //contact record still has testLeader, so using that ID .
       	
		PersonCollection pc3 = new PersonCollection();
		if (pc3.removeLeaderFromMembers(leaderIds)) {
			//hooray
		}
		       	
       	Contact checkLeaderRemoved = ([SELECT Id, Stand_Leader__c FROM Contact Where ID=: testMemPerson.id]);
       	system.AssertEquals (null, checkLeaderRemoved.Stand_Leader__c);
        
	}

}