public class MembershipFunctionControllerSavePoint {
        
        private final Contact contact;
        public Boolean refreshPage {get; set;}
        public ApexPages.StandardController stdCtrl {get; set;}
        public string leaderId {get; set;}
        public boolean showButtonsSection {get; set;}
        public string sectionName {get; set;}
        
        
        public String teamIdError {get; set;}
        
        public MembershipFunctionControllerSavePoint(ApexPages.StandardController controller) {
                
            controller.addFields(new List<String>{'FirstName', 'LastName', 'stand_team_Affiliation__c', 'membership_type__c', 'membership_status__c', 'is_member__c', 'is_leader__c', 'Stand_Leader__c'});
            this.contact = (Contact)controller.getRecord();
            refreshPage = false;
            leaderId = this.contact.Stand_Leader__c;
            teamIdError='';
            stdCtrl = controller;
            showButtonsSection = true;
        } 

          public PageReference doCancel () {
            pageRef.setRedirect(true);
            return pageRef;
        }

        

        public string userId {get; private set;}
        public boolean showJoinSection {get; set;}
        public boolean showRenewSection {get; set;}
        public boolean showQuitSection {get; set;}
        public boolean showLeaderConvertSection {get; set;}
        public boolean showChangeTeamLeaderSection {get; set;}
        public boolean showEndLeadershipSection {get; set;}
        PageReference pageRef = ApexPages.currentPage();
        
        public void setSustainer() {
                //if (memType == 'Sustainer') {
                        isSustainer=true;
                //}
        }
        
        public void showJoin () {
            showJoinSection = true;
            showButtonsSection=false;    
        }
        
        public void showButtons () {
                showButtonsSection = true;
        }

        public void showRenew () {
            showRenewSection = true;
            showButtonsSection=false; 
        }

        public void showQuit() {
	        showQuitSection = true;
	        showButtonsSection=false; 
        }

        public void showLeaderConvert() {
            showLeaderConvertSection = true;
            showButtonsSection=false; 
        }

        public void showChangeTeamLeader() {
            showChangeTeamLeaderSection = true;
            showButtonsSection=false; 
        }

        public void showEndLeadership() {
            showEndLeadershipSection = true;
            showButtonsSection=false; 
        }
         
        public string memType {
            set;
            get {
                if (memType == null) memType = this.contact.membership_type__c;
                return memType;
            }
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
                
        public boolean isCredit {get; set;}
        
        

        public List <selectOption> getTeams(){
            string userState = ([SELECT Primary_State_Office__c from USER where id=: UserInfo.getUserId()].Primary_State_Office__c);
            List<selectOption> options = new list <selectOption>();
            
            list <Account> teamList = new list <Account>([SELECT id, Name FROM Account WHERE Type = :'Stand Team' AND BillingState = :userState]);
            
            options.add(new selectOption('--select Team--','--select Team--'));
            
            for (Account a: teamList) {
                    options.add(new selectOption(a.id, a.Name));
            }
            
            return options;
        }
        
        public List <selectOption> getPayTypes(){
            List<selectOption> options = new list <selectOption>();
            
            options.add(new selectOption('Credit Card','Credit Card'));
            options.add(new selectOption('Cash','Cash'));
            options.add(new selectOption('Check','Check'));
            
            return options;
        }
        
        public List <selectOption> getFrequencies(){
            List<selectOption> options = new list <selectOption>();
            
            if (memType == 'Sustaining') {
            	options.add(new selectOption('Month','Month'));
            	options.add(new selectOption('Quarter','Quarter'));
            	options.add(new selectOption('Year','Year'));
            } else {
            	options.add(new selectOption('', '---Sustaining Only---'));
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
       
        
        public pageReference joinMember () {

                        
            Person person = new Person();
            person.getById(contact.id);
            
            double donationA = giftAmount;
            
            CCInterface cc = new CCInterface ();
			cc.cardHolderFirstName = contact.FirstName;
            cc.cardHolderLastName = contact.LastName;
            cc.cardHolderNameOnCard = nameOnCard;
            cc.cardNumber = ccNumber;
            cc.cv2 = cv2;
            cc.expirationDate = expDate;
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
            
            if (person.Membership.create(person, cc)) {
                    //hooray
            }

            showJoinSection = false;
            
            pageRef.setRedirect(true);
            return pageRef;
            
		
        }
        
        public pageReference renewMember () {
            
            Person person = new Person();
            person.getById(contact.id);
           
            
            double donationA = giftAmount;
            
            CCInterface cc = new CCInterface ();
            cc.cardHolderFirstName = contact.FirstName;
            cc.cardHolderLastName = contact.LastName;
            cc.cardHolderNameOnCard = nameOnCard;
            cc.cardNumber = ccNumber;
            cc.cv2 = cv2;
            cc.expirationDate = expDate;
            cc.ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            cc.donationAmount = giftAmount;
            cc.campaignName = '';
            if (memType == 'Sustaining') {
            	cc.recurringPayment = true;
            	cc.recurringPeriod = frequency;
            } else {
            	cc.recurringPayment = false;
            }
                
            system.debug('***************************************************ipAddress'+cc.ipAddress);
            system.debug('***************************************************memType'+memType);
            system.debug('***************************************************leaderIdPreAssignment'+leaderId);
            system.debug('***************************************************person.Membership.leader_id'+person.Membership.leader_id);
            
            person.Membership.membership_type = memType;
            person.Membership.team_id = teamId;
            if (leaderId == '') {
                person.Membership.leader_id = null;
            } else {
                person.Membership.leader_id = leaderId;
            }
            
            if (person.Membership.renew(person, cc)) {
                    //hooray
            }
                      
            pageRef.setRedirect(true);
            return pageRef;

        }
        
        public pageReference convertToLeader () {
                
                Person person = new Person();
            person.getById(contact.id);
            
            if ( person.Membership.convertIntoLeader(person)) {
                //hooray
            }
            
            pageRef.setRedirect(true);
            return pageRef;         
                
        }
        
        public pageReference quitMember () {
                
            Person person = new Person();
            person.getById(contact.id);
                
            if (person.Membership.quit(person)) {
                    //hooray
            }
            
            pageRef.setRedirect(true);
            return pageRef;

        }
        
        public pageReference changeTeamLeader () {
            Person person = new Person();
            person.getById(contact.id);
            
            person.Membership.team_id = teamId;
            person.Membership.leader_id = leaderId;
                
            if (contact.Stand_Team_Affiliation__c != teamId) {
                    person.Membership.changeTeam(person);
            }
            if (contact.Stand_Leader__c != leaderId) {
                    person.Membership.changeLeader(person);
            }
            
            pageRef.setRedirect(true);
            return pageRef;
 
                
        }
        
        public pageReference endLeadership () {
            Leader leader = new Leader();
            leader.getById(contact.id);
            
            leader.endLeadership();
            
            pageRef.setRedirect(true);
            return pageRef;

                
        }

}