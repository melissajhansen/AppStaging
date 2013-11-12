// UserStats.cls
// Primary controller object for the User Stats and Contact Search pages
// Implements a custom object called ContactDetails which presents Contact data
// for the presentation tier
// Also contains handler functions to populate drop down lists on UI input forms

global with sharing class UserStats implements ObjectPaginatorListener
{
	// drop down selector variables
    public string strStateId {get; set;}
    public string strChapterId {get; set;}
    public string strTeamId {get; set;}
    
    public string strStateName {get; set;}
    public string strStateAbbrev {get; set;}
    public string strChapterName {get; set;}
    public string strTeamName {get; set;}
    
    string strSelectedStateId, strSelectedChapterId, strSelectedTeamId;
    
    List<Account> lstAllChapters = new List<Account>();
    List<Account> lstAllTeams = new List<Account>();
    
    // UI control variables
    public boolean blnUserStats {get; set;}
    public boolean blnMembersList {get; set;}
    public boolean blnSingleState { get; set; }
    
    // added 6/17 SKT
    // feature to allow Organizers to see links in Contact display
    public boolean blnAllowResultLinks { get; set; }
    
    // added 7/16 SKT
    // control linking of State, Chapter and Team Header display
    public boolean blnShowStateOfficeLink { get; set; }
    public boolean blnShowChapterLink { get; set; }
    public boolean blnShowTeamLink { get; set; }
    
    // user variables
    string strContactId = '';
    public string strContactName {get; set;}
    public string strUserDivision { get; set; }
        
	// user stats - tbd    
	// below is commented out until needed for UserStatsDetails
//    public List<UserStatDetails> lstUserStatDetails {get; set;}
    public string strMembersCount {get; set;}

	// data grid controls
    public string strSortField {get; set;}
    public string strSortDirection {get; set;}

	// CSV download variables    
    public string strFileName {get;set;}
    public string strFileHeader {get;set;}
    public string strDownloadData { get; set; }
    
	// Main containers for display data for grid
	global List < ContactDetails > lstContactDetails = new List < ContactDetails > ();
    global List < ContactDetails > ContactDisplay {get; private set;}
    
    // debug support -- REMOVE THIS --
    public string strQueryDebug;
    public string strOrderByDebug;
    
    // SKT 11/19/2012
    public boolean blnVIPAccess;
    
	// Paginator
    global ObjectPaginator paginator { get; private set; }
    global Integer pageNumber {get; set;}
    
    global void handlePageChange ( List <Object> newPage) {
    	ContactDisplay.clear();
    	if ( newPage != null ) {
    		for ( Object c : newPage ) {
    			ContactDisplay.add ( ( ContactDetails ) c );
    		}
    	}
    }
    
    global class ContactDetails // -- this is newly created to test out a differnt way to display information
    {
    	// ----- CONTACT DATA -----
    	public Id Id { get; set; }
    	public string strConstituentId { get; set; }
        public string strFirstName {get; set;}
        public string strLastName {get; set;}
        public string strName { get; set; }
        public string strNameWithLeaderType { get; set; }
        public string strPrefEmail {get; set;}
        public string strDoNotEmail {get; set;}
        public string strPrefPhone {get; set;}
        public string strMobilePhone {get; set;}
        public string strHomePhone {get; set;}
        public string strDoNotCall {get; set;}
        public string strStreet {get; set;}
        public string strCity {get; set;}
        public string strState {get; set;}
        public string strZip {get; set;}
        public string strDoNotContact {get; set;}
        public string strEducatorType {get; set;}
        public string strContactState { get; set; }
        public string strWorkPhone {get; set;}
        public string strOtherPhone {get; set;}        
        
        // ----- MEMBERSHIP DATA -----
        public string strMembershipStatus {get; set;}
        public datetime dtMembershipExpiration {get; set;}
        public string strMembershipState {get; set;}
        public string strMembershipChapter {get; set;}
        public string strMembershipChapterId {get; set;}
        public string strMembershipTeam {get; set;}
        public string strMembershipTeamId {get; set;}
        public string strMembershipStateAffiliation {get; set;}
        public string strMembershipID { get; set; }
        public string strMembershipType { get; set; }
        public decimal decLastMembershipGiftAmount { get; set; }
        
        // ----- AFFILIATION DATA -------
        public string strLeaderContactName { get; set; }
        public string strLeaderContactId { get; set; }
        public string strChapterRoles { get; set; }
        public string strTeamRoles { get; set; }
        // ----- VIP Control --------------
        public string strContactType { get; set; }
        public string strVIPRecord { get; set; }
        // ----- MISC DATA -------
        public string strSpecialRequests { get; set; }
        public string strLeaderType {get; set;} 
        public string strOrganizer { get; set; } 
        public string strOrganizerId { get; set; }
        
        public boolean emailIsScrambled {
	    	get {
	    		if(strPrefEmail != null && strPrefEmail != '') {
	    			if(strPrefEmail.contains('⬚⬚')) {
	    				return true;
	    			} else {
	    				return false;
	    			}
	    		} else {
	    			return false;
	    		}
	    	}
	    	private set;
	    }
    }

    global PageReference skipToPage()
    {
        this.paginator.skipToPage(pageNumber);
        return null;
    }

    //End for paging

/*
// This is commented out until it is needed for UserStatDetails    
    class UserStatDetails
    {
        public string strAccountId {get; set;}
        public string strAccountName {get; set;}
        public string strRole {get; set;}
        public integer intNumMembers {get; set;}
    }
*/
    
    // ---- CONSTRUCTOR --------
    public UserStats(ApexPages.StandardController controller)
    {
        this.blnUserStats = true;
        this.blnMembersList = false;
        
        
        List < User > lstUser = new List < User > ();
        List < Account > lstAccount = new List < Account > ();
        String strQuery = '';
        
        /*  
        // This is commented out until it is needed for UserStatDetails  
        List<Contact> lstContact = [Select Id, Name from Contact where Stand_Employee_User__c =: UserInfo.getUserId()];
        if (lstContact != null && lstContact.size() > 0)
        {
            strContactId = lstContact[0].Id;
            strContactName = lstContact[0].Name;
        }
        ShowUserStats();
        strSortField = 'npe5__Contact__r.Name';
        strSortDirection = 'Desc';
        */
        
        // section to determine states visible to user
        // check the User->Division to see what state they should have as options
        // SKT 11/19/2012
        // Load user's profile name for VIP access determination
        lstUser = [ SELECT Division, ProfileId, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        	
        if ( lstUser != null ) {
       		this.strUserDivision = lstUser[0].Division;
       	}
        	
       	if ( this.strUserDivision == 'National' ) {
       		this.blnSingleState = false;
       	} else if ( this.strUserDivision != '' ) {
       		this.blnSingleState = true;
       		// load up the single state ID
       		strQuery = 'Select Id, Name from Account where Type = \'Stand Affiliate State\' and ' +                             
           				'State_Abbreviation__c = \'' + this.strUserDivision + '\' order by Name LIMIT 1';
           	lstAccount = Database.query(strQuery);
        
	        if (lstAccount != null && lstAccount.size() > 0)
	        {
	            this.strStateId = lstAccount[0].Id;
	            this.strStateName = lstAccount[0].Name;
	        }
        }
        
        // SKT 6/17
        // Determine if the user should see links or not
        // SKT 11/19/2012
        // Everyone should receive links now
        blnAllowResultLinks = true;
        
        // SKT 11/19/2012
        // Evaluate VIP
        if ( lstUser[0].Profile.Name.Contains ( 'VIP' ) ) {
        	this.blnVIPAccess = true;
        } else if ( lstUser[0].Profile.Name.Contains ( 'RESTRICTED' ) ) {
        	this.blnVIPAccess = false;
        } else if ( lstUser[0].Profile.Name == 'SYSTEM ADMINISTRATOR' ) {
        	this.blnVIPAccess = true;
        } else {
        	this.blnVIPAccess = false;
        }
    }
    
    public void ResetChapterTeam()
    {
        strChapterId = '';
        strTeamId = '';
        strChapterName = '';
        strTeamName = '';
    }

    public void ResetTeam()
    {
        strTeamId = '';
        strTeamName = '';
    }

    public List<selectOption> getStateNames
    {
        get
        {
            List<selectOption> lstState = new List<selectOption>();
            List<Account> lstAccount = new List<Account>();
            List<Membership__c> lstMembership = new List<Membership__c>();
            string strMembershipState = '';
            string strQuery = '';
            List<User> lstUser = new List<User>();
            
            if ( this.blnSingleState == false ) {
           		// load all states
           		strQuery = 'Select Id, Name from Account where Type = \'Stand Affiliate State\' order by Name';
           		// load up the accounts - aka list of states
	            lstAccount = Database.query(strQuery);
	            
	            lstState.Add(new SelectOption('', 'Select a State'));
	            if (lstAccount != null && lstAccount.size() > 0)
	            {
	                for(Account objAccount : lstAccount)
	                {
	                    lstState.Add(new SelectOption(objAccount.Id, objAccount.Name));
	                }
	            }
            } else {
            	lstState.Add(new SelectOption(this.strStateId, this.strStateName));
            }
			return lstState;            
        }
        private set;
    }

    public List<selectOption> getChapterNames
    {
        get
        {
            List<selectOption> lstChapter = new List<selectOption>();
            if (strStateId != '' && strStateId != null)
                lstAllChapters = [Select Id, Name from Account where Type = 'Stand Chapter' and Parent.Id = : strStateId order by Name];
            lstChapter.Add(new SelectOption('', 'Select a Chapter'));
            for(Account objAccount : lstAllChapters)
            {
                lstChapter.Add(new SelectOption(objAccount.Id, objAccount.Name));
            }
            // add Unassigned option to Chapter picklist
            // query looks for the 'none' value returned to pull those without an affiliation
            lstChapter.Add(new SelectOption('none', 'Unassigned'));            

            return lstChapter;
        }
        private set;
    }

    public List<selectOption> getTeamNames
    {
        get
        {
            List<selectOption> lstTeam = new List<selectOption>();
            
            if (strChapterId != '' && strChapterId != null)
                lstAllTeams = [Select Id, Name from Account where Type = 'Stand Team' and Parent.Id = : strChapterId order by Name];
            lstTeam.Add(new SelectOption('All', 'All Teams'));
            for(Account objAccount : lstAllTeams)
            {
                lstTeam.Add(new SelectOption(objAccount.Id, objAccount.Name));
            }
            // add Unassigned option to Team picklist
            // query looks for the 'none' value returned to pull those without an affiliation
            // only add this if Chapter selected is NOT Unassigned, which has a value of 'none'
			if (strChapterId != 'none')
			{
	            lstTeam.Add(new SelectOption('none', 'Unassigned'));
			}
            return lstTeam;
        }
        private set;
    }

// currently unused
// This is commented out until it is needed for UserStatDetails  
/*    public PageReference ShowUserStats()
    {
        List<Id> lstAccountId = new List<Id>();
        UserStatDetails objUserStatDetails;
        lstUserStatDetails = new List<UserStatDetails>();
        List< npe5__Affiliation__c > lstAffiliation = new List < npe5__Affiliation__c > ();
        
        blnUserStats = true;
        blnMembersList = false;
        lstAffiliation = [Select npe5__Organization__r.Id, npe5__Organization__r.Name, Affiliation__c
                            from npe5__Affiliation__c where npe5__Contact__c =: strContactId
                            and npe5__Status__c = 'Active' order by npe5__Organization__r.Name desc];
        
        for (npe5__Affiliation__c objAffiliation : lstAffiliation)
        {
            lstAccountId.Add(objAffiliation.npe5__Organization__r.Id);
        }

        List <AggregateResult> lstContactCount = [Select Count(npe5__Contact__r.Id), npe5__Organization__r.Id
                    from npe5__Affiliation__c where npe5__Status__c = 'Active' 
                    and npe5__Organization__r.Id in : lstAccountId
                    group by npe5__Organization__r.Id];

        for (npe5__Affiliation__c objAffiliation : lstAffiliation)
        {
            objUserStatDetails = new UserStatDetails();
            objUserStatDetails.strAccountId = objAffiliation.npe5__Organization__r.Id;
            objUserStatDetails.strAccountName = objAffiliation.npe5__Organization__r.Name;
            objUserStatDetails.strRole = objAffiliation.Affiliation__c;
            
            for (AggregateResult ar : lstContactCount)
            {
                if (ar.Id == objAffiliation.npe5__Organization__r.Id)
                    objUserStatDetails.intNumMembers = integer.valueof(ar.get('expr0'));
            }
            lstUserStatDetails.Add(objUserStatDetails);
        }
        return null;
    }
*/    
    // ---- Entry methods to initiate the loading of members into the ContactDisplay list
    
    public PageReference ShowMembers ()
    {
    	PrepareLoadMembers ( 'screen' );
        return null;
    }
    
    public PageReference SortMembers ()
    {
    	LoadMembers ( 'screen' );
        return null;
    }
    
    public PageReference DownloadMembers()
    {
    	String strOutput = '';
    	
        PrepareLoadMembers( 'download' );
        
        DateTime dtNow = DateTime.now();
        strFileName = 'Members' + dtNow.month() + dtNow.day() + dtNow.year() + dtNow.hour() + 
                		dtNow.minute() + dtNow.second();
        strFileHeader = strMembersCount;
        
        // build the export string to contain all of the records
        // also purge each row as we execute
        
        // build the column header
        strOutput = '"First Name","Last Name","Preferred Email","Preferred Phone","Mobile Phone","Membership Team","Organizer","Leader","Membership Status","Membership Type","Last Membership Gift Amount","Membership Expiration","Educator Type","Constituent ID","Leader Status"';
        strOutput = strOutput + '\r\n';
        // build data
        for ( ContactDetails c : ContactDisplay ) {
        	// write to the string the fields that we want to export
			strOutput = strOutput + '"' + c.strFirstName + '",';       
			strOutput = strOutput + '"' + c.strLastName + '",';
			strOutput = strOutput + '"' + c.strPrefEmail + '",';	
			strOutput = strOutput + '"' + c.strPrefPhone + '",';
			strOutput = strOutput + '"' + c.strMobilePhone + '",';
			strOutput = strOutput + '"' + c.strMembershipTeam + '",';
			strOutput = strOutput + '"' + c.strOrganizer + '",';
			strOutput = strOutput + '"' + c.strLeaderContactName + '",';
			strOutput = strOutput + '"' + c.strMembershipStatus + '",';
			strOutput = strOutput + '"' + c.strMembershipType + '",';
			strOutput = strOutput + '"' + c.decLastMembershipGiftAmount + '",';
			strOutput = strOutput + '"' + c.dtMembershipExpiration + '",';
			strOutput = strOutput + '"' + c.strEducatorType + '",';
			strOutput = strOutput + '"' + c.strConstituentId + '",';
			strOutput = strOutput + '"' + c.strLeaderType + '"';			
			
        	// write a carriage return
        	strOutput = strOutput + '\r\n';
        	
        }
        
        // clear out all nulls
		strOutput = strOutput.replace( '"null"', '""');
		
		strOutput = strOutput.replace( '<br/>', ',');
		strOutput = strOutput.replace( '⬚', '*');
			
        // delete ContactDisplay to save on space
        ContactDisplay.clear();
        
        // move to the public variable
        this.strDownloadData = strOutput;
        
        return Page.UserStatsExport;
    }
    
    public PageReference PrintMembers()
    {
        PrepareLoadMembers( 'download' );
        
        DateTime dtNow = DateTime.now();
        strFileName = 'Members' + dtNow.month() + dtNow.day() + dtNow.year() + dtNow.hour() + 
                dtNow.minute() + dtNow.second();
        strFileHeader = strStateName;
        
        if (strChapterName != '' && strChapterName != null)
        {
            strFileHeader += ' - ' + strChapterName;
        }
        if (strTeamName != '' && strTeamName != null)
        {
            strFileHeader += ' - ' + strTeamName;
        }
        if (strMembersCount != '')
        {
            strFileHeader += strMembersCount;
        }
        
        return Page.UserStatsPrint;
    }
    
    public void PrepareLoadMembers( String strDisplayType ) 
    {
    	// Valid options for strDisplayType
    	// Screen - output to screen + pagination
    	// Print - output to screen w/o pagination
    	// Download - download w/o pagination
    	
        blnUserStats = false;
        
        // SKT 7/16
        // Reset the Display Link indicators
        this.blnShowStateOfficeLink = false;
        this.blnShowChapterLink = false;
        this.blnShowTeamLink = false;
        
        Account objAccount = new Account();

		//System.debug ( 'Inside of SHOW Members ----------' );
		//System.debug ( ' #########  state => ' + strStateId );
		//System.debug ( ' #########  chapter => ' + strChapterId );
		//System.debug ( ' #########  team => ' + strTeamId );
		
		// Load Account Numbers as selected by the user
        if (strStateId != '' && strStateId != null)
        {
            blnMembersList = true;
            objAccount = [Select Name, State_Abbreviation__c from Account where Id =: strStateId];
            strStateName = objAccount.Name;
            strStateAbbrev = objAccount.State_Abbreviation__c;
            strSelectedStateId = strStateId;
            blnShowStateOfficeLink = true;
        }
// this is unneeded, since users must select a state
//        else
//        {
//            strStateName = '';
//            strSelectedStateId = '';
//        }
        if (strChapterId != '' && strChapterId != null)
        {
// this is unneeded, since users must select a chapter
//            if (strChapterId == 'All')
//            {
//                strChapterName = 'All Chapters';
//            }
//            else
//            {
            	// filter for Unassigned chapter - 'none'
            	if (strChapterId == 'none')
            	{
            		strChapterName = 'Unassigned';
            	}
            	else
            	{
                	objAccount = [Select Name from Account where Id =: strChapterId];
                	strChapterName = objAccount.Name;
                	blnShowChapterLink = true;
            	}            	
//            }
            strSelectedChapterId = strChapterId;
        }
//        else
//        {
//            strChapterName = '';
//            strSelectedChapterId = '';
//        }
        if (strTeamId != '' && strTeamId != null)
        {
            if (strTeamId == 'All' && strChapterId != 'All')
            {
                strTeamName = 'All Teams';
            }
            else
            {
            	// filter for Unassigned team - 'none'
            	if (strTeamId == 'none')
            	{
            		strTeamName = 'Unassigned';
            	}
            	else
            	{
                	objAccount = [Select Name from Account where Id =: strTeamId];
                	strTeamName = objAccount.Name;
                	blnShowTeamLink = true;
            	}
            }
            strSelectedTeamId = strTeamId;
        }
//        else
//        {
//            strTeamName = '';
//            stredTeamId = '';
//        }
        
        // execute the sort and load
        LoadMembers ( strDisplayType );
        
    }
    
    public void LoadMembers ( string strOutput )
    {
    	
        ContactDetails objContactDetails = new ContactDetails ();
        Map < Id, ContactDetails > mapContactDetails = new Map < Id, ContactDetails > ();
        List<npe5__Affiliation__c> lstAffiliation = new List < npe5__Affiliation__c > ();
        
        //List < Membership__c > lstMembership = new List < Membership__c > ();
        // 7/5 SKT
        // Adding capability to link to Membership records
        List < Membership__c > lstMemberships = null;
        map < ID, Membership__c > memberships = new map < ID, Membership__c > (); // indexed by Contact ID
        
        String strWhereMem = '';
        
        List < Contact > mlstContact = new List < Contact > ();
        List < Account > lstAccount = new List < Account > ();
        List < Id > lstContactId = new List < Id > ();
        integer intNumMembers = 0;
        string strQuery = '';
        string strQueryType = '';
        string strWhere = '';
        string strOrderBy = '';
        string leaderString = '';
        
        mlstContact = new List < Contact > ();
        List < npe4__Relationship__c > lstLeader = new List < npe4__Relationship__c > ();
        
        System.debug ( 'Inside of LoadMembers for :strOutput ----------' );
        
        // determine the sort type
        if ( strSortField == 'objContact.strName') {
        	strOrderBy =  'LastName ' + strSortDirection;
        }
        
        if ( strSortField == 'objContact.strPrefEmail') {
        	strOrderBy =  'Email ' + strSortDirection;
        }
        
        if ( strSortField == 'objContact.strPrefPhone') {
        	strOrderBy = 'Phone ' + strSortDirection;
        }
        
        if ( strSortField == 'objContact.strMobilePhone') {
        	strOrderBy = 'MobilePhone ' + strSortDirection;
        }
        
        if ( strSortField == 'objContact.strMembershipStatus') {
        	strOrderBy = 'Membership_status__c ' + strSortDirection;
        }
        
        if ( strSortField == 'objContact.strMembershipType') {
        	strOrderBy = 'Membership_Type__c ' + strSortDirection;
        }
        
        if ( strSortField == 'objContact.decLastMembershipGiftAmount'){
        	strOrderBy = 'Last_Membership_Gift_Amount__c ' + strSortDirection;
        }
        
        if ( strSortField == 'objContact.strMembershipTeam') {
        	strOrderBy = 'Stand_Team_Affiliation__r.name ' + strSortDirection;
        }
        
        if ( strSortField == 'objContact.strLeaderContactName') {
        	strOrderBy = 'Stand_Leader__r.LastName ' + strSortDirection;
        }
        
        strOrderByDebug = strOrderBy;
        
        // NEW method of pulling contact data
        // SKT 7/19/2012
        // Load Leader and LIT stop dates for D-01117
        strQuery =  'SELECT Id, FirstName, LastName, RecordType.Name, Name, Stand_Team_Organizer__c, Stand_Team_Organizer__r.Name, DoNotCall, Do_Not_Mail__c, Do_Not_Contact__c, Do_Not_Text__c, HasOptedOutOfEmail, Leader_Type__c, Leader_Stop_Date__c, LiT_Stop_Date__c, Email, Phone, MobilePhone, HomePhone, OtherPhone, ' +
        			'Stand_Office__c, Stand_Chapter_Affiliation__r.name, Stand_Team_Affiliation__r.name, ' +
        			'MailingStreet, MailingCity, MailingState, MailingPostalCode, ' +
        			'Educator_Type__c, Membership_State__c, Membership_status__c, Membership_Type__c, Last_Membership_Gift_Amount__c, Membership_Expiration__c, Stand_Leader__r.name, ' +
        			'Constituent_ID__c ' +
        			'FROM Contact';
        			
        // determine the querytype (Team, Chapter or State) and build list of contacts
        
        if (( strSelectedTeamId != 'All' ) && ( strSelectedTeamId != null ) && ( strSelectedTeamId != '' )) {
        	// have a team
        	strQueryType = 'TEAM';
        	// filter for Unassigned Team - 'none'
        	if (strTeamId == 'none')
        	{
        		if (strChapterId == 'none')
        		{
        			strWhere = strWhere + ' (Stand_Team_Affiliation__r.id = null and Stand_Chapter_Affiliation__r.id = null)';
        		}
        		else
        		{
        			strWhere = strWhere + ' (Stand_Team_Affiliation__r.id = null and Stand_Chapter_Affiliation__r.id = \'' + strChapterId + '\')';
        		}
        	}
        	else
        	{
        		strWhere = strWhere + ' (Stand_Team_Affiliation__r.id = \'' + strTeamId + '\' and Stand_Chapter_Affiliation__r.id = \'' + strChapterId + '\')';
        	}
        }
        
        if (( strSelectedChapterId != 'All' ) && ( strSelectedChapterId != null ) && ( strSelectedChapterId != '' )) {
        	// have a chapter
        	if ( strQueryType == '' ) {
        		strQueryType = 'CHAPTER';
        		// filter for Unassigned Chapter - 'none'
        		if (strChapterId == 'none')
        		{
        			strWhere = strWhere + ' (Stand_Chapter_Affiliation__r.id = null)';
        		}
        		else
        		{
        			strWhere = strWhere + ' (Stand_Chapter_Affiliation__r.id = \'' + strChapterId + '\')';
        		}
        	}
        }

// unneeded, since you must select a state and a chapter (at minimum)        
/*        if (( strSelectedStateId != null ) && ( strSelectedStateId != '' )) {
        	// have a state
        	if ( strQueryType == '' ) {
        		strQueryType = 'STATE';
        		strWhere = strWhere + ' (Stand_Office__c = \'' + strStateName + '\')';
        	}
        }*/
        
        // append membership status selection criteria
        strWhere = strWhere + ' AND (( Membership_Status__c = \'Active\') OR ( Membership_Status__c = \'Lapsed\'))';
        //TO DO: Remove this
        //strWhere = strWhere + ' AND ((Membership_Type__c = \'Annual\') OR (Membership_Type__c = \'Sustaining\') OR (Membership_Type__c = \'Complimentary\'))';
        //strWhere = strWhere + ' AND ((Last_Membership_Gift_Amount__c >= 1) OR (Last_Membership_Gift_Amount__c =NULL))';
        strWhereMem = strWhereMem + ' (( Status__c = \'Active\') OR ( Status__c = \'Lapsed\'))';
        // append membership state criteria
        strWhere = strWhere + ' and (Membership_State__c = \'' + strStateAbbrev + '\')';
        strWhereMem = strWhereMem + ' AND (Membership_State__c = \'' + strStateAbbrev + '\')';
        
        // append where to query
        strQuery = strQuery + ' WHERE ' + strWhere;
        
        if ( strOrderBy != '') {
        	// do a sort
        	strQuery = strQuery + ' ORDER BY ' + strOrderBy;
        }
        
        System.debug ( '************************' + ' QUERY ' + strQuery );
        
        mlstContact = Database.query ( strQuery );
        
        // 7/5 SKT
        // Load up Memberships
        lstMemberships = Database.query ( 'SELECT ID, Contact__c FROM Membership__c WHERE ' + strWhereMem );
		// reindex list of memberships into a map that is Contact ID based
		for ( Membership__c m : lstMemberships ) {
			memberships.put ( m.Contact__c, m );
		}        
		
        strQueryDebug = strQuery;
        
        // iterate through contact details to build ContactDetails
        ID memID = null;
        
        for ( Contact c : mlstContact ) {
        	// retrieve the map object
        	objContactDetails = new ContactDetails ();
        	
        	// build the leaderString
        	// SKT 7/19/2012
        	// Evaluate stop dates for D-01117
        	if (( c.Leader_Type__c == 'Leader' ) && ( c.Leader_Stop_Date__c == null )) {
        		leaderString = ' (Leader)';
        	} else if (( c.Leader_Type__c == 'Leader In Training' ) && ( c.LiT_Stop_Date__c == null )) {
        		leaderString = ' (Leader In Training)';
        	} else {
        		leaderString = '';
        	}
        	
        	// 7/5 SKT
        	// Load the Membership ID
        	if ( memberships.containsKey ( c.ID )) {
        		memID = memberships.get ( c.ID ).ID;
        	} else {
        		memID = null;
        	}
        	
        	// update the map object
        	objContactDetails.Id = c.Id;
        	objContactDetails.strName = c.Name;
        	objContactDetails.strNameWithLeaderType = c.Name + leaderString;
        	objContactDetails.strFirstName = c.FirstName;
        	objContactDetails.strLastName = c.LastName;
        	objContactDetails.strPrefEmail = c.Email;
        	objContactDetails.strPrefPhone = c.Phone;
        	objContactDetails.strMobilePhone = c.MobilePhone;
        	objContactDetails.strHomePhone = c.HomePhone;
        	objContactDetails.strContactState = c.Stand_Office__c;
       		objContactDetails.strMembershipChapter = c.Stand_Chapter_Affiliation__r.name;
       		objContactDetails.strMembershipChapterId = c.Stand_Chapter_Affiliation__c;
       		objContactDetails.strMembershipTeam = c.Stand_Team_Affiliation__r.name;
       		objContactDetails.strMembershipTeamId = c.Stand_Team_Affiliation__c;
       		objContactDetails.strMembershipID = memID;
       		objContactDetails.strStreet = c.MailingStreet;
       		objContactDetails.strCity = c.MailingCity;
       		objContactDetails.strState = c.MailingState;
       		objContactDetails.strZip = c.MailingPostalCode;
       		objContactDetails.strEducatorType = c.Educator_Type__c;
       		objContactDetails.strMembershipStatus = c.Membership_Status__c;
       		objContactDetails.strMembershipType = c.Membership_Type__c;
    		objContactDetails.dtMembershipExpiration = c.Membership_Expiration__c;
    		objContactDetails.strMembershipState = c.Membership_State__c;
       		objContactDetails.strLeaderContactName = c.Stand_Leader__r.name;
       		objContactDetails.strLeaderContactId = c.Stand_Leader__c;
       		objContactDetails.strConstituentId = c.Constituent_Id__c;
       		objContactDetails.strOtherPhone = c.OtherPhone;
       		objContactDetails.strSpecialRequests = '';
       		objContactDetails.strLeaderType = c.Leader_Type__c;
       		objContactDetails.strOrganizer = c.Stand_Team_Organizer__r.Name;
       		objContactDetails.strOrganizerId = c.Stand_Team_Organizer__c;
       		objContactDetails.strContactType = c.RecordType.Name;
       		objContactDetails.strVIPRecord = 'false';
       		objContactDetails.decLastMembershipGiftAmount = c.Last_Membership_Gift_Amount__c.setScale(2);
       		       		       		
       		// Start Masking Data
       		if(c.Do_Not_Mail__c == true) {
	        	objContactDetails.strStreet = '⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚';
	        	objContactDetails.strCity = '⬚⬚⬚⬚⬚⬚';
	        	objContactDetails.strZip = '⬚⬚⬚⬚⬚';
	        	objContactDetails.strState = '⬚⬚';
	        	objContactDetails.strSpecialRequests = 'This person\'s address is hidden because he or she has requested not to receive mail.';
	        }
	        if(c.DoNotCall == true) {
	        	if(objContactDetails.strPrefPhone != null)
	        		objContactDetails.strPrefPhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
	        	if(objContactDetails.strMobilePhone != null)
	        		objContactDetails.strMobilePhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
	        	if(objContactDetails.strHomePhone != null)
	        		objContactDetails.strHomePhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
	        	if(objContactDetails.strOtherPhone != null)
	        		objContactDetails.strOtherPhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
	        	if(objContactDetails.strSpecialRequests == '')
	        		objContactDetails.strSpecialRequests = objContactDetails.strSpecialRequests + 'This person\'s phone number is hidden because he or she has requested not to be called.';
	        	else
	        		objContactDetails.strSpecialRequests = objContactDetails.strSpecialRequests + '<br/>This person\'s phone number is hidden because he or she has requested not to be called.';
	        }
	        
	        if(c.Do_Not_Text__c == true) {
	        	if(objContactDetails.strSpecialRequests == '')
	        		objContactDetails.strSpecialRequests = objContactDetails.strSpecialRequests + 'This person has requested not to receive text messages.';
	        	else
	        		objContactDetails.strSpecialRequests = objContactDetails.strSpecialRequests + '<br/>This person has requested not to receive text messages.';
	        	if(objContactDetails.strMobilePhone != null)
        			objContactDetails.strMobilePhone = objContactDetails.strMobilePhone+' (do not text)';
	        }
	        
	        if(c.HasOptedOutOfEmail == true) {
	        	objContactDetails.strPrefEmail = '⬚⬚⬚⬚@⬚⬚⬚⬚⬚.⬚⬚⬚';
	        	if(objContactDetails.strSpecialRequests == '')
	        		objContactDetails.strSpecialRequests = objContactDetails.strSpecialRequests + 'This person\'s email address is hidden because he or she has requested not to be emailed.';
	        	else
	        		objContactDetails.strSpecialRequests = objContactDetails.strSpecialRequests + '<br/>This person\'s email address is hidden because he or she has requested not to be emailed.';
	        }
       		
       		if(c.Do_Not_Contact__c != null) {
	        	objContactDetails.strStreet = '⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚';
	        	objContactDetails.strCity = '⬚⬚⬚⬚⬚⬚';
	        	objContactDetails.strZip = '⬚⬚⬚⬚⬚';
	        	objContactDetails.strState = '⬚⬚';
	        	if(objContactDetails.strPrefPhone != null)
	        		objContactDetails.strPrefPhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
	        	if(objContactDetails.strMobilePhone != null)
	        		objContactDetails.strMobilePhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
	        	if(objContactDetails.strHomePhone != null)
	        		objContactDetails.strHomePhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
	        	if(objContactDetails.strOtherPhone != null)
	        		objContactDetails.strOtherPhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
	        	objContactDetails.strPrefEmail = '⬚⬚⬚⬚@⬚⬚⬚⬚⬚.⬚⬚⬚';
	        	objContactDetails.strSpecialRequests = 'This person\'s contact information is hidden because he or she has chosen to opt out of all communications.';
	        }       
	        
	        // SKT 11/19/2012
	        // Adding ability to mask for VIP records
	        if(c.RecordType.Name == 'VIP Contact') {
	        	// Set the VIP record flag
	        	objContactDetails.strVIPRecord = 'true';

	        	// Add VIP to last Name
	        	objContactDetails.strNameWithLeaderType = objContactDetails.strNameWithLeaderType + ' [VIP]';
	        	
	        	// check to see if the user can view VIPs
	        	if ( this.blnVIPAccess == false ) {
	        		// user cannot view VIPs
		        	objContactDetails.strStreet = '⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚';
		        	objContactDetails.strCity = '⬚⬚⬚⬚⬚⬚';
		        	objContactDetails.strZip = '⬚⬚⬚⬚⬚';
		        	objContactDetails.strState = '⬚⬚';
		        	if(objContactDetails.strPrefPhone != null)
		        		objContactDetails.strPrefPhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
		        	if(objContactDetails.strMobilePhone != null)
		        		objContactDetails.strMobilePhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
		        	if(objContactDetails.strHomePhone != null)
		        		objContactDetails.strHomePhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
		        	if(objContactDetails.strOtherPhone != null)
		        		objContactDetails.strOtherPhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
		        	objContactDetails.strPrefEmail = '⬚⬚⬚⬚@⬚⬚⬚⬚⬚.⬚⬚⬚';
		        	objContactDetails.strSpecialRequests = 'This person\'s contact information is hidden because he or she is a VIP Contact';
	        	}
	        }       
	               		
        	// put the object into the map
        	mapContactDetails.put (c.Id, objContactDetails );
        	
        	// reset the leaderstring
        	leaderString = '';
        }
        
        // make a list out of the mapped items
        
        lstContactDetails = new List < ContactDetails > ();
        
        // sort the list for output
        for ( Contact c : mlstContact ) {
        	// retrieve the map object
        	objContactDetails = mapContactDetails.get ( c.Id );
        	// add to the final list
        	lstContactDetails.add ( objContactDetails );
        }
        
      	// determine overall contact count
        intNumMembers = integer.valueof(lstContactDetails.size());
        if (intNumMembers != 0)
        {
            strMembersCount = ' (' + intNumMembers + ' Members)';
        }

		if ( strOutput == 'screen' ) {
    		// Start for paging
    		this.ContactDisplay = new List < ContactDetails > ();
    		paginator = new ObjectPaginator ( 50, this );
    		paginator.setRecords ( lstContactDetails );
        	//End for paging
		}
		
		if (( strOutput == 'download' ) || ( strOutput == 'print' )) {
			// build the non-paginated format
			this.ContactDisplay = lstContactDetails;
		}
        
    }
    
}