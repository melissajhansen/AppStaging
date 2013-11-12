public without sharing class CampaignUtil {
	
	public CampaignUtil () {
		
	}
	
	public boolean ValidationRules ( Campaign campaign) {
		if ( campaign.NumberOfOpportunities > 0 ) {
				campaign.AddError ( 'You cannot delete a Campaign that has Donations.  Remove this campaign from all donations before deleting');
				return false;
		}
		return true;
	} 
	
	
	public void UpdateCampTotalClosedLostHierarchyCount ( List < Campaign > campList) {
		//Select List of passed-in Campaigns for fields to be validated/updated
		List < Campaign > campUpdateList = new List < Campaign > ([SELECT ID, Name, ParentId, Total_Closed_Lost_Donations__c, Total_Closed_Lost_Donations_in_Hierarchy__c, Total_Closed_Lost_Donations_in_Children__c FROM Campaign WHERE Id in :campList ]);
		
		//declare variables to avoid null argument errors
		double closedLostCount = 0;
		double closedLostChildrenCount = 0;
		
		for (Campaign c :campUpdateList) {
			//First assign the variables the correct values for non-null arguments
			if (c.Total_Closed_Lost_Donations__c != null) {
			closedLostCount = c.Total_Closed_Lost_Donations__c;
			system.debug('*********************************************Total Closed Lost Donations'+closedLostCount);
			} else closedLostCount = 0;
			if (c.Total_Closed_Lost_Donations_in_Children__c != null){
				closedLostChildrenCount = c.Total_Closed_Lost_Donations_in_Children__c;
				system.debug('*********************************************Total Closed lost in Children'+closedLostChildrenCount);
			} else closedLostChildrenCount = 0;
			c.Total_Closed_Lost_Donations_in_Hierarchy__c = (closedLostCount + closedLostChildrenCount);
			system.debug('*********************************************total in hierarchy (calclulation result)'+c.Total_Closed_Lost_Donations_in_Hierarchy__c);
		}
		update campUpdateList;
	}

	//Method Called by Opportunity Automation to update Parent/Ancestor Closed Lost Compaign Counts
	public void UpdateCampClosedLostChildrenCount ( List < Campaign > campList ){
		
		//Select List of passed-in Campaigns for fields to be validated/updated
		List < Campaign > campUpdateList = new List < Campaign > ([SELECT ID, Name, ParentId, Total_Closed_Lost_Donations_in_Hierarchy__c, Total_Closed_Lost_Donations_in_Children__c FROM Campaign WHERE Id in :campList ]);
		
		//ID List for Parent Campaigns
		List < ID > parentCampaignIds = new List < ID > ();

		//Fill the list
		for (Campaign c:campUpdateList) {
			system.debug('****************************************CampaignInTriggerList'+c.Id);
			system.debug('******************************************Name'+c.name);
			system.debug('*******************************************CampaignParentID'+c.ParentId);
			if (c.ParentId != null) {
				parentCampaignIds.add(c.ParentId);
				
			}
		}
		system.debug('**********************************************sizeofParentCampaignIDList'+parentCampaignIds.size());
		//sObject List for the Parent Campaigns
		List < Campaign > parentCampaigns = new List < Campaign > ([SELECT Id, ParentId, Total_Closed_Lost_Donations_in_Hierarchy__c FROM Campaign WHERE Id in :parentCampaignIds]);
		
				
		//ID List for GrandParent Campaigns
		List < ID > grandParentCampaignIds = new List < ID > ();
		for (Campaign c :parentCampaigns) {
			if (c.ParentId != null) {
				grandParentCampaignIds.add(c.ParentId);
			}
			system.debug('**********************************************sizeofGrandParentCampaignIDList'+grandParentCampaignIds.size());
		}
		List < Campaign > grandParentCampaigns = new List < Campaign > ([SELECT Id, ParentId, Total_Closed_Lost_Donations_in_Hierarchy__c FROM Campaign WHERE Id in :grandParentCampaignIds]);
		
		
		//ID List for GreatGrandParent Campaigns
		List < ID > greatGrandParentCampaignIds = new List < ID > ();
		for (Campaign c :grandParentCampaigns) {
			if (c.ParentId != null) {
				greatGrandParentCampaignIds.add(c.ParentId);
			}
			system.debug('**********************************************sizeofGreatGrandParentCampaignIDList'+greatGrandParentCampaignIds.size());
		}
		List < Campaign > greatGrandParentCampaigns = new List < Campaign > ([SELECT Id, ParentId, Total_Closed_Lost_Donations_in_Hierarchy__c FROM Campaign WHERE Id in :greatGrandParentCampaignIds]);
		
		
		//ID List for GreatGreatGrandParent Campaigns
		List < ID > greatGreatGrandParentCampaignIds = new List < ID > ();
		for (Campaign c:greatGrandParentCampaigns) {
			if (c.ParentId !=null) {
				greatGreatGrandParentCampaignIds.add(c.ParentId);
			}
			system.debug('**********************************************sizeofGreatGreatGrandParentCampaignIDList'+greatGreatGrandParentCampaignIds.size());
		}
		
		//Pass the appropriate lists to the ClosedLostChildUpdater to have each level in the hierarchy updated
		CampaignUtil campUtil = new CampaignUtil ();
		
		if (parentCampaignIds != null) {
			campUtil.ClosedLostChildUpdater(parentCampaignIds);
		}
		if (grandParentCampaignIds != null) {
			campUtil.ClosedLostChildUpdater(grandParentCampaignIds);
		}
		if (greatGrandParentCampaignIds != null) {
			campUtil.ClosedLostChildUpdater(greatGrandParentCampaignIds);
		}
		if (greatGreatGrandParentCampaignIds != null) {
			campUtil.ClosedLostChildUpdater(greatGreatGrandParentCampaignIds);
		}
		
	}
	
	public void ClosedLostChildUpdater ( List < ID > parentCampaignIds){
		//Starting Section to Calculate ClosedLostChildrenCOunt
		
		//Create sObject Lists for the Parent Campaigns from the ID list passed in
		List < Campaign > parentCampaigns = new List < Campaign > ([SELECT Id, ParentId, Total_Closed_Lost_Donations_in_Hierarchy__c FROM Campaign WHERE Id in :parentCampaignIds]);
		system.debug('********************************************SizeofParentCampaignsList'+parentCampaigns.size());
		List < Campaign > allChildrenCampaigns = new List < Campaign > ([SELECT Id, ParentId, Total_Closed_Lost_Donations_in_Hierarchy__c FROM Campaign WHERE ParentId in: parentCampaignIds]);
		system.debug('********************************************SizeofAllChildrenCampaignsList'+allChildrenCampaigns.size());
		
		
		//Variable to hold CL Count for Child Campaigns
		double childrenCLCount = 0;
		
		for (Campaign pc :parentCampaigns) {
			system.debug('**************************************************ParentCampaignID'+pc.Id);
			for (Campaign cc :allChildrenCampaigns) {
				if (cc.Total_Closed_Lost_Donations_in_Hierarchy__c == null){
					cc.Total_Closed_Lost_Donations_in_Hierarchy__c = 0;
				}
				if (cc.ParentId == pc.Id) {
					childrenCLCount += cc.Total_Closed_Lost_Donations_in_Hierarchy__c;
					system.debug('********************************************ChildChampaign Total Closed Lost Donations in Hierarchy '+cc.Total_Closed_Lost_Donations_in_Hierarchy__c);
				}
			}
			pc.Total_Closed_Lost_Donations_in_Children__c = childrenCLCount;
			system.debug('*****************************************************Children Closed Lost Count'+childrenCLCount);
			childrenCLCount = 0;
		}
		
		update parentCampaigns;
		
		//After updating the Child CL Count, update the Hierarchy Count on the Parent Campaigns
		CampaignUtil campUtil = new CampaignUtil ();
		campUtil.UpdateCampTotalClosedLostHierarchyCount ( parentCampaigns );
	}


}