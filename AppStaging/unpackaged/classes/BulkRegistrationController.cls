/**
            Name           : BulkRegistrationController
            Author         : 
            Date           : 24/08/2013    
            Description    : This class insert registration into cohort in bulk.
                             This class filter the contacts and insert into cohort registrations 
*/           
public class BulkRegistrationController{
    public List<SelectOption> contacFieldList{get;set;}
    public List<SelectOption> operatorList{get;set;}
    public List<ContactModel> conList{get;set;}
    public List<FilterModel> modelList{get;set;}
    public String cohortId{get;set;}
    private String queryString;
    private boolean flag;   
    private set<id> contactSet;
    public String operatorName{get;set;}
    public String fieldName{get;set;}
    private Map<String,String>mapFieldType;
    public integer selectedIndex{get;set;}
    
    // constructor
    public BulkRegistrationController(){
        cohortId=ApexPages.currentPage().getParameters().get('id');
        contactSet = new set<id>();
        for(Registration__c reg: [select contact__c from Registration__c]){
            contactSet.add(reg.contact__c);
        }
        
        // Default list of Operators
        operatorList=new List<SelectOption>();
        operatorList.add(new SelectOption('none','--None--')); 
        operatorList.add(new SelectOption('=','equals'));
        operatorList.add(new SelectOption('!=','not equal to'));
        operatorList.add(new SelectOption('startswith','starts with'));
        operatorList.add(new SelectOption('contains','contains'));
        operatorList.add(new SelectOption('doesnotcontains','does not contains'));
        operatorList.add(new SelectOption('<','less than'));
        operatorList.add(new SelectOption('>','greater than'));
        operatorList.add(new SelectOption('<=','less or equal'));
        operatorList.add(new SelectOption('>=','greater or equal'));
        
        modelList=new List<FilterModel>();
        for(integer i=0;i<5;i++)
            modelList.add(new FilterModel(operatorList,i));
        contacFieldList=new List<SelectOption>();
        Map<String,Schema.SObjectField> ObjectFieldMap;
        mapFieldType = new Map<String,String>();
        Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe();
        Schema.SObjectType s = m.get('Contact') ;
        ObjectFieldMap = s.getDescribe().fields.getMap() ;
        for (Schema.SObjectField SObjectF : ObjectFieldMap.values()){
                Schema.DescribeFieldResult field = SObjectF.getDescribe();
                Schema.DisplayType fieldType =ObjectFieldMap.get(field.getName()).getDescribe().getType();
                String fieldDataType = fieldType+ '';
                if(fieldDataType.equalsIgnoreCase('String') || fieldDataType.equalsIgnoreCase('PickList') || fieldDataType.equalsIgnoreCase('MultiPicklist')){
                    contacFieldList.add(new SelectOption(field.getName(),field.getLabel()));
                    mapFieldType.put(field.getName(),fieldDataType);
                }    
            }
            System.debug('#####Type Map'+mapFieldType);
        contacFieldList.sort();    
        
        }
        // this method changes operator list according field selected.
        public void changeOperatorList(){
            System.debug('####fieldName====>>>'+fieldName);
            String type=mapFieldType.get(fieldName);    
            System.debug('####type====>>>'+type);
            //operatorList=new List<SelectOption>();
            if(selectedIndex!=null){
                 FilterModel fm=modelList[selectedIndex]; 
                 fm.oppList=new List<SelectOption>();
                 if(mapFieldType.get(fm.field)=='MULTIPICKLIST'){
                     fm.oppList.add(new SelectOption('none','--None--')); 
                     fm.oppList.add(new SelectOption('=','equals'));
                     fm.oppList.add(new SelectOption('!=','not equal to'));
                     fm.oppList.add(new SelectOption('includes','includes'));
                     fm.oppList.add(new SelectOption('excludes','excludes'));
                    }else{
                        fm.oppList.add(new SelectOption('none','--None--')); 
                        fm.oppList.add(new SelectOption('=','equals'));
                        fm.oppList.add(new SelectOption('!=','not equal to'));
                        fm.oppList.add(new SelectOption('startswith','starts with'));
                        fm.oppList.add(new SelectOption('contains','contains'));
                        fm.oppList.add(new SelectOption('doesnotcontains','does not contains'));
                        fm.oppList.add(new SelectOption('<','less than'));
                        fm.oppList.add(new SelectOption('>','greater than'));
                        fm.oppList.add(new SelectOption('<=','less or equal'));
                        fm.oppList.add(new SelectOption('>=','greater or equal'));
                    }  
            }
           
        }
        // this method filter contact and execute query.
        public void filterContact(){
            flag=false;
            string leadSrc = 'Stand Up';
            queryString='Select id,firstName,lastName,email,Account.Name,phone from contact Where LeadSource =:leadSrc ';
            flag = true;
            for(FilterModel model :modelList){
                if(model.field!='none' && model.operator!='none'){
                     generateQuery(model.field,model.operator,model.value);   
                }    
            }
            if(contactSet.size() > 0)
                queryString += ' AND Id not in:contactSet ' ; 
            System.debug('#####'+queryString);
            queryString += ' order by LastName';
            List<Contact>tempList=Database.query(queryString);
            conList=new List<ContactModel>();
            for(Contact con : tempList){
                ContactModel cm=new ContactModel();
                cm.con=con;
                cm.check=false;
                conList.add(cm);    
            }
            System.debug('&&&&&&&&&&'+conList);        
        }
        
        // this method generate query according field and operator
        public void generateQuery(String field,String operator,String value){
            if(operator=='startswith'){
               if(flag){
                   queryString += ' AND '+field+' like \''+value+'%\''; 
               }else{
                   queryString += 'where '+field+' like \''+value+'%\''; 
               }
            }else if(operator=='contains'){
              if(flag){
                   queryString += ' AND '+field+' like \'%'+value+'%\''; 
               }else{
                   queryString += 'where '+field+' like \'%'+value+'%\''; 
               }  
            }else if(operator=='doesnotcontains'){
              if(flag){
                   queryString += ' AND (NOT '+field+' like \'%'+value+'%\') '; 
               }else{
                   queryString += 'where NOT '+field+' like \'%'+value+'%\''; 
               }  
            }else if(operator=='includes'){
                 queryString += ' AND '+field+' '+operator+'(\''+value+'\')'; 
            }else if(operator=='excludes'){
                 queryString += ' AND '+field+' '+operator+'(\''+value+'\')'; 
            }else{
                if(flag){
                   queryString += ' AND '+field+' '+operator+'\''+value+'\''; 
               }else{
                   queryString += 'where '+field+' '+operator+'\''+value+'\''; 
               } 
            }
            flag=true;    
        }
        
        // this method insert the contacts in to cohort registrations
        public pagereference aaTOCohort(){
            List<Registration__c> insertRegList=new List<Registration__c>();
            for(ContactModel cm : conList){
                if(cm.check==true){
                    Registration__c newReg=new Registration__c();
                    newReg.Cohort__c= cohortId;
                    newReg.How_Registered__c = 'Introduction Meeting';
                    newReg.Registration_Date__c = Date.TODAY();
                    newReg.Contact__c=cm.con.Id;
                    insertRegList.add(newReg);           
                }
            }
            
            try{
            if(insertRegList.size()>0)
                insert insertRegList; 
            }catch(Exception ex){
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                return null;
            }
            PageReference pg = new PageReference('/' + cohortId);
            return pg;
        }
        
        // this is model for field operator and value for filteration
        public class FilterModel{
            public String field{get;set;}
            public String operator{get;set;}
            public String value{get;set;}
            public integer indx{get;set;}
            public List<SelectOption>oppList{get;set;}
            public FilterModel(List<SelectOption>oppList,Integer indx){
                this.oppList = oppList;
                this.indx = indx;
            }
        }
        public class  ContactModel{
            public boolean check{get;set;}
            public Contact con{get;set;}
        }
    }