@isTest
public with sharing class EmailQueueLapsedMembersButton_Test {

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
        
        EmailQueueLapsedMembersButton.showHideButton(objMembershipA.Id);
        EmailQueueLapsedMembersButton.createEmail(objMembershipA.Id);

        objMembershipA.Start_Date__c =  System.today().addDays(FirstLapsePeriod-900);
        objMembershipA.Membership_Action__c = 'Edit';      
        update objMembershipA; 

        EmailQueueLapsedMembersButton.showHideButton(objMembershipA.Id);
        EmailQueueLapsedMembersButton.createEmail(objMembershipA.Id);

        objMembershipA.Start_Date__c =  System.today();
        objMembershipA.Membership_Action__c = 'Edit';      
        update objMembershipA; 

        EmailQueueLapsedMembersButton.showHideButton(objMembershipA.Id);
        EmailQueueLapsedMembersButton.createEmail(objMembershipA.Id);

        
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
        
        EmailQueueLapsedMembersButton.showHideButton(objMembershipB.Id);
        EmailQueueLapsedMembersButton.createEmail(objMembershipB.Id);
        
        delete objMembershipB;

        EmailQueueLapsedMembersButton.showHideButton(objMembershipB.Id);
        EmailQueueLapsedMembersButton.createEmail(objMembershipB.Id);
        
    }

    public static TestMethod void TestEmailQueueLapsedMembers_Test2() {

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


        EmailQueueLapsedMembersButton.showHideButton(objMembershipC.Id);
        EmailQueueLapsedMembersButton.createEmail(objMembershipC.Id);

    }

    public static TestMethod void TestAbbrevToFullState() {
		String abbrev;
		abbrev = 'AL';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'AK';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'AZ';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'AR';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'CA';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'CO';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'CT';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'DE';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'FL';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'GA';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'HI';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'ID';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'IL';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'IN';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'IA';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'KS';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'KY';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'LA';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'ME';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'MD';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'MA';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'MI';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'MN';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'MS';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'MO';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'MT';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'NE';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'NV';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'NH';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'NJ';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'NM';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'NY';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'NC';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'ND';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'OH';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'OK';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'OR';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'PA';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'RI';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'SC';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'SD';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'TN';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'TX';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'UT';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'VT';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'VA';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'WA';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'WV';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'WI';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
		abbrev = 'WY';
		EmailQueueLapsedMembersButton.abbrevToFullStatev(abbrev);
	}
    
}