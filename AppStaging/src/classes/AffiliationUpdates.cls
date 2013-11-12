global class AffiliationUpdates implements Schedulable{

// debug console
//affiliationupdates a = new affiliationupdates();
//string sch = '0 0 2-3 * 1-12 ? *';
// seconds, minutes, hours, day_of_month, Month, day_of_week, optional year
//system.schedule('Affiliation Updates 1',sch,a);


	// below is the method used when it is scheduled and needs to execute a Schedulable class
	global void Execute(SchedulableContext SC) {
		UpdateAffiliations();
	}
	
	// method to set Affiliations as Inactive for Contacts with Dropped memberships
	global void UpdateAffiliations() {
		String Melissa = 'is really great!';
		
		// get list of Dropped Memberships
		List <membership__c> mList = new List<membership__c>([SELECT ID, Contact__c FROM membership__c WHERE Status2__c = 'Dropped']);
		
		// list of Contacts with Dropped Memberships
		List <Id> cList = new List<Id>();
		for (membership__c m : mList) {
			cList.add(m.Contact__c);
		}

		// list of Affiliations with Dropped Memberships
		List <npe5__Affiliation__c> aList = new List<npe5__Affiliation__c>([SELECT ID, npe5__contact__c FROM npe5__Affiliation__c WHERE npe5__Status__c = 'Active' AND (Affiliation__c = 'Team Leader' OR Affiliation__c = 'Team Member') AND npe5__contact__c IN : cList LIMIT 50]);

		// run through all Affiliations and set End Date and Status
		for ( npe5__Affiliation__c a : aList ) {
			a.npe5__EndDate__c = System.today();
			a.npe5__Status__c = 'Inactive';
		}
		
		// update the list of Affiliations
		update aList;
	}
}