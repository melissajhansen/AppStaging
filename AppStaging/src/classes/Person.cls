global with sharing class Person {
	//Must be Global, contains global classes used by web services
    
    public string			id;
    public string           account_id;
    public string  		 	first_name;
    public string  		 	last_name;
    public string   		mailing_address_street;
    public string   		mailing_address_city;
    public string   		mailing_address_state;
    public string   		mailing_address_zip;
    public string   		personal_email;
    public string   		preferred_email_type;
    public string   		work_email;
    public string   		alternate_email;
    public string   		preferred_phone_type;
    public string   		home_phone;
    public string   		work_phone;
    public string   		mobile_phone;
    public boolean			is_sms_opted_in = false;
    public string   		preferred_language;
    public string   		other_activist_interests;
    public string  			other_involvement_preferences;
    public boolean 			is_parent = false;
    public boolean  		is_community_member = false;
    public string   		educator_status;
    public string   		educator_type;
    public string   		organizer_notes;
    public datetime			last_modified_date;  
    public integer			sortorder;
    public decimal			version;
    public list < string > 	activist_interests_list;
    public list < string > 	involvement_preferences_list;
    
    public Membership		membership;
    public Leadership		leadership;
    
    
    public class Membership {
    	public string	person_id;
    	public string	membership_state;
    	public string	team_id;
		public string	leader_id;
		public string	organizer_id;
		public string 	membership_type;
		public string 	membership_status;
		public date		membership_expiration_date;
		public date		membership_start_date;
		public date		last_membership_renewal_date;
		public date		membership_quit_date;
		public double 	gift_amount =0;
		public double	lifetime_membership_gift_amount;
		public date 	gift_date;
		public string	gift_stage;
		public string	gift_frequency;
		public string	gift_pay_type;
		public double	average_annual_membership_gift_amount;
		public string	notes;
		
		
		public boolean create (Person newMember, CCInterface ccInfo) {
			//Takes a Person object as argument and CCInterface.  Authorizes the Financial transaction and creates Membership information on the matching Contact
			//Contact must exist, and  cannot allready have a membership
			
			//Load up contact record to join, validate 
			Contact newMemberRecord = ([SELECT id, Membership_Start_Date__c, Membership_Type__c, Membership_Status__c, Stand_Team_Affiliation__c, Organizer__c, Stand_Leader__c, version__c FROM Contact WHERE ID =:newMember.id]);
			list < Contact > leaderRecord = new list < Contact > ([SELECT ID, Stand_Team_Affiliation__c FROM Contact WHERE id =:newMember.Membership.leader_id ]);			
			string userState = ([SELECT Primary_State_Office__c from USER where id=: UserInfo.getUserId()].Primary_State_Office__c);
			String donationId;
			
			DateTime dT = System.now();
			Date d = date.newinstance(dT.Year(),dT.month(),dT.day());
		
			//Check for required Fields
			if ((newMember.membership.membership_type == null) || (newMember.membership.gift_amount == null) || (newMember.membership.team_id == null)) {
				throw new StandException(116); 
			}
			
			//Validate that the record has not been updated since it was retrieved
			if ( newMember.version != newMemberRecord.version__c ) {
				throw new StandException(300);
			}
			
			//If there is a leader, Validate that the member's leader matches their team
			if (leaderRecord.size()==1 ) {
				if ( newMember.Membership.team_id != leaderRecord[0].Stand_Team_Affiliation__c ) {
				throw new StandException(100);
				}
			}
						
			//Validate that the Contact Record is elligible for join
			if ((newMemberRecord.Membership_Start_Date__c != null) || (newMemberRecord.Membership_Type__c != null) || ( (newMemberRecord.Membership_Status__c != null) && (newMemberRecord.Membership_Status__c != 'Dropped'))) {
				throw new StandException(101);
			}

			//we have a winner.  Make him or her a member
			//First, run the CC Transaction.  if it fails, it will throw an exception
			//Can't use a Savepoint in conjuction with a callout
			CCInterface cc = new CCInterface();
			cc = ccInfo;
			ccInfo.authorize();
		
			newMemberRecord.Membership_Start_Date__c = d;
			newMemberRecord.Membership_Type__c = newMember.Membership.membership_type;
			newMemberRecord.Stand_Team_Affiliation__c = newMember.Membership.team_id;
			newMemberRecord.Membership_State__c = userState;
			//if they were dropped before, we clear out the Quit Date
			newMemberRecord.Membership_Quit_Date__c = null;
			//Leader may be blank
			if (newMember.Membership.leader_id != null ) {
				newMemberRecord.Stand_Leader__c = newMember.Membership.leader_id;
				//update the memberCOunt for the leader
			}
										
			try {
				update newMemberRecord;
			} catch (DMLException e) {
				throw new StandException(307);
				return false;
			} 
			
			
			//update Counts for team/leader/Organizer
			MemHelper.updateTallies (newMember.Membership.leader_id, 'Leader');
			MemHelper.updateTallies (newMember.Membership.team_id, 'Team');
			
			//Log the join
			//TODO:  Is it possible for CCInterface to pass back the order ID, or some other info that we can use to retreive the correct Opportunity...
			ActivityLogEntry a = new ActivityLogEntry(this.person_id, this.organizer_id, this.leader_id, this.team_id, '', 'MEMBER-JOIN', 'Membership Join', true);
			a.create();

			return true;
			
		}
		
		public boolean joinCashCheck (Person newMember, string payType) {
			//Takes a Person object as argument and , creates Membership information on the matching Contact and generates a pending opportunity
			//Used for Cash & Check transactions
			//Contact must exist, and  cannot already have a membership

			//Load up contact record to join, validate 
			
			Contact newMemberRecord = ([SELECT id, AccountID, Membership_Start_Date__c, Membership_Type__c, Membership_Status__c, Stand_Team_Affiliation__c, Organizer__c, Stand_Leader__c, version__c, Membership_State__c, FirstName, LastName FROM Contact WHERE ID =:newMember.id]);
			string contactName = newMemberRecord.firstName + ' ' + newMemberRecord.lastName;
			list < Contact > leaderRecord = new list < Contact > ([SELECT ID, Stand_Team_Affiliation__c FROM Contact WHERE id =:newMember.Membership.leader_id ]);			
			string userState = ([SELECT Primary_State_Office__c from USER where id=: UserInfo.getUserId()].Primary_State_Office__c);
			DateTime dT = System.now();
			Date d = date.newinstance(dT.Year(),dT.month(),dT.day());
			Id donationId;
		
			system.debug('*****************************************PersonMemType'+newMember.membership.membership_type);
			//Check for required Fields
			if ((newMember.membership.membership_type == null) || (newMember.membership.gift_amount == null) || (newMember.membership.team_id == null)) {
				throw new StandException(116); 
				return false;
			}
			//Validate that the record has not been updated since it was retrieved
			if ( newMember.version != newMemberRecord.version__c ) {
				throw new StandException(300);
			}
			
			//If there is a leader, Validate that the member's leader matches their team
			if (leaderRecord.size()==1 ) {
				if ( newMember.Membership.team_id != leaderRecord[0].Stand_Team_Affiliation__c ) {
				throw new StandException(100);
				}
			}
						
			//Validate that the Contact Record is elligible for join
			if ((newMemberRecord.Membership_Start_Date__c != null) || (newMemberRecord.Membership_Type__c != null) || ( (newMemberRecord.Membership_Status__c != null) && (newMemberRecord.Membership_Status__c != 'Dropped'))) {
				throw new StandException(101);
			}

			//we have a winner.  Make him or her a member
			newMemberRecord.Membership_Start_Date__c = d;
			newMemberRecord.Membership_Type__c = newMember.Membership.membership_type;
			newMemberRecord.Stand_Team_Affiliation__c = newMember.Membership.team_id;
			newMemberRecord.Stand_Leader__c = newMember.Membership.leader_id;
			//if they were dropped before, we clear out the Quit Date
			newMemberRecord.Membership_Quit_Date__c = null;
			
			//Insert a donation for the Join
			donationId = createDonation(payType, 'Join');
			
			//update the record
			try {
				update newMemberRecord;
			} catch (DMLException e){
				throw new StandException(320);
			}
			
			//update tallies
			MemHelper.updateTallies (newMember.Membership.leader_id, 'Leader');
			MemHelper.updateTallies (newMember.Membership.team_id, 'Team');

			ActivityLogEntry a = new ActivityLogEntry(this.person_id, this.organizer_id, this.leader_id, this.team_id, donationId, 'MEMBER-JOIN', 'Membership Join', true);
			a.create();
			return true;
			
		}
		
		public boolean renewCC (Person renewMember, CCInterface ccInfo) {
			//Takes a Person object as argument and CCInterface.  Authorizes the Financial transaction and renews Membership information on the matching Contact
			
			DateTime dT = System.now();
			Date d = date.newinstance(dT.Year(),dT.month(),dT.day());
			string oldTeamId;
			string oldLeaderId;
			//Pull up the contact record to be updated, load fields to update and/or validate			
			Contact contact_record = ([SELECT id, Membership_Start_Date__c, Last_Membership_Renewal_Date__c, Membership_Type__c, Stand_Team_Affiliation__c, Stand_Leader__c, Membership_status__c, version__c FROM Contact WHERE ID =:renewMember.id]);
			
			//Check for required Fields
			if ((renewMember.membership.membership_type == null) || (renewMember.membership.gift_amount == null) || (renewMember.membership.team_id == null)) {
				throw new StandException(116); 
			}
			
			//Validate that the record has not been updated since it was retrieved
			if ( renewMember.version != contact_record.version__c ) {
				throw new StandException(300);
			}
			
			//Pull up the contact record for the Leader to validate the team matches
			list < Contact > leaderlist = new list < Contact > ([SELECT ID, Stand_Team_Affiliation__c FROM Contact WHERE id =:renewMember.Membership.leader_id ]);
			//Validate that the member's leader matches their team
			if ( leaderlist.size() == 1) {
				if ( renewMember.Membership.team_id != leaderlist[0].Stand_Team_Affiliation__c ) {
				throw new StandException(100);
				}
			}
			
						
			//Validate that the Contact Record is elligible for renewal
			if ((contact_record.Membership_Start_Date__c == null) || (contact_record.Membership_Type__c == null) || (contact_record.Membership_Status__c == null)) {
				throw new StandException(102);
			}
			
			//Membership Gift must be $5 or More
			if ((gift_amount < 5)) {
				throw new StandException(103);
			}
		
			//otherwise, we have a winner!
			//First, run the CC Transaction.  if it fails, we throw an exception, nothing has yet been committed
			//Can't use a Savepoint in conjuction with a callout

			//If successful to this point, we now run the CC Transaction
			CCInterface cc = new CCInterface();
			cc = ccInfo;
		
			cc.authorize();
			//Now commit the renewal
				
			//Update counts for old leader/organizer
			oldTeamId = contact_record.stand_team_affiliation__c;
			oldLeaderId = contact_record.Stand_Leader__c;
			
			//make updates
			contact_record.Last_Membership_Renewal_Date__c = d;
			contact_record.Membership_Type__c = renewMember.Membership.membership_type;
			contact_record.Stand_Team_Affiliation__c = renewMember.Membership.team_id;
			//leader can be null
			if (renewMember.Membership.leader_id != null) {
				contact_record.Stand_Leader__c = renewMember.Membership.leader_id;
			} else {
				contact_record.Stand_Leader__c = null;
			}

			update contact_record;
			
			//Update Counts for the new & old Leader/Organizer
			MemHelper.updateTallies(renewMember.Membership.leader_id, 'Leader');
			MemHelper.updateTallies(oldLeaderId, 'Leader');
			MemHelper.updateTallies(renewMember.Membership.team_id, 'Team');
			MemHelper.updateTallies(oldTeamId, 'Team');

			//TODO:  Is it possible for CCInterface to pass back the order ID, or some other info that we can use to retreive the correct Opportunity...
			ActivityLogEntry a = new ActivityLogEntry(this.person_id, this.organizer_id, this.leader_id, this.team_id, '', 'MEMBER-RENEW', 'Membership Renewal', true);
			a.create();

			return true;
		
		}
		
		public boolean renewCashCheck (Person renewMember, string payType) {
			//Takes a person record and payment type, validates and processes a renewal and pending opportunity for cash and check gifts
			
			DateTime dT = System.now();
			Date d = date.newinstance(dT.Year(),dT.month(),dT.day());
			string oldTeamId;
			string oldLeaderId;
			string accountId;
			id donationId;
			
			//Check for required Fields
			if ((renewMember.membership.membership_type == null) || (renewMember.membership.gift_amount == null) || (renewMember.membership.team_id == null)) {
				throw new StandException(116); 
			}			
			
			//Pull up the contact record to be updated, load fields to update and/or validate			
			Contact contact_record = ([SELECT id, firstName, lastName, AccountID, Membership_Start_Date__c, Last_Membership_Renewal_Date__c, Membership_Type__c, Stand_Team_Affiliation__c, Stand_Leader__c, Membership_status__c, version__c FROM Contact WHERE ID =:renewMember.id]);
			string contactName = contact_record.firstName + ' ' + contact_record.lastName;
			
			//Validate that the record has not been updated since it was retrieved
			if ( renewMember.version != contact_record.version__c ) {
				throw new StandException(300);
			}
			
			//Pull up the contact record for the Leader to validate the team matches
			list < Contact > leaderlist = new list < Contact > ([SELECT ID, Stand_Team_Affiliation__c FROM Contact WHERE id =:renewMember.Membership.leader_id ]);
			//Validate that the member's leader matches their team
			if ( leaderlist.size() == 1) {
				if ( renewMember.Membership.team_id != leaderlist[0].Stand_Team_Affiliation__c ) {
				throw new StandException(100);
				}
			}
						
			//Validate that the Contact Record is elligible for renewal
			if ((contact_record.Membership_Start_Date__c == null) || (contact_record.Membership_Type__c == null) || (contact_record.Membership_Status__c == null)) {
				throw new StandException(102);
			}
			
			//Validate that the Gift Amount is $5 or more
			if (gift_amount < 5) {
				throw new StandException(103);
			}
			
			//otherwise, we have a winner!
			oldTeamId = contact_record.Membership_Type__c;
			oldLeaderId = contact_record.Stand_Leader__c;
			contact_record.Last_Membership_Renewal_Date__c = d;
			contact_record.Membership_Type__c = renewMember.Membership.membership_type;
			contact_record.Stand_Team_Affiliation__c = renewMember.Membership.team_id;
			contact_record.Stand_Leader__c = renewMember.Membership.leader_id;
	
			//Update the record
			update contact_record;
			
			//Insert the Opportunity
			donationId = createDonation(payType, 'Renew');

			MemHelper.updateTallies (renewMember.Membership.leader_id, 'Leader');
			MemHelper.updateTallies (renewMember.Membership.team_id, 'Team');

			//Insert an Activity Log Entry
			 ActivityLogEntry alog = new ActivityLogEntry(this.person_id, this.organizer_id, this.leader_id, this.team_id, donationId, 'MEMBER-RENEW', 'Membership Renewal', true);
			 alog.create();
			
			return true;
			
		}
		
		public boolean quit (Person quitMember) {
			//Takes in a Person as arguement and returns true if person's membership is quit
			//Must have an active membership to quit.  If they are a leader, their leadership will be ended
			DateTime dT = System.now();
			string oldTeamId;
			string oldLeaderId;
			//Load the Contact Record to be updated
			Contact contact_record = ([SELECT id, Membership_Start_Date__c, Membership_State__c, Last_Membership_Renewal_Date__c, Membership_Type__c, Membership_Status__c, Stand_Team_Affiliation__c, Stand_Leader__c,Membership_Quit_Date__c, Leader_Type__c, Membership_Expiration__c, version__c FROM Contact WHERE ID =:quitMember.id]);
			
			//Validate that the record has not been updated since it was retrieved
			if ( quitMember.version != contact_record.version__c ) {
				throw new StandException(300);
			}
			
			//Validate that the contact record has a membership that can be quit
			if ((contact_record.Membership_Start_Date__c == null) || (contact_record.Membership_Type__c == null) || (contact_record.Membership_Status__c == null) || (contact_record.Membership_Status__c == 'Dropped')) {
				throw new StandException(105);
			}
			//If the member is also a leader, must end their leadership first
			if ((contact_record.Leader_Type__c == 'Leader') || (contact_record.Leader_Type__c == 'Leader in Training')) {
				Leader ldr = new Leader();
				ldr.getById(contact_record.id);
				
				ldr.endLeadership();
			}
			
			
			//We have a quitter!
			//Capture team/leader info before update
			oldTeamId = contact_record.stand_team_affiliation__c;
			oldLeaderId= contact_record.Stand_Leader__c;
			
			//update record and commit
			contact_record.Membership_Quit_Date__c = date.newinstance(dT.Year(),dT.month(),dT.day());
			contact_record.Membership_Start_Date__c = null;
			contact_record.Membership_Type__c = null;
			contact_record.Stand_Team_Affiliation__c = null;
			contact_record.Stand_Leader__c = null;
			contact_record.Last_Membership_Renewal_Date__c = null;
			contact_record.Membership_State__c = null;
			update contact_record;
			
			//Update Team/Leader Tallies 
			MemHelper.updateTallies(oldTeamId, 'Team');
			MemHelper.updateTallies(oldLeaderId, 'Leader');
			
			ActivityLogEntry alog = new ActivityLogEntry (this.person_id, '', oldLeaderid, oldTeamId, '', 'MEMBER-DROP', 'Membership Dropped', False);
			alog.create();

			return true;
			
		}
		
		
		public boolean changeTeam (Person updatedPerson) {
	    	
	    	string oldTeamId;
	  		
	  		Contact changeTeamContact = ([SELECT ID, Stand_Team_Affiliation__c, Stand_Leader__c, Membership_Status__c  FROM Contact WHERE ID =:updatedPerson.Membership.person_id]);
	   		//load up the contact record of the leader so we can validate that the teams match
	   		system.debug('*****************LeaderID on instantiated Person'+this.leader_id);
	   		list < Contact > leaderContact = new list < Contact > ([SELECT ID, Stand_Team_Affiliation__c, Membership_Status__c, Leader_Type__c FROM Contact WHERE Id =:updatedPerson.Membership.leader_id]);
	    	system.debug('*****************LeaderID on Contact'+changeTeamContact.Stand_Leader__c);
	    	 
			//Verify that the leader, if there eis one, is on the same team as the person
			if ( leaderContact.size() == 1  ){
				if ( leaderContact[0].Stand_Team_Affiliation__c != updatedPerson.Membership.team_id ) {
					throw new StandException(100);
				}
			}
			
	  		//If all validations are good,
	
	    	//Save Old teamid For updating Tallies & make updates
			oldTeamId = changeTeamContact.Stand_Team_Affiliation__c;
			changeTeamContact.Stand_Team_Affiliation__c = updatedPerson.Membership.team_id;
	    	update changeTeamContact;
	    	
	    	//Finally, check to see if the member needs their leader updated (no update needed if leader was null and continues to be null)
	   		if (updatedPerson.Membership.leader_id != changeTeamContact.Stand_Leader__c ) {
	   			this.changeLeader(updatedPerson);
	   		}
	    	
	    	//Update the Member counts on both the new and old teams
	    	memHelper.updateTallies(oldTeamId, 'Team');
	    	memHelper.updateTallies(updatedPerson.Membership.team_id, 'Team');

	    	ActivityLogEntry alog = new ActivityLogEntry (this.person_id, '', '', oldTeamId, '', 'TEAM-LEFT', 'Left this Team', False);
			alog.create();

			ActivityLogEntry alog2 = new ActivityLogEntry (this.person_id, '', '', updatedPerson.Membership.team_id, '', 'TEAM-JOIN', 'Joined this Team', False);
			alog2.create();
    	
	    	return true;
	    	
	    }
	    
	    public boolean changeLeader (Person updatedPerson) {
	    	string oldLeaderId;

	    	Contact changeLeaderContact = ([SELECT ID, Stand_Leader__c, Stand_Team_Affiliation__c FROM Contact WHERE ID =:updatedPerson.Membership.person_id]);
	    	
	    	//Validate that the new Leader, if there is one, is on the same team as the member
	    	if ((updatedPerson.Membership.leader_id != null) &&(updatedPerson.Membership.team_id != changeLeaderContact.Stand_Team_Affiliation__c)){
	    		throw new StandException(100);
	    	}
	    	
	    	//save the old leader id, and update the leader value on the contact
	    	if ( changeLeaderContact.Stand_Leader__c != null ) {
	    		//update member counts for the old leader
	    		oldLeaderid = changeLeaderContact.Stand_Leader__c;
	    	}
	    	
	    	if ( updatedPerson.Membership.leader_id != null ) {
	    		changeLeaderContact.Stand_Leader__c = updatedPerson.Membership.leader_id;
	    	} 
	    	else {
	    		changeLeaderContact.Stand_Leader__c = null;
	    	}
	    	
	    	update changeLeaderContact;
	    	
	    	//Update Leader & Team Tallies
			MemHelper.updateTallies(OldLeaderId, 'Leader');
			MemHelper.updateTallies(updatedPerson.Membership.leader_id, 'Leader');

	    	ActivityLogEntry alog = new ActivityLogEntry (this.person_id, '', OldLeaderId, '', '', 'LEADER-UNASSIGNED', 'Unassigned from this Leader', False);
			alog.create();

			ActivityLogEntry alog2 = new ActivityLogEntry (this.person_id, '', updatedPerson.Membership.leader_id, '', '', 'LEADER-ASSIGNED', 'Assigned to this Leader', False);
			alog2.create();

	    	return true;    	
	    	
	    }
	    
	    public boolean updateNotes (Person notesPerson) {
	    	Contact notesContact = ([SELECT ID, Membership_Notes__c FROM Contact WHERE ID =:notesPerson.Membership.person_id]);
	    	
	    	notesContact.Membership_Notes__c = notesPerson.Membership.notes;
	    	
	    	update notesContact;
	    	
	    	return true;
	    	
    	}

    	public id createDonation (String payType, String transactionType) {
			DateTime dTime = System.now();
			Date dt = date.newinstance(dTime.Year(),dTime.month(),dTime.day());
			String thisYear = HelperFunctions.YearHelper();
			String state = this.membership_state;
			Id id;
			
			Contact c = ([SELECT AccountId, Name FROM Contact WHERE id = :this.person_id]);
			RecordType rt = ([SELECT Id from RecordType where Name = 'Membership Donation' and SobjectType = 'Opportunity' LIMIT 1 ]);
			List < Campaign > camp = ([SELECT Id from Campaign where Name =: state + ' Membership' + ' ' + thisYear]);

			Donation d = new Donation();
			d.account_id = c.AccountId;
			d.name = c.Name + ' Membership Gift';
			d.giver_type = 'Individual';
			d.amount = this.gift_amount;
			d.stage = 'Pending';
			d.close_date = dt;
			d.entity = 'Stand for Children, Inc. (C4)';
			d.fund = 'Membership';
			d.community = HelperFunctions.abbrevToFullStatev(state) + ' General';
			d.team = this.team_id;
			d.organizer = this.organizer_id;
			d.leader = this.leader_id;
			d.state = this.membership_state;
			d.transaction_type = transactionType;
			if (camp.size() == 1) {
				d.campaign = camp[0].id;
			}
			d.fiscal_year = 'FY' + ' ' + thisYear;
			d.record_type = rt.id;
			d.pay_method = payType;

			try {
				d.create();
				return d.id;
			} catch (Exception e) {
				throw new StandException(118);
			}
	
		}
    	
    
    }
    
    
    public class Leadership {
    	public string	person_id;
		public string 	leader_type;	//'Team Leader', 'Leader in Training', 'Former Leader'
		public integer 	member_count;	
		public integer	active_member_count;
		public integer	lapsed_member_count;
		public integer 	lapsing_member_count;
		public date 	lit_start_date; 
		public date 	lit_stop_date;
		public date 	leader_start_date; 
		public date 	leader_stop_date;
    }
    
    public Person () {
        //default constructor
    }
    
    

    public boolean getByID ( string person_id ) {
        //Returns true if a Contact matching the id passed in exists.  Instantiates a Person with the values on the contact record
                
        list < Contact > personList = new list < Contact > ([SELECT ID, AccountId, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, npe01__HomeEmail__c, npe01__WorkEmail__c, npe01__AlternateEmail__c, npe01__Preferred_Email__c, HomePhone, MobilePhone, npe01__WorkPhone__c, npe01__PreferredPhone__c, SMS_Status__c, Preferred_Language__c, Activist_Interests__c, Other_Activist_Interest__c, Involvement_Preferences__c, Other_Involvement_Preference__c, Community_Member__c, Parent_Guardian__c, Educator_Status__c, Educator_Type__c, Organizer_Notes__c, Version__C, SystemModstamp  FROM Contact WHERE ID=: person_id LIMIT 1 ]);
        //TODO, Custom Exception Handling if no contact is found
        
		this.id = personList[0].Id;
		this.account_id = personList[0].AccountId;
		this.first_name = personList[0].FirstName;
		this.last_name = personList[0].LastName;
		this.mailing_address_street = personList[0].MailingStreet;
		this.mailing_address_city = personList[0].MailingCity;
		this.mailing_address_state = personList[0].MailingState;
		this.mailing_address_zip = 	personList[0].MailingPostalCode;
		this.personal_email = personList[0].npe01__HomeEmail__c;
		this.preferred_email_type = personList[0].npe01__Preferred_Email__c;
		this.work_email = personList[0].npe01__WorkEmail__c;
		this.alternate_email = personList[0].npe01__AlternateEmail__c;
		this.preferred_phone_type = personList[0].npe01__PreferredPhone__c;
		this.home_phone = personList[0].HomePhone;
		this.work_phone = personList[0].npe01__WorkPhone__c;
		this.mobile_phone = personList[0].MobilePhone;
		this.is_sms_opted_in = Boolean.ValueOf(personList[0].SMS_Status__c);
		this.preferred_language = personList[0].Preferred_Language__c;
		this.other_activist_interests = personList[0].Other_Activist_Interest__c;
		this.other_involvement_preferences = personList[0].Other_Involvement_Preference__c;
		this.is_parent = Boolean.ValueOf(personList[0].Parent_Guardian__c);
		this.is_community_member = Boolean.ValueOf(personList[0].Community_Member__c);
		this.educator_status = personList[0].Educator_Status__c;
		this.educator_type = personList[0].Educator_Type__c;
		this.organizer_notes = personList[0].Organizer_Notes__c; 
		this.last_modified_date = personList[0].SystemModstamp;
		this.version = personList[0].Version__c;
		this.sortorder = 1;
		//Load up Membership information, may be null
		Membership mship = new Membership(); 
		this.membership = getMembership(person_id);
		//Load up Leadership information, may be null
		Leadership lship = new Leadership();
		this.leadership = getLeadership(person_id);
		
		//Activist Interests and Involvement Preferences are MultiSelect Picklist that is split out into a list of strings
		//handling here for empty fields which should set the person field to null
		if (string.isNotEmpty(personList[0].Activist_Interests__c)) {
			this.activist_interests_list = HelperFunctions.MultiSelectToList(personList[0].Activist_Interests__c);
		} else this.activist_interests_list = null;
		
		if (string.isNotEmpty(personList[0].Involvement_Preferences__c)) {
			this.involvement_preferences_list = HelperFunctions.MultiSelectToList(personList[0].Involvement_Preferences__c);
		} else this.involvement_preferences_list = null;

		return true;
    }
    		
		private Membership getMembership (string ContactId) {
			//Returns the membership information from a Contact Record matching the passed in id, returns as a Membership object	
			list < Contact > personList = new list < Contact > ([SELECT Membership_State__c, Stand_Team_Affiliation__c, Stand_Leader__c, Stand_Team_Organizer__c, Membership_Type__c, Membership_Status__c, Membership_Start_Date__c, Last_Membership_Renewal_Date__c, Last_Membership_Gift_Amount__c, Lifetime_Membership_Giving__c, Last_Membership_Gift_Date__c, Average_Annual_Membership_Gift_Amount__c, Membership_Expiration__c FROM Contact WHERE ID =:contactId LIMIT 1]);
		
			Membership mem= new Membership();
			
			mem.person_id = 							personList[0].Id;
			mem.membership_state =						personList[0].Membership_State__c;
			mem.team_id = 								personList[0].Stand_Team_Affiliation__c;
			mem.leader_id = 							personList[0].Stand_Leader__c;
			mem.organizer_id = 							personList[0].Stand_Team_Organizer__C;
			mem.membership_type = 						personList[0].Membership_Type__c;
			mem.membership_status = 					personList[0].Membership_Status__c;
			mem.membership_start_date = 				personList[0].Membership_Start_Date__c;
			mem.last_membership_renewal_date = 			personList[0].Last_Membership_Renewal_Date__c;
			mem.gift_amount = 							HelperFunctions.doubleValueOfDecimal(personList[0].Last_Membership_Gift_Amount__c);
			mem.lifetime_membership_gift_amount = 		HelperFunctions.doubleValueOfDecimal(personList[0].Lifetime_Membership_Giving__c);
			mem.gift_date = 							personList[0].Last_Membership_Gift_Date__c;
			mem.average_annual_membership_gift_amount = HelperFunctions.doubleValueOfDecimal(personList[0].Average_Annual_Membership_Gift_Amount__c);
			mem.membership_expiration_date = 			personList[0].Membership_Expiration__c;
		
			return mem;
			
		}
		
		private Leadership getLeadership (string ContactId) {
			//Returns the leadership information from a Contact Record matching the passed in id, returns as a Leadership object	
			list < Contact > personList = new list < Contact > ([SELECT Leader_Type__c, Name, Member_Count__c, Active_Member_Count__c, Lapsed_Member_Count__c, Lapsing_Member_Count__c, LiT_Start_Date__c, LiT_Stop_Date__c, Leader_Start_Date__c, Leader_Stop_Date__c FROM Contact WHERE ID=: ContactId LIMIT 1]);
			
			Leadership lead = new Leadership();
			lead.person_id = 			personList[0].Id;
			lead.leader_type = 			personList[0].Leader_Type__c;
			lead.member_count = 		HelperFunctions.trueIntegerValueOf(personList[0].Member_Count__c);
			lead.active_member_count =	HelperFunctions.trueIntegerValueOf(personList[0].Active_Member_Count__c);
			lead.lapsed_member_count =	HelperFunctions.trueIntegerValueOf(personList[0].Lapsed_Member_Count__c);
			lead.lapsing_member_count =	HelperFunctions.trueIntegerValueOf(personList[0].Lapsing_Member_Count__c);
			lead.lit_start_date = 		personList[0].LiT_Start_Date__c;
			lead.lit_stop_date = 		personList[0].LiT_Stop_Date__c;
			lead.leader_start_date = 	personList[0].Leader_Start_Date__c;
			lead.leader_stop_date = 	personList[0].Leader_Stop_Date__c;	
			
			return lead;
		}
		
		
	global Boolean create () {
			//Must be Global, called by web services
			//Takes a Person object as argument and inserts a new Contact Record with the information from the Person
			//Returns that Person including the id from the newly inserted Contact Record
			Contact newContact = new Contact();
			string userState = ([SELECT Primary_State_Office__c from USER where id=: UserInfo.getUserId()].Primary_State_Office__c);
			
			//set incoming fields
			newContact.FirstName = this.first_name;
			newContact.LastName = this.last_name;
			newContact.MailingStreet = this.mailing_address_street;
			newContact.MailingCity = this.mailing_address_city;
			newContact.MailingState = this.mailing_address_state;
			newContact.MailingPostalCode = this.mailing_address_zip;
			newContact.npe01__HomeEmail__c = this.personal_email;
			newContact.npe01__Preferred_Email__c = this.preferred_email_type;
			newContact.npe01__WorkEmail__c = this.work_email;
			newContact.npe01__AlternateEmail__c = this.alternate_email;
			newContact.npe01__PreferredPhone__c = this.preferred_phone_type;
			newContact.HomePhone = this.home_phone;
			newContact.npe01__WorkPhone__c = this.work_phone;
			newContact.MobilePhone = this.mobile_phone;
			newContact.Preferred_Language__c = this.preferred_language;
			newContact.Other_Activist_Interest__c = this.other_activist_interests;
			newContact.Other_Involvement_Preference__c = this.other_involvement_preferences;
			newContact.Educator_Status__c = this.educator_status;
			newContact.Educator_Type__c = this.educator_type;
			newContact.Organizer_Notes__c = this.organizer_notes;
			//For boolean fields and Picklists, check for a value before setting
			if (this.is_sms_opted_in != null ) {
				newContact.SMS_Status__c = this.is_sms_opted_in;
			}
			if (this.is_parent != null ) {
				newContact.Parent_Guardian__c = this.is_parent;
			}
			if (this.is_community_member != null ) {
				newContact.Community_Member__c = this.is_community_member;
			}
			if (this.activist_interests_list != null) {
				newContact.Activist_Interests__c = (string.join(this.activist_interests_list, ';'));
			}

			if (this.involvement_preferences_list != null) {
				newContact.Involvement_Preferences__c = (string.join(this.involvement_preferences_list, ';'));
			}
			//set required fields
			newContact.Acquired_By__c = 'C4 Acquired'; //TODO, this should be dynamic
			newContact.LeadSource = 'Organizer App'; //TODO, this should be dynamic
			newContact.Stand_Office__c = userState;
			
			insert newContact;
			
			//assign id to person object
			this.getByID(newContact.id);
			
			return true;
			
		}
		
		
		global Boolean edit () {
			//Must be Global, called by web services
			//Takes in a Person object and updates the Contact Record that matches.  Returns the Person
			Contact updateContact =([SELECT ID, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingPostalCode, npe01__HomeEmail__c, npe01__WorkEmail__c, npe01__AlternateEmail__c, npe01__Preferred_Email__c, HomePhone, MobilePhone, npe01__WorkPhone__c, npe01__PreferredPhone__c, SMS_Status__c, Preferred_Language__c, Activist_Interests__c, Other_Activist_Interest__c, Involvement_Preferences__c, Other_Involvement_Preference__c, Community_Member__c, Parent_Guardian__c, Educator_Status__c, Educator_Type__c, Organizer_Notes__c, Version__c, SystemModstamp  FROM Contact WHERE ID=: this.id LIMIT 1 ]);
			
			//Validate that the record has not been updated since it was retrieved
			if ( updateContact.Version__c != this.version ) {
				throw new StandException(300);
			}
			
			//set incoming fields
			updateContact.FirstName = this.first_name;
			updateContact.LastName = this.last_name;
			updateContact.MailingStreet = this.mailing_address_street;
			updateContact.MailingCity = this.mailing_address_city;
			updateContact.MailingState = this.mailing_address_state;
			updateContact.MailingPostalCode = this.mailing_address_zip;
			updateContact.npe01__HomeEmail__c = this.personal_email;
			updateContact.npe01__Preferred_Email__c = this.preferred_email_type;
			updateContact.npe01__WorkEmail__c = this.work_email;
			updateContact.npe01__AlternateEmail__c = this.alternate_email;
			updateContact.npe01__PreferredPhone__c = this.preferred_phone_type;
			updateContact.HomePhone = this.home_phone;
			updateContact.npe01__WorkPhone__c = this.work_phone;
			updateContact.MobilePhone = this.mobile_phone;
			updateContact.Preferred_Language__c = this.preferred_language;
			updateContact.Other_Activist_Interest__c = this.other_activist_interests;
			updateContact.Other_Involvement_Preference__c = this.other_involvement_preferences;
			updateContact.Educator_Status__c = this.educator_status;
			updateContact.Educator_Type__c = this.educator_type;
			updateContact.Organizer_Notes__c = this.organizer_notes;
			//For boolean fields and Picklists, check for a value before setting
			if (this.is_sms_opted_in != null ) {
				updateContact.SMS_Status__c = this.is_sms_opted_in;
			}
			if (this.is_parent != null ) {
				updateContact.Parent_Guardian__c = this.is_parent;
			}
			if (this.is_community_member != null ) {
				updateContact.Community_Member__c = this.is_community_member;
			}
			if (this.activist_interests_list != null) {
				updateContact.Activist_Interests__c = (string.join(this.activist_interests_list, ';'));
			} else updateContact.Activist_Interests__c = null;
			if (this.involvement_preferences_list != null) {
				updateContact.Involvement_Preferences__c = (string.join(this.involvement_preferences_list, ';'));
			} else updateContact.Involvement_Preferences__c = null;
			
			update updateContact;
			
			//load the updated contact so that a full person is instantiated
			this.getByID(this.id);
			
			return true;
		}
		
	public static boolean removeLeaderFromMembers (string leaderId) {
		//takes in a single leader id, removes them from all their assigned Members
		list < Contact > memberContacts = new list < Contact > ([SELECT Id, Stand_Leader__c FROM Contact WHERE Stand_Leader__c =:leaderId]);
		
		for ( Contact c:memberContacts ) {
    		c.Stand_Leader__c = null;
    	}
    	update memberContacts;
    	
    	//update Members counts for the leader
   		MemHelper.updateTallies(leaderId, 'Leader');

   		//TODO: Bulk ActivityLogEntries
    	
    	return true;
		
	}


	//The following are for testing purposes, they always return the type of exception indicated 
	public void throwDmlException() {
		Contact c = new Contact ();
        insert c;
	}
	
	public void throwStandException() {
		throw new StandException(100);
	}
	
	public void otherException () {
		Contact c = ([SELECT ID from Contact WHERE id =:'blah']);
	}
	


}