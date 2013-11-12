public with sharing class TeamFunctionController {
	
	private final Account account;
	public Boolean refreshPage {get; set;}
	public ApexPages.StandardController stdCtrl {get; set;}
	public string chapterId {get; set;}
	public boolean showDetailSection {get; set;}
	public string organizerId {get; set;}
	public string teamName {get; set;}
	
	public TeamFunctionController(ApexPages.StandardController controller) {
		
		controller.addFields(new List<String>{'Parent', 'Organizer__c', 'Name'});
		this.account = (Account)controller.getRecord();
		stdCtrl = controller;
		chapterId = this.account.parentId;
		organizerId = this.account.organizer__c;
		showDetailSection = true;
		teamName = this.account.name;
		
	}
	
	public boolean showChangeChapterSection{get; set;}
	public boolean showDeactivateTeamSection{get; set;}
	public boolean showEditDetailsSection {get; set;}
	public boolean showReactivateTeamSection{get; set;}
	PageReference pageRef = ApexPages.currentPage();
	
	
    public PageReference doCancel () {
        pageRef.setRedirect(true);
        return pageRef;
    }
	
	public void showChangeChapter () {
		showChangeChapterSection = true;
		showDetailSection = false;
	}
	public void showDeactivateTeam () {
		showDeactivateTeamSection = true;
		showDetailSection = false;
	}
	public void showReactivateTeam () {
		showReactivateTeamSection = true;
		showDetailSection = false;
	}
	public void showEditDetails() {
		showEditDetailsSection = true;
		showDetailSection = false;
	}
	public void showDetail () {
		showDetailSection = true;
	}
	
	public list <selectOption> getChapters() {
		string userState = ([SELECT Primary_State_Office__c from USER where id=: UserInfo.getUserId()].Primary_State_Office__c);
            List<selectOption> options = new list <selectOption>();
            
            list <Account> chapterList = new list <Account>([SELECT id, Name FROM Account WHERE Type = :'Stand Chapter' AND BillingState = :userState]);
            
            options.add(new selectOption('','--Select Chapter--'));
            
            for (Account a: chapterList) {
                    options.add(new selectOption(a.id, a.Name));
            }
            
            return options;
	}
	
	public list <selectOption> getOrganizers() {
		string userState = ([SELECT Primary_State_Office__c from USER where id=: UserInfo.getUserId()].Primary_State_Office__c);
  		string organizerRecordTypeID = Schema.Sobjecttype.Contact.RecordTypeInfosByName.get('Organizer').RecordTypeId;
            
        List<selectOption> options = new list <selectOption>();
        
        list <Contact> organizerList = new list <Contact>([SELECT id, Name, Linked_User__c FROM Contact WHERE RecordTypeId =:organizerRecordTypeID AND Linked_User__r.Primary_State_Office__c = :userState]);
        
        options.add(new selectOption('','--Select Organizer--'));
        
        for (Contact c: organizerList) {
                options.add(new selectOption(c.id, c.Name));
        }
        
        return options;
	}
	

	public pageReference changeChapter (){
		Team team = new Team();
		team.getById(account.id);
		
		team.chapter_id = chapterId;
		
		try {
			team.changeChapter();	
		} catch (StandException e) {
			ApexPages.addMessages(e);
			return null;
		} catch (Exception e) {
			ApexPages.addMessages(e);
			return null;
		}

		pageRef.setRedirect(true);
        return pageRef;
		
	}
	
	public pageReference editDetails (){
		Team team = new Team();
		team.getById(account.id);
		
		team.organizer_id = organizerId;
		team.team_name = teamName;
		
		try {
			team.changeOrganizer();
			team.editDetails();	
		} catch (StandException e) {
			ApexPages.addMessages(e);
			return null;
		} catch (Exception e) {
			ApexPages.addMessages (e);
		}
		
		pageRef.setRedirect(true);
        return pageRef;
		
	}
	
	public pageReference deactivateTeam (){
		Team team = new Team();
		team.getById(account.id);
		
		try {
			team.deactivate();	
		} catch (StandException e) {
			ApexPages.addMessages(e);

			return null;
		} catch (Exception e) {
			ApexPages.addMessages(e);
			return null;
		}
		
		refreshPage=true;
		return null;
		
	}
	
	public pageReference reactivateTeam (){
		Team team = new Team();
		team.getById(account.id);
		
		try {
			team.organizer_id = organizerId;
			team.reactivate();	
		} catch (StandException e) {
			ApexPages.addMessages(e);
			return null;
		} catch (Exception e) {
			ApexPages.addMessages(e);
			return null;
		}
		
		refreshPage=true;
		return null;
		
	}


}