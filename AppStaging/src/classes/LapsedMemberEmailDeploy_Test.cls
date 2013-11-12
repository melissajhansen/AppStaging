@isTest
public class LapsedMemberEmailDeploy_Test {

	public static Integer FirstLapsePeriod = 30;
	public static Integer SecondLapsePeriod = 7;
	public static Integer ThirdlapsePeriod = -7;

    public static TestMethod void TestEmailQueueLapsedMembers_Test() {

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
		e.sweepLapsedMembers();
		e.sweepEmailQueue();
		string sch = '0 0 * * 1-12 ? *';
		system.schedule('EmailQueueLapsedMembers Test',sch,e);

		List <Account> optedInStates = new List <Account> ([SELECT ID FROM Account WHERE Type =: 'Stand Affiliate State' AND OptStateOutOfLapsedMemberEmails__c =: False ]);
		
		if ( optedInStates.size()>= 1) {
			List <EmailQueue__c> lEQ = new List <EmailQueue__c>([SELECT Id FROM EmailQueue__c WHERE Name = 'MemberRequest Contact 1 Lapsing Email']);
			System.AssertEquals(lEQ.size(), 1);
			List <EmailQueue__c> lEQ2 = new List <EmailQueue__c>([SELECT Id FROM EmailQueue__c WHERE Name = 'MemberRequest Contact 2 Lapsing Email']);
			System.AssertEquals(lEQ2.size(), 1);
		}
    }
}