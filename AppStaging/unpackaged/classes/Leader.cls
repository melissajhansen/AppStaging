global with sharing class Leader {
	
	public Person 			leader;
	public PersonCollection	assignedMembers;
	public integer			sortOrder;

		
	public Leader () {
		// default constructor 
	
	}
	
	public boolean getByID ( string leader_id ) {
		
		//load up Leader's Person Record
		Person person = new Person ();
		if (person.getById (leader_id)) {
			this.leader = person;
		}
		
		//retrieve list of Members assigned to Leader
		PersonCollection p = new PersonCollection();
		if (p.getMembersByLeader(leader_id)) { 
			this.assignedMembers = p;
		}
		
		this.sortOrder = 1;
		
		return true;
		
	}
	
	public boolean create () {
		DateTime dT = System.now();
		Contact newLeader = ([SELECT ID, Leader_Type__c, LiT_Start_Date__c, Stand_Leader__c, Membership_Status__c, Stand_Team_Affiliation__c, Version__c FROM Contact WHERE id=: this.leader.id]);
		string oldLeaderId;
		
		//Validations
		if ( newLeader.Version__c != this.Leader.version ) {
 	    	throw new StandException(300);
		}
		
		//Must be an active member 
		if ( newLeader.Membership_Status__c != 'Active' ) {
 	    	throw new StandException(107);
		}
		//Must not already be a leader
		if ( (newLeader.Leader_Type__c == 'Leader') || (newLeader.Leader_Type__c == 'Leader in Training')) {
 	    	throw new StandException(108);
		}
		
		
		system.debug('******************************Existing Leader on Contact'+newLeader.Stand_Leader__c);
		//We have a winner, insert LiT start date (and if has Former Leader Status, clear out other dates, update leadercount for old leader)
		//Capture existing leaderId before removing
		oldLeaderId = newLeader.Stand_Leader__c;
		if ( newLeader.Leader_Type__c == 'Former Leader' ) {
			newLeader.LiT_Start_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
			newLeader.LiT_Stop_Date__c = null;
			newLeader.Leader_Start_Date__c = null;
			newLeader.Leader_Stop_Date__c = null;
			newLeader.Stand_Leader__c = null;
			newLeader.Leader_Type__c = 'Leader in Training';
		} else {
			newLeader.LiT_Start_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
			newLeader.Leader_Type__c = 'Leader in Training';
			newLeader.Stand_Leader__c = null;
		}
		
		update newLeader;
		//Update Tallies on oldLeader
		MemHelper.updateTallies(oldLeaderId, 'Leader');
		
		//Load updated Leader
		this.getById(newLeader.id);
		
		return true;
		
	}
	
	public boolean endLeadership () {
		DateTime dT = System.now();
		//Ends leadership by removing the leader from all Members and inserting the appropriate end date
		//If ending Leader-in-Training, insert system date as LiT End Date, otherwise insert system date as Leader End Date
		//TODO Change Leader Type  ???  That field might need to be a formula
		
		
		Contact endLeader = ([SELECT ID, Leader_Type__c, LiT_Stop_Date__c, Leader_Stop_Date__c, Stand_Team_Affiliation__c, Version__c FROM Contact WHERE id=: this.leader.id]);
		
		if ( endLeader.Leader_Type__c == 'Leader in Training' ) {
			endLeader.LiT_Stop_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
			endLeader.Leader_Type__c = 'Former Leader';
		} else if ( endLeader.Leader_Type__c == 'Leader' ){
			endLeader.Leader_Stop_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
			endLeader.Leader_Type__c = 'Former Leader';
		}  Else {
 	    	throw new StandException(105);
		}
		
		//Remove all members assigned to this Leader
		Person.removeLeaderFromMembers(this.leader.id);
		
		update endLeader;
		
		return true;
		
	}
	
	public boolean changeTeam () {
		//Accepts a leader Person record and updates the matching contact record's team with the team provided
		//Removes the Leader from their current members
		list < string > leaderIds = new list < string >(); 
		string oldTeamId;
		
		Contact leaderContact = ([SELECT id, Stand_Team_Affiliation__c, Leader_Type__c, Version__c FROM Contact WHERE id =:this.Leader.id]);
		
		//Validate that the record has not been updated since it was retrieved
		if ( this.leader.version != leaderContact.Version__c) {
 	    	throw new StandException(300);
		}
		
		//Validate that the person passed in is a viable Leader ( Leader or LiT )
		if ( (leaderContact.Leader_Type__c != 'Leader') && (leaderContact.Leader_Type__c != 'Leader in Training')) {
			throw new StandException(115);
		}
		//Remove Leader from Current Members
		Person.removeLeaderFromMembers(leaderContact.id);
		
		//Save old Team ID for updating and set new team on Contact Record
		oldTeamId = leaderContact.Stand_Team_Affiliation__c;
		leaderContact.Stand_Team_Affiliation__c = this.leader.Membership.team_id;
		update leaderContact;
		
		//Update member counts on old & new teams and old/new Organizers
		MemHelper.updateTallies(oldTeamId, 'Team');
		MemHelper.updateTallies(this.leader.Membership.team_id, 'Team');
		
		return true;
		
	}
	
	public static boolean updateLdrTallies (string leaderId) {
		//Takes a leader ID as argument and updates the Member Counts on that Leader's record
		//May be passed null id, enables this to be called irrespective of a member's leadership assignment or lack thereof
		
		//Check to see if a leader Id has been passed in (easy to do this hear than check for leader each time this method is called)
		if (leaderId == null ) {
			return true;
		}
		
		Contact ldr= ([SELECT Id, active_member_count__c, lapsed_member_count__c, lapsing_member_count__c FROM Contact WHERE id=:leaderId]);
		list < Contact > assignedMembers = new list < Contact > ([SELECT id, Membership_Status__c, Stand_Leader__c FROM Contact WHERE Stand_Leader__c =:ldr.id]);
		integer activeMemTally = 0;
		integer lapsingMemTally = 0;
		integer lapsedMemTally = 0;
		
		for ( Contact am: assignedMembers ) {
			if ( am.Membership_Status__c == 'Active') {
				activeMemTally++;
			} else if ( am.Membership_Status__c == 'Lapsing') {
				lapsingMemTally++;
			} else if ( am.Membership_Status__c == 'Lapsed' ) {
				lapsedMemTally++;
			}
		}
		
		ldr.Active_Member_Count__c = activeMemTally;
		ldr.Lapsing_Member_Count__c = lapsingMemTally;
		ldr.Lapsed_Member_Count__c = lapsedMemTally;
		
		update ldr;
		
		return true;
	}
	
}