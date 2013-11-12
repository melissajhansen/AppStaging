trigger Campaign_Trigger on Campaign (before delete, after delete, after insert, after undelete, 
after update) {


	//Will be calling method in OpportunityAutomation that updates Campaign ClosedLost Counts
	OpportunityAutomation oa = new OpportunityAutomation ();
	
	
	//Update the ClosedLostCounts and Hierarchy for all Campaign Inserts
	if (Trigger.isInsert && Trigger.isAfter) {
		oa.CampaignClosedLostCounter (trigger.new);		
	}
	
	//For updates we only need to update the Closed Lost Count if the hierarchy has changed
	if (Trigger.isUpdate && Trigger.isAfter) {
		list < ID > oldParentCampID = new List < ID >();
		list < Campaign > campaignsToUpdate = new List < Campaign > ();
		for (Campaign c :trigger.new) {
			Campaign oldC = System.Trigger.oldMap.get(c.Id);
			//If there has been a change in the Parent, add the Campaign to the list for updating, and put it's parent 
			//Campaign ID in a list to be added below (can't pass the Parent Campaign object directly into the list)
			if (c.ParentId != oldC.ParentId) {
				campaignsToUpdate.add(c);
				oldParentCampID.add(oldC.ParentID);
			}
		} 
		
		//Convert oldParentCampaign ID list to sObject list and add to list of Campaigns to Update
		
		if (oldParentCampID.size() > 0 ) {
			list < Campaign > oldParentCamp = new List < Campaign > ([SELECT ID, Name FROM Campaign WHERE ID in:oldParentCampID]);
			for (Campaign c :oldParentCamp) {
			campaignsToUpdate.add(c);
			}
		}

		//If we have an oldParentCampaign, it may no longer have child campaigns and must have its child campaign count updated directly
		if ((oldParentCampID.size()) > 0) {
			CampaignUtil cu = new CampaignUtil();
			cu.ClosedLostChildUpdater (oldParentCampID);
		}

		//If we have any campaigns that need to be updated, call the ClosedLost Counter Method
		if ((campaignsToUpdate.size()) > 0) {
			oa.CampaignClosedLostCounter(campaignsToUpdate);
		}
		

	}
	
	//For Deletes, check validation rules to make sure no donations are attached.  No updates necessary since all Donatinos must be removed before deleting
	if (Trigger.isDelete && Trigger.isBefore) {
		for ( Campaign c :trigger.old) {
			CampaignUtil cu = new CampaignUtil();
			cu.ValidationRules (c);
		}
	
		
	}

}