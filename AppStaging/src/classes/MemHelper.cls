public with sharing class MemHelper {

	public MemHelper () {
		
	}

	public static void updateTallies( string id, string objType ) {
		
		if ( objType == 'Organizer' ) {
			Organizer.updateOrgTallies (id, objType);
		} 
		else if ( objType == 'Team') {
			Team.updateTeamTallies (id);
			Organizer.updateOrgTallies (id, objType);
		}
		else if ( objType == 'Leader') {
			Leader.updateLdrTallies(id);
		}
	}
	
}