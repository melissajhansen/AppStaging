public with sharing class Donation {

	public Id id;
	public String name;
	public Id account_id;
	public String giver_type;
	public double amount;
	public String stage;
	public Date close_date;
	public String pay_type;
	public String entity;
	public String fund;
	public String community;
	public Id campaign;
	public String fiscal_year;
	public Id record_type;
	public Id team;
	public Id organizer;
	public String state;
	public Id chapter;
	public Id leader;
	public String transaction_type;
	public String pay_method;
	public String portal;

	public Donation () {

	}


	public void create () {

		Opportunity o = new Opportunity();
		o.Name = name;
		o.AccountId = account_id;
		o.Giver_Type__c = giver_type;
		o.Amount = amount;
		o.StageName = stage;
		o.CloseDate = close_date;
		o.Entity_Committed__c = entity;
		o.Fund_Committed__c = fund;
		o.Community_Committed__c = community;
		o.CampaignId = campaign;
		o.Fiscal_Year_Designation__c = fiscal_year;
		o.RecordTypeId = record_type;
		o.Team__c = team;
		o.Organizer__c = organizer;
		o.Chapter__c = chapter;
		o.Leader__c = leader;
		o.Stand_State__c = state;
		o.Transaction_Type__c = transaction_type;

		insert o;

		id = o.id;

		npe01__OppPayment__c pay = ([SELECT id, npe01__Payment_Method__c,npe01__Opportunity__c, Gift_Portal__c from npe01__OppPayment__c WHERE npe01__Opportunity__c = :o.id]);
		pay.npe01__Payment_Method__c = pay_method;
		pay.Gift_Portal__c = portal;
		update pay;

	}


}