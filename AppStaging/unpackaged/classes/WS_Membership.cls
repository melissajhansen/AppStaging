@RestResource(urlMapping='/membership/*')

global with sharing class WS_Membership {
	
	@HttpGet
	global static void getMethod () {
		
		//needed?  Prob not
		
		
	}
	
	@HttpPut 
	global static void putMethod () {
		//join
		
		//dummy the CC Info
		CCInterface cc = new CCInterface ();
		cc.cardHolderFirstName = 'Tester';
		cc.cardHolderLastName = 'Jones';
		cc.cardHolderNameOnCard = 'Tester Jones';
		cc.cardNumber = '4111111111111111';
		cc.cv2 = '111';
		cc.expirationDate = '09/17';
		cc.ipAddress = '50.1.1.1';
		cc.donationAmount = 50.00;
		cc.campaignName = '';
		
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		
		Blob b = req.requestbody;
		string s = b.toString();
		
		JSONParser parser = JSON.createParser (s);
	
		parser.nextToken();
		parser.nextToken();
		parser.nextToken();
		
		Person per = (Person)parser.readValueAs(Person.class);
		
		try {
			per.Membership.create (per, cc);
			string jsonResponse = '';
			res.statusCode = 200;
			jsonResponse = '{"Person" : ' + Json.serialize( per ) + '}';
			res.responseBody = blob.valueOf(jsonResponse);
		} catch (StandException e) {
			res = HelperFunctions.FormStandExcResponse(e);
		} catch (Exception e) {
			res = HelperFunctions.FormExcResponse(e);
		}
		
	}
	
	
	@HttpPost
	global static void postMethod () {
		//Renewal or Edit
		
		//dummy the CC Info
		CCInterface cc = new CCInterface ();
		cc.cardHolderFirstName = 'Tester';
		cc.cardHolderLastName = 'Jones';
		cc.cardHolderNameOnCard = 'Tester Jones';
		cc.cardNumber = '4111111111111111';
		cc.cv2 = '111';
		cc.expirationDate = '09/17';
		cc.ipAddress = '50.1.1.1';
		cc.donationAmount = 50.00;
		cc.campaignName = '';
 
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		
		Blob b = req.requestbody;
		string s = b.toString();
		
		JSONParser parser = JSON.createParser (s);
	
		parser.nextToken();
		parser.nextToken();
		parser.nextToken();
		
		Person per = (Person)parser.readValueAs(Person.class);
		Contact c = ([SELECT Membership_Status__c, Stand_Team_Affiliation__c, Stand_Leader__c FROM Contact Where id=:per.id]);
		
		//evaluate for changes in membership status, Team & leader
		if (per.membership.membership_status != c.Membership_Status__c ) {
			try {
				per.Membership.renewCC(per, cc);
			} catch (StandException e) {
				res = HelperFunctions.FormStandExcResponse(e);
			} catch (Exception e ) {
				res = HelperFunctions.FormExcResponse(e);
			} 
			
		}
		
		//If the team has changed, call change team which will also update the leader if needed
		if (per.membership.team_id != c.Stand_Team_Affiliation__c) {
			try {
				per.membership.changeTeam(per);
			} catch (StandException e) {
				res = HelperFunctions.FormStandExcResponse(e);
			} catch (Exception e ) {
				res = HelperFunctions.FormExcResponse(e);
			}

		//if only the leader has changed, call changeLeader
		} else if ( per.membership.leader_id != c.Stand_Leader__c ) {
			try {
				per.membership.changeLeader(per);
			} catch (StandException e) {
				res = HelperFunctions.FormStandExcResponse(e);
			} catch (Exception e ) {
				res = HelperFunctions.FormExcResponse(e);
			}
		}
		
		//Finally, return json response
		string jsonResponse = '';
		res.statusCode = 200;
		jsonResponse = '{"Person" : ' + Json.serialize( per ) + '}';
		res.responseBody = blob.valueOf(jsonResponse);
		
	}
	
	
	@HttpDelete 
	global static void deleteMethod () {
		
		//Quit, not in scope for app
		
		
	}

}