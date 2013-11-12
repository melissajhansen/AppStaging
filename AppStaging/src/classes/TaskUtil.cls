public with sharing class TaskUtil {
	
	//MP 2/12/13
	//Method for generating new Staff Follow-up Task when a task is completed and marked for staff follow-up.
	public void NewStaffTask(Task CurrentTask, Task OldTask, string triggerType) {
	
		//Get the Default Task Assignee from the User Record of the Owner on the Task,if one exists  (list of one)
		List < User > AssigneeList = new List < User > ( [SELECT ID, Default_Task_Assignee__c FROM User WHERE User.Id = :CurrentTask.OwnerId AND Default_Task_Assignee__c <>'']);
		
		//Originally had different logic for Update & Insert (checking whether the task was completed before the update, to avoid multiple, duplicative follow-up tasks)
		//Initial feedback is to create a new staff follow-up task any time the Task is edited and still qualifies.
		//if (((triggerType == 'Insert') && (CurrentTask.IsClosed == true) && (CurrentTask.Staff_to_Follow_up__c == true)) 
		//|| (triggerType == 'Update') && (OldTask.IsClosed == false) && (CurrentTask.IsClosed == true) && (CurrentTask.Staff_to_Follow_up__c == true)){
		if ((CurrentTask.IsClosed == true) && (CurrentTask.Staff_to_Follow_up__c == true)){
			Task objTask = new Task(); 
			//Check to see if the User has a Default Assignee on their User record. If so, assign follow-up task to that user.  If not, assign to user from current task.
			if (AssigneeList.size() > 0) {
				objTask.OwnerId = AssigneeList[0].Default_Task_Assignee__c;
			} else {
				objTask.OwnerId = CurrentTask.OwnerId;
			}
			objTask.RecordTypeId = CurrentTask.RecordTypeId;
			objTask.Subject = 'Follow-up Actions';
			objTask.Type = 'Other';
			objTask.WhoId = CurrentTask.WhoId;
			objTask.WhatId = CurrentTask.WhatId;
			objTask.ActivityDate = CurrentTask.ActivityDate + 2;
			objTask.Status = 'Not Started';
			objTask.Description = 'Outcomes from Original Task: ' + CurrentTask.Outcomes__c;
			Insert objTask;
		}
//		}
				
	}

}