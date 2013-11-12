global without sharing class HelperFunctions {

	//Get a list of picklist values from an existing object field
	global list < SelectOption > getPicklistValues (SObject obj, String fld) {
		list < SelectOption > options = new list < SelectOption > ();
		//get the object type of the SObject
		Schema.sObjectType objType = obj.getSObjectType();
		// Describe the Sobject using its object type
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
		//Get a map of fields for the SObject
		map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap ();
		//Get the list of picklist values for this field
		list < Schema.PicklistEntry > values= fieldMap.get(fld).getDescribe().getPickListValues();
		//Add these values to the sected option list
		for (Schema.PicklistEntry a : values){
			options.add(new SelectOption(a.getLabel(), a.getValue()));
		}
		return options;
	}
	
	// recordUpdatable & mapUpdatable
	// ------------------------------
	// Determines if a specifc record is updatable based on Last Modified Date of that record
	// If the Last Modified Date (LMD) passed in by the consumer equals the LMD of the stored record
	// then returns TRUE
	// All other error conditions return FALSE
	// ----------------
	// Notes
	// ----------------
	// 8/23/2013 :: Concurrency : this is based on an assumption that LastModifiedDate is a reliable way
	// to determine the "version" of a record - meaning, is this the record that I retrieved earlier?
	// Comparision routines use DateTime which uses seconds as its most granular precision
	// This means that it may be possible to load updates in a way to create false "positives"
	// 9/8/2013 :: Implemented a Version custom field on Contact object with a workflow as a trial
	// Updating a set of methods with logic to check against Version
	//
	// TODO Load test this solution (try to submit a series of transactions sub-second)
	//
	// ----------------
	// EXAMPLE - Version Type
	// ----------------
	/*
		// setup
		string id1 = '003M000000NNDzDIAX';
		string id2 = '003M000000NNEESIA5';
		
		decimal d1 = 2;
		decimal d2 = 3;
		
		Map < String, Decimal > mp = new Map < String, Decimal> ();
		mp.put ( id1, d1 );
		mp.put ( id2, d2 );
		
		// execute bulk method
		// map is in the logical format of ( object id, version )
		boolean b1 = HelperFunctions.isMapVersionUpdatable ( mp, 'Contact' );
		
		// execute single method
		boolean b2 = HelperFunctions.isRecordVersionUpdatable ( id1, 'Contact', d1 );
		
		// review results
		
		system.debug ('-------------------------------' + b1 );
		system.debug ('-------------------------------' + b2 );
	*/
	
	global static boolean isRecordUpdatable ( string target_id, string record_obj_name, DateTime input_system_mod_stamp ) {
		
		DateTime stored_system_mod_stamp;
		long ms_input_mod_stamp = 0;
		long ms_stored_mod_stamp = 0;
		
		// retrieve the stored system modified stamp
		string sql = 'SELECT ID, SystemModStamp FROM ' + record_obj_name + ' WHERE ID = \'' + target_id + '\'';
		system.debug ( sql );
		SObject obj = Database.query ( sql );
		
		if ( obj == null ) {
			// case : no record found
			return false;
		} else {
			// Check out Dynamic APEX - http://wiki.developerforce.com/page/An_Introduction_to_Apex
			stored_system_mod_stamp = (DateTime) obj.get ( 'SystemModStamp' );
			// convert to milliseconds GMT
			ms_stored_mod_stamp = stored_system_mod_stamp.getTime ();
			
			// convert input to milliseconds GMT
			ms_input_mod_stamp = input_system_mod_stamp.getTime ();
			
			// output input values in GMT
			system.debug ('---------------------------DT----' + stored_system_mod_stamp );
			system.debug ('---------------------------DT----' + input_system_mod_stamp );
			system.debug ('---------------------------MS----' + ms_stored_mod_stamp );
			system.debug ('---------------------------MS----' + ms_input_mod_stamp );
			// case : record found, check last_modified_dates
			if ( ms_stored_mod_stamp == ms_input_mod_stamp ) {
				// we have a winner!  matched
				return true;
			} else {
				// not good - don't do the update
				return false;
			}
			
			// TIGHT CODE - I think???
			//return ( ms_stored_mod_stamp == ms_input_mod_stamp );
			
		}
	}
	
	global static boolean isRecordVersionUpdatable ( string target_id, string record_obj_name, Decimal input_last_version) {
		
		// will crash if not Contact object
		Decimal stored_version = 0;
		
		// retrieve the stored system modified stamp
		string sql = 'SELECT ID, Version__c FROM ' + record_obj_name + ' WHERE ID = \'' + target_id + '\'';
		system.debug ( sql );
		SObject obj = Database.query ( sql );
		
		if ( obj == null ) {
			// case : no record found
			return false;
		} else {
			// Check out Dynamic APEX - http://wiki.developerforce.com/page/An_Introduction_to_Apex
			stored_version = (Decimal) obj.get( 'Version__c' );
			
			system.debug ('---------------------------S.V----' + stored_version );
			system.debug ('---------------------------L.V----' + input_last_version );
			// case : record found, compare versions
			if ( stored_version == input_last_version ) {
				// we have a winner!  matched
				return true;
			} else {
				// not good - don't do the update
				return false;
			}
		}
	}
	
	global static boolean isMapUpdatable ( Map < string, DateTime > input_map, string record_obj_name ) {

		string sql;
		
		// TODO validate that map has at least one entry
		
		// NOTE this portion is limited to the length of a SOQL statement
		// which is 20k character limit - with 50K row limit on return
		
		// TODO validate that the map has less than 900 records (theoretical limit ~ 995)
		
		sql = 'SELECT ID, LastModifiedDate FROM ' + record_obj_name + ' WHERE ID in ( ';
		// iterate through the map, building a SQL statement
		for ( string id : input_map.keySet () ) {
			sql = sql + '\'' + id + '\',';
		}
		// trucate last comma
		sql = sql.left ( sql.length () - 1 );
		
		// finish the sql statement off
		sql = sql + ' )';
		
		system.debug ( sql );
		
		// make dynamic SQL call
		SObject[] objs = Database.query ( sql );
		
		// iterate through SQL results
		// checking each last modified date against the input Map
		DateTime stored_last_modified_date;
		DateTime last_modified_date;
		Boolean found_problem = false;
		
		// output the map - DEBUGGING PURPOSES ONLY
		String tmpVal;
		for ( String s : input_map.keySet() ) {
			System.debug ( '-------------------IDS1------------' + s );
			tmpVal = s;
		}
		System.debug ( '-------------------IDS2------------' + input_map.get ( tmpVal ));
		// -- END DEBUG
		
		for ( SObject obj : objs ) {
			
			stored_last_modified_date = (DateTime) obj.get ( 'LastModifiedDate' );
			// note IDs in obj are 18-char, plain ole case insensitive bastards
			last_modified_date = input_map.get ((String) obj.get ( 'ID' ));
			System.debug ( '-------------------IDS3------------' + obj.get ( 'ID' ));
			
			// evaluate dates
			if ( stored_last_modified_date != last_modified_date ) {
				// not good - trigger problem
				found_problem = true;
			}
			
			system.debug ('----------DB-------------------' + stored_last_modified_date );
			system.debug ('----------Client---------------' + last_modified_date );
		}
		
		// evaluate and return results
		if ( found_problem ) {
			return false;
		} else {
			return true;
		}
	}
	
	global static boolean isMapVersionUpdatable ( Map < string, Decimal > input_map, string record_obj_name ) {

		string sql;
		
		// TODO validate that map has at least one entry
		
		// NOTE this portion is limited to the length of a SOQL statement
		// which is 20k character limit - with 50K row limit on return
		
		// TODO validate that the map has less than 900 records (theoretical limit ~ 995)
		
		sql = 'SELECT ID, Version__c FROM ' + record_obj_name + ' WHERE ID in ( ';
		// iterate through the map, building a SQL statement
		for ( string id : input_map.keySet () ) {
			sql = sql + '\'' + id + '\',';
		}
		// trucate last comma
		sql = sql.left ( sql.length () - 1 );
		
		// finish the sql statement off
		sql = sql + ' )';
		
		system.debug ( sql );
		
		// make dynamic SQL call
		SObject[] objs = Database.query ( sql );
		
		// check for empty
		if ( objs == null ) {
			return false;
		}
		
		// iterate through SQL results
		Decimal stored_last_version;
		Decimal last_version;
		Boolean found_problem = false;
		
		// output the map - DEBUGGING PURPOSES ONLY
		String tmpVal;
		for ( String s : input_map.keySet() ) {
			System.debug ( '-------------------IDS1------------' + s );
			tmpVal = s;
		}
		System.debug ( '-------------------IDS2------------' + input_map.get ( tmpVal ));
		// -- END DEBUG
		
		for ( SObject obj : objs ) {
			
			stored_last_version = (Decimal) obj.get ( 'Version__c' );
			// note IDs in obj are 18-char, plain ole case insensitive bastards
			last_version = input_map.get ((String) obj.get ( 'ID' ));
			System.debug ( '-------------------IDS3------------' + obj.get ( 'ID' ));
			
			// evaluate dates
			if ( stored_last_version != last_version ) {
				// not good - trigger problem
				found_problem = true;
			}
			
			system.debug ('----------DB-------------------' + stored_last_version );
			system.debug ('----------Client---------------' + last_version );
		}
		
		// evaluate and return results
		if ( found_problem ) {
			return false;
		} else {
			return true;
		}
	}
	
	Public Static List < string > MultiSelectToList ( string picklistValues) {
    	
    	list < string > picklistValuesList;
    	picklistValuesList = picklistValues.split(';');
    	
    	if (picklistValuesList.size()>=1) {
    		return picklistValuesList;
    	} else return null;
    	
    	
    } 
    
 // hhttp://boards.developerforce.com/t5/Apex-Code-Development/PLEASE-HELP-GUID-UUID-in-Salesforce/td-p/496411

	global static String generateGUID () {

		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
		return guid;
	}
	
	global static integer nullToZero(integer nullInt) {
		//verify that the int has a null value
		if (nullInt == null ) {
			return 0;
		} return nullInt;
		//todo add exception
	}
	
	//The salesforce method interger.valueOf, will return null if a null value is passed in.  This method returns 0 if passed a null value
	global static integer trueIntegerValueOf(decimal decValue) {
		integer returnValue;
		
		if (decValue != null) {
			returnValue = integer.valueOf(decValue);
			return returnValue;
		}
		else return 0;	
		
	}
	
	//Salesforce permits currency (double) fields to be null.  Using this method will return any given currency value, or a 0 if null
	global static double doubleValueOfDecimal(decimal decValue) {
		
		if (decValue != null) {
			return decValue;
		}
		else return 0;	
		
	}
	
	public static String sfdc15To18 (String original15) {
		// This method expects a 15-char valid Salesforce ID, and returns the 18-char equivalent
		
		Map<String,String> lookup5bin = new Map<String,String>();
		String Piece1 = '';
		String Piece2 = '';
		String Piece3 = '';
		
		original15 = original15.substring(0,15);
		
		lookup5bin.put('00000','A');	lookup5bin.put('01000','I'); lookup5bin.put('10000','Q');	lookup5bin.put('11000','Y');
		lookup5bin.put('00001','B');	lookup5bin.put('01001','J'); lookup5bin.put('10001','R');	lookup5bin.put('11001','Z');
		lookup5bin.put('00010','C');	lookup5bin.put('01010','K'); lookup5bin.put('10010','S');	lookup5bin.put('11010','0');
		lookup5bin.put('00011','D');	lookup5bin.put('01011','L'); lookup5bin.put('10011','T');	lookup5bin.put('11011','1');
		lookup5bin.put('00100','E');	lookup5bin.put('01100','M'); lookup5bin.put('10100','U');	lookup5bin.put('11100','2');
		lookup5bin.put('00101','F');	lookup5bin.put('01101','N'); lookup5bin.put('10101','V');	lookup5bin.put('11101','3');
		lookup5bin.put('00110','G');	lookup5bin.put('01110','O'); lookup5bin.put('10110','W');	lookup5bin.put('11110','4');
		lookup5bin.put('00111','H');	lookup5bin.put('01111','P'); lookup5bin.put('10111','X');	lookup5bin.put('11111','5');
		
		Piece1 = sfdc0Or1(original15.substring(4,5)) +
		sfdc0Or1(original15.substring(3,4)) +
		sfdc0Or1(original15.substring(2,3)) +
		sfdc0Or1(original15.substring(1,2)) +
		sfdc0Or1(original15.substring(0,1));
		
		Piece2 = sfdc0Or1(original15.substring(9,10)) +
		sfdc0Or1(original15.substring(8,9)) +
		sfdc0Or1(original15.substring(7,8)) +
		sfdc0Or1(original15.substring(6,7)) +
		sfdc0Or1(original15.substring(5,6));
		
		Piece3 = sfdc0Or1(original15.substring(14,15)) +
		sfdc0Or1(original15.substring(13,14)) +
		sfdc0Or1(original15.substring(12,13)) +
		sfdc0Or1(original15.substring(11,12)) +
		sfdc0Or1(original15.substring(10,11));
		
		system.debug('++++++++++++++++++++++++++++++++++18Char ID is: '+(original15 + lookup5bin.get(Piece1) + lookup5bin.get(Piece2) + lookup5bin.get(Piece3)));
		return (original15 + lookup5bin.get(Piece1) + lookup5bin.get(Piece2) + lookup5bin.get(Piece3));
		
		}

	private static String sfdc0Or1 (String charX) {
		// This method accepts a one-char string and returns '1' if it's between A and Z, otherwise '0'.
		
		if (charX.compareTo('A') >= 0 && charX.compareTo('A') <= 25 && charX.compareTo('Z') >= -25 && charX.compareTo('Z') <= 0) return '1';
		return '0';
	
	}

	public static testMethod void Test15_to_18_a() {
		// For the test methods, I've taken three values where I manually calculated the additional 3 chars expected
	
		String orig1 = '001A0000006Vm9r';
		System.AssertEquals(orig1+'IAC',sfdc15To18(orig1));
		
		String orig2 = '003A0000005QB3A';
		System.AssertEquals(orig2+'IAW',sfdc15To18(orig2));
		
		String orig3 = '003A0000008qb1s';
		System.AssertEquals(orig3+'IAA',sfdc15To18(orig3));
	
	}
	
	// method to calculate the current Year
	global static string YearHelper () {
		Date dCurrent = Date.today ();
		String sYear = String.valueOf ( dCurrent.year () );
		
		return sYear;
	}
	
	//method to help calculate the current Year for Gift Naming purposes
	global static string YearHelper2Digit () {
		Date dCurrent = Date.today ();
		String sYear = String.valueOf ( dCurrent.year () );
		
		return sYear.right ( 2 );
	}

	// Method to create WS Stand Exception Error Rest Responses
	global static RestResponse FormStandExcResponse (StandException e) {
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');
		res.statusCode = 500;
		string jsonResponse ='{"Error" : {"Code" : ' + e.errorCode + ', "Type" : ' + '"Stand Exception", "Message" : ' + '"'+ e.getmessage() + '"' + '}' +'}';
		res.responseBody = blob.valueOf(jsonResponse);
		return res;
	}

	// Method to create Exception Rest Responses
	global static RestResponse FormExcResponse (Exception e) {
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', 'application/json');
		res.statusCode = 500;
		string jsonResponse ='{"Error" : {"Code" : 700, "Type" : ' + '"'+ e.getTypeName() + '"' + ', "Message" : ' + '"'+ e.getmessage() + '"' + '}' +'}';
		res.responseBody = blob.valueOf(jsonResponse);
		return res;
	}
	

	// Method to create WS Error Messages
	// global static string wsError () {

	// }

	// Private Method to manaage state abbreviations in Email system
	global static String abbrevToFullStatev (String abbrev) {
		String fullState = '';
		if (abbrev == 'AL') {
			fullState = 'Alabama';
		} else if (abbrev == 'AK') {
			fullState = 'Alaska';
		} else if (abbrev == 'AZ') {
			fullState = 'Arizona';
		} else if (abbrev == 'AR') {
			fullState = 'Arkansas';
		} else if (abbrev == 'CA') {
			fullState = 'California';
		} else if (abbrev == 'CO') {
			fullState = 'Colorado';
		} else if (abbrev == 'CT') {
			fullState = 'Connecticut';
		} else if (abbrev == 'DE') {
			fullState = 'Delaware';
		} else if (abbrev == 'FL') {
			fullState = 'Florida';
		} else if (abbrev == 'GA') {
			fullState = 'Georgia';
		} else if (abbrev == 'HI') {
			fullState = 'Hawaii';
		} else if (abbrev == 'ID') {
			fullState = 'Idaho';
		} else if (abbrev == 'IL') {
			fullState = 'Illinois';
		} else if (abbrev == 'IN') {
			fullState = 'Indiana';
		} else if (abbrev == 'IA') {
			fullState = 'Iowa';
		} else if (abbrev == 'KS') {
			fullState = 'Kansas';
		} else if (abbrev == 'KY') {
			fullState = 'Kentucky';
		} else if (abbrev == 'LA') {
			fullState = 'Louisiana';
		} else if (abbrev == 'ME') {
			fullState = 'Maine';
		} else if (abbrev == 'MD') {
			fullState = 'Maryland';
		} else if (abbrev == 'MA') {
			fullState = 'Massachusetts';
		} else if (abbrev == 'MI') {
			fullState = 'Michigan';
		} else  if (abbrev == 'MN') {
			fullState = 'Minnesota';
		} else if (abbrev == 'MS') {
			fullState = 'Mississippi';
		} else if (abbrev == 'MO') {
			fullState = 'Missouri';
		} else if (abbrev == 'MT') {
			fullState = 'Montana';
		} else if (abbrev == 'NE') {
			fullState = 'Nebraska';
		} else if (abbrev == 'NV') {
			fullState = 'Nevada';
		} else if (abbrev == 'NH') {
			fullState = 'New Hampshire';
		} else if (abbrev == 'NJ') {
			fullState = 'New Jersey';
		} else if (abbrev == 'NM') {
			fullState = 'New Mexico';
		} else if (abbrev == 'NY') {
			fullState = 'New York';
		} else if (abbrev == 'NC') {
			fullState = 'North Carolina';
		} else if (abbrev == 'ND') {
			fullState = 'North Dakota';
		} else if (abbrev == 'OH') {
			fullState = 'Ohio';
		} else if (abbrev == 'OK') {
			fullState = 'Oklahoma';
		} else if (abbrev == 'OR') {
			fullState = 'Oregon';
		} else if (abbrev == 'PA') {
			fullState = 'Pennsylvania';
		} else if (abbrev == 'RI') {
			fullState = 'Rhode Island';
		} else if (abbrev == 'SC') {
			fullState = 'South Carolina';
		} else if (abbrev == 'SD') {
			fullState = 'South Dakota';
		} else if (abbrev == 'TN') {
			fullState = 'Tennessee';
		} else if (abbrev == 'TX') {
			fullState = 'Texas';
		} else if (abbrev == 'UT') {
			fullState = 'Utah';
		} else if (abbrev == 'VT') {
			fullState = 'Vermont';
		} else if (abbrev == 'VA') {
			fullState = 'Virginia';
		} else if (abbrev == 'WA') {
			fullState = 'Washington';
		} else if (abbrev == 'WV') {
			fullState = 'West Virginia';
		} else if (abbrev == 'WI') {
			fullState = 'Wisconsin';
		} else if (abbrev == 'WY') {
			fullState = 'Wyoming';
		}
		return fullState;
	}
    

}