@RestResource(urlMapping='/organizer/*')

global with sharing class WS_Organizer {
	
	
	@HttpPost
	global static void postMethod () {
		
		// handles a POST
		
	}
	
	@HttpGet
	global static void getMethod () {
		
		// handles a GET
		RestRequest req = RestContext.request;
		string userId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		
		// VALIDATE INPUT
		
		// PREPARE RESPONSE
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');
		
		// STUBBED VERSION
		Organizer o = new Organizer ();
		
		try{
			o.getByUserId ( userId );
			// success
			// return JSON
			string json_response = '';
			res.statusCode = 200;
			json_response = '{"Organizer" : ' + Json.serialize ( o ) + '}';
			res.responseBody = blob.valueOf ( json_response );
		} catch (StandException e) {
			res = HelperFunctions.FormStandExcResponse(e);
		} catch (Exception e ) {
			res = HelperFunctions.FormExcResponse(e);
		} 
	}
}