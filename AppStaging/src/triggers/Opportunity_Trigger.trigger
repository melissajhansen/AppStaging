trigger Opportunity_Trigger on Opportunity (before insert, after insert, before update, after update, after delete) {
    // Trigger to integrate CnP Custom Questions to Stand custom fields 
    // on opportunity record
    // BULK Happiness version
    // SKT 12/13/11
    
    // create list of CnP Transactions out of the list of opportunities being updated
    // Note: relies on the relationship between Opportunities and CnP Transaction through 
    // the CnP_PaaS__CnP_OrderNumber__c field
    // Also assumes a 1-1 relationship between an Opportunity and a CnP Transaction
    
    
    //Updated Trigger with Last Membership Gift Date logic
    //Updated Trigger to run after insert, after update, after delete (in addition  to before insert which was the previous condition)
    //MP 1/4/13
    
    // updated to add code for Anonymous Donors (Contacts and Accounts)
    // RB 1/9/13


	//Before Insert, call OppCustomQuestionLoader to load Custom Question Values from C&P Trans to Opportunity
	if (Trigger.isInsert && Trigger.isBefore){
		OpportunityAutomation oa = new OpportunityAutomation ();
		oa.OppCustomQuestionLoader( trigger.new );
	}
	

   // Section to manage Last Membership Gift Amount Field
   //For an Insert or Update to an Opportunity, run the Opportunity Automation to populate the Last Membership Gift Amount field on the Account.
   if ( ( Trigger.isInsert || Trigger.isUpdate ) && Trigger.isAfter ){
		OpportunityAutomation oa = new OpportunityAutomation ();
		oa.UpdateLastMemGiftAmount ( trigger.new );
	}
	
	//When an opportunity is deleted, run the Opportunity Automation to populate the Last Membership Gift Amount field on the Account.
	if (Trigger.isDelete && Trigger.isAfter){
		OpportunityAutomation oa = new OpportunityAutomation ();
		oa.UpdateLastMemGiftAmount ( trigger.old );
	}

	
	// call the method for Anon Gifts and pass in the Account ID List
	if (Trigger.isInsert && Trigger.isAfter) {
		OpportunityAutomation oa = new OpportunityAutomation ();
		oa.setAnonGifts (trigger.new);
	}
	
	// Call the method to Zero out Amount for Closed Lost Gifts (before insert/update)
	if ( ( Trigger.isInsert || Trigger.isUpdate ) && Trigger.isBefore ){
		OpportunityAutomation oa = new OpportunityAutomation ();
		oa.ZeroClosedLostGifts ( trigger.new );
	}
	
	//Evalutate whether the 'Do Not Auto Create Payment' checkbox needs to be updated for Opportunity Opportunities
	//If so call PaymentCheckboxOverride Method and pass through gifts to be updated
	if (Trigger.isInsert && Trigger.isBefore) {
		OpportunityAutomation oa = new OpportunityAutomation ();
		oa.PaymentCheckboxOverride (trigger.new );
	}
	if (Trigger.isUpdate && Trigger.isBefore) {
		list < Opportunity > oppOverrideUpdates = new List < Opportunity >();
		for (Opportunity o :Trigger.new){
			Opportunity oldO = System.Trigger.oldMap.get(o.Id);
			if (o.Do_Not_Auto_Create_Payment_Opp_Override__c != oldO.Do_Not_Auto_Create_Payment_Opp_Override__c) {
				oppOverrideUpdates.add(o);
			}
				
		}
		OpportunityAutomation oa = new OpportunityAutomation ();
		oa.PaymentCheckboxOverride ( oppOverrideupdates );
	}
	
	   // Section to manage Closed Lost Donation Count on Campaigns

	if (trigger.isAfter) {
	    //List to hold the IDs of Campaigns that need to be updated
	    List < ID > campIds = new List < ID > ();
	    
	    //For an Inserted Opportunity, if it is Closed Lost the Campaign will need to be udpated
	    if ( Trigger.isInsert && Trigger.isAfter){
			for ( Opportunity o :trigger.new) {
				if (o.IsWon == false && o.IsClosed == true) {
					campIds.add(o.CampaignId);
				}
			}
		} 
			
		//For an Updated Opportunity, check to see if it has become Closed Lost, Used to be Closed Lost, or simply if the Campaign has changed
		//If So, add it to the list to update
		if (Trigger.isUpdate && Trigger.isAfter) {
			for (opportunity o :trigger.new) {
				opportunity oldO = system.Trigger.oldMap.get(o.Id);
				if  ((o.IsWon == false && o.IsClosed == true) && (oldO.IsWon == true || oldO.IsClosed == false )) {
					campIds.add(o.CampaignId);
				} if ((o.IsWon == true || o.IsClosed == false) && (oldO.IsWon == false && oldO.IsClosed == true)) {
					system.debug('***************************************************OppID under Update changing from Closed Lost'+o.Id);
					system.debug('***************************************************CampaignID under Update changing from Closed Lost'+o.CampaignId);
					campIds.add( oldO.CampaignId );
				} if (o.CampaignId != oldO.CampaignID) {
					campIds.add (o.CampaignId);
					campIds.add (oldO.CampaignId);
				}
			} 
		} 
		
		//For a Deleted Opportunity, add it to the list to update
		if (Trigger.isDelete && Trigger.isAfter) {
			for ( Opportunity oldO :trigger.old) {
				if (oldO.IsWon == false && oldO.IsClosed == true ) {
					campIds.add(oldO.CampaignId);
				}
			}
		}
		
		if (campIds.size() >0 ) {
			List < Campaign > campList = new List < Campaign > ([SELECT ID From Campaign WHERE ID in :campIds]);
			OpportunityAutomation oa = new OpportunityAutomation();
			oa.CampaignClosedLostCounter(campList);			
		}
	}

}