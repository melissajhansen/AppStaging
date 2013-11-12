@RestResource(urlMapping='/team/*')

global with sharing class WS_Team {
	
	
	@HttpPost
	global static void postMethod () {
		
		// handles a POST
		
	}
	
	@HttpGet
	global static void getMethod () {
		
		// handles a GET
		RestRequest req = RestContext.request;
		string teamId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		
		// VALIDATE INPUT
		
		// PREPARE RESPONSE
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');
		// STUBBED VERSION
		
			
		Team t = new Team ();
		try {
			t.getById ( teamId );
			// success
			// return JSON
			string jsonResponse = '';
			res.statusCode = 200;
			jsonResponse = '{"Team" : ' + Json.serialize( t ) + '}';
			res.responseBody = blob.valueOf(jsonResponse);
		} catch (StandException e) {
			res = HelperFunctions.FormStandExcResponse(e);
		} catch (Exception e ) {
			res = HelperFunctions.FormExcResponse(e);
		} 
		
	}
}