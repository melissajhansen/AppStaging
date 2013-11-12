// RB 2/28/13
// class to sweep through all Tasks for Users with the EmailNotificationOfTasks__c flag set to true
// and build an Email of Tasks that are overdue or are new since the last time they logged in

global class EmailQueueUtils implements Schedulable {

//EmailQueueUtils e = new EmailQueueUtils();
//string sch = '0 0 2 * 1-12 ? *';
//system.schedule('EmailQueueUtils 1',sch,e);


	global void Execute(SchedulableContext SC) {
		// only run this Monday - Friday (not on Sat or Sun)
		// Sun = 0, Mon = 1, Tue = 2, Wed = 3, Thu = 4, Fri = 5, Sat = 6
		Date weekStart = System.today().toStartofWeek();
		Integer dayOfWeek = weekStart.daysBetween(System.today());
//		System.debug('====================DATE INFORMATION RLB======================');
//		System.debug(dayOfWeek);
		if (dayOfWeek >= 1 && dayOfWeek <= 5 ) {
			sweepTasks();
			sweepEmailQueue();
		}
	}

	global void sweepTasks() {
		// need set of all users (distinct) that have outstanding tasks
		// list of Tasks that are still open
		List <Task> tList = new List <Task>([SELECT OwnerId, Status, Subject, CreatedDate, ActivityDate, WhoId FROM Task WHERE Status != 'Completed']);
		// set of Ids to hold the distinct users with tasks
		Set <Id> uIDList = new Set <Id>();
		Set <Id> cIDList = new Set <Id>();
		for (Integer i = 0; i < tList.size(); i++) {
			uIDList.add(tList[i].OwnerId);
			cIDList.add(tList[i].WhoId);
		}
		
		
		Date threeDaysAgo = System.today().addDays(-3);
// below line is for testing, since you otherwise have to wait 3 days from the time someone last logged in
// to get the emails sent.  The line below changes it to 3 days in the future, so it will send the emails
// no matter when someone last logged in
//		Date threeDaysAgo = System.today().addDays(3);
		// create a list of User records from the Set
		// who have the EmailNotificationOfTasks__c flag set to true
		List <User> uList1 = new List <User>([SELECT Id, Name, Email, EmailNotificationCC__c, EmailNotificationOfTasks__c, LastLoginDate FROM User WHERE EmailNotificationOfTasks__c =: true AND (LastLoginDate <=: threeDaysAgo OR LastLoginDate = null) AND Id IN : uIDList]);
		List <User> uList = new List <User>();
		
		// check to see if the user has any tasks that are new or overdue
		// if they have tasks then add them to the list
		Boolean tasksFound = false;
		for ( User u1 : uList1 ) {
			tasksFound = false;
			for ( Task t1 : tList ) {
				if ( t1.OwnerId == u1.Id && (t1.CreatedDate >= u1.LastLoginDate || u1.LastLoginDate == null) && u1.Name != 'UserOverdueTasks User' ) {
					tasksFound = true;
				} 
				if ( (t1.OwnerId == u1.Id && t1.ActivityDate < System.today()) || u1.Name == 'UserOverdueTasks User' ) {
					tasksFound = true;
				}
			}
			if ( tasksFound == true ) {
				uList.add(u1);
			}
		}
		
		// create a list of Contact records from the Set
		List <Contact> cList = new List <Contact>([SELECT Id, Name FROM Contact WHERE Id IN : cIDList]);
		
		// loop through all users and build the EmailQueue record
		// from all of their outstanding Tasks
		// list of Tasks that will be included in the email
		String overdueNotStartedTasks = '<b>Overdue Tasks Not Started:</b>';
		String newTasks = '<b>New Tasks:</b> (as of ' + String.valueOf(System.now().format('MMMMM dd, yyyy hh:mm a')) + ') ';
		String overdueWaitingTasks = '<b>Overdue Tasks Waiting On Someone Else:</b> ';
		String overdueInProgressTasks = '<b>Overdue Tasks In Progress:</b>';
		String baseURL = System.URL.getSalesforceBaseUrl().getHost();
		String tName = '';
		Boolean tNameFound = false;
		Boolean overdueNotStartedFound = false;
		Boolean newTasksFound = false;
		Boolean overdueWaitingFound = false;
		Boolean overdueInProgressFound = false;
		Integer i;

		for ( User u : uList ) {
			overdueNotStartedTasks = '<b>Overdue Tasks Not Started:</b>';
			newTasks = '<b>New Tasks:</b> (as of ' + String.valueOf(System.now().format('MMMMM dd, yyyy hh:mm a')) + ') ';
			overdueWaitingTasks = '<b>Overdue Tasks Waiting On Someone Else:</b> ';
			overdueInProgressTasks = '<b>Overdue Tasks In Progress:</b>';
			// select the overdue tasks for the user
			// and new tasks since their last login
			for ( Task t : tList ) {
				String dateNow = '';
				if ( t.ActivityDate != null ) {
					Datetime dtNow = t.ActivityDate;
					dateNow = dtNow.format('MM/dd/yy');
				}
				// New Tasks
				// filter includes u.Name for handling Test Coverage
				if ( t.OwnerId == u.Id && (t.CreatedDate >= u.LastLoginDate || u.LastLoginDate == null) && u.Name != 'UserOverdueTasks User' ) {
					newTasksFound = true;
					for ( Contact c : cList ) {
						if ( c.Id == t.WhoId ) {
							tName = c.Name;
							tNameFound = true;
						}
					}
					if ( tNameFound == true ) {
						newTasks = newTasks + '<br>* <a href="https://' + baseURL + '/' + t.Id + '">' + t.Subject + '</a> for ' + tName + ' (due ' + dateNow + ')<br>';
					} else {
						newTasks = newTasks + '<br>* <a href="https://' + baseURL + '/' + t.Id + '">' + t.Subject + '</a> (due ' + dateNow + ')<br>';
					}
				// Overdue Tasks
				// filter includes u.Name for handling Test Coverage
				} else if ( (t.OwnerId == u.Id && t.ActivityDate < System.today()) || u.Name == 'UserOverdueTasks User' ){
					for ( Contact c : cList ) {
						if ( c.Id == t.WhoId ) {
							tName = c.Name;
							tNameFound = true;
						}
					}
					if ( tNameFound == true ) {
						if ( t.Status == 'Not Started' ) {
							overdueNotStartedFound = true;
							overdueNotStartedTasks = overdueNotStartedTasks + '<br>* <a href="https://' + baseURL + '/' + t.Id + '">' + t.Subject + '</a> for ' + tName + ' (due ' + dateNow + ')<br>';
						} else if ( t.Status == 'Waiting on someone else' ) {
							overdueWaitingFound = true;
							overdueWaitingTasks = overdueWaitingTasks + '<br>* <a href="https://' + baseURL + '/' + t.Id + '">' + t.Subject + '</a> for ' + tName + ' (due ' + dateNow + ')<br>';
						} else if ( t.Status == 'In Progress' ) {
							overdueInProgressFound = true;
							overdueInProgressTasks = overdueInProgressTasks + '<br>* <a href="https://' + baseURL + '/' + t.Id + '">' + t.Subject + '</a> for ' + tName + ' (due ' + dateNow + ')<br>';
						}
					} else {
						if ( t.Status == 'Not Started' ) {
							overdueNotStartedFound = true;
							overdueNotStartedTasks = overdueNotStartedTasks + '<br>* <a href="https://' + baseURL + '/' + t.Id + '">' + t.Subject + '</a> (due ' + dateNow + ')<br>';
						} else if ( t.Status == 'Waiting on someone else' ) {
							overdueWaitingFound = true;
							overdueWaitingTasks = overdueWaitingTasks + '<br>* <a href="https://' + baseURL + '/' + t.Id + '">' + t.Subject + '</a> (due ' + dateNow + ')<br>';
						} else if ( t.Status == 'In Progress' ) {
							overdueInProgressFound = true;
							overdueInProgressTasks = overdueInProgressTasks + '<br>* <a href="https://' + baseURL + '/' + t.Id + '">' + t.Subject + '</a> (due ' + dateNow + ')<br>';
						}
					}
				}
				tName = '';
				tNameFound = false;
			}
			
			// create the EmailQueue record
			EmailQueue__c e = new EmailQueue__c();
			e.User__c = u.Id;
			e.EmailType__c = 'Task Reminder Email';
			e.Name = u.Name + ' Tasks Notification ' + String.valueOf(System.now());
			e.To__c = u.Email;
			e.CC__c = u.EmailNotificationCC__c;
			e.Subject__c = 'Salesforce Task Reminder';
			
			//e.Body__c = '<span style=\'font-family:"Calibri","sans-serif";color:black\'>Dear ' + u.Name + ':<br><br> You have new and/or overdue tasks in Salesforce. <br><br>' + newTasks + '<br><br>' + overdueTasks + '<br><br> About this email: <br>-  This is an automated reminder, please do not reply.<br>-  This reminder is only sent if you have not logged into Salesforce recently.<br>-  If you would like to stop these notifications, please contact the InfoTeam by submitting a ticket at http://my.stand.org/help/services.</span>';
			e.Body__c = '<span style=\'font-family:"Calibri","sans-serif";color:black\'>Dear ' + u.Name;
			if ( newTasksFound == true && (overdueNotStartedFound == true || overdueWaitingFound == true || overdueInProgressFound == true) ) {
				if ( overdueNotStartedFound == true ) {
					e.Body__c = e.Body__c +  ':<br><br> You have new and overdue tasks in Salesforce. <br><br>' + overdueNotStartedTasks + '<br><br>' + newTasks + '<br><br>';
				} else if ( overdueNotStartedFound == false ) {
					e.Body__c = e.Body__c +  ':<br><br> You have new and overdue tasks in Salesforce. <br><br>' + newTasks + '<br><br>';
				} 
				if ( overdueWaitingFound == true ) {
					e.Body__c = e.Body__c + overdueWaitingTasks + '<br><br>';
				} 
				if ( overdueInProgressFound == true ) {
					e.Body__c = e.Body__c +  overdueInProgressTasks + '<br><br>';
				}
			} else if ( newTasksFound == true && (overdueNotStartedFound == false && overdueWaitingFound == false && overdueInProgressFound == false) ) {
				e.Body__c = e.Body__c +  ':<br><br> You have new tasks in Salesforce. <br><br>' + newTasks + '<br><br>';
			} else if ( newTasksFound == false && (overdueNotStartedFound == true || overdueWaitingFound == true || overdueInProgressFound == true) ) {
				e.Body__c = e.Body__c +  ':<br><br> You have overdue tasks in Salesforce. <br><br>';
				if ( overdueNotStartedFound == true ) {
					e.Body__c = e.Body__c + overdueNotStartedTasks + '<br><br>';
				}
				if ( overdueWaitingFound == true ) {
					e.Body__c = e.Body__c + overdueWaitingTasks + '<br><br>';
				} 
				if ( overdueInProgressFound == true ) {
					e.Body__c = e.Body__c +  overdueInProgressTasks + '<br><br>';
				}
//			} else if ( newTasksFound == false && (overdueNotStartedFound == false && overdueWaitingFound == false && overdueInProgressFound == false) ) {
//				break;
			}
			e.Body__c = e.Body__c + 'Visit your <a href="https://' + baseURL + '/home/home.jsp">Salesforce home page</a> to view all tasks and activities.<br><br>About this email: <br>-  This is an automated reminder, please do not reply.<br>-  This reminder is only sent if you have not logged into Salesforce recently.<br>-  If you would like to stop these notifications, please contact the InfoTeam by submitting a ticket at http://my.stand.org/help/services.</span>';
			try {
				insert e;
			} catch ( System.Exception ex ) {
				System.debug('============Unable to insert EmailQueue record=================');
				System.debug('Error Type: ' + ex.getTypeName() + ' Message: ' + ex.getMessage());
				System.debug('User: ' + u.Name);
				System.debug(System.now());
				System.debug('===============================================================');
			}
			
			newTasksFound = false;
			overdueNotStartedFound = false;	
			overdueWaitingFound = false;
			overdueInProgressFound = false;
		}
	}
	
	global void sweepEmailQueue() {
		// sweep through all EmailQueue records that have not been sent and send out the emails
		// then set the DateEmailSent__c to System.now()
		List <EmailQueue__c> eQList = new List <EmailQueue__c>([SELECT Id, To__c, CC__c, Subject__c, Body__c FROM EmailQueue__c WHERE EmailType__c = 'Task Reminder Email' AND DateEmailSent__c =: null]);
		
		// array of single emails
		List <Messaging.SingleEmailMessage> theEmails = new List <Messaging.SingleEmailMessage>();
		
		// loop through all records in eQ
		for ( EmailQueue__c e : eQList ) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List <String> toAddress = new List <String>();
			toAddress.add(e.To__c);
			mail.setToAddresses(toAddress);
			// below is for internal emails
			// however, if we add a CC to the email, it may count as an external email
			//mail.SetTargetObjectId(e.To__c)
			List <String> ccAddress = new List <String>();
			if ( e.CC__c != null ) {
				ccAddress.add(e.CC__c);
			}
			if (ccAddress.size() > 0) {
				mail.setCcAddresses(ccAddress);
			}
			mail.setReplyTo('infoteam@stand.org');
			mail.setSenderDisplayName('Salesforce Task Reminder');
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