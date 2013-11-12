global with sharing class ContactSearch implements ObjectPaginatorListener
{

    public string strFirstName {get; set;}
    public string strLastName {get; set;}
    public string strCity {get; set;}
    public string strState {get; set;}
    public string strEmail {get; set;}
    public string strPhone {get; set;}
    public string strZip {get; set;}
    public boolean blnSearch {get; set;}
    public string strSortField {get; set;}
    public string strSortDirection {get; set;}
    public integer intContactCount { get; set; }
    
    // SKT 11/19/2012
    // VIP Access
    public boolean blnVIPAccess { get; set; }
    
    private integer csMaxQueries = 100;
    private integer csMaxLimitQueries = 500;
    
    transient string strSelectedFirstName, strSelectedLastName, strSelectedCity, strSelectedState, strSelectedEmail, strSelectedPhone, strSelectedZip;

    //Start for paging
    global ObjectPaginator paginator {get; private set;} 
    global Integer pageNumber {get; set;}
    
	global List < ContactDetail > lstContactDetails = new List < ContactDetail > ();
    global List < ContactDetail > ContactDisplay {get; private set;}
    
    global void handlePageChange ( List <Object> newPage) {
    	ContactDisplay.clear();
    	if ( newPage != null ) {
    		for ( Object c : newPage ) {
    			ContactDisplay.add ( ( ContactDetail ) c );
    		}
    	} 
    }

    global PageReference skipToPage()
    {
        this.paginator.skipToPage(pageNumber);
        return null;
    }
		
    // ---- Constructor ------------
    public ContactSearch(ApexPages.StandardController controller)
    {
    	closePopup();
    	closeLimitPopup();
        strFirstName = 'First Name';
        strLastName = 'Last Name';
        strCity = 'City';
        strEmail = 'Email';
        strPhone = 'Phone';
        strZip = 'Zip';
        blnSearch = false;
        strSortField = 'Name';
        strSortDirection = 'Asc';
        
        // SKT 11/19/2012
        // Determine users' VIP access
        List < User > lstUser = [ SELECT Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        	
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
    
    public List<selectOption> getStateList
    {
        get
        {
        	// create a list of state abbreviations
        	// TODO, make our list of states some other, more consistent and robust way
        	List < string > mStates = new List < string > {'AK','AL','AR','AS','AZ','CA','CO','CT','DC','DE','FL','GA','GU','HI','IA','ID','IL','IN','KS','KY','LA','MA','MD','ME','MH','MI','MN','MO','MS','MT','NC','ND','NE','NH','NJ','NM','NV','NY', 'OH','OK','OR','PA','PR','PW','RI','SC','SD','TN','TX','UT','VA','VI','VT','WA','WI','WV','WY' };
            List<selectOption> lstState = new List<selectOption>();
            lstState.Add(new SelectOption('', 'All States'));
            for ( string s : mStates ) {
            	lstState.Add(new SelectOption(s, s));
            }
            //lstState.Add(new SelectOption('National', 'National'));
            return lstState;
        }
        private set;
    }

    public void SetSearchVariables()
    {
        strSelectedFirstName = String.escapeSingleQuotes(strFirstName.trim());
        strSelectedLastName = String.escapeSingleQuotes(strLastName.trim());
        strSelectedCity = String.escapeSingleQuotes(strCity.trim());
        strSelectedState = strState;
        strSelectedEmail = String.escapeSingleQuotes(strEmail.trim());
        strSelectedPhone = String.escapeSingleQuotes(strPhone.trim());
        strSelectedZip = String.escapeSingleQuotes(strZip.trim());
        SearchContacts();
    }

    public void SearchContacts()
    {
    	closePopup();
    	closeLimitPopup();
        blnSearch = true;
        string strWhere = '';
        string strQuery = '';        
        string strSortExpression = '';
        
        List < Contact > lstContact = new List < Contact > ();
        ContactDetail objContactDetail;
        
        if (strSortField != null && strSortField != '')
            strSortExpression = ' order by ' + strSortField + ' ' + strSortDirection;

        if (strSelectedFirstName != 'First Name' && strSelectedFirstName != '' && strSelectedFirstName != null)
			strWhere = ' where FirstName like \'%' + strSelectedFirstName + '%\'';

        if (strSelectedLastName != 'Last Name' && strSelectedLastName != '' && strSelectedLastName != null)
            if (strWhere == '')
                strWhere = ' where LastName like \'%' + strSelectedLastName + '%\'';
            else
                strWhere += ' and LastName like \'%' + strSelectedLastName + '%\'';

        if (strSelectedCity != 'City' && strSelectedCity != '' && strSelectedCity != null)
            if (strWhere == '')
                strWhere = ' where MailingCity like \'%' + strSelectedCity + '%\'';
            else
                strWhere += ' and MailingCity like \'%' + strSelectedCity + '%\'';

        if (strSelectedState != '' && strSelectedState != null)
            if (strWhere == '')
                strWhere = ' where MailingState = \'' + strSelectedState + '\'';
            else
                strWhere += ' and MailingState = \'' + strSelectedState + '\'';

        if (strSelectedEmail != 'Email' && strSelectedEmail != '' && strSelectedEmail != null)
            if (strWhere == '')
                strWhere = ' where Email like \'%' + strSelectedEmail + '%\'';
            else
                strWhere += ' and Email like \'%' + strSelectedEmail + '%\'';

        if (strSelectedPhone != 'Phone' && strSelectedPhone != '' && strSelectedPhone != null)
            if (strWhere == '')
                strWhere = ' where Phone like \'%' + strSelectedPhone + '%\'';
            else
                strWhere += ' and Phone like \'%' + strSelectedPhone + '%\'';

        if (strSelectedZip != 'Zip' && strSelectedZip != '' && strSelectedZip != null)
            if (strWhere == '')
                strWhere = ' where MailingPostalCode like \'%' + strSelectedZip + '%\'';
            else
                strWhere += ' and MailingPostalCode like \'%' + strSelectedZip + '%\'';

        if (strWhere != '')
        {
        	// SKT 11/19/2012
        	// Adding VIP capabilities
            // build and execute the query
            strQuery = 	'SELECT Id, Name, RecordType.Name, Stand_Team_Organizer__r.Name, DoNotCall, Do_Not_Mail__c, Do_Not_Contact__c, Do_Not_Text__c, HasOptedOutOfEmail, Email, Phone, MobilePhone, HomePhone, OtherPhone, Stand_Office__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, ' +
            					'(SELECT status2__c, membership_state__c FROM memberships__r), ' +
            					'(SELECT npe5__Organization__r.name, Affiliation__c FROM npe5__affiliations__r ' + 
            					'WHERE npe5__status__c = \'Active\') FROM Contact ' +
            					strWhere;
            					
            // rough sort
            strQuery = strQuery + ' ORDER BY LastName, FirstName';           
            
            // run query	
            lstContact = Database.Query(strQuery);
            
            if(continueSearch != true) {
	            if((lstContact.size() >= csMaxQueries)&&(lstContact.size() <= csMaxLimitQueries)) {
	            	displayPopupInfo = 'Your search has returned more than '+csMaxQueries+' records, do you want to continue?';
	            	showPopup();
	            }
            } else {
            	closePopup();
            	dontCntSearch();
            }
            
            if(lstContact.size() > csMaxLimitQueries) {
            	displayPopupInfo = 'Your search has returned '+lstContact.size()+' records (Max = '+csMaxLimitQueries+'), you must refine your search.  Try adding State, City, Email, etc. to your search criteria.\\n\\nFYI: Statewide lists are in Galaxy';
            	showLimitPopup();
            	return;
            }
            
            // clear out the global var
            this.lstContactDetails.clear();
            
            // set some header level vars
            this.intContactCount = lstContact.size();
            
            // load up the ContactDetail object
            for ( Contact c : lstContact ) {
            	objContactDetail = new ContactDetail (c, this.blnVIPAccess);           	
            	this.lstContactDetails.add ( objContactDetail );
            	
            }
        }
        else
        {
            blnSearch = false;
        }
        // Start for paging
    	this.ContactDisplay = new List < ContactDetail > ();
    	paginator = new ObjectPaginator ( 50, this );
    	paginator.setRecords ( lstContactDetails );
        //End for paging
    }
    
    public boolean displayPopup {get; set;}    
    public boolean displayLimitPopup {get; set;}
    public string displayPopupInfo {get; set;} 
    public boolean continueSearch {get; set;}

    public void closePopup() {
        displayPopup = false;
    }

    public void showPopup() {
        displayPopup = true;
    }
    
    public void closeLimitPopup() {
        displayLimitPopup = false;
    }

    public void showLimitPopup() {
        displayLimitPopup = true;
    }
    
    public void dontCntSearch() {
        continueSearch = false;
    }
    
}