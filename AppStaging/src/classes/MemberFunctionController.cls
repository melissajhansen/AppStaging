public class MemberFunctionController {
        
        private final Contact contact;
        public Boolean refreshPage {get; set;}
        public ApexPages.StandardController stdCtrl {get; set;}
        public string leaderId {get; set;}
        public boolean showButtonsSection {get; set;}
        public string sectionName {get; set;}
        public boolean showMemDetailBlockSection {get; set;}
        public boolean showLdrDetailBlockSection {get; set;}
        public string membershipNotes {get; set;}
        public string memType {get; set;}
        public boolean joinRedirect {get; set;}
        
        // object to encapsulate the entered value and any error
		// message associated with it
		public ValueAndError accountIdVal {get; set;}
        
        
        
        public String teamIdError {get; set;}
        
        public MemberFunctionController(ApexPages.StandardController controller) {
                
            controller.addFields(new List<String>{'FirstName', 'LastName', 'stand_team_Affiliation__c', 'membership_type__c', 'membership_status__c', 'is_member__c', 'is_leader__c', 'Stand_Leader__c', 'Membership_Notes__c'});
            this.contact = (Contact)controller.getRecord();
            refreshPage = false;
            leaderId = this.contact.Stand_Leader__c;
            teamIdError='';
            stdCtrl = controller;
            showButtonsSection = true;
            showMemDetailBlockSection = true;
        	showLdrDetailBlockSection = true;
        	membershipNotes = this.contact.Membership_Notes__c;
        	accountIdVal=new ValueAndError();
        	memType = this.contact.membership_type__c;
        	joinRedirect = false;
  
   
        } 
        
        //public void doCancel () {
       //     refreshPage = true;
        //}

        

        public string userId {get; private set;}
        public boolean showJoinSection {get; set;}
        public boolean renewRedirect {get; set;}
        public boolean quitRedirect {get; set;}
        public boolean LeaderConvertRedirect {get; set;}
        public boolean changeTeamLeaderRedirect {get; set;}
        public boolean EndLeadershipRedirect {get; set;}
        public boolean changeLeaderTeamRedirect {get; set;}
        PageReference pageRef = ApexPages.currentPage();
        //pageReference contactPage = new ApexPages.StandardController(contact).view();
        //PageReference contactPage1 = new PageReference('/' + this.contact.id);
        
        public void setSustainer() {
                //if (memType == 'Sustainer') {
                        isSustainer=true;
                //}
        }
        
        public pageReference showJoin () {
            joinRedirect = true;
            return null;        
        }
        
        public void showButtons () {
            showButtonsSection = true;
        }
        
        public void showMemDetailBlock () {
        	showMemDetailBlockSection = true;
        }
        
        public void showLdrDetailBlock () {
        	showLdrDetailBlockSection = true;
        }

        public void showRenew () {
            renewRedirect = true;
        }

        public void showQuit() {
	        quitRedirect = true;
        }

        public void showLeaderConvert() {
            LeaderConvertRedirect = true;
        }

        public void showChangeTeamLeader() {
            changeTeamLeaderRedirect = true;
        }

        public void showEndLeadership() {
            EndLeadershipRedirect = true;
        }
        
        public void showchangeLeaderTeam () {
        	changeLeaderTeamRedirect = true;
        }
         
        public string teamId {
            set;
            get {
                if (teamId == null) teamId = this.contact.stand_team_affiliation__c;
                return TeamId;
            }
        }
        
        public double giftAmount {get; set;}
        public string frequency {get; set;}
        public string payType {get; set;}
        public Transient string ccNumber {get; set;}
        public Transient string cv2 {get; set;}
        public string nameOnCard {get; set;}
        public string expDate {get; set;}
        public boolean isSustainer {get; set;}
        public string expMonth {get; set;}
        public string expYear {get; set;} 
        
                
        public boolean isCredit {get; set;}
        
        

        public List <selectOption> getTeams(){
            string userState = ([SELECT Primary_State_Office__c from USER where id=: UserInfo.getUserId()].Primary_State_Office__c);
            List<selectOption> options = new list <selectOption>();
            
            list <Account> teamList = new list <Account>([SELECT id, Name FROM Account WHERE Type = :'Stand Team' AND BillingState = :userState]);
            
            options.add(new selectOption('','--select Team--'));
            
            for (Account a: teamList) {
                    options.add(new selectOption(a.id, a.Name));
            }
            
            return options;
        }
        
        public List <selectOption> getPayTypes(){
            List<selectOption> options = new list <selectOption>();
            
            options.add(new selectOption('Cash','Cash'));
            options.add(new selectOption('Check','Check'));
            options.add(new selectOption('Credit Card','Credit Card'));
            
            return options;
        }
        
        public List <selectOption> getFrequencies(){
            List<selectOption> options = new list <selectOption>();
            
            if (memType == 'Sustaining') {
            	options.add(new selectOption('Month','Monthly'));
            	options.add(new selectOption('Quarter','Quarterly'));
            	options.add(new selectOption('Year','Annually'));
            } else {
            	options.add(new selectOption('', ''));
            }
            
            return options;
        }
        
        public List <selectOption> getMemTypes(){
            List<selectOption> options = new list <selectOption>();
            
            options.add(new selectOption('',''));
            options.add(new selectOption('Annual', 'Annual'));
            options.add(new selectOption('Sustaining', 'Sustaining'));
            
            return options;
        }
        
        public List <selectOption> getLeaders(){
            List<selectOption> options = new list <selectOption>();
            
            list <Contact> leaderList = new list <Contact>([SELECT id, Name FROM Contact WHERE (Leader_Type__c =:'Leader' OR Leader_Type__c =:'Leader in Training') AND Stand_Team_Affiliation__c = :teamId]);
            
            options.add(new selectOption('','--No Leader--'));
            
            for (Contact ldr: leaderList) {
                    options.add(new selectOption(ldr.id, ldr.Name));
            }
            
            return options;
        }
        
        public List <selectOption> getMonths(){
            List<selectOption> options = new list <selectOption>();
            
            //Months are strings...
            options.add(new selectOption('','--'));
            options.add(new selectOption('01', '01'));
            options.add(new selectOption('02', '02'));
            options.add(new selectOption('03', '03'));
            options.add(new selectOption('04', '04'));
            options.add(new selectOption('05', '05'));
            options.add(new selectOption('06', '06'));
            options.add(new selectOption('07', '07'));
            options.add(new selectOption('08', '08'));
            options.add(new selectOption('09', '09'));
            options.add(new selectOption('10', '10'));
            options.add(new selectOption('11', '11'));
            options.add(new selectOption('12', '12'));
            
            return options;
        }
        
        public List <selectOption> getYears(){
           	integer year = integer.valueOf(HelperFunctions.YearHelper2Digit());
            List<selectOption> options = new list <selectOption>();
            
            options.add(new selectOption('','--'));
            
            for (integer j=0; J<10; j++) {
            	options.add(new selectOption(string.valueOf(year+j),string.valueOf(year+j)));
            }
            
            return options;
        }
       
        
		public pageReference joinMember () {
			PageReference contactPage = new PageReference('/' + this.contact.id);
            
			if ( payType == 'Cash') {
				if (cashCheckJoin ('Cash')) {
           			return contactPage;
           		}
           		else {
           			return null;
           		}
            } 
			if (payType == 'Check')  {
           		if (cashCheckJoin ('Check')) {
           			return contactPage;
           		}
           		else {
           			return null;
           		}
           	}
           	
			if (payType == 'Credit Card') {
           		if (creditCardJoin()) {
           			return contactPage;
           		}
           		else {
           			return null;
           		}
           	}
           	
           	else {
           		throw new StandException('Payment Type not Recognized');
           		return null;
           	}
           	
        }
           		
        private boolean creditCardJoin () {
            
            Person person = new Person();
            person.getById(contact.id);
            
            double donationA = giftAmount;
            
            CCInterface cc = new CCInterface ();
			cc.cardHolderFirstName = contact.FirstName;
            cc.cardHolderLastName = contact.LastName;
            cc.cardHolderNameOnCard = nameOnCard;
            cc.cardNumber = ccNumber;
            cc.cv2 = cv2;
            cc.expirationDate = expMonth + '/' + expYear;
            cc.ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            cc.donationAmount = giftAmount;
            cc.campaignName = '';
            if (memType == 'Sustaining') {
            	cc.recurringPayment = true;
            	cc.recurringPeriod = frequency;
            } else {
            	cc.recurringPayment = false;
            }   
            
            person.Membership.membership_type = memType;
            person.Membership.team_id = teamId;
            person.Membership.leader_id = leaderId;
            person.Membership.gift_amount = giftAmount;
            person.membership.notes = membershipNotes;
            
            //attempt to run the card and create the Membership.  Return any custom error messages if failed
            try {
            	person.Membership.create(person, cc);
            	person.Membership.updateNotes(person);
            } catch (StandException excp) {
            	ApexPages.addMessages(excp);
            	return false;
            } catch (Exception e) {
            	ApexPages.addMessages(e);
            }
            
            return true;
            
        }
        
        private boolean cashCheckJoin (string payType) {
            Person person = new Person();
            person.getById(contact.id);
            
            system.debug('***************************ControllerMemType'+memType);
            person.Membership.membership_type = memType;
            person.Membership.team_id = teamId;
            person.Membership.leader_id = leaderId;
            person.Membership.gift_amount = giftAmount;
            person.membership.notes = membershipNotes;
            
            try {
            	person.Membership.joinCashCheck (person, payType);
            	person.Membership.updateNotes(person);
            } catch (StandException excp) {
            	ApexPages.addMessages(excp);
            	return false;
            } catch (Exception e) {
            	ApexPages.addMessages(e);
            }
            
            return true;
        }
        
        public pageReference renewMember () {
        	PageReference contactPage = new PageReference('/' + this.contact.id);
        	//validate Field Entries
        	
        	
        	if ( payType == 'Cash') {
           		if (cashCheckRenew ('Cash')) {
           			return contactPage;
           		} 
           		else {
           			return null;
           		}
            } 
           	
			if (payType == 'Check')  {
           		if (cashCheckRenew ('Check')) {
           			return contactPage;
           		}
           		else {
           			return null;
           		}
           	}
           	
			if (payType == 'Credit Card') {
           		if (creditCardRenew()) {
           			return contactPage;
           		}
           		else {
           			return null;
           		}
           	}
           	
			else {
           		throw new StandException('Payment Type not Recognized');
           		return null;
           	}
        }
        
        private boolean creditCardRenew () {
            
            Person person = new Person();
            person.getById(contact.id);
            
            
            CCInterface cc = new CCInterface ();
            cc.cardHolderFirstName = contact.FirstName;
            cc.cardHolderLastName = contact.LastName;
            cc.cardHolderNameOnCard = nameOnCard;
            cc.cardNumber = ccNumber;
            cc.cv2 = cv2;
            cc.expirationDate = expMonth + '/' + expYear;
            cc.ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            cc.donationAmount = giftAmount;
            
            cc.campaignName = '';
            if (memType == 'Sustaining') {
            	cc.recurringPayment = true;
            	cc.recurringPeriod = frequency;
            } else {
            	cc.recurringPayment = false;
            }
            
            person.Membership.membership_type = memType;
            person.Membership.team_id = teamId;
            person.Membership.leader_id = leaderId;
            person.Membership.notes = membershipNotes;
            person.Membership.gift_amount = giftAmount;

			//attempt to run the card and renew the Membership.  Return any custom error messages if failed
            try {
            	person.Membership.renewCC(person, cc);
            	person.Membership.updateNotes(person); 
            } catch (StandException excp) {
            	ApexPages.addMessages(excp);
            	return false;
            }

            return true;
        }
        
        private boolean cashCheckRenew (string payType) {
        	Person person = new Person();
            
            try {
            	person.getById(contact.id);
            
            
	            person.Membership.membership_type = memType;
	            person.Membership.team_id = teamId;
	            person.Membership.leader_id = leaderId;
	            person.Membership.gift_amount = giftAmount;
	            person.membership.notes = membershipNotes;
            	person.Membership.renewCashCheck (person, payType);
            	person.Membership.updateNotes(person);
            	
           } catch (StandException ex) {
            	ApexPages.AddMessages(ex);
            	return false;
            } catch (Exception e) {
            	ApexPages.AddMessages(e);
            	return false;
            }

            return true;
        	
        }
        
        public pageReference convertToLeader () {
        	PageReference contactPage = new PageReference('/' + this.contact.id);
                
            Leader leader = new Leader();
            leader.getByID(contact.id);
            
            Person person = new Person();
            person.getById(contact.id);
                        
            //If Team has changed, first Change Team, then create as Leader
            if(leader.Leader.Membership.team_id != teamId ) {
            	person.getById(contact.id);
            	person.Membership.team_id = teamId;
            	person.Membership.changeTeam(person);
            }
            
            try {
                leader.create();
            	return contactPage;
            } catch (Exception e) {
                ApexPages.addMessages(e);
                return null;  
            }
            
                   
                
        }
        
        public pageReference quitMember () {
         	PageReference contactPage = new PageReference('/' + this.contact.id);
                
            Person person = new Person();
            person.getById(contact.id);
            person.membership.notes = membershipNotes;
            
                
            try {
                person.Membership.quit(person);
				person.Membership.updateNotes(person);                    
                return contactPage;
            } catch (Exception e) {
                ApexPages.addMessages(e);
                return null;
            }            

        }
        
        public void changeTeamLeader () {
            Person person = new Person();
            person.getById(contact.id);
            
			person.membership.notes = membershipNotes;
            person.Membership.updateNotes(person);
            
            person.Membership.team_id = teamId;
            person.Membership.leader_id = leaderId;
                
            if (contact.Stand_Team_Affiliation__c != teamId) {
                    person.Membership.changeTeam(person);
            }
            if (contact.Stand_Leader__c != leaderId) {
                    person.Membership.changeLeader(person);
            }
            
            refreshPage = true;
 
                
        }
        
        public void endLeadership () {
            Leader leader = new Leader();
            leader.getById(contact.id);
            
            leader.endLeadership();
            
            refreshPage = true;
                
        }
        
    	public void changeLeaderTeam () {
            Leader leader = new Leader();
            leader.getById(contact.id);
            leader.leader.Membership.team_id = teamId;
            
            leader.changeTeam();
            
            refreshPage = true;
                
        }
        
    // custom class to encapsulate a value and error message
	public class ValueAndError
	{
		public String value {get; set;}
		public String error {get; set;} 
		
		public Boolean getHasError()
		{
			return (!String.IsBlank(error));
		}
	}
        
        

}