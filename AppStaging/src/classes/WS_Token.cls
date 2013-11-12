@RestResource(urlMapping='/token/*')

global with sharing class WS_Token { 
	
	global static Integer EXPIRING_PERIOD = 45;
	
	@HttpGet
	
	// token to be passed on the end of the URL
	global static void getMethod () {
		
		string renewal_status;
		string member_state;
		
		//retrieves information on a token
		RestRequest req = RestContext.request;
		string token = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		
		if ( String.isBlank ( token )) {
			// TODO throw exception - no token value
			return;
		}
		
		// PROCESS THE TOKEN
		Token t = new Token();
		Token.TokenValidationData tV = t.validate(EncodingUtil.urlDecode( token, 'UTF-8'));
		
		// make sure that the Token is valid
		if ( String.isBlank ( tV.ObjectID )) {
			// TODO throw exception - no token found
		}
		
		System.debug('============mT.token=================');
		System.debug(token);
		System.debug('============EncodingUtil.urlDecode(mT.token)=====================');
		System.debug(EncodingUtil.urlDecode(token, 'UTF-8'));
		
		// PREPARE RESPONSE
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');

		// load up the member via the TokenValidationData.objectID
		Person per = new Person ();
		if ( per.getByID ( tV.ObjectID ) ) {
			// success
			
			// determine the formType
			// SR = Smart Renew
			// R = Renew
			// MD = Membership Donate
			// membership active = membership expiring in next 45 days
			// membership lapsed = (membership status = lapsed)
			// membership renewed = (membership status = active and not expiring in next 45 days)
			
			if ( per.membership.Membership_Status == 'Lapsed' ) {
				member_state = 'Lapsed';
			} else if ( per.membership.membership_expiration_date >= System.today() && per.membership.membership_expiration_date <= System.today().addDays( EXPIRING_PERIOD ) ) {
				member_state = 'Active';
			} else if ( per.membership.membership_expiration_date >= System.today() && per.membership.membership_expiration_date > System.today().addDays( EXPIRING_PERIOD ) ) {
				member_state = 'Renewed';
			}
			
			// tV is data class for token with these two variables
			// TokenStatus: Valid, Used, Expired, Revoked, ''
			// ObjectID = Membership ID
			
			// token valid, membership active = SR
			if ( tV.TokenStatus == 'Valid' && member_state == 'Active') {
				renewal_status = 'SmartRenew';
			
			// token valid, membership lapsed = SR
			} else if ( tV.TokenStatus == 'Valid' && member_state == 'Lapsed' ) {
				renewal_status = 'SmartRenew';
			
			// token valid, memberhsip renewed = MD
			} else if ( tV.TokenStatus == 'Valid' && member_state == 'Renewed' ) {
				renewal_status = 'MembershipDonate';
				
			// token used, membership active = R
			} else if ( tV.TokenStatus == 'Used' && member_state == 'Active' ) {
				renewal_status = 'Renew';
				
			// token used, membership lapsed = R
			} else if ( tV.TokenStatus == 'Used' && member_state == 'Lapsed' ) {
				renewal_status = 'Renew';
				
			// token used, membership renewed = MD
			} else if ( tV.TokenStatus == 'Used' && member_state == 'Renewed' ) {
				renewal_status = 'MembershipDonate';
			
			// token rev/exp, membership active = R
			} else if ( (tV.TokenStatus == 'Revoked' || tV.TokenStatus == 'Expired') && member_state == 'Active' ) {
				renewal_status = 'Renew';
				
			// token rev/exp, membership lapsed = R
			} else if ( (tV.TokenStatus == 'Revoked' || tV.TokenStatus == 'Expired') && member_state == 'Lapsed' ) {
				renewal_status = 'Renew';
				
			// token rev/exp, membership renewed = R
			} else if ( (tV.TokenStatus == 'Revoked' || tV.TokenStatus == 'Expired') && member_state == 'Renewed' ) {
				renewal_status = 'Renew';
			}
			// return JSON
			
			string jsonResponse = '';
		
			res.statusCode = 200;
			jsonResponse = '{"Token_Status" : "' + tV.TokenStatus + '", "Renewal_Status" : "' + renewal_status + '","Person" : ' + Json.serialize( per ) + '}';
			res.responseBody = blob.valueOf(jsonResponse);
		} else {
			// fail
			// return error
			res.statusCode = 500;
		}
		
		// Process the Email Queue as Clicked
		// get the Token__c object from the validate response
		List <Token__c> tList = new List <Token__c>([SELECT Id FROM Token__c WHERE Id = : tV.TokenId]);

		if ( tList.size() != 1 ) {
			// error, because this shouldn't happen
			// TODO throw exception
		} else {
			// get the EmailQueue object with this TokenId
			List <EmailQueue__c> eList = new List <EmailQueue__c>([SELECT Id FROM EmailQueue__c WHERE Token__c =: tList[0].Id]);

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


		return;
	}
	
	@HttpDelete
	
	// token to be passed on the end of the URL
	global static void deleteMethod () {
		
		//disables a token
		
		RestRequest req = RestContext.request;
		string token = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		
		if ( String.isBlank ( token )) {
			// TODO throw exception - no token value
			return;
		}
		
		// PREPARE RESPONSE
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');
		
		// Process the token revoke
		String decodedToken = EncodingUtil.urlDecode(token, 'UTF-8');
		
		Token t = new Token();
		
		Token.TokenValidationData tV = new Token.TokenValidationData();
		tV = t.validate(EncodingUtil.urlDecode(token, 'UTF-8'));
		
		Boolean revokeResponse = t.revoke(decodedToken, 'Used');

		if ( revokeResponse == false ) {
			// Error condition
			res.statusCode = 500;
			
		} else if ( revokeResponse == true ) {
			// Success Condition
			string jsonResponse = '';
		
			res.statusCode = 200;
			jsonResponse = '{"Token_Status" : "used"}';
			res.responseBody = blob.valueOf(jsonResponse);
		}
		
		return;
		
	}
}