global class StandException extends Exception {
	
	global integer errorCode {get; set;}
	
	global StandException(Integer code) {
		this.errorCode = code;
		
		//Load Exceptions and 
		list <Exceptions__c> exc = Exceptions__c.getAll().values();
		for (Exceptions__c e:exc) {
			if (e.Exception_Code__c == code) {
				this.setMessage(UserInfo.getFirstName()+ ', ' + e.Exception_Message__c);
				if (e.Log_Exception__c) {
					this.writeToLog();
				}
				if (e.Send_Notification_Email__c) {
					this.emailNotification(e.Notification_Email_Address__c);
				}
			}
		} 
	}
	
	private void emailNotification (string emailAddress) {

    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	//TODO:  When moved to Production, change address to helpdesk@stand.org
    	String[] toAddresses = new String[]{};
    	if (emailAddress != null) {
    		toAddresses.add(emailAddress);
    	} else {
    		toAddresses.add('sfdev@stand.org');
    	}
    	
    	mail.setToAddresses(toAddresses);
    	mail.setReplyTo('developer@stand.org');
    	mail.setSenderDisplayName('APEX Error Message');
    	mail.setSubject('Error from Org: '+UserInfo.getORganizationName()+' '+this.errorCode);
    	mail.setHtmlBody('<b>Error Code:  </b>'+this.errorCode + '<br><br>'+'<b>Error Message:  </b>'+ this.getMessage()+ '<br><br>'+'<b>StackTrace: </b>'+this.getStackTraceString()+'<br><br><b>User: </b>'+UserInfo.getUserName());
    	Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
		
	}
	
	private void writeToLog() {
		Log__c errorLog = new Log__c();
		
		errorLog.Name = 'Stand Custom Exception ' +this.errorCode;
		errorLog.Type__c = 'Custom Exception';
		errorLog.Fail_Code__c = String.ValueOf(this.errorCode);
		errorLog.Result__c = this.getMessage();
		errorLog.Result_Message__c = this.getStackTraceString();
		errorLog.Running_User__c = UserInfo.getUserId();
		errorLog.Date_of_Request__c = System.now();
		
		insert errorLog;
		
	}
}