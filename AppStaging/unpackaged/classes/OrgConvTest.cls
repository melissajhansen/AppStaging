@isTest
private class OrgConvTest {
/*	
	 public static TestMethod void TestOrgConv()
    {
	    Profile objProfile = [Select Id from Profile where Name='Standard User'];
	    User objUser = new User();	  
	    objUser.Alias = 'TstClsU';
	    objUser.CommunityNickname = 'TstClsU';
	    objUser.Email = 'testclassuser@test.com';
	    objUser.EmailEncodingKey = 'UTF-8';
	    objUser.FirstName = 'TestClass';
	    objUser.LocaleSidKey = 'en_US';
	    objUser.LastName = 'User';
	    objUser.LanguageLocaleKey = 'en_US';
	    objUser.ProfileId = objProfile.Id;
	    objUser.TimeZoneSidKey = 'America/Los_Angeles';
	    objUser.UserName = 'testclassuser@test.com';
	    objUser.Division = 'National';
	    Insert objUser;
	 
	    System.runAs(objUser)
	    {
	    	Date dtCurrentDate1 = System.Today();
	    	
	        Account objAccount = new Account();
	        objAccount.Name = 'Test State';
	        objAccount.Type = 'Stand Affiliate State';
	        objAccount.Acquired_By__c = 'C3 Acquired';
	        objAccount.State_Abbreviation__c = 'HI';
	        Insert objAccount;
	        
			Account objAccountChapter = new Account();
			objAccountChapter.Name = 'Test Chapter';
			objAccountChapter.Type = 'Stand Chapter';
			objAccountChapter.Acquired_By__c = 'C3 Acquired';
			objAccountChapter.ParentId = objAccount.Id;
			Insert objAccountChapter;
			
			Account objAccountChapter2 = new Account();
			objAccountChapter2.Name = 'Test Chapter2';
			objAccountChapter2.Type = 'Stand Chapter';
			objAccountChapter2.Acquired_By__c = 'C3 Acquired';
			objAccountChapter2.ParentId = objAccount.Id;
			Insert objAccountChapter2;
	        
	        List<Account> tm = new List<Account>();
	        
	        Account objAccountTeamA = new Account();
	        objAccountTeamA.Name = 'Test Team A';
	        objAccountTeamA.Type = 'Stand Team';
	        objAccountTeamA.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamA.ParentId = objAccountChapter.Id;
	        objAccountTeamA.State_Abbreviation__c = 'HI';
	        objAccountTeamA.BillingState = 'HI';
	        tm.add(objAccountTeamA);
	        
	        Account objAccountTeamB = new Account();
	        objAccountTeamB.Name = 'Test Team B';
	        objAccountTeamB.Type = 'Stand Team';
	        objAccountTeamB.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamB.ParentId = objAccountChapter.Id;
	        objAccountTeamB.BillingState = 'HI';
	        objAccountTeamB.State_Abbreviation__c = 'HI';
	        tm.add(objAccountTeamB);
	        
	        Account objAccountTeamWide = new Account();
	        objAccountTeamWide.Name = 'Test Chapter Wide Team';
	        objAccountTeamWide.Type = 'Stand Team';
	        objAccountTeamWide.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamWide.ParentId = objAccountChapter.Id;
	        objAccountTeamWide.BillingState = 'HI';
	        objAccountTeamWide.State_Abbreviation__c = 'HI';
	        tm.add(objAccountTeamWide);
	        
	        Account objAccountTeamWide2 = new Account();
	        objAccountTeamWide2.Name = 'Test Chapter Wide Team2';
	        objAccountTeamWide2.Acquired_By__c = 'C3 Acquired';
	        objAccountTeamWide2.ParentId = objAccountChapter.Id;
	        objAccountTeamWide2.BillingState = 'HI';
	        objAccountTeamWide2.State_Abbreviation__c = 'HI';
	        tm.add(objAccountTeamWide2);
	        
	        insert tm;
	        
	        List<Contact> ctList = new List<Contact>();
	        
	        Contact objContactA = new Contact();
	        objContactA.FirstName = 'Test1';
	        objContactA.LastName = 'ContactA';
	        objContactA.Stand_Office__c = 'HI';
	        objContactA.Membership_State__c = 'HI';
	        ctList.add(objContactA);	   
	        
	        Contact objContactLeaderA = new Contact();
	        objContactLeaderA.FirstName = 'Test1';
	        objContactLeaderA.LastName = 'ContactLeaderA';
	        objContactLeaderA.Stand_Office__c = 'HI';
	        objContactLeaderA.Membership_State__c = 'HI';
	        objContactLeaderA.Leader_Type__c = 'Leader in Training';
	        objContactLeaderA.LiT_Start_Date__c = System.Today();
	        objContactLeaderA.Membership_Type__c = 'Annual';
	        ctList.add(objContactLeaderA);	
	        
	        Contact objContactB = new Contact();
	        objContactB.FirstName = 'Test1';
	        objContactB.LastName = 'ContactB';
	        objContactB.Stand_Office__c = 'HI';
	        objContactB.Membership_State__c = 'HI';
	        ctList.add(objContactB);	   
	        
	        Contact objContactLeaderB = new Contact();
	        objContactLeaderB.FirstName = 'Test1';
	        objContactLeaderB.LastName = 'ContactLeaderB';
	        objContactLeaderB.Stand_Office__c = 'HI';
	        objContactLeaderB.Membership_State__c = 'HI';
	        objContactLeaderB.Leader_Type__c = 'Leader in Training';
	        objContactLeaderB.LiT_Start_Date__c = System.Today();
	        objContactLeaderB.Membership_Type__c = 'Annual'; 
	        ctList.add(objContactLeaderB);	  
	        
	        Contact objContactC = new Contact();
	        objContactC.FirstName = 'Test1';
	        objContactC.LastName = 'ContactC';
	        objContactC.Stand_Office__c = 'HI';
	        objContactC.Membership_State__c = 'HI';
	        ctList.add(objContactC);	   
	        
	        Contact objContactLeaderC = new Contact();
	        objContactLeaderC.FirstName = 'Test1';
	        objContactLeaderC.LastName = 'ContactLeaderC';
	        objContactLeaderC.Stand_Office__c = 'HI';
	        objContactLeaderC.Membership_State__c = 'HI';
	        objContactLeaderC.Leader_Type__c = 'Leader in Training';
	        objContactLeaderC.LiT_Start_Date__c = System.Today();
	        objContactLeaderC.Membership_Type__c = 'Annual'; 
	        ctList.add(objContactLeaderC);	   
	        
	        Contact objContactD = new Contact();
	        objContactD.FirstName = 'Test1';
	        objContactD.LastName = 'ContactD';
	        objContactD.Stand_Office__c = 'HI';
	        objContactD.Membership_State__c = 'HI';
	        ctList.add(objContactD);
	        
	        Contact objContactE = new Contact();
	        objContactE.FirstName = 'Test1';
	        objContactE.LastName = 'ContactE';
	        objContactE.Stand_Office__c = 'HI';
	        objContactE.Membership_State__c = 'HI';
	        ctList.add(objContactE);
	        
	        Contact objContactF = new Contact();
	        objContactF.FirstName = 'Test1';
	        objContactF.LastName = 'ContactF';
	        objContactF.Stand_Office__c = 'HI';
	        objContactF.Membership_State__c = 'HI';
	        ctList.add(objContactF);
	        
	        Contact objContactG = new Contact();
	        objContactG.FirstName = 'Test1';
	        objContactG.LastName = 'ContactG';
	        objContactG.Stand_Office__c = 'HI';
	        objContactG.Membership_State__c = 'HI';
	        ctList.add(objContactG);
	        
	        Contact objContactH = new Contact();
	        objContactH.FirstName = 'Test1';
	        objContactH.LastName = 'ContactH';
	        objContactH.Stand_Office__c = 'HI';
	        objContactH.Membership_State__c = 'HI';
	        ctList.add(objContactH);
	        
	        Contact objContactI = new Contact();
	        objContactI.FirstName = 'Test1';
	        objContactI.LastName = 'ContactI';
	        objContactI.Stand_Office__c = 'HI';
	        objContactI.Membership_State__c = 'HI';	     
	        objContactI.Membership_Type__c = 'Annual';   
	        objContactI.Leader_Type__c = 'Leader in Training';
	        objContactI.LiT_Start_Date__c = dtCurrentDate1.addDays(-5);
	        ctList.add(objContactI);	        
	        
	        insert ctlist; 
	        
	        objContactB.Stand_Leader__c = objContactLeaderB.Id;
	        update objContactB;
	        
	        objContactA.Stand_Leader__c = objContactLeaderA.Id;
	        update objContactA;
	        
	        objContactI.Stand_Leader__c = objContactLeaderA.Id;
	        update objContactI;        
	        	        
	        List<Membership__c> mbList = new List<Membership__c>();
	        
	        Membership__c objMembershipA = new Membership__c();
            objMembershipA.Contact__c = objContactA.Id;
            objMembershipA.Membership_State__c = 'HI';           
            
            objMembershipA.Start_Date__c = System.Today();
            objMembershipA.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipA.Type__c = 'Annual';    
            objMembershipA.Stand_Team__c = objAccountTeamA.Id;  
            objMembershipA.Membership_Source__c = 'Web';
            objMembershipA.Membership_Action__c = 'Join';      
            mbList.add(objMembershipA);   

			Membership__c objMembershipA2 = new Membership__c();
            objMembershipA2.Contact__c = objContactLeaderA.Id;
            objMembershipA2.Membership_State__c = 'HI';            
           
            objMembershipA2.Start_Date__c = System.Today();
            objMembershipA2.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipA2.Type__c = 'Annual';            
            objMembershipA2.Stand_Team__c = objAccountTeamA.Id; 
            objMembershipA2.Membership_Source__c = 'Web';
            objMembershipA2.Membership_Action__c = 'Join';   
            mbList.add(objMembershipA2);    
            
            Membership__c objMembershipB = new Membership__c();
            objMembershipB.Contact__c = objContactB.Id;
            objMembershipB.Membership_State__c = 'HI';            
            
            objMembershipB.Start_Date__c = System.Today();
            objMembershipB.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipB.Type__c = 'Annual';       
            objMembershipB.Stand_Team__c = objAccountTeamB.Id;   
            objMembershipB.Membership_Source__c = 'Web';
            objMembershipB.Membership_Action__c = 'Join';  
            mbList.add(objMembershipB);     
            
            Membership__c objMembershipB2 = new Membership__c();
            objMembershipB2.Contact__c = objContactLeaderB.Id;
            objMembershipB2.Membership_State__c = 'HI';            
            
            objMembershipB2.Start_Date__c = System.Today();
            objMembershipB2.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipB2.Type__c = 'Annual';     
            objMembershipB2.Stand_Team__c = objAccountTeamB.Id;  
            objMembershipB2.Membership_Source__c = 'Web';
            objMembershipB2.Membership_Action__c = 'Join';      
            mbList.add(objMembershipB2);  
            
            Membership__c objMembershipC = new Membership__c();
            objMembershipC.Contact__c = objContactC.Id;
            objMembershipC.Membership_State__c = 'HI';            
            
            objMembershipC.Start_Date__c = System.Today();
            objMembershipC.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipC.Type__c = 'Annual';
            objMembershipC.Stand_Team__c = objAccountTeamA.Id; 
            objMembershipC.Membership_Source__c = 'Web';
            objMembershipC.Membership_Action__c = 'Join';            
            mbList.add(objMembershipC);     
            
            Membership__c objMembershipC2 = new Membership__c();
            objMembershipC2.Contact__c = objContactLeaderC.Id;
            objMembershipC2.Membership_State__c = 'HI';            
            
            objMembershipC2.Start_Date__c = System.Today();
            objMembershipC2.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipC2.Type__c = 'Annual';      
            objMembershipC2.Stand_Team__c = objAccountTeamB.Id; 
            objMembershipC2.Membership_Source__c = 'Web';
            objMembershipC2.Membership_Action__c = 'Join';      
            mbList.add(objMembershipC2);  
            
            Membership__c objMembershipD = new Membership__c();
            objMembershipD.Contact__c = objContactD.Id;
            objMembershipD.Membership_State__c = 'HI';            
            
            objMembershipD.Start_Date__c = System.Today();
            objMembershipD.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipD.Type__c = 'Annual';  
            objMembershipD.Stand_Team__c = objAccountTeamA.Id; 
            objMembershipD.Membership_Source__c = 'Web';
            objMembershipD.Membership_Action__c = 'Join';         
            mbList.add(objMembershipD);  
            
            Membership__c objMembershipE = new Membership__c();
            objMembershipE.Contact__c = objContactE.Id;
            objMembershipE.Membership_State__c = 'HI';            
            
            objMembershipE.Start_Date__c = System.Today();
            objMembershipE.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipE.Type__c = 'Annual';  
            objMembershipE.Stand_Team__c = objAccountTeamWide.Id; 
            objMembershipE.Membership_Source__c = 'Web';
            objMembershipE.Membership_Action__c = 'Join';         
            mbList.add(objMembershipE); 
            
            Membership__c objMembershipF = new Membership__c();
            objMembershipF.Contact__c = objContactF.Id;
            objMembershipF.Membership_State__c = 'HI';            
            
            objMembershipF.Start_Date__c = System.Today();
            objMembershipF.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipF.Type__c = 'Annual';  
            objMembershipF.Stand_Team__c = objAccountTeamA.Id; 
            objMembershipF.Membership_Source__c = 'Web';
            objMembershipF.Membership_Action__c = 'Join';         
            mbList.add(objMembershipF); 
            
            Membership__c objMembershipG = new Membership__c();
            objMembershipG.Contact__c = objContactG.Id;
            objMembershipG.Membership_State__c = 'HI';            
            
            objMembershipG.Start_Date__c = System.Today();
            objMembershipG.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipG.Type__c = 'Annual';  
            objMembershipG.Stand_Team__c = objAccountTeamA.Id; 
            objMembershipG.Membership_Source__c = 'Web';
            objMembershipG.Membership_Action__c = 'Join';         
            mbList.add(objMembershipG);
            
            Membership__c objMembershipH = new Membership__c();
            objMembershipH.Contact__c = objContactH.Id;
            objMembershipH.Membership_State__c = 'HI';            
            
            objMembershipH.Start_Date__c = System.Today();
            objMembershipH.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipH.Type__c = 'Annual';  
            objMembershipH.Stand_Team__c = objAccountTeamA.Id; 
            objMembershipH.Membership_Source__c = 'Web';
            objMembershipH.Membership_Action__c = 'Join';         
            mbList.add(objMembershipH);
            
            Membership__c objMembershipI = new Membership__c();
            objMembershipI.Contact__c = objContactI.Id;
            objMembershipI.Membership_State__c = 'HI';            
            
            objMembershipI.Start_Date__c = System.Today();
            objMembershipI.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembershipI.Type__c = 'Annual';  

            objMembershipI.Membership_Source__c = 'Web';
            objMembershipI.Membership_Action__c = 'Join';        
            mbList.add(objMembershipI);
                        
            insert mbList;   
            
            List<npe5__Affiliation__c> affList = new List<npe5__Affiliation__c>();         
            
            npe5__Affiliation__c objAffiliationContactTeamA = new npe5__Affiliation__c();
            objAffiliationContactTeamA.npe5__Contact__c = objContactLeaderA.Id;
            objAffiliationContactTeamA.npe5__Organization__c = objAccountTeamA.Id;
            objAffiliationContactTeamA.npe5__Status__c = 'Active';
            objAffiliationContactTeamA.Affiliation__c = 'Team Leader';  
            objAffiliationContactTeamA.npe5__StartDate__c = System.today();
            affList.add(objAffiliationContactTeamA);	 
            
            npe5__Affiliation__c objAffiliationContactTeamA2 = new npe5__Affiliation__c();
            objAffiliationContactTeamA2.npe5__Contact__c = objContactA.Id;
            objAffiliationContactTeamA2.npe5__Organization__c = objAccountTeamA.Id;
            objAffiliationContactTeamA2.npe5__Status__c = 'Active';   
            objAffiliationContactTeamA2.Affiliation__c = 'Team Member';   
            objAffiliationContactTeamA2.npe5__StartDate__c = System.today();
            affList.add(objAffiliationContactTeamA2);	           
            
            npe5__Affiliation__c objAffiliationContactTeamB = new npe5__Affiliation__c();
            objAffiliationContactTeamB.npe5__Contact__c = objContactB.Id;
            objAffiliationContactTeamB.npe5__Organization__c = objAccountTeamB.Id;
            objAffiliationContactTeamB.npe5__Status__c = 'Active';   
            objAffiliationContactTeamB.Affiliation__c = 'Team Member';
            objAffiliationContactTeamB.npe5__StartDate__c = System.today();
            affList.add(objAffiliationContactTeamB);	                 
        
            npe5__Affiliation__c objAffiliationContactTeamC = new npe5__Affiliation__c();
            objAffiliationContactTeamC.npe5__Contact__c = objContactLeaderC.Id;
            objAffiliationContactTeamC.npe5__Organization__c = objAccountTeamA.Id;
            objAffiliationContactTeamC.npe5__Status__c = 'Active';   
            objAffiliationContactTeamC.npe5__StartDate__c = System.today();
            affList.add(objAffiliationContactTeamC);	
            
            npe5__Affiliation__c objAffiliationContactTeamD = new npe5__Affiliation__c();
            objAffiliationContactTeamD.npe5__Contact__c = objContactD.Id;
            objAffiliationContactTeamD.npe5__Organization__c = objAccountChapter.Id;
            objAffiliationContactTeamD.npe5__Status__c = 'Inactive';   
            objAffiliationContactTeamD.Affiliation__c = 'Team Member';
            objAffiliationContactTeamD.npe5__StartDate__c = System.today();
            affList.add(objAffiliationContactTeamD);
            
            npe5__Affiliation__c objAffiliationContactF = new npe5__Affiliation__c();
            objAffiliationContactF.npe5__Contact__c = objContactD.Id;
            objAffiliationContactF.npe5__Organization__c = objAccountChapter.Id;
            objAffiliationContactF.npe5__Status__c = 'Active';   
            objAffiliationContactF.Affiliation__c = 'Chapter Contact';
            objAffiliationContactF.npe5__StartDate__c = System.today();
            affList.add(objAffiliationContactF);
            
            /*
            npe5__Affiliation__c objAffiliationContactG = new npe5__Affiliation__c();
            objAffiliationContactG.npe5__Contact__c = objContactF.Id;
            objAffiliationContactG.npe5__Organization__c = objAccountTeamA.Id;
            objAffiliationContactG.npe5__Status__c = 'Active';   
            objAffiliationContactG.Affiliation__c = 'Team Leader';
            objAffiliationContactG.npe5__StartDate__c = System.today();
            affList.add(objAffiliationContactG);
            
            npe5__Affiliation__c objAffiliationContactH = new npe5__Affiliation__c();
            objAffiliationContactH.npe5__Contact__c = objContactG.Id;
            objAffiliationContactH.npe5__Organization__c = objAccountTeamA.Id;
            objAffiliationContactH.npe5__Status__c = 'Active';   
            objAffiliationContactH.Affiliation__c = 'Team Leader';
            affList.add(objAffiliationContactH);
            */
/*            
            npe5__Affiliation__c objAffiliationContactI = new npe5__Affiliation__c();
            objAffiliationContactI.npe5__Contact__c = objContactI.Id;
            objAffiliationContactI.npe5__Organization__c = objAccountTeamA.Id;
            objAffiliationContactI.npe5__Status__c = 'Active';   
            objAffiliationContactI.Affiliation__c = 'Team Leader';
            affList.add(objAffiliationContactI);
            
            insert affList;  
	        
	        List<npe4__Relationship__c> rlList = new List<npe4__Relationship__c>();
	        
	        npe4__Relationship__c objRelationshipA = new npe4__Relationship__c ();
            objRelationshipA.npe4__Contact__c = objContactLeaderA.Id;
            objRelationshipA.npe4__RelatedContact__c = objContactA.id;
            objRelationshipA.npe4__Status__c = 'Active';
            objRelationshipA.ContactRelationship__c = 'Follower';
            objRelationshipA.Start_Date__c = System.Today();
            rlList.add(objRelationshipA);
            
            npe4__Relationship__c objRelationshipA2 = new npe4__Relationship__c ();
            objRelationshipA2.npe4__Contact__c = objContactA.Id;
            objRelationshipA2.npe4__RelatedContact__c = objContactLeaderA.id;
            objRelationshipA2.npe4__Status__c = 'Active';
            objRelationshipA2.ContactRelationship__c = 'Leader';
            objRelationshipA2.Start_Date__c = System.Today();
            rlList.add(objRelationshipA2);
            
            npe4__Relationship__c objRelationshipB = new npe4__Relationship__c ();
            objRelationshipB.npe4__Contact__c = objContactLeaderB.Id;
            objRelationshipB.npe4__RelatedContact__c = objContactB.id;
            objRelationshipB.npe4__Status__c = 'Active';
            objRelationshipB.ContactRelationship__c = 'Follower';
            objRelationshipB.Start_Date__c = System.Today();
            rlList.add(objRelationshipB);
            
            npe4__Relationship__c objRelationshipB2 = new npe4__Relationship__c ();
            objRelationshipB2.npe4__Contact__c = objContactB.Id;
            objRelationshipB2.npe4__RelatedContact__c = objContactLeaderB.id;
            objRelationshipB2.npe4__Status__c = 'Active';
            objRelationshipB2.ContactRelationship__c = 'Leader';
            objRelationshipB2.Start_Date__c = System.Today();
            rlList.add(objRelationshipB2);
            
            npe4__Relationship__c objRelationshipC = new npe4__Relationship__c ();
            objRelationshipC.npe4__Contact__c = objContactC.Id;
            objRelationshipC.npe4__RelatedContact__c = objContactLeaderC.id;
            objRelationshipC.npe4__Status__c = 'Active';
            objRelationshipC.ContactRelationship__c = 'Leader';
            objRelationshipC.Start_Date__c = System.Today();
            rlList.add(objRelationshipC);
            
            npe4__Relationship__c objRelationshipE = new npe4__Relationship__c ();
            objRelationshipE.npe4__Contact__c = objContactE.Id;
            objRelationshipE.npe4__RelatedContact__c = objContactC.id;
            objRelationshipE.npe4__Status__c = 'Active';
            objRelationshipE.Start_Date__c = System.Today();
            rlList.add(objRelationshipE);
            
            npe4__Relationship__c objRelationshipG = new npe4__Relationship__c ();
            objRelationshipG.npe4__Contact__c = objContactG.Id;
            objRelationshipG.npe4__RelatedContact__c = objContactB.id;
            objRelationshipG.npe4__Status__c = 'Active';
            objRelationshipG.ContactRelationship__c = 'Leader';
            objRelationshipG.Start_Date__c = System.Today();
            rlList.add(objRelationshipG);
            
            npe4__Relationship__c objRelationshipH = new npe4__Relationship__c ();
            objRelationshipH.npe4__Contact__c = objContactG.Id;
            objRelationshipH.npe4__RelatedContact__c = objContactLeaderB.id;
            objRelationshipH.npe4__Status__c = 'Active';
            objRelationshipH.ContactRelationship__c = 'Leader';
            objRelationshipH.Start_Date__c = System.Today();
            rlList.add(objRelationshipH);            
            
            npe4__Relationship__c objRelationshipI = new npe4__Relationship__c ();
            objRelationshipI.npe4__Contact__c = objContactG.Id;
            objRelationshipI.npe4__RelatedContact__c = objContactI.id;
            objRelationshipI.npe4__Status__c = 'Active';
            objRelationshipI.ContactRelationship__c = 'Leader';
            rlList.add(objRelationshipI);            
            
            insert rlList;                      
            
            OrgConv4 oc4 = new OrgConv4('HI', null, null, null);   
           
            oc4 = new OrgConv4('HI', 'DEBUG', null, null);  
            
            delete objAccountTeamWide;        
                        
            oc4.PrepData();            
            oc4.FixLeaders();
            oc4.FixMemberships();  
            oc4.FixContacts();       
            oc4.CommitJobResults();            
            oc4.ClearJobResultsByBatch(1);
            oc4.CleanContacts('ALL');
            oc4.UpdateStateWideAffiliations();         
            
            oc4 = new OrgConv4('HI', 'JOB', 'PREP', null);                   
            oc4 = new OrgConv4('HI', 'JOB', 'WRITE', null);          
            
            oc4.PrepData();            
            oc4.FixLeaders();
 // SKT FIX
 /*
            oc4.FixMemberships();  
 */
 /*
            oc4.FixContacts();        
            oc4.CommitJobResults();            
            oc4.ClearJobResultsByBatch(1);
            
            oc4 = new OrgConv4('HI', 'JOB', 'PREP', 1);
            oc4 = new OrgConv4('HI', null, 'PREP', null);                     
        	        
	    }
    }
*/
}