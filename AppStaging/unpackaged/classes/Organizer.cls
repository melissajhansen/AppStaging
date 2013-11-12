public with sharing class Organizer {
	// interface defining an Organizer
	public string 			organizer_user_id;
	public string 			organizer_contact_id;
	public string 			first_name;
	public string 			last_name;
	public decimal			version;
	public TeamCollection 	teams;
	public integer			member_count;					
	public integer 			active_member_count;			
	public integer 			lapsing_member_count;			
	public integer 			lapsed_member_count;			
	public double 			average_annual_gift_amount;		
	public integer 			leader_member_connection_count;	 
	public integer			orphan_count;		
	public integer			leader_count;
	public integer			team_leader_count;
	public integer			leader_in_training_count;
	
	public Organizer () {
			//default Constructor	
	}
	

	
	// Final Methods
	
	public boolean getByUserId ( string organizer_user_id ) {
		
		list < string > teamIds = new list < string > ();
		//Look up Organizer's Contact ID from the User ID provided
		Contact organizerContact = ([SELECT ID, Linked_User__c, FirstName, LastName, Version__c, Member_Count__c, Active_Member_Count__c, Lapsing_Member_Count__c, Lapsed_Member_Count__c, Assigned_Members_Avg_Annual_Gift__c, Connected_Member_Count__c, Orphan_Count__c, Leader_in_Training_Count__c, Team_Leader_Count__c, Leader_Count__c  FROM Contact WHERE Linked_User__c =: organizer_user_id]);  //Error Handling for empty list or list >1

		this.organizer_contact_id = 			organizerContact.Id;
		this.organizer_user_id = 				organizerContact.Linked_User__c;
		this.first_name = 						organizerContact.FirstName;
		this.last_name = 						organizerContact.LastName;
		this.version = 							organizerContact.Version__c;
		this.member_count =						HelperFunctions.trueIntegerValueOf(organizerContact.Member_Count__c);
		this.active_member_count =				HelperFunctions.trueIntegerValueOf(organizerContact.Active_Member_Count__c);
		this.lapsing_member_count =				HelperFunctions.trueIntegerValueOf(organizerContact.Lapsing_Member_Count__c);
		this.lapsed_member_count =				HelperFunctions.trueIntegerValueOf(organizerContact.Lapsed_Member_Count__c);
		this.average_annual_gift_amount =		HelperFunctions.doubleValueOfDecimal(organizerContact.Assigned_Members_Avg_Annual_Gift__c);
		this.leader_member_connection_count =	HelperFunctions.trueIntegerValueOf(organizerContact.Connected_Member_Count__c);
		this.orphan_count =						HelperFunctions.trueIntegerValueOf(organizerContact.Orphan_Count__c);
		this.leader_count =						HelperFunctions.trueIntegerValueOf(organizerContact.leader_count__c);
		this.team_leader_count =				HelperFunctions.trueIntegerValueOf(organizerContact.team_leader_count__c);
		this.leader_in_training_count =			HelperFunctions.trueIntegerValueOf(organizerContact.leader_in_training_count__c);

		//Create and Fill a list of team accounts for this Organizer
		list < Account > teamAccounts = new list < Account > ([SELECT ID from Account WHERE Organizer__c =: organizerContact.Id AND Type =:'Stand Team']);
		//put those Ids into a list of strings
		for (Account a: teamAccounts) {
			teamIds.add(a.id);
		}
		//Get and fill the TeamCollection
		TeamCollection t = new TeamCollection();
		if (t.getByIdList(teamIds)) {
			this.teams = t;
		}
		
		return true;
	}
	
	public boolean getByContactId ( string contact_user_id ) {
		
		list < string > teamIds = new list < string > ();
		//Look up Organizer's Contact ID from the User ID provided
		Contact organizerContact = ([SELECT ID, Linked_User__c, FirstName, LastName, Version__c, Member_Count__c, Active_Member_Count__c, Lapsing_Member_Count__c, Lapsed_Member_Count__c, Assigned_Members_Avg_Annual_Gift__c, Connected_Member_Count__c, Orphan_Count__c, Leader_Count__c, Leader_in_Training_Count__c, Team_Leader_Count__c FROM Contact WHERE id =: contact_user_id]);  //Error Handling for empty list or list >1

		this.organizer_contact_id = 			organizerContact.Id;
		this.organizer_user_id = 				organizerContact.Linked_User__c;
		this.first_name = 						organizerContact.FirstName;
		this.last_name = 						organizerContact.LastName;
		this.version = 							organizerContact.Version__c;
		this.member_count =						HelperFunctions.trueIntegerValueOf(organizerContact.Member_Count__c);
		this.active_member_count =				HelperFunctions.trueIntegerValueOf(organizerContact.Active_Member_Count__c);
		this.lapsing_member_count =				HelperFunctions.trueIntegerValueOf(organizerContact.Lapsing_Member_Count__c);
		this.lapsed_member_count =				HelperFunctions.trueIntegerValueOf(organizerContact.Lapsed_Member_Count__c);
		this.average_annual_gift_amount =		HelperFunctions.doubleValueOfDecimal(organizerContact.Assigned_Members_Avg_Annual_Gift__c);
		this.leader_member_connection_count =	HelperFunctions.trueIntegerValueOf(organizerContact.Connected_Member_Count__c);
		this.orphan_count =						HelperFunctions.trueIntegerValueOf(organizerContact.Orphan_Count__c);
		this.leader_count =						HelperFunctions.trueIntegerValueOf(organizerContact.leader_count__c);
		this.team_leader_count =				HelperFunctions.trueIntegerValueOf(organizerContact.team_leader_count__c);
		this.leader_in_training_count =			HelperFunctions.trueIntegerValueOf(organizerContact.leader_in_training_count__c);
		
		//Create and Fill a list of team accounts for this Organizer
		list < Account > teamAccounts = new list < Account > ([SELECT ID from Account WHERE Organizer__c =: organizerContact.Id AND Type =:'Stand Team']);
		//put those Ids into a list of strings
		for (Account a: teamAccounts) {
			teamIds.add(a.id);
		}
		//Get and fill the TeamCollection
		TeamCollection t = new TeamCollection();
		if (t.getByIdList(teamIds)) {
			this.teams = t;
		}
		
		return true;
	}
	
	public boolean create () {
		//Given a Contact ID for an eligible contact (no leader, matching user record) this method updates the Contact Record Type to Organizer and links to the matching user
		
		//There must be an existing contact Record and a User record.  They cannot have a leader, but may or may not be a member
		Contact newOrganizerContact = ([SELECT Id, RecordTypeId, Name, Stand_Leader__c, Linked_User__c FROM Contact WHERE id=:this.organizer_contact_id ]);
		system.debug('***********************ThisFirstName + Last Name'+this.first_name+' '+this.last_name);
		
		list < User > newOrganizerUser = new list < User > ([SELECT id, Name, Primary_State_Office__c FROM User WHERE Name=:this.first_name+' '+this.last_name]);//not sure this is foolproof
		string organizerRecordTypeID = Schema.Sobjecttype.Contact.RecordTypeInfosByName.get('Organizer').RecordTypeId;
				
		if ( newOrganizerUser.size() != 1 ) {
	    	throw new StandException(109);
			return false;
		}
		
		if ( newOrganizerContact.Stand_Leader__c != null) {
	    	throw new StandException(110);
			return false;
		}
		
		//Change the contact record's recordtype to Organizer and link to their User record
		newOrganizerContact.RecordTypeId = organizerRecordTypeId;
		newOrganizerContact.Linked_User__c = newOrganizerUser[0].id;
		
		update newOrganizerContact;
		
		return true;
		
		
	}
	
	public boolean deactivate () {
		//Given the contact id for an Organizer's contact recored, validates that the ORganizer is not assigned any teams or chapters and changes their record type back to the default
		
		Contact organizerDeactivateContact = ([SELECT Id, RecordTypeId, Name, Linked_User__c FROM Contact WHERE id=:this.organizer_contact_id ]);
		list < Account > teamChapterAccounts = new list < Account > ([SELECT Id, Name FROM Account WHERE Organizer__c =:this.organizer_contact_id]);	
		
		string defaultRecordTypeID = Schema.Sobjecttype.Contact.RecordTypeInfosByName.get('Non-VIP Contact').RecordTypeId;
		
		if ( teamChapterAccounts.size()>=1 ) {
	    	throw new StandException(111);
			return false;
		}
		
		organizerDeactivateContact.RecordTypeId = defaultRecordTypeID;
		update organizerDeactivateContact;
		return true;
	
	}
	
	public static boolean updateOrgTallies (string id, string objType) {
		if ( objType == 'Organizer') {
			updateOrganizerMemCounts (id);
			return true;
		}
		else if ( objType == 'Team') {
			updateOrganizerMemCountsByTeam(id);
			return true;
		}
		else return false;
	}
	 
	private static boolean updateOrganizerMemCountsByTeam ( string teamId ) {
		//Takes a Team ID as argument and updates the Member Counts for the Organizer of that Team
		system.debug('**********************TeamIDPassedIn'+teamID);
		Account organizerTeam =([SELECT id, name, organizer__c FROM Account WHERE id= :teamId]);
		Contact organizerCon = ([SELECT Id, name, active_member_count__c, lapsed_member_count__c, lapsing_member_count__c FROM Contact WHERE id=:organizerTeam.Organizer__c]);
		list < Contact > assignedMembers = new list < Contact > ([SELECT id, Membership_Status__c, Organizer__c, Stand_Leader__c, Leader_Type__c FROM Contact WHERE Organizer__c =:organizerCon.Id]);
		integer activeMemTally = 0;
		integer lapsingMemTally = 0;
		integer lapsedMemTally = 0;
		integer orphanedMemTally= 0;
		integer connectedMemTally= 0;
		integer TeamLeaderTally= 0;
		integer LiTTally= 0;
		
		for ( Contact am: assignedMembers ) {
			//member status tallies
			if ( am.Membership_Status__c == 'Active') {
				activeMemTally++;
			} 
			else if ( am.Membership_Status__c == 'Lapsing') {
				lapsingMemTally++;
			} 
			else if ( am.Membership_Status__c == 'Lapsed' ) {
				lapsedMemTally++;
			}
			//orphan/connected tallies
			if (am.Stand_Leader__c == null && (am.leader_type__c == null || am.leader_type__c == 'Former Leader')) {
				orphanedMemTally++;
			} 
			else if (am.Stand_Leader__c != null) {
				connectedMemTally++;
			}
			else if (am.Stand_Leader__c == null && am.leader_type__c != null) {  //Leaders count as connected Members
				connectedMemTally++;
			}
			//Leader Tallies
			if (am.Leader_Type__c == 'Team Leader') {
				TeamLeaderTally++;
			} 
			else if (am.Leader_Type__c == 'Leader in Training') {
				LiTTally++;
			}
		}
		
		organizerCon.Active_Member_Count__c = activeMemTally;
		organizerCon.Lapsing_Member_Count__c = lapsingMemTally;
		organizerCon.Lapsed_Member_Count__c = lapsedMemTally;
		organizerCon.Orphan_Count__c = orphanedMemTally;
		organizerCon.Connected_Member_Count__c = connectedMemTally;
		organizerCon.team_leader_count__c = TeamLeaderTally;
		organizerCon.leader_in_training_count__c = LiTTally;
		
		update organizerCon;
		
		return true;
	}
	
	private static boolean updateOrganizerMemCounts ( string organizerId ) {
		//Takes an Organizer ID as argument and updates the Member Counts for the Organizer
		Contact organizerCon = ([SELECT Id, name, active_member_count__c, lapsed_member_count__c, lapsing_member_count__c FROM Contact WHERE id=:organizerId]);
		list < Contact > assignedMembers = new list < Contact > ([SELECT id, Membership_Status__c, Organizer__c, Stand_Leader__c, Leader_Type__c FROM Contact WHERE Organizer__c =:organizerId]);
		integer activeMemTally = 0;
		integer lapsingMemTally = 0;
		integer lapsedMemTally = 0;
		integer orphanedMemTally= 0;
		integer connectedMemTally= 0;
		integer TeamLeaderTally= 0;
		integer LiTTally= 0;
		
		
		for ( Contact am: assignedMembers ) {
			//member status tallies
			if ( am.Membership_Status__c == 'Active') {
				activeMemTally++;
			} 
			else if ( am.Membership_Status__c == 'Lapsing') {
				lapsingMemTally++;
			} 
			else if ( am.Membership_Status__c == 'Lapsed' ) {
				lapsedMemTally++;
			}
			//orphan/connected tallies
			if (am.Stand_Leader__c == null && (am.leader_type__c == null || am.leader_type__c == 'Former Leader')) {
				orphanedMemTally++;
			} 
			else if (am.Stand_Leader__c != null) {
				connectedMemTally++;
			} 
			else if (am.Stand_Leader__c == null && am.leader_type__c != null) {  //Leaders count as connected Members
				connectedMemTally++;
			}
			//Leader Tallies
			if (am.Leader_Type__c == 'Team Leader') {
				TeamLeaderTally++;
			} 
			else if (am.Leader_Type__c == 'Leader in Training') {
				LiTTally++;
			}
		}
		
		organizerCon.Active_Member_Count__c = activeMemTally;
		organizerCon.Lapsing_Member_Count__c = lapsingMemTally;
		organizerCon.Lapsed_Member_Count__c = lapsedMemTally;
		organizerCon.Orphan_Count__c = orphanedMemTally;
		organizerCon.Connected_Member_Count__c = connectedMemTally;
		organizerCon.team_leader_count__c = TeamLeaderTally;
		organizerCon.leader_in_training_count__c = LiTTally;
		
		update organizerCon;
		
		return true;
	}
}