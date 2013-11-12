public with sharing class PaymentUtil {

	public PaymentUtil () {
		
	}
	//Method to populate payments created by C&P transactions, with the relevent information from the C&P Transaction	
	public void paymentCPInfo (List < npe01__OppPayment__c > payList ){
		
		//Declare Variables & Lists
		String authCode = '';
		String payType = '';
		String lastFour = '';
		String expDate = '';
		String cardName = '';
		String cardType = '';
		String donorName = '';
		String donorAddress = '';
		
		//Create List of Opportunity IDS for the Opportunities related to payments in PayList
		List < ID > allPayOppList = new List < ID > ();
		//Populate allPayOppList
		for (npe01__OppPayment__c p : payList) {
			allPayOppList.add(p.npe01__Opportunity__c);
		}
		
		//List of all Opportunities that have a C&P Transaction and are in the allPayOppList
		List < Opportunity > OppList = new List < Opportunity > ([SELECT ID, CnP_PaaS__CnP_OrderNumber__c, npe01__Number_of_Payments__c, Account.ID FROM Opportunity WHERE ID in: allPayOppList AND CnP_PaaS__CnP_OrderNumber__c != null]);
		
		//Create List of Account IDs, and Acounts to get access to Name/Address
		list < ID > accountIDList = new list < ID > ();
		
		//Create and fill List of CnP Transaction IDs
		//Fill AccountID List while we're at it
		list < ID > CnPIDList = new list < ID > ();
		for (Opportunity o : OppList) {
			CnPIDList.add(o.CnP_PaaS__CnP_OrderNumber__c);	
			accountIDList.add(o.AccountID);
		}	
		
		//Create a list of the Transaction sObjects from the CnP Transaction ID List
		list < CnP_PaaS__CnP_Transaction__c > cnPList = new list < CnP_PaaS__CnP_Transaction__c > ([SELECT ID, CnP_PaaS__AutorizationCode__c, CnP_PaaS__PaymentType__c, CnP_PaaS__CreditCard4x4__c, cnp_paas__cardexpiration__c, cnp_paas__name_on_card__c, CnP_PaaS__Credit_Card_Name__c, CnP_PaaS__first_name__c, CnP_PaaS__Last_Name__c, CnP_PaaS__Address1__c, CnP_PaaS__Address_2__c, CnP_PaaS__City__c, CnP_PaaS__State__c, CnP_PaaS__Zip_Code__c FROM CnP_PaaS__CnP_Transaction__c WHERE ID in: CnPIDList]);
		
		//Create and fill Map of CnP ID/CnP Transaction.  This will give access to CnP Fields below based on ID without having a SOQL call in the loop
		map < ID, CnP_PaaS__CnP_Transaction__c > CnPMap = new map < ID, CnP_PaaS__CnP_Transaction__c > ();
		//Fill the map
		for (CnP_PaaS__CnP_Transaction__c cp: CnPList) {
			CnPMap.put(cp.ID, cp);
		}	
		
		//List of Account sObjects to get access to PAC Donor Name and Address
		list < Account > accountList = new list < Account > ([SELECT ID, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account WHERE ID in: accountIDList]);
		//Now create a Map of Account ID/Account so we can reference data from the Account later
		map < ID, Account > accountMap = new map < ID, Account> ();
		for (Account a :accountList) {
			accountMap.put(a.ID, a);
		}
		//Loop through the Starting list of Payments and for each one with an Opportunity that has a C&P Trans, update the Payment with relevant fields
		for ( npe01__OppPayment__c p : payList ) {
			for (Opportunity o : OppList) {
				//Checking to see that the Opp has a CnP Transaction, and that this is the first payment on that Opportunity
				if ((p.npe01__Opportunity__c == o.id) && (o.npe01__Number_of_Payments__c == 0)) {
					//fill in the default field(s)
					p.Gift_Portal__c = 'Web';
					
					//Retreive the CnP Payment from the CnPMap using the Id from Opportunity and assign it to the CnPTrans variable
					sObject CnPTrans = CnPMap.get(o.CnP_PaaS__CnP_OrderNumber__c);
					system.debug('***********************************************'+ CnPTrans);
					//Create list of CnP Field Values
					authCode = (String.valueOf(CnPTrans.get('CnP_PaaS__AutorizationCode__c')));
					paytype = (String.valueOf(CnPTrans.get('CnP_PaaS__PaymentType__c')));
					lastFour = (String.valueOf(CnPTrans.get('CnP_PaaS__CreditCard4x4__c')));
					expDate = (String.valueOf(CnPTrans.get('cnp_paas__cardexpiration__c')));
					cardName = (String.valueOf(CnPTrans.get('cnp_paas__name_on_card__c')));
					cardType = (String.valueOf(CnPTrans.get('CnP_PaaS__Credit_Card_Name__c')));
					
					//Fill in Payment Values
					if (authCode != null) {
						p.Authorization_Code__c = authCode.left(25);
					}
					if (paytype != null) {
						if (paytype == 'eCheck') p.npe01__Payment_Method__c = 'Debit'; else p.npe01__Payment_Method__c = paytype;
					}
					if (lastFour != null) {
						p.Card_Last_4_Numbers__c = lastFour.right(4);
					}
					if (expDate != null) {
						p.Card_Expiration_Month__c = DatetoMonthString(expDate);
						p.Card_Expiration_Year__c = expDate.right(4);
					}
					if (cardName != null) {
						p.Cardholder_Name__c = cardName.left(40);
					}
					if (cardType != null) {
						p.Card_Type__c = cardType;
					}
				}
			}
		}
	
		//Create Map of Opportunity ID & C&P ID
		map <ID, ID> CnPTrans = new map <ID, ID> ();
		String tmp_Value = '';
		
		for ( npe01__OppPayment__c p : payList ) {
			for (Opportunity o: OppList) {
				if (p.npe01__Opportunity__c == o.id){
					CnPTrans.put(o.id, o.CnP_PaaS__CnP_OrderNumber__c);				
				}
			}
		}
		
		CnP_Custom_Question_Loader cq = new CnP_Custom_Question_Loader ( CnPTrans.values () );
		if ( cq.Get_Maps () ) {
		//call to the loader was successful, update Payments as necessary
			for (npe01__OppPayment__c p : payList) {
				for ( Opportunity o: OppList) {
					//Need to loop through Occupation, Employer Name and Employer Address
					tmp_Value = cq.Get_Value_By_Trans_Key( CnPTrans.get ( o.Id ), 'Occupation');
					if (tmp_Value != null) {
						//write the record
						p.PAC_Occupation__c = tmp_Value.left(75);
					}
					
					tmp_Value = cq.Get_Value_By_Trans_Key( CnPTrans.get ( o.Id ), 'Employer Name');
					if (tmp_Value != null) {
						//write the record
						p.PAC_Employer_Name__c = tmp_Value.left(100);
					}
					
					tmp_Value = cq.Get_Value_By_Trans_Key( CnPTrans.get ( o.Id ), 'Employer Address');
					if (tmp_Value != null) {
						//write the record
						p.PAC_Employer_Address__c = tmp_Value.left(255);
					}
					
					//If there are PAC Values, fill in the PAC Donor Address and PAC Donor Name from the transaction
					if ((p.PAC_Employer_Address__c != null) || (p.PAC_Employer_Name__c != null) || (p.PAC_Occupation__c != null)){
						//Update the PAC Donor Name and PAC Donor Address from the Account onto the payment
						//Using the Account Map we build above
						account a = accountMap.get(o.AccountID);
						p.PAC_Donor_Name__c = a.Name;
						p.PAC_Donor_Address__c = a.BillingStreet + ', ' + a.BillingCity + ', ' + a.BillingState + ', ' + a.BillingPostalCode;

					}
				}
			}
		}
	}	
		
		

	
	public static String DatetoMonthString (String expText) {
		string mon;
		if (expText.left(2) == '01') {
			mon = 'Jan';
		} else if (expText.left(2) == '02') {
			mon = 'Feb'; 
		} else if (expText.left(2) == '03') {
			mon = 'Mar'; 
		} else if (expText.left(2) == '04') {
			mon = 'Apr'; 
		} else if (expText.left(2) == '05') {
			mon = 'May'; 
		} else if (expText.left(2) == '06') {
			mon = 'Jun'; 
		} else if (expText.left(2) == '07') {	
			mon = 'Jul'; 
		} else if (expText.left(2) == '08') {
			mon = 'Aug'; 
		} else if (expText.left(2) == '09') {
			mon = 'Sep';
		} else if (expText.left(2) == '10') {
			mon = 'Aug';
		} else if (expText.left(2) == '11') {
			mon = 'Nov';
		} else if (expText.left(2) == '12') {
			mon = 'Dec';} 
		return mon;
	}

}