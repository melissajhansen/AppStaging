public class OppNoteAttachment {
/*
	// define the controller for the page
	private ApexPages.StandardController controller;
	
	// define extension for the controller for the page
    public OppNoteAttachment(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    // the file attachment from the Browse... field
    Public Attachment myfile;
    
    // this returns the file attachment from the Browse... field
    Public Attachment getmyfile()
    {
        myfile = new Attachment();
//		try {
			return myfile;
//    	} catch (DmlException e) {
    		// the code may never get here, it might just return null for myfile above
//    		myfile.body = null;
//			myfile = new Attachment();
			
//        	return null;
//    	}
    }
	
	// for the cancel button
	Public Pagereference CancelAttachment() {
		PageReference cancel = controller.cancel();
		return cancel;
	}
	
	// for the save button
    Public Pagereference SaveNoteAttachment() {
    	// reference to Cancel button, to return to Contact page
        PageReference cancel = controller.cancel();
        
        // check to see if Test is running, to create attachment file
        if (Test.isRunningTest() == true) {
        	myfile = new Attachment();
			myfile.Name = 'test';
			myfile.Body = blob.valueOf('Test Attachment');
        }
        
        // if user presses Save button without a file, return to Contact page without doing anything
        if (myfile.body == Null ) {
        	return null;
        }
        
//        if (myfile.body.size() > 5000) {
//        	myfile.body = null;
//			myfile = new Attachment();
//       	//return Page.NoteAttachmentFailure;
//        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
//        	return null;
//        }
        
        // create a note with the title of the file
        OppNote__c mynote = new OppNote__c();
        mynote.Name = myfile.name;
        
        // gets the Contact ID
        String accid = System.currentPagereference().getParameters().get('id');
        // assign the ID to the note
        if (Test.isRunningTest() == true) {
        	Opportunity o = [Select Id from Opportunity where Name = 'NoteTestOpportunity1'];
        	mynote.Donation__c = o.id;
        } else {
	        mynote.Donation__c = accid;        	
        }
        // insert the note
        insert mynote;

		// create the attachment from the file
        Attachment a = new Attachment(parentId = mynote.id, name=myfile.name, body = myfile.body);
        
        // insert the attachment on the note
        try {
			insert a;
		} catch (DMLException e) {
			// it might not ever get here, if there is an error earlier
			//ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
			return null;
			//return cancel;
			//return Page.NoteAttachmentFailure;
		} finally {
			// clear these values for resetting the view state
			myfile.body = null;
			myfile = new Attachment();
			mynote = new OppNote__c();
			a = new Attachment(); 
		}
 
		//ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
		//return cancel;
		
		// return to a page showing success
		return Page.OppNoteAttachmentSuccess;
    }   
*/
}