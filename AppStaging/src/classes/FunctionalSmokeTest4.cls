@isTest
public with sharing class FunctionalSmokeTest4 {

	// test inserting a contact on the Contact page (standard controller)
	// verify data is correct in saved record
	public static TestMethod void createContactInBrowserTest() {
		// create the contact object and set the field values
		// but don't save
		Contact c1 = new Contact();
		c1.FirstName = 'FunSmo4createContactsTest';
		c1.LastName = 'createContactsTest';
		c1.Stand_Office__c = 'MA';
		
		// instantiate the standard controller for the Contact page
        ApexPages.StandardController controller = new ApexPages.standardController(c1);
        // press the save button on the contact page
		controller.save();
		
		// see if the record was saved
		List <Contact> cList = new List <Contact>([SELECT Id, FirstName, LastName, Stand_Office__c FROM Contact WHERE FirstName =: 'FunSmo4createContactsTest']);
		// verify the data is correct
		System.assertEquals(cList.size(),1);
		System.assertEquals(cList[0].FirstName,'FunSmo4createContactsTest');
		System.assertEquals(cLIst[0].LastName, 'createContactsTest');
		System.assertEquals(cList[0].Stand_Office__c, 'MA');

	}


	// test inserting a contact on the Contact page (standard controller)
	// then updating the Contact on the Contact page (standard controller)
	// verify data is correct in saved record
	public static TestMethod void createUpdateContactInBrowserTest() {
		// create the contact object and set the field values
		// but don't save
		Contact c1 = new Contact();
		c1.FirstName = 'FunSmo4createUpdateContactInBrowserTest';
		c1.LastName = 'createContactsTest';
		c1.Stand_Office__c = 'MA';
		
		// instantiate the standard controller for the Contact page
        ApexPages.StandardController controller = new ApexPages.standardController(c1);
        // press the save button on the contact page
		controller.save();
		
		// see if the record was saved
		List <Contact> cList = new List <Contact>([SELECT Id, FirstName, LastName, Stand_Office__c FROM Contact WHERE FirstName =: 'FunSmo4createUpdateContactInBrowserTest']);
		// verify the data is correct
		System.assertEquals(cList.size(),1);
		System.assertEquals(cList[0].FirstName,'FunSmo4createUpdateContactInBrowserTest');
		System.assertEquals(cLIst[0].LastName, 'createContactsTest');
		System.assertEquals(cList[0].Stand_Office__c, 'MA');

		// get the record that was just saved
		Contact c2 = [SELECT ID FROM Contact WHERE Id =: cList[0].Id];
		// instantiate the standard controller again, to be used with the Edit page
		ApexPages.standardController Econtroller = new ApexPages.standardController(c2);
		// set the controller to the edit page
		Econtroller.edit();
		// update the Contact
		c2.FirstName = 'FunSmo4New';
		c2.LastName = 'createContactsTest';
		c2.Stand_Office__c = 'MA';
		// press the save button on the contact page
		Econtroller.save();
		
		// see if the record was saved
		cList = new List <Contact>([SELECT Id, FirstName, LastName, Stand_Office__c FROM Contact WHERE FirstName =: 'FunSmo4New']);
		// verify the data is correct
		System.assertEquals(cList.size(),1);
		System.assertEquals(cList[0].FirstName,'FunSmo4New');
		System.assertEquals(cLIst[0].LastName, 'createContactsTest');
		System.assertEquals(cList[0].Stand_Office__c, 'MA');
		
		// make sure that the record was updated and a new record wasn't created
		// query the old firstname and make sure it doesn't exist
		List <Contact> cList2 = new List <Contact>([SELECT Id, FirstName, LastName, Stand_Office__c FROM Contact WHERE FirstName =: 'FunSmo4createUpdateContactInBrowserTest']);
		System.assertEquals(cList2.size(),0);
	}


	// test inserting a membership on the Membership page (standard controller)
	// this test creates the membership, oppportunity, and affiliation
	// verify data is correct in saved record
	public static TestMethod void createMembershipInBrowserTest() {
		// create the contact that will be used for the Membership
		Contact c1 = new Contact();
		c1.FirstName = 'FunSmo4createMembershipInBrowserTest';
		c1.LastName = 'createMembershipInBrowserTest';
		c1.Stand_Office__c = 'MA';
		insert c1;
		
		// create the membership object and set the field values
		// but don't save
		Membership__c m = new Membership__c();
   	    m.Contact__c = c1.Id;
       	m.Membership_State__c = 'MA';          
        m.Start_Date__c =  System.Today();
   	    m.Gift_Amount__c = 12345;
       	m.Type__c = 'Annual';    
        m.Membership_Source__c = 'Event';
   	    m.Membership_Action__c = 'Join';      
 
 		// instantiate the standard controller for the Contact page
        ApexPages.StandardController controller = new ApexPages.standardController(m);
        // press the save button on the contact page
		controller.save();
		
		// see if the record was saved
		List <Membership__c> mList = new List <Membership__c>([SELECT Id, Contact__c, Membership_State__c, Type__c FROM Membership__c WHERE Contact__c = : c1.Id]);
		// verify the data is correct
		System.assertEquals(mList.size(),1);
		System.assertEquals(mList[0].Contact__c, c1.Id);
		System.assertEquals(mLIst[0].Membership_State__c, 'MA');
		System.assertEquals(mList[0].Type__c, 'Annual');
 
 		// get the AccountId for the Contact
 		List <Contact> c2 = new List <Contact>([SELECT Id, AccountId FROM Contact WHERE Id = : c1.Id]);
 		// see if the record was saved
 		List <Opportunity> oList = new List <Opportunity>([SELECT Id, Name, Amount FROM Opportunity WHERE AccountId = : c2[0].AccountId]);
 		// verify the data is correct
 		System.assertEquals(oList.size(), 1);
 		System.assertEquals(oList[0].Amount, 12345);
 
	}


	// test inserting a membership on the Membership page (standard controller)
	// this test creates the membership, oppportunity, and affiliation
	// verify data is correct in saved record
	public static TestMethod void createUpdateMembershipInBrowserTest() {
		// create the contact that will be used for the Membership
		Contact c1 = new Contact();
		c1.FirstName = 'FunSmo4createMembershipInBrowserTest';
		c1.LastName = 'createMembershipInBrowserTest';
		c1.Stand_Office__c = 'MA';
		insert c1;
		
		// create the membership object and set the field values
		// but don't save
		Membership__c m = new Membership__c();
   	    m.Contact__c = c1.Id;
       	m.Membership_State__c = 'MA';          
        m.Start_Date__c =  System.Today();
   	    m.Gift_Amount__c = 12345;
       	m.Type__c = 'Annual';    
        m.Membership_Source__c = 'Event';
   	    m.Membership_Action__c = 'Join';      
 
 		// instantiate the standard controller for the Contact page
        ApexPages.StandardController controller = new ApexPages.standardController(m);
        // press the save button on the contact page
		controller.save();
		
		// see if the record was saved
		List <Membership__c> mList = new List <Membership__c>([SELECT Id, Contact__c, Membership_State__c, Type__c FROM Membership__c WHERE Contact__c = : c1.Id]);
		// verify the data is correct
		System.assertEquals(mList.size(),1);
		System.assertEquals(mList[0].Contact__c, c1.Id);
		System.assertEquals(mLIst[0].Membership_State__c, 'MA');
		System.assertEquals(mList[0].Type__c, 'Annual');
 
 		// get the AccountId for the Contact
 		List <Contact> c2 = new List <Contact>([SELECT Id, AccountId FROM Contact WHERE Id = : c1.Id]);
 		// see if the record was saved
 		List <Opportunity> oList = new List <Opportunity>([SELECT Id, Name, Amount FROM Opportunity WHERE AccountId = : c2[0].AccountId]);
 		// verify the data is correct
 		System.assertEquals(oList.size(), 1);
 		System.assertEquals(oList[0].Amount, 12345);


		// get the record that was just saved
		Membership__c m2 = [SELECT ID, Membership_State__c, Start_Date__c, Type__c, Membership_Source__c, Gift_Amount__c, Membership_Action__c FROM Membership__c WHERE Id =: mList[0].Id];
		// instantiate the standard controller again, to be used with the Edit page
		ApexPages.standardController Econtroller = new ApexPages.standardController(m2);
		// set the controller to the edit page
		Econtroller.edit();
		// update the Membership
       	m2.Membership_State__c = 'MA';          
        m2.Start_Date__c =  System.Today();
       	m2.Type__c = 'Sustaining';    
        m2.Membership_Source__c = 'Event';
		m2.Gift_Amount__c = 12345;
   	    m2.Membership_Action__c = 'Edit';
		// press the save button on the contact page
		Econtroller.save();

		// see if the record was saved
		List <Membership__c> mList2 = new List <Membership__c>([SELECT Id, Contact__c, Membership_State__c, Type__c FROM Membership__c WHERE Id = : m2.Id]);
		// verify the data is correct
		System.assertEquals(mList2.size(),1);
		System.assertEquals(mList2[0].Contact__c, c1.Id);
		System.assertEquals(mLIst2[0].Membership_State__c, 'MA');
		System.assertEquals(mList2[0].Type__c, 'Sustaining');
 
 		// get the AccountId for the Contact
 		List <Contact> c3 = new List <Contact>([SELECT Id, AccountId FROM Contact WHERE Id = : c1.Id]);
 		// see if the record was saved
 		List <Opportunity> oList2 = new List <Opportunity>([SELECT Id, Name, Amount FROM Opportunity WHERE AccountId = : c3[0].AccountId]);
 		// verify the data is correct
 		System.assertEquals(oList2.size(), 1);
 		System.assertEquals(oList2[0].Amount, 12345);
 
	}


}