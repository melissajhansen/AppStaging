@isTest ( SeeAllData = true) 

// SKT 9/8/13
// Due to the fact that CnP makes outbound calls to their webservice end point
// Tests are skipped per the SFDC Test Manager System.  We have attained close to 90%
// code coverage, even with this constraint - will leave this for now
// and evaluate later.  I think Rob figured this out, will need to do a longer
// review of some of his test classes.
//
// TODO get this to 100% code coverage
//

public class CCInterface_Test {

	public static TestMethod void SimpleAuthorization () {
		
		double donationA = 50.00;
		
		CCInterface cc = new CCInterface ();

		cc.cardHolderFirstName = 'Tester';
		cc.cardHolderLastName = 'Smith123';
		cc.cardHolderNameOnCard = 'Tester Judy';
		cc.cardNumber = '4111111111111111';
		cc.cv2 = '111';
		cc.expirationDate = '09/17';
		cc.ipAddress = '50.1.1.1';
		cc.donationAmount = donationA;
		
		// check donation Amount
		system.assertequals ( cc.donationAmount, donationA );
		cc.campaignName = '';
		cc.recurringPayment = false;
		//cc.recurringPeriod = 'Month';

		if ( cc.authorize() ) {
			// success
			system.assertequals ( true, cc.transactionResultCode == 0 );
		} else {
			// failure
			system.assertequals ( false, true );  // we should never hit this branch
		}
	}
	 
	public static TestMethod void RecurringMonthAuthorization () {
		CCInterface cc = new CCInterface ();

		cc.cardHolderFirstName = 'Tester';
		cc.cardHolderLastName = 'Smith123';
		cc.cardHolderNameOnCard = 'Tester Judy';
		cc.cardNumber = '4111111111111111';
		cc.cv2 = '111';
		cc.expirationDate = '09/17';
		cc.ipAddress = '50.1.1.1';
		cc.donationAmount = 50.00;
		cc.campaignName = '';
		cc.recurringPayment = true;
		cc.recurringPeriod = 'Month';

		if ( cc.authorize() ) {
			// success
			system.assertequals ( true, cc.transactionResultCode == 0 );
		} else {
			// failure
			system.assertequals ( false, true );  // we should never hit this branch
		}
	}
	
	public static TestMethod void RecurringQuarterAuthorization () {
		CCInterface cc = new CCInterface ();

		cc.cardHolderFirstName = 'Tester';
		cc.cardHolderLastName = 'Smith123';
		cc.cardHolderNameOnCard = 'Tester Judy';
		cc.cardNumber = '4111111111111111';
		cc.cv2 = '111';
		cc.expirationDate = '09/17';
		cc.ipAddress = '50.1.1.1';
		cc.donationAmount = 50.00;
		cc.campaignName = '';
		cc.recurringPayment = true;
		cc.recurringPeriod = 'Quarter';

		if ( cc.authorize() ) {
			// success
			system.assertequals ( true, cc.transactionResultCode == 0 );
		} else {
			// failure
			system.assertequals ( false, true );  // we should never hit this branch
		}
	}
	
	public static TestMethod void RecurringYearAuthorization () {
		CCInterface cc = new CCInterface ();

		cc.cardHolderFirstName = 'Tester';
		cc.cardHolderLastName = 'Smith123';
		cc.cardHolderNameOnCard = 'Tester Judy';
		cc.cardNumber = '4111111111111111';
		cc.cv2 = '111';
		cc.expirationDate = '09/17';
		cc.ipAddress = '50.1.1.1';
		cc.donationAmount = 50.00;
		cc.campaignName = '';
		cc.recurringPayment = true;
		cc.recurringPeriod = 'Year';

		if ( cc.authorize() ) {
			// success
			system.assertequals ( true, cc.transactionResultCode == 0 );
		} else {
			// failure
			system.assertequals ( false, true );  // we should never hit this branch
		}
	}
	
	public static TestMethod void SimpleAuthorizationFailure () {
		CCInterface cc = new CCInterface ();

		cc.cardHolderFirstName = 'Tester';
		cc.cardHolderLastName = 'Smith123';
		cc.cardHolderNameOnCard = 'Tester Judy';
		cc.cardNumber = '4111111111111111';
		cc.cv2 = '111';
		cc.expirationDate = '09/12';  // old exp date
		cc.ipAddress = '50.1.1.1';
		cc.donationAmount = 50.00;
		cc.campaignName = '';
		//cc.recurringPayment = true;
		//cc.recurringPeriod = 'Month';

		if ( cc.authorize() ) {
			// success
			system.assertequals ( true, cc.transactionResultCode == 0 );
		} else {
			// failure
			system.assertequals ( false, true );  // we should never hit this branch
		}
	}
	
	public static TestMethod void RecurringAuthorizationFailure () {
		
	}
	
	public static TestMethod void SystemError () {
		
	}
	
}