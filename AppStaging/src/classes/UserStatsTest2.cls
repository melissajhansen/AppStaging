@isTest
private class UserStatsTest2
{
    public static TestMethod void TestShowUserStatsShowMembers2()
    {
        Profile objProfile = [Select Id from Profile where Name='System Administrator'];
        User objUser2 = new User();
        objUser2.Alias = 'TstCls2';
        objUser2.CommunityNickname = 'TstCls2';
        objUser2.Email = 'testclassuser2@test.com';
        objUser2.EmailEncodingKey = 'UTF-8';
        objUser2.FirstName = 'TestClass2';
        objUser2.LocaleSidKey = 'en_US';
        objUser2.LastName = 'User2';
        objUser2.LanguageLocaleKey = 'en_US';
        objUser2.ProfileId = objProfile.Id;
        objUser2.TimeZoneSidKey = 'America/Los_Angeles';
        objUser2.UserName = 'testclassuser2@test.com';
        objUser2.Division = 'AZ';
        Insert objUser2;

        System.runAs(objUser2)
        {
            Contact objContact = new Contact();
            objContact.FirstName = 'Test2';
            objContact.LastName = 'User2';
            objContact.Stand_Employee_User__c = objUser2.Id;
            Insert objContact;
            
            Apexpages.StandardController stdController = new Apexpages.StandardController(objContact);
            
            // ------ STATE -------------
            Account objAccount = new Account();
            objAccount.Name = 'Test2 State';
            objAccount.Type = 'Stand Affiliate State';
            objAccount.Acquired_By__c = 'C3 Acquired';
            objAccount.BillingState = 'AZ';
            objAccount.State_Abbreviation__c = 'AZ';
            Insert objAccount;
            
            // ------ Chapter 1 -------------
            Account objAccountChapter1 = new Account();
            objAccountChapter1.Name = 'Test2 Chapter1';
            objAccountChapter1.Type = 'Stand Chapter';
            objAccountChapter1.Acquired_By__c = 'C3 Acquired';
            objAccountChapter1.ParentId = objAccount.Id;
            objACcountChapter1.BillingState = 'AZ';
            objAccountChapter1.State_Abbreviation__c = 'AZ';
            Insert objAccountChapter1;
            
            // ------ Chapter 2 -------------
            Account objAccountChapter2 = new Account();
            objAccountChapter2.Name = 'Test2 Chapter2';
            objAccountChapter2.Type = 'Stand Chapter';
            objAccountChapter2.Acquired_By__c = 'C3 Acquired';
            objAccountChapter2.ParentId = objAccount.Id;
            objAccountChapter2.BillingState = 'AZ';
            objAccountChapter2.State_Abbreviation__c = 'AZ';
            Insert objAccountChapter2;
            
            // ------ Team 1-1 -------------
            Account objAccountTeam11 = new Account();
            objAccountTeam11.Name = 'Test2 Team11';
            objAccountTeam11.Type = 'Stand Team';
            objAccountTeam11.Acquired_By__c = 'C3 Acquired';
            objAccountTeam11.ParentId = objAccountChapter1.Id;
            objAccountTeam11.BillingState = 'AZ';
            objAccountTeam11.State_Abbreviation__c = 'AZ';
            Insert objAccountTeam11;
            
            // ------ Team 1-2 -------------
            Account objAccountTeam12 = new Account();
            objAccountTeam12.Name = 'Test2 Team12';
            objAccountTeam12.Type = 'Stand Team';
            objAccountTeam12.Acquired_By__c = 'C3 Acquired';
            objAccountTeam12.ParentId = objAccountChapter1.Id;
            objAccountTeam12.BillingState = 'AZ';
            objAccountTeam12.State_Abbreviation__c = 'AZ';
            Insert objAccountTeam12;
            
            // ------ Team 2-1 -------------
            Account objAccountTeam21 = new Account();
            objAccountTeam21.Name = 'Test2 Team21';
            objAccountTeam21.Type = 'Stand Team';
            objAccountTeam21.Acquired_By__c = 'C3 Acquired';
            objAccountTeam21.ParentId = objAccountChapter2.Id;
            objAccountTeam21.BillingState = 'AZ';
            objAccountTeam21.State_Abbreviation__c = 'AZ';
            Insert objAccountTeam21;
            
            // ------ Team 2-2 -------------
            Account objAccountTeam22 = new Account();
            objAccountTeam22.Name = 'Test2 Team22';
            objAccountTeam22.Type = 'Stand Team';
            objAccountTeam22.Acquired_By__c = 'C3 Acquired';
            objAccountTeam22.ParentId = objAccountChapter2.Id;
            objAccountTeam22.BillingState = 'AZ';
            objAccountTeam22.State_Abbreviation__c = 'AZ';
            Insert objAccountTeam22;
            
            List<Contact> ctList = new List<Contact>();
            
            Contact objContactChapter1 = new Contact();
            objContactChapter1.FirstName = 'Chapter1Test2';
            objContactChapter1.LastName = 'Contact Chapter1';
            objContactChapter1.Stand_Office__c = 'AZ';
            objContactChapter1.Stand_Chapter_Affiliation__c = objAccountChapter1.Id;
            ctList.add(objContactChapter1);
            
            Contact objContactChapter2 = new Contact();
            objContactChapter2.FirstName = 'Chapter2Test2';
            objContactChapter2.LastName = 'Contact Chapter2';
            objContactChapter2.Stand_Office__c = 'AZ';
            objContactChapter2.Stand_Chapter_Affiliation__c = objAccountChapter2.Id;
            ctList.add(objContactChapter2);
            
            Contact objContactTeam11 = new Contact();
            objContactTeam11.FirstName = 'Team11Test2';
            objContactTeam11.LastName = 'Contact Team11';
            objContactTeam11.Stand_Office__c = 'AZ';
            objContactChapter1.Stand_Chapter_Affiliation__c = objAccountChapter1.Id;
            objContactChapter1.Stand_Team_Affiliation__c = objAccountTeam11.Id;            
            ctList.add(objContactTeam11);
            
            Contact objContactTeam12 = new Contact();
            objContactTeam12.FirstName = 'Team12Test2';
            objContactTeam12.LastName = 'Contact Team12';
            objContactTeam12.Stand_Office__c = 'AZ';
            objContactTeam12.Stand_Chapter_Affiliation__c = objAccountChapter1.Id;
            objContactTeam12.Stand_Team_Affiliation__c = objAccountTeam12.Id;            
            ctList.add(objContactTeam12);
            
            Contact objContactTeam21 = new Contact();
            objContactTeam21.FirstName = 'Team21Test2';
            objContactTeam21.LastName = 'Contact Team21';
            objContactTeam21.Stand_Office__c = 'AZ';
            objContactTeam21.Stand_Chapter_Affiliation__c = objAccountChapter2.Id;
            objContactTeam21.Stand_Team_Affiliation__c = objAccountTeam21.Id;            
            ctList.add(objContactTeam21);
            
            Contact objContactTeam22 = new Contact();
            objContactTeam22.FirstName = 'Team22Test2';
            objContactTeam22.LastName = 'Leader Team22';
            objContactTeam22.Stand_Office__c = 'AZ';
            objContactTeam22.Stand_Chapter_Affiliation__c = objAccountChapter2.Id;
            objContactTeam22.Stand_Team_Affiliation__c = objAccountTeam22.Id;            
            ctList.add(objContactTeam22);
            
            insert ctList;
            
            List<Membership__c> mbList = new List<Membership__c>();
            
            Membership__c objMembership1 = new Membership__c();
            objMembership1.Contact__c = objContactChapter1.Id;
            objMembership1.Membership_State__c = 'AZ';
            Date dtCurrentDate1 = System.Today();
            objMembership1.RE_Drop_Date__c = dtCurrentDate1.addDays(365);
            objMembership1.Quit_Date__c = dtCurrentDate1.addDays(365);
            objMembership1.Start_Date__c = System.Today();
            objMembership1.Type__c = 'Annual';
            objMembership1.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership1);
            
            Membership__c objMembership2 = new Membership__c();
            objMembership2.Contact__c = objContactChapter2.Id;
            objMembership2.Membership_State__c = 'AZ';
            Date dtCurrentDate2 = System.Today();
            objMembership2.RE_Drop_Date__c = dtCurrentDate2.addDays(365);
            objMembership2.Quit_Date__c = dtCurrentDate2.addDays(365);
            objMembership2.Start_Date__c = System.Today();
            objMembership2.Type__c = 'Annual';
            objMembership2.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership2);
            
            Membership__c objMembership11 = new Membership__c();
            objMembership11.Contact__c = objContactTeam11.Id;
            objMembership11.Membership_State__c = 'AZ';
            Date dtCurrentDate11 = System.Today();
            objMembership11.RE_Drop_Date__c = dtCurrentDate11.addDays(365);
            objMembership11.Quit_Date__c = dtCurrentDate11.addDays(365);
            objMembership11.Start_Date__c = System.Today();
            objMembership11.Type__c = 'Annual';
            objMembership11.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership11);
            
            Membership__c objMembership12 = new Membership__c();
            objMembership12.Contact__c = objContactTeam12.Id;
            objMembership12.Membership_State__c = 'AZ';
            Date dtCurrentDate12 = System.Today();
            objMembership12.RE_Drop_Date__c = dtCurrentDate12.addDays(365);
            objMembership12.Quit_Date__c = dtCurrentDate12.addDays(365);
            objMembership12.Start_Date__c = System.Today();
            objMembership12.Type__c = 'Annual';
            objMembership12.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership12);
            
            Membership__c objMembership21 = new Membership__c();
            objMembership21.Contact__c = objContactTeam21.Id;
            objMembership21.Membership_State__c = 'AZ';
            Date dtCurrentDate21 = System.Today();
            objMembership21.RE_Drop_Date__c = dtCurrentDate21.addDays(365);
            objMembership21.Quit_Date__c = dtCurrentDate21.addDays(365);
            objMembership21.Start_Date__c = System.Today();
            objMembership21.Type__c = 'Annual';
            objMembership21.Gift_Amount__c = Decimal.valueOf('50.00');
            mbList.add(objMembership21);
            
            Membership__c objMembership22 = new Membership__c();
            objMembership22.Contact__c = objContactTeam22.Id;
            objMembership22.Membership_State__c = 'AZ';
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
            affList.add(objAffiliationContactTeam21);
            
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
            
           	

/*            // ------ Contact Unassigned-Unassigned -------------
            Contact objContactTeamUU = new Contact();
            objContactTeamUU.FirstName = 'Test2';
            objContactTeamUU.LastName = 'Unassigned';
            objContactTeamUU.Stand_Office__c = 'AZ';
            
            Insert objContactTeamUU;
            
            System.Debug('objContactTeamUU.id = ' + objContactTeamUU.Id);
            
           	Membership__c objMembershipUU = new Membership__c();
            objMembershipUU.Contact__c = objContactTeamUU.Id;
            objMembershipUU.Membership_State__c = 'AZ';
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
            //rlb
            //objUserStats.strStateId = lstStates[1].getValue();
            // rlb
            //System.AssertEquals(objUserStats.strStateId, objAccount.Id );
            //rlb
            //System.AssertEquals(lstStates.size(), 3);
            
            List<selectOption> lstChapters = objUserStats.getChapterNames;
            //System.AssertEquals(lstChapters.size(), 10);
            if (lstStates.size() > 1)
            {
            	
                
                // load first chapter
                lstChapters = objUserStats.getChapterNames;
                System.AssertEquals(lstChapters.size(), 3);
                objUserStats.strChapterId = lstChapters[1].getValue();
                
                List<selectOption> lstTeams = objUserStats.getTeamNames;
                System.AssertEquals(lstTeams.size(), 3);
                
                if (lstChapters.size() > 1)
                {
                	// test for Chapter 1, no team selection
                    objUserStats.strChapterId = lstChapters[1].getValue();
                    objUserStats.strTeamId = 'All';
                    // rlb
                    //System.AssertEquals(objUserStats.strChapterId, objAccountChapter1.Id);
                    
                    objUserStats.ShowMembers();
                    System.AssertEquals(objUserStats.ContactDisplay.size(), 2);

					// test for chapter 1, team = all                    
                    lstTeams = objUserStats.getTeamNames;
                    System.AssertEquals(lstTeams.size(), 3);
                    objUserStats.strTeamId = lstTeams[0].getValue();
                    System.AssertEquals(objUserStats.strTeamId, 'All');
                    
                    objUserStats.ShowMembers();
                    System.AssertEquals(objUserStats.ContactDisplay.size(), 2); 
                    
                    if (lstTeams.size() > 1)
                    {
                    	// test for chapter 1, team 1
                        objUserStats.strTeamId = lstTeams[1].getValue();
                        // rlb
                        //System.AssertEquals(objUserStats.strTeamId, objAccountTeam11.Id);
                        objUserStats.ShowMembers();
                        System.AssertEquals(objUserStats.ContactDisplay.size(), 1); 
                    }
                }
                //rlb
                //System.AssertEquals(objUserStats.strStateId, objAccount.Id);
                //rlb
                //System.AssertEquals(objUserStats.strChapterId, objAccountChapter1.Id);
                //rlb
                //System.AssertEquals(objUserStats.strTeamId, objAccountTeam11.Id);
                
/*                //rlb
                // load Unassigned chapter
                //lstChapters = objUserStats.getChapterNames;
                //System.AssertEquals(lstChapters.size(), 4);
                objUserStats.strChapterId = lstChapters[4].getValue();
                
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
                    System.AssertEquals(lstTeams.size(), 4);
                    objUserStats.strTeamId = lstTeams[4].getValue();
                    System.AssertEquals(objUserStats.strTeamId, 'none');
                    
                    objUserStats.ShowMembers();
                    System.AssertEquals(objUserStats.ContactDisplay.size(), 1); 
                    
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
*/                
                
                
                
                
	            objUserStats.pageNumber = 0;
    	        objUserStats.skipToPage();
                
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
        }
    }
}