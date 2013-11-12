@RestResource(urlMapping='/person/*')

global with sharing class WS_Person {
	
	@HttpGet
	global static void getMethod () {
		
		// handles a GET
		RestRequest req = RestContext.request;
		string contactId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		
		// VALIDATE INPUT
		
		// PREPARE RESPONSE
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');
		
		try {
			Person per = new Person ();
			per.getByID(contactId);
			// success
			// return JSON
			string jsonResponse = '';
			res.statusCode = 200;
			jsonResponse = '{"Person" : ' + Json.serialize( per ) + '}';
			res.responseBody = blob.valueOf(jsonResponse);
		} catch (StandException e) {
			res = HelperFunctions.FormStandExcResponse(e);
		} catch (Exception e ) {
			res = HelperFunctions.FormExcResponse(e);
		} 
	}

	@HttpPut 
	global static void putMethod () {
		
		// Create a new Person record
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
			per.create();
			//success, return JSON
			string jsonResponse = '';
			res.statusCode = 200;
			jsonResponse = '{"Person" : ' + Json.serialize( per ) + '}';
			res.responseBody = blob.valueOf(jsonResponse);
		} catch (StandException e) {
			res = HelperFunctions.FormStandExcResponse(e);
		} catch(Exception e) {
			res = HelperFunctions.FormExcResponse(e);
		}		
	}
	
	
	@HttpPost
	global static void postMethod () {
		//Edit a person record, Demo info only, not membership or leadership info
		
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
			per.edit();
			//success, return JSON
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
	
	
}