// EXAMPLE
/*
  
ActivityLogEntry a = new ActivityLogEntry ();
a.contact = '003L000000FsQSz';
a.opportunity = '006L0000003fNkz';
a.entry_type = 'TEAM-START';
a.action = 'Start Team';
a.outcome = 'Complete';
a.chatter_post = true;
a.create ();


*/
// END EXAMPLE

//  Activity Log must be consistent - enforced via this class

public with sharing class ActivityLogEntry {
	
	// TODO - Add Custom Setting to supress all Chatter posts - this will be used for conversion
	public ID account_id;
	public ID campaign_id;
	public ID contact_id;
	public ID related_contact_1;
	public ID related_contact_2;
	
	// --- new to be implemented
	public ID organizer_id;
	public ID leader_id;
	public ID team_id;
	// -- end new
	
	public ID opportunity_id;
	public string entry_type;
	public string action;
	public string outcome;
	public boolean chatter_postable;
	public datetime entry_date_time;
	
	private List < String > valid_log_entry_types;
	private ID activity_log_entry_id;
	
	// init routine - required by constructors
	private void init () {
		valid_log_entry_types = new List <string> ( );
		
		// ORGANIZING MODEL ACTIVITIES
		// TODO Make this custom setting with Type Key and Chatter Postability
		
		valid_log_entry_types.add ( 'MEMBER-JOIN' );  // New Membership ( Team, Leader, Organizer, Contact (member), Membership Gift )
		valid_log_entry_types.add ( 'MEMBER-RENEW' );  // Membership Renewal ( Team, Leader, Organizer, Contact (member), Membership Gift )
		valid_log_entry_types.add ( 'MEMBER-LAPSE' );  // Membership Lapsed ( Team, Leader, Organizer, Contact (member) )
		valid_log_entry_types.add ( 'MEMBER-DROP' );   // Membership Dropped ( Team, Leader, Organizer, Contact (member) )

		//building what is essentially a data warehouse file here is starting to feel super heavy and I'm not convinced that it's necessary.  Are we really going to go to this as historical data
		//when we acquire a BI/Warehouse tool?  will it be useable??
		
		valid_log_entry_types.add ( 'ORG-AFF-START' );   // Affiliation Started ( Team, Leader, Organizer, Contact (member) )
		valid_log_entry_types.add ( 'ORG-AFF-END' );     // Affiliation Started ( Team, Leader, Organizer, Contact (member) )
		
		// default fields
		
		if ( chatter_postable == null ) {
			chatter_postable = false;
		}
		
		activity_log_entry_id = null;
	}
	
	// basic constructor
	public ActivityLogEntry () {
		init();
	}
	
	// overloaded constructor with quick setup
	public ActivityLogEntry ( ID account, ID campaign, ID contact, ID related_contact_1, ID related_contact_2, ID organizer, ID leader, ID team, ID opportunity, String entry_type, String action, String outcome, Boolean post_chatter ) {
		this.account_id = account;
		this.campaign_id = campaign;
		this.contact_id = contact;
		this.related_contact_1 = related_contact_1;
		this.related_contact_2 = related_contact_2;
		this.organizer_id= organizer;
		this.leader_id= leader;
		this.team_id= team;
		this.opportunity_id = opportunity;
		this.entry_type = entry_type;
		this.action = action;
		this.outcome = outcome;
		this.chatter_postable = post_chatter;
		init();
	}

	//overloaded constructor for Membership Activities
	public ActivityLogEntry (ID contact, ID organizer, ID leader, ID team, ID opportunity, String entry_type, String action, Boolean post_chatter) {
		this.contact_id = contact;
		this.organizer_id= organizer;
		this.leader_id= leader;
		this.team_id= team;
		this.opportunity_id = opportunity;
		this.entry_type = entry_type;
		this.action = action;
		this.chatter_postable = post_chatter;
		init();
	}
	
	
	// TODO create a bulk version of this (see Bulk cases)
	// Note: Chatter component relies on the fact that the actual User is initiating this transaction
	
	public boolean create ( ) {
		
		// check for type exceptions  ??what does that mean
		system.debug('***************************************At least were in the Create Method');
		
		// create the activity log entry
		Activity_Log__c al = new Activity_Log__c ();
		al.Account__c = account_id;
		al.Campaign__c = campaign_id;
		al.Contact__c = contact_id;
		al.Leader__c = (leader_id!='' ? leader_id : null);
		al.Organizer__c = (organizer_id!='' ? organizer_id : null);
		al.Team__c = (team_id!='' ? team_id : null);
		al.Related_Contact_1__c = related_contact_1;
		al.Related_Contact_2__c = related_contact_2;

		al.Opportunity__c = (opportunity_id!='' ? opportunity_id : null);
		al.Type__c = entry_type;
		al.Action__c = action;
		al.Outcome__c = outcome;
		al.User__c = UserInfo.getUserId();
		
		// insert the new record
		try {
			insert al;
		} catch (exception e) {
			system.debug('***************************************Entered the catch');
			throw new StandException(119);
		}
		
		activity_log_entry_id = al.Id;
		
		// whoa - chatter post
		// note: no account, campaign supported
		if ( chatter_postable ) {
			chatterHandler ( );
			
		}
		
		return true;
	}
	
	private boolean chatterHandler ( ) {
		
		string chatter_body;
		string chatter_taglist;
		string baseUrl = string.ValueOf(URL.getSalesforceBaseURL().toExternalForm());
		Account team = ([SELECT Name FROM Account WHERE Id =:this.team_id]);
		string team_name = team.name;
		
		if ( this.entry_type == 'MEMBER-JOIN' ) {
			chatter_body = 'New Member on the ' + team_name +'!';
			chatter_taglist = '#' + team_name.replaceAll('\\s+', '') + ' #' + this.action.replaceAll('\\s+', '');
			return createChatterPost ( this.contact_id , chatter_body, chatter_taglist, baseUrl +'/' + this.activity_log_entry_id , 'view log entry' );
		} else if (this.entry_type == 'MEMBER-RENEW') {
			chatter_body = 'Renewed Member on the ' + team_name +'!';
			chatter_taglist = '#' + team_name.replaceAll('\\s+', '') + ' #' + this.action.replaceAll('\\s+', '');
			return createChatterPost ( this.contact_id , chatter_body, chatter_taglist, baseUrl +'/' + this.activity_log_entry_id , 'view log entry' );
		} 
		
		return false;
	}
	
	private boolean createChatterPost ( ID obj_id, string body, string tag_list, string link_url, string link_title ) {
		
		FeedItem post = new FeedItem();
		post.ParentId = obj_id;
		post.Body = body + '\r\n\r\n' + '{ ' + tag_list + ' }';
		post.LinkUrl = link_url;
		post.Title = link_title;
		
		insert post;
		
		return true;
		
	}
}