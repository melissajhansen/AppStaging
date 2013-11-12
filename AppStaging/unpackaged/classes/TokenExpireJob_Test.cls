@isTest
private class TokenExpireJob_Test {

    static testMethod void TokenExpireTest() {
        
        Date tDate = System.TODAY ();
        
        // ------ Token -------------
        Token__c objToken = new Token__c();
        objToken.Type__c = 'MemRenewLink';
        objToken.Expiration_Date__c = tdate -366;
        objToken.Status__c = 'Valid';
        objToken.ObjectID__c = 'a0Uc0000000B56gEAC';
        insert objToken;
        objToken.Key__c = objToken.ID;
        update objToken;
        
        Token__c checkToken = [SELECT ID, ObjectID__c, Key__c FROM Token__c WHERE ID =: objToken.ID];
        
        TokenExpireJob t = new TokenExpireJob ();
        t.tokenExpires ();
        
        //reload the token and check the status
        Token__c checkToken2 = [SELECT ID, Status__c FROM Token__c WHERE ID =: objToken.ID];
        
        System.assertEquals ('Expired', checkToken2.Status__c);

		string sch = '0 0 * * 1-12 ? *';
		system.schedule('TokenExpireJob Test',sch,t);

    }
}