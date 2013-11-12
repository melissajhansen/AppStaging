// MP Created 3/19/13
// Class to Create/Validate/Revoke Tokens

public with sharing class Token {
	
	public Token () {
	}

	public class TokenValidationData {
		public string ObjectID;
		public string TokenStatus;
		public string TokenId;			
	}
	
	public class TokenCreateData {
		public string Token;
		public string TokenId;
	}


	// bulkified create method
	// pass in a list of record IDs and the TokenType string
	// note that all records in the input List will have the same TokenType
	// returns a Map with the Id of the record and the encrypted token, or a failed message
	public Map<Id,TokenCreateData> bulkCreate ( List <String> lObjectID, String TokenType ) {
		Date tDate = System.today();
		string encryptedKey;
		List <Membership__c> mList = new List <Membership__c>();
		// map to hold the return values, the objectID and the TokenCreateData
		Map <Id, TokenCreateData> tMap = new Map <Id, TokenCreateData>();
		
		if (TokenType == 'MemRenewLink') {
			// create a list of Memberships from the record IDs
			mList = [SELECT Id FROM Membership__c WHERE Id in : lObjectID];
		} else {
			return tMap;
		}
		
		List <Token__c> tList = new List <Token__c>();
		Token__c oToken = new Token__c ();
		// loop through mList and create tokens
		// add tokens to lTokens
		for ( Membership__c m : mList ) {
			//Create default values based on type
			//SF will generate: Created Date/Created By/ Record Type (default)/ Owner
			oToken = new Token__c ();
			oToken.Type__c = TokenType;
			oToken.Expiration_Date__c = tDate + 30;
			oToken.Status__c = 'Valid';
			oToken.ObjectID__c = m.Id;
			tList.add(oToken);
		}
		
		// insert the tokens
		insert tList;
		
		// loop through the token list and update the token Key__c field
		for ( Token__c t : tList ) {
			//Create the key, just the Token Record ID for now
			t.Key__c = t.ID;
		}
		
		// update the tokens
		update tList;
		
		// loop through the tokens and get the encrypted key
		// create Map to return
		for ( Token__c t : tList ) {
			encryptedKey = encryptKey(t.Key__c);
			if (encryptedKey == 'fail' || encryptedKey == null) {
				TokenCreateData TCD = new TokenCreateData();
				TCD.Token = 'FailedCreate';
				TCD.TokenId = 'FailedCreate';
				tMap.put(t.ObjectID__c, TCD);
			} else {
				TokenCreateData TCD = new TokenCreateData();
				TCD.Token = encryptedKey;
				TCD.TokenId = t.Id;
				tMap.put(t.ObjectID__c, TCD);
			}
		}
		
		return tMap;		
	}
		
	//Method to Create single Token
	public TokenCreateData create (String ObjectID, String TokenType )  {
		TokenCreateData TCD = new TokenCreateData();
		
		Date tDate = System.TODAY ();
		string encryptedKey;		
		
		//Check the Object ID, based detrmining Object based on TokenType, and make sure the ID is valid.
		if (TokenType=='MemRenewLink'){
			try {
				Membership__c m = [SELECT ID FROM Membership__c WHERE ID=: ObjectID];
			} catch (Queryexception e) {
			system.debug('Error' + e);
			TCD.Token = 'FailedCreate';
			TCD.TokenId = 'FailedCreate';
			return TCD;
			}
		}
		
		//Create default values based on type
		//SF will generate: Created Date/Created By/ Record Type (default)/ Owner
		Token__c oToken = new Token__c ();
		oToken.Type__c = TokenType;
		oToken.Expiration_Date__c = tDate + 30;
		oToken.Status__c = 'Valid';
		oToken.ObjectID__c = ObjectID;
		insert oToken;	
		
		//Create the key, just the Token Record ID for now
		oToken.Key__c = oToken.ID;
		update oToken;
		system.debug('*************************************************************' + oToken.Key__c);
		
		//Encrypt the Key, get back Encrypted Key
		encryptedKey = encryptKey(oToken.key__c);	
		system.debug('*************************************************************' + encryptedKey);
		if (encryptedKey == 'fail' || encryptedKey == null) {
			TCD.Token = 'FailedCreate';
			TCD.TokenId = 'FailedCreate';
			return TCD;
		} else {
			TCD.Token = encryptedKey;
			TCD.TokenId = oToken.Id;
			return TCD;
		}

	}
	
	
	// bulkified validate method
	// returned map is encrypted key and TokenValidationData (which is ObjectID and TokenStatus)
	// input list is encrypted keys
	public Map<String,TokenValidationData> bulkValidate ( List <String> lEncryptedKeys ) {
		// map to hold the return values, the encrypted key and the TokenValidationData
		Map <String, TokenValidationData> eMap = new Map <String, TokenValidationData>();
		// map to hold the decrypted key and the encrypted key
		Map <String, String> edKeys = new Map <String, String>();
		
		// list to hold the decrypted keys
		List <String> dKeys = new List <String>();
		
		//Token__c oToken;
		List <Token__c> lTokens = new List <Token__c>();
		string decryptedKey;
		TokenValidationData valD = new TokenValidationData ();
		
		for ( String eKey : lEncryptedKeys ) {
			//Take the encrypted key recieved and attempt to decrypt using decryption method
			//If the decryption fails or returns null, return Failed string
			decryptedKey = this.decryptKey ( eKey );
			system.debug('*************************************************************' + decryptedKey);
			if (decryptedKey == 'fail' || decryptedKey == null) {
				valD = new TokenValidationData ();
				valD.ObjectID = '';
				valD.TokenStatus = '';
				valD.TokenId = '';
				//return valD;
				eMap.put(eKey, valD);
			} else {
				dKeys.add(decryptedKey);
				edKeys.put(decryptedKey, eKey);
			}
		}
		
		//Use the decrypted key to look-up the Tokens being validated  
		lTokens = [SELECT ID, Status__c, Type__c, Key__c, ObjectID__c FROM Token__c WHERE Key__c in : dKeys];
		
		for ( Token__c t : lTokens ) {
			//Check the Token Status and set the appropriate return values  
			//Using the TokenValidationData data class above to set the status and Membership ID to return	
			if (t.Status__c == 'Valid') {
				valD = new TokenValidationData ();
				valD.ObjectID = t.ObjectID__c;
				valD.TokenStatus = 'Valid';
				valD.TokenId = t.Id;
				eMap.put(edKeys.get(t.Key__c), valD);
			} if (t.Status__c == 'Used') {
		    	valD = new TokenValidationData ();
		    	valD.ObjectID = t.ObjectID__c;
				valD.TokenStatus = 'Used';
				valD.TokenId = t.Id;
				eMap.put(edKeys.get(t.Key__c), valD);
			} if (t.Status__c == 'Expired') {
		    	valD = new TokenValidationData ();
		    	valD.ObjectID = t.ObjectID__c;
				valD.TokenStatus = 'Expired';
				valD.TokenId = t.Id;
				eMap.put(edKeys.get(t.Key__c), valD);
			} if (t.Status__c == 'Revoked') {
		    	valD = new TokenValidationData ();
		    	valD.ObjectID = t.ObjectID__c;
				valD.TokenStatus = 'Revoked';
				valD.TokenId = t.Id;
				eMap.put(edKeys.get(t.Key__c), valD);
			} else {
				valD = new TokenValidationData ();
				valD.ObjectID = '';
				valD.TokenStatus = '';
				valD.TokenId = t.Id;
				eMap.put(edKeys.get(t.Key__c), valD);
			}
		}

		return eMap;
	}
	
	
	//  Method to Validate Token
	public TokenValidationData validate ( string encryptedKey)  {
		
		Token__c oToken;
		string decryptedKey;
		TokenValidationData valD = new TokenValidationData ();
		
		//Take the encrypted key recieved and attempt to decrypt using decryption method
		//If the decryption fails or returns null, return Failed string
		decryptedKey = this.decryptKey ( encryptedKey );
		system.debug('*************************************************************' + decryptedKey);
		if (decryptedKey == 'fail' || decryptedKey == null) {
			valD.ObjectID = '';
			valD.TokenStatus = '';
			valD.TokenId = '';
			return valD;
		}
		
		//Use the decrypted key to look-up the Token being validated  
		//Return failed string if the lookup fails
		try {
			oToken = [SELECT ID, Status__c, Type__c, Key__c, ObjectID__c FROM Token__c WHERE Key__c =: decryptedKey];
		} catch (Queryexception e) {
			system.debug('Error' + e);
			valD.ObjectID = '';
			valD.TokenStatus = '';
			valD.TokenId = '';
			return valD;
		}
		
		//Check the Token Status and return the appropriate value.  
		//Using the TokenValidationData data class above to set the status and Membership ID to return	
		if (oToken.Status__c == 'Valid') {
			valD.ObjectID = oToken.ObjectID__c;
			valD.TokenStatus = 'Valid';
			valD.TokenId = oToken.Id;
			return valD;
		} if (oToken.Status__c == 'Used') {
		    valD.ObjectID = oToken.ObjectID__c;
			valD.TokenStatus = 'Used';
			valD.TokenId = oToken.Id;
			return valD;
		} if (oToken.Status__c == 'Expired') {
		    valD.ObjectID = oToken.ObjectID__c;
			valD.TokenStatus = 'Expired';
			valD.TokenId = oToken.Id;
			return valD;
		} if (oToken.Status__c == 'Revoked') {
		    valD.ObjectID = oToken.ObjectID__c;
			valD.TokenStatus = 'Revoked';
			valD.TokenId = oToken.Id;
			return valD;
		} else {
			valD.ObjectID = '';
			valD.TokenStatus = '';
			valD.TokenId = '';
			return valD;
		}
	}
	
	// bulkified Revoke method
	// returned map is encrypted key and response
	// input map is encrypted key and reason
	public Map<String,boolean> bulkRevoke (Map<String,String> mKeys) {
		string decryptedKey;
		Map<String,boolean> revokeResponse = new Map<String,boolean>();

		//Take the encrypted key recieved and attempt to decrypt using decryption method
		//If the decryption fails or returns null, return False			
		//allow handling for Used token and Revoke (not sure yet when this will happen)	
		
		//example
//		Map<Id,String> mailContainer = new Map<Id,String>{};
//		for (Id id : mailContainer.keySet()) {
//		    System.debug(id);
//		    System.debug(mailContainer.get(id));
//		}
		
		// loop through all encrypted keys and get the decrypted keys
		String encryptedKey;
		String keyReason;
		List<String> lDKeys = new List<String>();
		for (String t : mKeys.keySet()) {
			encryptedKey = t;
			
			decryptedKey = this.decryptKey ( encryptedKey );
			if (decryptedKey != 'fail' && decryptedKey != null) {
				lDKeys.add(decryptedKey);
			}
		}

		// create list of tokens from the decrypted keys
		List<Token__c> lTokens = new List<Token__c>([SELECT ID, Status__c, ObjectID__c, Key__c FROM Token__c WHERE Key__c IN: lDKeys]);
		List<Token__c> lTokensToUpdate = new List<Token__c>();
		
		// loop through encrypted keys
		for (String eKey : mKeys.keySet()) {
			encryptedKey = eKey;
			keyReason = mKeys.get(eKey);
			
			decryptedKey = this.decryptKey ( encryptedKey );
			system.debug('*************************************************************' + decryptedKey);
			if (decryptedKey == 'fail' || decryptedKey == null) {
				revokeResponse.put(encryptedKey,false);
			}

			//Use the decrypted key to look-up the Token being revoked  
			//Throw an error if the look-up fails
			//Return False if Look-up Fails
			for (Token__c t : lTokens) {
				if (t.Key__c == decryptedKey) {
					//Change status to Used if the reason given is Used, Only runs if Status is Active to avoid overwriting a Revoked or Expired Status
					//Throw an Error if Update fails
					//TO DO: Once "revoke" protocal is settled on, add handling for setting status to revoked
					if ( keyReason == 'Used' && t.Status__c == 'Valid') {
						try {
							t.Status__c = 'Used';
							lTokensToUpdate.add(t);
							revokeResponse.put(encryptedKey, true);
						} catch (DmlException e) {
							system.debug ('Error' + e);
							revokeResponse.put(encryptedKey, false);
						}
					} else {
						revokeResponse.put(encryptedKey, false);
					}	

					break;
				}
			}
		}
		update lTokensToUpdate;
		return revokeResponse;
	}
		
	
	//  Method to Revoke a single Token when used succesfully
	public boolean revoke (string encryptedKey, string reason) {
	
		Token__c oToken;
		string decryptedKey;
		
		//Take the encrypted key recieved and attempt to decrypt using decryption method
		//If the decryption fails or returns null, return False			
		//allow handling for Used token and Revoke (not sure yet when this will happen)	
		
		decryptedKey = this.decryptKey ( encryptedKey );
		system.debug('*************************************************************' + decryptedKey);
		if (decryptedKey == 'fail' || decryptedKey == null) {
			return false;
		}
		
		//Use the decrypted key to look-up the Token being revoked  
		//Throw an error if the look-up fails
		//Return False if Look-up Fails
		try {
			oToken = [SELECT ID, Status__c, ObjectID__c FROM Token__c WHERE Key__c =: decryptedKey];
		} catch (Queryexception e) {
			system.debug ('Error' + e);
			return false;
		}
		
		//Change status to Used if the reason given is Used, Only runs if Status is Active to avoid overwriting a Revoked or Expired Status
		//Throw an Error if Update fails
		//TO DO: Once "revoke" protocal is settled on, add handling for setting status to revoked
		if ( reason == 'Used' && oToken.Status__c == 'Valid') {
			try {
				oToken.Status__c = 'Used';
				update oToken;
				//Success!
				return true;
								
			} catch (DmlException e) {
				system.debug ('Error' + e);
				return false;
			}
		} else {
			return false;
		}	
	}
		
	//  Encrypt the key
	private string encryptKey (string key) {
		
		//Retrieve the private key from Custom Settings (SET_App_Settings/TOKEN PRIVATE KEY/Value) & convert to Blob
		SET_App_Settings__c sPrivateKey = SET_App_Settings__c.getValues('TOKEN_PRIVATE_KEY');
		string privateKey = sPrivateKey.Value__c;
		Blob privateKeyBlob = Blob.valueOf(privateKey);
		
		//TO DO :  Try to use a different variable name, not data which is reserved word
		try {
			//convert key to be encrypted into a blob
			Blob keyBlob = Blob.valueOf(key);
		
			// Encrypt the data using the built in AES256 algorithm 
			Blob encryptedData = Crypto.encryptWithManagedIV('AES256', privateKeyBlob, keyBlob);	
			
			//Convert blob of encrypted data to a base 64 string
			string encryptedKey = EncodingUtil.base64Encode(encryptedData);
			system.debug('*************************************************************' + encryptedKey);
			
			return encryptedKey;
		} catch (Exception e) {
			system.debug ( 'encryption error' + e);
			return 'fail';
		}
		
	}
	
	// Decrypt the key
	private string decryptKey (string encryptedKey) {
		
		//Retrieve the private key from Custom Settings (SET_App_Settings/TOKEN PRIVATE KEY/Value)and convert to Blob
		SET_App_Settings__c sPrivateKey = SET_App_Settings__c.getValues('TOKEN_PRIVATE_KEY');
		string privateKey = sPrivateKey.Value__c;
		Blob privateKeyBlob = Blob.valueOf(privateKey);
		
		try {
			//Convert the Encrypted Key to a Blob
			Blob keyBlob = EncodingUtil.base64Decode(encryptedKey);
			
			//Take the encrypted key Blob, decrypt
			Blob decryptedData = Crypto.decryptWithManagedIV('AES256', privateKeyBlob, keyBlob);
			// Convert blob to string
			string decryptedKey = decryptedData.toString();
			//Return Decrypted Key
			return decryptedKey;
		} catch (Exception e) {
			return 'fail';
		}
		
	}
	
}