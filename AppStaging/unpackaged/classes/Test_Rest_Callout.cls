public with sharing class Test_Rest_Callout {

	public static void TestPersonGET () {

		String clientID = '3MVG9MHOv_bskkhQ4ibkksTXWmOudLuTUSDQRcBz66gyWcCQg_N_V6hrqk69V3CRDWy96JjAYDW8AMDg0QycH';
		String clientSecret = '8942106032471629115';
		String reqbody = 'grant_type=password&client_id=' + clientId + '&client_secret=' + clientSecret + '&username=developer@stand.org.appstaging&password=12358StandProgrammern5Mtm36lhXzYeTfC9EoMcl09';

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setBody(reqbody);
		req.setMethod('POST');
		req.setEndpoint('https://test.salesforce.com/services/oauth2/token');

		HttpResponse res = h.send(req);
		system.debug('--------response oAuth----------------'+res.getBody());

		JSONParser parser = JSON.createParser(res.getBody());
		String oAuthToken;
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
				// Get the value.
				parser.nextToken();
				oAuthToken = parser.getText();
			}
		}

		system.debug('-----------oAuthToken------------'+oAuthToken);
		
		Http h1 = new Http();
		HttpRequest req1 = new HttpRequest();
		req1.setHeader('Authorization', 'Bearer '+oAuthToken);
		req1.setMethod('GET');
		req1.setEndpoint('https://cs8.salesforce.com/services/apexrest/person/003L000000FHVKi');
		
		HttpResponse res1 = h1.send(req1);
		system.debug('===========-----------=========='+res1.getBody());
	}
	
	// to test the OAuth2.0 login token and insert a single Contact using the PUT method
	public static void TestPersonPUT() {
		
		//-----------------------Setting Credentials-----------------------------------------------------------------
		String clientId = '3MVG9sLbBxQYwWqt0jFs8em2YNsimddh_pzN7QHtTigHvQIT6WdMjJ0lYU7x7yCLpc0SIzL3me7IJgLfhulsA';
		String clientSecret = '5856193165896608108';
		String reqbody = 'grant_type=password&client_id=' + clientId + '&client_secret=' + clientSecret + '&username=developer@stand.org.orgapp&password=12358StandProgrammerzLe9ZXnLmcYZZ4HvprQl7vn5';

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setBody(reqbody);
		req.setMethod('POST');
		req.setEndpoint('https://test.salesforce.com/services/oauth2/token');

		HttpResponse res = h.send(req);
		system.debug('--------response oAuth----------------'+res.getBody());

		
		JSONParser parser = JSON.createParser(res.getBody());
		String oAuthToken;
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
				// Get the value.
				parser.nextToken(); 
				oAuthToken = parser.getText();
			}
		}

		system.debug('-----------oAuthToken------------'+oAuthToken);
		
		//-----------------------PUT -----------------------------------------------------------------
		
		Http h1 = new Http();
		HttpRequest req1 = new HttpRequest();
		req1.setHeader('Authorization', 'Bearer '+oAuthToken);
		req1.setHeader('Content-Type', 'application/json');  
		req1.setMethod('PUT');
		req1.setEndpoint('https://cs7.salesforce.com/services/apexrest/person');
		req1.setBody('{"Person":{"first_name" : "TestInsertPersonPut1024", "last_name" : "TestInsertPersonPut1024", "work_phone" : "5555555555", "personal_email" : "mprcic@stand.org", "is_community_member" : true }}');
		
		HttpResponse res1 = h1.send(req1);
		system.debug('===========-----------=========='+res1.getBody());
		

	}
	
// to test the OAuth2.0 login token and edit a single Contact using the POST method
	public static void TestPersonPOST() {
		
		//-----------------------Setting Credentials-----------------------------------------------------------------
		String clientId = '3MVG9sLbBxQYwWqt0jFs8em2YNsimddh_pzN7QHtTigHvQIT6WdMjJ0lYU7x7yCLpc0SIzL3me7IJgLfhulsA';
		String clientSecret = '5856193165896608108';
		String reqbody = 'grant_type=password&client_id=' + clientId + '&client_secret=' + clientSecret + '&username=developer@stand.org.orgapp&password=12358StandProgrammerzLe9ZXnLmcYZZ4HvprQl7vn5';

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setBody(reqbody);
		req.setMethod('POST');
		req.setEndpoint('https://test.salesforce.com/services/oauth2/token');

		HttpResponse res = h.send(req);
		system.debug('--------response oAuth----------------'+res.getBody());

		
		JSONParser parser = JSON.createParser(res.getBody());
		String oAuthToken;
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
				// Get the value.
				parser.nextToken(); 
				oAuthToken = parser.getText();
			}
		}

		system.debug('-----------oAuthToken------------'+oAuthToken);
		
		//-----------------------POST -----------------------------------------------------------------
		
		Http h1 = new Http();
		HttpRequest req1 = new HttpRequest();
		req1.setHeader('Authorization', 'Bearer '+oAuthToken);
		req1.setHeader('Content-Type', 'application/json');  
		req1.setMethod('POST');
		req1.setEndpoint('https://cs7.salesforce.com/services/apexrest/person');
		req1.setBody('{"Person":{"id" : "003M000000O95rf", "first_name" : "TestUpdatePersonPOST650", "last_name" : "TestUpdatePersonPost0650", "personal_email" : "mprcic@stand.org", "is_community_member" : true }}');
		
		HttpResponse res1 = h1.send(req1);
		system.debug('===========-----------=========='+res1.getBody());
		

	}
	
		// to test the OAuth2.0 login token and insert a single Contact using the PUT method
	public static void TestMembershipPUT() {
		
		//-----------------------Setting Credentials-----------------------------------------------------------------
		String clientId = '3MVG9sLbBxQYwWqt0jFs8em2YNsimddh_pzN7QHtTigHvQIT6WdMjJ0lYU7x7yCLpc0SIzL3me7IJgLfhulsA';
		String clientSecret = '5856193165896608108';
		String reqbody = 'grant_type=password&client_id=' + clientId + '&client_secret=' + clientSecret + '&username=developer@stand.org.orgapp&password=12358StandProgrammerzLe9ZXnLmcYZZ4HvprQl7vn5';

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setBody(reqbody);
		req.setMethod('POST');
		req.setEndpoint('https://test.salesforce.com/services/oauth2/token');

		HttpResponse res = h.send(req);
		system.debug('--------response oAuth----------------'+res.getBody());

		
		JSONParser parser = JSON.createParser(res.getBody());
		String oAuthToken;
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
				// Get the value.
				parser.nextToken(); 
				oAuthToken = parser.getText();
			}
		}

		system.debug('-----------oAuthToken------------'+oAuthToken);
		
		//-----------------------PUT -----------------------------------------------------------------
		
		Http h1 = new Http();
		HttpRequest req1 = new HttpRequest();
		req1.setHeader('Authorization', 'Bearer '+oAuthToken);
		req1.setHeader('Content-Type', 'application/json');  
		req1.setMethod('PUT');
		req1.setEndpoint('https://cs7.salesforce.com/services/apexrest/membership');
		req1.setBody('{"Person":{"id" : "003M000000O95rf", "first_name" : "TestUpdatePersonPOST650", "last_name" : "TestUpdatePersonPOST650", "personal_email" : "mprcic@stand.org", "is_community_member" : true, "Membership" : {"membership_start_date" : "2013-09-24", "membership_type" : "Annual", "team_id" : "001M000000SUlhYIAT" }}}');
		
		HttpResponse res1 = h1.send(req1);
		system.debug('===========-----------=========='+res1.getBody());
		
	}
	
	public static void TestMembershipPOST() {
		
		//-----------------------Setting Credentials-----------------------------------------------------------------
		String clientId = '3MVG9sLbBxQYwWqt0jFs8em2YNsimddh_pzN7QHtTigHvQIT6WdMjJ0lYU7x7yCLpc0SIzL3me7IJgLfhulsA';
		String clientSecret = '5856193165896608108';
		String reqbody = 'grant_type=password&client_id=' + clientId + '&client_secret=' + clientSecret + '&username=developer@stand.org.orgapp&password=12358StandProgrammerzLe9ZXnLmcYZZ4HvprQl7vn5';

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setBody(reqbody);
		req.setMethod('POST');
		req.setEndpoint('https://test.salesforce.com/services/oauth2/token');

		HttpResponse res = h.send(req);
		system.debug('--------response oAuth----------------'+res.getBody());

		
		JSONParser parser = JSON.createParser(res.getBody());
		String oAuthToken;
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
				// Get the value.
				parser.nextToken(); 
				oAuthToken = parser.getText();
			}
		}

		system.debug('-----------oAuthToken------------'+oAuthToken);
		
		//-----------------------POST -----------------------------------------------------------------
		
		
		Http h1 = new Http();
		HttpRequest req1 = new HttpRequest();
		req1.setHeader('Authorization', 'Bearer '+oAuthToken);
		req1.setHeader('Content-Type', 'application/json');  
		req1.setMethod('POST');
		req1.setEndpoint('https://cs7.salesforce.com/services/apexrest/membership');
		req1.setBody('{"Person":{"id" : "003M000000NLCtG", "first_name" : "Scott", "last_name" : "Christian", "personal_email" : "mprcic@stand.org", "is_community_member" : true, "Membership" : {"person_id" : "003M000000NLCtG", "membership_status" : "Active", "last_membership_renewal_date" : "2013-09-23", "Stand_Team_Affiliation__c" : "001M000000SUlhYIAT", "Membership_Type__c" : "Annual"}}}');
		
		HttpResponse res1 = h1.send(req1);
		system.debug('===========-----------=========='+res1.getBody());
		
	}
	
	public static void TestLeaderGET () {

		String clientID = '3MVG9Gmy2zmPB01pW6I6mDqIKvecP_tvO1Ub3imMjUwdBYX1RN3w9DMDxIa_yvIRyi3yDfPc01ZOsmuURF_rw';
		String clientSecret = '4860039967432360226';
		String reqbody = 'grant_type=password&client_id=' + clientId + '&client_secret=' + clientSecret + '&username=developer@stand.org.orgapp&password=12358StandProgrammerzLe9ZXnLmcYZZ4HvprQl7vn5';

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setBody(reqbody);
		req.setMethod('POST');
		req.setEndpoint('https://test.salesforce.com/services/oauth2/token');

		HttpResponse res = h.send(req);
		system.debug('--------response oAuth----------------'+res.getBody());

		JSONParser parser = JSON.createParser(res.getBody());
		String oAuthToken;
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
				// Get the value.
				parser.nextToken();
				oAuthToken = parser.getText();
			}
		}

		system.debug('-----------oAuthToken------------'+oAuthToken);
		
		Http h1 = new Http();
		HttpRequest req1 = new HttpRequest();
		req1.setHeader('Authorization', 'Bearer '+oAuthToken);
		req1.setMethod('GET');
		req1.setEndpoint('https://cs7.salesforce.com/services/apexrest/leadership/003M000000NLCt5');
		
		HttpResponse res1 = h1.send(req1);
		system.debug('===========-----------=========='+res1.getBody());
	}	

	public static void TestLeaderPUT() {
		
		//-----------------------Setting Credentials-----------------------------------------------------------------
		String clientId = '3MVG9sLbBxQYwWqt0jFs8em2YNsimddh_pzN7QHtTigHvQIT6WdMjJ0lYU7x7yCLpc0SIzL3me7IJgLfhulsA';
		String clientSecret = '5856193165896608108';
		String reqbody = 'grant_type=password&client_id=' + clientId + '&client_secret=' + clientSecret + '&username=developer@stand.org.orgapp&password=12358StandProgrammerzLe9ZXnLmcYZZ4HvprQl7vn5';

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setBody(reqbody);
		req.setMethod('POST');
		req.setEndpoint('https://test.salesforce.com/services/oauth2/token');

		HttpResponse res = h.send(req);
		system.debug('--------response oAuth----------------'+res.getBody());

		
		JSONParser parser = JSON.createParser(res.getBody());
		String oAuthToken;
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
				// Get the value.
				parser.nextToken(); 
				oAuthToken = parser.getText();
			}
		}

		system.debug('-----------oAuthToken------------'+oAuthToken);
		
		//-----------------------PUT -----------------------------------------------------------------
		
		Http h1 = new Http();
		HttpRequest req1 = new HttpRequest();
		req1.setHeader('Authorization', 'Bearer '+oAuthToken);
		req1.setHeader('Content-Type', 'application/json');  
		req1.setMethod('PUT');
		req1.setEndpoint('https://cs7.salesforce.com/services/apexrest/leadership');
		req1.setBody('{"Leader" : {"sortOrder" : "1", "leader":{"id" : "003M000000NLCtG", "first_name" : "Scott ", "last_name" : "Christian", "personal_email" : "mprcic@stand.org", "is_community_member" : true, "Membership" : {"membership_start_date" : "2013-09-24", "membership_type" : "Annual", "team_id" : "001M000000SUlhYIAT" }}}}');
		
		HttpResponse res1 = h1.send(req1);
		system.debug('===========-----------=========='+res1.getBody());
		
	}
	

	// to test the OAuth2.0 login token and edit a single Leader Edit using the POST method
	public static void TestLeaderPOST() {
		
		//-----------------------Setting Credentials-----------------------------------------------------------------
		String clientId = '3MVG9sLbBxQYwWqt0jFs8em2YNsimddh_pzN7QHtTigHvQIT6WdMjJ0lYU7x7yCLpc0SIzL3me7IJgLfhulsA';
		String clientSecret = '5856193165896608108';
		String reqbody = 'grant_type=password&client_id=' + clientId + '&client_secret=' + clientSecret + '&username=developer@stand.org.orgapp&password=12358StandProgrammerzLe9ZXnLmcYZZ4HvprQl7vn5';

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setBody(reqbody);
		req.setMethod('POST');
		req.setEndpoint('https://test.salesforce.com/services/oauth2/token');

		HttpResponse res = h.send(req);
		system.debug('--------response oAuth----------------'+res.getBody());

		
		JSONParser parser = JSON.createParser(res.getBody());
		String oAuthToken;
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
				// Get the value.
				parser.nextToken(); 
				oAuthToken = parser.getText();
			}
		}

		system.debug('-----------oAuthToken------------'+oAuthToken);
		
		//-----------------------POST -----------------------------------------------------------------
		
		Http h1 = new Http();
		HttpRequest req1 = new HttpRequest();
		req1.setHeader('Authorization', 'Bearer '+oAuthToken);
		req1.setHeader('Content-Type', 'application/json');  
		req1.setMethod('POST');
		req1.setEndpoint('https://cs7.salesforce.com/services/apexrest/leadership');
		req1.setBody('{"Leader":{"leader":{"work_phone":null,"work_email":null,"version":1,"sortorder":1,"preferred_phone_type":null,"preferred_language":null,"preferred_email_type":"Personal","personal_email":"mprcic@stand.org","other_involvement_preferences":null,"other_activist_interests":null,"organizer_notes":null,"mobile_phone":null,"membership":{"team_id":"001M000000SUlhYIAT","person_id":"003M000000NLCtDIAX","organizer_id":"003M000000NLCFcIAP","membership_type":"Sustaining","membership_status":"Lapsed","membership_state":"OR","membership_start_date":"2012-05-12","membership_quit_date":null,"lifetime_membership_gift_amount":30.0,"leader_id":null,"last_membership_renewal_date":null,"last_membership_gift_date":"2012-05-12","last_membership_gift_amount":30.0,"average_annual_membership_gift_amount":0.0},"mailing_address_zip":null,"mailing_address_street":null,"mailing_address_state":"OR","mailing_address_city":null,"leadership":{"person_id":"003M000000NLCtDIAX","member_count":0,"lit_stop_date":null,"lit_start_date":"2012-06-30","leader_type":"Leader in Training","leader_stop_date":null,"leader_start_date":null,"lapsing_member_count":0,"lapsed_member_count":0,"active_member_count":0},"last_name":"Man","last_modified_date":"2013-09-23T15:53:57.000Z","is_sms_opted_in":false,"is_parent":false,"is_community_member":false,"involvement_preferences_list":null,"id":"003M000000NLCtDIAX","home_phone":null,"first_name":"Duff","educator_type":null,"educator_status":null,"alternate_email":null,"activist_interests_list":null},"assignedMembers":{"people":[]}}}');
		
		system.debug('===========-----------==========req1'+req1.getBody());
		HttpResponse res1 = h1.send(req1);
		system.debug('===========-----------==========res1'+res1.getBody());
		

	}

	public static void TestTeamGET () {

		String clientID = '3MVG9Gmy2zmPB01pW6I6mDqIKvecP_tvO1Ub3imMjUwdBYX1RN3w9DMDxIa_yvIRyi3yDfPc01ZOsmuURF_rw';
		String clientSecret = '4860039967432360226';
		String reqbody = 'grant_type=password&client_id=' + clientId + '&client_secret=' + clientSecret + '&username=developer@stand.org.orgapp&password=12358StandProgrammerzLe9ZXnLmcYZZ4HvprQl7vn5';

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setBody(reqbody);
		req.setMethod('POST');
		req.setEndpoint('https://test.salesforce.com/services/oauth2/token');

		HttpResponse res = h.send(req);
		system.debug('--------response oAuth----------------'+res.getBody());

		JSONParser parser = JSON.createParser(res.getBody());
		String oAuthToken;
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
				// Get the value.
				parser.nextToken();
				oAuthToken = parser.getText();
			}
		}

		system.debug('-----------oAuthToken------------'+oAuthToken);
		
		Http h1 = new Http();
		HttpRequest req1 = new HttpRequest();
		req1.setHeader('Authorization', 'Bearer '+oAuthToken);
		req1.setMethod('GET');
		req1.setEndpoint('https://cs7.salesforce.com/services/apexrest/team/001M000000S6ltUIAR');
		
		HttpResponse res1 = h1.send(req1);
		system.debug('===========-----------=========='+res1.getBody());
		
	}

	public static void TestOrganizerGET () {

		String clientID = '3MVG9Gmy2zmPB01pW6I6mDqIKvecP_tvO1Ub3imMjUwdBYX1RN3w9DMDxIa_yvIRyi3yDfPc01ZOsmuURF_rw';
		String clientSecret = '4860039967432360226';
		String reqbody = 'grant_type=password&client_id=' + clientId + '&client_secret=' + clientSecret + '&username=developer@stand.org.orgapp&password=12358StandProgrammerzLe9ZXnLmcYZZ4HvprQl7vn5';

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setBody(reqbody);
		req.setMethod('POST');
		req.setEndpoint('https://test.salesforce.com/services/oauth2/token');

		HttpResponse res = h.send(req);
		system.debug('--------response oAuth----------------'+res.getBody());

		
		JSONParser parser = JSON.createParser(res.getBody());
		String oAuthToken;
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
				// Get the value.
				parser.nextToken();
				oAuthToken = parser.getText();
			}
		}

		system.debug('-----------oAuthToken------------'+oAuthToken);
		
		Http h1 = new Http();
		HttpRequest req1 = new HttpRequest();
		req1.setHeader('Authorization', 'Bearer '+oAuthToken);
		req1.setMethod('GET');
		req1.setEndpoint('https://cs7.salesforce.com/services/apexrest/organizer/005M0000004mGr4');
		
		HttpResponse res1 = h1.send(req1);
		system.debug('===========-----------=========='+res1.getBody());
		
	}

}