@isTest (seeAllData=true)
private class TokenTest {
	

    static testMethod void CreateValidateRevokeTest() {
        // Test coverage for 'Golden Path' correct behavior
        // create base objects
         
        Date tDate = System.TODAY ();
        
        // ------ Contact 1 -------------
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact Chapter1';
        objContact.Stand_Office__c = 'HI';
        Insert objContact;
        
        // create new membership (Join)
		Membership__c objMember = new Membership__c();
		objMember.Contact__c = objContact.Id;
		objMember.Membership_Action__c = 'Join';
		objMember.Membership_Source__c = 'Web';
		objMember.Membership_State__c = 'HI';
		objMember.Type__c = 'Annual';
		objMember.Gift_Amount__c = 25;	
		Insert objMember;
		
		//set Membership for validating
		Membership__c checkMembership = [SELECT ID, Expiration_Date__c FROM Membership__c WHERE ID =: objMember.ID];
		string membershipID = checkMembership.ID;
		
		//new instance of token
		Token tk = new Token();
		
		Token.TokenCreateData TCD = new Token.TokenCreateData();
		//Call Create and validate results
//		string encryptedKey = tk.create ( membershipID, 'MemRenewLink' );
		TCD = tk.create ( membershipID, 'MemRenewLink' );
		String encryptedKey = TCD.Token;
		
		//set Token for validating
		Token__c checkToken = [SELECT ID, ObjectID__c, Status__c, Key__c FROM Token__c WHERE ObjectID__c =: membershipID];
		
		//Asserts to check for correct token creation
		System.assertequals (checkToken.ObjectID__c, checkMembership.ID);
		System.assertequals (checkToken.Status__c, 'Valid');
		System.assertequals (checkToken.Key__c, checkToken.ID);
		
		//Call Validate Method and validate results
		token.TokenValidationData valID = new token.TokenValidationData ();		
		valID = tk.validate ( encryptedKey );
		//Asserts to check for correct Validation
		System.assertequals(checkMembership.ID, valID.ObjectID);
		System.assertequals(checkToken.Status__c, valID.TokenStatus);
		system.debug('***********************************************TokenStatusafter Validate'+ checkToken.Status__c);
		
		//Call Revoke Method and validate reuslts
		boolean revokeResult = tk.revoke (encryptedKey, 'Used');
		//Assert to check for successfull revoke
		checkToken = [SELECT ID, Status__c, Key__c FROM Token__c WHERE ID =: checkToken.ID];
		System.assertequals(revokeResult, true);
		System.assertequals (checkToken.Status__c, 'Used');
		system.debug('***********************************************TokenStatusafter Revoke'+ checkToken.Status__c);
		
    }
		
	static testMethod void ExpiredUsedRevokedToken() {
        // Test for outcome when Token is expired/Used/or Revoked
        // create base objects
         
        Date tDate = System.TODAY ();
        
        // ------ Contact 1 -------------
        Contact objContact = new Contact();
        objContact.FirstName = 'Test';
        objContact.LastName = 'Contact Chapter1';
        objContact.Stand_Office__c = 'HI';
        Insert objContact;
        
        // create new membership (Join)
		Membership__c objMember = new Membership__c();
		objMember.Contact__c = objContact.Id;
		objMember.Membership_Action__c = 'Join';
		objMember.Membership_Source__c = 'Web';
		objMember.Membership_State__c = 'HI';
		objMember.Type__c = 'Annual';
		objMember.Gift_Amount__c = 25;
		Insert objMember;
		
		//set Membership for validating
		Membership__c checkMembership = [SELECT ID, Expiration_Date__c FROM Membership__c WHERE ID =: objMember.ID];
		string membershipID = checkMembership.ID;
		
		//new instance of token
		Token tk = new Token();
		//Call Create and validate results
		Token.TokenCreateData TCD = new Token.TokenCreateData();
//		string encryptedKey = tk.create ( membershipID, 'MemRenewLink' );
		TCD = tk.create ( membershipID, 'MemRenewLink' );
		String encryptedKey = TCD.Token;
		//set Token for validating
		Token__c checkToken = [SELECT ID, ObjectID__c, Status__c, Key__c FROM Token__c WHERE ObjectID__c =: membershipID];
		
		
		//This section will run through the possible Token status's other than valid and confirm that the correct status is returned
		
		//Update Token to be Expired and check for correct result with validate and revoke
		checkToken.Expiration_Date__c = tDate - 35;
		checkToken.Status__c = 'Expired';
		update checkToken;
		checkToken = [SELECT ID, ObjectID__c, Status__c, Key__c FROM Token__c WHERE ObjectID__c =: membershipID];
		
		//Call Validate Method and validate results (should return ID, and 'Expired')
		token.TokenValidationData valID = new token.TokenValidationData ();		
		valID = tk.validate ( encryptedKey );
		//Asserts to check for correct Validation
		System.assertequals(checkMembership.ID, valID.ObjectID);
		System.assertequals(checkToken.Status__c, valID.TokenStatus);
		//Call Revoke Method and validate results
		boolean revokeResult = tk.revoke (encryptedKey, 'Expired');
		//Assert to check for unsuccessful revoke
		checkToken = [SELECT ID, Status__c, Key__c FROM Token__c WHERE ID =: checkToken.ID];
		System.assertequals(revokeResult, false );
		
		
		
		//Update Token to be Used and check for correct result with validate and revoke
		checkToken.Status__c = 'Used';
		update checkToken;
		//Reset Token for validating
		checkToken = [SELECT ID, ObjectID__c, Status__c, Key__c FROM Token__c WHERE ObjectID__c =: membershipID];
		//Call Validate Method and validate results (should return ID, and 'Used')
		valID = tk.validate ( encryptedKey );
		//Asserts to check for correct Validation
		System.assertequals(checkMembership.ID, valID.ObjectID);
		System.assertequals(checkToken.Status__c, valID.TokenStatus);
		//Call Revoke Method and validate results
		revokeResult = tk.revoke (encryptedKey, 'Used');
		//Assert to check for unsuccessful revoke
		checkToken = [SELECT ID, Status__c, Key__c FROM Token__c WHERE ID =: checkToken.ID];
		System.assertequals(revokeResult, false );
		
		
		
		//Update Token to be Revoked and check for correct result with validate and revoke
		checkToken.Status__c = 'Revoked';
		update checkToken;
		//Reset Token for validating
		checkToken = [SELECT ID, ObjectID__c, Status__c, Key__c FROM Token__c WHERE ObjectID__c =: membershipID];
		//Call Validate Method and validate results (should return ID, and 'Revoked')
		valID = tk.validate ( encryptedKey );
		//Asserts to check for correct Validation
		System.assertequals(checkMembership.ID, valID.ObjectID);
		System.assertequals(checkToken.Status__c, valID.TokenStatus);
		//Call Revoke Method and validate results
		revokeResult = tk.revoke (encryptedKey, 'Revoked');
		//Assert to check for unsuccessful revoke
		checkToken = [SELECT ID, Status__c, Key__c FROM Token__c WHERE ID =: checkToken.ID];
		System.assertequals(revokeResult, false );
		
		
		
		//Update Token to have an invalid status to test behavior when the Status isn't recognized
		checkToken.Status__c = 'badStatus';
		update checkToken;
		//Reset Token for validating
		checkToken = [SELECT ID, ObjectID__c, Status__c, Key__c FROM Token__c WHERE ObjectID__c =: membershipID];
		//Call Validate Method and validate results (should return ID, and '')
		valID = tk.validate ( encryptedKey );
		//Call Revoke Method and validate failed results
		revokeResult = tk.revoke (encryptedKey, 'badStatus');
		//Assert to check for unsuccessful revoke
		checkToken = [SELECT ID, Status__c, Key__c FROM Token__c WHERE ID =: checkToken.ID];
		System.assertequals(revokeResult, false );
	
	}
	static testMethod void FailCreate() {
        // Test for FailedCreate outcome when Object ID is bogus
        
        Date tDate = System.TODAY ();
        //new instance of token
		Token tk = new Token();
		
		//Call Create and validate results
		Token.TokenCreateData TCD = new Token.TokenCreateData();
//		string createResult = tk.create ( 'SomeBadMemID', 'MemRenewLink' );
		TCD = tk.create ( 'SomeBadMemID', 'MemRenewLink' );
		String createResult = TCD.Token;
		System.assertequals(createResult, 'FailedCreate' );
	
    }
    
    	static testMethod void DecryptFail() {
 		// Test for correct behavior when Decryption Fails
 		//**Cannot test for bad Encryption because the Create method, the only one that calls Encrypt
 		//verifies the object ID before Encrypting

         
		//Pass through a bad encrypted key to decrypt
		Token tk = new Token();
		//Call Create with an invalid ID
		string encryptedKey = '123456789123789';
		//New TokenValidationData for Asserts
		token.TokenValidationData valID = new token.TokenValidationData ();	
		valID = tk.validate(encryptedKey);
		//Check that TokenValidationData returns empty when encryptedKey is bad
		System.assertequals('', valID.ObjectID);
		System.assertequals('', valID.TokenStatus);
		
		//Call Create with an apparently good encrypted key that won't return a token in validate
		encryptedKey = 'JmUtekaDEuHcivRsC+6/mVBiWwyg1xIfTpM3crccYgnHM6YliJ89aEdkYIvYHtut';
		//set Token for validating
		valID = tk.validate(encryptedKey);
		//Check that TokenValidationData returns empty when encryptedKey is bad
		System.assertequals('', valID.ObjectID);
		System.assertequals('', valID.TokenStatus);
	
    }
    
    
    static TestMethod void bulkCreateValidateTest() {
    	// ------ Contact 1 -------------
        Contact objContact1 = new Contact();
        objContact1.FirstName = 'TestBulkCreate';
        objContact1.LastName = 'Contact1';
        objContact1.Stand_Office__c = 'OR';
        Insert objContact1;
        
        // create new membership for Contact 1
		Membership__c objMember1 = new Membership__c();
		objMember1.Contact__c = objContact1.Id;
		objMember1.Membership_Action__c = 'Join';
		objMember1.Membership_Source__c = 'Web';
		objMember1.Membership_State__c = 'OR';
		objMember1.Type__c = 'Annual';
		objMember1.Gift_Amount__c = 10;	
		Insert objMember1;

    	// ------ Contact 2 -------------
        Contact objContact2 = new Contact();
        objContact2.FirstName = 'TestBulkCreate';
        objContact2.LastName = 'Contact1';
        objContact2.Stand_Office__c = 'OR';
        Insert objContact2;
        
        // create new membership for Contact 1
		Membership__c objMember2 = new Membership__c();
		objMember2.Contact__c = objContact2.Id;
		objMember2.Membership_Action__c = 'Join';
		objMember2.Membership_Source__c = 'Web';
		objMember2.Membership_State__c = 'OR';
		objMember2.Type__c = 'Annual';
		objMember2.Gift_Amount__c = 10;	
		Insert objMember2;
    	
    	List <String> lObjectID = new List <String>();
    	lObjectID.add(objMember1.Id);
    	lObjectID.add(objMember2.Id);
    	
    	Token t = new Token();
    	
    	// test the bulk create method
//		Map <Id, String> mTokens = new Map <Id, String>();
		Map <Id, Token.TokenCreateData> mTokens = new Map <Id, Token.TokenCreateData>();
		mTokens = t.bulkCreate(lObjectID, 'MemRenewLink');
		
		// test the bulk validate method
		Map <String, Token.TokenValidationData> eMap = new Map <String, Token.TokenValidationData>();
		List <String> lEncryptedKeys = new List <String>();
		Token.TokenCreateData TCD = new Token.TokenCreateData();
		Token.TokenValidationData TVD = new Token.TokenValidationData();
		for (Id mID : mTokens.keySet()) {
			TCD = new Token.TokenCreateData();
//			lEncryptedKeys.add(mTokens.get(mID));
			TCD = mTokens.get(mID);
			lEncryptedKeys.add(TCD.Token);
		}
		eMap = t.bulkValidate(lEncryptedKeys);
		
		// test Used/Expired token
		Token__c t1 = new Token__c();
		t1 = ([SELECT Id FROM Token__c WHERE ObjectID__c =: objMember1.Id]);
		t1.Status__c = 'Used';
		update t1;
		Token__c t2 = new Token__c();
		t2 = ([SELECT Id FROM Token__c WHERE ObjectID__c =: objMember2.Id]);
		t2.Status__c = 'Expired';
		update t2;
		eMap = t.bulkValidate(lEncryptedKeys);
		
		// test Revoked and Blank token
		t1.Status__c = 'Revoked';
		update t1;
		t2.Status__c = '';
		update t2;
		eMap = t.bulkValidate(lEncryptedKeys);

		// test bulkRevoke method
		t1.Status__c = 'Valid';
		update t1;
		t2.Status__c = 'Valid';
		update t2;
		eMap = t.bulkValidate(lEncryptedKeys);
		Map<String,boolean> bulkRevokeResponse = new Map<String,boolean>();
		Map<String,String> bulkRevokeInput = new Map<String,String>();
		// returned map is encrypted key and response
		// input map is encrypted key and reason
		for (String s : lEncryptedKeys) {
			bulkRevokeInput.put(s,'Used');
		}
		bulkRevokeResponse = t.bulkRevoke(bulkRevokeInput);
		Token__c t1Test = [SELECT Id, Status__c FROM Token__c WHERE Id =: t1.Id];
		Token__c t2Test = [SELECT Id, Status__c FROM Token__c WHERE Id =: t2.Id];
		System.AssertEquals(t1Test.Status__c, 'Used');
		System.AssertEquals(t2Test.Status__c, 'Used');
		for (String s : bulkRevokeResponse.keySet()) {
			System.AssertEquals(bulkRevokeResponse.get(s),true);
		}

// example		
//		Map<Id,String> mailContainer = new Map<Id,String>{};
//		for (Id id : mailContainer.keySet()) {
//		    System.debug(id);
//		    System.debug(mailContainer.get(id));
//		}

		
		// test bad decrypt in bulkValidate method
		lEncryptedKeys = new List <String>();
		lEncryptedKeys.add('123456789123789');
		lEncryptedKeys.add('JmUtekaDEuHcivRsC+6/mVBiWwyg1xIfTpM3crccYgnHM6YliJ89aEdkYIvYHtut');
		eMap = new Map <String, Token.TokenValidationData>();
		eMap = t.bulkValidate(lEncryptedKeys);
		
		// call the bulk method with bad ObjectIDs and a different TokenType
		lObjectID = new List <String>();
    	lObjectID.add('12345');
    	lObjectID.add('67890');
//    	mTokens = new Map <Id, String>();
		mTokens = new Map <Id, Token.TokenCreateData>();
		mTokens = t.bulkCreate(lObjectID, 'AnotherType');

    }

}