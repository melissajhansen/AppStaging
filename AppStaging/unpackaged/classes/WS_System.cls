@RestResource(urlMapping='/system/*')

global with sharing class WS_System {
	
	
	@HttpGet
	global static void getMethod () {
		
		// handles a GET
		RestRequest req = RestContext.request;
		string action = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		
		// setup output
		RestResponse res = RestContext.response;
		string jsonResponse = '';
		
		// build output
		if ( action == 'recent-items' ) {
			// return a list of recent records
			Search s = new Search ();
			s.recent_items();
				
			// output results
			res.addHeader('Content-Type', 'application/json');
			res.statusCode = 200;
			jsonResponse = '{"results" : ' + Json.serialize( s.results ) + '}';
			res.responseBody = blob.valueOf(jsonResponse);
		}
		
		if ( action == 'picklist-values' ) {
			res.addHeader('Content-Type', 'application/json');
			res.statusCode = 200;
			jsonResponse = '{"results" : "to be implemented" }';
			res.responseBody = blob.valueOf(jsonResponse);
		}
		
		if ( res.statusCode != 200 ) {
			// todo exception, invalid System option
			res.statusCode = 500;
			jsonResponse = '{"error" : "invalid system option - '+ action + '" }';
			res.responseBody = blob.valueOf(jsonResponse);
		}
		
		
	}
}