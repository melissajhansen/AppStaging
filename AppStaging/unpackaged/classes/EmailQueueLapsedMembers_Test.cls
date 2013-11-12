@isTest
public class EmailQueueLapsedMembers_Test {

	public static Integer FirstLapsePeriod = 30;
	public static Integer SecondLapsePeriod = 7;
	public static Integer ThirdlapsePeriod = -7;

    public static TestMethod void TestEmailQueueLapsedMembers_Test() {
	Test.startTest();
        
		// Test 1
		// FirstLapsePeriod
        Contact objContactA = new Contact();
        objContactA.FirstName = 'MemberRequest';
        objContactA.LastName = 'Contact 1';
        objContactA.Stand_Office__c = 'OR';
        objContactA.Email = 'test@stand.org';
        insert objContactA;

        Membership__c objMembershipA = new Membership__c();
        objMembershipA.Contact__c = objContactA.Id;
        objMembershipA.Membership_State__c = 'OR';          
        objMembershipA.Start_Date__c =  System.today().addDays(FirstLapsePeriod-365);
        objMembershipA.Gift_Amount__c = Decimal.valueOf('10.00');
        objMembershipA.Type__c = 'Annual';    
        objMembershipA.Membership_Source__c = 'Phone';
        objMembershipA.Membership_Action__c = 'Join';      
        insert objMembershipA; 
        
        objMembershipA.Start_Date__c =  System.today().addDays(FirstLapsePeriod-365);
        objMembershipA.Membership_Action__c = 'Edit';      
        update objMembershipA; 
        
		// Test 2
		// SecondLapsePeriod
        Contact objContactB = new Contact();
        objContactB.FirstName = 'MemberRequest';
        objContactB.LastName = 'Contact 2';
        objContactB.Stand_Office__c = 'OR';
        objContactB.Email = 'test@stand.org';
        insert objContactB;

        Membership__c objMembershipB = new Membership__c();
        objMembershipB.Contact__c = objContactB.Id;
        objMembershipB.Membership_State__c = 'OR';          
        objMembershipB.Start_Date__c =  System.today().addDays(SecondLapsePeriod-365);
        objMembershipB.Gift_Amount__c = Decimal.valueOf('10.00');
        objMembershipB.Type__c = 'Annual';    
        objMembershipB.Membership_Source__c = 'Phone';
        objMembershipB.Membership_Action__c = 'Join';      
        insert objMembershipB; 
        
        objMembershipB.Start_Date__c =  System.today().addDays(SecondLapsePeriod-365);
        objMembershipB.Membership_Action__c = 'Edit';      
        update objMembershipB; 

		EmailQueueLapsedMembers e = new EmailQueueLapsedMembers();
		//e.sweepLapsedMembers();
		//e.sweepEmailQueue();
		string sch = '0 0 * * 1-12 ? *';
		system.schedule('EmailQueueLapsedMembers Test',sch,e);
        
    Test.stopTest();

		List <Account> optedInStates = new List <Account> ([SELECT ID FROM Account WHERE Type =: 'Stand Affiliate State' AND OptStateOutOfLapsedMemberEmails__c =: False ]);
		
		if ( optedInStates.size()>= 1) {
			List <EmailQueue__c> lEQ = new List <EmailQueue__c>([SELECT Id FROM EmailQueue__c WHERE Name = 'MemberRequest Contact 1 Lapsing Email']);
			System.AssertEquals(lEQ.size(), 1);
			List <EmailQueue__c> lEQ2 = new List <EmailQueue__c>([SELECT Id FROM EmailQueue__c WHERE Name = 'MemberRequest Contact 2 Lapsing Email']);
			System.AssertEquals(lEQ2.size(), 1);
		}
    }

    public static TestMethod void TestEmailQueueLapsedMembers_Test2() {
	Test.startTest();
		// Test 3
		// ThirdlapsePeriod
        Contact objContactC = new Contact();
        objContactC.FirstName = 'MemberRequest';
        objContactC.LastName = 'Contact 3';
        objContactC.Stand_Office__c = 'OR';
        objContactC.Email = 'test@stand.org';
        insert objContactC;

        Membership__c objMembershipC = new Membership__c();
        objMembershipC.Contact__c = objContactC.Id;
        objMembershipC.Membership_State__c = 'OR';          
        objMembershipC.Start_Date__c =  System.today().addDays(ThirdlapsePeriod-365);
        objMembershipC.Gift_Amount__c = Decimal.valueOf('10.00');
        objMembershipC.Type__c = 'Annual';    
        objMembershipC.Membership_Source__c = 'Phone';
        objMembershipC.Membership_Action__c = 'Join';      
        insert objMembershipC; 
        
        objMembershipC.Start_Date__c =  System.today().addDays(ThirdlapsePeriod-365);
        objMembershipC.Membership_Action__c = 'Edit';      
        update objMembershipC; 


		EmailQueueLapsedMembers e = new EmailQueueLapsedMembers();
		//e.sweepLapsedMembers();
		//e.sweepEmailQueue();
		string sch = '0 0 * * 1-12 ? *';
		system.schedule('EmailQueueLapsedMembers Test',sch,e);
		
	Test.stopTest();
	
		List <Account> optedInStates = new List <Account> ([SELECT ID FROM Account WHERE Type =: 'Stand Affiliate State' AND OptStateOutOfLapsedMemberEmails__c =: False ]);
		
		if ( optedInStates.size()>= 1) {
			List <EmailQueue__c> lEQ = new List <EmailQueue__c>([SELECT Id FROM EmailQueue__c WHERE Name = 'MemberRequest Contact 3 Lapsed Email']);
			System.AssertEquals(lEQ.size(), 1);
		}

/*		
		List <EmailQueue__c> lEQ = new List <EmailQueue__c>([SELECT Id, Name FROM EmailQueue__c WHERE EmailType__c = 'Lapsed 7 days ago Member Email']);
		System.debug('===============START===============');
		for ( EmailQueue__c eq : lEQ ) {
			System.debug(eq.Name);
		}		
		
		List <Membership__c> mList = ([select id, Contact__r.Name, Expiration_Date__c from Membership__c where Expiration_Date__c = : System.today().addDays(ThirdlapsePeriod)]);
		System.debug('===============START 2=====================');
		for ( Membership__c m : mList ) {
			System.debug(m.Contact__R.Name);
			System.debug(m.Expiration_Date__c);
		}
		System.debug(System.today().addDays(ThirdlapsePeriod));
*/

    }

    public static TestMethod void TestEmailQueueLapsedMembers_Test3() {
    Test.startTest();
    
    	Account objAccount = new Account();
	    objAccount.Name = 'HI State Office';
	    objAccount.Type = 'Stand Affiliate State';
	    objAccount.Acquired_By__c = 'C3 Acquired';
	    objAccount.State_Abbreviation__c = 'HI';
	    objAccount.BillingState = 'HI';
	    objAccount.OptStateOutOfLapsedMemberEmails__c = true;
	    insert objAccount;
	    
		// Test 4
		// FirstLapsePeriod
		// State is opted out
        Contact objContactA = new Contact();
        objContactA.FirstName = 'MemberRequest';
        objContactA.LastName = 'Contact 4';
        objContactA.Stand_Office__c = 'HI';
        insert objContactA;

        Membership__c objMembershipA = new Membership__c();
        objMembershipA.Contact__c = objContactA.Id;
        objMembershipA.Membership_State__c = 'HI';          
        objMembershipA.Start_Date__c =  System.today().addDays(FirstLapsePeriod-365);
        objMembershipA.Gift_Amount__c = Decimal.valueOf('10.00');
        objMembershipA.Type__c = 'Annual';    
        objMembershipA.Membership_Source__c = 'Phone';
        objMembershipA.Membership_Action__c = 'Join';      
        insert objMembershipA; 
        
        objMembershipA.Start_Date__c =  System.today().addDays(FirstLapsePeriod-365);
        objMembershipA.Membership_Action__c = 'Edit';      
        update objMembershipA; 
       
        List <Account> optedInStates = new List <Account> ([SELECT ID FROM Account WHERE Type =: 'Stand Affiliate State' AND OptStateOutOfLapsedMemberEmails__c =: False ]);
        
        if ( optedInStates.size()>= 1) {
			List <EmailQueue__c> lEQ = new List <EmailQueue__c>([SELECT Id FROM EmailQueue__c WHERE Name = 'MemberRequest Contact 4 Lapsing Email']);
			System.AssertEquals(lEQ.size(), 0);
        }
		
		// Test 5
		// FirstLapsePeriod
		// Contact is opted out
        Contact objContactB = new Contact();
        objContactB.FirstName = 'MemberRequest';
        objContactB.LastName = 'Contact 5';
        objContactB.Stand_Office__c = 'OR';
        objContactB.Exclusions__c = 'Do Not Send Automated Membership Renewal';
        insert objContactB;

        Membership__c objMembershipB = new Membership__c();
        objMembershipB.Contact__c = objContactB.Id;
        objMembershipB.Membership_State__c = 'OR';          
        objMembershipB.Start_Date__c =  System.today().addDays(FirstLapsePeriod-365);
        objMembershipB.Gift_Amount__c = Decimal.valueOf('10.00');
        objMembershipB.Type__c = 'Annual';    
        objMembershipB.Membership_Source__c = 'Phone';
        objMembershipB.Membership_Action__c = 'Join';      
        insert objMembershipB; 
        
        objMembershipB.Start_Date__c =  System.today().addDays(FirstLapsePeriod-365);
        objMembershipB.Membership_Action__c = 'Edit';      
        update objMembershipB; 
        
		EmailQueueLapsedMembers e = new EmailQueueLapsedMembers();
		//e.sweepLapsedMembers();
		//e.sweepEmailQueue();
		string sch = '0 0 * * 1-12 ? *';
		system.schedule('EmailQueueLapsedMembers Test',sch,e);
		
	Test.stopTest();
		
		if ( optedInStates.size()>= 1) {
			List <EmailQueue__c> lEQ2 = new List <EmailQueue__c>([SELECT Id FROM EmailQueue__c WHERE Name = 'MemberRequest Contact 5 Lapsing Email']);
			System.AssertEquals(lEQ2.size(), 0);
		}
		
    }

    public static TestMethod void TestAbbrevToFullState() {
		String abbrev;
		abbrev = 'AL';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'AK';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'AZ';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'AR';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'CA';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'CO';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'CT';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'DE';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'FL';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'GA';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'HI';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'ID';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'IL';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'IN';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'IA';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'KS';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'KY';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'LA';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'ME';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'MD';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'MA';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'MI';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'MN';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'MS';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'MO';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'MT';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'NE';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'NV';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'NH';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'NJ';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'NM';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'NY';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'NC';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'ND';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'OH';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'OK';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'OR';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'PA';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'RI';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'SC';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'SD';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'TN';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'TX';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'UT';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'VT';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'VA';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'WA';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'WV';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'WI';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
		abbrev = 'WY';
		EmailQueueLapsedMembers.abbrevToFullStatev(abbrev);
	}
    
}