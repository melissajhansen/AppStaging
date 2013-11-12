// RB 4/29/13
// class to build an Email for a Membership Renew
// then send that Email out from a button on the Membership object

global class EmailQueueLapsedMembersButton {

	// Integer to hold the first Lapse period
	// set to 30, to equal 30 days after a certain date
	public static Integer FirstLapsePeriod = 30;
	public static String FirstLapsePeriodEmailType = 'Lapsing';
	// Integer to hold the second Lapse period
	// set to 7, to equal 7 days after a certain date
	public static Integer SecondLapsePeriod = 7;
	public static String SecondLapsePeriodEmailType = 'Lapsing';
	// Integer to hold the second Lapse period
	// set to -7, to equal 7 days before a certain date
	public static Integer ThirdlapsePeriod = -7;
	public static String ThirdLapsePeriodEmailType = 'Lapsed';

	// method to determine if the Send Renewal Email button should be shown on the Membership page layout
	// controlled via javascript in a hidden Home Page component on the left nav
	// these methods (called from javascript) have to be webService methods in order to work
	webService static String showHideButton(String memId) {
//		System.debug(memId);
		List <Membership__c> mList = new List <Membership__c>([SELECT Id, Expiration_Date__c, Status2__c FROM Membership__c WHERE Id =: memId AND Type__c != 'Sustaining' AND Contact__r.Email != '']);
		
		// if there are no Memberships with this ID, hide the button
		if ( mList.size() == 0 ) {
			return 'hide';
		}
		// if the Expiration date is in the lapsing period
		if (mList[0].Expiration_Date__c <= System.today().addDays(FirstLapsePeriod)) {
			// if the status isn't dropped, then show the button
			if (mList[0].Status2__c != 'Dropped') {
				return 'show';
			} else {
				return 'hide';
			}
		}
		// default is to hide the button
		return 'hide';
	}

	// method to create and send the email when the button is pushed
	webService static String createEmail(String memId) {
		
		PersonCollection pc = new PersonCollection ();
		
		integer email_count = pc.queueMemberRenewalEmails ( 'ondemand' );
		
		if ( email_count == 0 ) {
			return 'fail';
		}

		// return a success message
		return 'success';
		
	}
	

}