global with sharing class TeamCollection {
	
	public list < Team > teams;
	
	public TeamCollection() {
			//default constructor
			
	} 

	public boolean getByIdList ( list < string > team_ids) {
		integer sizeOfTeamList;
		
		list < Account > teamAccounts = new list < Account > ([SELECT Id, Name, Organizer__c, Leader_Count__c, Team_Leader_Count__c, Leader_in_Training_Count__c, Member_Count__c, Active_Member_Count__c, Lapsed_Member_Count__c, Lapsing_Member_Count__c, Average_Annual_Membership_Gift_Amount__c, Orphan_Count__c, Connected_Member_Count__c, Version__c From Account Where Id in: team_ids ]);
		sizeOfTeamList = teamAccounts.size();
		LeaderCollection teamLeaders = new LeaderCollection();
		PersonCollection leaderlessMembers = new PersonCollection();
		list < string > leaderIdList = new list < string >();
		
		//Load Up Leaders
		LeaderCollection ldrs = new LeaderCollection();
		if (ldrs.getLeadersByTeamIdList(team_ids)) {
			teamLeaders.leaders = ldrs.leaders;
		}
		
		for ( Leader leader: teamLeaders.leaders) {
			leaderIdList.add(leader.leader.id);
		}
		
		//Load Up Leaderless Members
		PersonCollection mems = new PersonCollection();
		if ( mems.getMembersWithoutLeadersByTeamList (team_ids)) {
			leaderlessMembers.people = mems.people;
		}
		
		this.teams = new list < Team >();
		team t;
		
		for (integer x = 0; x < sizeOfTeamList; x++) {
			t = new Team();
			t.id = teamAccounts[x].Id;
			t.team_name = teamAccounts[x].Name;
			t.organizer_id = teamAccounts[x].Organizer__c;
			t.leader_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Leader_Count__c);
			t.team_leader_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Team_Leader_Count__c);
			t.leader_in_training_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Leader_in_Training_Count__c);
			t.member_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Member_Count__c);
			t.active_member_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Active_Member_Count__c);
			t.lapsing_member_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Lapsing_Member_Count__c);
			t.lapsed_member_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Lapsed_Member_Count__c);
			t.average_annual_gift_amount = HelperFunctions.doubleValueOfDecimal(teamAccounts[x].Average_Annual_Membership_Gift_Amount__c);
			t.leader_member_connection_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Connected_Member_Count__c);
			t.orphan_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Orphan_Count__c);
			t.version = teamAccounts[x].Version__c;
			
			
			t.leaders = new LeaderCollection();
			t.leaders.leaders = new list < Leader >();
			for (Leader ldr: teamLeaders.leaders) {
				if (ldr.leader.membership.team_id == t.id){
					t.leaders.leaders.add(ldr);
				}
			}
			
			t.members_without_leader = new PersonCollection();
			t.members_without_leader.people = new list < Person >();
			for (Person mem: leaderlessMembers.people) {
				if (mem.membership.team_id == t.id) {
					t.members_without_leader.people.add(mem);
				}
			}
			
			this.teams.add(t);
		
			
		}

		
		return true;
	}
	
	// Added SKT 10/7/13
	public boolean getHeaderOnlyByIdList ( list < string > team_ids) {
		integer sizeOfTeamList;
		
		list < Account > teamAccounts = new list < Account > ([SELECT Id, Name, Organizer__c, Leader_Count__c, Team_Leader_Count__c, Leader_in_Training_Count__c, Member_Count__c, Active_Member_Count__c, Lapsed_Member_Count__c, Lapsing_Member_Count__c, Average_Annual_Membership_Gift_Amount__c, Orphan_Count__c, Connected_Member_Count__c, Version__c From Account Where Id in: team_ids ]);
		sizeOfTeamList = teamAccounts.size();
		
		this.teams = new list < Team >();
		team t;
		
		for (integer x = 0; x < sizeOfTeamList; x++) {
			t = new Team();
			t.id = teamAccounts[x].Id;
			t.team_name = teamAccounts[x].Name;
			t.organizer_id = teamAccounts[x].Organizer__c;
			t.leader_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Leader_Count__c);
			t.team_leader_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Team_Leader_Count__c);
			t.leader_in_training_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Leader_in_Training_Count__c);
			t.member_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Member_Count__c);
			t.active_member_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Active_Member_Count__c);
			t.lapsing_member_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Lapsing_Member_Count__c);
			t.lapsed_member_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Lapsed_Member_Count__c);
			t.average_annual_gift_amount = HelperFunctions.doubleValueOfDecimal(teamAccounts[x].Average_Annual_Membership_Gift_Amount__c);
			t.leader_member_connection_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Connected_Member_Count__c);
			t.orphan_count = HelperFunctions.trueIntegerValueOf(teamAccounts[x].Orphan_Count__c);
			t.version = teamAccounts[x].Version__c;
			
			this.teams.add(t);
			
		}
		
		return true;
	}
	
	public static boolean updateTeamsMemberCounts ( list < string > team_ids ) {
		list < Account > teamAccounts = new list < Account > ([SELECT id, Active_Member_Count__c, Lapsing_Member_Count__c, Lapsed_Member_Count__c FROM Account WHERE id in:team_ids]);
		list < Contact > assignedMembers = new list < Contact > ([SELECT id, Membership_Status__c, Stand_Team_Affiliation__c FROM Contact WHERE Stand_Team_Affiliation__c in:team_ids]);
		integer activeMemTally = 0;
		integer lapsingMemTally = 0;
		integer lapsedMemTally = 0;
		
		for ( Account t: teamAccounts ) {
			for ( Contact am: assignedMembers ) {
				if ( am.Stand_Team_Affiliation__c == t.id ) {
					if (  am.Membership_Status__c == 'Active' ) {
						activeMemTally++;
					} else if ( am.Membership_Status__c == 'Lapsing' ) {
						lapsingMemTally++;
					} else if ( am.Membership_Status__c == 'Lapsed' ) {
						lapsedMemTally++;
					}
				}
			}
			//assign counts
			t.Active_Member_Count__c = activeMemTally;
			t.Lapsing_Member_Count__c = lapsingMemTally;
			t.Lapsed_Member_Count__c = lapsedMemTally;
			//zero out the variables
			activeMemTally = 0;
			lapsingMemTally = 0;
			lapsedMemTally = 0;
		}
		
		update teamAccounts;
		return true;
	}

}