public with sharing class OpportunityAutomation {

	public OpportunityAutomation () {
		
	}
	
	// UpdateAcctLastMemGiftAmount
	// -----------------------------
	// Public method to calculate the most recent Gift that is:
	//   Fund = Membership
	//   Is Wom = true
	//   And write that Gift Amount into the related Account field named:
	//   Last_Membership_Gift_Amount__c
	//   MP/ST 1/6/2012
	public boolean UpdateLastMemGiftAmount ( List < Opportunity > oppList ) {
		
		Decimal lastGiftAmount = 0;
		
		// first we need a unique list of Accounts from the oppList passed into the method
		Set < ID > acctIDSet = new Set < ID > ();
		
		for ( Opportunity o : oppList ) {
			if ( acctIDSet.contains ( o.AccountId ) == false ) {
				acctIDSet.add ( o.AccountId );
			}
		}
		
		// Build a list of accounts with related opportunities
		List < Account > acctList = new List < Account > ( [ SELECT ID, Last_Membership_Gift_Amount__c, ( SELECT ID, Amount FROM Opportunities WHERE Fund_Committed__c = 'Membership' AND IsWon = true ORDER BY CloseDate DESC ) FROM Account WHERE ID IN : acctIDSet ] );
		
		for ( Account a : acctList ) {
			
			// check if there are any related opportunities and pull the top one as the current Last Mem Gift Amount
			if ( a.opportunities.size() > 0 ) {
				// we have opportunities, pull the top one
				lastGiftAmount = a.opportunities[0].amount;
			} else {
				lastGiftAmount = 0;
			}
			
			a.Last_Membership_Gift_Amount__c = lastGiftAmount;
			
		}
		
		update acctList;
		
		return true;
		
	}
	
	// class for Anonymous Gifts
	// for both Contacts and Organizations
	public void setAnonGifts ( List < Opportunity > oppList ) {
	    // list of Accounts from all of the Opportunities inn the trigger (for Anonymous Donors)
		List < ID > adIDList = new List < ID > ();

		for (Opportunity o : oppList) {
		   	// add the account to the adID list for Anon Donors
		    adIDList.add(o.AccountId);
		}
		
		// List of Contacts for those Accounts
		List < Contact > cList = ([SELECT ID, AccountId, Anonymous_Donor__c, Name FROM Contact WHERE AccountId in : adIDList]);
		// List of IDs for those Contacts
		List < ID > cAIDList = new List < ID > ();
		for (Contact c : cList) {
			cAIDList.add(c.AccountID);
		}
		// List to hold the AccountID for Contacts marked as Anonymous
		List < ID > cIDList = new List < ID > ();
		for (Contact c : cList) {
			if (c.Anonymous_Donor__c == true) {
				cIDList.add(c.AccountId);
			}
		}

		// list of Accounts that are NOT Contact Accounts, they are Organization Accounts
		List < Account > aList = ([SELECT ID FROM Account WHERE Anonymous_Org_Donor__c = true AND ID in : adIDList]);
		// list of IDs for those Accounts
		List < ID > aIDList = new List < ID > ();
		for (Account a : aList) {
			if ( (new Set<ID>(cIDList)).contains(a.ID) ) {
			} else {
				aIDList.add(a.ID);
			}
		}
		
		// create a new list of the same Opportunities in the trigger, so that the AccountId is not null
		List <Opportunity> oListNew = ([SELECT AccountId, Anonymous__c FROM Opportunity WHERE ID in : oppList]);
		// changed below from oppList to oListNew
		for (Opportunity o : oListNew) {
			// (new Set<Id>(listOfIds)).contains(idToCompare);
			// if the opportunity is in the Contact list, then look at the contact to determine if the Contact is Anonymous
			if ( (new Set<ID>(cIDList)).contains(o.AccountId) ) {
				if (o.Anonymous__c != true) {
					o.Anonymous__c = true;
					update o;
				}
			}
			if ( (new Set<ID>(aIDList)).contains(o.AccountId) ) {
				if (o.Anonymous__c != true) {
					o.Anonymous__c = true;
					update o;
				}
			}
		}
	}
	
	//When a Donation is marked Closed-Lost, the Amount should be changed to Zero
	//History is available through Amount Planned and History Tracking
	public void ZeroClosedLostGifts ( List < Opportunity > oppList ) {
		
		//Iterate through the list of Opportunities in the trigger.  If the stage is closed lost, and the Amount is not zero
		//change the amount to zero.
		for ( Opportunity o : oppList ) {
			if ( o.IsWon == false && o.IsClosed == true && o.amount != 0 ) {
				o.amount = 0;
			}
		}		
	}
	
	//For Opportunity Record Types we want to use a custom "Do Not Automatically Create Paymet" Checkbox that can be defaulted to Checked on Opportunities
	//For this record type only, this field will control the NPSP Field
	public void PaymentCheckboxOverride ( List < Opportunity > oppList ) {
		for ( Opportunity o :oppList ) {
			if (o.RecordTypeId == '012E0000000MEz3') {
				o.npe01__Do_Not_Automatically_Create_Payment__c = o.Do_Not_Auto_Create_Payment_Opp_Override__c;	
			}
		}
	}
	
	
	// 3/5/13 - MP - Moving the CnP Custom Question logic here from Opportunity Trigger. 
	// Edited Scott's comments below for clarity
	// Method to integrate CnP Custom Questions to Stand custom fields 
    // on opportunity record
    // BULK Happiness version
    // SKT 12/13/11
    
    // create list of CnP Transactions out of the list of opportunities being updated
    // Note: relies on the relationship between Opportunities and CnP Transaction through 
    // the CnP_PaaS__CnP_OrderNumber__c field
    // Also assumes a 1-1 relationship between an Opportunity and a CnP Transaction
    
    public void CampaignClosedLostCounter ( List < Campaign > campaignList) {
				
		//Create a list of the IDs from the Campaigns passed in, so we can create a master Opportunity List
		List < ID > campaignIDs = new List < ID > ();
		for (Campaign c :campaignList) {
			campaignIds.add(c.Id);
		}
		
		//Create a master list of all the closed-lost opportunities in all the campaigns in the list
		List < Opportunity > allOppList = new List < Opportunity > ([SELECT ID, CampaignId FROM Opportunity WHERE IsWon = FALSE AND IsClosed = TRUE AND CampaignID in :campaignIDs]);
		
		//Convert ID list back into sObject List, selecting variables that we need to update or check
		List < Campaign > campaignUpdateList = new List < Campaign > ([SELECT ID, Total_Closed_Lost_Donations__c FROM Campaign WHERE Id in :campaignIds]);
		
		//Declare Variable to hold count of Closed Lost Opportunities for each Campaign in the following loop
		decimal clCount = 0;
		
		for (Campaign c: campaignUpdateList ) {
			for (Opportunity o: allOppList) {
				if (c.id == o.campaignId) {
					clCount++;
				}
			}
			system.debug('**********************************OppAutomation:TotalClosedLostDonationsCount'+clCount);
			system.debug('**********************************CampaignID being Updated'+c.id);
			c.Total_Closed_Lost_Donations__c = clCount;
			clCount = 0;
		}
			
			//Update the list of Campaigns with Closed Lost Count
			update campaignUpdateList;
			
			//Call the method on Campaign Util that updates the hierarchy count (since the CL Count went up, so does the hierarchy total)
			CampaignUtil campUtil = new CampaignUtil ();
			campUtil.UpdateCampTotalClosedLostHierarchyCount ( campaignUpdateList );
			
			
			//Now that the Closed Lost count is updated and the hierarchy total on the updated Campaign, call the method to update the Child ClosedLost Count for the Parent Campaign(s)
			CampaignUtil campUtil2 = new CampaignUtil ();
			campUtil2.UpdateCampClosedLostChildrenCount (campaignUpdateList);
	}		
	
	
	public void OppCustomQuestionLoader ( List < Opportunity > oppList ) {
		
		//map of opportunity ID/Order Number
		map <ID, ID> CnPTrans = new map <ID, ID> ();
		String tmp_Value = '';
	    String campName = '';
		
		//Fill in the CnPTrans Map with Opportunity ID/Order Number Pairs
		    for (Opportunity o : oppList) {
		        if (o.CnP_PaaS__CnP_OrderNumber__c != null) {
		            CnPTrans.put(o.id, o.CnP_PaaS__CnP_OrderNumber__c);
		        }
		    }
		    
			//Following Section is to build a map of Campaign ID/Name to avoid a SOQL query within a loop
		   	//List for Campaign Names from Custom Questions
		   	List < String > campNames = new List < String > ();
		   
			//Fill list with Campaign Names using the custom question loader to retreive Campaign names present	   
		   	CnP_Custom_Question_Loader campCQ = new CnP_Custom_Question_Loader ( CnPTrans.values () );
		   	if ( campCQ.Get_Maps () ) {
		   		//call to the loader was successful, build map of Campaign ID/Value
		   		for (Opportunity o: opplist) {
			   		if (o.CnP_PaaS__CnP_OrderNumber__c != null) {
			   			campName = campCQ.Get_Value_By_Trans_Key( CnPTrans.get (o.Id), 'Campaign');
			   			CampNames.add(campName);
			   		}
			   	}
			} 
			 //Create a Map for Campaign ID/Name Pairs
			 map <String, Id> CampaignMap = new map <String, Id> ();
			 //Create a list of Campaigns with Names in the campNames list
			 List <Campaign> CampaignList = new List <Campaign> ([SELECT ID, Name FROM Campaign WHERE Name in :campNames]);
			 //Fill the Campaign Map
			 for (Campaign c: CampaignList) {
			 	CampaignMap.put(c.Name, c.Id);
			 }
			
		    
			    CnP_Custom_Question_Loader cq = new CnP_Custom_Question_Loader ( CnPTrans.values () );
			    if ( cq.Get_Maps () ) {
			        // call to the loader was successful, update Opportunities as necessary
			        for (Opportunity o : oppList) {
			        	if (o.CnP_PaaS__CnP_OrderNumber__c != null){
			        		//Fill in Default Value(s)
			        		o.Giver_Type__c = 'Individual';
			        		
			        		// need to loop through Community, Entity and Fund values
				            tmp_Value = cq.Get_Value_By_Trans_Key( CnPTrans.get ( o.Id ), 'Community' );
				            if ( tmp_Value != null ) {
				                // write the record
				                o.Community_Committed__c = tmp_Value;
				            }
				            
				            tmp_Value = cq.Get_Value_By_Trans_Key( CnPTrans.get ( o.Id ), 'Entity' );
				            if ( tmp_Value != null ) {
				                // write the record
				                o.Entity_Committed__c = tmp_Value;
				            }
				            
				            tmp_Value = cq.Get_Value_By_Trans_Key( CnPTrans.get ( o.Id ), 'Fund' );
				            if ( tmp_Value != null ) {
				                // write the record
				                o.Fund_Committed__c = tmp_Value;
				            }
				            
				         	tmp_Value = cq.Get_Value_By_Trans_Key( CnPTrans.get ( o.Id ), 'Campaign' );
				            if ( tmp_Value != null ) {
				                // write the record, using the Campaign Map to retrieve the ID instead of Campaign name
				                o.CampaignId = CampaignMap.get(tmp_Value);
				            }
			        	}
			        
			        }
			    }
		
		
    }
}