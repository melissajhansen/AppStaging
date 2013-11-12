trigger Payment_Trigger on npe01__OppPayment__c (before insert) {
	
	
	PaymentUtil pu = new PaymentUtil ();
	pu.paymentCPInfo (trigger.new);

}