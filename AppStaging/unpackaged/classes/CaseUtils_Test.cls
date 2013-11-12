@isTest

public class CaseUtils_Test {
	
	// test the creation of the basic test case
	public static TestMethod void TestExceptionCase () {
		
		// create new contact
        Contact oContact = new Contact ();
        oContact.FirstName = 'Test';
        oContact.LastName = 'Contact Chapter1';
        oContact.Stand_Office__c = 'HI';
        insert oContact;
        
        // trigger the case helper
        CaseUtils oCaseU = new CaseUtils ();
        oCaseU.createAdminException ( 'ZIPLOOKUP', 'EXTRA', oContact );
        
        // look up the new case
        Case oCase = [ SELECT Id, Subject, Code__c, Description FROM Case WHERE ContactId =: oContact.Id ];
        
        // do an assert on the code value
        System.AssertEquals ( 'ZIPLOOKUP', oCase.Code__c );
        System.AssertEquals ( true, oCase.Description.contains ( 'EXTRA') );
	}
	
	// test Exceptions
	public static TestMethod void TestExceptionCase_Exceptions () {
		
        // trigger the case helper
        CaseUtils oCaseU = new CaseUtils ();
        oCaseU.createAdminException ( '', '', null );
        
	}
	
	// test the creation of an Owner exception
	public static TestMethod void TestExceptionCase_Owner () {
		
		// create new contact
        Contact oContact = new Contact ();
        oContact.FirstName = 'Test';
        oContact.LastName = 'Contact Chapter1';
        oContact.Stand_Office__c = 'HI';
        insert oContact;
        
        // trigger the case helper
        CaseUtils oCaseU = new CaseUtils ();
        oCaseU.createAdminException ( 'OWNER' , '', oContact );
        
        // look up the new case
        Case oCase = [ SELECT Id, Subject, Code__c FROM Case WHERE ContactId =: oContact.Id ];
        
        // do an assert on the code value
        System.AssertEquals ( 'OWNER', oCase.Code__c );
	}
	
	// test the creation of a Dupe exception
	public static TestMethod void TestExceptionCase_Dupe () {
		
		// create new contact
        Contact oContact = new Contact ();
        oContact.FirstName = 'Test';
        oContact.LastName = 'Contact Chapter1';
        oContact.Stand_Office__c = 'HI';
        insert oContact;
        
        // trigger the case helper
        CaseUtils oCaseU = new CaseUtils ();
        oCaseU.createAdminException ( 'DUPE' , '', oContact );
        
        // look up the new case
        Case oCase = [ SELECT Id, Subject, Code__c FROM Case WHERE ContactId =: oContact.Id ];
        
         // do an assert on the code value
        System.AssertEquals ( 'DUPE', oCase.Code__c );
	}
	
	// test the creation of a System exception
	public static TestMethod void TestExceptionCase_System () {
		
		// create new contact
        Contact oContact = new Contact ();
        oContact.FirstName = 'Test';
        oContact.LastName = 'Contact Chapter1';
        oContact.Stand_Office__c = 'HI';
        insert oContact;
        
        // trigger the case helper
        CaseUtils oCaseU = new CaseUtils ();
        oCaseU.createAdminException ( 'SYSTEM' , '', oContact );
        
        // look up the new case
        Case oCase = [ SELECT Id, Subject, Code__c FROM Case WHERE ContactId =: oContact.Id ];
        
         // do an assert on the code value
        System.AssertEquals ( 'SYSTEM', oCase.Code__c );
	}
	
	public static TestMethod void TestBulkCase () {
		
		// create new contact
        Contact oContact = new Contact ();
        oContact.FirstName = 'Test';
        oContact.LastName = 'Contact Chapter1';
        oContact.Stand_Office__c = 'HI';
        insert oContact;
        
        // case helper batch mode
        CaseUtils oCaseU = new CaseUtils ();
        
        // EXCEPTION - test ListSize before an init
        System.AssertEquals ( -1, oCaseU.bulkListSize());
        
        // do the standard init
        oCaseU.bulkInit();
        oCaseU.bulkCreateAdminException ( 'OWNER', '', oContact );
        
        // check the list size
        System.AssertEquals ( 1, oCaseU.bulkListSize());
        
        // try a bad type value - should be a silent failure, but list size won't increment
        oCaseU.bulkCreateAdminException ( 'FAIL', '', oContact );
        System.AssertEquals ( 1, oCaseU.bulkListSize());
        
        // try a empty type value - should be a silent failure
        oCaseU.bulkCreateAdminException ( '', '', oContact );
        System.AssertEquals ( 1, oCaseU.bulkListSize());
        
        // try a null type value - should be a silent failure
        oCaseU.bulkCreateAdminException ( null, '', oContact );
        System.AssertEquals ( 1, oCaseU.bulkListSize());
        
        // save the case
        oCaseU.bulkCommitCases();
        
        // look up the new case
        Case oCase = [ SELECT Id, Subject, Code__c FROM Case WHERE ContactId =: oContact.Id ];
        
         // do an assert on the code value
        System.AssertEquals ( 'OWNER', oCase.Code__c );
	}
	
	// Single Case insert method - with DML exception triggering
	public static TestMethod void TestExceptionCase_With_Exceptions () {
		
		// create new contact
        Contact oContact = new Contact ();
        oContact.FirstName = 'Test';
        oContact.LastName = 'Contact Chapter1';
        oContact.Stand_Office__c = 'HI';
        insert oContact;
        
        Test.setReadOnlyApplicationMode( true );
        
        // trigger the case helper
        CaseUtils oCaseU = new CaseUtils ();
        oCaseU.createAdminException ( 'ZIPLOOKUP', 'EXTRA', oContact );
        
        // make sure there are no cases
        List < Case > lCase = new List < Case > ([ SELECT Id, Subject, Code__c, Description FROM Case WHERE ContactId =: oContact.Id ]);
        
        System.AssertEquals ( 0, lCase.size() );
        
        Test.setReadOnlyApplicationMode( false );
	}
	
	// Bulk case creation - with Exception testing
	public static TestMethod void TestBulkCase_With_Exceptions () {
		
		// create new contact
        Contact oContact = new Contact ();
        oContact.FirstName = 'Test';
        oContact.LastName = 'Contact Chapter1';
        oContact.Stand_Office__c = 'HI';
        insert oContact;
        
        // case helper batch mode
        CaseUtils oCaseU = new CaseUtils ();
        
        // EXCEPTION - test ListSize before an init
        System.AssertEquals ( -1, oCaseU.bulkListSize());
        
        
        // do the init so we can continue
        oCaseU.bulkInit();
        oCaseU.bulkCreateAdminException ( 'OWNER', '', oContact );
        
        // check the list size
        System.AssertEquals ( 1, oCaseU.bulkListSize());
        
        // try a bad type value - should be a silent failure, but list size won't increment
        oCaseU.bulkCreateAdminException ( 'FAIL', '', oContact );
        System.AssertEquals ( 1, oCaseU.bulkListSize());
        
        // try a empty type value - should be a silent failure
        oCaseU.bulkCreateAdminException ( '', '', oContact );
        System.AssertEquals ( 1, oCaseU.bulkListSize());
        
        // try a null type value - should be a silent failure
        oCaseU.bulkCreateAdminException ( null, '', oContact );
        System.AssertEquals ( 1, oCaseU.bulkListSize());
        
        // test DML error
        Test.setReadOnlyApplicationMode( true );
        
        // save the case
        oCaseU.bulkCommitCases();
        
        // make sure there are no cases
        List < Case > lCase = new List < Case > ([ SELECT Id, Subject, Code__c, Description FROM Case WHERE ContactId =: oContact.Id ]);
        
        System.AssertEquals ( 0, lCase.size() );
        
        Test.setReadOnlyApplicationMode( false );
	}
}