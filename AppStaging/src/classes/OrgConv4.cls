public with sharing class OrgConv4 {
// Common Usage - run the Conversion for a State:
	// State Code, Log Level, Write Mode, Batch ID
	// 'IN', null, 'PREP' or 'WRITE'
	
	/*
	OrgConv4 o = new OrgConv4( 'TN', 'JOB', 'WRITE', 31);
	//o.PrepData(); o.FixContacts(); o.FixLeaders();
	//o.CleanContacts('All');
	//o.UpdateStateWideAffiliations();
	//o.FixMemberships();
	//o.CommitJobResults();
	*/
	
/*	
	// ========================================================
	// CONSTRUCTOR
	// ========================================================
	
	public OrgConv4 ( String stateCode, String logLevel, String writeMode, Decimal batchID ) {
		
		// create the Jobs Result list
		this.jobResultList = new list < Job_Result__c > ();
		
		this.logLevel = logLevel;
		this.stateCode = stateCode;
		
		// calc the logLevel
		if ( logLevel == 'DEBUG' ) {
			this.writeDebug = true;
			this.writeJobResult = false;
		} else if ( logLevel == 'JOB' ) {
			this.writeDebug = false;
			this.writeJobResult = true;
		} else  {
			this.writeDebug = true;
			this.writeJobResult = true;
		}
		
		// calc the write mode
		if ( writeMode == 'WRITE' ) {
			this.commitPrep = true;
			this.commitData = true; 
		} else if ( writeMode == 'PREP' ){
			this.commitPrep = true;
			this.commitData = false;
		} else {
			commitPrep = false;
			commitData = false;
		}
		
		if ( batchID == null ) {
			this.batchID = 0;
		} else {
			this.batchID = batchID;
		}
		
		this.commitStage = 0;
		
	}
	
	// ========================================================
	// OBJECT LEVEL VARIABLES
	// ========================================================
	
	private list < Job_Result__c > jobResultList;
	
	private Decimal batchID;
	private String logLevel;
	private String stateCode;
	private Boolean writeDebug;
	private Boolean writeJobResult;
	private Boolean commitPrep;
	private Boolean commitData;
	private Integer passCount;
	private Integer commitStage;
	
	// MASTER VARIABLES
	set < ID > allContacts = new set < ID > ();
	set < ID > allLeaders = new set < ID > ();
	
	// Supporting Maps
	// Membership
	map < ID, Membership__c > contactWithMemberships = new map < ID, Membership__c > ();
	
	// Contact focus
	map < ID, npe5__Affiliation__c > contactWithTeams = new map < ID, npe5__Affiliation__c > ();
	map < ID, npe4__Relationship__c > contactWithLeaderRelationship = new map < ID, npe4__Relationship__c > ();
	map < ID, npe5__Affiliation__c > contactWithChapters = new map < ID, npe5__Affiliation__c > ();
	map < ID, Contact > contacts = new map < ID, Contact > ();
	map < ID, ID > contactsWithChaptersTeamOverride = new map < ID, ID > (); // Contact, Account (team ID)
	
	set < ID > testContacts = new set < ID > (); // used to reduce the number of contacts in test
	map < ID, npe5__Affiliation__c > contactWithTeamsUpdated = new map < ID, npe5__Affiliation__c > (); // used in Membership update section
	
	// Leader focus
	map < ID, npe4__Relationship__c > leaderRelationships = new map < ID, npe4__Relationship__c > ();
	map < ID, npe5__Affiliation__c > leadersWithAffiliations = new map < ID, npe5__Affiliation__c > ();
	map < ID, contact > leaderContacts = new map < ID, contact > ();
	map < ID, Date > leaderAffiliationStartDate = new map < ID, Date > ();
	map < ID, Date > leaderStartDates = new map < ID, Date > ();
	map < ID, Integer > leaderFollowerCounts = new map < ID, Integer > ();
	
	// ancillary
	map < ID, Account > stateChapterWideTeams = null;
	map < ID, ID > teamWithChapters = new map < ID, ID > ();
	
	integer executionRecords = 0;
	integer totalPossibleExecutions = 0;
	integer executionUpdateLeader = 0;
	integer executionCreateTeamAffiliationWithLeader = 0;
	integer executionCreateChapterWideTeam = 0;
	integer leadersWithoutMemberships = 0;
	integer LeadersWithComplimentaryMemberships = 0;
	
	// master DML containers
	list < Contact > contactsForUpdate = new list < Contact > ();
	map < ID, npe5__Affiliation__c > affiliationsForUpdate = new map < ID, npe5__Affiliation__c > (); // contact ID indexed affiliations for DML upserting
	list < Membership__c > membershipsForUpdate = new list <  Membership__c > ();
	list < npe5__Affiliation__c > affiliationsForDelete = new list < npe5__Affiliation__c > ();
	list < npe4__Relationship__c > relationshipsForDelete = new list < npe4__Relationship__c > ();
	
	// ========================================================
	// PRIVATE METHODS
	// ========================================================
	
	// Private method to allow for results storage during execution
	// Use commitJobResults() to write to SFDC
	
	// SKT 7/11/12 - changed this to a public method so I can reuse it in other scripts
	
	public void logJobResult ( ID parentID, String parentType, ID childID, String childType, String actionType, String detail ) {
		
		if ( this.writeJobResult ) {
			Job_Result__c tmpResult = new Job_Result__c ();
			tmpResult.Contact__c = parentID;
			tmpResult.Parent_ID__c = parentID;
			tmpResult.Parent_Type__c = parentType;
			tmpResult.Child_ID__c = childID;
			tmpResult.Child_Type__c = childType;
			tmpResult.Action_Type__c = actionType;
			if ( this.commitData ) {
				tmpResult.Detail__c = '[COMMIT] ' + detail;
				tmpResult.Mode__c = 'Commit';
			} else {
				tmpResult.Detail__c = detail;
				tmpResult.Mode__c = 'Test';
			}
			tmpResult.Time_Stamp__c = datetime.now();
			tmpResult.Batch_Count__c = this.batchId;
			tmpResult.Batch_Key__c = this.stateCode;
			// SKT 7/5
			// Adding marked record capability for detailed reporting
			if ( this.testContacts.contains ( parentID )) {
				tmpResult.Marked__c = true;
			} else {
				tmpResult.Marked__c = false;
			}
			// add the entry to the list
			jobResultList.add ( tmpResult );
		}
		
		if ( this.writeDebug ) {
			System.debug ( ' ====== ' + actionType + ' : ' + parentType + ' => ' + parentID + ' :: ' + childType + ' => ' + childID + ' :: ' + detail);
		}
	}
	
	// Private method to write results and exceptions to the Jobs Reports object in SFDC
	
	public void CommitJobResults () {
		
		// if Batch ID is zero (noting a null), clear out the previous job results
		if ( batchID == 0 ) {
			this.ClearJobResults();
		}
		
		// write the job results
		if ( jobResultList.size() > 0 ) {
			insert jobResultList;
		}
		
	}
	
	private void ClearJobResults () {
		// removes all job results from SDFC storage
		list < Job_Result__c > jr = new list < Job_Result__c > ( [ SELECT ID FROM Job_Result__c WHERE batch_key__c = : this.stateCode ] );
		delete jr;
	} 

	public void ClearJobResultsByBatch ( Integer batchID ) {
		// removes all job results from SDFC storage
		list < Job_Result__c > jr = new list < Job_Result__c > ( [ SELECT ID FROM Job_Result__c WHERE batch_key__c = : this.stateCode AND batch_count__c = : batchId ] );
		delete jr;
	} 
	
	private void PrepSupportData () {
		// ================= PREP ======================
		// load chapter wide teams for related state
		list < Account > stateChapters = new list < Account > ( [ SELECT ID FROM Account WHERE Parent.State_Abbreviation__c = : this.stateCode AND Parent.Type = 'Stand Affiliate State' AND Type = 'Stand Chapter' ]);
		this.stateChapterWideTeams = new map < ID, Account > ();
		list < Account > stateTeams = new list < Account > ( [ SELECT ID, Name, ParentID, Parent.Name FROM Account WHERE ParentID IN : stateChapters AND Type = 'Stand Team' ]);
		integer chapterWideTeamCount = 0;
		
		// storage for this information is a Map indexed by Chapter ID and returns the Account for the associated Chapter Wide Team
		for ( Account t : stateTeams ) {
			if ( t.Name == t.Parent.Name + ' Wide Team' ) {
				// found a chapter wide team
				stateChapterWideTeams.put ( t.ParentID, t );
				System.debug ( '=========== INFO PREP ==>> Found ' + t.name + ' chapter wide team for ' + this.stateCode + ' =============================' );
				chapterWideTeamCount++;
			}
			// add to the team indexed chapter list
			teamWithChapters.put ( t.Id, t.parentID );
		}
		
		// addition to "Fix" Chapter Wide Teams by inserting those that are needed
		Account tmpAccount = null;
		list < Account > teamsToAdd = new list < Account > ();
		
		if ( chapterWideTeamCount != stateChapters.size() ) {
			// we do not have all chapterWideTeams
			list < Account > chaptersWithoutWideTeams = new list < Account > ( [ SELECT ID, Name, OwnerID FROM Account WHERE Parent.State_Abbreviation__c = : this.stateCode AND Parent.Type = 'Stand Affiliate State' AND Type = 'Stand Chapter' AND ID NOT IN : stateChapterWideTeams.keySet() ]);
			for ( Account a : chaptersWithoutWideTeams ) {
				tmpAccount = new Account();
				tmpAccount.parentID = a.ID;
				tmpAccount.name = a.name + ' Wide Team';
				tmpAccount.BillingState = this.stateCode;
				tmpAccount.Type = 'Stand Team';
				tmpAccount.OwnerId = a.OwnerID;
				tmpAccount.Acquired_By__c = 'C4 Acquired';
				tmpAccount.State_Abbreviation__c = this.stateCode;
				teamsToAdd.add ( tmpAccount );
				this.logJobResult ( null, null, a.ID, 'Chapter-Account', 'CREATE-ACCT-CH', 'Created Chapter Wide Team - Name: ' + tmpAccount.name);
			}
			// write the DML insert
			if ( this.commitPrep ) {
				insert teamsToAdd;
			}
			
			// redo the initial list loads - this should be refactored, but it's really late...
			stateChapters = new list < Account > ( [ SELECT ID FROM Account WHERE Parent.State_Abbreviation__c = : this.stateCode AND Parent.Type = 'Stand Affiliate State' AND Type = 'Stand Chapter' ]);
			this.stateChapterWideTeams = new map < ID, Account > ();
			stateTeams = new list < Account > ( [ SELECT ID, Name, ParentID, Parent.Name FROM Account WHERE ParentID IN : stateChapters AND Type = 'Stand Team' ]);
			teamWithChapters.clear();
			
			// storage for this information is a Map indexed by Chapter ID and returns the Account for the associated Chapter Wide Team
			for ( Account t : stateTeams ) {
				if ( t.Name == t.Parent.Name + ' Wide Team' ) {
					// found a chapter wide team
					stateChapterWideTeams.put ( t.ParentID, t );
					System.debug ( '=========== INFO PREP 2 ==>> Found ' + t.name + ' chapter wide team for ' + this.stateCode + ' =============================' );
				}
				// add to the team indexed chapter list
				teamWithChapters.put ( t.Id, t.parentID );
			}
		}
		
		System.debug ( '=========== INFO PREP ==>> Found ' + stateChapterWideTeams.size() + ' chapter wide teams for ' + this.stateCode + ' =============================' );
		
		// Load Memberships
		list < Membership__c > memberships = new list < Membership__c > ( [ SELECT ID, Membership_State__c, Status2__c, Contact__c FROM Membership__c WHERE Membership_State__c = : this.stateCode ] );
		// flip into a contact indexed list
		for ( Membership__c m : memberships ) {
			if ( this.contactWithMemberships.containsKey ( m.Contact__c ) == false ) {
				// add the new entry
				this.contactWithMemberships.put ( m.Contact__c, m );
			} else {
				// multiple memberships - log the error
				this.logJobResult ( m.Contact__c, 'Contact', m.ID, 'Membership', 'EX-MULTI-MEM', 'Exception :: Found multiple membership records for a member, could not add additional membership for Contact' );
				//System.debug ( '=========== EX-MULTI-MEM ==>> Exception :: Found multiple membership records for a member, could not add additional membership for Contact ' + m.Contact__c + ' with Membership ' + m.ID );
		
			}
		}
	}
	
	private void PrepContacts () {
		// ================= PREP ======================
		// load contacts with active affiliations to a team as a team contact
		System.debug ( '=========== INFO PREP==>> Loading all Team Contact Affiliations =============================' );
		// 6/28/12 SKT
		// changed this to look at Membership_State__c on the Contact record rather than State Office
		// change this to look for Team Member and Team Contact (to be backwards compatible)
		map < ID, npe5__Affiliation__c > contactTeamAffiliations = null;
		
		contactTeamAffiliations = new map < ID, npe5__Affiliation__c > ( [ SELECT ID, npe5__Contact__c, npe5__Organization__c, npe5__StartDate__c, Team_Leader__c FROM npe5__Affiliation__c WHERE npe5__Contact__r.Membership_State__c = : this.stateCode AND ( Affiliation__c = 'Team Contact' OR Affiliation__c = 'Team Member' ) AND npe5__Status__c = 'Active' AND npe5__Organization__r.Type = 'Stand Team' ]);
		
		// switch to Contact uniquely indexed with a map of Team ID + Affiliation Object as value 
		
		for (npe5__Affiliation__c a : contactTeamAffiliations.values () ) {
			// check to see if we already have this contact/team assignment
			if ( contactWithTeams.containsKey ( a.npe5__Contact__c ) == false ) {
				contactWithTeams.put ( a.npe5__Contact__c, a );
				allContacts.add ( a.npe5__Contact__c );
			} else {
				// Exeception - could not add additional Team Contact affilition
				this.logJobResult ( a.npe5__Contact__c, 'Contact',  a.ID, 'Team-Account', 'EX-TEAM-AFF', 'Exception :: Found multiple Team affilitions for a member, could not add additional Team Contact affilition for Contact' );
				//System.debug ( '=========== EX-TEAM-AFF ==>> could not add additional Team Contact affilition for Contact ' + a.npe5__Contact__c + ' with Affiliation ' + a.ID );
			}
		}
		
		// ================= PREP ======================
		// load contacts with active affiliations to a chapter and not a team
		System.debug ( '=========== INFO PREP==>> Loading all Chapter Contact Affiliations =============================' );
		// 6/28/12
		// SKT - changed this to look at Membership_State__c on the Contact record rather than State Office
		// also updated so it only fetches contacts with active or lapsed membership
		map < ID, npe5__Affiliation__c > contactChapterAffiliations = null;
		
		contactChapterAffiliations = new map < ID, npe5__Affiliation__c > ( [ SELECT ID, npe5__Contact__c, npe5__Organization__c, npe5__StartDate__c FROM npe5__Affiliation__c WHERE npe5__Contact__r.Membership_State__c = : this.stateCode AND ( Affiliation__c = 'Chapter Contact' ) AND npe5__Status__c = 'Active' AND ( npe5__Contact__r.Membership_Status__c = 'Active' OR npe5__Contact__r.Membership_Status__c = 'Lapsed' ) AND npe5__Organization__r.Type = 'Stand Chapter' AND npe5__Contact__c NOT IN : contactWithTeams.keySet() ]);
		
		// switch to Contact uniquely indexed with a map of Chapter ID + Affiliation IDs as value
		
		for (npe5__Affiliation__c a : contactChapterAffiliations.values () ) {
			// check to see if we already have this contact/chapter assignment
			if ( contactWithChapters.containsKey ( a.npe5__Contact__c) == false ) {
				contactWithChapters.put ( a.npe5__Contact__c, a );
				allContacts.add ( a.npe5__Contact__c );
			} else {
				// Exeception - could not add additional Chapter Contact affilition
				this.logJobResult ( a.npe5__Contact__c, 'Contact', a.ID, 'Affiliation', 'EX-DUPE-CHAPTER', 'Exception :: Duplicate Chapter affiliation found for Contact' );
				//System.debug ( '=========== EX-DUPE-CHAPTER ==>> could not add additional Chapter Contact affilition for Contact ' + a.npe5__Contact__c + ' with Affiliation ' + a.ID );
			}
		}
		
		// ================= PREP ======================
		// load full contact information against allContacts to do "clean up"
		this.contacts = new map < ID, Contact > ( [ SELECT ID, Stand_Team_Affiliation__c, Stand_Chapter_Affiliation__c, Stand_Leader__c FROM Contact WHERE ID IN : this.allContacts ]);
	}
	
	private void PrepLeaders () {
		// ================= PREP ======================
		// load all affiliations for Leaders
		System.debug ( '=========== INFO PREP==>> Loading all Team Leader Affiliations =============================' );
		// 6/28/2012
		// SKT - changed this to look at Membership_State__c on the Contact record rather than State Office
		// added criteria to ensure that identified leader has an Active/Lapsed Membership type
		map < ID, npe5__Affiliation__c > leaderAffiliations = null;
		
		leaderAffiliations = new map < ID, npe5__Affiliation__c > ( [ SELECT ID, npe5__Contact__c, npe5__Organization__c, npe5__StartDate__c FROM npe5__Affiliation__c WHERE npe5__Contact__r.Membership_State__c = : this.stateCode AND Affiliation__c = 'Team Leader' AND npe5__Status__c = 'Active' AND ( npe5__Contact__r.Membership_Status__c = 'Active' OR npe5__Contact__r.Membership_Status__c = 'Lapsed' ) AND npe5__Organization__r.Type = 'Stand Team' ]);

		// switch to Contact uniquely indexed with a map of Team ID + Affiliation Object as value 
		// set to only allow a single Team Leader affiliation
		
		for (npe5__Affiliation__c a : leaderAffiliations.values () ) {
			// check to see if we already have this leader affiliation
			if ( this.leadersWithAffiliations.containsKey ( a.npe5__Contact__c ) == false ) {
				// we need to add this new leader
				this.leadersWithAffiliations.put ( a.npe5__Contact__c, a );
				this.leaderAffiliationStartDate.put ( a.npe5__Contact__c, a.npe5__StartDate__c );
				// add leader to master leader list
				allLeaders.add ( a.npe5__Contact__c );
			} else {
				// Exeception - could not add additional Team Leader affilition
				this.logJobResult ( a.npe5__Contact__c, 'Contact-Leader',  a.ID, 'Team-Account', 'EX-TEAM-LEADER-AFF', 'Exception :: Found multiple Team affilitions for a Leader, could not add additional Team Leader affilition for Leader' );
				//System.debug ( '=========== EX-TEAM-LEADER-AFF ==>> could not add additional Team Leader affilition for Contact-Leader ' + a.npe5__Contact__c + ' with Affiliation ' + a.ID );
	
			}
		}
		
		// ================= PREP ======================
		// load contacts with active "leader" relationship and calculate follower count
		System.debug ( '=========== INFO PREP ==>> Loading contacts with active "Leader" relationships =============================' );
		// 6/28/12 SKT 
		// updated this to look at Membership_State__c on the Contact record rather than State Office
		// added criteria to ensure that related Followers have Active or Lapsed Memberships
		// added criteria to ensure that identified leader has an Active/Lapsed Membership type
		// RELIES on Membership Status on the Contact record to be updated
		this.leaderRelationships = new map < ID, npe4__Relationship__c > ( [ SELECT ID, npe4__Contact__c, npe4__RelatedContact__c, Start_Date__c FROM npe4__Relationship__c WHERE npe4__Contact__r.Membership_State__c = : this.stateCode AND ContactRelationship__c = 'Leader' AND npe4__Status__c = 'Active' AND ( npe4__RelatedContact__r.Membership_Status__c = 'Active' OR npe4__RelatedContact__r.Membership_Status__c = 'Lapsed' ) AND ( npe4__Contact__r.Membership_Status__c = 'Active' OR npe4__Contact__r.Membership_Status__c = 'Lapsed' )]);
		
		// Calculate Follower Count - make sure that these followers are Active/Lapsed memberships, and Rel status = active
		// switch to Contact uniquely indexed with related Relationship Obj as value
		Integer tmpFollowerCount = 0;
		ID leaderTeamID = null;
		ID teamID = null;
		
		for ( npe4__Relationship__c r : leaderRelationships.values() ) {
			// check to see if we already have this contact first
			if ( contactWithLeaderRelationship.get ( r.npe4__Contact__c ) == null ) {
				// add the new contact
				contactWithLeaderRelationship.put ( r.npe4__Contact__c , r );
				// add this contact with a leader into the master contact loop list
				allContacts.add ( r.npe4__Contact__c );
				// add this leader into the master list of leaders
				allLeaders.add ( r.npe4__RelatedContact__c );
				// Check for matching Teams or if they are in the Contact with Chapter list
				if ( leadersWithAffiliations.containsKey ( r.npe4__RelatedContact__c ) && ( contactWithTeams.containsKey ( r.npe4__Contact__c ) || contactWithChapters.containsKey ( r.npe4__Contact__c ))) {
					// found a affiliation for current leader and contact
					leaderTeamID = leadersWithAffiliations.get ( r.npe4__RelatedContact__c ).npe5__Organization__c;
					if ( contactWithTeams.containsKey ( r.npe4__Contact__c )) {
						teamID = contactWithTeams.get ( r.npe4__Contact__c ).npe5__Organization__c;
					} else {
						// get the team from the original leader - MP: in the case of the follower only having a chapter aff, just use the leader's
						teamID = leaderTeamID;
						contactsWithChaptersTeamOverride.put ( r.npe4__Contact__c, teamID );  // use this list later during the chapter assignment in fixContacts
					}
					if ( leaderTeamID == teamID ) {
						// increment the leader count 
						if ( leaderFollowerCounts.containsKey (r.npe4__RelatedContact__c) == false ) {
							// insert a new LeaderFollowerCount item
							leaderFollowerCounts.put ( r.npe4__RelatedContact__c, 1 );
						} else {
							// update the current count
							tmpFollowerCount = leaderFollowerCounts.remove (r.npe4__RelatedContact__c) + 1;
							leaderFollowerCounts.put ( r.npe4__RelatedContact__c, tmpFollowerCount );
						}
					} else {
						// notice - team mismatch
						this.logJobResult ( r.npe4__Contact__c, 'Contact', r.npe4__RelatedContact__c, 'Leader-Contact', 'NOTICE-FOLLOWER-MISTEAM', 'Exception :: Could not add follower count - mismatched teams ' );
		
					}
				} else {
					// notice - no affiliations
					if ( leadersWithAffiliations.containsKey ( r.npe4__RelatedContact__c ) ) {
						this.logJobResult ( r.npe4__Contact__c, 'Contact', r.npe4__RelatedContact__c, 'Leader-Contact', 'NOTICE-FOLLOWER-CONTACT-AFF', 'Exception :: Could not add follower count - missing affiliations ' );
					} else {
						this.logJobResult ( r.npe4__Contact__c, 'Contact', r.npe4__RelatedContact__c, 'Leader-Contact', 'NOTICE-FOLLOWER-LEADER-AFF', 'Exception :: Could not add follower count - missing affiliations ' );
						//System.debug ( '=========== NOTICE-FOLLOWER-LEADER-AFF ==>> Exception :: Could not add follower count - no affiliations on leader ' + r.npe4__Contact__c + ' with Leader ID ' + r.npe4__RelatedContact__c );
					}
				}
				
				// mark the relationship for deletion
				relationshipsForDelete.add ( r );
				
			} else {
				// log exception - duplicate Contact with Active Leader found
				this.logJobResult ( r.npe4__Contact__c, 'Contact', r.npe4__RelatedContact__c, 'Leader-Contact', 'EX-DUPE-LEADER', 'Exception :: Duplicate Active Leader found for Contact' );
				//System.debug ( '=========== EX-DUPE-LEADER ==>> Duplication Active Leader found for Contact ' + r.npe4__Contact__c + ' with Leader ID ' + r.npe4__RelatedContact__c );
			}
		}
		
		// ================= PREP ======================
		// build the LIT evaluation maps
		System.debug ( '=========== INFO PREP==>> Calculating and min start dates for LIT =============================' );
		// SKT 6/28/2012
		// min(start_date) - we evaluate all followers, regardless of Active or Inactive at this point on the REL
		list < AggregateResult > leaderRelStartDate = new list < AggregateResult > ( [ SELECT npe4__Contact__c, min ( Start_Date__c ) lowStartDate FROM npe4__Relationship__c WHERE npe4__Contact__c IN : allLeaders AND ContactRelationship__c = 'Follower' GROUP BY npe4__Contact__c ]);
		// create a list indexed by contact-leader ID
		
		for ( AggregateResult ar : leaderRelStartDate ) {
			leaderStartDates.put ( (ID) ar.get ( 'npe4__Contact__c' ), (Date) ar.get ( 'lowStartDate' ));
		}
		
		// ================= PREP ======================
		// for all leaders, we need to determine what team's they are for a future evaluation below
		// we will also use these Contact objects to update against when calculation LIT information
		// NOTE: do not rely on these contact Fields during execution - these are not reliable
		System.debug ( '=========== INFO PREP==>> Loading Leaders and their Teams =============================' );
		this.leaderContacts = new map < ID, contact > ( [ SELECT ID, Stand_Team_Affiliation__c, Stand_Leader__c, Leader_Type__c, LiT_Start_Date__c, Leader_Start_Date__c, Membership_Status__c, Membership_Type__c, Membership_Start_Date__c, Number_of_Followers__c FROM contact WHERE ID IN : allLeaders ]);
		
		System.debug ( 'Leader Affiliation Start Dates: ' + leaderAffiliationStartDate.size());
		for ( ID i : leaderAffiliationStartDate.keySet() ) {
			System.debug ( ' Aff Start Date ' + leaderAffiliationStartDate.get (i) + ' ID ' + i);
		}
	}
	
	public void Execute ( String execMode, Integer passCount ) {
		
		// main controller to execute work
		if ( execMode == 'ALL' ) {
			// run everything at once
			this.commitStage = 0;
			this.PrepData();
			this.FixContacts();
			this.FixLeaders();
			this.FixMemberships();
			this.CommitJobResults();
			
		} else if ( execMode == 'SPLIT' ) {
			// run Contacts and Leaders first, then membership
			this.commitStage = 0;
			if ( passCount == 1 ) {
				this.PrepData();
				this.FixContacts();
				this.FixLeaders();
				this.CommitJobResults();
			} else if ( passCount == 2 ) {
				this.FixMemberships();
				this.CommitJobResults();
			}
		} else if ( execMode == 'SLOW' ) {
			// use the passCount to manage the committing of data
			if (( passCount == 1 ) || ( passCount == 2 ) || ( passCount == 3 )) {
				if (( passCount == 2 ) || ( passCount == 3 )) {
					this.writeJobResult = false; // turn off logging as we are doing the same work as the first pass
				}
				this.commitStage = passCount;
				this.PrepData ();
				this.FixContacts ();
				this.FixLeaders ();
				this.CommitJobResults();
			}
			if ( passCount == 4 ) {
				this.FixMemberships();
				this.CommitJobResults();
			}
		}
		
	}
	
	public void PrepData () {
		
		this.PrepContacts ();
		this.PrepLeaders ();
		this.PrepSupportData ();
	}
	
	public void FixContacts () {
		// ================ EXECUTION ================== 
		// Loop for all Contacts
		Boolean haveLeader = false;
		Boolean haveTeam = false;
		Boolean haveChapter = false;
		
		ID leaderID = null;
		ID leaderTeamID = null;
		ID teamID = null;
		ID chapterID = null;
		String membershipStatus = null;
		String membershipType = null;
		npe5__Affiliation__c affObject = null;
		ID teamAccountID = null;
		npe4__Relationship__c relObject = null;
		Boolean didUpdate = false;
		Boolean dirtyContact = false; 
		Boolean leaderInvalid = false; // used to trigger the contact clean up
		Boolean checkChapterWide = false; // used to trigger the Chapter Wide team check
		
		for ( ID c : allContacts ) {
			
			System.debug ( '[[------------');
			
			// do we have any relationships to a leader
			haveLeader = contactWithLeaderRelationship.containsKey (c );
			// do we have any team or chapter affiliations
			haveTeam = contactWithTeams.containsKey ( c );
			// do we have any Chapter only affiliations
			haveChapter = contactWithChapters.containsKey ( c );
			
			if ( haveLeader ) {
				leaderID = contactWithLeaderRelationship.get ( c ).npe4__RelatedContact__c;
				if ( leadersWithAffiliations.containsKey ( leaderID )) {
					leaderTeamID = leadersWithAffiliations.get ( leaderID ).npe5__Organization__c;
				} else {
					leaderTeamID = null;
				}
			}
			
			if ( haveTeam ) { 
				teamID = contactWithTeams.get ( c ).npe5__Organization__c;
			}
			
			this.logJobResult ( c, 'Contact', leaderID, 'Leader-Contact', 'ATTEMPT-CONTACT', 'Org v2 Conversion Started for Contact and Leader pair' );
				
			// has a leader relationship and team affiliation
			if (( haveLeader ) && ( haveTeam )) {
				// check to see if the team between the leader and team affiliation match
				if (( leaderTeamId == teamId ) && ( leaderTeamId != null )) {
					// teams match
					// update the affiliation record with the leader
					affObject = contactWithTeams.get ( c );
					affObject.Team_Leader__c = leaderID;
					affObject.Type__c = 'Organizing';
					if ( affObject.npe5__Organization__c != leaderTeamId ) {
						// we can't add this record ????
						this.logJobResult ( c, 'Contact', affObject.ID, 'Affiliation', 'EX-UPDATE-AFF-LDR-MISTEAM', 'Leader ' + leaderID + ' not updated onto existing Affiliation record for contact due to misteam assignment' );
						leaderInvalid = true;
					}
					this.affiliationsForUpdate.put ( affObject.npe5__Contact__c, affObject );
					this.contactWithTeamsUpdated.put ( affObject.npe5__Contact__c, affObject );
					
					didUpdate = true;
					this.logJobResult ( c, 'Contact', affObject.ID, 'Affiliation', 'UPDATE-AFF-LEADER', 'Leader ' + leaderID + ' updated onto existing Affiliation record for contact' );
					executionUpdateLeader++;
				} else {
					// exception - mismatched Teams for Leader and Contact
					
					// need to add this unedited affiliation to the Membership list
					// so we can evaluate it later in the Mem record clean up
					this.contactWithTeamsUpdated.put ( c, contactWithTeams.get ( c ) );
					
					if ( leaderTeamId == null ) {
						// no team found for leader
						this.logJobResult ( c, 'Contact', leaderID, 'Leader-Contact', 'EX-MIS-LEADER-TEAM', 'Leader Team not found - Affiliation not updated' );
						leaderInvalid = true;
					} else {
						this.logJobResult ( c, 'Contact', leaderID, 'Leader-Contact', 'EX-MISMATCH-LEADER', 'Mismatched Leader to Team relationship for Contact and Leader combination - Affiliation not updated' );
						leaderInvalid = true;
					}
				}
				
			} else if (( haveTeam == false ) && ( haveLeader )) {
				// has a leader but no team
				// create a new affiliation
				// create the new affiliation with a leader
				// first load the original leader relationship
				relObject = contactWithLeaderRelationship.get ( c );
				// write the new affiliation
				if (( leaderTeamID != null ) && ( relObject != null )) {
					// check to make sure that this person is not a leader
					if ( this.allLeaders.contains ( c ) == false ) {
						affObject = new npe5__Affiliation__c ();
						affObject.Affiliation__c = 'Team Member';
						affObject.npe5__Contact__c = c;
						affObject.Team_Leader__c = leaderID;
						affObject.npe5__Organization__c = leaderTeamID;
						affObject.npe5__StartDate__c = relObject.Start_Date__c;
						affObject.npe5__Status__c = 'Active';
						affObject.Type__c = 'Organizing';
						this.affiliationsForUpdate.put ( affObject.npe5__Contact__c, affObject );
						this.contactWithTeamsUpdated.put ( affObject.npe5__Contact__c, affObject );
						
						didUpdate = true;
						this.logJobResult ( c, 'Contact', leaderID, 'Leader-Contact', 'CREATE-AFF-TEAM', 'Creating a new Affilition for Contact ' + c + ' with Leader ID ' + leaderID + ' to Team ID ' + leaderTeamID + ' with start date ' + relObject.Start_Date__c );
						//System.debug ( '=========== CREATE-AFF-TEAM: WRITING EXECUTION ==>> Creating a new Affilition for Contact ' + c + ' with Leader ID ' + leaderID + ' to Team ID ' + leaderTeamID + ' with start date ' + relObject.Start_Date__c);
						executionCreateTeamAffiliationWithLeader++;
					} else {
						// prevents a problem with a Team Member affiliation being created when the Contact is actually a Leader
						this.logJobResult ( c, 'Contact', leaderID, 'Leader-Contact', 'EX-CREATE-AFF-TEAM-LEADER', 'Prevented created a new Affilition for Contact ' + c + ' with Leader ID ' + leaderID + ' to Team ID ' + leaderTeamID + ' with start date ' + relObject.Start_Date__c );
					}
					
				} else {
					if ( leaderTeamID == null ) {
						this.logJobResult ( c, 'Contact', leaderID, 'Leader-Contact', 'EX-LEADER-TEAM', 'Leader Team not found  ' + c + ' with Leader ID ' + leaderID + ' - no Affiliation updated/inserted' );
						leaderInvalid = true;
						checkChapterWide = true;
					} else {
						this.logJobResult ( c, 'Contact', leaderID, 'Leader-Contact', 'EX-LEADER-REL', 'Leader/Follower Relationship not found ' + c + ' with Leader ID ' + leaderID + ' - no Affiliation updated/inserted' );
						leaderInvalid = true;
						checkChapterWide = true;
					}
				}
			} else if (( haveTeam == false ) && ( haveLeader == false)) {
				// no team and no leader
				// check for chapter
				checkChapterWide = true;
			}
				
			if ( checkChapterWide ) {
				if ( haveChapter ) {
					// check to see if this chapter affiliation is in the override list
					if ( contactsWithChaptersTeamOverride.containsKey ( c )) {
						// just pull the team from this list
						teamAccountID = contactsWithChaptersTeamOverride.get ( c );
						this.logJobResult ( c, 'Contact', null, null, 'NOTICE-AFF-CH-OVERRIDE', 'Attempting to create a new Affilition  for Contact ' + c + ' to Leader sourced team : ' + teamAccountID );
					} else {
						// look up chapter wide team affiliation
						affObject = contactWithChapters.get ( c );
						if ( stateChapterWideTeams.containsKey ( affObject.npe5__Organization__c )) {
							teamAccountID = stateChapterWideTeams.get ( affObject.npe5__Organization__c ).Id;
						} else {
							teamAccountID = null;
						}
					}
					
					if ( teamAccountID != null ) {
						// check to make sure that this person is not a leader
						if ( this.allLeaders.contains ( c ) == false ) {
							// create the new affiliation for this team
							affObject = new npe5__Affiliation__c ();
							affObject.Affiliation__c = 'Team Member';
							affObject.npe5__Contact__c = c;
							affObject.npe5__StartDate__c = contactWithChapters.get ( c ).npe5__StartDate__c;
							affObject.npe5__Status__c = 'Active';
							affObject.npe5__Organization__c = teamAccountID;
							affObject.Type__c = 'Organizing';
							this.affiliationsForUpdate.put ( affObject.npe5__Contact__c, affObject );
							this.contactWithTeamsUpdated.put ( affObject.npe5__Contact__c, affObject );
							didUpdate = true;
							this.logJobResult ( c, 'Contact', null, null, 'CREATE-AFF-CH', 'Created a new Affilition  for Contact ' + c + ' to Chapter Wide Team : ' + affObject.npe5__Organization__c + ' with start date ' + affObject.npe5__StartDate__c );
						
							// mark the old affiliation as one to delete
							affiliationsForDelete.add ( contactWithChapters.get ( c ));
							this.logJobResult ( c, 'Contact', affObject.Id, 'Affiliation', 'DELETE-AFF-CH', 'Deleted affiliation due to creation of related Team Affiliation');
							executionCreateChapterWideTeam++;
						} else {
							// at this point we've found a Leader that only has a Chapter affiliation
							// check to see if the Leader already has a team affiliation
							if ( leadersWithAffiliations.containsKey ( c ) == false ) {
								// we are sure that this leader has no Team affiliations, create the Team Member affiliation
								// to the Chapter wide team
								affObject = new npe5__Affiliation__c ();
								affObject.Affiliation__c = 'Team Member';
								affObject.npe5__Contact__c = c;
								affObject.npe5__StartDate__c = contactWithChapters.get ( c ).npe5__StartDate__c;
								affObject.npe5__Status__c = 'Active';
								affObject.npe5__Organization__c = teamAccountID;
								affObject.Type__c = 'Organizing';
								
								this.affiliationsForUpdate.put ( affObject.npe5__Contact__c, affObject );
								this.contactWithTeamsUpdated.put ( affObject.npe5__Contact__c, affObject );
								this.logJobResult ( c, 'Contact', null, null, 'CREATE-AFF-CH-LEAD-MEM', 'Created a new Team Member Affilition for Former Leader Contact ' + c + ' to Chapter Wide Team : ' + affObject.npe5__Organization__c + ' with start date ' + affObject.npe5__StartDate__c );
							
								this.allLeaders.remove ( c ); // this downgrades the Contact to a Member and not a leader
								this.leaderContacts.remove ( c ); // also downgrades the Contact to a Member and not a leader
								this.logJobResult ( c, 'Contact', null, null, 'EX-LEADER-TO-MEMBER', 'Downgraded Leader to a Member due to lack of a valid Team affiliation.  Chapter wide Team affiliation has been created to : ' + affObject.npe5__Organization__c );
							
								didUpdate = true;
							
								// mark the old affiliation as one to delete
								affiliationsForDelete.add ( contactWithChapters.get ( c ));
								this.logJobResult ( c, 'Contact', affObject.Id, 'Affiliation', 'DELETE-AFF-CH', 'Deleted chapter level affiliation due to creation of related Team Affiliation');
								executionCreateChapterWideTeam++;
							} else {
								// prevents a problem with a Team Member affiliation being created when the Contact is actually a Leader
								this.logJobResult ( c, 'Contact', null, null, 'EX-CREATE-AFF-CH-LEADER', 'Prevented created a new Affilition for Contact ' + c + ' to Team ID ' + teamAccountID + ' with start date ' + contactWithChapters.get ( c ).npe5__StartDate__c );
								affiliationsForDelete.add ( contactWithChapters.get ( c ));
								this.logJobResult ( c, 'Contact', affObject.Id, 'Affiliation', 'DELETE-AFF-CH', 'Deleted chapter level affiliation due to not needing it any more');
							}
						}
					} else {
						// did not find a corresponding chapter wide team
						this.logJobResult ( c, 'Contact', null, null, 'EX-CREATE-AFF-CH', 'Could not create a new Affilition for Contact ' + c + ' to Chapter  : ' + affObject.npe5__Organization__c + ' with start date ' + affObject.npe5__StartDate__c );
					}
				} else {
					//System.debug ( '=========== EX-END ==>> Hitting End of Execution for Chapter Wide affiliated Contact ' + c );
					this.logJobResult ( c, 'Contact', null, null, 'EX-END', 'Hitting End of Execution for Contact ' + c );
				}
			}
			
			// if we did nothing, let's make sure that the contact record is clean
			/*
			if ( didUpdate == false ) {
				// check all contact fields to make sure that we have a clean Contact
				System.debug ( ' ================ In the Clean Up Section ===========> ' + c);
				if ( this.contacts.containsKey ( c ) ) {
					// check Team Affiliation on the Contact Record
					if ( this.contacts.get ( c ).Stand_Team_Affiliation__c != null ) {
						// check to see if team assignment still stands
						// 7/5 SKT - check the leaderTeam list too
						if ( this.leadersWithAffiliations.containsKey ( c )) {
							// let's make sure that the team on the leader matches the team on their contact
							if ( this.contacts.get ( c ).Stand_Team_Affiliation__c != this.leadersWithAffiliations.get ( c ).npe5__Organization__c ) {
								// have a team mismatch, update
								this.logJobResult ( c, 'Contact', this.leadersWithAffiliations.get ( c ).npe5__Organization__c, 'Account-Team', 'UPD-CONTACT-UPD-TEAM-LEADER', 'Updating Contact to update team for a leader - original team - ' + this.contacts.get ( c ).Stand_Team_Affiliation__c);
								this.contacts.get ( c ).Stand_Team_Affiliation__c = this.leadersWithAffiliations.get ( c ).npe5__Organization__c;
								// check to see if we can update the chapter too
								if ( this.teamWithChapters.containsKey ( this.leadersWithAffiliations.get ( c ).npe5__Organization__c )) {
									// have a chapter
									this.contacts.get ( c ).Stand_Chapter_Affiliation__c = this.teamWithChapters.get ( this.contacts.get ( c ).Stand_Team_Affiliation__c );
								}
								dirtyContact = true;
							}
						} else if ( this.contactWithTeams.containsKey ( c )) {
							if ( this.contacts.get ( c ).Stand_Team_Affiliation__c != this.contactWithTeams.get ( c ).npe5__Organization__c ) {
								// have a team mismatch, update
								this.logJobResult ( c, 'Contact', this.contactWithTeams.get ( c ).npe5__Organization__c, 'Account-Team', 'UPD-CONTACT-UPD-TEAM', 'Updating Contact to update team - original team - ' + this.contacts.get ( c ).Stand_Team_Affiliation__c);
								this.contacts.get ( c ).Stand_Team_Affiliation__c = this.contactWithTeams.get ( c ).npe5__Organization__c;
								// check to see if we can update the chapter too
								if ( this.teamWithChapters.containsKey ( this.contactWithTeams.get ( c ).npe5__Organization__c )) {
									// have a chapter
									this.contacts.get ( c ).Stand_Chapter_Affiliation__c = this.teamWithChapters.get ( this.contactWithTeams.get ( c ).npe5__Organization__c );
								}
								dirtyContact = true;
							}
						} else {
							// clear the value - we don't have a team any more
							this.logJobResult ( c, 'Contact', this.contacts.get ( c ).Stand_Team_Affiliation__c, 'Account-Team', 'UPD-CONTACT-CLEAN-TEAM', 'Updating Contact to remove team' );
							this.contacts.get ( c ).Stand_Team_Affiliation__c = null;
							this.contacts.get ( c ).Stand_Chapter_Affiliation__c = null;
							dirtyContact = true;
						}
					}
					// check Leader assignment on the Contact Record
					if ( this.contacts.get ( c ).Stand_Leader__c != null ) {
						// first check the leaderInvalid flag - this takes priority over the other evaluations
						if ( leaderInvalid ) {
							this.logJobResult ( c, 'Contact', this.contacts.get ( c ).Stand_Leader__c, 'Contact-Leader', 'UPD-CONTACT-CLEAN-LEADER', 'Updating Contact to remove leader' );
							this.contacts.get ( c ).Stand_Leader__c = null;
							dirtyContact = true;
						} else if ( this.contactWithLeaderRelationship.containsKey ( c )) {
							if ( this.contacts.get ( c ).Stand_Leader__c != this.contactWithLeaderRelationship.get ( c ).npe4__RelatedContact__c ) {
								this.contacts.get ( c ).Stand_Leader__c = this.contactWithLeaderRelationship.get ( c ).npe4__RelatedContact__c;
								this.logJobResult ( c, 'Contact', this.contactWithLeaderRelationship.get ( c ).npe4__RelatedContact__c, 'Contact-Leader', 'UPD-CONTACT-UPD-LEADER', 'Updating Contact to update leader' );
								dirtyContact = true;
							}
						} else {
							// clear the value - we don't have a leader anymore
							this.logJobResult ( c, 'Contact', this.contacts.get ( c ).Stand_Leader__c, 'Contact-Leader', 'UPD-CONTACT-CLEAN-LEADER', 'Updating Contact to remove leader' );
							this.contacts.get ( c ).Stand_Leader__c = null;
							dirtyContact = true;
						}
					}
					
					if ( dirtyContact ) {
						this.contactsForUpdate.add ( this.contacts.get ( c ));
					}
					
				}
			}*/
/*			
			// reset vars
			haveLeader = false;
			haveTeam = false;
			haveChapter = false;
			
			leaderID = null;
			leaderTeamID = null;
			teamID = null;
			chapterID = null;
			
			affObject = null;
			relObject = null;
			teamAccountID = null;
			
			membershipStatus = null;
		 	membershipType = null;
			
			didUpdate = false;
			dirtyContact = false;
			leaderInvalid = false;
			checkChapterWide = false;
			
			System.debug ( '------------]]');
		}
		
		// UPDATE RECORDS
		this.updateDML();
		
	}
		
	public void FixLeaders () {
		// ================ EXECUTION ================== 
		// LIT Updates
		// only update leaders that have followers
		Date currentLITStartDate = null;
		Date relStartDate = null;
		Date affStartDate = null;
		Integer dayCount = 0;
		String leaderType = '';
		Integer followerCount = 0;
		
		for ( ID currentLeaderID : allLeaders ) {
			
			this.logJobResult ( currentLeaderID, 'Leader-Contact', null, null, 'ATTEMPT-LEADER', 'Org v2 Conversion Started for Contact and Leader pair' );
			
			// check to see if this leader existed in the master Leader Contact map and we have an Affiliation to a team
			if ( this.leaderContacts.containsKey ( currentLeaderID ) && this.leadersWithAffiliations.containsKey ( currentLeaderID )) {
				
				// setup for each Leader with follower Counts
				if ( leaderFollowerCounts.containsKey ( currentLeaderID )) {
					followerCount = leaderFollowerCounts.get ( currentLeaderID );
				} else {
					followerCount = 0;
				}
			
				// calculate the level of Leadership
				if ( followerCount >= 10 ) {
					leaderType = 'Leader';
					this.logJobResult ( currentLeaderID, 'Contact-Leader', null, null, 'COUNT-UPD-CONTACT-LEADER', 'Leader Type calculated = Leader with follower count: ' + followerCount);
				} else {
					leaderType = 'Leader in Training';
					this.logJobResult ( currentLeaderID, 'Contact-Leader', null, null, 'COUNT-UPD-CONTACT-LIT', 'Leader Type calculated = Leader in Training with follower count: ' + followerCount );
				}
				
				// calculate start dates for LIT
				relStartDate = leaderStartDates.get ( currentLeaderID );
				affStartDate = leaderAffiliationStartDate.get ( currentLeaderID );
				
				if (( relStartDate != null ) && ( affStartDate != null )) {
					// we have both values, do a compare
					dayCount = relStartDate.daysBetween ( affStartDate );
					if ( dayCount < 0 ) {
						// relStartDate is after affStartDate
						currentLITStartDate = affStartDate;
						System.debug ( '============  LIT Start Date ::: ' + currentLITStartDate + ' << AffDate Calced');
					} else {
						// relStartDate is before or equal to affStartDate
						currentLITStartDate = relStartDate;
						System.debug ( '============  LIT Start Date ::: ' + currentLITStartDate + ' << RelDate Calced ');
					}
				} else if (( affStartDate == null ) && ( relStartDate == null )) {
					// we absolutely do not have a date - need to default
					// 6/28/2012 SKT - default this case to current Membership Start Date
					currentLITStartDate = this.leaderContacts.get ( currentLeaderID ).Membership_Start_Date__c;
					if ( currentLITStartDate == null ) {
						currentLITStartDate = Date.newInstance ( 2000, 1, 1 );
						this.logJobResult ( currentLeaderID, 'Contact-Leader', null, null, 'EX-LIT-START-DEFAULT', 'Exception:: Start date had to be defaulted ' + currentLITStartDate );
	
					}
					this.logJobResult ( currentLeaderID, 'Contact-Leader', null, null, 'EX-LIT-START-DATE', 'Exception:: Start date had to be derrived from Membership Start Date - Contact-Leader ID: ' + currentLeaderID + ' LIT / Membership Start Date: ' + currentLITStartDate );
				} else if ( relStartDate == null ) {
						// use the affStartDate
						currentLITStartDate = affStartDate;
						System.debug ( '============  LIT Start Date ::: ' + currentLITStartDate + ' << AffDate ');
				} else if ( affStartDate == null ) {
						// use the relStartDate
						currentLITStartDate = relStartDate;
						System.debug ( '============  LIT Start Date ::: ' + currentLITStartDate + ' << RelDate ');
				} 
				
				// write the dates
				this.leaderContacts.get ( currentLeaderID ).LiT_Start_Date__c = currentLITStartDate;
				System.debug ( '============  LIT Start Date ::: ' + currentLITStartDate );
				if ( leaderType == 'Leader' ) {
					// SKT 6/28/2012
					// By default we will copy the LIT start date to the Leader start date if the Leader is a Leader
					this.leaderContacts.get ( currentLeaderID ).Leader_Start_Date__c = currentLITStartDate;
				}
				
				// write the leader type
				this.leaderContacts.get ( currentLeaderID ).Leader_Type__c = leaderType;
				
				// write the number of members
				this.leaderContacts.get ( currentLeaderID ).Number_of_Followers__c = followerCount;
				
				// write the team to the leader-contact record
				this.leaderContacts.get ( currentLeaderID ).Stand_Team_Affiliation__c = leadersWithAffiliations.get ( currentLeaderID ).npe5__Organization__c;
				
				// add the contact record to the master DML update list for contacts
				contactsForUpdate.add ( this.leaderContacts.get ( currentLeaderID ));
				
				this.logJobResult ( currentLeaderID, 'Contact-Leader', null, null, 'UPDATE-CONTACT-LEADER', 'Leader Update - Contact ID: ' + currentLeaderID + ' Leader Type: ' + this.leaderContacts.get ( currentLeaderID ).Leader_Type__c + ' Start Date: ' + this.leaderContacts.get ( currentLeaderID ).LiT_Start_Date__c );
	
			} else {
				// execption - we didn't have a LeaderContact???
				if ( this.leadersWithAffiliations.containsKey ( currentLeaderID ) == false ) {
					this.logJobResult ( currentLeaderID, 'Contact-Leader', null, null, 'EX-UPDATE-CONTACT-LEADER-TEAM', 'Could not update LeaderContact due to lack of Team Leader affiliation ' + currentLeaderID );
				} else { 
					this.logJobResult ( currentLeaderID, 'Contact-Leader', null, null, 'EX-UPDATE-CONTACT-LEADER', 'Could not find LeaderContact to update Contact ID: ' + currentLeaderID + ' LiT Start Date: ' + currentLITStartDate );
				}
			}
			
			System.debug ( '============  LIT INFO ==> FOR Contact ID: ' + currentLeaderID + ' Member Follower Count: ' + followerCount + '  Start Date: ' + currentLITStartDate);
			
			// reset vars
			followerCount = 0;
			relStartDate = null;
			affStartDate = null;
			dayCount = 0;
			currentLITStartDate = null;
			leaderType = '';
		}
		
		// UPDATE RECORDS
		this.updateDML();
		
	}
	
	public void FixMemberships() {
		// Method to fix membership data related to the organizing model
		// Relies on Affiliations to be completely updated before running
		// Updates:
		//		Team
		//		Leader flag
		//		Assigned Leader
		
		// ================= PREP ======================
		// build list of contacts indexed by memberships
		
		list < Membership__c > memberships = null;
		
		// master list of Membership for manipulation and updating in DML
		memberships = new list < Membership__c > ( [ SELECT ID, Contact__c, Stand_Team__c, Team_Leader__c, Leader__c, Contact__r.Stand_Team_Affiliation__c, Contact__r.Stand_Leader__c, Contact__r.Leader_Type__c FROM Membership__c WHERE Membership_State__c = : this.stateCode AND ( Status2__c = 'Active' OR Status2__c = 'Lapsed' ) ] );
		
		Boolean isDirty = false;
		Boolean matchLeaderType = false;
		ID matchTeam = null;
		ID matchLeader = null;

		for ( Membership__c m : memberships ) {
			
			matchLeaderType = (( m.Contact__r.Leader_Type__c == 'Leader in Training' ) || ( m.Contact__r.Leader_Type__c == 'Leader' ));
			matchTeam = m.Contact__r.Stand_Team_Affiliation__c;
			matchLeader = m.Contact__r.Stand_Leader__c;
			
			this.logJobResult ( m.Contact__c, 'Contact', m.Stand_Team__c, 'TEAM-ACCOUNT', 'NOTICE-MBR-START', 'Updating Membership:  ' + m.ID + '  C Leader Type: ' + matchLeaderType + ' C Stand Team: ' + matchTeam +  ' C Stand Leader: ' + matchLeader + ' M Leader Flag: ' + m.Team_Leader__c + ' M Team: ' + m.Stand_Team__c + ' M Assigned Leader: ' + m.Leader__c );
			// case of Membership Team is blank, but Contact has a team
			if (( matchTeam != null ) && ( m.Stand_Team__c == null )) {
				// if membership object does not have a team, but the contact does, update the membership
				m.Stand_Team__c = matchTeam;
				isDirty = true;
				this.logJobResult ( m.Contact__c, 'Contact', m.Stand_Team__c, 'TEAM-ACCOUNT', 'MBR-UPDATE-TEAM', 'Updating Membership:  ' + m.ID + '  to new team account: ' + m.Stand_Team__c );
			}
			// case of Membership Leader is blank, Membership Team is not blank and Contact Leader has a value
			if (( matchLeader != null ) && ( m.Leader__c == null ) && ( m.Stand_Team__c != null )) {
				// check to see if they are a leader
				if ( matchLeaderType ) {
					// leaders cannot have leaders themselves, clear this from the membership record
					m.leader__c = null;
					this.logJobResult ( m.Contact__c, 'Contact', m.Leader__c, 'LEADER-CONTACT', 'MBR-UPDATE-LEADER-EX', 'Updating Membership: ' + m.ID + '  remove old leader account - Leaders cannot have leaders themselves ' + m.Leader__c );
				} else {
					m.Leader__c = matchLeader;
					this.logJobResult ( m.Contact__c, 'Contact', m.Leader__c, 'LEADER-CONTACT', 'MBR-UPDATE-LEADER', 'Updating Membership: ' + m.ID + '  to new leader account: ' + m.Leader__c );
				}
				isDirty = true;
			}
			// SKT 7/11/12 - found this case in Indiana
			// check for having a Membership leader has a value, but Contact Leader is blank
			if (( matchLeader == null) && ( m.Leader__c != null )) {
				// remove the leader from the membership record
				this.logJobResult ( m.Contact__c, 'Contact', m.Leader__c, 'LEADER-CONTACT', 'MBR-UPDATE-LEADER-EX', 'Updating Membership: ' + m.ID + '  remove old leader account - leader did not exist on contact record ' + m.Leader__c );
				m.leader__c = null;
				isDirty = true;
			}
			// Case for Contact is a Leader and the Membership does not have Leader checked and there is a Team on the membership
			if (( matchLeaderType ) && (( m.Team_Leader__c == null ) || ( m.Team_Leader__c == false )) && m.Stand_Team__c != null ) {
				m.Team_Leader__c = true;
				isDirty = true;
				this.logJobResult ( m.Contact__c, 'Contact', null, null, 'MBR-UPDATE-LFLAG', 'Updating Membership: ' + m.ID + ' leader flag to true' );
			}
			if ( isDirty ) {
				this.membershipsForUpdate.add ( m );
			}
			// reset
			isDirty = false;
			matchTeam = null;
			matchLeader = null;
			matchLeaderType = false;
		}
		
		// update records
		if ( this.commitData ) {
			update membershipsForUpdate;
		}
		
	}
	
	// CleanContacts() manages the clean up of Contact Chapter, Team and Membership State information
	// based on the existance of an Active Team Member or Team Leader affiliation to a Stand Team
	// Used to prep records after an analysis of Affiliations when Triggers cannot be relied on
	// and one needs to rely on Contact records to be valid
	public void CleanContacts ( String MemStatus ) {
		
		String dbQuery = '';
		
		dbQuery = 'SELECT ID, Contact__c, Status2__c, Membership_State__c FROM Membership__c WHERE Membership_State__c = \'' + this.stateCode + '\' '; 
		
		if (( MemStatus == 'Active' ) || ( MemStatus == 'Lapsed') || ( MemStatus == 'Dropped')) {
			dbQuery = dbQuery + ' AND Status2__c = \'' + MemStatus + '\'';
		}
		
		// load all memberships
		List < Membership__c > memberList = Database.query(dbQuery);
		
		Set < ID > contactIDs = new Set < ID > ();
		
		// load Contacts based on Memberships
		for ( Membership__c m : memberList ) {
			contactIDs.add ( m.Contact__c );
		}
		
		Map < ID, Contact > contactMap = new Map < ID, Contact > ( [ SELECT ID, Membership_State__c, Membership_Status__c, Stand_Chapter_Affiliation__c, Stand_Team_Affiliation__c, Stand_Leader__c, Stand_Office__c FROM Contact WHERE ID IN : contactIDs ]);
		
		// load Affiliations based on Contacts - only load Teams in the current state
		List < npe5__Affiliation__c > affTeamList = new List < npe5__Affiliation__c > ( [ SELECT ID, npe5__Contact__c, npe5__Organization__c, npe5__Status__c, npe5__Description__c, npe5__Organization__r.parentID, Team_Leader__c FROM npe5__Affiliation__c WHERE npe5__Contact__c IN : contactIDs AND npe5__Organization__r.type = 'Stand Team' AND npe5__Status__c = 'Active' AND ( Affiliation__c = 'Team Member' OR Affiliation__c = 'Team Leader' ) AND npe5__Organization__r.billingState = : this.stateCode ]);
		
		// reindex the Affiliations based on Contact ID
		Map < ID, npe5__Affiliation__c > affTeamMap = new Map < ID, npe5__Affiliation__c > ();
		
		for ( npe5__Affiliation__c a : affTeamList ) {
			affTeamMap.put ( a.npe5__Contact__c, a );
		}
		
		// loop through Memberships and update Contacts based on logic rules
		
		ID cID = null;
		Boolean contactUpdated = false;
		
		for ( Membership__c m : memberList ) {
			cID =  m.Contact__c;
			// check for a team aff
			if ( affTeamMap.containsKey ( cID )) {
				// have a valid Team affiliation - check to see if it matches the contact record
				if ( contactMap.get ( cID ).Stand_Team_Affiliation__c != affTeamMap.get ( cID ).npe5__Organization__c ) {
					// update the Team field on the Contact - it does not match current active Team affiliation
					this.logJobResult ( cID, 'Contact', affTeamMap.get ( cID ).npe5__Organization__c, 'Team-Account', 'SCRIPT-CONTACT-UPDATE-TEAM', 'Contact updated from an Active Team Affiliation - Team value changed from original Team: ' + contactMap.get ( cID ).Stand_Team_Affiliation__c );
					contactMap.get ( cID ).Stand_Team_Affiliation__c = affTeamMap.get ( cID ).npe5__Organization__c;
					contactUpdated = true;
				}
				if ( contactMap.get ( cID ).Stand_Chapter_Affiliation__c != affTeamMap.get ( cID ).npe5__Organization__r.ParentID ) {
					// update the Chapter from the related team
					this.logJobResult ( cID, 'Contact', affTeamMap.get ( cID ).npe5__Organization__r.ParentID, 'Chapter-Account', 'SCRIPT-CONTACT-UPDATE-CHAPTER', 'Contact updated from an Active Team Affiliation - Chapter value changed from original Chapter: ' + contactMap.get ( cID ).Stand_Chapter_Affiliation__c );
					contactMap.get ( cID ).Stand_Chapter_Affiliation__c = affTeamMap.get ( cID ).npe5__Organization__r.ParentID;
					contactUpdated = true;
				}
				if (( contactMap.get ( cID ).Stand_Leader__c != affTeamMap.get ( cID ).Team_Leader__c ) && ( affTeamMap.get ( cID ).Team_Leader__c != null )) {
					// we have a leader on the Affiliation and it does not match the Contact records
					this.logJobResult ( cID, 'Contact', affTeamMap.get ( cID ).Team_Leader__c, 'Leader-Contact', 'SCRIPT-CONTACT-UPDATE-LEADER', 'Contact updated from an Active Team Affiliation - Leader value changed from original Leader: ' + contactMap.get ( cID ).Stand_Leader__c );
					contactMap.get ( cID ).Stand_Leader__c = affTeamMap.get ( cID ).Team_Leader__c;
					contactUpdated = true;
				}
				if (( contactMap.get ( cID ).Stand_Leader__c != affTeamMap.get ( cID ).Team_Leader__c ) && ( contactMap.get ( cID ).Stand_Leader__c != null )) {
					// we have a leader on the Contact and it does not match the Affiliation records
					this.logJobResult ( cID, 'Contact', null, null, 'SCRIPT-CONTACT-REMOVE-LEADER', 'Contact updated from an Active Team Affiliation - Leader value removed due to lack of Leader on Affiliation' );
					contactMap.get ( cID ).Stand_Leader__c = affTeamMap.get ( cID ).Team_Leader__c;
					contactUpdated = true;
				}
			} else {
				// check to see if we have to clear any items on the record
				if (( contactMap.get ( cID ).Stand_Team_Affiliation__c != null ) || ( contactMap.get ( cID ).Stand_Team_Affiliation__c != null ) || ( contactMap.get ( cID ).Stand_Team_Affiliation__c != null )) {
					this.logJobResult ( cID, 'Contact', null, null, 'SCRIPT-CONTACT-CLEAR', 'Contact Team, Chapter and Leader cleared, no Team affiliation found - Original Contact Team: ' + contactMap.get ( cID ).Stand_Team_Affiliation__c + ' and Chapter: ' + contactMap.get ( cID ).Stand_Chapter_Affiliation__c + ' and Leader: ' + contactMap.get ( cID ).Stand_Leader__c );
					contactMap.get ( cID ).Stand_Team_Affiliation__c = null;
					// clear the chapter
					contactMap.get ( cID ).Stand_Chapter_Affiliation__c = null;
					// clear the leader
					contactMap.get ( cID ).Stand_Leader__c = null;
					contactUpdated = true;
				}
			}
			
			if ( !contactUpdated ) {
				this.logJobResult ( cID, 'Contact', null, null, 'SCRIPT-CONTACT-VALID', 'No updates made to contact' );
			}
			contactUpdated = false;
		}
		
		// update records
		if ( this.commitData ) {
			update contactMap.values();
		}
	}
	
	
	public void UpdateStateWideAffiliations () {
	
		// Any member that is lapsed or active
		// that does not have a Team affiliation
		// should be affiliated to the State Wide Team
		
		Boolean errorState = false;
		
		// load up Affiliations
		List < npe5__Affiliation__c > aList = new List < npe5__Affiliation__c > ( [ SELECT npe5__Contact__c FROM npe5__Affiliation__c WHERE npe5__Contact__r.Membership_State__c = : this.stateCode AND ( Affiliation__c = 'Team Member' OR Affiliation__c = 'Team Leader' ) AND ( npe5__Status__c = 'Active' ) ]);
		
		// pull out the contacts that have Active Team Member or Team Leader affiliations
		Set < ID > contactsWithAffiliations = new Set < ID > ();
		for ( npe5__Affiliation__c a : aList ) {
			contactsWithAffiliations.add ( a.npe5__Contact__c );
		}
		
		// load up list of members that are not in the contactsWithAffiliations set
		List < Membership__c > mList = new List < Membership__c > ( [ SELECT ID, Contact__c, Status2__c, Start_Date__c FROM Membership__c WHERE ( Status2__c = 'Active' OR Status2__c = 'Lapsed' ) AND Membership_State__c = : this.stateCode AND Contact__c NOT IN : contactsWithAffiliations ]);
		
		// find the state wide team
		String stateWideTeamName = stateCode + ' State Wide Team';
		ID stateWideTeamID = null;
		
		System.debug ( 'Looking for State Wide Team - ' + stateWideTeamName );
		
		List < Account > stateWideTeams = new List < Account > ( [ SELECT ID, Name FROM Account WHERE type = 'Stand Team' AND Name = : stateWideTeamName ]);
		
		if ( stateWideTeams.size() == 1 ) {
			// found the team
			stateWideTeamID = stateWideTeams[0].ID;
		} else {
			// Error condition, did not find state
			System.debug ( ' Did not find a State Wide Team or found more than one - ending execution ');
			errorState = true;
		}
		
		// lets do some work
		List < npe5__Affiliation__c > affInsert = new List < npe5__Affiliation__c > ();
		npe5__Affiliation__c aff = null;
		string descText = 'Automated creation ' + date.today() + ' for Organizer Conversion batch';
		
		if ( !errorState ) {
			for ( Membership__c m : mList ) {
				// create a new affiliation
				aff = new npe5__Affiliation__c ( npe5__Contact__c = m.Contact__c, npe5__StartDate__c = m.Start_Date__c, npe5__Organization__c = stateWideTeamID, npe5__Description__c = descText, affiliation__c = 'Team Member', type__c = 'Organizing');
				affInsert.add ( aff );
				this.logJobResult ( m.Contact__c, 'Contact', stateWideTeamID, 'Team-Account', 'SCRIPT-STATEWIDE-TEAM-AFF-CREATE', 'New Affiliation created to State Wide Team with start date ' + m.Start_Date__c );
			}
		}
		
		if ( this.commitData ) {
			insert affInsert;
		}
		
	}
	// Private Method to update DML containers
	// Note: DML lists are cleared after execution
	
	private void updateDML () {
		// update records
		// UPDATE RECORDS
		
		if ( this.commitData ) {
			
			// Update Contacts
			if (( this.commitStage == 0 ) || ( this.commitStage == 1 )) {
				update contactsForUpdate;
				System.debug ( '============ TOTAL CONTACT RECORDS FOR UPDATE => ' + contactsForUpdate.size() );
			}
			
			// Update and Insert Affiliations
			if (( this.commitStage == 0 ) || ( this.commitStage == 2 )) { 
				upsert affiliationsForUpdate.values();
				System.debug ( '============ TOTAL AFFILIATION RECORDS FOR UPSERT => ' + affiliationsForUpdate.size() );
			}
			
			// Delete Old Relationships (Leader + Follower)
			
			// // delete relationshipsForDelete;
			System.debug ( '============ TOTAL RELATIONSHIP RECORDS FOR DELETE => ' + relationshipsForDelete.size() );
			
			
			// Delete Old Affiliations - Chapter Contact
			if (( this.commitStage == 0 ) || ( this.commitStage == 3 )) { 
				System.debug ( '============ TOTAL AFFILIATION RECORDS FOR DELETE => ' + affiliationsForDelete.size() );
				delete affiliationsForDelete;
			}
			
		} else { 
			System.debug ( '================ SIMULATED WRITE MODE ================================' );
			System.debug ( '============ TOTAL CONTACT RECORDS FOR UPDATE (SIMULATED) => ' + contactsForUpdate.size() );
			System.debug ( '============ TOTAL AFFILIATION RECORDS FOR UPSERT (SIMULATED)  => ' + affiliationsForUpdate.size() );
			System.debug ( '============ TOTAL RELATIONSHIP RECORDS FOR DELETE (SIMULATED) => ' + relationshipsForDelete.size() );
			System.debug ( '============ TOTAL AFFILIATION RECORDS FOR DELETE (SIMULATED)  => ' + affiliationsForDelete.size() );
			System.debug ( '============ TOTAL MEMBERSHIP RECORDS FOR UPDATE (SIMULATED)  => ' + membershipsForUpdate.size() );
		}
		
		// clear the DML lists for future use
		contactsForUpdate.clear();
		affiliationsForUpdate.clear();
		relationshipsForDelete.clear();
		affiliationsForDelete.clear();
		membershipsForUpdate.clear();
	}
*/	
}