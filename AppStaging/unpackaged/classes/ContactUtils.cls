// --------------------
// ContactUtils.cls
// --------------------
// Purpose: Utility methods for Contacts
// 1/10/13 RLB
// methods for Zip to City and State added: zipToCityState, zip2, zip2Test
// the methods are broken up because the trigger can't call a @future method
// so the callout was moved to zip2, which is set as a @future method

 
public class ContactUtils {

	// set variables for geonames city/state lookup
	public static String cityStateURLGeo1 = 'http://api.geonames.org/postalCodeSearch?postalcode=';
	public static String cityStateURLGeo2 = '&country=US&username=domainstand';
	// set variables for Open Street Map lookup
	//public static String openStreetsURL1 = 'http://nominatim.openstreetmap.org/search?q=';
	public static String openStreetsURL1 = 'http://nominatim.openstreetmap.org/search?';
	public static String openStreetsURL2 = '&format=xml&polygon=1&addressdetails=1';
	// all of these are viable queries
	// http://nominatim.openstreetmap.org/search?q=50+Leverett+Rd,+Shutesbury&format=xml&polygon=1&addressdetails=1
	// http://nominatim.openstreetmap.org/search?q=50 Leverett Rd 01072&format=xml&polygon=1&addressdetails=1
	// http://nominatim.openstreetmap.org/search?q=50 Leverett Rd Shutesbury MA&format=xml&polygon=1&addressdetails=1
	// http://nominatim.openstreetmap.org/search?q=01072&format=xml&polygon=1&addressdetails=1
	

	// this method is called from the Contact Trigger
	// cList is all Contacts that the trigger is running on
	public static void zipToCityState ( List <Contact> cList, List <Contact> cListOld) {
		// loop through cList and create another list with only those Contacts that need to be updated
		List <Contact> cList2 = new List <Contact> ();
		for (Contact c : cList) {
			// if there is a zip and the City or State is blank, add to the new list
			if (c.MailingPostalCode != null && (c.MailingCity == null || c.MailingState == null)) {
				cList2.add(c);
			} else if (c.State_House_District__c == null || c.State_Senate_District__c == null) {
				cList2.add(c);
			} else if ( cListOld != null ) {
				for ( Contact cOld : cListOld ) {
					if (c.Id == cOld.Id) {
						if (c.MailingStreet != cOld.MailingStreet) {
							cList2.add(c);
						}
					}
				}
			}
		}
		
		// loop through all the Contacts in the new list
		for ( Contact c : cList2 ) {
			if ( cListOld != null ) {
				for ( Contact cOld : cListOld ) {
					if (c.Id == cOld.Id) {
						if (c.MailingStreet != cOld.MailingStreet && c.MailingStreet != null) {
							ContactUtils.lookupZipAndDistrict( c.ID, c.MailingPostalCode, true, false );
							//break;
						} else {
							ContactUtils.lookupZipAndDistrict( c.ID, c.MailingPostalCode, false, false );
							//break;
						}
					}
				}
			} else {
				ContactUtils.lookupZipAndDistrict( c.ID, c.MailingPostalCode, true, true );
				//break;
			}
		}
	}
	
	// need @future (callout=true) for making web service calls
	// this makes it asynchronous
	// this method is called from zipToCityState for each contact
	// it looks up the City and State from the Zip
	// and updates those fields on the Contact record if they are null
	
	@future (callout=true)
	public static void lookupZipAndDistrict ( ID cID, String strZip, Boolean streetUpdated, Boolean isInsert ) {
		if (strZip == null || strZip == '00000') {
			return;
		}
		
		// Log__c object for logging all future calls
		// 1 is for Address/Zip to City/State
		// 2 is for Address to District
		// Name (name of record): ID + Datetime
		String logName1;
		String logName2;
		// Id (id of object): Text(100)
		String logId1;
		String logId2;
		// Type (type of object this is in relation to): picklist
		String logType1;
		String logType2;
		
		// Log details: Text Area (Long)
		String logDetails1;
		String logDetails2;
		// Endpoint: Text Area (Long)
		String logEndpoint1;
		String logEndpoint2;
		// Date of Request: Date/Time
		Datetime logDateOfRequest1;
		Datetime logDateOfRequest2;
		// Date of Response: Date/Time
		Datetime logDateOfResponse1;
		Datetime logDateOfResponse2;
		// Elapsed_ms_for_lookup__c: Text
		Long logStartOfRequest1;
		Long logStartOfRequest2;
		Long logEndOfRequest1;
		Long logEndOfRequest2;
		// Result: Text(100)
		String logResult1;
		String logResult2;
		// Fail Code: Text Area (Long)
		String logFailCode1;
		String logFailCode2;
		// Result Message: Text Area (Long)
		String logResultMessage1;
		String logResultMessage2;
		
		
		// lookup the contact
		Contact c = ([SELECT Name, ID, MailingStreet, MailingCity, MailingState, MailingPostalCode, State_Senate_District__c, State_House_District__c FROM Contact WHERE ID =: cID]);
		logName1 = c.Name + ' ZipToCityState';
		logName2 = c.Name + ' AddressToDistrict';
		logId1 = c.Id;
		logId2 = c.Id;
		logType1 = 'Contact';
		logType2 = 'Contact';
		
		//String lookupURL = cityStateURLGeo1 + strZip + cityStateURLGeo2;
		String lookupURL;
		String htmlStreet;
		if (c.MailingStreet != null ) {
//			htmlStreet = c.MailingStreet.replace(' ', '%20');
			// http://nominatim.openstreetmap.org/search?q=1798%20Northeast%20Irving%20St%2097232%20United%20States&format=xml&polygon=1&addressdetails=1
			//lookupURL = openStreetsURL1 + 'q=' + htmlStreet + '%20' + c.MailingPostalCode.left(5) + '%20United%20States%20of%20America' + openStreetsURL2;
			//http://nominatim.openstreetmap.org/search?street=4710 W. Schubert Ave&postalcode=60639&countrycodes=us&format=xml&polygon=1&addressdetails=1
//			lookupURL = openStreetsURL1 + 'street=' + htmlStreet + '&postalcode=' + c.MailingPostalCode.left(5) + '&countrycodes=us' + openStreetsURL2;
			for(String s: c.MailingStreet.split('\r',0)) {
				htmlStreet = s;
				break;
			}
			lookupURL = openStreetsURL1 + 'street=' + EncodingUtil.urlEncode(htmlStreet,'UTF-8') + '&postalcode=' + EncodingUtil.urlEncode(c.MailingPostalCode.left(5),'UTF-8') + '&countrycodes=us' + openStreetsURL2;
		} else {
			//lookupURL = openStreetsURL1 + 'q=' + c.MailingPostalCode + ',United%20States' + openStreetsURL2;
			lookupURL = cityStateURLGeo1 + EncodingUtil.urlEncode(c.MailingPostalCode.left(5),'UTF-8') + cityStateURLGeo2;
		}
//		lookupURL = EncodingUtil.urlEncode(lookupURL1,'UTF-8');
		String res = '';
		logEndpoint1 = lookupURL;
		logDateOfRequest1 = System.now();
		logStartOfRequest1 = System.now().getTime();

		
		// create the request and get the response
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(lookupURL);
		req.setMethod('GET');
		req.setTimeout(120000); // timeout in milliseconds
		
		// if it is a test, don't run the Invoke, since SFDC won't run http requests when it is a test
		// when it is a test, return the predefined string to simulate the request
		// this is so that test coverage can be written to cover this class
		//if (!isApexTest)
		if (Test.isRunningTest() == false)
		{
			HttpResponse res1 = h.send(req);
			res = res1.getBody();
			logDateOfResponse1 = System.now();
			logEndOfRequest1 = System.now().getTime();
			logResultMessage1 = res;
			logDetails1 = 'Status: ' + res1.getStatus() + ', Status Code: ' + String.valueOf(res1.getStatusCode());
		} else {
			if (c.MailingStreet != null ) {
				// for open street maps
				res = '<tag>something</tag><place importance="1" lat=\'42.4686074870505\' lon=\'-72.4282520036429\' display_name=\'Shutesbury\'></lng><city>Shutesbury</city><state>Massachusetts</state>';
				logDateOfResponse1 = System.now();
				logEndOfRequest1 = System.now().getTime();
				logResultMessage1 = res;
			} else {
				// for geonames
				res = '<tag>something</tag><adminCode1>MA</adminCode1><name>Shutesbury</name><lat>42.48197</lat><lng>-72.42134</lng>';		
				logDateOfResponse1 = System.now();
				logEndOfRequest1 = System.now().getTime();
				logResultMessage1 = res;
			}
		}
		
		String resState;
		String resCity;
		String resLat;
		String resLong;
		if (c.MailingStreet != null ) {
			// pull out the State from the XML from open street maps
			Integer startIndexState = res.indexOf('<state>') + 7;
			Integer endIndexState = res.indexOf('</state>');
			if (startIndexState-6 > 0 && endIndexState > 0) {
				resState = res.substring(startIndexState,endIndexState);
			} else {
				logFailCode1 = 'Could not find State in Response.';
			}
			if (resState != null) {
				if (resState.length() > 2) {
					resState = fullStateToAbbrev(resState);
				}
			}
			// pull out the City from the XML from open street maps
			Integer startIndexCity = res.indexOf('<city>') + 6;
			Integer endIndexCity = res.indexOf('</city>');
			if (startIndexCity-7 > 0 && endIndexCity > 0) {
				resCity = res.substring(startIndexCity,endIndexCity);
			} else {
				logFailCode1 = logFailCode1 + ' Could not find City in Response';
			}
		
			// NEW CODE FOR OPENSTATES.ORG DISTRICTS
			// this one uses OpenStates.org
			// it finds the lat and long from the zip to city state lookup
			Integer startIndexLat = res.indexOf('lat=\'') + 5;
			Integer endIndexLat = res.indexOf('\' lon=');
			if (startIndexLat-5 > 0 && endIndexLat > 0) {
				resLat = res.substring(startIndexLat,endIndexLat);
			}
			Integer startIndexLong = res.indexOf('lon=\'') + 5;
			Integer endIndexLong = res.indexOf('\' display_name');
			if (startIndexLong-5 > 0 && endIndexLong > 0) {
				resLong = res.substring(startIndexLong,endIndexLong);
			}
		} else {
			// pull out the State from the XML from geonames
			Integer startIndexState = res.indexOf('<adminCode1>') + 12;
			if (startIndexState-12 > 0) {
				resState = res.substring(startIndexState,startIndexState+2);
			} else {
				logFailCode1 = 'Could not find State in Response.';
			}
			// pull out the City from the XML from geonames
			Integer startIndexCity = res.indexOf('<name>') + 6;
			Integer endIndexCity = res.indexOf('</name>');
			if (startIndexCity-6 > 0 && endIndexCity > 0) {
				resCity = res.substring(startIndexCity,endIndexCity);
			} else {
				logFailCode1 = logFailCode1 + ' Could not find City in Response';
			}

			// this one uses geonames.org
			// it finds the lat and long from the zip to city state lookup
			// DEPRACATED
			// Need to have a Street address + zip to do the district lookup, which uses lat and long
			//Integer startIndexLat = res.indexOf('<lat>') + 5;
			//Integer endIndexLat = res.indexOf('</lat>');
			//if (startIndexLat-5 > 0 && endIndexLat > 0) {
			//	resLat = res.substring(startIndexLat,endIndexLat);
			//}
			//Integer startIndexLong = res.indexOf('<lng>') + 5;
			//Integer endIndexLong = res.indexOf('</lng>');
			//if (startIndexLong-5 > 0 && endIndexLong > 0) {
			//	resLong = res.substring(startIndexLong,endIndexLong);
			//}
		}

		




		// http://openstates.org/api/v1/legislators/geo/?long=-72.42134&lat=42.48197&apikey=f20e07ab829441c980c54c9c7ca115ec
		String districtLookup1 = 'http://openstates.org/api/v1/legislators/geo/?long=';
		String districtLookup2 = '&lat=';
		String districtLookup3 = '&apikey=f20e07ab829441c980c54c9c7ca115ec&fields=last_name,first_name,district,active';
		String districtLookupURL = districtLookup1 + resLong + districtLookup2 + resLat + districtLookup3;
		String resD = '';
		logEndpoint2 = districtLookupURL;
		logDateOfRequest2 = System.now();
		logStartOfRequest2 = System.now().getTime();
		
		// create the request and get the response
		Http hD = new Http();
		HttpRequest reqD = new HttpRequest();
		reqD.setEndpoint(districtLookupURL);
		reqD.setMethod('GET');
		reqD.setTimeout(120000); // timeout in milliseconds
			
		// if it is a test, don't run the Invoke, since SFDC won't run http requests when it is a test
		// when it is a test, return the predefined string to simulate the request
		// this is so that test coverage can be written to cover this class
		if (Test.isRunningTest() == false)
		{
			if (resLong != null && resLat != null) {
				HttpResponse resD1 = h.send(reqD);
				resD = resD1.getBody();
				logDateOfResponse2 = System.now();
				logEndOfRequest2 = System.now().getTime();
				logDetails2 = 'Status: ' + resD1.getStatus() + ', Status Code: ' + String.valueOf(resD1.getStatusCode());
				if (resD != null) {
					logResultMessage2 = resD;
				} else {
					logResultMessage2 = String.valueOf(resD1);
				}
			}
		} else {
			// for geonames
			resD = '[{"first_name": "Stanley", "last_name": "Rosenberg", "district": "Hampshire, Franklin and Worcester", "chamber": "upper", "state": "ma", "active": true, "boundary_id": "sldu/ma-hampshire-franklin-worcester", "id": "MAL000032"}, {"first_name": "Stephen", "last_name": "Kulik", "district": "First Franklin", "chamber": "lower", "state": "ma", "active": true, "boundary_id": "sldl/ma-1st-franklin", "id": "MAL000125"}]';
			logDateOfResponse2 = System.now();
			logEndOfRequest2 = System.now().getTime();
			logResultMessage2 = resD;
		}
		String upperDistrict;
		String lowerDistrict;
		String tempDistrict;
		if (resD != '') {
			JSONParser parser = JSON.createParser(resD);
			//System.debug ('-----------begin----------------------');
			//System.debug (parser.getText());
			while (parser.nextToken() != null) {
				if (parser.getText() == 'district') {
					parser.nextToken();
					tempDistrict = parser.getText();
					//System.debug (parser.getText());
					parser.nextToken();
					//System.debug (parser.getText());
					if (parser.getText() == 'chamber') {
						parser.nextToken();
						//System.debug (parser.getText());
						if (parser.getText() == 'upper') {
							upperDistrict = tempDistrict;
						}
						if (parser.getText() == 'lower') {
							lowerDistrict = tempDistrict;
						}
					}
				}
				//System.debug (parser.getText());
				if (upperDistrict != null && lowerDistrict != null) {
					//break;
				}
			}
			//System.debug ('upper district is: ');
			//System.debug (upperDistrict);
			//System.debug ('lower district is: ');
			//System.debug (lowerDistrict);
			//System.debug ('-----------end------------------------');
		}
		if (upperDistrict == null && lowerDistrict == null) {
			logFailCode2 = 'Could not find Districts in Response.';
		}
		
		
		// update the record
		Boolean updateRecordDistrict = false;
		if (upperDistrict != null || lowerDistrict != null || streetUpdated == true) {
			if ((streetUpdated == true && upperDistrict != null) || (c.State_Senate_District__c == null && c.State_Senate_District__c != upperDistrict)) {
				c.State_Senate_District__c = upperDistrict;
				c.District_Data_Last_Updated_On__c = Date.Today();
				updateRecordDistrict = true;
			}
			if ((streetUpdated == true && upperDistrict != null) || (c.State_House_District__c == null && c.State_House_District__c != lowerDistrict)) {
				c.State_House_District__c = lowerDistrict;
				c.District_Data_Last_Updated_On__c = Date.Today();
				updateRecordDistrict = true;
			}
		}
		// END NEW CODE FOR OPENSTATES.ORG DISTRICT

		Boolean updateRecordCityState = false;
		if (resState != null || resCity != null) {
			// if the City is null, update the City
			if ( c.MailingCity == null && c.MailingCity != resCity && resCity != null ) {
				c.MailingCity = resCity;
				updateRecordCityState = true;
			}
			// if the State is null, update the State
			if ( c.MailingState == null && c.MailingState != resState && resState != null ) {
				c.MailingState = resState;
				updateRecordCityState = true;
			}
		}
		
		if ( updateRecordDistrict == true || updateRecordCityState == true ) {
			update c;
		}

		// create the Log for the Zip to City/State
		Log__c l = new Log__c();
		l.Name = logName1;
		l.ID__c = logId1;
		l.Type__c = logType1;
		l.Endpoint__c = logEndpoint1;
		l.Date_Of_Request__c = logDateOfRequest1;
		l.Date_Of_Response__c = logDateOfResponse1;
		if (logEndOfRequest1 > 0 && logStartOfRequest1 > 0) {
			l.Elapsed_ms_for_lookup__c = String.valueOf(logEndOfRequest1-logStartOfRequest1);
		}
		l.Result_Message__c = logResultMessage1;
		if ( updateRecordCityState == true ) {
			logResult1 = 'City and/or State updated';
		} else {
			logResult1 = 'Nothing updated';
		}
		l.Result__c = logResult1;
		l.Fail_Code__c = logFailCode1;
		l.Log_Details__c = logDetails1;
		insert l;

		// create the Log for the Address to District
		Log__c l2 = new Log__c();
		l2.Name = logName2;
		l2.ID__c = logId2;
		l2.Type__c = logType2;
		l2.Endpoint__c = logEndpoint2;
		l2.Date_Of_Request__c = logDateOfRequest2;
		l2.Date_Of_Response__c = logDateOfResponse2;
		if (logEndOfRequest2 > 0 && logStartOfRequest2 > 0) {
			l2.Elapsed_ms_for_lookup__c = String.valueOf(logEndOfRequest2-logStartOfRequest2);
		}
		l2.Result_Message__c = logResultMessage2;
		if ( updateRecordDistrict == true ) {
			logResult2 = 'District updated';
		} else {
			logResult2 = 'Nothing updated';
		}
		l2.Result__c = logResult2;
		l2.Fail_Code__c = logFailCode2;
		l2.Log_Details__c = logDetails2;
		insert l2;
		
		// Section to update Stand Office and Record Owner for New records after they are updated with a Mailing State
		// Incorporated here b/c zip-to-State is Asynchonous and we only want to make this update for new records
		
		//Only making these updates if this is an insert
		if (isInsert == true ){				
			//Create a list containing the Contact being updated
			List < Contact > cList = new List < Contact > ([SELECT ID, Stand_Office__c FROM Contact WHERE ID =: cID]);
			
			//Instantiate a new instance of Contact Utils and call the AddStandOffice Method, followed by the AssignDefaultOwner Method
			ContactUtils cUtil = new ContactUtils ();
			system.debug('************************************SizeofCListPassedtoAddStandOffice'+cList.size());
			cUtil.AddStandOffice ( cList );
			cUtil.AssignDefaultOwnerOnUpdate ( cList );
		}
		
	}
		
	//Method to copy data from fields on Contact Records to corresponding fields on their 1:1 Account Record.
	public void ContactToAccount ( List <Contact> cList, List <Contact> cListOld, Map < ID, Contact > cMapOld, String triggerType) {
		// loop through cList and create another list with only those Contacts that need to be updated

		List < ID > aID = new List < ID > ();
		Boolean addAccount = false;
		Contact oldContact = null;
		
		for ( Contact c : cList ) {
		
			addAccount = false;
		
			if (( c.npe01__Organization_Type__c == 'One-to-One Individual') || ( c.npe01__Organization_Type__c == 'Bucket Individual')) {
				// 8/28/12 - SKT - adding a check to only fire the trigger if we find one of the three
				// fields modified that we're interested in
				//3/4/12 MP - Adding Stand Office as a field check
				if ( triggerType == 'Insert' ) {
					// for inserts, we just need to check to make sure that the data fields that we're
					// interested in have values, ownerID is handled by NPSP
					if (( c.Prospect_Priority__c != null ) || ( c.Prospect_Status__c != null ) || (c.Stand_Office__c != null) || (c.Boards_Involvement__c != null) || (c.Estimated_Capacity__c != null) || (c.Funding_Program_Interests__c != null) || (c.Other_Funding_Interests__c != null) || (c.Philanthropic_Giving_History__c != null) || (c.Political_Giving_History__c != null) || (c.Prospect_Classification__c != null)) {
						// have values in fields that we want to update
						addAccount = true;
					}
				} else if ( triggerType == 'Update' ) {
					// for updates, we need to check against the OldMap
					oldContact = cMapOld.get(c.ID);
					if (( oldContact.Prospect_Priority__c != c.Prospect_Priority__c ) || ( oldContact.Prospect_Status__c != c.Prospect_Status__c ) || ( oldContact.OwnerId != c.OwnerId ) || ( oldContact.Stand_Office__c != c.Stand_Office__c) || (oldContact.Boards_Involvement__c != c.Boards_Involvement__c) || (oldContact.Estimated_Capacity__c != c.Estimated_Capacity__c) || (oldContact.Funding_Program_Interests__c != c.Funding_Program_Interests__c) || (oldContact.Other_Funding_Interests__c != c.Other_Funding_Interests__c) || (oldContact.Philanthropic_Giving_History__c != c.Philanthropic_Giving_History__c) || (oldContact.Political_Giving_History__c != c.Political_Giving_History__c) || (oldContact.Prospect_Classification__c != c.Prospect_Classification__c)) {
						// have a change in values
						addAccount = true;
					}
				}
				
				if ( addAccount ) {
					// add the related account
					aID.add ( c.AccountId );
				}
			}

		}
	
			
		if ( aID.isEmpty() == false ) {
			// traverse through the account list and update account info
			Map < ID, Account > aMap = new Map < ID, Account > ( [ SELECT ID, OwnerId, Prospect_Priority__c, Prospect_Status__c FROM Account WHERE ID IN : aID ] );
			
			// go through the contacts again
			ID accountID;
			Account theAccount;
			
			for ( Contact c : cList ) {
				
				accountID = c.AccountId;
				// search for it in the map and update if it's found
				
				if ( aMap.get ( accountID ) != null ) {
					// Fundraising Rqmt - Update Prospect fields from Contact to Account ( 1-1 Organizations only )
					aMap.get ( accountID ).Prospect_Priority__c = c.Prospect_Priority__c;
					aMap.get ( accountID ).Prospect_Status__c = c.Prospect_Status__c;
					aMap.get ( accountID ).Boards_Involvement__c = c.Boards_Involvement__c;
					aMap.get ( accountID ).Estimated_Capacity__c = c.Estimated_Capacity__c;
					aMap.get ( accountID ).Funding_Program_Interests__c = c.Funding_Program_Interests__c;
					aMap.get ( accountID ).Other_Funding_Interests__c = c.Other_Funding_Interests__c;
					aMap.get ( accountID ).Philanthropic_Giving_History__c = c.Philanthropic_Giving_History__c;
					aMap.get ( accountID ).Political_Giving_History__c = c.Political_Giving_History__c;
					aMap.get ( accountID ).Prospect_Classification__c = c.Prospect_Classification__c;
					
					// Contact ownership - Update Account Owner for 1-1 organizations if contact is updated
					aMap.get ( accountID ).OwnerId = c.OwnerId;
					aMap.get( accountID ).OneToOneContactStandOffice__c = c.Stand_Office__c;
				}
				
			}
			
			// update the accounts
			update aMap.values();
		}
	}
	
	//Method to update the Stand Office of a new Contact Record with the correct Stand Office
	//Based on Mailing State
	
	public void AddStandOffice ( List < Contact> cList) {
		

		//First, get the current list of Stand States  using the HelperFunctions' getPicklistValues method
		//pass in a Contact sObject and the field to get back picklist options
		list < SelectOption > standStates = new List < SelectOption > ();
		HelperFunctions hlp = new HelperFunctions ();
		standStates = hlp.getPicklistValues(cList[0], 'Stand_Office__c' );
		
		//Create a new list of only contacts without a Stand Office and select needed fields
		//If Stand Office is filled in, than Owner was updated immediately on insert and no further updating is needed here
		
		list < Contact > cUpdateList = new list < Contact > ([SELECT ID, Stand_Office__c, MailingState FROM Contact WHERE ID in :cList AND Stand_Office__c =: null]);
		
		//Check to see if Mailing State matches a Stand Office
		//If so, add that state to the Stand Office Multi-Select Picklist	
		for ( Contact c : cUpdateList) {
			for ( SelectOption s : standStates) {
				if (c.MailingState == s.getValue()) {
					c.Stand_Office__c = s.getValue();
				}
			}
			update cUpdateList;
			
		}
	}
	
	//Method to update the Owner of a new Contact Record from the web with the correct Record Owner on Insert
	//Relies on the Default State Owner field on user records.  Each State + National must have one User with that State filled in.
	//NPSP ensures that the 1:1 Account record has the correct owner
	public void AssignDefaultOwnerOnInsert ( List <Contact> cList) {
		
		//system.debug('********************************************sizeOfContactListAtStartOfAssignDefaultOwner'+cList.size());
		
		//Create and assign variable for dacco (Developer Account) user
		List < User > daccoList = new List < User > ([SELECT ID From User WHERE Alias = 'dacco']);
		system.debug('********************************************daccoList'+daccoList);
		User dacco = daccoList[0];
		
		//Create a new list via select to access needed fields
		//list < ID > cIDs = new list < ID > ();
		//for ( Contact c :cList) {
		//	cIDs.add(c.ID);
		//}
		//list < Contact > cUpdateList = new list < Contact > ([SELECT ID, OwnerID, Stand_Office__c FROM Contact WHERE ID in :cIDs]);
		//List of Users who are default owners for their state
		List < User > userList = new List < User > ( [SELECT ID, Default_State_Owner__c FROM User WHERE Default_State_Owner__c != null]);
		//List to hold any contacts where an owner could not be found
		List < Contact > contactOwnerExceptions = new List < Contact >();
		
		//Loop through each contact in the list and find the user who is the default record owner for their state
		for ( Contact c : clist ) {
			for ( User u : userList ) {
				if (c.Stand_Office__c == u.Default_State_Owner__c) {
					c.OwnerID = u.Id;
				}	
			}
		}
	}
	
	
	//Method to update the Owner of a new Contact Record from the web with the correct Record Owner after State is filled in by Contact Utils
	//Functions slightly differently than the method to update before insert
	//Relies on the Default State Owner field on user records.  Each State + National must have one User with that State filled in.
	//NPSP ensures that the 1:1 Account record has the correct owner

	public void AssignDefaultOwnerOnUpdate ( List <Contact> cList) {
		
		//system.debug('********************************************sizeOfContactListAtStartOfAssignDefaultOwner'+cList.size());
		
		//Create and assign variable for dacco (Developer Account) user
		List < User > daccoList = new List < User > ([SELECT ID From User WHERE Alias = 'dacco']);
		system.debug('********************************************daccoList'+daccoList);
		User dacco = daccoList[0];
		
			
		//Create a new list via select to access needed fields
		list < ID > cIDs = new list < ID > ();
		for ( Contact c :cList) {
			cIDs.add(c.ID);
		}
		list < Contact > cUpdateList = new list < Contact > ([SELECT ID, OwnerID, Stand_Office__c FROM Contact WHERE ID in :cIDs]);
		//List of Users who are default owners for their state
		List < User > userList = new List < User > ( [SELECT ID, Default_State_Owner__c FROM User WHERE Default_State_Owner__c != null]);
		//List to hold any contacts where an owner could not be found
		List < Contact > contactOwnerExceptions = new List < Contact >();
		
		//Loop through each contact in the list and find the user who is the default record owner for their state
		for ( Contact c : cUpdateList ) {
			for ( User u : userList ) {
				if (c.Stand_Office__c == u.Default_State_Owner__c) {
					c.OwnerID = u.Id;
				}	
			}
		}
		
		update cUpdateList;
		
	}


/*
		// NEW CODE FOR USGEOCODER.COM DISTRICTS005E0000000ZYTZIA4
		
		// with address:  https://www.usgeocoder.com/api/get_info.php?address=50 Leverett Rd&zipcode=01072&authkey=fe766f32a4d3175b3ab8c9b1c1b9cbd0
		// without address: https://www.usgeocoder.com/api/get_info.php?address=1&zipcode=01072&authkey=fe766f32a4d3175b3ab8c9b1c1b9cbd0		
		String districtLookup1 = 'https://usgeocoder.com/api/get_info.php?address=';
		String districtLookup2 = '&zipcode=';
		String districtLookup3 = '&authkey=fe766f32a4d3175b3ab8c9b1c1b9cbd0';
		
		Contact c1 = ([SELECT ID, MailingStreet, MailingPostalCode, State_House_District__c, State_Senate_District__c FROM Contact WHERE ID =: cID]);
		
		String districtLookupURL;
		if ( c1.MailingStreet != null ) {
			districtLookupURL = districtLookup1 + c1.MailingStreet + districtLookup2 + c1.MailingPostalCode + districtLookup3;
//			districtLookupURL = 'https://usgeocoder.com/api/get_info.php?address=1&zipcode=95131&authkey=fe766f32a4d3175b3ab8c9b1c1b9cbd0';
		} else {
			districtLookupURL = districtLookup1 + '1' + districtLookup2 + c1.MailingPostalCode + districtLookup3;
		}
		String resD = '';
			
		// create the request and get the response
		Http hD = new Http();
		HttpRequest reqD = new HttpRequest();
		reqD.setEndpoint(districtLookupURL);
		reqD.setMethod('GET');
	
		// if it is a test, don't run the Invoke, since SFDC won't run http requests when it is a test
		// when it is a test, return the predefined string to simulate the request
		// this is so that test coverage can be written to cover this class
		if (Test.isRunningTest() == false)
		{
			HttpResponse resD1 = h.send(reqD);
			resD = resD1.getBody();
		} else {
			// for geonames
			resD = '<tag>something</tag><adminCode1>MA</adminCode1><name>Shutesbury</name>';
		}

		System.debug('==============================');
		System.debug(reqD);
		System.debug('==============================');
		System.debug(resD);


		Integer startIndexUpperHouse = resD.indexOf('<state_upper_house_district_name>') + 33;
		Integer endIndexUpperHouse = resD.indexOf('</state_upper_house_district_name>');
		String upperDistrict;
		System.debug('------------------------------------');
		System.debug('startIndexUpperHouse is: ');
		System.debug(startIndexUpperHouse);
		System.debug('endIndexUpperHouse is: ');
		System.debug(endIndexUpperHouse);

		if (startIndexUpperHouse-33 > 0 && endIndexUpperHouse > 0) {
			upperDistrict = resD.substring(startIndexUpperHouse,endIndexUpperHouse);
		}
		Integer startIndexLowerHouse = resD.indexOf('<state_lower_house_district_name>') + 33;
		Integer endIndexLowerHouse = resD.indexOf('</state_lower_house_district_name>');
		String lowerDistrict;
		if (startIndexLowerHouse-33 > 0 && endIndexLowerHouse > 0) {
			lowerDistrict = resD.substring(startIndexLowerHouse,endIndexLowerHouse);
		}
		
		//Boolean resultUpper = upperDistrict.contains('&amp;');
		//if ( resultUpper = true ) {
		//	upperDistrict = upperDistrict.replace('&amp;', '&');
		//}
		//Boolean resultLower = lowerDistrict.contains('&amp;');
		//if ( resultLower = true ) {
		//	lowerDistrict = lowerDistrict.replace('&amp;', '&');
		//}
		
		if (upperDistrict != null || lowerDistrict != null) {
			Boolean updateRecord = false;
			
			// WHAT TO DO IF FIELDS ARE NOT BLANK?
			// WHAT TO DO IF DATA CONFLICTS WITH WHAT IS IN FIELDS?
			if (c1.State_Senate_District__c == null) {
				c1.State_Senate_District__c = upperDistrict;
				updateRecord = true;
			}
			if (c1.State_House_District__c == null) {
				c1.State_House_District__c = lowerDistrict;
				updateRecord = true;
			}
			if (updateRecord == true) {
				update c1;
			}
		}
		// END NEW CODE FOR USGEOCODER.COM DISTRICT
*/
		
	

	public static String fullStateToAbbrev (String fullState) {
		String ab;
		if (fullState == 'Alabama') {
			ab = 'AL';
		} else if (fullState == 'Alaska') {
			ab = 'AK';
		} else if (fullState == 'Arizona') {
			ab = 'AZ';
		} else if (fullState == 'Arkansas') {
			ab = 'AR';
		} else if (fullState == 'California') {
			ab = 'CA';
		} else if (fullState == 'Colorado') {
			ab = 'CO';
		} else if (fullState == 'Connecticut') {
			ab = 'CT';
		} else if (fullState == 'Delaware') {
			ab = 'DE';
		} else if (fullState == 'Florida') {
			ab = 'FL';
		} else if (fullState == 'Georgia') {
			ab = 'GA';
		} else if (fullState == 'Hawaii') {
			ab = 'HI';
		} else if (fullState == 'Idaho') {
			ab = 'ID';
		} else if (fullState == 'Illinois') {
			ab = 'IL';
		} else if (fullState == 'Indiana') {
			ab = 'IN';
		} else if (fullState == 'Iowa') {
			ab = 'IA';
		} else if (fullState == 'Kansas') {
			ab = 'KS';
		} else if (fullState == 'Kentucky') {
			ab = 'KY';
		} else if (fullState == 'Louisiana') {
			ab = 'LA';
		} else if (fullState == 'Maine') {
			ab = 'ME';
		} else if (fullState == 'Maryland') {
			ab = 'MD';
		} else if (fullState == 'Massachusetts') {
			ab = 'MA';
		} else if (fullState == 'Michigan') {
			ab = 'MI';
		} else  if (fullState == 'Minnesota') {
			ab = 'MN';
		} else if (fullState == 'Mississippi') {
			ab = 'MS';
		} else if (fullState == 'Missouri') {
			ab = 'MO';
		} else if (fullState == 'Montana') {
			ab = 'MT';
		} else if (fullState == 'Nebraska') {
			ab = 'NE';
		} else if (fullState == 'Nevada') {
			ab = 'NV';
		} else if (fullState == 'New Hampshire') {
			ab = 'NH';
		} else if (fullState == 'New Jersey') {
			ab = 'NJ';
		} else if (fullState == 'New Mexico') {
			ab = 'NM';
		} else if (fullState == 'New York') {
			ab = 'NY';
		} else if (fullState == 'North Carolina') {
			ab = 'NC';
		} else if (fullState == 'North Dakota') {
			ab = 'ND';
		} else if (fullState == 'Ohio') {
			ab = 'OH';
		} else if (fullState == 'Oklahoma') {
			ab = 'OK';
		} else if (fullState == 'Oregon') {
			ab = 'OR';
		} else if (fullState == 'Pennsylvania') {
			ab = 'PA';
		} else if (fullState == 'Rhode Island') {
			ab = 'RI';
		} else if (fullState == 'South Carolina') {
			ab = 'SC';
		} else if (fullState == 'South Dakota') {
			ab = 'SD';
		} else if (fullState == 'Tennessee') {
			ab = 'TN';
		} else if (fullState == 'Texas') {
			ab = 'TX';
		} else if (fullState == 'Utah') {
			ab = 'UT';
		} else if (fullState == 'Vermont') {
			ab = 'VT';
		} else if (fullState == 'Virginia') {
			ab = 'VA';
		} else if (fullState == 'Washington') {
			ab = 'WA';
		} else if (fullState == 'West Virginia') {
			ab = 'WV';
		} else if (fullState == 'Wisconsin') {
			ab = 'WI';
		} else if (fullState == 'Wyoming') {
			ab = 'WY';
		}
		return ab;
	}






/*	
	// Assigns a Default Owner as specified in the User object
	// to a contact.  
	// See error conditions below for exception handling
	//
	// This method only works for a single contact record (not batch)
	// 
	// Error Conditions:
	// - if no Default Owner is found, no updated is executed and a Task is created logging the error
	// 
	// @param Contact oContact   - object to be updated, method will call a DML update
	//                            at the end of execution to update the Contact record
	// @param string sState - used to designate what State Office this contact
	//                            should be assigned to
	// @param boolean bUpdateContact - 	used to change the mode of this method to be passive 
	//									(will not write the update) or direct (will write the update)
	//									if calling this from a trigger, set value to false
	// @return void
	
	public static void assignDefaultOwner ( Contact oContact, string sState, boolean bUpdateContact ) {
		// check for parameters
		if (( oContact == null ) || ( sState == null ) || ( sState == '' ) || ( bUpdateContact == null )) {
			return;
		}
		
		// find the default state user
		List < User > lUsers = new List < User > ( [ SELECT ID, default_state_contact_owner__c FROM User WHERE default_state_contact_owner__c = : sState ] );
		
		if ( lUsers.size () == 0 ) {
			// error condition, no user was found
			CaseUtils cu = new CaseUtils ();
			cu.createAdminException ( 'OWNER', 'Default state owner not found for state ' + sState, oContact );
		} else {
			// Update the contact with default state contact owner
			try {
				oContact.OwnerId = lUsers[0].Id;
				if ( bUpdateContact ) {
					// method is being called in a way that an update is required
					// if a trigger is calling this method, set bUpdateContact to false
					// since the update will be made by the trigger itself
					update oContact;
				}
			} catch ( Exception e ) {
				CaseUtils cu = new CaseUtils ();
				cu.createAdminException ( 'OWNER', e.getMessage() , oContact );
			}
		}
	} 
*/ 
}