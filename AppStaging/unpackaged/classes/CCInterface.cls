// Primary interface class for processing Credit Cards
// - Authorization

// REQUIRES:
// CnP Paas Objects
// Custom Settings :: CnPAccountSetting

// Adding a change

// Sample Usage
// ------------------------------------------
/* 
 CCInterface cc = new CCInterface ();
 
 cc.cardHolderFirstName = 'Tester';
 cc.cardHolderLastName = 'Jones';
 cc.cardHolderNameOnCard = 'Tester Jones';
 cc.cardNumber = '4111111111111111'; 
 cc.cv2 = '111';
 cc.expirationDate = '09/17';
 cc.ipAddress = '50.1.1.1';
 cc.donationAmount = 50.00;
 cc.campaignName = '';
 
 // if recurring
 cc.recurringPayment = true;
 cc.recurringPeriod = 'Month';
 
 // authorize the transaction
 boolean result = cc.authorize();
*/
// ------------------------------------------

public without sharing class CCInterface {
	
	// public parameters
	public string billingName;
	public string cardHolderFirstName;
	public string cardHolderLastName;
	public string cardHolderNameOnCard;
	
	public string cardNumber;
	public string cv2;
	public string expirationDate;  // mm/yy
	public string ipAddress;
	public double donationAmount {  // 15.00
						set {
							donationAmountForXML = (long) ( value * 100 ).round();  
							donationAmount = value;
						}
						get {
							return donationAmount;
						}
					}
	
	private long donationAmountForXML;  // 1500

	public string campaignName;	
	public string transactionNumber;
	public long transactionResultCode;
	
	public boolean recurringPayment;
	public string recurringPeriod;  // Month, Quarter, Year (case sensitive, includes other options that we do not use - see API docs)
	
	private integer recurringInstallment;
	private string recurringMethod;  // set to Subscription
	
	// private parameters
	private CnP_IaaS.Paas_Class cnpxmlstring { get; set; }
	private CnP_IaaS.Paas_Class.Operation Operation { get; set; }
	private CnP_IaaS.Paas_Class.Order Order { get; set; }
	private CnP_IaaS.Paas_Class.Authentication Authentication { get; set; }
	private CnP_IaaS.Paas_Class.BillingInformation BillingInfo { get; set; }
	private CnP_IaaS.Paas_Class.PaymentMethod PaymentMethod { get; set; }
	private CnP_IaaS.Paas_Class.Receipt Receipt { get; set; }
	private CnP_IaaS.Paas_Class.cnpTransaction cnptransaction { get; set; }
	public integer ResultCode { get; set; }
	public boolean error { get; set; }
	private list < CnP_IaaS.PaaS_Class.Items > items;
	
	private string cnpAccountNumber;
	private string cnpAccountGUID;
	private string orderMode;  // TODO Move this into Custom Settings
	
	// CONSTRUCTOR -----------------------------------------
	
	public CCInterface ( ) {
		// check to see if Account Settings are set
		list < CnPAccountSetting__c > SettingsList = [ select C_P_AccountGUID__c,C_P_Account_Number__c,WID__c, Order_Mode__c from CnPAccountSetting__c limit 1 ];
	
		if ( SettingsList.isempty () ) {
			// error handler
			system.debug ( '============================= EMPTY =====================' );
			error = true;
		}
		
		// init parameters
		this.campaignName = '';
		recurringMethod = 'Subscription';
		recurringInstallment = 999;// default to max - 999
		this.recurringPayment = false;  // default to false on recurring payment
		
		this.transactionNumber = '';  // blank notes unset
		this.transactionResultCode = -1; // negative 1 notes unset
		
		// initiate the C&P Class
		cnpxmlstring = new CnP_IaaS.Paas_Class();
		Operation = new CnP_IaaS.Paas_Class.Operation();
		Order = new CnP_IaaS.Paas_Class.Order();
		Authentication = new CnP_IaaS.Paas_Class.Authentication();
		BillingInfo = new CnP_IaaS.Paas_Class.BillingInformation();
		PaymentMethod = new CnP_IaaS.Paas_Class.PaymentMethod();
		Receipt = new CnP_IaaS.Paas_Class.Receipt();
		cnptransaction = new CnP_IaaS.Paas_Class.cnpTransaction();
		
		// Set Paas connection information
		Authentication.AccountGuid = SettingsList[0].C_P_AccountGUID__c;
		Authentication.AccountID = SettingsList[0].C_P_Account_Number__c;
		
		// set local configuration vars
		cnpAccountNumber = SettingsList[0].C_P_Account_Number__c;
		cnpAccountGUID = SettingsList[0].C_P_AccountGUID__c;
		orderMode = SettingsList[0].Order_Mode__c;

		string dd = datetime.now ().format ( 'MM/dd/yyyy' );
		string mon = dd.substring ( 0, 2 );
		string year = dd.substring ( 7, 10 );
		
		PaymentMethod.ExpirationMonth=mon;
		PaymentMethod.ExpirationYear=year;
	}
	
	
	// authorize ()
	// ---------------
	// Requests an authorization for CC transaction
	// to Click and Pledge
	public boolean authorize ( ) {
		//Validate Required Fields
		if ((this.cardHolderFirstName == '') || (this.cardHolderLastName == '') || (this.cardHolderNameOnCard == '') || (this.cardNumber == '') || (this.cv2 == '') || (this.expirationDate == '') || (this.ipAddress == '') || (this.donationAmount == 0) || (this.donationAmount == null)) {
			throw new StandException(116);
		}
		try {
		this.process();
		} catch (StandException e) {
			throw new StandException(e.errorCode);
			return false;
		} catch (Exception e) {
			throw new StandException(304);
			return false;
		}
		return true;

	}
	
	private boolean process() {
		
		// TODO SKT
		// Note: 8/21/2013
		// Had to turn off a validation rule on Contact - Prospect_Classification_Status_Agreement
		// to get this to work - I think...
		// Make sure to turn the validation rule back on!!!
		// Also turned off validation rule on Account - Prospect_Classification_Status_Agreement
		// Update: Found out that Validation rule problems are encountered IF C&P is not pointing to the current
		// SFDC instance
		

		if ((cnpAccountNumber == '') || ( cnpAccountGUID == '')) {
			// both must have values
			throw new StandException (306);
			return false;
		} else {
			// load up the authorization object
			Authentication.AccountGuid = cnpAccountGUID;
			Authentication.AccountID = cnpAccountNumber;
		}
 
		/*
		// set Order Mode
		Order.OrderMode='Test';

		// Setup Operation
		
		cnpxmlstring.getOperation_node( Operation );

		// Setup Order
		cnpxmlstring.getOrder_node(Order);

		// Setup authentication
		cnpxmlstring.getAuthentication_node(Authentication);

		// Set billing info
		cnpxmlstring.getBillingInformation_node(BillingInfo);

		// -- Set items
       
        items = new list<CnP_IaaS.PaaS_Class.Items>();
        CnP_IaaS.PaaS_Class.Items TempItem = new CnP_IaaS.PaaS_Class.Items();
        TempItem.ItemName = 'Donation';
        TempItem.UnitPrice = this.donationAmount;
        items.add(TempItem);
		cnpxmlstring.getItemslist_node( items );
		cnpxmlstring.getItemsString_node(cnpxmlstring);
	
		// Set transaction details
		cnpxmlstring.getTransactionDetails_node(cnptransaction);

		// Set Payment methods
		cnpxmlstring.getPaymentMethod_node(PaymentMethod);

		// Set recript
		cnpxmlstring.getreceipt_node(Receipt);

		// Generate XML
		cnpxmlstring.getgeneratexml(cnpxmlstring);
		
		//System.debug ( cnpxmlstring.xmlfile );
		*/
		
		// SKT 9/9/13
		// We are using this method of building the XML manually below due to a problem in the current CnP API Class Libraries
		// The standard CC interface to CNP uses the IP Address of the client request as exposed through System API.  Since this
		// is a request that does not have an active SFDC web client, this fails.
		// Work around is to manually create the XML to be sent to CNP
		
		// Build recurring portion if needed
		string xmlRecurring = '';
		if ( this.recurringPayment ) {
			xmlRecurring = '<Recurring><Installment>' + recurringInstallment + '</Installment><Periodicity>' + this.recurringPeriod + '</Periodicity><RecurringMethod>' + recurringMethod + '</RecurringMethod></Recurring>';
		}
		
		// custom parameters
		string cqString = '<CustomParameters><Parameter><Field>QNAME</Field><Value>QVALUE</Value></Parameter></CustomParameters>';

		// the main XML string to pass into API
		//TEST - string xmlString = '<CnPAPI xmlns="urn:APISchema.xsd"><Version>12</Version><Engine><Request><Operation><OperationType>Transaction</OperationType><IPAddress>' + this.ipAddress + '</IPAddress><DeclineFraud>true</DeclineFraud><EnableRestriction>true</EnableRestriction><UrlReferrer></UrlReferrer></Operation><Authentication><AccountGuid>' + cnpAccountGUID + '</AccountGuid><AccountID>' + cnpAccountNumber + '</AccountID></Authentication><Order><OrderMode>' + orderMode + '</OrderMode><Tracker><![CDATA[]]></Tracker><Campaign><![CDATA[' + campaignName + ']]></Campaign><CardHolder><BillingInformation><BillingFirstName><![CDATA[' + cardHolderFirstName +']]></BillingFirstName><BillingMI></BillingMI><BillingLastName><![CDATA[' + cardHolderLastName +']]></BillingLastName></BillingInformation><PaymentMethod><PaymentType>CreditCard</PaymentType><CreditCard><NameOnCard><![CDATA[' + cardHolderNameOnCard +']]></NameOnCard><CardNumber>' + cardNumber +'</CardNumber><Cvv2>' + cv2 +'</Cvv2><ExpirationDate>' + expirationDate +'</ExpirationDate></CreditCard></PaymentMethod>' + cqString + ' </CardHolder><ThirdParty></ThirdParty><OrderItemList><OrderItem><ItemID>1</ItemID><ItemName><![CDATA[Donation]]></ItemName><Quantity>1</Quantity><UnitPrice>'+ donationAmountForXML + '</UnitPrice><UnitDeductible>0</UnitDeductible><UnitTax>0</UnitTax><UnitDiscount>0</UnitDiscount><SKU></SKU><CouponCode></CouponCode><Campaign><![CDATA[' + campaignName + ']]></Campaign></OrderItem></OrderItemList><Receipt><SendReceipt>true</SendReceipt><Language>ENG</Language><OrganizationInformation><![CDATA[]]></OrganizationInformation><ThankYouMessage><![CDATA[]]></ThankYouMessage><TermsCondition><![CDATA[]]></TermsCondition><Deductible>false</Deductible></Receipt><Transaction><TransactionType>Authorize</TransactionType><DynamicDescriptor></DynamicDescriptor>' + xmlRecurring + '<CurrentTotals><TotalDiscount>0</TotalDiscount><TotalTax>0</TotalTax><TotalShipping>0</TotalShipping><TotalDeductible>0</TotalDeductible><Total>' + donationAmountForXML + '</Total></CurrentTotals><CouponCode></CouponCode><TransactionDiscount>0</TransactionDiscount><TransactionTax>0</TransactionTax><TransactionConvenienceFee>0</TransactionConvenienceFee></Transaction></Order></Request></Engine></CnPAPI>';
		//TEST - string xmlString = '<CnPAPI xmlns="urn:APISchema.xsd"><Version>12</Version><Engine><Request><Operation><OperationType>Transaction</OperationType><IPAddress>' + this.ipAddress + '</IPAddress><DeclineFraud>true</DeclineFraud><EnableRestriction>true</EnableRestriction><UrlReferrer></UrlReferrer></Operation><Authentication><AccountGuid>d34f7264-eb39-4cd1-8532-5cbeff6fb6ce</AccountGuid><AccountID>19060</AccountID></Authentication><Order><OrderMode>Test</OrderMode><Tracker><![CDATA[]]></Tracker><Campaign><![CDATA[]]></Campaign><CardHolder><BillingInformation><BillingFirstName><![CDATA[Test]]></BillingFirstName><BillingMI></BillingMI><BillingLastName><![CDATA[User]]></BillingLastName></BillingInformation><PaymentMethod><PaymentType>CreditCard</PaymentType><CreditCard><NameOnCard><![CDATA[Over The Line]]></NameOnCard><CardNumber>4111111111111111</CardNumber><Cvv2>111</Cvv2><ExpirationDate>06/17</ExpirationDate></CreditCard></PaymentMethod>' + cqString + ' </CardHolder><ThirdParty></ThirdParty><OrderItemList><OrderItem><ItemID>1</ItemID><ItemName><![CDATA[Donation]]></ItemName><Quantity>1</Quantity><UnitPrice>1500</UnitPrice><UnitDeductible>0</UnitDeductible><UnitTax>0</UnitTax><UnitDiscount>0</UnitDiscount><SKU></SKU><CouponCode></CouponCode><Campaign><![CDATA[]]></Campaign></OrderItem></OrderItemList><Receipt><SendReceipt>true</SendReceipt><Language>ENG</Language><OrganizationInformation><![CDATA[]]></OrganizationInformation><ThankYouMessage><![CDATA[]]></ThankYouMessage><TermsCondition><![CDATA[]]></TermsCondition><Deductible>false</Deductible></Receipt><Transaction><TransactionType>Authorize</TransactionType><DynamicDescriptor></DynamicDescriptor><CurrentTotals><TotalDiscount>0</TotalDiscount><TotalTax>0</TotalTax><TotalShipping>0</TotalShipping><TotalDeductible>0</TotalDeductible><Total>1500</Total></CurrentTotals><CouponCode></CouponCode><TransactionDiscount>0</TransactionDiscount><TransactionTax>0</TransactionTax><TransactionConvenienceFee>0</TransactionConvenienceFee></Transaction></Order></Request></Engine></CnPAPI>';
		string xmlString = '<CnPAPI xmlns="urn:APISchema.xsd"><Version>12</Version><Engine><Request><Operation><OperationType>Transaction</OperationType><IPAddress>' + this.ipAddress + '</IPAddress><DeclineFraud>true</DeclineFraud><EnableRestriction>true</EnableRestriction><UrlReferrer></UrlReferrer></Operation><Authentication><AccountGuid>' + cnpAccountGUID + '</AccountGuid><AccountID>' + cnpAccountNumber + '</AccountID></Authentication><Order><OrderMode>' + orderMode + '</OrderMode><Tracker><![CDATA[]]></Tracker><Campaign><![CDATA[' + campaignName + ']]></Campaign><CardHolder><BillingInformation><BillingFirstName><![CDATA[' + cardHolderFirstName +']]></BillingFirstName><BillingMI></BillingMI><BillingLastName><![CDATA[' + cardHolderLastName +']]></BillingLastName></BillingInformation><PaymentMethod><PaymentType>CreditCard</PaymentType><CreditCard><NameOnCard><![CDATA[' + cardHolderNameOnCard +']]></NameOnCard><CardNumber>' + cardNumber +'</CardNumber><Cvv2>' + cv2 +'</Cvv2><ExpirationDate>' + expirationDate + '</ExpirationDate></CreditCard></PaymentMethod>' + cqString + ' </CardHolder><ThirdParty></ThirdParty><OrderItemList><OrderItem><ItemID>1</ItemID><ItemName><![CDATA[Donation]]></ItemName><Quantity>1</Quantity><UnitPrice>' + donationAmountForXML + '</UnitPrice><UnitDeductible>0</UnitDeductible><UnitTax>0</UnitTax><UnitDiscount>0</UnitDiscount><SKU></SKU><CouponCode></CouponCode><Campaign><![CDATA[' + campaignName + ']]></Campaign></OrderItem></OrderItemList><Receipt><SendReceipt>true</SendReceipt><Language>ENG</Language><OrganizationInformation><![CDATA[]]></OrganizationInformation><ThankYouMessage><![CDATA[]]></ThankYouMessage><TermsCondition><![CDATA[]]></TermsCondition><Deductible>false</Deductible></Receipt><Transaction><TransactionType>Authorize</TransactionType><DynamicDescriptor></DynamicDescriptor>' + xmlRecurring + '<CurrentTotals><TotalDiscount>0</TotalDiscount><TotalTax>0</TotalTax><TotalShipping>0</TotalShipping><TotalDeductible>0</TotalDeductible><Total>' + donationAmountForXML + '</Total></CurrentTotals><CouponCode></CouponCode><TransactionDiscount>0</TransactionDiscount><TransactionTax>0</TransactionTax><TransactionConvenienceFee>0</TransactionConvenienceFee></Transaction></Order></Request></Engine></CnPAPI>';
		
		System.debug ( xmlString );
		
		// Transmit the XML transaction
		// I know this looks wrong - why are we continuing if VerifyXML is False?
		// well, the developers at CnP obviously don't understand english logic
		// so don't be fooled, IF the XML File is Verified, it will return false
		
		if ( cnpxmlstring.Verifyxmlfile == false ) {
			//cnpxmlstring.Send_Transaction_api(cnpxmlstring.xmlfile);
			if ( Test.isRunningTest() == false ) {
				cnpxmlstring.Send_Transaction_api ( xmlString );
				System.debug ( '========== CNP CALL ============' + xmlString );
			} else {
				// skip and return
				return true;
			}
		} else {
			throw new StandException (304);
			return false; // this is an error condition!!!
		}
		
		// output?
		System.debug ( '======================================================================' + cnpxmlstring.TransactionResultCode );
		System.debug ( '======================================================================' + cnpxmlstring.TransactionNumber );
		
		this.transactionNumber = cnpxmlstring.TransactionNumber;
		this.transactionResultCode = cnpxmlstring.TransactionResultCode;
		
		if ( cnpxmlstring.TransactionResultCode == 0 ) {
			// success
			return true;
		} else {
			// failure
			throw new StandException (304);
			return false;	
		}
	}

}