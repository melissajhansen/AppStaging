// RB 3/15/13
// class to sweep through all Lapsed or Lapsing Members
// and build an Email for a Membership Renew
// then send the Emails that are built in the EmailQueue

// Scheduled Job notes:
// Frequency: Monthly - on day 1 of every month, starts at 10am

// Change Log
// ------------
//  11/4/2013 - SKT, updates for new membership system - first pass done, ready for dev testing

global class EmailQueueLapsedMembers implements Schedulable {

//EmailQueueLapsedMembers e = new EmailQueueLapsedMembers();
//string sch = '0 30 11 * 1-12 ? *';
//system.schedule('EmailQueueLapsedMembers 1',sch,e);
	

	global void Execute(SchedulableContext SC) {
		// old code
		//sweepLapsedMembers();
		//sweepEmailQueue();
		
		// new code
		integer email_count;
		PersonCollection pc = new PersonCollection ();
		
		email_count = pc.queueMemberRenewalEmails( 'pre30' );
		email_count = pc.queueMemberRenewalEmails( 'pre7' );
		email_count = pc.queueMemberRenewalEmails( 'post7' );
		
		sweepEmailQueue();
	}

	global void sweepEmailQueue() {
		// sweep through all EmailQueue records that have not been sent and send out the emails
		// then set the DateEmailSent__c to System.now()
		List <EmailQueue__c> eQList = new List <EmailQueue__c>([SELECT Id, To__c, BCC__c, Subject__c, Body__c FROM EmailQueue__c WHERE (EmailType__c = 'MemRenewPre30' OR EmailType__c = 'MemRenewPre7' OR EmailType__c = 'MemRenewPost7') AND DateEmailSent__c =: null]);
		
		// find the OrgWideEmailAddress membership@stand.org
		OrgWideEmailAddress owea = [SELECT Id, Address from OrgWideEmailAddress WHERE Address = 'membership@stand.org'];
		
		// array of single emails
		List <Messaging.SingleEmailMessage> theEmails = new List <Messaging.SingleEmailMessage>();
		
		// loop through all records in eQ
		for ( EmailQueue__c e : eQList ) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List <String> toAddress = new List <String>();
			toAddress.add(e.To__c);
			List <String> bccAddress = new List <String>();
			bccAddress.add(e.BCC__c);
			mail.setOrgWideEmailAddressId(owea.id); 
			mail.setToAddresses(toAddress);
			mail.setBccAddresses(bccAddress);
			mail.setReplyTo('membership@stand.org');
//			mail.setSenderDisplayName('Simone Coker-Kamna');
			mail.setSubject(e.Subject__c);
			mail.setHtmlBody(e.Body__c);
			
			theEmails.add(mail);
			
			// update the DateEmailSent__c field
			e.DateEmailSent__c = System.now();
		}

		// update the EmailQueue list
		update eQList;
		
		// list of Emails that will be sent
		List <Messaging.Email> allMails = new List <Messaging.Email>();
		// loop through all single emails and add to the list of Emails
		for ( Integer j = 0; j < theEmails.size(); j++ ) {
			allMails.add(theEmails.get(j));
		}
		
		// send the emails and capture the results
		List <Messaging.SendEmailResult> results = Messaging.sendEmail(allMails);
		
		// list of errors
		List <Messaging.SendEmailError> errors = new List <Messaging.SendEmailError>();
		String emailErrorReport;
		// loop through results and check for errors
		for ( Messaging.SendEmailResult currentResult : results ) {
			errors = currentResult.getErrors();
			if ( errors != null ) {
				for ( Messaging.SendEmailError currentError : errors ) {
					emailErrorReport = emailErrorReport + '(' + currentError.getStatusCode() + ') ' + currentError.getMessage() + '\r';
				}
			}
		}
		
		System.debug('============EMAIL ERROR REPORT======================');
		System.debug(emailErrorReport);
		System.debug('============END EMAIL ERROR REPORT==================');
		
	}

}