public with sharing class PersonCollection {

    public list < Person > people;
    private static string TOKEN_TYPE = 'MemRenewLink';			 // used by the Member Renewal Email system
	private static string TEST_EMAIL = 'SFDCTesting@stand.org';  // used when in test mode to prevent real contacts from receiving the email
    
    public PersonCollection() {
            //defaultconstructor
    }
         
    
    public boolean getByIdList ( list < string > person_ids ) {
        integer sizeOfList;
        
        //List to hold Memberships for people
        list < Person.Membership > personMemberships = new list < Person.Membership > ();
        //List to Hold Leaderships for peopel
        list < Person.Leadership > personLeaderships = new list < Person.Leadership > ();
        
        list < Contact > personList = new list < Contact > ([SELECT ID, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, npe01__HomeEmail__c, npe01__WorkEmail__c, npe01__AlternateEmail__c, npe01__Preferred_Email__c, HomePhone, MobilePhone, npe01__WorkPhone__c, npe01__PreferredPhone__c, SMS_Status__c, Preferred_Language__c, Activist_Interests__c, Other_Activist_Interest__c, Involvement_Preferences__c, Other_Involvement_Preference__c, Community_Member__c, Parent_Guardian__c, Educator_Status__c, Educator_Type__c, Organizer_Notes__c, SystemModstamp, Membership_Status__c, Version__c FROM Contact WHERE Id in: person_ids ORDER BY Membership_Status__c, LastName, FirstName]);
        sizeOfList = personList.size();
        
        this.people = new list < Person > ();
        Person p;
        
        for (integer x = 0; X <sizeOfList; x++) {
            p = new Person();
            p.id =                              personList[x].Id;
            p.first_name =                      personList[x].FirstName;
            p.last_name =                       personList[x].LastName;
            p.mailing_address_street =          personList[x].MailingStreet;
            p.mailing_address_city =            personList[x].MailingCity;
            p.mailing_address_state =           personList[x].MailingState;
            p.mailing_address_zip =             personList[x].MailingPostalCode;
            p.personal_email =                  personList[x].npe01__HomeEmail__c;
            p.preferred_email_type =            personList[x].npe01__Preferred_Email__c;
            p.work_email =                      personList[x].npe01__WorkEmail__c;
            p.alternate_email =                 personList[x].npe01__AlternateEmail__c;
            p.preferred_phone_type =            personList[x].npe01__PreferredPhone__c;
            p.home_phone =                      personList[x].HomePhone;
            p.work_phone =                      personList[x].npe01__WorkPhone__c;
            p.mobile_phone =                    personList[x].MobilePhone;
            p.is_sms_opted_in =                 personList[x].SMS_Status__c; 
            p.preferred_language =              personList[x].Preferred_Language__c;
            p.other_activist_interests =        personList[x].Other_Activist_Interest__c;
            p.other_involvement_preferences =   personList[x].Other_Involvement_Preference__c;
            p.is_parent =                       personList[x].Parent_Guardian__c;
            p.is_community_member =             personList[x].Community_Member__c;
            p.educator_status =                 personList[x].Educator_Status__c;
            p.educator_type =                   personList[x].Educator_Type__c;
            p.organizer_notes =                 personList[x].Organizer_Notes__c; 
            p.version = 						personList[x].Version__c;
            p.last_modified_date =              personList[x].SystemModstamp;
            
            if (string.isNotEmpty(personList[x].Activist_Interests__c)) {
                p.activist_interests_list = HelperFunctions.MultiSelectToList(personList[x].Activist_Interests__c);
            } else p.activist_interests_list = null;
            
            if (string.isNotEmpty(personList[x].Involvement_Preferences__c)) {
                p.involvement_preferences_list = HelperFunctions.MultiSelectToList(personList[x].Involvement_Preferences__c);
            } else p.involvement_preferences_list = null;
        
       		 this.people.add(p);
       		 
        }
        
        
        //Set the Memberships
        personMemberships = getMemberships(person_ids);
       
        for (Person per:people) {
            for (Person.Membership mem :personMemberships) {
                if (per.id == mem.person_id) {
                    per.membership = mem;
                }
            }
        }
        
        //Set the LEaderships
        personLeaderships = getLeaderships (person_ids);
        
        for (Person per: people) {
            for (Person.Leadership ldr :personLeaderships) {
                if (per.id == ldr.person_id) {
                    per.leadership = ldr;
                }
            }
        }
        
        return true;
    } 
    
    // Added 10/7/13 SKT
    public boolean getHeaderOnlyByIdList ( list < string > person_ids ) {
        integer sizeOfList;
        
        list < Contact > personList = new list < Contact > ([SELECT ID, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, npe01__HomeEmail__c, npe01__WorkEmail__c, npe01__AlternateEmail__c, npe01__Preferred_Email__c, HomePhone, MobilePhone, npe01__WorkPhone__c, npe01__PreferredPhone__c, SMS_Status__c, Preferred_Language__c, Activist_Interests__c, Other_Activist_Interest__c, Involvement_Preferences__c, Other_Involvement_Preference__c, Community_Member__c, Parent_Guardian__c, Educator_Status__c, Educator_Type__c, Organizer_Notes__c, SystemModstamp, Membership_Status__c, Version__c FROM Contact WHERE Id in: person_ids ORDER BY Membership_Status__c, LastName, FirstName]);
        sizeOfList = personList.size();
        
        this.people = new list < Person > ();
        Person p;
        
        for (integer x = 0; X <sizeOfList; x++) {
            p = new Person();
            p.id =                              personList[x].Id;
            p.first_name =                      personList[x].FirstName;
            p.last_name =                       personList[x].LastName;
            p.mailing_address_street =          personList[x].MailingStreet;
            p.mailing_address_city =            personList[x].MailingCity;
            p.mailing_address_state =           personList[x].MailingState;
            p.mailing_address_zip =             personList[x].MailingPostalCode;
            p.personal_email =                  personList[x].npe01__HomeEmail__c;
            p.preferred_email_type =            personList[x].npe01__Preferred_Email__c;
            p.work_email =                      personList[x].npe01__WorkEmail__c;
            p.alternate_email =                 personList[x].npe01__AlternateEmail__c;
            p.preferred_phone_type =            personList[x].npe01__PreferredPhone__c;
            p.home_phone =                      personList[x].HomePhone;
            p.work_phone =                      personList[x].npe01__WorkPhone__c;
            p.mobile_phone =                    personList[x].MobilePhone;
            p.is_sms_opted_in =                 personList[x].SMS_Status__c; 
            p.preferred_language =              personList[x].Preferred_Language__c;
            p.other_activist_interests =        personList[x].Other_Activist_Interest__c;
            p.other_involvement_preferences =   personList[x].Other_Involvement_Preference__c;
            p.is_parent =                       personList[x].Parent_Guardian__c;
            p.is_community_member =             personList[x].Community_Member__c;
            p.educator_status =                 personList[x].Educator_Status__c;
            p.educator_type =                   personList[x].Educator_Type__c;
            p.organizer_notes =                 personList[x].Organizer_Notes__c; 
            p.version = 						personList[x].Version__c;
            p.last_modified_date =              personList[x].SystemModstamp;
            
            if (string.isNotEmpty(personList[x].Activist_Interests__c)) {
                p.activist_interests_list = HelperFunctions.MultiSelectToList(personList[x].Activist_Interests__c);
            } else p.activist_interests_list = null;
            
            if (string.isNotEmpty(personList[x].Involvement_Preferences__c)) {
                p.involvement_preferences_list = HelperFunctions.MultiSelectToList(personList[x].Involvement_Preferences__c);
            } else p.involvement_preferences_list = null;
        
       		 this.people.add(p);
       		 
        }
        
        return true;
    } 
    
    private list <Person.Membership> getMemberships ( list < string > person_ids ) {
        integer listSize;
        
        list < Contact > contactList = new List < Contact >  ([SELECT ID, Stand_Team_Affiliation__c, Stand_Leader__c, Stand_Team_Organizer__c, Membership_Type__c, Membership_Status__c, Membership_Start_Date__c, Last_Membership_Renewal_Date__c, Last_Membership_Gift_Amount__c, Lifetime_Membership_Giving__c, Last_Membership_Gift_Date__c, Average_Annual_Membership_Gift_Amount__c, Membership_State__c FROM Contact WHERE ID in: person_ids]);
        listSize = contactList.size();
        
        list < Person.Membership > memberships = new List < Person.Membership > ();
        
        Person.Membership m;
        for (integer x = 0; x < listSize; x++ ) {
            m = new Person.Membership();
            m.person_id =                               contactList[x].Id;
            m.membership_state =						contactList[x].Membership_State__c;		
            m.team_id =                                 contactList[x].Stand_Team_Affiliation__c;
            m.leader_id =                               contactList[x].Stand_Leader__c;
            m.organizer_id =                            contactList[x].Stand_Team_Organizer__C;
            m.membership_type =                         contactList[x].Membership_Type__c;
            m.membership_status =                       contactList[x].Membership_Status__c;
            m.membership_start_date =                   contactList[x].Membership_Start_Date__c;
            m.last_membership_renewal_date =            contactList[x].Last_Membership_Renewal_Date__c;
            m.gift_amount =             				HelperFunctions.doubleValueOfDecimal(contactList[x].Last_Membership_Gift_Amount__c);
            m.lifetime_membership_gift_amount =         HelperFunctions.doubleValueOfDecimal(contactList[x].Lifetime_Membership_Giving__c);
            m.gift_date =               				contactList[x].Last_Membership_Gift_Date__c;
            m.average_annual_membership_gift_amount =   HelperFunctions.doubleValueOfDecimal(contactList[x].Average_Annual_Membership_Gift_Amount__c);
            
            memberships.add(m); 
             
        }
        return memberships;
    }
    
    private list < Person.Leadership > getLeaderships ( list < string > person_ids) {
        integer listSize;
        
        list < Contact > contactList = new List < Contact > ([SELECT ID, Leader_Type__c, Member_Count__c, Active_Member_Count__c, Lapsed_Member_Count__c, Lapsing_Member_Count__c, LiT_Start_Date__c, LiT_Stop_Date__c, Leader_Start_Date__c, Leader_Stop_Date__c, Stand_Team_Organizer__c, Stand_Team_Affiliation__c FROM Contact WHERE Id in: person_ids]);
        listSize = contactList.size();
        
        list < Person.Leadership > leaderships = new list < Person.Leadership > ();
        
        Person.Leadership ldr;
        for ( integer x = 0; x < listSize; x++) {
            ldr = new Person.Leadership();
            ldr.person_id =             contactList[x].Id;
            ldr.leader_type =           contactList[x].Leader_Type__c;
            ldr.member_count =   		HelperFunctions.trueIntegerValueOf(contactList[x].Member_Count__c); 
            ldr.active_member_count =   HelperFunctions.trueIntegerValueOf(contactList[x].Active_Member_Count__c);
            ldr.lapsed_member_count =   HelperFunctions.trueIntegerValueOf(contactList[x].Lapsed_Member_Count__c);
            ldr.lapsing_member_count =  HelperFunctions.trueIntegerValueOf(contactList[x].Lapsing_Member_Count__c);
            ldr.lit_start_date =        contactList[x].LiT_Start_Date__c;
            ldr.lit_stop_date =         contactList[x].LiT_Stop_Date__c;
            ldr.leader_start_date =     contactList[x].Leader_Start_Date__c;
            ldr.leader_stop_date =      contactList[x].Leader_Stop_Date__c; 
            
            leaderships.add(ldr);
            
        }
        
        return leaderships;
    
    }
    
    public boolean getMembersWithoutLeadersByTeam ( string team_id ) {
        
        //Get list of Contact IDs for contacts in the team specified with no Leader     
        list < Contact > contactMembersWithoutLeaders = new list < Contact > ([SELECT ID FROM Contact WHERE Stand_Team_Affiliation__c =: team_id AND Stand_Leader__c =:Null ORDER BY Membership_Status__c, LastName, FirstName]);
        list < Id > contactIds = new list < Id > ();
        list < Person > membersWithoutLeader = new list < Person >();
        
        
        for ( Contact c: contactMembersWithoutLeaders) {
            contactIds.add(c.Id);
        }
        
        this.people = new list < Person > ();
        if (getByIdList(contactIds)) {
            membersWithoutLeader = this.People;
        }
        
        return true;         
    }
    
	public boolean getMembersWithoutLeadersByTeamList ( list < string > team_ids ) {
        
        //Get list of Contact IDs for contacts in the team specified with no Leader     
        list < Contact > contactMembersWithoutLeaders = new list < Contact > ([SELECT ID FROM Contact WHERE Stand_Team_Affiliation__c in:team_ids AND Stand_Leader__c =: Null ORDER BY Membership_Status__c, LastName, FirstName]);
        list < Id > contactIds = new list < Id > ();
        list < Person > membersWithoutLeader = new list < Person >();
        
        
        for ( Contact c: contactMembersWithoutLeaders) {
            contactIds.add(c.Id);
        }
        
        this.people = new list < Person > ();
        if (getByIdList(contactIds)) {
            membersWithoutLeader = this.People;
        }
        
        return true;         
    }
    
    public boolean getMembersByLeader ( string leader_id) {
        //Get list of Contact IDs for contacts assigned to the leader specified     
        list < Contact > contactMembers = new list < Contact > ([SELECT ID FROM Contact WHERE Stand_Leader__c =:leader_id ORDER BY Membership_Status__c, LastName, FirstName]);
        list < Id > contactIds = new list < Id > ();
        list < Person> membersAssignedToLeader = new list < Person >();
    
        
        for ( Contact c: contactMembers) {
            contactIds.add(c.Id);
        }
        
        if (getByIdList(contactIds)) {
            membersAssignedToLeader = this.People;
        }
        
        return true;    
    }
    
    public boolean getMembersByLeaderList ( list < string > leader_ids) {
        //Get list of Contact IDs for contacts assigned to the leader specified     
        list < Contact > contactMembers = new list < Contact > ([SELECT ID FROM Contact WHERE Stand_Leader__c in: leader_ids ORDER BY Membership_Status__c, LastName, FirstName]);
        list < Id > contactIds = new list < Id > ();
        list < Person> membersAssignedToLeaders = new list < Person >();
        
        
        for ( Contact c: contactMembers) {
            contactIds.add(c.Id);
        }
        
        if (getByIdList(contactIds)) {
            membersAssignedToLeaders = this.People;
        }
        
        return true;    
    }
    
    public boolean create () {
		list < Contact > newContacts = new list < Contact >();
		list < string > newContactIds = new list < string >();
		integer listSize = this.people.size();
		string userState = ([SELECT Primary_State_Office__c from USER where id=: UserInfo.getUserId()].Primary_State_Office__c);
		
		Contact c;
		
		
		for ( Person p: this.people ) {
			c = new Contact ();
			c.FirstName = p.first_name;
			c.LastName = p.last_name;
			c.MailingStreet = p.mailing_address_street;
			c.MailingCity = p.mailing_address_city;
			c.MailingState = p.mailing_address_state;
			c.MailingPostalCode = p.mailing_address_zip;
			c.npe01__HomeEmail__c = p.personal_email;
			c.npe01__Preferred_Email__c = p.preferred_email_type;
			c.npe01__WorkEmail__c = p.work_email;
			c.npe01__AlternateEmail__c = p.alternate_email;
			c.npe01__PreferredPhone__c = p.preferred_phone_type;
			c.HomePhone = p.home_phone;
			c.npe01__WorkPhone__c = p.work_phone;
			c.MobilePhone = p.mobile_phone;
			c.SMS_Status__c = p.is_sms_opted_in;
			c.Preferred_Language__c = p.preferred_language;
			c.Other_Activist_Interest__c = p.other_activist_interests;
			c.Other_Involvement_Preference__c = p.other_involvement_preferences;
			c.Parent_Guardian__c = p.is_parent;
			c.Community_Member__c = p.is_community_member;
			c.Educator_Status__c = p.educator_status;
			c.Educator_Type__c = p.educator_type;
			c.Organizer_Notes__c = p.organizer_notes;
			c.Stand_Office__c = userState;
			c.Acquired_By__c = 'C3 Acquired'; //TODO, Make this dynamic
			c.LeadSource = 'Organizer App'; //TODO, Make this dynamic
			
			if (p.activist_interests_list != null) {
				c.Activist_Interests__c = (string.join(p.activist_interests_list, ';'));
			}

			if (p.involvement_preferences_list != null) {
				c.Involvement_Preferences__c = (string.join(p.involvement_preferences_list, ';'));
			}
			
			newContacts.add(c);
		}
		
		insert newContacts;
		
		//Create list of ids from the newly inserted contacts
		for (Contact nc: newContacts) {
			newContactIds.add(nc.id);
		}
		
		//update this with PersonCollection including IDs (allows us to have correct IDs for persons in PersonCollection)
		this.getByIdList(newContactIds);

		return true;
		   	
    	
    }
    
    public boolean edit () {
    	//Takes in a Person Collection, and updates the matching Contact Records' fields to match those passed in.
    	
    	list < string > editContactsIds = new list < string >();
   
   		for ( Person per:this.people) {
   			editContactsIds.add(per.id);
   		}
    	
    	list < Contact > editContacts = new list < Contact > ([SELECT ID, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, npe01__HomeEmail__c, npe01__WorkEmail__c, npe01__AlternateEmail__c, npe01__Preferred_Email__c, HomePhone, MobilePhone, npe01__WorkPhone__c, npe01__PreferredPhone__c, SMS_Status__c, Preferred_Language__c, Activist_Interests__c, Other_Activist_Interest__c, Involvement_Preferences__c, Other_Involvement_Preference__c, Community_Member__c, Parent_Guardian__c, Educator_Status__c, Educator_Type__c, Organizer_Notes__c, SystemModstamp, Version__c  FROM Contact WHERE ID in:editContactsIds]);
    	
    	for ( Contact c: editContacts ) {
    		for ( Person p: this.people ) {
    			if ( p.id == c.id ) {
       				//Validate that the record has not been updated since it was retrieved
       				if (p.version != c.Version__c ) {
       					//TODO throw custom exception, contact has been updated since it was retrieved by the app
       				}
       				c.FirstName = p.first_name;
       				system.debug('*******c.FirstNameinLoop'+c.FirstName);
					c.LastName = p.last_name;
					c.MailingStreet = p.mailing_address_street;
					c.MailingCity = p.mailing_address_city;
					c.MailingState = p.mailing_address_state;
					c.MailingPostalCode = p.mailing_address_zip;
					c.npe01__HomeEmail__c = p.personal_email;
					c.npe01__Preferred_Email__c = p.preferred_email_type;
					c.npe01__WorkEmail__c = p.work_email;
					c.npe01__AlternateEmail__c = p.alternate_email;
					c.npe01__PreferredPhone__c = p.preferred_phone_type;
					c.HomePhone = p.home_phone;
					c.npe01__WorkPhone__c = p.work_phone;
					c.MobilePhone = p.mobile_phone;
					c.SMS_Status__c = p.is_sms_opted_in;
					c.Preferred_Language__c = p.preferred_language;
					c.Other_Activist_Interest__c = p.other_activist_interests;
					c.Other_Involvement_Preference__c = p.other_involvement_preferences;
					c.Parent_Guardian__c = p.is_parent;
					c.Community_Member__c = p.is_community_member;
					c.Educator_Status__c = p.educator_status;
					c.Educator_Type__c = p.educator_type;
					c.Organizer_Notes__c = p.organizer_notes;
		
					if (p.activist_interests_list != null) {
						c.Activist_Interests__c = (string.join(p.activist_interests_list, ';'));
					} else c.Activist_Interests__c = null;
			
					
					if (p.involvement_preferences_list != null) {
						c.Involvement_Preferences__c = (string.join(p.involvement_preferences_list, ';'));
					} else c.Involvement_Preferences__c = null;	
    			}
    		}
    	}
    	
    	update editContacts;
    	
    	return true;
    }
    
    public boolean changeLeader () {
    //Opperates on a PersonCollection and updates the contact records with the Leader on the loaded PC
    //The leader provided must be a leader and be on the same team as the Member
    	
    	list < string > changeLeaderContactsIds = new list < string >();
    	list < string > newLeaderContactIds = new list < string >();
    	list < string > oldLeaderIds = new list < string >();
   
   		//Fill up the ID list of members to be updated and new Leaders
   		for ( Person per:this.People) {
   			changeLeaderContactsIds.add(per.id);
   			newLeaderContactIds.add(per.membership.leader_id);
   		}
   		
   		list < Contact > changeLeaderContacts = new list < Contact > ([SELECT ID, Stand_Team_Affiliation__c, Stand_Leader__c, Membership_Status__c, Version__c  FROM Contact WHERE ID in:changeLeaderContactsIds]);
   		//load up the contact records of the new leaders so we can validate that the teams match
   		list < Contact > leaderContacts = new list < Contact > ([SELECT ID, Stand_Team_Affiliation__c, Membership_Status__c, Leader_Type__c FROM Contact WHERE Id in:newLeaderContactIds]);
    	 
    	
    	for ( Person per: this.People ) {
    		for ( Contact ldrCon: leaderContacts ) {
    			if ( per.Membership.leader_id == ldrCon.id ) {
    				//Verify that the leader is on the same team as the person, and that the leader is a Team Leader or Leader in Training
    				if ( per.Membership.team_id != ldrCon.Stand_Team_Affiliation__c) {
 	    				throw new StandException(113);
    				}
    				if ((ldrCon.Leader_Type__c != 'Leader') && (ldrCon.Leader_Type__c != 'Leader in Training')) {
     	    			throw new StandException(114);
    				}
    			}
    		}
    	}
    	
    	//IF all validations are good, assign the new leader and update old and new Leader Member Counts 
    	for ( Person p: this.People ) {
    		for ( Contact c: changeLeaderContacts ) {
    			if ( p.id == c.id ) {
    				//if there is already a leader on the record, add its ID to the list of old leaders' ids
    				if ( c.Stand_Leader__c != null ) {
    					oldLeaderIds.add(c.Stand_Leader__c);
    				}
    				//update the contact with the new leader from person
    				c.Stand_Leader__c = p.Membership.leader_id;
    			}
    		}
    	}
    	//Update the Member Counts for both the new and old leaders
    	LeaderCollection.updateLeaderMemberCounts(oldLeaderIds);
    	LeaderCollection.updateLeaderMemberCounts(newLeaderContactIds);

    	update changeLeaderContacts;
    	
    	return true;
    	
    }
    
    public boolean changeTeam ( PersonCollection changeTeamPeople ) {
    	//takes in a PersonCollection and updates the teams on matching Contacts
    	//The leader on the person must be on the same team
    	//TODO, if there is already a leader for the member, we should null it out
    	
    	list < string > changeTeamContactsIds = new list < string >();
    	list < string > LeaderContactIds = new list < string >();
    	list < string > oldTeamIds = new list < string >();
    	list < string > newTeamIds = new list < string >();
   
   		//Fill up the ID list of members to be updated, new team Ids and leaderIds
   		for ( Person per:changeTeamPeople.People) {
   			changeTeamContactsIds.add(per.id);
   			newTeamIds.add(per.Membership.team_id);
   			LeaderContactIds.add(per.Membership.leader_id);
   		}
   		
   		list < Contact > changeTeamContacts = new list < Contact > ([SELECT ID, Stand_Team_Affiliation__c, Stand_Leader__c, Membership_Status__c  FROM Contact WHERE ID in:changeTeamContactsIds]);
   		//load up the contact records of the leaders so we can validate that the teams match
   		list < Contact > leaderContacts = new list < Contact > ([SELECT ID, Stand_Team_Affiliation__c, Membership_Status__c, Leader_Type__c FROM Contact WHERE Id in:LeaderContactIds]);
    	 
    	
    	for ( Person per: changeTeamPeople.People ) {
    		for ( Contact ldrCon: leaderContacts ) {
    			if ( per.Membership.leader_id == ldrCon.id ) {
    				//Verify that the leader is on the same team as the person, and that the leader is a Team Leader or Leader in Training
    				if ( per.Membership.team_id != ldrCon.Stand_Team_Affiliation__c) {
 	    				throw new StandException(113);    				}
    			}
    		}
    	}
    	
    	//IF all validations are good, assign the new team 
    	for ( Person p: changeTeamPeople.People ) {
    		for ( Contact c: changeTeamContacts ) {
    			if ( p.id == c.id ) {
    				//if there is already a team on the record, add its ID to the list of old team' ids
    				if ( c.Stand_Team_Affiliation__c != null ) {
    					oldTeamIds.add(c.Stand_Team_Affiliation__c);
    				}
    				//update the contact with the new Team
    				c.Stand_Team_Affiliation__c = p.Membership.team_id;
    			}
    		}
    	}
    	
    	update changeTeamContacts;
    	
    	//Update the Member counts on both the new and old teams
    	TeamCollection.updateTeamsMemberCounts(newTeamIds);
    	TeamCollection.updateTeamsMemberCounts(oldTeamIds);
    	
    	return true; 
    	
    }
    
    public boolean removeLeadersFromMembers ( list < string > leader_ids ) {
    	//Removes the leaders from all members currently assigned to them
    	//this is one step in ending a leadership
    	
    	list < Contact > memberContacts = new list < Contact > ([SELECT Id, Stand_Leader__c FROM Contact WHERE Stand_Leader__c in:leader_ids ]);
    	
    	for ( Contact c:memberContacts ) {
    		c.Stand_Leader__c = null;
    	}
    	
    	update memberContacts;
    	
    	//update the Member Counts for the Leaders
    	LeaderCollection.updateLeaderMemberCounts(leader_ids);
    	
    	return true;	
    		
    }
    
    // -----------------
    // renewSustainers()
    // -----------------
    // Author: SKT
    // Date: 11/4/2013
    //
    // Design Notes:  Sustainers should never get to Lapsing or Lapsed status
    //                Therefore, we may want to consider updating membership status
    //                and use this job to move memberships forward year on year
    //
    // Inputs: none
    // Outputs: count of sustainers that were successfully renewed
    // Method takes all Sustaining members and renews them if: 
    // 1.  their renewal date is tomorrow
    // 2.  they have a membership status of Lapsing (this should be fixed)
    // 3.  membership type is sustaining
    // 4.  recurring gift status is Active (this is manually set by Membership team)
    
    // FUTURE improvements:
    // Should check for Cash or Check?  What do we do here?
    
    public integer renewSustainers () {
    	
    	List < Contact > lContacts = new List < Contact > ();
		
		// load up the contacts
		// look for active, sustainer and recurring gift status of active - with date of expiring 31 days from today (makes sure that they never go lapsing)
		
		Date dExpire = Date.Today().addDays ( 1 );
		
		lContacts = [ SELECT ID, Membership_Expiration__c FROM Contact WHERE Membership_Expiration__c =: dExpire AND Membership_Status__c = 'Active' AND Membership_Type__c = 'Sustaining' AND Recurring_Gift_Status__c = 'Active' ];
		
		System.debug ( '+++++++++++++ TOTAL CONTACT FOR UPDATE COUNT : ' + lContacts.size() );
		
		// update the contact to reflect the renewal
		// should be 365 days from last expire date
		
		// TODO add the second pass to catch lapsed sustainers
		
		Date dRenew;
		
		for ( Contact c : lContacts ) {
		
			dRenew = c.Membership_Expiration__c.addYears ( 1 ).addDays ( -1 );
			System.debug ( '+++++++++++++' + dRenew );
			
			// update the contact
			c.Last_Membership_Renewal_Date__c = dRenew;
		
			// create the membership activity log entry
			
		}
		
		// batch commit the contact updates
		update lContacts;
		
		// TODO batch write the activity log
		
		// TODO batch update counts (this is necessary because of the lapsing to active issue)
		
		// return number of updates
		return lContacts.size();
		
    }
    
    // ---------------------------
    // queueMemberRenewalEmails ()
    // ---------------------------
    // Refactored version of EmailQueuedLapsedMembers.cls (originally developed by Rob Bowen)
    //
    // Inputs: string sweep_period - 'pre30', 'pre7', 'post7', 'ondemand'
    //         pre30 - lapsing members 30 til expiration
    //         pre7 - lapsing members 7 days til expiration
    //         post7 - lapsed members 7 days after expiration
    //         ondemand - triggered on demand by a user, cannot be a dropped member and not a sustaining membership
    // Output: Number of emails queued
    // Dependencies - Custom Setting list - SET_App_Settings__c
    
	public integer queueMemberRenewalEmails ( string mode ) {
		
		integer day_range;
		string email_type;
		string email_suffix;
		string email_subject;
		
		string environment_type;
		string membership_email_bcc;
		string web_renewal_address;
		
		boolean is_production = false;
		
		// setup control variables
		if ( mode == 'pre30' ) {
			day_range = 30;
			email_type = 'MemRenewPre30';
			email_suffix = ' Lapsing Email';
			email_subject = 'Stand with Us Again';
		} else if ( mode == 'pre7' ) {
			day_range = 7;
			email_type = 'MemRenewPre7';
			email_suffix = ' Lapsing Email';
			email_subject = 'Take a Stand and Renew Now';
		} else if ( mode == 'post7' ) {
			day_range = -7;
			email_type = 'MemRenewPost7';
			email_suffix = ' Lapsed Email';
			email_subject = 'Stand with Us Again';
		} else if ( mode== 'ondemand' ) {
			email_type = 'MemRenewOnDemand';
			email_suffix = ' Single Email';
			email_subject = 'Your Membership Matters';
		} else {
			// TODO throw exception - invalid input
			return -1;
		}
		
		// load custom settings
		try {
			environment_type = SET_App_Settings__c.getValues('ENVIRONMENT_TYPE').Value__c;
			membership_email_bcc = SET_App_Settings__c.getValues('MEMBERSHIP_EMAIL_BCC').Value__c;
			web_renewal_address = SET_App_Settings__c.getValues('WEB_RENEWAL_ADDRESS').Value__c;
		} catch ( Exception e ) {
			// if we have an exception, bail out - we did not get all custom settings
			// TODO rig this into the custom exception handler
			return -1;
		}
		
		
		// check each field for something
		if ( String.ISBLANK ( environment_type ) || String.ISBLANK ( membership_email_bcc ) || String.ISBLANK ( web_renewal_address )) {
			// TODO throw exception - custom settings blank!
			return -1;
		}
		
		// set the production flag
		if ( environment_type == 'Production' ) {
			is_production = true;
		}
		
		// find which states are NOT opted out
		List <String> lStates = new List <String>();
		List <Account> lAccount = new List <Account>([SELECT Id, BillingState FROM Account WHERE Type = 'Stand Affiliate State' AND OptStateOutOfLapsedMemberEmails__c = false]);
		if ( lAccount.size() == 0 ) {
			return 0; // no opted in states, return with a 0
		} else {
			for ( Account a : lAccount ) {
				lStates.add(a.BillingState);
			}
		}
		
		// Start Processing --------------------
		
		List < Contact > members = new List < Contact > ();
		
		if ( mode == 'ondemand' ) {
			// specialized single member look up :: mode = ondemand
			members = [ SELECT Id, Membership_Expiration__c, Name, Email, Membership_State__c FROM Contact WHERE Do_Not_Contact__c = null AND Membership_Type__c != 'Sustaining' AND Email != '' ];
		} else {
			// all other mode types
			members = [ SELECT Id, Membership_Expiration__c, Name, Email, Membership_State__c FROM Contact WHERE Do_Not_Contact__c = null AND Membership_Type__c != 'Sustaining' AND Exclusions__c excludes ( 'Do Not Send Automated Membership Renewal' ) AND Email != '' AND Membership_Expiration__c = : System.today().addDays( day_range ) AND Membership_State__c IN : lStates ];
		}
		
		List <EmailQueue__c> lEmails = new List <EmailQueue__c>();
		
		Token t = new Token();
		
		// list for bulk token creation
		List <String> lObjectID = new List <String>();
		for ( Contact c : members ) {
			lObjectID.add(c.Id);
		}

		// call the bulk method
		Token.TokenCreateData TCD = new Token.TokenCreateData();
		Map <Id, Token.TokenCreateData> mTokens = new Map <Id, Token.TokenCreateData>();
		mTokens = t.bulkCreate( lObjectID, TOKEN_TYPE );
		// list of TokenIds
		List <String> tList1 = new List <String>();
		for ( Token.TokenCreateData TCD1 : mTokens.values() ) {
			if ( TCD1.Token != 'FailedCreate' ) {
				tList1.add(TCD1.TokenId);
			}
		}
		
		// map to hold the TokenId for all of the tokens in mTokens
		// ObjectId and TokenId
		Map <Id, Id> cTokens = new Map <Id, Id>();
		List <Token__c> tList = new List <Token__c>([SELECT Id, ObjectID__c FROM Token__c WHERE Id in : tList1]);
		for ( Token__c t1 : tList ) {
			cTokens.put(t1.ObjectID__c, t1.Id);
		}
		
		String mToken = '';
		Token.TokenCreateData mToken1 = new Token.TokenCreateData();
		for ( Contact c : members ) {
			// create the EmailQueue record
			EmailQueue__c e = new EmailQueue__c();
			e.Contact__c = c.id;
			e.EmailType__c = email_type;
			e.Name = c.Name + email_suffix;
			
			if ( is_production ) {
				e.To__c = c.Email;
			} else {
				e.To__c = TEST_EMAIL;
			}
			
			e.BCC__c = membership_email_bcc;
			
			e.Subject__c = email_subject;
			
			// create the token from the contact ID
			mToken1 = mTokens.get(c.Id);
			if ( mToken1.Token != '' && mToken1.Token != null ) {
				mToken = EncodingUtil.urlEncode(mToken1.Token,'UTF-8');
			} else {
				mToken = '';
			}
			
			// create the body and merge individual member personalized fields
			if ( mode == 'pre30' ) {
				e.Body__c = '<span style=\'font-size:10.0pt;font-family:"News Gothic","sans-serif";color:black\'>Dear ' + c.Name + '<br><br>Your Stand for Children membership will expire in 30 days.  <b>We urgently need you to <a href="' + web_renewal_address + HelperFunctions.abbrevToFullStatev(c.Membership_State__c) + '/renew?token=' + mToken + '">renew now</a>.</b><br><br>Because of members like you, we are able to continue our critical work for children. Together, we’re building an empowered, united voice to transform the unacceptable status quo in our public schools. Joining together as parents, educators and community members, we’re fighting for real change for our students, including:<br><br><ul><li>Effective leadership at every school and great teachers in every classroom for every student</li><li>High quality school options accessible to every child</li><li>High quality early childhood and pre-K programs for every child</li><li>Budget transparency and dollars being used in the best interest of students in each school</li><li>Teacher evaluations that provide quality feedback on performance and the support they need to be highly effective</li></ul>We have a unique opportunity to change the educational outcomes for an entire generation of students across this country.<br><br><b>Please <a href="' + web_renewal_address + HelperFunctions.abbrevToFullStatev(c.Membership_State__c) + '/renew?token=' + mToken + '">renew your membership now</a>.</b><br><br>Thank you for your continued support.<br><br>Standing with You,<br><br><br>Simone Coker-Kamna<br>National Membership Coordinator<br><br><i>Your membership contribution is not tax-deductible. For more information or for questions about your membership, call us at (503) 308-7292 or email <a href="mailto:membership@stand.org">membership@stand.org</a>.</i>';
			}
			
			if ( mode == 'pre7' ) {
				e.Body__c = '<span style=\'font-size:10.0pt;font-family:"News Gothic","sans-serif";color:black\'>Dear ' + c.Name + '<br><br>I’m writing again to notify you that your Stand for Children membership will expire in 7 days.  <b>We urgently need you to <a href="' + web_renewal_address + HelperFunctions.abbrevToFullStatev(c.Membership_State__c) + '/renew?token=' + mToken + '">renew now</a>!</b><br><br>Your membership is a crucial piece to the puzzle of expanding educational opportunities for students across the country. We believe that with the unified, empowered voice of parents, educators and community members, we can change the outcomes for an entire generation of kids. Like you, we believe in equitable access to education, with our nation’s cities filled with vibrant, high-performing schools. We advocate for changes that allow educators to do their best so that students can reach their highest potential.<br><br><b>We can’t do it without you.</b><br><br><b>Please <a href="' + web_renewal_address + HelperFunctions.abbrevToFullStatev(c.Membership_State__c) + '/renew?token=' + mToken + '">renew your membership now</a>.</b><br><br>Your continued support makes a difference. Thank you for joining us again.<br><br>Standing with You,<br><br><br>Simone Coker-Kamna<br>National Membership Coordinator<br><br><i>Your membership contribution is not tax-deductible. For more information or for questions about your membership, call us at (503) 308-7292 or email <a href="mailto:membership@stand.org">membership@stand.org</a>.</i>';
			}
			
			if ( mode == 'post7' ) {
				e.Body__c = '<span style=\'font-size:10.0pt;font-family:"News Gothic","sans-serif";color:black\'>Dear ' + c.Name + '<br><br>Your Stand for Children membership has now expired.  <b><a href="' + web_renewal_address + HelperFunctions.abbrevToFullStatev(c.Membership_State__c) + '/renew?token=' + mToken + '">Renew your membership now</a>.</b><br><br>Your support over the past year resulted in tremendous gains in education for students across the country. We trained over 400 parents last semester to become more involved in their child\'s academics. We empowered thousands more to lobby at the district and state level in support of better public schools.  Alongside our members, we’ve fought tirelessly for policies that improve education for <b>every child</b> in <b>every classroom.</b><br><br><b>You play an important role in this work - please <a href="' + web_renewal_address + HelperFunctions.abbrevToFullStatev(c.Membership_State__c) + '/renew?token=' + mToken + '">renew your membership now</a>.</b><br><br>Together we can have a unified voice that will change the landscape of education for an entire generation of students. Thank you for your continued support.<br><br>Standing with You,<br><br><br>Simone Coker-Kamna<br>National Membership Coordinator<br><br><i>Your membership contribution is not tax-deductible. For more information or for questions about your membership, call us at (503) 308-7292 or email <a href="mailto:membership@stand.org">membership@stand.org</a>.</i>';
			}
			
			if ( mode == 'ondemand' ) {
				e.Body__c = '<span style=\'font-size:10.0pt;font-family:"News Gothic","sans-serif";color:black\'>Dear ' + c.Name + '<br><br>It\'s time to renew your Stand for Children membership.  <b><a href="' + web_renewal_address + HelperFunctions.abbrevToFullStatev(c.Membership_State__c) + '/renew?token=' + mToken + '">Renew your membership now</a>.</b><br><br>Your support over the past year resulted in tremendous gains in education for students across the country. We trained over 400 parents last semester to become more involved in their child\'s academics. We empowered thousands more to lobby at the district and state level in support of better public schools. Alongside our members, we’ve fought tirelessly for policies that improve education for <b>every child</b> in <b>every classroom.</b><br><br><b>You play an important role in this work - please <a href="' + web_renewal_address + HelperFunctions.abbrevToFullStatev(c.Membership_State__c) + '/renew?token=' + mToken + '">renew your membership now</a>.</b><br><br>Together we can have a unified voice that will change the landscape of education for an entire generation of students. Thank you for your continued support.<br><br>Standing with You,<br><br><br>Simone Coker-Kamna<br>National Membership Coordinator<br><br><i>Your membership contribution is not tax-deductible. For more information or for questions about your membership, call us at (503) 308-7292 or email <a href="mailto:membership@stand.org">membership@stand.org</a>.</i>';		
			}
			
			e.Token__c = cTokens.get(c.Id);
			
			if ( mToken != '' ) {
				lEmails.add(e);
			}
		}
		
		// insert emails into the queue object
		try {
			insert lEmails;
		} catch ( System.Exception ex ) {
			System.debug('============Unable to insert EmailQueue records=================');
			System.debug('Error Type: ' + ex.getTypeName() + ' Message: ' + ex.getMessage());
			System.debug(System.now());
			System.debug('===============================================================');
		}
		
		// return the number of emails queued
		return lEmails.size();
				
	}
	


}