@isTest
private class UserStatsTest
{
    public static TestMethod void TestShowUserStatsShowMembers()
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
        objUser.UserName = 'UseStaTestShowUserStatsShowMembers@test.com';
        objUser.Division = 'National';
        insert objUser;

        System.runAs(objUser)
        {
            Contact objContact = new Contact();
            objContact.FirstName = 'Test';
            objContact.LastName = 'User';
            objContact.Stand_Employee_User__c = objUser.Id;
            Insert objContact;
            
            Apexpages.StandardController stdController = new Apexpages.StandardController(objContact);
            
            // ------ STATE -------------
            Account objAccount = new Account();
            objAccount.Name = 'Test State';
            objAccount.Type = 'Stand Affiliate State';
            objAccount.Acquired_By__c = 'C3 Acquired';
            objAccount.BillingState = 'HI';
            objAccount.State_Abbreviation__c = 'HI';
            Insert objAccount;
            
            // ------ Chapter 1 -------------
            Account objAccountChapter1 = new Account();
            objAccountChapter1.Name = 'Test Chapter1';
            objAccountChapter1.Type = 'Stand Chapter';
            objAccountChapter1.Acquired_By__c = 'C3 Acquired';
            objAccountChapter1.ParentId = objAccount.Id;
            objAccountChapter1.BillingState = 'HI';
            objAccountChapter1.State_Abbreviation__c = 'HI';
            Insert objAccountChapter1;
            
            // ------ Chapter 2 -------------
            Account objAccountChapter2 = new Account();
            objAccountChapter2.Name = 'Test Chapter2';
            objAccountChapter2.Type = 'Stand Chapter';
            objAccountChapter2.Acquired_By__c = 'C3 Acquired';
            objAccountChapter2.ParentId = objAccount.Id;
            objAccountChapter2.BillingState = 'HI';
            objAccountChapter2.State_Abbreviation__c = 'HI';
            Insert objAccountChapter2;
            
            // ------ Team 1-1 -------------
            Account objAccountTeam11 = new Account();
            objAccountTeam11.Name = 'Test Team11';
            objAccountTeam11.Type = 'Stand Team';
            objAccountTeam11.Acquired_By__c = 'C3 Acquired';
            objAccountTeam11.ParentId = objAccountChapter1.Id;
            objAccountTeam11.BillingState = 'HI';
            objAccountTeam11.State_Abbreviation__c = 'HI';
            Insert objAccountTeam11;
            
            // ------ Team 1-2 -------------
            Account objAccountTeam12 = new Account();
            objAccountTeam12.Name = 'Test Team12';
            objAccountTeam12.Type = 'Stand Team';
            objAccountTeam12.Acquired_By__c = 'C3 Acquired';
            objAccountTeam12.ParentId = objAccountChapter1.Id;
            objAccountTeam12.BillingState = 'HI';
            objAccountTeam12.State_Abbreviation__c = 'HI';
            Insert objAccountTeam12;
            
            // ------ Team 2-1 -------------
            Account objAccountTeam21 = new Account();
            objAccountTeam21.Name = 'Test Team21';
            objAccountTeam21.Type = 'Stand Team';
            objAccountTeam21.Acquired_By__c = 'C3 Acquired';
            objAccountTeam21.ParentId = objAccountChapter2.Id;
            objAccountTeam21.BillingState = 'HI';
            objAccountTeam21.State_Abbreviation__c = 'HI';
            Insert objAccountTeam21;
            
            // ------ Team 2-2 -------------
            Account objAccountTeam22 = new Account();
            objAccountTeam22.Name = 'Test Team22';
            objAccountTeam22.Type = 'Stand Team';
            objAccountTeam22.Acquired_By__c = 'C3 Acquired';
            objAccountTeam22.ParentId = objAccountChapter2.Id;
            objAccountTeam22.BillingState = 'HI';
            objAccountTeam22.State_Abbreviation__c = 'HI';
            Insert objAccountTeam22;
            
            List<Contact> ctList = new List<Contact>();
            
            // ------ Contact 1 -------------
            Contact objContactChapter1 = new Contact();
            objContactChapter1.FirstName = 'Chapter1Test';
            objContactChapter1.LastName = 'Contact Chapter1';
            objContactChapter1.Stand_Office__c = 'HI';
            objContactChapter1.Stand_Chapter_Affiliation__c = objAccountChapter1.Id;
            ctList.add(objContactChapter1);
            
            Contact objContactChapter2 = new Contact();
            objContactChapter2.FirstName = 'Chapter2Test';
            objContactChapter2.LastName = 'Contact Chapter2';
            objContactChapter2.Stand_Office__c = 'HI';
            objContactChapter2.Stand_Chapter_Affiliation__c = objAccountChapter2.Id;
            ctList.add(objContactChapter2);
            
            Contact objContactTeam11 = new Contact();
            objContactTeam11.FirstName = 'Team11Test';
            objContactTeam11.LastName = 'Contact Team11';
            objContactTeam11.Stand_Office__c = 'HI';
            objContactChapter1.Stand_Chapter_Affiliation__c = objAccountChapter1.Id;
            objContactChapter1.Stand_Team_Affiliation__c = objAccountTeam11.Id;            
            ctList.add(objContactTeam11);
            
            Contact objContactTeam12 = new Contact();
            objContactTeam12.FirstName = 'Team12Test';
            objContactTeam12.LastName = 'Contact Team12';
            objContactTeam12.Stand_Office__c = 'HI';
            objContactTeam12.Stand_Chapter_Affiliation__c = objAccountChapter1.Id;
            objContactTeam12.Stand_Team_Affiliation__c = objAccountTeam12.Id;            
            ctList.add(objContactTeam12);
            
            Contact objContactTeam21 = new Contact();
            objContactTeam21.FirstName = 'Team21Test';
            objContactTeam21.LastName = 'Contact Team21';
            objContactTeam21.Stand_Office__c = 'HI';
            objContactTeam21.Stand_Chapter_Affiliation__c = objAccountChapter2.Id;
            objContactTeam21.Stand_Team_Affiliation__c = objAccountTeam21.Id;            
            ctList.add(objContactTeam21);
            
            Contact objContactTeam22 = new Contact();
            objContactTeam22.FirstName = 'Team22Test';
            objContactTeam22.LastName = 'Leader Team22';
            objContactTeam22.Stand_Office__c = 'HI';
            objContactTeam22.Stand_Chapter_Affiliation__c = objAccountChapter2.Id;
            objContactTeam22.Stand_Team_Affiliation__c = objAccountTeam22.Id;       
            objContactTeam22.Membership_Type__c = 'Annual';
            objContactTeam22.LiT_Start_Date__c = System.Today();
	        objContactTeam22.Leader_Type__c = 'Leader in Training';
	        objContactTeam22.Membership_State__c = 'HI';     
            ctList.add(objContactTeam22);
            
            insert ctList;
            
            List<Membership__c> mbList = new List<Membership__c>();
            
            Membership__c objMembership1 = new Membership__c();
            objMembership1.Contact__c = objContactChapter1.Id;
            objMembership1.Membership_State__c = 'HI';
            Date dtCurrentDate1 = System.Today();
            objMembership1.RE_Drop_Date__c = dtCurrentDate1.addDays(365);
            objMembership1.Quit_Date__c = dtCurrentDate1.addDays(365);
            objMembership1.Start_Date__c = System.Today();
            objMembership1.Type__c = 'Annual';
            objMembership1.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership1);
            
            Membership__c objMembership2 = new Membership__c();
            objMembership2.Contact__c = objContactChapter2.Id;
            objMembership2.Membership_State__c = 'HI';
            Date dtCurrentDate2 = System.Today();
            objMembership2.RE_Drop_Date__c = dtCurrentDate2.addDays(365);
            objMembership2.Quit_Date__c = dtCurrentDate2.addDays(365);
            objMembership2.Start_Date__c = System.Today();
            objMembership2.Type__c = 'Annual';
            objMembership2.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership2);
            
            Membership__c objMembership11 = new Membership__c();
            objMembership11.Contact__c = objContactTeam11.Id;
            objMembership11.Membership_State__c = 'HI';
            Date dtCurrentDate11 = System.Today();
            objMembership11.RE_Drop_Date__c = dtCurrentDate11.addDays(365);
            objMembership11.Quit_Date__c = dtCurrentDate11.addDays(365);
            objMembership11.Start_Date__c = System.Today();
            objMembership11.Type__c = 'Annual';
            objMembership11.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership11);
            
            Membership__c objMembership12 = new Membership__c();
            objMembership12.Contact__c = objContactTeam12.Id;
            objMembership12.Membership_State__c = 'HI';
            Date dtCurrentDate12 = System.Today();
            objMembership12.RE_Drop_Date__c = dtCurrentDate12.addDays(365);
            objMembership12.Quit_Date__c = dtCurrentDate12.addDays(365);
            objMembership12.Start_Date__c = System.Today();
            objMembership12.Type__c = 'Annual';
            objMembership12.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership12);
            
            Membership__c objMembership21 = new Membership__c();
            objMembership21.Contact__c = objContactTeam21.Id;
            objMembership21.Membership_State__c = 'HI';
            Date dtCurrentDate21 = System.Today();
            objMembership21.RE_Drop_Date__c = dtCurrentDate21.addDays(365);
            objMembership21.Quit_Date__c = dtCurrentDate21.addDays(365);
            objMembership21.Start_Date__c = System.Today();
            objMembership21.Type__c = 'Annual';
            objMembership21.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership21);
            
            Membership__c objMembership22 = new Membership__c();
            objMembership22.Contact__c = objContactTeam22.Id;
            objMembership22.Membership_State__c = 'HI';
            Date dtCurrentDate22 = System.Today();
            objMembership22.RE_Drop_Date__c = dtCurrentDate22.addDays(365);
            objMembership22.Quit_Date__c = dtCurrentDate22.addDays(365);
            objMembership22.Start_Date__c = System.Today();
            objMembership22.Type__c = 'Annual';
            objMembership22.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership22);
            
            insert mbList;  
            
            List<npe5__Affiliation__c> affList = new List<npe5__Affiliation__c>();
            
            npe5__Affiliation__c objAffiliationContactChapter1 = new npe5__Affiliation__c();
            objAffiliationContactChapter1.npe5__Contact__c = objContactChapter1.Id;
            objAffiliationContactChapter1.npe5__Organization__c = objAccountChapter1.Id;
            objAffiliationContactChapter1.npe5__Status__c = 'Active';
            objAffiliationContactChapter1.Affiliation__c = 'Chapter Contact';
            affList.add(objAffiliationContactChapter1);                      
            
            npe5__Affiliation__c objAffiliationContactChapter2 = new npe5__Affiliation__c();
            objAffiliationContactChapter2.npe5__Contact__c = objContactChapter2.Id;
            objAffiliationContactChapter2.npe5__Organization__c = objAccountChapter2.Id;
            objAffiliationContactChapter2.npe5__Status__c = 'Active';
            objAffiliationContactChapter2.Affiliation__c = 'Chapter Contact';
            affList.add(objAffiliationContactChapter2);
            
            npe5__Affiliation__c objAffiliationContactTeam11 = new npe5__Affiliation__c();
            objAffiliationContactTeam11.npe5__Contact__c = objContactTeam11.Id;
            objAffiliationContactTeam11.npe5__Organization__c = objAccountTeam11.Id;
            objAffiliationContactTeam11.npe5__Status__c = 'Active';
            objAffiliationContactTeam11.Affiliation__c = 'Team Member';
            affList.add(objAffiliationContactTeam11);
            
            npe5__Affiliation__c objAffiliationContactChapter11 = new npe5__Affiliation__c();
            objAffiliationContactChapter11.npe5__Contact__c = objContactTeam11.Id;
            objAffiliationContactChapter11.npe5__Organization__c = objAccountChapter1.Id;
            objAffiliationContactChapter11.npe5__Status__c = 'Active';
            objAffiliationContactChapter11.Affiliation__c = 'Chapter Contact';
            affList.add(objAffiliationContactChapter11);                         
            
            npe5__Affiliation__c objAffiliationContactTeam12 = new npe5__Affiliation__c();
            objAffiliationContactTeam12.npe5__Contact__c = objContactTeam12.Id;
            objAffiliationContactTeam12.npe5__Organization__c = objAccountTeam12.Id;
            objAffiliationContactTeam12.npe5__Status__c = 'Active';
            objAffiliationContactTeam12.Affiliation__c = 'Team Member';
            affList.add(objAffiliationContactTeam12);
     
            npe5__Affiliation__c objAffiliationContactChapter12 = new npe5__Affiliation__c();
            objAffiliationContactChapter12.npe5__Contact__c = objContactTeam12.Id;
            objAffiliationContactChapter12.npe5__Organization__c = objAccountChapter1.Id;
            objAffiliationContactChapter12.npe5__Status__c = 'Active';
            objAffiliationContactChapter12.Affiliation__c = 'Chapter Contact';
            affList.add(objAffiliationContactChapter12);
         
            npe5__Affiliation__c objAffiliationContactTeam21 = new npe5__Affiliation__c();
            objAffiliationContactTeam21.npe5__Contact__c = objContactTeam21.Id;
            objAffiliationContactTeam21.npe5__Organization__c = objAccountTeam21.Id;
            objAffiliationContactTeam21.npe5__Status__c = 'Active';
            objAffiliationContactTeam21.Affiliation__c = 'Team Member';
            Insert objAffiliationContactTeam21;
            
            npe5__Affiliation__c objAffiliationContactChapter21 = new npe5__Affiliation__c();
            objAffiliationContactChapter21.npe5__Contact__c = objContactTeam21.Id;
            objAffiliationContactChapter21.npe5__Organization__c = objAccountChapter2.Id;
            objAffiliationContactChapter21.npe5__Status__c = 'Active';
            objAffiliationContactChapter21.Affiliation__c = 'Chapter Contact';
            affList.add(objAffiliationContactChapter21);       
         
            npe5__Affiliation__c objAffiliationContactTeam22 = new npe5__Affiliation__c();
            objAffiliationContactTeam22.npe5__Contact__c = objContactTeam22.Id;
            objAffiliationContactTeam22.npe5__Organization__c = objAccountTeam22.Id;
            objAffiliationContactTeam22.npe5__Status__c = 'Active';
            objAffiliationContactTeam22.Affiliation__c = 'Team Leader';
            affList.add(objAffiliationContactTeam22);
          
            npe5__Affiliation__c objAffiliationContactChapter22 = new npe5__Affiliation__c();
            objAffiliationContactChapter22.npe5__Contact__c = objContactTeam22.Id;
            objAffiliationContactChapter22.npe5__Organization__c = objAccountChapter2.Id;
            objAffiliationContactChapter22.npe5__Status__c = 'Active';
            objAffiliationContactChapter22.Affiliation__c = 'Chapter Contact';
            affList.add(objAffiliationContactChapter22);    
         
            insert affList;       
           	

/*            // ------ Contact Unassigned-Unassigned -------------
            Contact objContactTeamUU = new Contact();
            objContactTeamUU.FirstName = 'Test';
            objContactTeamUU.LastName = 'Unassigned';
            objContactTeamUU.Stand_Office__c = 'HI';
            
            Insert objContactTeamUU;
            
            System.Debug('objContactTeamUU.id = ' + objContactTeamUU.Id);
            
           	Membership__c objMembershipUU = new Membership__c();
            objMembershipUU.Contact__c = objContactTeamUU.Id;
            objMembershipUU.Membership_State__c = 'HI';
            Date dtCurrentDateUU = System.Today();
            objMembershipUU.RE_Drop_Date__c = dtCurrentDateUU.addDays(365);
            objMembershipUU.Quit_Date__c = dtCurrentDateUU.addDays(365);
            objMembershipUU.Start_Date__c = System.Today();
            Insert objMembershipUU;
*/


            // Start Tests
            UserStats objUserStats = new UserStats(stdController);
//            System.AssertEquals(objUserStats.lstUserStatDetails[0].strAccountId, objAccount.Id);
//            System.AssertEquals(objUserStats.lstUserStatDetails[0].strAccountName, objAccount.Name);
//            System.AssertEquals(objUserStats.lstUserStatDetails[0].strRole, objAffiliation.Affiliation__c);
//            System.AssertEquals(objUserStats.lstUserStatDetails[0].intNumMembers, 1);
            
            List<selectOption> lstStates = objUserStats.getStateNames;
            objUserStats.strStateId = lstStates[1].getValue();
   //         System.AssertEquals(objUserStats.strStateId, objAccount.Id );
   //         System.AssertEquals(lstStates.size(), 2);
            
            List<selectOption> lstChapters = objUserStats.getChapterNames;
   //         System.AssertEquals(lstChapters.size(), 4);
            if (lstStates.size() > 1)
            {
            	
                
                // load first chapter
                lstChapters = objUserStats.getChapterNames;
    //            System.AssertEquals(lstChapters.size(), 4);
                objUserStats.strChapterId = lstChapters[1].getValue();
                
                List<selectOption> lstTeams = objUserStats.getTeamNames;
  //              System.AssertEquals(lstTeams.size(), 4);
                
                if (lstChapters.size() > 1)
                {
                	// test for Chapter 1, no team selection
                    objUserStats.strChapterId = lstChapters[1].getValue();
                    objUserStats.strTeamId = 'All';
//                    System.AssertEquals(objUserStats.strChapterId, objAccountChapter1.Id);
                    
                    objUserStats.ShowMembers();

//                    System.AssertEquals(objUserStats.ContactDisplay.size(), 3);

					// test for chapter 1, team = all                    
                    lstTeams = objUserStats.getTeamNames;
 //                   System.AssertEquals(lstTeams.size(), 4);
                    objUserStats.strTeamId = lstTeams[0].getValue();
 //                   System.AssertEquals(objUserStats.strTeamId, 'All');
                    
                    objUserStats.ShowMembers();

 //                   System.AssertEquals(objUserStats.ContactDisplay.size(), 3); 

                    if (lstTeams.size() > 1)
                    {
 
 
                    	// test for chapter 1, team 1
                        objUserStats.strTeamId = lstTeams[1].getValue();
                        System.AssertEquals(objUserStats.strTeamId, objAccountTeam11.Id);
                        objUserStats.ShowMembers();
                        System.AssertEquals(objUserStats.ContactDisplay.size(), 0); 
  
                    }
                }
 
                System.AssertEquals(objUserStats.strStateId, objAccount.Id);
                System.AssertEquals(objUserStats.strChapterId, objAccountChapter1.Id);
                System.AssertEquals(objUserStats.strTeamId, objAccountTeam11.Id);
                
                //rlb
                // load Unassigned chapter
                //lstChapters = objUserStats.getChapterNames;
                //System.AssertEquals(lstChapters.size(), 4);
                //objUserStats.strChapterId = lstChapters[4].getValue();
                
//                List<selectOption> lstTeams = objUserStats.getTeamNames;
//                System.AssertEquals(lstTeams.size(), 2);
                
                if (lstChapters.size() > 1)
                {
                	// test for Unassigned Chapter 1, no team selection
                    objUserStats.strChapterId = 'none';
                    objUserStats.strTeamId = 'none';
                    System.AssertEquals(objUserStats.strChapterId, 'none');
                    
                    objUserStats.ShowMembers();
                    System.AssertEquals(objUserStats.ContactDisplay.size(), 0);

					// test for Unassigned chapter, unassigned team                    
                    lstTeams = objUserStats.getTeamNames;
 //                   System.AssertEquals(lstTeams.size(), 4);
//                    objUserStats.strTeamId = lstTeams[4].getValue();
                    System.AssertEquals(objUserStats.strTeamId, 'none');
                    
                    objUserStats.ShowMembers();
 //                   System.AssertEquals(objUserStats.ContactDisplay.size(), 1); 
                    
//                    if (lstTeams.size() > 1)
//                    {
//                    	// test for chapter 1, team 1
//                        objUserStats.strTeamId = lstTeams[1].getValue();
//                        System.AssertEquals(objUserStats.strTeamId, objAccountTeam11.Id);
//                        objUserStats.ShowMembers();
//                        System.AssertEquals(objUserStats.ContactDisplay.size(), 1); 
//                    }
                }
//                System.AssertEquals(objUserStats.strStateId, objAccount.Id);
//                System.AssertEquals(objUserStats.strChapterId, objAccountChapter1.Id);
//                System.AssertEquals(objUserStats.strTeamId, objAccountTeam11.Id);
                
                
	            objUserStats.pageNumber = 0;
    	        //objUserStats.skipToPage();
                
                objUserStats.DownloadMembers();
                
                objUserStats.SortMembers();
                
                objUserStats.PrintMembers();
               
/*                objUserStats.strSortField = 'objContact.strName';
                objUserStats.LoadMembers('screen');

                objUserStats.strSortField = 'objContact.strPrefEmail';
                objUserStats.LoadMembers('screen');

                objUserStats.strSortField = 'objContact.strPrefPhone';
                objUserStats.LoadMembers('screen');

                objUserStats.strSortField = 'objContact.strMobilePhone';
                objUserStats.LoadMembers('screen');

                objUserStats.strSortField = 'objContact.strMembershipStatus';
                objUserStats.LoadMembers('screen');

                objUserStats.strSortField = 'objContact.strMembershipTeam';
                objUserStats.LoadMembers('screen');

                objUserStats.strSortField = 'objContact.strLeaderContactName';
                objUserStats.LoadMembers('screen');
*/
                objUserStats.strChapterId = lstChapters[0].getValue();
                lstTeams = objUserStats.getTeamNames;
                objUserStats.ResetTeam();
                
                objUserStats.strStateId = lstStates[0].getValue();
                lstChapters = objUserStats.getChapterNames;
                objUserStats.ResetChapterTeam();
                
                //objUserStats.ShowMembers();
                //System.AssertEquals(objUserStats.ContactDisplay.size(), 0);
                //objUserStats.DownloadMembers();
            }
            
            objUser.Division = 'HI';
	        Update objUser;
	        
	        System.runAs(objUser)
	        {
	        	Contact objContact2 = new Contact();
	            objContact2.FirstName = 'Test';
	            objContact2.LastName = 'User';
	            objContact2.Stand_Employee_User__c = objUser.Id;
	            Insert objContact2;
	            
	            Apexpages.StandardController stdController2 = new Apexpages.StandardController(objContact2);
	        	UserStats objUserStats2 = new UserStats(stdController2);
	        	
	        	objUserStats2.strChapterId = 'none';
	        	objUserStats2.strTeamId = 'none';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	
	        	objUserStats2.strSortDirection = 'ASC';
	        	objUserStats2.strSortField = 'objContact.strName';
	        	objUserStats2.PrepareLoadMembers('screen');       
	        	objUserStats2.strSortField = 'objContact.strPrefEmail';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	objUserStats2.strSortField = 'objContact.strPrefPhone';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	objUserStats2.strSortField = 'objContact.strMobilePhone';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	objUserStats2.strSortField = 'objContact.strMembershipStatus';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	objUserStats2.strSortField = 'objContact.strMembershipTeam';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	objUserStats2.strSortField = 'objContact.strLeaderContactName';
	        	objUserStats2.PrepareLoadMembers('screen');       
	        	
	        	objUserStats2.blnSingleState = true;  
	        	List<selectOption> lstStates2 = objUserStats2.getStateNames;   	
	        	
	        	objUserStats2.strChapterId = objUserStats.strChapterId;
	        	objUserStats2.PrepareLoadMembers('screen');
	        	
	        	objUserStats2.strTeamId = 'ALL';
	        	objUserStats2.strChapterId = 'none';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	
	        	UserStats.ContactDetails uc = new UserStats.ContactDetails ();
	        	uc.strPrefEmail = '⬚⬚';
	        	boolean aa = uc.emailIsScrambled;
	        	uc.strPrefEmail = 'aa';
	        	aa = uc.emailIsScrambled;
	        	uc.strPrefEmail = null;
	        	aa = uc.emailIsScrambled;        	
	        	        	
	        }
        }
    }
    
    
    public static TestMethod void TestNewUserStats()
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
        objUser.UserName = 'UseStaTestNewUserStats@test.com';
        objUser.Division = 'National';
        insert objUser;

        System.runAs(objUser)
        {
            Contact objContact = new Contact();
            objContact.FirstName = 'Test';
            objContact.LastName = 'User';
            objContact.Stand_Employee_User__c = objUser.Id;
            Insert objContact;
            
            Apexpages.StandardController stdController = new Apexpages.StandardController(objContact);
            
            // ------ STATE -------------
	        Account objAccount = new Account();
	        objAccount.Name = 'Test State';
	        objAccount.Type = 'Stand Affiliate State';
	        objAccount.Acquired_By__c = 'C3 Acquired';
	        objAccount.BillingState = 'HI';
	        objAccount.State_Abbreviation__c = 'HI';
	        Insert objAccount;
	        
			  // ------ Chapter -------------
			Account objAccountChapter = new Account();
			objAccountChapter.Name = 'Test Chapter';
			objAccountChapter.Type = 'Stand Chapter';
			objAccountChapter.Acquired_By__c = 'C3 Acquired';
			objAccountChapter.ParentId = objAccount.Id;
			objAccountChapter.BillingState = 'HI';
			objAccountChapter.State_Abbreviation__c = 'HI';
			Insert objAccountChapter;
	        
	        // ------ Team -------------
	        Account objAccountTeam = new Account();
	        objAccountTeam.Name = 'Test Team';
	        objAccountTeam.Type = 'Stand Team';
	        objAccountTeam.Acquired_By__c = 'C3 Acquired';
	        objAccountTeam.ParentId = objAccountChapter.Id;
	        objAccountTeam.State_Abbreviation__c = 'HI';
	        objAccountTeam.BillingState = 'HI';
	        Insert objAccountTeam;
            
            List<Contact> ctList = new List<Contact>();
            
            // ------ Contact 1 -------------
            Contact objContactChapter1 = new Contact();
            objContactChapter1.FirstName = 'Chapter1Test';
            objContactChapter1.LastName = 'Contact Chapter1';
            objContactChapter1.Stand_Office__c = 'HI';
            objContactChapter1.Stand_Chapter_Affiliation__c = objAccountChapter.Id;
            objContactChapter1.Stand_Team_Affiliation__c = objAccountTeam.Id; 
            objContactChapter1.Membership_State__c = 'HI'; 
            objContactChapter1.Phone = '1234567890';
            objContactChapter1.MobilePhone = '1234567890';
            objContactChapter1.HomePhone = '1234567890';
            objContactChapter1.OtherPhone = '1234567890';
            ctList.add(objContactChapter1);
            
            Contact objContactChapter2 = new Contact();
            objContactChapter2.FirstName = 'Chapter2Test';
            objContactChapter2.LastName = 'Contact Chapter2';
            objContactChapter2.Stand_Office__c = 'HI';
            objContactChapter2.Stand_Chapter_Affiliation__c = objAccountChapter.Id;
            objContactChapter2.Stand_Team_Affiliation__c = objAccountTeam.Id; 
            objContactChapter2.Membership_State__c = 'HI'; 
            objContactChapter2.Phone = '1234567890';
            objContactChapter2.MobilePhone = '1234567890';
            objContactChapter2.HomePhone = '1234567890';
            objContactChapter2.OtherPhone = '1234567890';
            ctList.add(objContactChapter2);
            
            Contact objContactTeam11 = new Contact();
            objContactTeam11.FirstName = 'Team11Test';
            objContactTeam11.LastName = 'Contact Team11';
            objContactTeam11.Stand_Office__c = 'HI';
            objContactTeam11.Stand_Chapter_Affiliation__c = objAccountChapter.Id;
            objContactTeam11.Stand_Team_Affiliation__c = objAccountTeam.Id;   
            objContactTeam11.Membership_State__c = 'HI';     
            objContactTeam11.Phone = '1234567890';
            objContactTeam11.MobilePhone = '1234567890';
            objContactTeam11.HomePhone = '1234567890';
            objContactTeam11.OtherPhone = '1234567890';     
            ctList.add(objContactTeam11);
            
            Contact objContactTeam12 = new Contact();
            objContactTeam12.FirstName = 'Team12Test';
            objContactTeam12.LastName = 'Contact Team12';
            objContactTeam12.Stand_Office__c = 'HI';
            objContactTeam12.Stand_Chapter_Affiliation__c = objAccountChapter.Id;
            objContactTeam12.Stand_Team_Affiliation__c = objAccountTeam.Id; 
            objContactTeam12.Membership_State__c = 'HI';        
            objContactTeam12.Phone = '1234567890';
            objContactTeam12.MobilePhone = '1234567890';
            objContactTeam12.HomePhone = '1234567890';
            objContactTeam12.OtherPhone = '1234567890';    
            ctList.add(objContactTeam12);
            
            Contact objContactTeam21 = new Contact();
            objContactTeam21.FirstName = 'Team21Test';
            objContactTeam21.LastName = 'Contact Team21';
            objContactTeam21.Stand_Office__c = 'HI';
            objContactTeam21.Stand_Chapter_Affiliation__c = objAccountChapter.Id;
            objContactTeam21.Stand_Team_Affiliation__c = objAccountTeam.Id;   
            objContactTeam21.Phone = '1234567890';
            objContactTeam21.MobilePhone = '1234567890';
            objContactTeam21.HomePhone = '1234567890';
            objContactTeam21.OtherPhone = '1234567890'; 
            objContactTeam21.Membership_State__c = 'HI';         
            ctList.add(objContactTeam21);
            
            Contact objContactTeam22 = new Contact();
            objContactTeam22.FirstName = 'Team22Test';
            objContactTeam22.LastName = 'Leader Team22';
            objContactTeam22.Stand_Office__c = 'HI';
            objContactTeam22.Stand_Chapter_Affiliation__c = objAccountChapter.Id;
            objContactTeam22.Stand_Team_Affiliation__c = objAccountTeam.Id;       
            objContactTeam22.Membership_Type__c = 'Annual';
            objContactTeam22.LiT_Start_Date__c = System.Today();
	        objContactTeam22.Leader_Type__c = 'Leader in Training';
	        objContactTeam22.Phone = '1234567890';
            objContactTeam22.MobilePhone = '1234567890';
            objContactTeam22.HomePhone = '1234567890';
            objContactTeam22.OtherPhone = '1234567890';
	        objContactTeam22.Membership_State__c = 'HI';     
            ctList.add(objContactTeam22);
            
            Contact objContactTeam33 = new Contact();
            objContactTeam33.FirstName = 'Team33Test';
            objContactTeam33.LastName = 'Contact Team33';
            objContactTeam33.Stand_Office__c = 'HI';
            objContactTeam33.Stand_Chapter_Affiliation__c = objAccountChapter.Id;
            objContactTeam33.Stand_Team_Affiliation__c = objAccountTeam.Id;  
            objContactTeam33.Do_Not_Text__c = true;   
            objContactTeam33.Do_Not_Mail__c = true;   
            objContactTeam33.DoNotCall = true;  
            objContactTeam33.Do_Not_Contact__c = 'test';  
            objContactTeam33.Membership_State__c = 'HI';  
            objContactTeam33.Phone = '1234567890';
            objContactTeam33.MobilePhone = '1234567890';
            objContactTeam33.HomePhone = '1234567890';
            objContactTeam33.OtherPhone = '1234567890';  
            ctList.add(objContactTeam33);
            
            Contact objContactTeam44 = new Contact();
            objContactTeam44.FirstName = 'Team44Test';
            objContactTeam44.LastName = 'Contact Team44';
            objContactTeam44.Stand_Office__c = 'HI';
            objContactTeam44.Stand_Chapter_Affiliation__c = objAccountChapter.Id;
            objContactTeam44.Stand_Team_Affiliation__c = objAccountTeam.Id; 
            objContactTeam44.HasOptedOutOfEmail = true;    
            objContactTeam44.Phone = '1234567890';
            objContactTeam44.MobilePhone = '1234567890';
            objContactTeam44.HomePhone = '1234567890';
            objContactTeam44.OtherPhone = '1234567890';
            objContactTeam44.Membership_State__c = 'HI';        
            ctList.add(objContactTeam44);
            
            insert ctList;
            
            List<Membership__c> mbList = new List<Membership__c>();
            
            Date dtCurrentDate1 = System.Today();
            
            Membership__c objMembership1 = new Membership__c();
            objMembership1.Contact__c = objContactChapter1.Id;
            objMembership1.Membership_State__c = 'HI';                
            objMembership1.Start_Date__c = System.Today();
            objMembership1.Type__c = 'Annual';
            objMembership1.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership1);
            
            Membership__c objMembership2 = new Membership__c();
            objMembership2.Contact__c = objContactChapter2.Id;
            objMembership2.Membership_State__c = 'HI'; 
            objMembership2.Start_Date__c = System.Today();
            objMembership2.Type__c = 'Annual';
            objMembership2.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership2);
            
            Membership__c objMembership11 = new Membership__c();
            objMembership11.Contact__c = objContactTeam11.Id;
            objMembership11.Membership_State__c = 'HI';            
            objMembership11.Start_Date__c = System.Today();
            objMembership11.Type__c = 'Annual';
            objMembership11.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership11);
            
            Membership__c objMembership12 = new Membership__c();
            objMembership12.Contact__c = objContactTeam12.Id;
            objMembership12.Membership_State__c = 'HI';            
            objMembership12.Start_Date__c = System.Today();
            objMembership12.Type__c = 'Annual';
            objMembership12.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership12);
            
            Membership__c objMembership21 = new Membership__c();
            objMembership21.Contact__c = objContactTeam21.Id;
            objMembership21.Membership_State__c = 'HI';           
            objMembership21.Start_Date__c = System.Today();
            objMembership21.Type__c = 'Annual';
            objMembership21.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership21);
            
            Membership__c objMembership22 = new Membership__c();
            objMembership22.Contact__c = objContactTeam22.Id;
            objMembership22.Membership_State__c = 'HI';           
            objMembership22.Start_Date__c = System.Today();
            objMembership22.Type__c = 'Annual';
            objMembership22.Gift_Amount__c = Decimal.valueOf('50.00');
            objMembership22.Membership_Source__c = 'Web';
            objMembership22.Membership_Action__c = 'Join';  
            mbList.add(objMembership22);
            
            Membership__c objMembership33 = new Membership__c();
            objMembership33.Contact__c = objContactTeam33.Id;
            objMembership33.Membership_State__c = 'HI';           
            objMembership33.Start_Date__c = System.Today();
            objMembership33.Type__c = 'Annual';
            objMembership33.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership33);
            
            Membership__c objMembership44 = new Membership__c();
            objMembership44.Contact__c = objContactTeam44.Id;
            objMembership44.Membership_State__c = 'HI';            
            objMembership44.Start_Date__c = System.Today();
            objMembership44.Type__c = 'Annual';
            objMembership44.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership44);
            
            insert mbList;  
           
            List<npe5__Affiliation__c> affList = new List<npe5__Affiliation__c>();
            
            npe5__Affiliation__c objAffiliationContactChapter1 = new npe5__Affiliation__c();
            objAffiliationContactChapter1.npe5__Contact__c = objContactChapter1.Id;
            objAffiliationContactChapter1.npe5__Organization__c = objAccountChapter.Id;
            objAffiliationContactChapter1.npe5__Status__c = 'Active';
            objAffiliationContactChapter1.Affiliation__c = 'Chapter Contact';
            affList.add(objAffiliationContactChapter1);                      
            
            npe5__Affiliation__c objAffiliationContactChapter2 = new npe5__Affiliation__c();
            objAffiliationContactChapter2.npe5__Contact__c = objContactChapter2.Id;
            objAffiliationContactChapter2.npe5__Organization__c = objAccountChapter.Id;
            objAffiliationContactChapter2.npe5__Status__c = 'Active';
            objAffiliationContactChapter2.Affiliation__c = 'Chapter Contact';
            affList.add(objAffiliationContactChapter2);
            
            npe5__Affiliation__c objAffiliationContactTeam11 = new npe5__Affiliation__c();
            objAffiliationContactTeam11.npe5__Contact__c = objContactTeam11.Id;
            objAffiliationContactTeam11.npe5__Organization__c = objAccountTeam.Id;
            objAffiliationContactTeam11.npe5__Status__c = 'Active';
            objAffiliationContactTeam11.Affiliation__c = 'Team Member';
            affList.add(objAffiliationContactTeam11);
            
            npe5__Affiliation__c objAffiliationContactChapter11 = new npe5__Affiliation__c();
            objAffiliationContactChapter11.npe5__Contact__c = objContactTeam11.Id;
            objAffiliationContactChapter11.npe5__Organization__c = objAccountChapter.Id;
            objAffiliationContactChapter11.npe5__Status__c = 'Active';
            objAffiliationContactChapter11.Affiliation__c = 'Chapter Contact';
            affList.add(objAffiliationContactChapter11);                         
            
            npe5__Affiliation__c objAffiliationContactTeam12 = new npe5__Affiliation__c();
            objAffiliationContactTeam12.npe5__Contact__c = objContactTeam12.Id;
            objAffiliationContactTeam12.npe5__Organization__c = objAccountTeam.Id;
            objAffiliationContactTeam12.npe5__Status__c = 'Active';
            objAffiliationContactTeam12.Affiliation__c = 'Team Member';
            affList.add(objAffiliationContactTeam12);
     
            npe5__Affiliation__c objAffiliationContactChapter12 = new npe5__Affiliation__c();
            objAffiliationContactChapter12.npe5__Contact__c = objContactTeam12.Id;
            objAffiliationContactChapter12.npe5__Organization__c = objAccountChapter.Id;
            objAffiliationContactChapter12.npe5__Status__c = 'Active';
            objAffiliationContactChapter12.Affiliation__c = 'Chapter Contact';
            affList.add(objAffiliationContactChapter12);
         
            npe5__Affiliation__c objAffiliationContactTeam21 = new npe5__Affiliation__c();
            objAffiliationContactTeam21.npe5__Contact__c = objContactTeam21.Id;
            objAffiliationContactTeam21.npe5__Organization__c = objAccountTeam.Id;
            objAffiliationContactTeam21.npe5__Status__c = 'Active';
            objAffiliationContactTeam21.Affiliation__c = 'Team Member';
            affList.add(objAffiliationContactTeam21);
            
            npe5__Affiliation__c objAffiliationContactChapter21 = new npe5__Affiliation__c();
            objAffiliationContactChapter21.npe5__Contact__c = objContactTeam21.Id;
            objAffiliationContactChapter21.npe5__Organization__c = objAccountChapter.Id;
            objAffiliationContactChapter21.npe5__Status__c = 'Active';
            objAffiliationContactChapter21.Affiliation__c = 'Chapter Contact';
            affList.add(objAffiliationContactChapter21);       
         
            npe5__Affiliation__c objAffiliationContactTeam22 = new npe5__Affiliation__c();
            objAffiliationContactTeam22.npe5__Contact__c = objContactTeam22.Id;
            objAffiliationContactTeam22.npe5__Organization__c = objAccountTeam.Id;
            objAffiliationContactTeam22.npe5__Status__c = 'Active';
            objAffiliationContactTeam22.Affiliation__c = 'Team Leader';
            objAffiliationContactTeam22.npe5__StartDate__c = System.today();
            affList.add(objAffiliationContactTeam22);
          
            npe5__Affiliation__c objAffiliationContactChapter22 = new npe5__Affiliation__c();
            objAffiliationContactChapter22.npe5__Contact__c = objContactTeam22.Id;
            objAffiliationContactChapter22.npe5__Organization__c = objAccountChapter.Id;
            objAffiliationContactChapter22.npe5__Status__c = 'Active';
            objAffiliationContactChapter22.Affiliation__c = 'Chapter Contact';
            affList.add(objAffiliationContactChapter22);    
            
            npe5__Affiliation__c objAffiliationContactTeam33 = new npe5__Affiliation__c();
            objAffiliationContactTeam33.npe5__Contact__c = objContactTeam33.Id;
            objAffiliationContactTeam33.npe5__Organization__c = objAccountTeam.Id;
            objAffiliationContactTeam33.npe5__Status__c = 'Active';
            objAffiliationContactTeam33.Affiliation__c = 'Team Member';
            affList.add(objAffiliationContactTeam33);
            
            npe5__Affiliation__c objAffiliationContactTeam44 = new npe5__Affiliation__c();
            objAffiliationContactTeam44.npe5__Contact__c = objContactTeam44.Id;
            objAffiliationContactTeam44.npe5__Organization__c = objAccountTeam.Id;
            objAffiliationContactTeam44.npe5__Status__c = 'Active';
            objAffiliationContactTeam44.Affiliation__c = 'Team Member';
            affList.add(objAffiliationContactTeam44);
         
            insert affList;       
       
            // Start Tests
            UserStats objUserStats = new UserStats(stdController);
            
            List<selectOption> lstStates = objUserStats.getStateNames;
            objUserStats.strStateId = lstStates[1].getValue();
  
            
            List<selectOption> lstChapters = objUserStats.getChapterNames;
 
            if (lstStates.size() > 1)
            {
            	
                
                // load first chapter
                lstChapters = objUserStats.getChapterNames;
                objUserStats.strChapterId = lstChapters[1].getValue();
                
                List<selectOption> lstTeams = objUserStats.getTeamNames;
                
                if (lstChapters.size() > 1)
                {
                	// test for Chapter 1, no team selection
                    objUserStats.strChapterId = lstChapters[1].getValue();
                    objUserStats.strTeamId = 'All';
                    
                    objUserStats.ShowMembers();

                  
                    lstTeams = objUserStats.getTeamNames;
                    objUserStats.strTeamId = lstTeams[0].getValue();
                    
                    objUserStats.ShowMembers();


                    if (lstTeams.size() > 1)
                    {
 
 
                    	// test for chapter 1, team 1
                        objUserStats.strTeamId = lstTeams[1].getValue();
                        System.AssertEquals(objUserStats.strTeamId, objAccountTeam.Id);
                        objUserStats.ShowMembers();
                        System.AssertEquals(objUserStats.ContactDisplay.size(), 8); 
  
                    }
                }
 
                System.AssertEquals(objUserStats.strStateId, objAccount.Id);
                System.AssertEquals(objUserStats.strChapterId, objAccountChapter.Id);
                System.AssertEquals(objUserStats.strTeamId, objAccountTeam.Id);
             
                
                if (lstChapters.size() > 1)
                {
                	// test for Unassigned Chapter 1, no team selection
                    objUserStats.strChapterId = 'none';
                    objUserStats.strTeamId = 'none';
                    System.AssertEquals(objUserStats.strChapterId, 'none');
                    
                    objUserStats.ShowMembers();
                    System.AssertEquals(objUserStats.ContactDisplay.size(), 0);

					// test for Unassigned chapter, unassigned team                    
                    lstTeams = objUserStats.getTeamNames;
 		            System.AssertEquals(objUserStats.strTeamId, 'none');
                    
                    objUserStats.ShowMembers();
 
                }

                
	            objUserStats.pageNumber = 0;
                 
                objUserStats.DownloadMembers();
                
                objUserStats.SortMembers();
                
                objUserStats.PrintMembers();
               
                objUserStats.strChapterId = lstChapters[0].getValue();
                lstTeams = objUserStats.getTeamNames;
                objUserStats.ResetTeam();
                
                objUserStats.strStateId = lstStates[0].getValue();
                lstChapters = objUserStats.getChapterNames;
                objUserStats.ResetChapterTeam();
                
                objUserStats.ShowMembers();
                
                objUserStats.DownloadMembers();
            }
            
            objUser.Division = 'HI';
	        Update objUser;
	        
	        System.runAs(objUser)
	        {
	        	Contact objContact2 = new Contact();
	            objContact2.FirstName = 'Test';
	            objContact2.LastName = 'User';
	            objContact2.Stand_Employee_User__c = objUser.Id;
	            Insert objContact2;
	            
	            Apexpages.StandardController stdController2 = new Apexpages.StandardController(objContact2);
	        	UserStats objUserStats2 = new UserStats(stdController2);
	        	
	        	objUserStats2.strChapterId = 'none';
	        	objUserStats2.strTeamId = 'none';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	
	        	objUserStats2.strSortDirection = 'ASC';
	        	objUserStats2.strSortField = 'objContact.strName';
	        	objUserStats2.PrepareLoadMembers('screen');       
	        	objUserStats2.strSortField = 'objContact.strPrefEmail';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	objUserStats2.strSortField = 'objContact.strPrefPhone';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	objUserStats2.strSortField = 'objContact.strMobilePhone';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	objUserStats2.strSortField = 'objContact.strMembershipStatus';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	objUserStats2.strSortField = 'objContact.strMembershipTeam';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	objUserStats2.strSortField = 'objContact.strLeaderContactName';
	        	objUserStats2.PrepareLoadMembers('screen');       
	        	
	        	objUserStats2.blnSingleState = true;  
	        	List<selectOption> lstStates2 = objUserStats2.getStateNames;   	
	        	
	        	objUserStats2.strChapterId = objUserStats.strChapterId;
	        	objUserStats2.PrepareLoadMembers('screen');
	        	
	        	objUserStats2.strTeamId = 'ALL';
	        	objUserStats2.strChapterId = 'none';
	        	objUserStats2.PrepareLoadMembers('screen');
	        	
	        	UserStats.ContactDetails uc = new UserStats.ContactDetails ();
	        	uc.strPrefEmail = '⬚⬚';
	        	boolean aa = uc.emailIsScrambled;
	        	uc.strPrefEmail = 'aa';
	        	aa = uc.emailIsScrambled;
	        	uc.strPrefEmail = null;
	        	aa = uc.emailIsScrambled;        	
	        	        	
	        }
        }
    }
    
}