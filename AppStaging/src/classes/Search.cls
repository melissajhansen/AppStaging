// Common Usage
// -------------
// 1.  Standard search ( Search.find )
//
// List < String > st = new List < String > ();
// st.add ('t');
//
// Search s = new Search ();
// s.find ( 'tes*', '*', 10 );
// 
// ------
//
// 2.  Recent Items ( Search.recent_items )
//     Note: this relies on the user account executing the transaction

// Search s = new Search ();
// s.recent_items ();
//
// -------------

public with sharing class Search {
	
	// Search Limits for Recents
	private static integer RECENT_RESULT_LIMIT = 7;
		
	public with sharing class Search_Result {
		
		public string id;
		public string name;
		public string city;
		public string state;
		public string obj_type;
		
		public Search_Result () {
			
		}
		
		public void create ( string id, string obj_type, string name, string city, string state ) {
			this.id = id;
			this.name = name;
			this.city = city;
			this.state = state;
			this.obj_type = obj_type;
		}
		
	}
		
	public list < Search_Result > results;
	
	private void init () {
		results = new list < Search_Result > ();
	}
	
	public Search () {
		init ();
	}

	public void find ( String key, String search_type, integer result_count ) {
		
		boolean search_person = false;
		boolean search_team = false;
		
		// process inputs
		if ( search_type == 'person' ) {
			search_person = true;
			search_team = false;
		}
		
		if ( search_type == 'team' ) {
			search_person = false;
			search_team = true;
		}

		if ( search_type == '*' ) {
			search_person = true;
			search_team = true;
		}		
		
				
		// TODO check that key is greater than 1 char
		// TODO check that result_count is valid
		
		// execute the search
		
		List < List < sObject >> l = new List < List < sObject >> ();
		l = [ FIND :key IN NAME FIELDS RETURNING Contact ( Id, Name ORDER BY Name ASC LIMIT :result_count ), Account ( Id, Name WHERE Type = 'Stand Team' ORDER BY Name ASC LIMIT :result_count ) ];

		account a;
		contact c;
		List < contact > cl = new List < contact > ();
		List < account > al = new List < account > ();
		
		// filter the objects by type
		for ( List < sObject > slist : l ) {
			system.debug ( slist.size() );
			for ( sObject o : slist ) {
				if (( o.getsObjectType() == Contact.sObjectType ) && ( search_person )) {
					c = ( Contact ) o;
					system.debug ( c.name );
					cl.add ( c );
				}
				if (( o.getsObjectType() == Account.sObjectType ) && ( search_team )) {
					a = ( Account ) o;
					system.debug ( a.name );
					al.add ( a );
				}
			}
		}
		
		Search_Result sr;
		
		while (( cl.size () > 0 ) || ( al.size () > 0 )) {
			// loops until both lists are empty
			if (( cl.size() > 0 ) && ( al.size () > 0 )) {
				// both lists have a value to compare
				if ( cl[ 0 ].name <= al[ 0 ].name ) {
					// contact is lowest
					sr = new Search_Result ();
					sr.create ( cl [ 0 ].id, 'person', cl [ 0 ].name, '','' );
					results.add ( sr );
					cl.remove ( 0 );
				} else {
					// account is lowest
					sr = new Search_Result ();
					sr.create ( al [ 0 ].id, 'team', al [ 0 ].name, '','' );
					results.add ( sr );
					al.remove ( 0 );
				}
			}
			// only contact list?
			if (( cl.size () > 0 ) && ( al.size () == 0 )) {
				// contact is moved
				sr = new Search_Result ();
				sr.create ( cl [ 0 ].id, 'person', cl [ 0 ].name, '','' );
				results.add ( sr );
				cl.remove ( 0 );
			}
			
			// only account list?
			if (( al.size () > 0 ) && ( cl.size () == 0 )) {
				// contact is moved
				sr = new Search_Result ();
				sr.create ( al [ 0 ].id, 'team', al [ 0 ].name, '','' );
				results.add ( sr );
				al.remove ( 0 );
			}
			
		} // end WHILE loop
		
		// at this point we have a master list of Search_Results ( this.results )
		// and our sObject lists are empty
		
	}
	
	public void recent_items ( ) {
		
		// reset parameters
		init ();
		
		// load recently viewed records
		List < Contact > contacts = new List < Contact > ( [ SELECT Id, Name, Email, LastViewedDate FROM Contact WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 10 ] );
		List < Account > accounts = new List < Account > ( [ SELECT Id, Name, LastViewedDate FROM Account WHERE Type = 'Stand Team' AND LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 10 ] );
		
		Search_Result sr;
		
		integer result_counter = 0;
		// i'm suprised that we have to merge two lists sorted again
		while ((( contacts.size () > 0 ) || ( accounts.size () > 0 )) && ( result_counter <= RECENT_RESULT_LIMIT )) {
			// loops until both lists are empty
			if (( contacts.size() > 0 ) && ( accounts.size () > 0 )) {
				// both lists have a value to compare
				if ( contacts[ 0 ].LastViewedDate >= accounts[ 0 ].LastViewedDate ) {
					// contact was accessed more recently
					sr = new Search_Result ();
					sr.create ( contacts [ 0 ].id, 'person', contacts [ 0 ].name, '','' );
					results.add ( sr );
					contacts.remove ( 0 );
				} else {
					// account was accessed more recently
					sr = new Search_Result ();
					sr.create ( accounts [ 0 ].id, 'team', accounts [ 0 ].name, '','' );
					results.add ( sr );
					accounts.remove ( 0 );
				}
			}
			// only contact list?
			if (( contacts.size () > 0 ) && ( accounts.size () == 0 )) {
				// contact is moved
				sr = new Search_Result ();
				sr.create ( contacts [ 0 ].id, 'person', contacts [ 0 ].name, '','' );
				results.add ( sr );
				contacts.remove ( 0 );
			}
			
			// only account list?
			if (( accounts.size () > 0 ) && ( contacts.size () == 0 )) {
				// contact is moved
				sr = new Search_Result ();
				sr.create ( accounts [ 0 ].id, 'team', accounts [ 0 ].name, '','' );
				results.add ( sr );
				accounts.remove ( 0 );
			}
			
			result_counter++;
			
		} // end WHILE loop
		
		// at this point we have a master list of Search_Results ( this.results )
	}
	
	public void output ( ) {
		// traverses results
		for ( Search_Result sr : results ) {
			system.debug ( '----------' + sr.obj_type + ' == ' + sr.name );
		}
		
	}

}