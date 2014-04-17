public with sharing class ProcessInstallations_Rearrange 
{
	public static void Rearrange_Asset_Items(Map<OpportunityLineItem, List<Product2>> sub_Map,opportunity opp)
	{
	map<string,List<Asset_Item__c>> astitm_mp = new map<string,List<Asset_Item__c>>(); 
	List<Asset_Item__c> aitlst = new List<Asset_Item__c>();
	List<Asset_Item__c> atmupdate = new List<Asset_Item__c>();
	aitlst = [Select ID,Asset__c,Opportunity__c,Hide_on_Portal__c,Environment__c,End_Date__c,Parent_Asset_Item__c,
	Part_Number__c,Process_later__c,Product__c,Quantity__c,Server__c from Asset_Item__c where Opportunity__c =: opp.id];
	
	if(!aitlst.isEmpty())
	{
	for(Asset_Item__c atm : aitlst)
	{
	if(astitm_mp.containskey(atm.Part_Number__c))
	{
	astitm_mp.get(atm.Part_Number__c).add(atm);
	}
	else
	{
	List<Asset_Item__c> temp = new List<Asset_Item__c>();
	temp.add(atm);
	astitm_mp.put(atm.Part_Number__c,temp);
	}	
	}
	for(OpportunityLineItem op : sub_Map.keyset())
	{
	if(op.PricebookEntry.Product2.Solution_Product__c)
	{
	for(product2 sbprod : sub_Map.get(op))
	{
		if(astitm_mp.containskey(sbprod.Part_Number__c) && astitm_mp.containskey(op.PricebookEntry.Product2.Part_Number__c))
		{
	for(Asset_Item__c subatm : astitm_mp.get(sbprod.Part_Number__c))
	{
	for(Asset_Item__c parentatm : astitm_mp.get(op.PricebookEntry.Product2.Part_Number__c))
	{
	if(parentatm.Asset__c == subatm.Asset__c && parentatm.Server__c == subatm.Server__c)
	{
		atmupdate.add(new Asset_Item__c(id = subatm.id,Parent_Asset_Item__c = parentatm.id,quantity__c = sbprod.SubProduct_Quantity__c));	
	}	
	}	
	}
    }
	}	
	}			
	}		
	}	
	}
}