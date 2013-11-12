@isTest
private class ContactSearchTest 
{
    public static TestMethod void TestSearchContacts()
    {
        Contact objContact = new Contact();
        Apexpages.StandardController stdController = new Apexpages.StandardController(objContact);
        ContactSearch objContactSearch = new ContactSearch(stdController);
        
        List<selectOption> lstStates = objContactSearch.getStateList;

        System.AssertEquals(objContactSearch.strSortField, 'Name');
        System.AssertEquals(objContactSearch.strSortDirection, 'Asc');
        
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 0);
        
        objContact = new Contact();
        objContact.FirstName = 'TestFirstName1';
        objContact.LastName = 'TestLastName1';
        objContact.MailingCity = 'TestCity1';
        if (lstStates.size() > 1)
            objContact.MailingState = lstStates[1].getLabel();
        objContact.Email = 'testemail1@test.com';
        objContact.Phone = '11111';
        objContact.MailingPostalCode = '121212';
        Insert objContact;
        
        objContactSearch.strFirstName = 'TestFirstName1';
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 1);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'TestFirstName1 TestLastName1');
        
        objContact = new Contact();
        objContact.FirstName = 'TestFirstName1';
        objContact.LastName = 'TestLastName2';
        objContact.MailingCity = 'TestCity2';
        objContact.Phone = '22222';
        objContact.MailingPostalCode = '121212';
        Insert objContact;
        
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 2);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'TestFirstName1 TestLastName1');
        System.AssertEquals(objContactSearch.ContactDisplay[1].strName, 'TestFirstName1 TestLastName2');
        
        objContact = new Contact();
        objContact.FirstName = 'TestFirstName2';
        objContact.LastName = 'TestLastName2';
        objContact.MailingCity = 'TestCity1';
        objContact.Phone = '11111';
        objContact.MailingPostalCode = '343434';
        Insert objContact;
        
        objContactSearch.strLastName = 'TestLastName2';
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 1);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'TestFirstName1 TestLastName2');
        
        objContactSearch.strFirstName = '';
        objContactSearch.strLastName = 'TestLastName2';
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 2);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'TestFirstName1 TestLastName2');
        System.AssertEquals(objContactSearch.ContactDisplay[1].strName, 'TestFirstName2 TestLastName2');
        
        objContactSearch.strFirstName = '';
        objContactSearch.strLastName = '';
        objContactSearch.strCity = 'TestCity1';
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 2);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'TestFirstName1 TestLastName1');
        System.AssertEquals(objContactSearch.ContactDisplay[1].strName, 'TestFirstName2 TestLastName2');
        
        objContactSearch.strFirstName = 'TestFirstName1';
        objContactSearch.strCity = 'TestCity1';
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 1);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'TestFirstName1 TestLastName1');
        
        objContactSearch.strFirstName = '';
        objContactSearch.strCity = '';
        objContactSearch.strState = lstStates[1].getLabel();
        objContactSearch.SetSearchVariables();
// below is original testing code
//        System.AssertEquals(objContactSearch.ContactDisplay.size(), 1);
// below is original testing code
//        System.AssertEquals(objContactSearch.ContactDisplay[0].Name, 'TestFirstName1 TestLastName1');
        
        objContactSearch.strFirstName = 'TestFirstName1';
        objContactSearch.strState = lstStates[1].getLabel();
        objContactSearch.SetSearchVariables();
// below is original testing code
//        System.AssertEquals(objContactSearch.ContactDisplay.size(), 1);
// below is original testing code
//        System.AssertEquals(objContactSearch.ContactDisplay[0].Name, 'TestFirstName1 TestLastName1');
        
        objContactSearch.strFirstName = 'TestFirstName2';
        objContactSearch.strState = lstStates[1].getLabel();
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 0);
        
        objContactSearch.strFirstName = '';
        objContactSearch.strState = '';
        objContactSearch.strEmail = 'testemail1@test.com';
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 1);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'TestFirstName1 TestLastName1');

        objContactSearch.strFirstName = 'TestFirstName1';
        objContactSearch.strEmail = 'testemail1@test.com';
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 1);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'TestFirstName1 TestLastName1');
        
        objContactSearch.strFirstName = '';
        objContactSearch.strEmail = '';
        objContactSearch.strPhone = '11111';
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 2);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'TestFirstName1 TestLastName1');
        System.AssertEquals(objContactSearch.ContactDisplay[1].strName, 'TestFirstName2 TestLastName2');
        
        objContactSearch.strFirstName = 'TestFirstName1';
        objContactSearch.strPhone = '11111';
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 1);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'TestFirstName1 TestLastName1');
        
        objContactSearch.strFirstName = '';
        objContactSearch.strPhone = '';
        objContactSearch.strZip = '121212';
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 2);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'TestFirstName1 TestLastName1');
        System.AssertEquals(objContactSearch.ContactDisplay[1].strName, 'TestFirstName1 TestLastName2');
        
        objContactSearch.strCity = 'TestCity1';
        objContactSearch.strZip = '343434';
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 1);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'TestFirstName2 TestLastName2');
        
        objContact = new Contact();
        objContact.FirstName = 'FirstAffiliation';
        objContact.LastName = 'LastAffiliation';
        objContact.MailingCity = 'CityAffiliation';
        Insert objContact;
        
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.Type = 'Stand State';
        objAccount.Acquired_By__c = 'C3 Acquired';
        Insert objAccount;
        
        npe5__Affiliation__c objAffiliation = new npe5__Affiliation__c();
        objAffiliation.npe5__Contact__c = objContact.Id;
        objAffiliation.npe5__Organization__c = objAccount.Id;
        objAffiliation.npe5__Status__c = 'Active';
        objAffiliation.Affiliation__c = 'State Contact';
        Insert objAffiliation;
        
// added for testing
        objAffiliation = new npe5__Affiliation__c();
        objAffiliation.npe5__Contact__c = objContact.Id;
        objAffiliation.npe5__Organization__c = objAccount.Id;
        objAffiliation.npe5__Status__c = 'Active';
        objAffiliation.Affiliation__c = 'Chapter Contact';
        Insert objAffiliation;

		Membership__c objMember = new Membership__c();
		objMember.Status__c = 'Active';
		objMember.Contact__c = objContact.Id;
		objMember.Type__c = 'Annual';
		objMember.Gift_Amount__c = 10.00;
		objMember.Membership_Source__c = 'Mail';
		Insert objMember;

// added for testing
        objAffiliation = new npe5__Affiliation__c();
        objAffiliation.npe5__Contact__c = objContact.Id;
        objAffiliation.npe5__Organization__c = objAccount.Id;
        objAffiliation.npe5__Status__c = 'Active';
        objAffiliation.Affiliation__c = 'Team Leader';
        Insert objAffiliation;

        objAffiliation = new npe5__Affiliation__c();
        objAffiliation.npe5__Contact__c = objContact.Id;
        objAffiliation.npe5__Organization__c = objAccount.Id;
        objAffiliation.npe5__Status__c = 'Active';
        objAffiliation.Affiliation__c = 'Team Member';
        Insert objAffiliation;
        
        objAffiliation = new npe5__Affiliation__c();
        objAffiliation.npe5__Contact__c = objContact.Id;
        objAffiliation.npe5__Organization__c = objAccount.Id;
        objAffiliation.npe5__Status__c = 'Active';
        objAffiliation.Affiliation__c = 'Team Member';
        Insert objAffiliation;
        
        objContactSearch.strFirstName = 'FirstAffiliation';
        objContactSearch.strCity = 'CityAffiliation';
        objContactSearch.strZip = '';
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 1);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'FirstAffiliation LastAffiliation');
        
        objContactSearch.strSortField = 'MailingCity';
        objContactSearch.strSortDirection = 'Desc';
        
        // TODO - put this back when you figure out why NPE01 runs out of SOQL queries at this point
       /* integer intI;
        for (intI = 0; intI < 10; intI++)
        {
            objContact = new Contact();
            objContact.FirstName = 'TestFirstName';
            objContact.LastName = 'TestLastName' + intI;
            objContact.MailingCity = 'TestCity' + intI;
            objContact.Email = 'testemail1@test.com';
            Insert objContact;
        }
        
        objContactSearch.strFirstName = 'TestFirstName';
        objContactSearch.strCity = '';
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 10);
        System.AssertEquals(objContactSearch.ContactDisplay[0].strName, 'TestFirstName TestLastName0');
        
        objContactSearch.strSortField = 'Affiliation__c';
        objContactSearch.strSortDirection = 'Desc';
        objContactSearch.SetSearchVariables(); */
        
        
 //       objContactSearch.pageNumber = 2;
 //       objContactSearch.skipToPage();

		//Creates a list of ContactDetails and sets the Paginator record so that skipToPage() can be covered
		List < ContactDetail > lstContact = new List < ContactDetail > ();
		for(integer i=0;i<150;i++) {
			Contact objContactz = new Contact();
	        objContactz.FirstName = 'TestFirstName1'+i;
	        objContactz.LastName = 'TestLastName2'+i;
	        objContactz.MailingCity = 'TestCity2'+i;
			ContactDetail oo = new ContactDetail(objContactz, objContactSearch.blnVIPAccess);			      
			lstContact.add(oo);
		}    
		objContactSearch.paginator.setRecords(lstContact);
		objContactSearch.pageNumber = 1;          
		objContactSearch.skipToPage();             

		//Two memberships objects have to be inserted for the lines inside
		//if ( c.memberships__r.size() > 1 ) to be covered               
		objContactSearch.SearchContacts();
    }
    
    public static TestMethod void TestSearchContactsSpecialRequests()
    {
    	Contact objContact = new Contact();
        Apexpages.StandardController stdController = new Apexpages.StandardController(objContact);
        ContactSearch objContactSearch = new ContactSearch(stdController);
        
        List<selectOption> lstStates = objContactSearch.getStateList;

        System.AssertEquals(objContactSearch.strSortField, 'Name');
        System.AssertEquals(objContactSearch.strSortDirection, 'Asc');
        
        objContactSearch.SetSearchVariables();
        System.AssertEquals(objContactSearch.ContactDisplay.size(), 0);
        
        objContact = new Contact();
        objContact.FirstName = 'TestFirstName1';
        objContact.LastName = 'TestLastName1';
        objContact.MailingCity = 'TestCity1';
        if (lstStates.size() > 1)
            objContact.MailingState = lstStates[1].getLabel();
        objContact.Email = 'testemail1@test.com';
        objContact.Phone = '11111';
        objContact.MobilePhone = '22222';
        objContact.MailingPostalCode = '121212';
        objContact.DoNotCall = true;
        objContact.Do_Not_Text__c = true;
        objContact.HasOptedOutOfEmail = true;
        objContact.Do_Not_Contact__c = 'Test';
        Insert objContact;
        
        objContactSearch.strFirstName = 'TestFirstName1';
        objContactSearch.SetSearchVariables();
        
        objContact = new Contact();
        objContact.FirstName = 'TestFirstName1';
        objContact.LastName = 'TestLastName2';
        objContact.MailingCity = 'TestCity2';
        objContact.Phone = '22222';
        objContact.MailingPostalCode = '121212';
        objContact.Do_Not_Mail__c = true;
        Insert objContact;
        
        objContactSearch.SetSearchVariables();
       
    }
}