@RestResource(urlMapping='/search/*')

global with sharing class WS_Search {
	
	
	@HttpGet
	global static void getMethod () {
		
		// handles a GET
		RestRequest req = RestContext.request;
		string search_string = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		
		// read parameters
		Map < String, String > params = req.params;
		
		// type
		boolean have_type = false;
		
		if ( params.containsKey ( 'type' )) {
			have_type = true;
		}
		
		// search string
		boolean have_search = false;
		
		if ( params.containsKey ( 'keys' )) {
			have_search = true;
		}
		
		// count
		boolean have_count = false;
		
		if ( params.containsKey ( 'count' )) {
			have_count = true;
		}
		
		// process behaviors
		
		// VALIDATE INPUT
		// TODO: make sure that it's at least 2 chars
		RestResponse res = RestContext.response;
		string jsonResponse = '';
		
		if ( have_type && have_search && have_count ) {
			// PREPARE RESPONSE
			
			res.addHeader('Content-Type', 'application/json');
			
			Search s = new Search ();
			s.find ( params.get( 'keys' ), params.get ( 'type' ), integer.valueof ( params.get ( 'count' )));
				
			// output results
			
			res.statusCode = 200;
			
			jsonResponse = '{"results" : ' + Json.serialize( s.results ) + '}';
			
			res.responseBody = blob.valueOf(jsonResponse);
			
		} else {
			// todo exception, missing a field
			res.statusCode = 500;
			string errStr = '';
			
			if ( have_count ) { errStr += 'count | '; }
			if ( have_type ) { errStr += 'type | '; }
			if ( have_search ) { errStr += 'keys | '; }
				
			jsonResponse = '{"error" : ' + errStr + ' }';
			jsonResponse += Json.serialize ( params );
			jsonResponse += params.size();
			//res.responseBody = blob.valueOf(jsonResponse);
			res.responseBody = req.requestBody;
		}
	}
}