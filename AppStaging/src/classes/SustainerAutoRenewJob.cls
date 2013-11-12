// Nightly Batch job to update Sustainers with Auto Renewal

// Note: To schedule use the following code (change the values - ss mm hr dom month dow year)
// SustainerAutoRenewJob sa = new SustainerAutoRenewJob ();
// String sch = '0 10 22 20 2 ? 2013';
// system.schedule ( 'One Time SA', sch, sa );

// Change Log
// ------------
// SKT 11/4/2013 - updated for new membership system - first pass done, ready for dev testing

global class SustainerAutoRenewJob Implements Schedulable {
	
	public SustainerAutoRenewJob () {

	}
	 
	global void execute ( SchedulableContext sc ) {
		PersonCollection pc = new PersonCollection ();
		integer count = pc.renewSustainers ();
	} 
	
}