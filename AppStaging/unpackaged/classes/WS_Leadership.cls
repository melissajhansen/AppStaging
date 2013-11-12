@RestResource(urlMapping='/leadership/*')

global with sharing class WS_Leadership {
	
	@HttpGet
	global static void getMethod () {
		
		//Get Leader Record		
		// handles a GET
		RestRequest req = RestContext.request;
		string contactID = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		
		// VALIDATE INPUT
		
		// PREPARE RESPONSE
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');
			
		Leader ldr = new Leader ();
		try {
			ldr.getByID ( contactId );
			// success
			// return JSON
			string jsonResponse = '';
			res.statusCode = 200;
			jsonResponse = '{"Leader" : ' + Json.serialize( ldr ) + '}';
			res.responseBody = blob.valueOf(jsonResponse);
		} catch (StandException e) {
			res = HelperFunctions.FormStandExcResponse(e);
		} catch (Exception e ) {
			res = HelperFunctions.FormExcResponse(e);
		}
	}
	
	@HttpPut 
	global static void putMethod () {
		
		//Make a Leader
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		
		Blob b = req.requestbody;
		string s = b.toString();
		
		JSONParser parser = JSON.createParser (s);
	
		parser.nextToken();
		parser.nextToken();
		parser.nextToken();
		
		Leader ldr = (Leader)parser.readValueAs(Leader.class);
		try {
			ldr.create();
			// success
			// return JSON
			string jsonResponse = '';
			res.statusCode = 200;
			jsonResponse = '{"Leader" : ' + Json.serialize( ldr ) + '}';
			res.responseBody = blob.valueOf(jsonResponse);
		} catch (StandException e) {
			res = HelperFunctions.FormStandExcResponse(e);
		} catch (Exception e ) {
			res = HelperFunctions.FormExcResponse(e);
		}
		
	}
	
	@HttpPost
	global static void postMethod () {
	
		//Change leader's team
		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;
		
		Blob b = req.requestbody;
		string s = b.toString();
		
		JSONParser parser = JSON.createParser (s);
	
		parser.nextToken();
		parser.nextToken();
		parser.nextToken();
		
		//jsonResponse = 
		system.debug('**************************************'+RestContext.request);
		system.debug('**************************************'+s);
		
		
		Leader ldr = (Leader)parser.readValueAs(Leader.class);
//		system.debug('*********************leader.person.id'+ldr.leader.id);
		try {
			ldr.changeTeam();
			// success
			// return JSON
			string jsonResponse = '';
			res.statusCode = 200;
			jsonResponse = '{"Leader" : ' + Json.serialize( ldr ) + '}';
			res.responseBody = blob.valueOf(jsonResponse);
		} catch (StandException e) {
			res = HelperFunctions.FormStandExcResponse(e);
		} catch (Exception e ) {
			res = HelperFunctions.FormExcResponse(e);
		} 

	}
	
	@HttpDelete 
	global static void deleteMethod () {
		
		//End Leadership, not in scope for App
		
		
	}

}