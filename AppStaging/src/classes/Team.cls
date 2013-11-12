global with sharing class Team {
	
	public string 			id;								//Account ID
	public string 			team_name;						
	public string 			organizer_id;					// organizer's Contact id
	public string			organizer_user_id;				// organizer's User Id, this is what the 
	public string			chapter_id;						// parent account record
	public integer			leader_count;					// total leaders for a team (all leader types)
	public integer 			team_leader_count;				// total team leaders for a team
	public integer 			leader_in_training_count; 		// total leader in training for a team
	public integer			member_count;					// total members for a team (all member types - includes all leaders)
	public integer 			active_member_count;			// total active members for a team (includes leaders)	
	public integer 			lapsing_member_count;			// total lapsing members for a team (includes leaders)
	public integer 			lapsed_member_count;			// total lapsed members for a team (includes leaders)
	public double 			average_annual_gift_amount;		// average donations of all members - projected???
	public integer 			leader_member_connection_count;	// number of members that have a leader assigned
	public integer			orphan_count;					 
	public integer			sortOrder;						// 
	public decimal			version;						// version number, used for data collision avoidance
	public LeaderCollection	leaders;						// collection of Leaders for a team, includes assigned Members
	public PersonCollection	members_without_leader;			// collection of Members who do not have a leader
	
	public Team () {
		// default constructor
	}
	
	public boolean getById ( string team_Id ) {
		
		//Retreive single-entry list of Account matching the Team ID, assign variables
		list < Account > teamAccounts = new list < Account > ([SELECT Id, Name, Organizer__c, ParentId, Leader_Count__c, Team_Leader_Count__c, Leader_in_Training_Count__c, Member_Count__c, Active_Member_Count__c, Lapsed_Member_Count__c, Lapsing_Member_Count__c, Average_Annual_Membership_Gift_Amount__c, Orphan_Count__c, Connected_Member_Count__c, Version__c From Account Where Id =: team_Id LIMIT 1]);
		
		this.id =								teamAccounts[0].Id;
		this.team_name = 						teamAccounts[0].Name;
		this.organizer_id = 					teamAccounts[0].Organizer__c;
		this.chapter_id = 						teamAccounts[0].ParentId;
		this.leader_count = 					HelperFunctions.trueIntegerValueOf(teamAccounts[0].Leader_Count__c);
		this.team_leader_count = 				HelperFunctions.trueIntegerValueOf(teamAccounts[0].Team_Leader_Count__c);
		this.leader_in_training_count = 		HelperFunctions.trueIntegerValueOf(teamAccounts[0].Leader_in_Training_Count__c);
		this.member_count = 					HelperFunctions.trueIntegerValueOf(teamAccounts[0].Member_Count__c);
		this.active_member_count = 				HelperFunctions.trueIntegerValueOf(teamAccounts[0].Active_Member_Count__c);
		this.lapsing_member_count = 			HelperFunctions.trueIntegerValueOf(teamAccounts[0].Lapsing_Member_Count__c);
		this.lapsed_member_count = 				HelperFunctions.trueIntegerValueOf(teamAccounts[0].Lapsed_Member_Count__c);
		this.average_annual_gift_amount = 		HelperFunctions.doubleValueOfDecimal(teamAccounts[0].Average_Annual_Membership_Gift_Amount__c);
		this.leader_member_connection_count = 	HelperFunctions.trueIntegerValueOf(teamAccounts[0].Connected_Member_Count__c);
		this.orphan_count = 					HelperFunctions.trueIntegerValueOf(teamAccounts[0].Orphan_Count__c);
		this.version = 							teamAccounts[0].Version__c;
		this.sortOrder = 						1;
			
		//Get Leaders for the Team
		this.leaders = new LeaderCollection();
		LeaderCollection teamLeaders = new LeaderCollection ();
		if (teamLeaders.getLeadersByTeamId( team_Id )) {
			this.leaders = teamLeaders;
		}
		
		//Get Members without a Leader on the Team
		this.members_without_leader = new PersonCollection();
		PersonCollection membersWithoutLeader = new PersonCollection ();
		if (membersWithoutLeader.getMembersWithoutLeadersByTeam (team_Id)) {
			this.members_without_leader = membersWithoutLeader;
		}
		
		return true;
		
	}
	
	public boolean create () {
		Account newTeamAccount = new Account();
		Account chapterAccount = ([SELECT id, BillingState FROM Account WHERE id =:this.chapter_id]);
		string teamRecordTypeID = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Team').RecordTypeId;
		
		//set incoming fields
		newTeamAccount.name = this.team_name;
		newTeamAccount.ParentId = this.chapter_id;
		newTeamAccount.Organizer__c = this.organizer_id;
		newTeamAccount.RecordTypeId = teamRecordTypeID;
		newTeamAccount.Type = 'Stand Team';
		newTeamAccount.Acquired_By__c = 'C4 Acquired';
		newTeamAccount.BillingState = chapterAccount.BillingState;
		
		insert newTeamAccount;
		
		return true;	
		
	}
	
	public boolean deactivate () {
		//For now, team can only be deactivated AFTER all members and Leaders have been reassigned
		//ability to globally move all members and Leaders from a deactivating  team to a different team has been proposed
		string FormerStandTeamRecordTypeID = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Former Stand Team').RecordTypeId;
		
		//Check that there are no Members/Leaders assigned to this team		
		list < Contact > assignedContacts= new list < Contact > ([SELECT id FROM Contact WHERE Stand_Team_Affiliation__c =:this.id]);
		if ( assignedContacts.size()>=1 ) {
			throw new standException(117);
			
		}
		//Change Account Type to Former Team & Remove Organizer
		Account deactivateTeamAccount = ([SELECT id, Organizer__c, Version__c, type FROM Account WHERE Id=:this.id ]);
		if ( deactivateTeamAccount.Version__c != this.version ) {
	    	throw new StandException(300);
	    	return false;
		}
		deactivateTeamAccount.Organizer__c = null;
		deactivateTeamAccount.Type = 'Former Stand Team';
		deactivateTeamAccount.RecordTypeId = FormerStandTeamRecordTypeID;
		
		update deactivateTeamAccount;
		
		return true;
		
	}
	
	public boolean reactivate () {
		
		//Change Account Type to Stand Team & add Organizer
		Account reactivateTeamAccount = ([SELECT id, Organizer__c, Version__c, type FROM Account WHERE Id=:this.id ]);
		string teamRecordTypeID = Schema.Sobjecttype.Account.RecordTypeInfosByName.get('Stand Team').RecordTypeId;
		
		if ( reactivateTeamAccount.Version__c != this.version ) {
	    	throw new StandException(300);
		}
		reactivateTeamAccount.Organizer__c = this.organizer_id;
		reactivateTeamAccount.Type = 'Stand Team';
		reactivateTeamAccount.RecordTypeId = teamRecordTypeID;		
		
		update reactivateTeamAccount;
		
		return true;
		
	}
	
	public boolean changeChapter () {
		//This will move the entire Team (leaders & Members) to the new chapter and set the Organizer to be the Organizer on the new Chapter
		Account newChapter = ([SELECT id, RecordTypeId FROM Account WHERE Id=:this.chapter_id]);
		Account changingChapterTeam = ([SELECT id, ParentId, Version__c FROM Account WHERE id=:this.id]);
		
		if ( changingChapterTeam.Version__c != this.version ) {
	    	throw new StandException(300);
		}
		
		changingChapterTeam.ParentId = newChapter.id;
		
		update changingChapterTeam;		
		
		return true;
	}
	
	public boolean changeOrganizer () {
		//This will move the entire Team (leaders & Members) to the new Organizer
		Account changingOrganizerTeam = ([SELECT id, Organizer__c, ParentId, Version__c FROM Account WHERE id=:this.id]);
		string oldOrganizerId;
		
		if ( changingOrganizerTeam.Version__c != this.version ) {
	    	throw new StandException(300);
		}
		
		//capture the old organizer id	
		oldOrganizerId = changingOrganizerTeam.Organizer__c;
		changingOrganizerTeam.Organizer__c = this.Organizer_id;
		
		update changingOrganizerTeam;	
		
		//Update tallies on former and new Organizer
		Organizer.updateOrgTallies(changingOrganizerTeam.Organizer__c, 'Organizer');
		Organizer.updateOrgTallies(this.Organizer_id, 'Organizer');
		
		return true;
	}
	
	public boolean editDetails () {
		Account editTeam = ([SELECT id, Organizer__c, Name, BillingState FROM Account WHERE id=:this.id]);
		
		editTeam.Name = this.team_name;		
		
		update editTeam;
		
		//TODO Validate that the name follows the format "text" + "Team"
		
		return true;
	}
	
	public static boolean updateTeamTallies (string teamId) {
		//In some cases this method may be passed a null (no existing team when attmpting to change teams) returns true since there is no team to update counts for.
		if ( teamId == null) {
			return true;
		}
		
		Account teamAccount = ([SELECT id, Active_Member_Count__c, Lapsing_Member_Count__c, Lapsed_Member_Count__c FROM Account WHERE id=:teamId]);
		list < Contact > assignedMembers = new list < Contact > ([SELECT id, Membership_Status__c, Stand_Team_Affiliation__c, Stand_Leader__c, Leader_Type__c FROM Contact WHERE Stand_Team_Affiliation__c=:teamId]);
		integer activeMemTally = 0;
		integer lapsingMemTally = 0;
		integer lapsedMemTally = 0;
		integer orphanedMemTally= 0;
		integer connectedMemTally= 0;
		integer TeamLeaderTally= 0;
		integer LiTTally= 0;
		
		for ( Contact am: assignedMembers) {
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
		
		teamAccount.Active_Member_Count__c = activeMemTally;
		teamAccount.Lapsing_Member_Count__c = lapsingMemTally;
		teamAccount.Lapsed_Member_Count__c = lapsedMemTally;
		teamAccount.Orphan_Count__c = orphanedMemTally;
		teamAccount.Connected_Member_Count__c = connectedMemTally;
		teamAccount.Leader_in_Training_Count__c = LiTTally;
		teamAccount.Team_Leader_Count__c = TeamLeaderTally;
		
		update teamAccount;
		
		return true;
	}
}