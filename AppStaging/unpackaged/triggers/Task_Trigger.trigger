// MP 2/11/2013
// Created Trigger to support Automatic Follow-up Tasks

trigger Task_Trigger on Task (after insert, after update) {

	if ((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate)){
		
		//check for a single record submission.  Does not work in batch mode
		if (trigger.new.size() == 1) {
	
			TaskUtil task = new TaskUtil ();
			Task CurrentTask = trigger.new[0];
			
			if (Trigger.isUpdate) {
				task.NewStaffTask (CurrentTask, trigger.old[0], 'Update');
			} if (Trigger.isInsert){
				task.NewStaffTask (CurrentTask, null, 'Insert');
			}
		}
	}


}