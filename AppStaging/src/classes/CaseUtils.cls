// CaseUtils
// ----------------
// Class to support the creation and management of cases
// within SFDC.
//
// TODO
// the interface to this class needs to be more robust
// right now usage should be managed well - especially if doing
// multiple bulk commits.  No protection that you won't be adding to 
// a list of cases after you've done a commit - for instance.

public with sharing class CaseUtils {
	
	private List < Case > lBulkCase;
	
	private integer iMaxBulkSize = 200;  // TODO implement this
	
	// make sure when running bulk that you get a true value from bulkInit()
	public boolean bulkInit () {
		try {
			// init the case list
			this.lBulkCase = new List < Case > ();
		} catch ( Exception e ) {
			return false;
		}
		
		return true;
	}
	
	private Case createCase ( string sType, string sAddDescription, Contact oContact  ) {

		// clear prior values
		string sPriority;
		string sStatus = '';
		string sSubject = '';
		string sDescription = '';
		string idContact = null;
		Case oCase;
				
		// determine the case specifics
		if ( sType == 'ZIPLOOKUP' ) {
			sPriority = 'Medium';
			sStatus = 'New';
			sSubject = 'Zip to City State lookup failed';
			sDescription = 'Manual lookup of City State required on contact record';
		} else if ( sType == 'OWNER' ) {
			sPriority = 'Medium';
			sStatus = 'New';
			sSubject = 'Automated Owner Assignment Failed';
			sDescription = 'Owner of the contact record needs to be reassigned manually';
		} else if ( sType == 'DUPE' ) {
			sPriority = 'Medium';
			sStatus = 'New';
			sSubject = 'Duplicate Contact Detected';
			sDescription = 'Manual lookup of City State required on contact record';
		} else if ( sType == 'SYSTEM' ) {
			sPriority = 'Medium';
			sStatus = 'New';
			sSubject = 'System Failure';
			sDescription = 'System Failure';
		} else {
			return null;
		}
		
		// append additional description if needed
		if ( sAddDescription != '' ) {
			sDescription = sDescription + '\n' + sAddDescription;
		}
		
		// append Contact object if available
		if ( oContact != null ) {
			idContact = oContact.Id;
		}
		
		//Cannot access the "Use Assignment Rules" flag directly, must utilize DML Options as below
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule= true;
		
		// build the case
		oCase = new Case ();
		
		oCase.setOptions(dmo);
		oCase.Origin = 'Automation';
		oCase.Priority = sPriority;
		oCase.Status = sStatus;
		oCase.Subject = sSubject;
		oCase.Description = sDescription;
		oCase.Code__c = sType;
		oCase.ContactId = idContact;
		
		return oCase;
		
	}
	
	public void bulkCreateAdminException ( string sType, string sAddDescription, Contact oContact ) {

		Case oCase;
		
		// input validations
		if (( sType == null ) || ( sType == '' )) {
			return;
		}
		
		// create the case
		oCase = this.createCase ( sType, sAddDescription, oContact );
		
		if ( oCase != null ) {
			system.debug('************************************************************IsoCaseNull?'+oCase);
			// add to the list of cases
			this.lBulkCase.add ( oCase );
		} // TODO throw exception here if the sType didn't match any of our acceptable items
	}
	
	public integer bulkListSize () {
		if ( this.lBulkCase != null ) {
			return this.lBulkCase.size();
		} else {
			// case of a non initialized list
			return -1;
		}
	}
	
	// SKT - this interface is rough, I'd rather it throw an exception on a fail, but 
	// will leave this as an improvement going forward
	// Also best to check the bulkListSize() to see if it committed all records
	public void bulkCommitCases () {
		// execute the DML to do the inserts
		if ( lBulkCase != null ) {
			try {	
				insert this.lBulkCase;
			} catch ( Exception e ) {
				// do something here - for now we'll exit without
				// clearing the list
				return;
			}
		}
		
		// flush the list
		this.lBulkCase.clear();
	}
	
	
	// method to create a new Case for Administrator Exception handling
	// this is the non bulk method
	public void createAdminException ( string sType, string sAddDescription, Contact oContact ) {

		Case oCase;
		
		// input validations
		if (( sType == null ) || ( sType == '' )) {
			return;
		}
		
		// calculate the details of the case
		oCase = this.createCase ( sType, sAddDescription, oContact );

		// insert the case
		try { 
			insert oCase;
		} catch ( Exception e ) {
			// do something here - for now we'll exit without
			return;
		}
				
	}
}