trigger Relationship_Trigger on npe4__Relationship__c (before delete, before insert, before update) {
/*
	Boolean objResult = true;
	
	// SKT 6/7/2012
	// Removed all actions from the relationship trigger - encountered
	// SOQL limits and decided to move the updates to the contact record
	// into the Membership Trigger base
	// Any direct changes to Relationships of the Organizing type
	// will cause systems such as Rocket to be defective
	// Changes must be initiated by the Membership object
	
	if (( Trigger.isBefore && Trigger.isInsert ) || ( Trigger.isBefore && Trigger.isUpdate )) {
		// ContactAffiliationIntegration obj = new ContactAffiliationIntegration ();
		//objResult = obj.HandleRelationship( Trigger.new, 'update' );
		if ( objResult ) {
			// commit the save
		} else {
			// rollback the insert or update
		}
	} 
	
	if ( Trigger.isBefore && Trigger.isDelete ) {
		// ContactAffiliationIntegration obj = new ContactAffiliationIntegration ();
		//objResult = obj.HandleRelationship( Trigger.old, 'delete' );
		if ( objResult ) { 
			// commit the delete
		} else { 
			// rollback the delete
		}
	} 
	*/
}