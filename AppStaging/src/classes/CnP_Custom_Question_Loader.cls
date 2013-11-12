// Class to access the CnP Custom Question object to pull out
// a map of key-value pairs indexed by CnP Order ID

public with sharing class CnP_Custom_Question_Loader {
    
    private List < String > CnP_TransIDs;       // list containing all CnP Transaction IDs
    
    private map < ID, CnP_PaaS__CnP_Transaction__c > mNames;  // map containing
    private map < ID, CnP_PaaS__Custom_Question__c > mCQ_IDs;
    private map < ID, CnP_PaaS__Custom_Question__c > mCQ_Keys;
    private map < ID, CnP_PaaS__Custom_Question__c > mCQ_Values;
    private map < String, ID > mNameID;  // a special list to provide look ups by Name to get the original ID
    private map < ID, map < String, String > > mMaster_Map;
    
    // Constructor
    // Requires a List of CnP Order IDs to process
    
    public CnP_Custom_Question_Loader ( List < String > CnP_TransIDs ) {
        this.CnP_TransIDs = CnP_TransIDs;
        
    }
    
    // Main method to load Custom Question fields from CnP and populates the Master Map structure
    // Upon completion, the mMaster_Map structure is indexed by Transaction ID and contains key value pairs
    // Returns True on successful execution
    // Returns False if no Custom Questions are found based on the Transaction ID list
    public Boolean Get_Maps () {
        
        // check to make sure we have a list of Transaction IDs
        if ( this.CnP_TransIDs.size () == 0 )
            return false;
            
        // SOQL - load up Names based on the Transaction IDs
        this.mNames = new map < ID, CnP_PaaS__CnP_Transaction__c > ( [ SELECT ID, Name FROM CnP_PaaS__CnP_Transaction__c WHERE ID IN : CnP_TransIDs ORDER BY Name ] );
        
        // make sure we found CnP Transactions - apparently this may never happen
        // SKT 12/19/11 - commenting this out to provide for 100% test coverage
        //                it seems that due to relational integrity this case should 
        //                never appear.
        //if (mNames.size () == 0)
        //  return false;
        
        // build the set of names for use in next set of SOQL cmds
        // also build the reverse lookup of Name -> ID for use in remapping the master map
        set < String > tmp_Names = new set < String > ();
        map < String, ID > mNameID = new map < String, ID > ();
        
        for ( ID i : this.mNames.keyset()) {
            tmp_Names.add ( mNames.get ( i ).Name );
            mNameID.put ( mNames.get ( i ).Name, i );
        }
        
        // SOQL - retrieve all Custom Questions
        this.mCQ_IDs = new map < Id, CnP_PaaS__Custom_Question__c > ( [ SELECT ID, Name FROM CnP_PaaS__Custom_Question__c WHERE Name IN : tmp_Names ORDER BY Name ] );
        this.mCQ_Keys = new map < Id, CnP_PaaS__Custom_Question__c > ( [ SELECT ID, CnP_PaaS__Custom_Question__c FROM CnP_PaaS__Custom_Question__c WHERE Name IN : tmp_Names ORDER BY Name ] );
        this.mCQ_Values = new map < Id, CnP_PaaS__Custom_Question__c > ( [ SELECT ID, CnP_PaaS__Answer__c FROM CnP_PaaS__Custom_Question__c WHERE Name IN : tmp_Names ORDER BY Name ] );
        
        // check that we found custom questions
        if ( this.mCQ_IDs.size () == 0 )
            return false;
            
        // build the internal data structure for storing the ID indexed Key Value pairs
        this.mMaster_Map = new map < ID, map < String, String > > ();
        String current_Order_ID = '';
        ID tmp_ID = null;  
        
        for ( String cq_ID : this.mCQ_IDs.keyset() ) {
            // set the Order ID
            current_Order_ID = this.mCQ_IDs.get ( cq_ID ).name;
            
            // fetch the ID from the name
            tmp_ID = mNameID.get ( current_Order_ID );
            // add the current Key Value pair to the master map indexed to the current order ID
            this.Add_Key_Value_To_Master_Map ( tmp_ID, mCQ_Keys.get ( cq_ID ).CnP_PaaS__Custom_Question__c, mCQ_Values.get ( cq_ID ).CnP_PaaS__Answer__c);
        }
        
        // FUTURE: provide the mapping from CnP Question to the actual field that is updated in parent objects
        
        return true;
    }
    
    // Retrieves a specific Custom Question value indexed by Transaction ID and Question
    public String Get_Value_By_Trans_Key ( ID Trans_ID, String Key ) {
        
        String ret_val = null;
        
        if ( this.mMaster_Map.containsKey ( Trans_ID ) ) {
            map < String, String > tmp_kv = this.mMaster_Map.get ( Trans_ID );
            ret_val = tmp_kv.get ( Key );
        }
        
        return ret_val;
    }
    
    // Adds a key value pair to the Master map indexed by Order ID
    // Does not return a value
    
    private void Add_Key_Value_To_Master_Map ( ID i, String Key, String Value) {
        
        map < String, String > tmp_kv;  // tmp storage for the list of key value pairs
        
        if ( mMaster_Map.containsKey ( i ) ) {
            // need to remove the element and re-add
            tmp_kv = mMaster_Map.remove ( i );
            tmp_kv.put ( Key, Value );
            
        } else {
            tmp_kv = new map < String, String > { Key => Value };
        }
        
        // add the list back into the master map
        mMaster_Map.put ( i, tmp_kv ); 
    }
    
     
}