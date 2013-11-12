public with sharing class OrganizationUtil {
	
	private List<Id> initContactIds = new List<Id>();
    private List<Id> initTeamIds = new List<Id>();
    
	private Map < Id, Contact > contactMap = new Map < Id, Contact >();
	private Map < Id, Account > teamMap = new Map < Id, Account >();
	private Map < Id, List<npe5__Affiliation__c> > teamAffiliationMap = new  Map < Id, List<npe5__Affiliation__c> >();	
	private Map < Id, membership__c > membershipMap = new Map < Id, membership__c >();
	private Map < Id, List<npe5__Affiliation__c> > contactAffiliationMap = new  Map < Id, List<npe5__Affiliation__c> >();
	
	public void setup(List < npe5__Affiliation__c > Affiliations) {
		for(npe5__Affiliation__c al: Affiliations) {
			initTeamIds.add(al.npe5__Organization__c);
			initContactIds.add(al.npe5__contact__c);
		}
		for(npe5__Affiliation__c af: [select Id, Team_Leader__c, npe5__Role__c, npe5__Status__c, Affiliation__c, npe5__contact__c, npe5__Organization__c, npe5__Organization__r.parent.Id from npe5__Affiliation__c where npe5__contact__c != null and npe5__Organization__c in : initTeamIds]) {	
			initContactIds.add(af.npe5__contact__c);			
			if(teamAffiliationMap.containsKey(af.npe5__Organization__c)) {
				List<npe5__Affiliation__c> tmpAffList = teamAffiliationMap.get(af.npe5__Organization__c);
				tmpAffList.add(af);
			} else {
				List<npe5__Affiliation__c> tmpAffList = new List<npe5__Affiliation__c>();				
				tmpAffList.add(af);
				teamAffiliationMap.put(af.npe5__Organization__c, tmpAffList);
			}
			if(contactAffiliationMap.containsKey(af.npe5__contact__c)) {
				List<npe5__Affiliation__c> tmpAffList2 = contactAffiliationMap.get(af.npe5__contact__c);
				tmpAffList2.add(af);
			} else {
				List<npe5__Affiliation__c> tmpAffList2 = new List<npe5__Affiliation__c>();				
				tmpAffList2.add(af);
				contactAffiliationMap.put(af.npe5__contact__c, tmpAffList2);
			}
		}
		contactMap = new Map < Id, Contact > ([SELECT Id, Name, Membership_Status__c, Number_of_Followers__c, Leader_Type__c, Membership_Type__c, Stand_Leader__c, Stand_Team_Organizer__c FROM Contact where Id in : initContactIds ]);				
		Map < Id, membership__c > mbMap = new Map < Id, membership__c >([ SELECT Id, Name, Contact__c, Status2__c, Type__c, Team_Leader__c FROM membership__c where Name != '' and Id != '' and Contact__c in : initContactIds ]);   
        for(membership__c mb: mbMap.values()) {
              membershipMap.put(mb.Contact__c, mb);
        }		
		teamMap = new Map < Id, Account >([ SELECT Id, Name, Organizer__c, ParentId FROM Account where Id in : initTeamIds ]);
	}
	
	public Map < Id, Contact > getContactMap() {
		return contactMap;
	}
	
	public Map < Id, Account > getTeamMap() {
		return teamMap;
	}
	
	public Map < Id, membership__c > getMembershipMap() {
		return membershipMap;
	}
	
	public Map < Id, List<npe5__Affiliation__c> > getTeamAffiliationMap () {
		return teamAffiliationMap;
	}
	
	public Map < Id, List<npe5__Affiliation__c> > getContactAffiliationMap () {
		return contactAffiliationMap;
	}

}