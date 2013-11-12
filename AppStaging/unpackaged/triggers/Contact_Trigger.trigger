trigger Contact_Trigger on Contact (before insert, after insert, after update) {
	
	List < Contact > cList = trigger.new;
	List < Contact > cListOld = trigger.old;
	Map < ID, Contact > cMapOld = trigger.oldMap;
	
	// trigger to update associated account for 1-1 organizations
	// 7/31/12 - SKT created for Fundraising prototype
	// 8/20/12 - SKT updated to support Account Owner automation
	//				Theoretical limit of this trigger is ~10,000 contact updates
	//				Due to the limit of DML Statements (10,000)
	// 8/6/13 - MP Updated to remove Case creation for failures to assign Stand Office or Record Owner. Admins prefer to handle this in bulk.
	
	

	
	ContactUtils cUtil = new ContactUtils ();
	
	if (Trigger.isUpdate && Trigger.isAfter)
	 {
	 	cUtil.ContactToAccount (cList, cListOld, cMapOld, 'Update');
	 } 
	 if (Trigger.isInsert && Trigger.isAfter) {
	 	cUtil.ContactToAccount (cList, cListOld, null, 'Insert');
	 }
	 
	// Delete build a list of associated Accounts
	// Delete List < ID > aID = new List < ID > ();
	
	// 8/20/12 - SKT - note: included Bucket Individual since test cases were not triggering One-to-One types in ScottDev
	// Will retest in other environments to see if this is required.
	// Real case should only include One-To-One types
	
	// 1/10/13 - RLB
	// Zip to City/State
	// pass the Contact list into the method, as an After Insert or After Update
	if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
		if (trigger.new.size() == 1 && !system.isBatch() && !system.isFuture() && Test.isRunningTest() == false && !system.isScheduled()) {
			ContactUtils.zipToCityState(cList, cListOld);
		}
	}
	
	
	//Reasign Record Owner
	if (Trigger.isBefore && Trigger.isInsert) {
		//Create list to hold Contacts to be updated
		List < Contact > contactUpdateList = new List < Contact > ();
		//Get the ID for Developer Account (varies for each environment)
		List < User > daccoList = new List < User > ([SELECT ID, Name From User WHERE Alias = 'dacco']);
		User dacco = daccoList[0];
		string daccoID = dacco.Id;

		//for each contact in the trigger, check if the owner is dacco.  If so, we need to call our owner assigment method on contact util
		for ( Contact c : cList) {
			if ( c.OwnerId == daccoID && c.Stand_Office__c != '' ) {
				contactUpdateList.add(c);
			}
		}
		//If there are records to be updated, pass to the update method on Contact Util
		if ( contactUpdateList.size()>0 ) {
			cUtil.AssignDefaultOwnerOnInsert(contactUpdateList);
		}
	}
	
	/*
	// trigger to update associated account for 1-1 organizations
	// 7/31/12 - SKT created for Fundraising prototype
	// 8/20/12 - SKT updated to support Account Owner automation
	//				Theoretical limit of this trigger is ~10,000 contact updates
	//				Due to the limit of DML Statements (10,000)
	
	Boolean addAccount = false;
	
	for ( Contact c : cList ) {
		
		addAccount = false;
		
		if (( c.npe01__Organization_Type__c == 'One-to-One Individual') || ( c.npe01__Organization_Type__c == 'Bucket Individual')) {
			// 8/28/12 - SKT - adding a check to only fire the trigger if we find one of the three
			// fields modified that we're interested in
			//3/4/12 MP - Adding Stand Office as a field check
			if ( Trigger.isInsert ) {
				// for inserts, we just need to check to make sure that the two data fields that we're
				// interested in have values, ownerID is handled by NPSP
				if (( c.Prospect_Priority__c != null ) || ( c.Prospect_Status__c != null ) || c.Stand_Office__c != null) {
					// have values in fields that we want to update
					addAccount = true;
				}
			} else if ( Trigger.isUpdate ) {
				// for updates, we need to check against the OldMap
				Contact oldContact = Trigger.oldMap.get(c.ID);
				if (( oldContact.Prospect_Priority__c != c.Prospect_Priority__c ) || ( oldContact.Prospect_Status__c != c.Prospect_Status__c ) || ( oldContact.OwnerId != c.OwnerId ) || ( oldContact.Stand_Office__c != c.Stand_Office__c)) {
					// have a change in values
					addAccount = true;
				}
			}
			
			if ( addAccount ) {
				// add the related account
				aID.add ( c.AccountId );
			}
		}
	}
	
	if ( aID.isEmpty() == false ) {
		// traverse through the account list and update account info
		Map < ID, Account > aMap = new Map < ID, Account > ( [ SELECT ID, OwnerId, Prospect_Priority__c, Prospect_Status__c FROM Account WHERE ID IN : aID ] );
		
		// go through the contacts again
		ID accountID;
		Account theAccount;
		
		for ( Contact c : cList ) {
			
			accountID = c.AccountId;
			// search for it in the map and update if it's found
			
			if ( aMap.get ( accountID ) != null ) {
				// Fundraising Rqmt - Update Prospect fields from Contact to Account ( 1-1 Organizations only )
				aMap.get ( accountID ).Prospect_Priority__c = c.Prospect_Priority__c;
				aMap.get ( accountID ).Prospect_Status__c = c.Prospect_Status__c;
				// Contact ownership - Update Account Owner for 1-1 organizations if contact is updated
				aMap.get ( accountID ).OwnerId = c.OwnerId;
				aMap.get( accountID ).OneToOneContactStandOffice__c = c.Stand_Office__c;
			}
			
		}
		
		// update the accounts
		update aMap.values();
	}
	*/
}