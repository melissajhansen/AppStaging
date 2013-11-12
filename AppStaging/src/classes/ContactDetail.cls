global with sharing class ContactDetail {

	// ----- CONTACT DATA -----
    public Id Id { get; set; }
    public string strFirstName {get; set;}
    public string strLastName {get; set;}
    public string strName { get; set; }
    public string strEmail {get; set;}
    public string strDoNotEmail {get; set;}
    public string strPrefPhone {get; set;}
    public string strWorkPhone {get; set;}
    public string strMobilePhone {get; set;}
    public string strHomePhone {get; set;}
    public string strOtherPhone {get; set;}
    public string strDoNotCall {get; set;}
    public string strStreet {get; set;}
    public string strCity {get; set;}
    public string strState {get; set;}
    public string strZip {get; set;}
    public string strDoNotContact {get; set;}
    public string strDoNotText {get; set;}
    public string strDoNotMail {get; set;}
    public string strDoNotFieldMsg1 {get; set;}
    public string strDoNotFieldMsg2 {get; set;}
    public string strDoNotFieldMsg3 {get; set;}
    public string strDoNotFieldMsg4 {get; set;}
    public string strDoNotFieldMsg5 {get; set;}
    public string strEducatorType {get; set;}
    public string strContactState { get; set; }
    public string strMailingState { get; set; } 
    
    public string strVIPRecord { get; set; } 
    
    public string strOrganizer { get; set; }  
        
    // ----- MEMBERSHIP DATA -----
    public string strMembershipSummary { get; set; }
      
    // ----- AFFILIATION DATA -------
    public string strAffiliationSummary { get; set; }
    
    public ContactDetail(Contact c, Boolean blnVIPAccess) {
    	
    	string strBracketL = '';
        string strBracketR = '';
    	strName = c.name;
        strEmail = c.email;
        strWorkPhone = c.Phone;
        strMobilePhone = c.MobilePhone;
        strHomePhone = c.HomePhone;
        strOtherPhone = c.OtherPhone;
        strContactState = c.Stand_Office__c;
        strMailingState = c.MailingState;
        strCity = c.MailingCity;
        strZip = c.MailingPostalCode;
        strStreet = c.MailingStreet; 
        strOrganizer = c.Stand_Team_Organizer__r.Name; 
        strVIPRecord = 'false';
        
        if(c.Do_Not_Mail__c == true) {
        	strStreet = '⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚';
        	strCity = '⬚⬚⬚⬚⬚⬚';
        	strZip = '⬚⬚⬚⬚⬚';
        	strMailingState = '⬚⬚';
        	strDoNotFieldMsg1 = 'This person\'s address is hidden because he or she has requested not to receive mail.';
        }
        if(c.DoNotCall == true) {
        	if(strWorkPhone != null)
        		strWorkPhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
        	if(strMobilePhone != null)
        		strMobilePhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
        	if(strHomePhone != null)
        		strHomePhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
        	if(strOtherPhone != null)
        		strOtherPhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
        	strDoNotFieldMsg2 = 'This person\'s phone number is hidden because he or she has requested not to be called.';
        }
        
        if(c.Do_Not_Text__c == true) {
        	strDoNotFieldMsg4 = 'This person has requested not to receive text messages.';
        	if(strMobilePhone != null)
        		strMobilePhone = strMobilePhone+' (do not text)';
        }
        
        if(c.HasOptedOutOfEmail == true) {
        	strEmail = '⬚⬚⬚⬚@⬚⬚⬚⬚⬚.⬚⬚⬚';
        	strDoNotFieldMsg5 = 'This person\'s email address is hidden because he or she has requested not to be emailed.';
        }
        
        if(c.Do_Not_Contact__c != null) {
        	strStreet = '⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚';
        	strCity = '⬚⬚⬚⬚⬚⬚';
        	strZip = '⬚⬚⬚⬚⬚';
        	strMailingState = '⬚⬚';
        	if(strWorkPhone != null)
        		strWorkPhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
        	if(strMobilePhone != null)
        		strMobilePhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
        	if(strHomePhone != null)
        		strHomePhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
        	if(strOtherPhone != null)
        		strOtherPhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
        	strEmail = '⬚⬚⬚⬚@⬚⬚⬚⬚⬚.⬚⬚⬚';
        	strDoNotFieldMsg3 = 'This person\'s contact information is hidden because he or she has chosen to opt out of all communications.';
        	strDoNotFieldMsg1 = null;
        	strDoNotFieldMsg2 = null;
        	strDoNotFieldMsg4 = null;
        	strDoNotFieldMsg5 = null;
        }    
        
        // SKT 11/19/2012
        // Adding VIP capabilities  
        // SKT 11/19/2012
	    // Adding ability to mask for VIP records
	    if(c.RecordType.Name == 'VIP Contact') {
	    	// Set the VIP record flag
	        strVIPRecord = 'true';

	        // check to see if the user can view VIPs
	        if ( blnVIPAccess == false ) {
        		// user cannot view VIPs
        		strStreet = '⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚⬚';
	        	strCity = '⬚⬚⬚⬚⬚⬚';
	        	strZip = '⬚⬚⬚⬚⬚';
	        	strMailingState = '⬚⬚';
	        	if(strWorkPhone != null)
	        		strWorkPhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
	        	if(strMobilePhone != null)
	        		strMobilePhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
	        	if(strHomePhone != null)
	        		strHomePhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
	        	if(strOtherPhone != null)
	        		strOtherPhone = '(⬚⬚⬚) ⬚⬚⬚-⬚⬚⬚⬚';
	        	strEmail = '⬚⬚⬚⬚@⬚⬚⬚⬚⬚.⬚⬚⬚';
	        	strDoNotFieldMsg3 = 'This person\'s contact information is hidden because he or she is a VIP Contact';
	        	strDoNotFieldMsg1 = null;
	        	strDoNotFieldMsg2 = null;
	        	strDoNotFieldMsg4 = null;
	        	strDoNotFieldMsg5 = null;
        	} else {
        		strDoNotFieldMsg3 = 'This person\'s contact information is covered under VIP Contact policies';
        	}
	    }       
	            	
        // calculate the membership summary
        if ( c.memberships__r.size() > 1 ) {
        	strBracketL = '[';
            strBracketR = ']';
        } else {
            strBracketL = '';
            strBracketR = '';
        }
        strMembershipSummary = '';
        for ( Membership__c m : c.memberships__r ) {
        	strMembershipSummary = strMembershipSummary + strBracketL + m.membership_state__c + '-' + m.status2__c + strBracketR + ' ';
        }
            	
        // calculate the affiliations summary
        if ( c.npe5__affiliations__r.size() > 1 ) {
        	strBracketL = '[';
            strBracketR = ']';
        } else {
            strBracketL = '';
            strBracketR = '';
        }
        strAffiliationSummary = '';
        for ( npe5__affiliation__c a : c.npe5__affiliations__r ) {
            strAffiliationSummary = strAffiliationSummary + strBracketL + a.npe5__organization__r.name + '-' + a.affiliation__c + strBracketR + ' ';
        }
    }
    
    public boolean emailIsScrambled {
    	get {
    		if(strEmail != null) {
    			return strEmail.contains('⬚⬚');
    		} else {
    			return false;
    		}
    	}
    	private set;
    }

}