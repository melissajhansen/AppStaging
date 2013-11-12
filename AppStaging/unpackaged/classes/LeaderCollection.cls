global with sharing class LeaderCollection {
    
        public list < Leader > leaders;
        
    
    public LeaderCollection () {
        //default constructor
    }

    public boolean getLeadersByTeamId ( string team_id ) {
    //instantiates a LeaderCollection from a single team id, loading up Leaders for the team provided
        
        list < Contact > contactLeadersByTeam = new list < Contact > ([SELECT ID FROM Contact WHERE Is_Leader__c =: true AND Stand_Team_Affiliation__c =: team_id]);
        list < Id > contactLeadersIds = new List < Id >();
        PersonCollection leaderPersons = new PersonCollection ();
        PersonCollection allLeadersMembers = new PersonCollection ();
        
        for ( Contact c: contactLeadersByTeam) {
            contactLeadersIds.add(c.Id);
        }
        
        //Load up Leader Person records
        PersonCollection p = new PersonCollection();
        if (p.getByIdList(contactLeadersIds)) {
            leaderPersons = p;
        }
        //Load up Leaders' members
        PersonCollection m = new PersonCollection ();
        if (m.getMembersByLeaderList(contactLeadersIds)) {
            allLeadersMembers = m;
        }
		
		//Initialize leaders list fo this collection 
        this.leaders = new list < Leader > ();
        Leader ldr;
                
  		//Loop through the list of leaderPersons, instantiating a new Leader, assigning the person as the Leader Person 
  		//and iterating through The Members, assigning them to that leader's assignedMember's List based on their leader id
       for (Person per: leaderPersons.people) {
       		ldr = new Leader();
       		ldr.leader = per;
       		ldr.assignedMembers = new PersonCollection ();
       		ldr.assignedMembers.people = new list < Person > ();
       		for ( Person mem: allLeadersMembers.people) {
       			if ( ldr.leader.id == mem.Membership.leader_id) {
       				ldr.assignedMembers.people.add(mem);
       			}
       		}
       	 	this.leaders.add(ldr);
       }
       
        return true;
    }
    
	public boolean getLeadersByTeamIdList ( list < string > team_ids ) {
	//instantiates a LeaderCollection from a list of teamIds, loading up Leaders for the teams provided
        
        list < Contact > contactLeadersByTeam = new list < Contact > ([SELECT ID FROM Contact WHERE Is_Leader__c =: true AND Stand_Team_Affiliation__c in: team_ids]);
        list < Id > contactLeadersIds = new List < Id >();
        PersonCollection leaderPersons = new PersonCollection ();
        PersonCollection allLeadersMembers = new PersonCollection ();
        
        for ( Contact c: contactLeadersByTeam) {
            contactLeadersIds.add(c.Id);
        }
        
        //Load up Leader Person records
        PersonCollection p = new PersonCollection();
        if (p.getByIdList(contactLeadersIds)) {
            leaderPersons = p;
        }
        
		//Load up Leaders' members
        PersonCollection m = new PersonCollection ();
        if (m.getMembersByLeaderList(contactLeadersIds)) {
            allLeadersMembers = m;
        }
		
		//Initialize leaders list fo this collection 
        this.leaders = new list < Leader > ();
        Leader ldr;
                
  		//Loop through the list of leaderPersons, instantiating a new Leader, assigning the person as the Leader Person 
  		//and iterating through The Members, assigning them to that leader's assignedMember's List based on their leader id
       for (Person per: leaderPersons.people) {
       		ldr = new Leader();
       		ldr.leader = per;
       		ldr.assignedMembers = new PersonCollection ();
       		ldr.assignedMembers.people = new list < Person > ();
       		for ( Person mem: allLeadersMembers.people) {
       			if ( ldr.leader.id == mem.Membership.leader_id) {
       				ldr.assignedMembers.people.add(mem);
       			}
       		}
       	 	this.leaders.add(ldr);
       }
       
       return true;
    }
    
    public static boolean updateLeaderMemberCounts ( list < string > leadersToUpdateIds ) {
    //Takes in a list of Leader IDs and updates their member counts
    	list < Contact > leaderContacts = new list < Contact > ([SELECT Leader_Type__c, Member_Count__c, Active_Member_Count__c, Lapsed_Member_Count__c, Lapsing_Member_Count__c FROM Contact WHERE id in:leadersToUpdateIds]);
    	list < Contact > assignedMembers = new list < Contact > ([SELECT id, Membership_Status__c, Stand_Leader__c FROM Contact WHERE Stand_Leader__c in:leadersToUpdateIds ]);
    	integer activeMemTally = 0;
		integer lapsingMemTally = 0;
		integer lapsedMemTally = 0;
		
		for ( Contact ldr: leaderContacts ) {
			for ( Contact am: assignedMembers ) {
    			if ( am.Stand_Leader__c == ldr.id ) {
    				if ( am.Membership_Status__c == 'Active') {
    					activeMemTally++;
    				} else if ( am.Membership_Status__c == 'Lapsing' ) {
    					lapsingMemTally++;
    				} else if ( am.Membership_Status__c == 'Lapsed') {
    					lapsedMemTally++;
    				}
    			}
    		}
			//assign counts
			ldr.Active_Member_Count__c = activeMemTally;
			ldr.Lapsing_Member_Count__c = lapsingMemTally;
			ldr.Lapsed_Member_Count__c = lapsedMemTally;
			//zero out the variables
			activeMemTally = 0;
			lapsingMemTally = 0;
			lapsedMemTally = 0;
    	}
    	
    	update leaderContacts;
    	
    	return true;
    }
    
}