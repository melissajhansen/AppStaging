// RB updated from original 3/18/13
// this is a class to hold methods for web services needed by stand.org

// tokens from TokenCreateTokens_Rob class
// new urlencoded token:  %2Fz9nUDxooWIHn8OYD29bSnacvkwmRI%2BY1bkHARqgGjjWDTnNH5wzG4IqZasBgke9

global class StandWebService {/*
	
	// variable for test coverage
	global static boolean isApexTest = false;
	
	global static Integer ExpiringPeriod = 45;
	
	// data passed from web to SFDC for Member Renewal Request
	global class MemberRequestInfo {
		webService String token;
	}
	
	// data passed from web to SFDC for Member Complete Request
	global class MemberCompleteInfo {
		webService String token;
	}
	
	// sub data class for holding the Contact info
	// in the format that web wants
	global class MemberContactInfo {
		webService String contactId;
		webService String firstName;
		webService String lastName;
		webService String memState;
		webService Double renewalAmount;
		webService String mailingStreet;
		webService String mailingCity;
		webService String mailingState;
		webService String mailingPostalCode;
		webService String email;
	}
	
	// data for any errors encountered
	global class ErrorData {
		webService String errorStatusCode;
		webService String errorMessage;
	}
	
	// data passed from SFDC to web for Member Renewal Request
	global class MemberRequestInfoResponse {
		// values for renewalStatus
		// Ready for Renew=SmartRenew, Already Renewed=MemberDonate, Other=Renew, Error
		webService String renewalStatus;

		webService ErrorData errorData;

		webService Boolean success;
		webService MemberContactInfo contactData;
	}

	// data passed from SFDC to web for Member Complete Request
	global class MemberCompleteInfoResponse {
		webService ErrorData errorData;

		webService Boolean success;
	}

	
	// web service that receives ContactInfo
	webService static MemberRequestInfoResponse memberRequest(MemberRequestInfo mT) {
		MemberRequestInfoResponse mResponse = new MemberRequestInfoResponse();
		MemberContactInfo mC = new MemberContactInfo();
		ErrorData eData = new ErrorData();
		
		// PROCESS THE TOKEN
		Token t = new Token();
		Token.TokenValidationData tV = new Token.TokenValidationData();
		tV = t.validate(EncodingUtil.urlDecode(mT.token, 'UTF-8'));
//		tV = t.validate(mT.token);
		System.debug('============mT.token=================');
		System.debug(mT.token);
		System.debug('============EncodingUtil.urlDecode(mT.token)=====================');
		System.debug(EncodingUtil.urlDecode(mT.token, 'UTF-8'));

		// FOR NOW, the Request call passes a Membership Id, and returns the appropriate data
		//List <Membership__c> lstMem = new List <Membership__c>([SELECT Id, Contact__r.Id, Contact__r.Name FROM Membership__c WHERE Id = : mT.token]);
		List <Membership__c> lstMem = new List <Membership__c>([SELECT Id, Contact__r.Id, Contact__r.Name FROM Membership__c WHERE Id = : tV.ObjectID]);
		if (lstMem.size() == 0) {
			// handle error when membership is not found
			mC.firstName = '';
			mC.lastName = '';
			mC.memState = '';
			mC.renewalAmount = 0;
			mC.contactId = '';
			mC.mailingStreet = '';
			mC.mailingCity = '';
			mC.mailingState = '';
			mC.mailingPostalCode = '';
			mc.email = '';
			mResponse.contactData = mC;
			eData.errorStatusCode = '';
			eData.errorMessage = 'Unable to find Membership';
			mResponse.errorData = eData;
			mResponse.renewalStatus = 'NO DATA';
			mResponse.success = false;
			
			return mResponse;
		}

		// get the Token__c object from the validate response
		List <Token__c> tList = new List <Token__c>([SELECT Id FROM Token__c WHERE Id = : tV.TokenId]);
//			Token__c t1 = [SELECT Id FROM Token__c WHERE Id = : tV.TokenId];
		if ( tList.size() != 1 ) {
			// error, because this shouldn't happen
		} else {
			// get the EmailQueue object with this TokenId
			List <EmailQueue__c> eList = new List <EmailQueue__c>([SELECT Id FROM EmailQueue__c WHERE Token__c =: tList[0].Id]);
//			EmailQueue__c e = [SELECT Id FROM EmailQueue__c WHERE Token__c =: tList[0].Id];
			if ( eList.size() != 1 ) {
				// error, because this shouldn't happen
			} else {
				for ( EmailQueue__c e : eList ) {
					// update the EmailQueue object and set the DateEmailClicked field to today
					e.DateEmailClicked__c = system.today();
					update e;
				}
			}
		}

		List < Contact > lstContact = new List <Contact>([SELECT Id, FirstName, LastName, Email, npe01__AlternateEmail__c, npe01__HomeEmail__c, npe01__WorkEmail__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, Membership_State__c, Last_Membership_Gift_Amount__c, Membership_Status__c, Membership_Expiration__c FROM Contact WHERE Id = : lstMem[0].Contact__r.Id]);
		
		String membState = '';
		// if there is only one Contact, return the data
		if (lstContact.size() == 1) {
			for (Contact c : lstContact) {
				// determine the formType
				
				// set the data for the response
				mC.firstName = c.FirstName;
				mC.lastName = c.LastName;
				mC.memState = c.Membership_State__c;
				if (c.FirstName == 'MemberRequest' && c.LastName == 'Contact 1') {
					System.debug('=================MemberRequest==================');
					System.debug(c.Last_Membership_Gift_Amount__c);
				}
				if ( c.Last_Membership_Gift_Amount__c == 0 || c.Last_Membership_Gift_Amount__c < 5 ) {
					mC.renewalAmount = 5;
				} else {
					mC.renewalAmount = c.Last_Membership_Gift_Amount__c;
				}
				mC.contactId = c.Id;
				mC.mailingStreet = c.MailingStreet;
				mC.mailingCity = c.MailingCity;
				mC.mailingState = c.MailingState;
				mC.mailingPostalCode = c.MailingPostalCode;
				// Email, npe01__AlternateEmail__c, npe01__HomeEmail__c, npe01__WorkEmail__c
				if ( c.Email == null ) {
					if ( c.npe01__HomeEmail__c == null ) {
						if ( c.npe01__WorkEmail__c == null ) {
							if ( c.npe01__AlternateEmail__c == null ) {
								mC.email = '';
							} else {
								mC.email = c.npe01__AlternateEmail__c;
							}
						} else {
							mC.email = c.npe01__WorkEmail__c;
						}
					} else {
						mC.email = c.npe01__HomeEmail__c;
					}
				} else {
					mC.email = c.Email;
				}
				// SR = Smart Renew
				// R = Renew
				// MD = Membership Donate
				// membership active = membership expiring in next 45 days
				// membership lapsed = (membership status = lapsed)
				// membership renewed = (membership status = active and not expiring in next 45 days)
				
				if ( c.Membership_Status__c == 'Lapsed' ) {
					membState = 'Lapsed';
				} else if ( c.Membership_Expiration__c >= System.today() && c.Membership_Expiration__c <= System.today().addDays(ExpiringPeriod) ) {
					membState = 'Active';
				} else if ( c.Membership_Expiration__c >= System.today() && c.Membership_Expiration__c > System.today().addDays(ExpiringPeriod) ) {
					membState = 'Renewed';
				}
				
				// tV is data class for token with these two variables
				// TokenStatus: Valid, Used, Expired, Revoked, ''
				// ObjectID = Membership ID
				
				// token valid, membership active = SR
				if ( tV.TokenStatus == 'Valid' && membState == 'Active') {
					mResponse.renewalStatus = 'SmartRenew';
				
				// token valid, membership lapsed = SR
				} else if ( tV.TokenStatus == 'Valid' && membState == 'Lapsed' ) {
					mResponse.renewalStatus = 'SmartRenew';
				
				// token valid, memberhsip renewed = MD
				} else if ( tV.TokenStatus == 'Valid' && membState == 'Renewed' ) {
					mResponse.renewalStatus = 'MembershipDonate';
					
				// token used, membership active = R
				} else if ( tV.TokenStatus == 'Used' && membState == 'Active' ) {
					mResponse.renewalStatus = 'Renew';
					
				// token used, membership lapsed = R
				} else if ( tV.TokenStatus == 'Used' && membState == 'Lapsed' ) {
					mResponse.renewalStatus = 'Renew';
					
				// token used, membership renewed = MD
				} else if ( tV.TokenStatus == 'Used' && membState == 'Renewed' ) {
					mResponse.renewalStatus = 'MembershipDonate';
				
//				// token not found, membership active = R
//				} else if ( tV.TokenStatus == '' && membState == 'Active' ) {
//					mResponse.renewalStatus = 'Renew';
				
//				// token not found, membership lapsed = R
//				} else if ( tV.TokenStatus == '' && membState == 'Lapsed' ) {
//					mResponse.renewalStatus = 'Renew';
					
//				// token not found, membership renewed = R
//				} else if ( tV.TokenStatus == '' && membState == 'Renewed' ) {
//					mResponse.renewalStatus = 'Renew';
					
				// token rev/exp, membership active = R
				} else if ( (tV.TokenStatus == 'Revoked' || tV.TokenStatus == 'Expired') && membState == 'Active' ) {
					mResponse.renewalStatus = 'Renew';
					
				// token rev/exp, membership lapsed = R
				} else if ( (tV.TokenStatus == 'Revoked' || tV.TokenStatus == 'Expired') && membState == 'Lapsed' ) {
					mResponse.renewalStatus = 'Renew';
					
				// token rev/exp, membership renewed = R
				} else if ( (tV.TokenStatus == 'Revoked' || tV.TokenStatus == 'Expired') && membState == 'Renewed' ) {
					mResponse.renewalStatus = 'Renew';
				}
				
				mResponse.contactData = mC;
				eData.errorStatusCode = '';
				eData.errorMessage = '';
				mResponse.errorData = eData;
				mResponse.success = true;
			}
		}
		return mResponse;
	}

	webService static MemberRequestInfoResponse memberRequestTest( MemberRequestInfo mT )
	{
		StandWebService.isApexTest = true;
		return memberRequest( mT );
	}

	// web service that receives ContactInfo
	webService static MemberCompleteInfoResponse memberComplete(MemberCompleteInfo mT) {
		MemberCompleteInfoResponse mResponse = new MemberCompleteInfoResponse();
		ErrorData eData = new ErrorData();
		
		String decodedToken = EncodingUtil.urlDecode(mT.token, 'UTF-8');
		
		Token t = new Token();
		
		Token.TokenValidationData tV = new Token.TokenValidationData();
		tV = t.validate(EncodingUtil.urlDecode(mT.token, 'UTF-8'));
		
		Boolean revokeResponse = t.revoke(decodedToken, 'Used');
//		Boolean revokeResponse = t.revoke(mT.token, 'Used');


		if ( revokeResponse == false ) {
			eData.errorStatusCode = '';
			eData.errorMessage = 'Failed to revoke token';
			mResponse.errorData = eData;
			mResponse.success = false;
		} else if ( revokeResponse == true ) {
			eData.errorStatusCode = '';
			eData.errorMessage = '';
			mResponse.errorData = eData;
			mResponse.success = true;

			// get the Token__c object from the validate response
			Token__c t1 = [SELECT Id FROM Token__c WHERE Id = : tV.TokenId];
			// get the EmailQueue object with this TokenId
			EmailQueue__c e = [SELECT Id FROM EmailQueue__c WHERE Token__c = : t1.Id];
//			EmailQueue__c e = [SELECT Id FROM EmailQueue__c WHERE Token__c = : tV.TokenId];
			// update the EmailQueue object and set the DateEmailClicked field to today
			e.DateMembershipRenewed__c = system.today();
			update e;

		}
		return mResponse;
	}

	webService static MemberCompleteInfoResponse memberCompleteTest( MemberCompleteInfo mT )
	{
		StandWebService.isApexTest = true;
		return memberComplete( mT );
	}*/

}