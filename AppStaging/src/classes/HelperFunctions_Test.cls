@isTest
private class HelperFunctions_Test {

    static testMethod void getPicklistValuesTest() {
        //Create a contact Record so we have an SObject
        // ------ Contact 1 -------------
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact Chapter1';
        objContact.Stand_Office__c = 'AZ';
        Insert objContact;
        
        List < Contact > checkContactList = new List < Contact > ([SELECT ID, Stand_Office__c FROM Contact Where ID =: objContact.ID]);
        
        List < SelectOption > standStates = new List < SelectOption > ();
        HelperFunctions hlp = new HelperFunctions ();
        standStates = hlp.getPicklistValues( checkContactList[0], 'Stand_Office__c');
        system.debug('**************************************************************standStates'+standStates);
        system.debug('**************************************************************firstStateLabel'+standStates[0].getValue());
        
        System.assertequals ( standStates[0].getValue(), 'AZ');
    }
    
    static testMethod void isRecordUpdatableTest () {
    	// insert new contact
    	Contact c0 = new Contact ();
    	c0.firstName = 'Test';
    	c0.LastName = 'LastName';
    	c0.Stand_Office__c = 'AZ';
    	
    	Insert c0;
    	
    	// fetch c1
    	List <Contact> c1 = new List <Contact> ( [ SELECT lastname, SystemModStamp, Version__c FROM Contact WHERE id =: c0.id ] );
    	System.debug ( '========FIRST===========================' + c1[0].SystemModStamp.getTime() + '============' + c1[0].SystemModStamp + '===========' + c1[0].Version__c );
    	
    	// check to see if we can update this record
    	Boolean b = HelperFunctions.isRecordUpdatable ( c1[0].id, 'Contact', c1[0].SystemModStamp );
    	
    	System.assertEquals ( true, b );
    	
    	// now let's go and update the record
    	List <Contact> c2 = new List <Contact> ( [ SELECT lastname, SystemModStamp, Version__c FROM Contact WHERE id =: c0.id ] );
    	c2[0].lastname = 'ThisShouldFail';
    	update c2[0];  // this should have updated the SystemModStamp
    	
    	// retrieve the record to make sure that SystemModStamp was updated
    	List <Contact> c3 = new List <Contact> ( [ SELECT lastname, SystemModStamp, Version__c FROM Contact WHERE id =: c0.id ] );
    	System.debug ( '=========SECOND==========================' + c3[0].SystemModStamp.getTime() + '============' + c3[0].SystemModStamp + '===========' + c3[0].Version__c );
    	
    	// check to see if we can update this record - should be false
    	b = HelperFunctions.isRecordUpdatable ( c1[0].id, 'Contact', c1[0].SystemModStamp );
    	
    	//System.assertEquals ( false, b );
    }
    
     static testMethod void isRecordVersionUpdatableTest () {
    	// insert new contact
    	Contact c0 = new Contact ();
    	c0.firstName = 'Test';
    	c0.LastName = 'LastName';
    	c0.Stand_Office__c = 'AZ';
    	
    	Insert c0;
    	
    	// fetch c1
    	List <Contact> c1 = new List <Contact> ( [ SELECT lastname, SystemModStamp, Version__c FROM Contact WHERE id =: c0.id ] );
    	System.debug ( '========FIRST===========================' + c1[0].SystemModStamp.getTime() + '============' + c1[0].SystemModStamp + '===========' + c1[0].Version__c );
    	
    	// check to see if we can update this record
    	Boolean b = HelperFunctions.isRecordVersionUpdatable ( c1[0].id, 'Contact', c1[0].Version__c );
    	
    	System.assertEquals ( true, b );
    	
    	// now let's go and update the record
    	List <Contact> c2 = new List <Contact> ( [ SELECT lastname, SystemModStamp, Version__c FROM Contact WHERE id =: c0.id ] );
    	c2[0].lastname = 'ThisShouldFail';
    	update c2[0];  // this should have updated the Version__c
    	
    	// retrieve the record to make sure that SystemModStamp was updated
    	List <Contact> c3 = new List <Contact> ( [ SELECT lastname, SystemModStamp, Version__c FROM Contact WHERE id =: c0.id ] );
    	System.debug ( '=========SECOND==========================' + c3[0].SystemModStamp.getTime() + '============' + c3[0].SystemModStamp + '===========' + c3[0].Version__c );
    	
    	// check to see if we can update this record - should be false
    	b = HelperFunctions.isRecordVersionUpdatable ( c1[0].id, 'Contact', c1[0].Version__c );
    	
    	System.assertEquals ( false, b );
    }
     
    static testMethod void isMapUpdateableTest () {
    	// insert new contacts
    	Contact c0 = new Contact ();
    	c0.firstName = 'ThisIsALongTestString';
    	c0.LastName = 'LastName0';
    	c0.Stand_Office__c = 'AZ';
    	
    	Insert c0;
    	
    	Contact c1 = new Contact ();
    	c1.firstName = 'ThisIsALongTestString';
    	c1.LastName = 'LastName1';
    	c1.Stand_Office__c = 'AZ';
    	
    	Insert c1;
    	
    	
    	// fetch c1
    	List <Contact> cl = new List <Contact> ( [ SELECT lastname, SystemModStamp FROM Contact WHERE firstName =: c0.firstName ] );
    	
    	// create an update Map
    	Map < String, DateTime > mp = new Map < String, DateTime > ();
    	for ( Contact c : cl ) {
    		mp.put ( c.id, c.systemModStamp);
    	}
    
    	// check to see if we can update this record
    	Boolean b = HelperFunctions.isMapUpdatable ( mp, 'Contact' );
    	
    	System.assertEquals ( true, b );
    	
    	// now let's go and update a record
    	List <Contact> c2 = new List <Contact> ( [ SELECT lastname, SystemModStamp FROM Contact WHERE id =: c0.id ] );
    	c2[0].lastname = 'ThisShouldFail';
    	update c2[0];
    	
    	// check to see if we can update this record - should be false
    	b = HelperFunctions.isMapUpdatable ( mp, 'Contact' );
    	
    	//System.assertEquals ( false, b );
    }
    
    static testMethod void isMapVersionUpdateableTest () {
    	// insert new contacts
    	Contact c0 = new Contact ();
    	c0.firstName = 'ThisIsALongTestString';
    	c0.LastName = 'LastName0';
    	c0.Stand_Office__c = 'AZ';
    	
    	Insert c0;
    	
    	Contact c1 = new Contact ();
    	c1.firstName = 'ThisIsALongTestString';
    	c1.LastName = 'LastName1';
    	c1.Stand_Office__c = 'AZ';
    	
    	Insert c1;
    	
    	
    	// fetch c1
    	List <Contact> cl = new List <Contact> ( [ SELECT lastname, Version__c FROM Contact WHERE firstName =: c0.firstName ] );
    	
    	// create an update Map
    	Map < String, Decimal > mp = new Map < String, Decimal > ();
    	for ( Contact c : cl ) {
    		mp.put ( c.id, c.Version__c);
    	}
    
    	// check to see if we can update this record
    	Boolean b = HelperFunctions.isMapVersionUpdatable ( mp, 'Contact' );
    	
    	System.assertEquals ( true, b );
    	
    	// now let's go and update a record
    	List <Contact> c2 = new List <Contact> ( [ SELECT lastname, version__c FROM Contact WHERE id =: c0.id ] );
    	c2[0].lastname = 'ThisShouldFail';
    	update c2[0];
    	
    	// check to see if we can update this record - should be false
    	b = HelperFunctions.isMapVersionUpdatable ( mp, 'Contact' );
    	
    	System.assertEquals ( false, b );
    }
    
    static testMethod void isMapVersionUpdateable_EmptySet_Test () {
    	// try to send in multiple invalid IDs which should trigger an immediate false return
    	
    }
    
    static testMethod void isRecordVersionUpdateable_EmptySet_Test () {
    	// try to send in an invalid ID which should trigger an immediate false return
    	
    }
    
    static testMethod void isRecordVersionUpdateableLoadTest () {
    	// do some sort of load test of the version keys
    }
}