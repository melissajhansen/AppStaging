public class MembershipAutomation {
	// bool to indicate if we are in an date override situation (see PreInsertUpdate() for setting)
	private Boolean mDateOverride;
	
	public MembershipAutomation () {
		mDateOverride = false;
	}
	
	// stores the calculated date to use for membership transactions
	private Date mDate;
	
	// SKT 6/7/2012
	// Membership Automation
	// General controller class for automating membership activities
	// Impacts the following objects:
	// * Membership
	// * Contact
	// * Affiliation
	// * Relationship
	// * Opportunity (and payment)
	
	// SKT 6/13/2012
	// Branched from ScottDev into NewModel
	// Adding support for Date automation override - aka Backdating capabilities
	
	public boolean ValidationRules ( Membership__c m, Membership__c mOld, String triggerType) {
		
		// SKT 7/15/2012
		// Validation rule to check if we have more than one membership
		// Had to add a check to make sure that we're not pulling back the current Membership - (case of error in entering a membership)
		List < Membership__c > membershipList = new List < Membership__c > ([ SELECT ID, Contact__r.Name FROM Membership__c WHERE Contact__c = : m.Contact__c AND ID <> : m.ID ] );
		if ( membershipList.size() > 0 ) {
			// we already have a membership - do not allow this new membership to be saved
			m.AddError ( 'You cannot add more than one Membership to a contact.  Please click <a href=\'\\' + membershipList[0].ID + '\'>here</a> to view ' + membershipList[0].Contact__r.Name + '\'s Membership Record');
			return false;
		}
		
		// MP 12/3/2012
		// Validation rule to make sure the Actions Edit/Renew/Drop are not used when creating a new membership
		if ((triggerType == 'Insert') && (( m.Membership_Action__c == 'Edit' ) || ( m.Membership_Action__c == 'Renew' ) || (m.Membership_Action__c == 'Drop'))) {
			// A new membership is being created - do not allow Memberhsip action to be Edit, Renew or Drop
			m.AddError ( 'You are creating a membership for this contact.  Please change the Membership Action to be Join.');
			return false;
		}
		
		// MP 12/3/2012
		// Validation rule to make sure the Action Join can only be used when creating a new membership
		if ((triggerType == 'Update') && (m.Membership_Action__c == 'Join')) {
			// An existing membership is being updated - do not allow Memberhsip action to be Join
			m.AddError ( 'You are editing an existing membership for this contact.  The membership Action cannot be join.');
			return false;
			
		}
				
		// MP 12/6/2012
		// Validation rule to make sure the amount can only be changed when processing a Join or Renew
		if ((triggerType == 'Update') && ((m.Membership_Action__c == 'Edit') || (m.Membership_Action__c == 'Join') || (m.Membership_Action__c == 'Drop'))) {
			if (m.Gift_Amount__c != mOld.Gift_Amount__c) {
			// Don't allow gift amount to be changed if not a Renewal
			m.AddError ( 'You may not enter a gift amount unless you are processing a Join or Renewal.  If you need to change the gift amount from a previous Join or Renewal, please contact Program Support.');
			return false;
			}
		}
		
		// MP 2/27/13
		// Validation rule to not allow Renewals with a Complimentary Membership Type
		if ((triggerType == 'Update') && (m.Membership_Action__c == 'Renew') && (m.Type__c == 'Complimentary')) {
			// An existing membership is being updated - do not allow Memberhsip action to be Join
			m.AddError ( 'Beginning March 1, Renewals must be for Annual or Sustaining Memberships.');
			return false;
		}
					 
		// SKT 7/15/2012
		// Team Leader rule
		// If Team Leader is being turned off (ie. Contact was a team leader and is now no longer one)
		// there cannot be any followers
		// MP 4/2/13- Updating so that this rule only evalutates on Edit/Delete and checks if the Leader box was checked and has now been unchecked
		
		// Also need to check for Membership Record being deleted here - prevent that
		String followerList = '';
		if ( (triggerType == 'Update' || triggerType == 'Delete') && (m.Team_Leader__c == false && mOld.Team_Leader__c == true)) {
			// load Contacts that are followers of this current membership contact
			List < npe5__Affiliation__c > followers = new List < npe5__Affiliation__c > ( [ SELECT npe5__Contact__r.Name FROM npe5__Affiliation__c WHERE Team_Leader__c = : m.Contact__c AND npe5__Status__c = 'Active' ]);
			if ( followers.size() > 0 ) {
				// build a string of followers for error display
				for ( npe5__Affiliation__c c : followers) {
					if ( followerList == '' ) {
						followerList = c.npe5__Contact__r.Name;
					} else {
						followerList = followerList + ', ' + c.npe5__Contact__r.Name;
					}
				}
				// return the error
				m.AddError ( 'To remove this Member as a Leader, please remove them as the Team Leader for the following contacts: ' + followerList );
				return false;
			}
				
		}
		
		// Check for Field Level Validation Rules
		// 1.  All Joins and Renews must have a Type defined if not sourced from the Web
		if ((m.Membership_Source__c != 'Web' ) && ( m.Type__c == null ) && (( m.Membership_Action__c == 'Join' ) || ( m.Membership_Action__c == 'Renew' ))) {
			m.AddError( 'Please select a Membership Type when entering a Membership ' + m.Membership_Action__c );
			return false;
		} else if ((m.Membership_Source__c == null ) && (( m.Membership_Action__c == 'Join' ) || ( m.Membership_Action__c == 'Renew' ))) {
			// SKT 11/12/2012 - need to check for System Flag - Sustaining Auto Renew Case
			// There is a problem where memberships in the system do not have Membership Sources - so in the case
			// of Auto Renew we do not want the validation rule to trigger.
			
			if ( m.Auto_System_Flag__c == false ) {
				// 2.  All Joins and Renews must have a Membership Source
				m.AddError( 'Please select a Membership Source when entering a Membership ' + m.Membership_Action__c );
				return false;
			}
		} 
		
		// MP 2/27/13
		// Validation rule to require a gift of 5 or more with an Annual Membership
		if ((m.Type__c == 'Annual') && (( m.Membership_Action__c == 'Join' ) || ( m.Membership_Action__c == 'Renew' )) && (( m.Gift_Amount__c < 5.00 ) || ( m.Gift_Amount__c == null ))) {
			// 3.  For Join or Renew of an Annual membership, Gift Amount must be > 5.00 and not null
			m.AddError( 'The minimum '+ m.Type__c + ' Membership Donation is $5.' );
			return false;
		}
		// MP 2/27/13
		// Validation rule to reequire a gift of 5 or more with a sustaining Membership.
		if ((m.Type__c == 'Sustaining') && (( m.Membership_Action__c == 'Join' ) || ( m.Membership_Action__c == 'Renew' )) && (( m.Gift_Amount__c < 5.00 ) || ( m.Gift_Amount__c == null ))) {
			// 3.  For Join or Renew of a Sustaining membership, Gift Amount must be > 5.00 and not null
			m.AddError( 'The minimum '+ m.Type__c + ' Membership Donation is $5/month.' );
			return false;
		}
		
		return true;
	}
	
	// main controller to be called from the Before Trigger section
	// handles execution of automation rules fired from the Membership object
	public boolean PreInsertUpdate ( Membership__c m, Membership__c mOld ) {
		// Clear out Trigger control fields
		m.Auto_Opportunity_ID__c = null;
		m.Auto_Task_Id__c = null;
		m.Auto_Date__c = null;
				
		// set the start or quit date automation 
		// 6/12/2012
		// Requirement to prevent backdating of Membership records
		DateTime dt = System.now ();
		// 8/7/2012 SKT
		// use the Auto Date field for all future date recording
		m.Auto_Date__c = date.newInstance ( dt.year(), dt.month(), dt.day() );
		
		// 6/13/2012
		// Auto Date Override - do not allow the system to automatically set dates
		if ( m.Auto_Date_Override__c != null ) {
			m.Auto_Date__c = m.Auto_Date_Override__c;
			mDateOverride = true;
			m.Auto_Date_Override__c = null;
		}
		
		// set the membership date field, manage post processing flag and process gifts as needed
		if ( m.Membership_Action__c == 'Join' ) {
			// 8/3/12 SKT
			// Fix problem where Start Date was being updated for a Renewal
			// Membership Start Date should only be updated in a Join transaction
			m.start_date__c = m.Auto_Date__c;
			
			// Flag for post trigger processing
			m.Auto_Task_Id__c = m.Membership_Action__c;
			
			// Write the Opp ID (for PostJoin work)
			m.Auto_Opportunity_Id__c = this.AddGift ( m );
		}
		
		// SKT 10/28/12 - added support for Sustainer Automated Renewal case
		
		// set the membership date field, manage post processing flag and process gifts as needed
		if ( m.Membership_Action__c == 'Renew') {
			
			if ( m.Auto_System_Flag__c == true ) {
				// Flag for post trigger processing
				// SKT 10/28/12 - use Auto Renew flag for Renew + Auto_System_Flag checked = Sustainer Renew case
				m.Auto_Task_Id__c = 'Auto Renew';
			} else {
			
				// Flag for post trigger processing
				m.Auto_Task_Id__c = m.Membership_Action__c;
			
				// Write the Opp ID (for PostJoin work)
				m.Auto_Opportunity_Id__c = this.AddGift ( m );
			}
		}
		
		if ( m.Membership_Action__c == 'Drop' ) {
			m.quit_date__c = m.Auto_Date__c;
			m.Auto_Task_Id__c = m.Membership_Action__c;
		}
		
		// Clear the Action flag
		// SKT 10/28/12 - reset the System Flag
		m.Membership_Action__c = '';
		m.Auto_System_Flag__c = false; 
		return true;
	}
	
	// Execute updates that require all IDs to be set (after insert/update)
	public boolean PostInsertUpdate ( Membership__c m, Membership__c mOld ) {
		// 6/19
		// SKT - changed this to use the Membership_Activity object
		if ( m.Auto_Task_Id__c == 'Join' ) {
			// create a Join Membership_Activity
			AddTask ( m, 'Membership Join', m.Auto_Date__c );
		}
		
		if ( m.Auto_Task_Id__c == 'Renew' ) {
			// create a renew Membership_Activity
			AddTask ( m, 'Membership Renewal', m.Auto_Date__c );
		}
		
		if ( m.Auto_Task_Id__c == 'Auto Renew' ) {
			// SKT 10/28/12
			// Adding handler for Automated Renewal process
			// create an Automated Renewal Membership_Activity
			// Date the task a day ahead so the new expiration date accounts for the -1 day offset run of the time-based workflow
			AddTask ( m, 'Membership Auto Renewal', m.Auto_Date__c + 1 );
		}
		
		// SKT 7/14/2012
		// clean up the contact record ( membership state, membership type )
		// this replaces logic formerly in ContactAffiliationIntegration
		Contact c = [ SELECT AccountId, Membership_State__c, Membership_Type__c FROM Contact WHERE Id =: m.Contact__c ];
		c.Membership_State__c = m.Membership_State__c;
		c.Membership_Type__c = m.Type__c;
		
		update c;
		
		// 10/29/2012 SKT - moving set affiliations after contact update 
		// to fix problem with assigning leaders while entering new memberships
		
		// set affiliations
		this.SetAffiliations ( m, mOld );
		
		// Update the opportunity with the newly saved ID
		if ( m.Auto_Opportunity_ID__c != null ) {
			Opportunity o = [ SELECT Id FROM Opportunity WHERE Id =: m.Auto_Opportunity_Id__c ];
			o.accountId = c.AccountId;
			update o;
		}
		
		return true;
	}
	
	// Execute updates to related contact record to manage a Membership Delete
	public boolean PreDelete ( Membership__c m ) {
		
		Date endAffDate = Date.today();
		
		// disable affiliations
		if ( m.Stand_Team__c != null ) {
			if ( m.Team_Leader__c ) {
				// disable a team leader affiliation
				this.DisableAffiliation ( m, m.Contact__c, m.Stand_Team__c, endAffDate, 'Leader' );
			} else {
				// disable a team member affiliation
				this.DisableAffiliation ( m, m.Contact__c, m.Stand_Team__c, endAffDate, 'Team' );
			}
		}
		
		// clean up the contact record ( membership state, membership type )
		// this replaces logic formerly in ContactAffiliationIntegration
		Contact c = [ SELECT AccountId, Membership_State__c, Membership_Type__c FROM Contact WHERE Id =: m.Contact__c ];
		c.Membership_State__c = null;
		c.Membership_Type__c = null;
		
		return true;
	}

	//Public method to generate a Renewal Membership Activity, currently only to process a renewal from the web
	//Works for singles only.  NOT BULKIFIED!  
	//TO DO: This could be merged with a more fleshed out version of AddTask, but holding off for now to reduce risk and anticipating possible Mem automation Overhaul
	public void WebRenewActivity (ID MemberID) {
		Date tDate = System.TODAY();
		
		//Instantiate the activity
		Membership_Activity__c mActivity = new Membership_Activity__c ();
		
		//Set Default Values
		mActivity.Membership__c = MemberID;
		mActivity.Start_Date__c = tDate;
		mActivity.Source__c = 'Web';
		mActivity.Subject__c = 'Membership Renewal';
		insert mActivity;
		
		//Update the Source field on the Membership to match
		Membership__c m = [SELECT ID, Membership_Source__c FROM Membership__c WHERE ID =: MemberID];
		m.Membership_Source__c = mActivity.Source__c;
		update m;
		  
	}

	private boolean SetAffiliations ( Membership__c m, Membership__c mOld ) {
		// Date calcuation rules
		// If there is an action (Join/Renew), use the Automation Date on the membership object
		// If there is an action (Drop), use the Quit Date
		// If there is no action (this should be Edit), assume the date as today (so we get the most accurate date stamps possible)
		// 6/13 - support for date override
		Date affDate;
		Date endAffDate;
		
		affDate = m.Auto_Date__c;
		
		// SKT 7/2/2012
		// Adding rule that original Aff End date needs to be a day before
		// the new date
		if ( m.Auto_Task_id__c != 'Drop' ) {
			endAffDate = affDate.addDays( -1 ); // calc the date -1
		} else {
			endAffDate = affDate;
		}
		
		// Disable Old Team affiliations
		if ( mOld != null ) { 
			// evaluate if the Team, Is Team Leader or Leader fields have changed from an original value
			Boolean teamChange = ( m.Stand_Team__c != mOld.Stand_Team__c );
			Boolean hadTeam = ( mOld.Stand_Team__c != null );
			Boolean IsTeamLeaderChange = ( m.Team_Leader__c != mOld.Team_Leader__c );
			Boolean LeaderChange = ( m.Leader__c != mOld.Leader__c );
			
			if ( hadTeam && ( teamChange || IsTeamLeaderChange || LeaderChange )) {
				// Here we had a team associated to the membership, and something has changed
				// need to disable an old affiliation
				// evaluate the original Is Team Leader value to determine which type of affiliation to disable
				if ( mOld.Team_Leader__c == true ) {
					this.DisableAffiliation ( m, mOld.Contact__c, mOld.Stand_Team__c, endAffDate, 'Leader' );
				} else {
					this.DisableAffiliation ( m, mOld.Contact__c, mOld.Stand_Team__c, endAffDate, 'Team' );
				}
			} 
		}
		
		// if drop, inactivate the affiliations
		if ( m.Auto_Task_id__c == 'Drop' ) {
			this.DisableAffiliation( m, m.Contact__c, m.Stand_Team__c,  endAffDate, 'Team' );
		}
		
		// Add the updated affiliation
		if ( m.Auto_Task_id__c != 'Drop' ) {
			if ( m.Team_Leader__c == true ) {
				// add a Team Leader affiliation
				this.AddAffiliation ( m, m.Contact__c, m.Stand_Team__c, m.Leader__c, affDate, 'Leader' );
			} else {
				// add a Team Member affiliation
				this.AddAffiliation ( m, m.Contact__c, m.Stand_Team__c, m.Leader__c, affDate, 'Team' );
			}
		}
		
		return true;
	}
	
	// SKT 6/2/2012 -----
	// AddAffiliation - private helper function.  Adds a new Affiliation and returns true
	
	private boolean AddAffiliation ( Membership__c m, Id c, Id a, Id leader, Date dt, String AddType ) {
		string typeString = '';
		string affiliationString = '';
		
		// check for required fields
		if (( c == null ) || ( a == null ) || ( AddType == null )) {
			return false;
		}
		
		if ( AddType == 'Team' ) {
			typeString = 'Organizing';
			affiliationString = 'Team Member';
		}
		
		if ( AddType == 'Leader' ) {
			typeString = 'Organizing';
			affiliationString = 'Team Leader';
		}
		
		List < npe5__Affiliation__c > affList = [ SELECT ID FROM npe5__Affiliation__c 
										  		  WHERE npe5__Contact__c =: c AND npe5__Organization__c =: a 
										  		  AND Type__c =: typeString AND Affiliation__c =: affiliationString
										  		  AND npe5__Status__c = 'Active' ];	
		
		if ( affList.size() == 0 ) {
			// build the  Affiliation Record
			npe5__Affiliation__c aff = new npe5__Affiliation__c ();
			aff.npe5__Contact__c = c;
			aff.npe5__Organization__c = a;
			aff.npe5__StartDate__c = dt;
			aff.npe5__Status__c = 'Active';
			aff.Team_Leader__c = leader;
			aff.Type__c = typeString;
			aff.Affiliation__c = affiliationString;
			try {
				insert aff;
			} catch ( Exception e ) {
				m.AddError ( 'Could not save Membership due to a problem setting a Team Affiliation - please contact Program Support if you have questions.  System Error = [ ' + e.getMessage() + ' ]' );
			}
			
			return true;
		}
	

		return true;
	}
	
	private boolean DisableAffiliation ( Membership__c m, Id c, Id a, Date dt, String DisableType ) {
		string affiliationString = '';
		
		// check for required fields
		if (( c == null ) || ( a == null ) || ( DisableType == null )) {
			return false;
		}
		
		// SKT 7/2/2012
		// Removing TypeString = 'Organizing' since old affiliations may not have
		// this value set
		if ( DisableType == 'Team' ) {
			affiliationString = 'Team Member';
		}
		
		if ( DisableType == 'Leader' ) {
			affiliationString = 'Team Leader';
		}
		
		List < npe5__Affiliation__c > affList = [ SELECT ID FROM npe5__Affiliation__c 
										  		  WHERE npe5__Contact__c =: c AND npe5__Organization__c =: a 
										  		  AND Affiliation__c =: affiliationString 
										  		  AND npe5__Status__c = 'Active' ];	
		
		for ( npe5__Affiliation__c aff : affList ) {
			aff.npe5__Status__c = 'Inactive';
			aff.npe5__EndDate__c = dt;
		}
		
		try {
			update affList;
		} catch ( Exception e ) {
			m.AddError ( 'Could not save Membership due to a problem setting a Team Affiliation - please contact Program Support if you have questions' );
		}
		
		return true;
	}
	
	// 8/7/2012 - SKT
	// Fixing date problem with Renewals
	private Id AddTask ( membership__c m, string subject, Date startDate ) {
		// 6/19/2012
		// SKT - changed this from Activities to custom Membership Activity Object
		
		Membership_Activity__c ma = new Membership_Activity__c ();
		ma.Membership__c = m.id;
		ma.Start_Date__c = startDate;
		ma.Subject__c = subject;
		ma.Contact__c = m.Contact__c;
		//ma.Source__c = m.Membership_Source__c;
		
		insert ma;
		
		return ma.id;
		
	} 
	
	// private method to help calculate the current Year for Gift Naming purposes
	private string YearHelper ( boolean bCodeOnly ) {
		Date dCurrent = Date.today ();
		String sYear = String.valueOf ( dCurrent.year () );
		
		if ( bCodeOnly ) {
			return sYear.right ( 2 );
		} else {
			return sYear;
		}
	}
	
	private Id AddGift ( Membership__c m ) {
		// Add a related Gift - if Membership Type = Annual or Sustaining or Complimentary
		// If the source is web and it's not a renewal, do not add a gift
		if ((( m.Type__c == 'Annual' ) || ( m.Type__c == 'Sustaining' )) && (m.Membership_Source__c != 'Web' || m.Membership_Action__c == 'Renew')){
		
			Opportunity o = new Opportunity();
			// Load Contact Info 
			Contact c = [ SELECT id, firstName, lastName FROM Contact WHERE Id =: m.Contact__c ];
			
			// TODO - consider tying the campaigns to the state, chapter or team level
			string campaign_action = '';
			if ( m.Membership_Action__c == 'Join' ) {
				campaign_action = 'New';
			} else {
				campaign_action = 'Renewal';
			}
			
			string campaign_source = m.Membership_State__c + ' MEMBERSHIP ' + this.YearHelper ( false ) + ' ' + m.Membership_Source__c + ' ' + campaign_action;
			
			List < Campaign > cList = [ SELECT Id FROM Campaign WHERE Name =: campaign_source ];
			if ( cList.size() > 1 ) {
				// found a matching campaign
				o.campaignId = cList[0].Campaign_ID__c;
			}
			
			o.Name = c.firstName + ' ' + c.lastName + ' ' + campaign_source;
			o.Giver_Type__c = 'Individual';
			
			o.amount = m.Gift_Amount__c;
			o.StageName = 'Pending';
			o.CloseDate = m.Auto_Date__c;
			if ( m.Type__c == 'Sustaining' ) {
				o.Type = 'Recurring Gift';
			}
			
			o.Entity_Committed__c = 'Stand for Children, Inc. (C4)';
			o.Fund_Committed__c = 'Membership';
			o.Community_Committed__c = '';  // TODO - consider putting Community code at the team/chapter state levels
			o.Fiscal_Year_Designation__c = 'FY' + this.YearHelper( true );
			
			// set the record type to Simple Donation
			o.RecordType = [ select Id from RecordType where Name = 'Simple Donation' and SobjectType = 'Opportunity' ];
			insert o;
			
			OpportunityContactRole ocr = new OpportunityContactRole();
			ocr.ContactId = m.Contact__c;
			ocr.OpportunityId = o.id;
			ocr.Role = 'Donor';
			insert ocr;
			
			return o.id;
		}
		
		return null;
	}
	
}