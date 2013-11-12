// Nightly Batch job to expire Tokens on their expiration date

global class TokenExpireJob Implements Schedulable {
	
	public TokenExpireJob () {
	}

	global void execute ( schedulableContext sc) {
		tokenExpires ();
	}

	//controller class to expire Tokens
	public void tokenExpires () {
	
		//List of tokens to be expired
		List < Token__c > lapsingTokens = new List < Token__c > ();
		
		//add Tokens with expiration dates of today or earlier and a status of Active
		lapsingTokens = [SELECT ID, Expiration_Date__c, Status__c FROM Token__c WHERE Expiration_Date__c <= TODAY AND Status__c = 'Valid'];
				
		//if there are tokens to be expired, change the status for each token in the list and update the list
		if (lapsingTokens.size()> 0) {
			for (Token__c t : lapsingTokens) {
				t.Status__c = 'Expired';
			}
			update lapsingTokens;
		
		}
		
	}

}