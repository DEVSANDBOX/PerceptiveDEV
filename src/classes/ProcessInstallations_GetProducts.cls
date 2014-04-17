public class ProcessInstallations_GetProducts 
{

    public static Map<OpportunityLineItem, List<Product2>> ProcessInstallations_getProducts(ID oppID)
    {
        
            Map<OpportunityLineItem, List<Product2>> productsToProcess = new Map<OpportunityLineItem, List<Product2>>();    //list that will hold all products to be processed.
            Map<ID, List<Product_Sub_Item__c>> subitems = new Map<ID, List<Product_Sub_Item__c>>();     //list of subitems - will be put in map related to lineitemRec
            Map<Id, List<Product_Sub_Item__c>> productSubitemstocheck = new Map<Id, List<Product_Sub_Item__c>>();   //list of subitems need to be checked for additional sub items
            Map<Id, List<Product_Sub_Item__c>> subProduct = new Map<Id, List<Product_Sub_Item__c>>();
            Map<ID, List<Product_Sub_Item__c>> productSubItems = new Map<ID, List<Product_Sub_Item__c>>();     //ProductID-->List<Subitems>
            Boolean ProductsFound;
            
        //get list of LineItems
        List<OpportunityLineItem> OppLineItems = (List <OpportunityLineItem>)(Database.query('Select Id,Part_number__c,Opportunity.AccountId,Opportunity.Account.Name,Opportunity.OwnerID,OpportunityId,Opportunity.Opportunity_Number__c,Opportunity.Type,Originating_Company__c,  Opportunity.Admin_Contact__r.Name, Opportunity.Admin_Contact__r.Email,Opportunity.Admin_Contact__r.Phone,Server__c,Price_Type__c,Quantity,Return__c,PricebookEntry.Product2.Core_Product__c,PricebookEntry.Product2.Environment__c,PricebookEntry.Product2.Failover_Environments_Allowed__c,PricebookEntry.Product2.part_number__c,PricebookEntry.Product2.Failover_Environments_Needed__c,PricebookEntry.Product2.Failover_Licenses_Allowed__c,PricebookEntry.Product2.Exclude_from_Failover_Clone__c,PricebookEntry.Product2.Exclude_from_Test_Clone__c,PricebookEntry.Product2.Id,PricebookEntry.Product2.License_Required__c,PricebookEntry.Product2.Name,PricebookEntry.Product2.Parent_Product__r.Product_Model__r.Name,PricebookEntry.Product2.Parent_Product__r.Name,PricebookEntry.Product2.Product_Model__c,   PricebookEntry.Product2.Product_Model__r.Asset_Required__c,PricebookEntry.Product2.Product_Model__r.Family__c,PricebookEntry.Product2.Product_Model__r.Line__c,PricebookEntry.Product2.Product_Model__r.Model__c,              PricebookEntry.Product2.Product_Model__r.Name,PricebookEntry.Product2.Product_Model__r.Series__c,PricebookEntry.Product2.SMSA_Product__c,PricebookEntry.Product2.SMSA_Product__r.Product_Model__r.Name,PricebookEntry.Product2.Test_Environments_Allowed__c,PricebookEntry.Product2.Test_Environments_Needed__c,PricebookEntry.Product2.Test_Licenses_Allowed__c,PricebookEntry.Product2.Replicate_Full_Environment__c,PricebookEntry.Product2.Use_Sizing_Tool__c,PricebookEntry.Product2.Replicate_Assets__c FROM OpportunityLineItem Where OpportunityId = :oppId'));
    
      
 
        //from initial list check to see if any of these produts have subitems  
        if (OppLineItems.size() > 0) 
        {            
            Set<ID> ProductIDSet = new Set<ID>();            
            
            for(OpportunityLineItem LineItem : OppLineItems)
            {
                system.debug('LineItemRec.PricebookEntry.Product2.Id: '+ LineItem.PricebookEntry.Product2.Id);
                ProductIDSet.add(LineItem.PricebookEntry.Product2.Id);
                system.debug('productIDSet' + productIDSet);
            }
                
            productSubItems = loadProductSubItems(ProductIDSet);        //get products related to productId
                
            if (productSubItems.size() > 0) 
            {
                system.debug('OppLineItems : ' + OppLineItems);
                For(OpportunityLineItem LineItemRec : OppLineItems) 
                {
                    system.debug('LineItemRec: ' + LineItemRec);
                    ID LineItemProductID = LineItemRec.PricebookEntry.Product2.Id;
                    boolean subItemKey;
                    subItemKey = productsubItems.containsKey(LineItemRec.PricebookEntry.Product2.Id);
                    system.debug('subitemKey: ' + subItemKey);
                    if (subItemKey)
                    {
                        List<Product_Sub_Item__c> ProductSubItemsList = productsubItems.get(LineItemRec.PricebookEntry.Product2.Id);
                        if (ProductSubItemsList.size() > 0) {
                            system.debug('productSubItemsList: ' + productSubItemsList);
                            subItems.put(LineItemProductID, ProductSubItemsList);           //add any subproducts found so can check if they have subproducts
                            productsfound = true;           //subproducts found for line item.
                            system.debug('productsfound' + productsfound);
                        }else {
                            system.debug('no Key found in ProductSubItemsList');
                            ProductstoProcess.putall(AddProductsToMap(createProductRecsfromLineItems(LineItemRec), ProductstoProcess));   
                            productsfound = false;              //no subproducts found for line item
                            system.debug('productsfound' + productsfound);
                        }
                    }else{
                        system.debug('no Key found in ProductSubItemsList');
                        ProductstoProcess.putall(AddProductsToMap(createProductRecsfromLineItems(LineItemRec), ProductstoProcess));    
                        productsfound = false;              //no subproducts found for line item
                        system.debug('productsfound' + productsfound);
                    }
        
                    //****filter through if any subitems.  all these items will get put into map with opportunityLineItems
                    //by the time we have gotten to the 'Products found'
                    if (productsfound){
                        do{
                            if (subItems.size() > 0 ){
                                productSubitemstocheck.putall(subItems);            //all subitems still need to check for additional subitems
                                system.debug('productSubitemstocheck: ' + productSubitemstocheck);
                                subItems.clear();                                   //remove previous subitems so they are not combined with new sub items.
                                List<ID> ProductSubitemsToCheckKeySet = new List<ID>(productSubitemstocheck.keyset());                      //define id set to hold Keyset Ids
                                system.debug('ProductSubitemsToCheckKeySet:' + ProductSubitemsToCheckKeySet);
                                for(ID keyset : ProductSubitemsToCheckKeySet ){
                                    system.debug('keyset - ProductSubitemsToCheckKeySet: ' + keyset);
                                    For(Product_Sub_Item__c subItem: productSubitemstocheck.get(keyset)){
            
                                        set<id> subItemIDSet = new set<id>();
                                        system.debug('subItemRec - funneling through keyset: ' + subItem);
                                        subItemIDset.clear();
                                        subItemIDSet.add(subItem.id);
                                        subproduct = loadProductSubItems(subItemIDSet);
                                        system.debug('subProduct - in do: ' + subProduct);
                                        if (subproduct.size() > 0) {
                                            productsfound = true;
                                            system.debug('productsfound - in do: ' + productsfound);
                                            try {
                                                List<Product_Sub_Item__c> SubProductItemsList = subproduct.get(subItem.id);
                                                if(SubProductItemsList.size() > 0) {
                                                    system.debug('SubProductItemsList: ' + SubProductItemsList);
                                                    subItems.put(subItem.id, SubProductItemsList);
                                                }else{
                                                    productsToProcess.putall(AddProductsToMap(createProductRecsfromSubItems(subItem, lineItemRec), ProductstoProcess)); 
                                                }
                                            }catch(exception subItemsException){
                                                system.debug('subItemsException:' + subItemsException);
                                                productsToProcess.putall(AddProductsToMap(createProductRecsfromSubItems(subItem, lineItemRec), ProductstoProcess)); 
                                            }
                                        }else {         //no subitems - all records get processed
                                            system.debug('in do - subItem from productSubItemstoCheck: ' + subItem);
                                            system.debug('in do - lineITemRec from productSubItemstoCheck: ' + lineItemRec);
                                            productsToProcess.putall(AddProductsToMap(createProductRecsfromSubItems(subItem, lineItemRec), ProductstoProcess));     ///check this line - where should it go
                                            productsfound = false;
                                            system.debug('in do - productsFound: ' + productsfound);
                                        }
                                    }   
                                }
                                system.debug('productSubItemstocheck: ' + productSubItemstocheck);
                                productSubitemstocheck.clear(); 
                            }else{
                                productsfound = false;
                            }   
                        } while(productsfound);
                    }       
                }
            }else {
                //all products get added to productsToProcess
                for (OpportunityLineItem lineItem : OppLineItems ){
                    ProductstoProcess.putall(AddProductsToMap(createProductRecsfromLineItems(lineItem), ProductstoProcess)); 
                }   
            }       
        }
        system.debug('exit do');
        system.debug('productsToProcess - after do: ' + productsToProcess);
        Return productsToProcess;
    }
    public static Map<Id, List<Product_Sub_Item__c>> loadProductSubItems(Set<Id> parentID)
    {
        Map<ID, List<Product_Sub_Item__c>> ProductSubItemMap = new Map<Id, List<Product_Sub_Item__c>>();
        List<Product_Sub_Item__c> subItemRecs = new List<Product_Sub_Item__c>([SELECT Parent_Product__c,
                                                                                        Id,
                                                                                        Product__c,
                                                                                        Product__r.Name,
                                                                                        Product__r.Part_Number__c,
                                                                                        Product__r.Core_Product__c,
                                                                                        Product__r.Environment__c, 
                                                                                        Product__r.Failover_Environments_Allowed__c,
                                                                                        Product__r.Failover_Environments_Needed__c,
                                                                                        Product__r.Failover_Licenses_Allowed__c,
                                                                                        Product__r.Exclude_from_Failover_Clone__c,
                                                                                        Product__r.Exclude_from_Test_Clone__c,
                                                                                        Product__r.License_Required__c,
                                                                                        Product__r.Parent_Product__r.Name,
                                                                                        Product__r.SMSA_Product__c,
                                                                                        Product__r.Solution_Product__c,
                                                                                        Product__r.Product_Model__c,
                                                                                        Product__r.Product_Model__r.Name,
                                                                                        Product__r.Test_Environments_Allowed__c,
                                                                                        Product__r.Test_Environments_Needed__c,
                                                                                        Product__r.Test_Licenses_Allowed__c,
                                                                                        Product__r.Replicate_Full_Environment__c,
                                                                                        Product__r.Use_Sizing_Tool__c,
                                                                                        Product__r.Replicate_Assets__c,                                                                                        
                                                                                        Quantity__c
                                                                                        FROM Product_Sub_Item__c 
                                                                                        WHERE Active__c = true AND Parent_Product__c in :parentID]);
                                                                                        
        system.debug('subItemRecs: ' +subItemRecs);
        if (subItemRecs.size()>0 )
        { 
        
            for(Product_Sub_Item__c SubRec : subItemRecs){  
                //get map entry - add subrec
                boolean productKey; 
                if (ProductSubItemMap.size() > 0){  
                     productKey = ProductSubItemMap.containsKey(subRec.Parent_Product__c);
                }else{
                    productKey = false;
                }
                system.debug('productKey: ' + productKey);
                List<Product_Sub_Item__c> tmpItemList = new List<Product_Sub_Item__c>();
                if (productKey){        
                        tmpItemList = ProductSubItemMap.get(subRec.Parent_Product__c);
                }       
                tmpItemList.add(subRec);
                ProductSubItemMap.put(subRec.Parent_Product__c,tmpItemList);
            }   
        }
        system.debug('productSubItemMap: ' + productSubItemMap);        
        return ProductSubItemMap;
                
    }
    public static Map<OpportunityLineItem, List<Product2>> createProductRecsfromSubItems(Product_Sub_Item__c subItemRec, OpportunityLineItem LineItem){
        Map<OpportunityLineItem, List<Product2>> subItemProducts = new Map<OpportunityLineItem, List<Product2>>();
        List<Product2> subItemProductsList = new List<Product2>();
        Product2 newSubItemProductRec = new Product2();
            newSubItemProductRec.Parent_Product__c = subItemRec.Parent_Product__c;
            newSubItemProductRec.Part_Number__c  = subItemRec.Product__r.Part_Number__c;
            newSubItemProductRec.Core_Product__c = subItemRec.Product__r.Core_Product__c;
            newSubItemProductRec.Environment__c = subItemRec.Product__r.Environment__c;
            newSubItemProductRec.Failover_Environments_Allowed__c = subItemRec.Product__r.Failover_Environments_Allowed__c;
            newSubItemProductRec.Failover_Environments_Needed__c = subItemRec.Product__r.Failover_Environments_Needed__c;
            newSubItemProductRec.Failover_Licenses_Allowed__c = subItemRec.Product__r.Failover_Licenses_Allowed__c;
            newSubItemProductRec.Exclude_from_Failover_Clone__c = subItemRec.Product__r.Exclude_from_Failover_Clone__c;
            newSubItemProductRec.Exclude_from_Test_Clone__c = subItemRec.Product__r.Exclude_from_Test_Clone__c;
            newSubItemProductRec.License_Required__c = subItemRec.Product__r.License_Required__c;
            newSubItemProductRec.Name = subItemRec.Product__r.Name;
            newSubItemProductRec.Product_Model__c = subItemRec.Product__r.Product_Model__c; 
            newSubItemProductRec.SMSA_Product__c = subItemRec.Product__r.SMSA_Product__c;
            newSubItemProductRec.Test_Environments_Allowed__c = subItemRec.Product__r.Test_Environments_Allowed__c;
            newSubItemProductRec.Test_Environments_Needed__c = subItemRec.Product__r.Test_Environments_Needed__c;
            newSubItemProductRec.Test_Licenses_Allowed__c = subItemRec.Product__r.Test_Licenses_Allowed__c;
            newSubItemProductRec.Replicate_Full_Environment__c = subItemRec.Product__r.Replicate_Full_Environment__c;
            newSubItemProductRec.Product_Bundled__c = true;
            newSubItemProductRec.SubProduct_Quantity__c = subItemRec.Quantity__c;
            newSubItemProductRec.Name_Abbrev__c = subitemRec.Product__r.id;         //used this field because couldn't populate ID in my temp table
            newSubItemProductRec.Use_Sizing_Tool__c= subitemRec.Product__r.Use_Sizing_Tool__c;                   
            newSubItemProductRec.Replicate_Assets__c= subitemRec.Product__r.Replicate_Assets__c;                  
        subItemProductsList.add(newSubItemProductRec);
                
        subItemProducts.put(LineItem, subItemProductsList);
                
        return subItemProducts;
                
    }
            
    public static Map<OpportunityLineItem, List<Product2>> createProductRecsfromLineItems(OpportunityLineItem lineItemRec){
        system.debug('createProductRecsfromLineItems - lineItemRec: ' + lineItemRec);
        system.debug('lineItemRec.PricebookEntry.Product2.Product_Model__r.Name: ' + lineItemRec.PricebookEntry.Product2.Product_Model__r.Name);
        system.debug('lineItemRec.PricebookEntry.Product2.Product_Model__r.Asset_Required__c: ' + lineItemRec.PricebookEntry.Product2.Product_Model__r.Asset_Required__c);

        Map<OpportunityLineItem, List<Product2>> LineItemProducts = new Map<OpportunityLineItem, List<Product2>>();
        List<Product2> lineItemProductsList = new List<Product2>();
        Product2 newLineItemProductRec = new Product2();
            newLineItemProductRec.Core_Product__c = lineItemRec.PricebookEntry.Product2.Core_Product__c;
            newLineItemProductRec.Part_Number__c  = lineItemRec.PricebookEntry.Product2.Part_Number__c;
            newLineItemProductRec.Environment__c = lineItemRec.PricebookEntry.Product2.Environment__c;
            newLineItemProductRec.Failover_Environments_Allowed__c = lineItemRec.PricebookEntry.Product2.Failover_Environments_Allowed__c;
            newLineItemProductRec.Failover_Environments_Needed__c = lineItemRec.PricebookEntry.Product2.Failover_Environments_Needed__c;
            newLineItemProductRec.Failover_Licenses_Allowed__c = lineItemRec.PricebookEntry.Product2.Failover_Licenses_Allowed__c;
            newLineItemProductRec.Exclude_from_Failover_Clone__c = lineItemRec.PricebookEntry.Product2.Exclude_from_Failover_Clone__c;
            newLineItemProductRec.Exclude_from_Test_Clone__c = lineItemRec.PricebookEntry.Product2.Exclude_from_Test_Clone__c;
            newLineItemProductRec.License_Required__c = lineItemRec.PricebookEntry.Product2.License_Required__c;
            newLineItemProductRec.Name = lineItemRec.PricebookEntry.Product2.Name;
            newLineItemProductRec.Product_Model__c = lineItemRec.PricebookEntry.Product2.Product_Model__c; 
            newLineItemProductRec.SMSA_Product__c = lineItemRec.PricebookEntry.Product2.SMSA_Product__c;
            newLineItemProductRec.Test_Environments_Allowed__c = lineItemRec.PricebookEntry.Product2.Test_Environments_Allowed__c;
            newLineItemProductRec.Test_Environments_Needed__c = lineItemRec.PricebookEntry.Product2.Test_Environments_Needed__c;
            newLineItemProductRec.Test_Licenses_Allowed__c = lineItemRec.PricebookEntry.Product2.Test_Licenses_Allowed__c;
            newLineItemProductRec.Replicate_Full_Environment__c = lineItemRec.PricebookEntry.Product2.Replicate_Full_Environment__c;
            newLineItemProductRec.SubProduct_Quantity__c = 0;
            newLineItemProductRec.Name_Abbrev__c = lineItemRec.PricebookEntry.Product2.id;          //used this field because couldn't populate ID in my temp table
            newLineItemProductRec.Use_Sizing_Tool__c= lineItemRec.PricebookEntry.Product2.Use_Sizing_Tool__c;    
            newLineItemProductRec.Replicate_Assets__c= lineItemRec.PricebookEntry.Product2.Replicate_Assets__c;                
            lineItemProductsList.add(newLineItemProductRec);    
            
            LineItemProducts.put(LineItemRec, lineItemProductsList);
                
            return LineItemProducts;
        
    }
    
    
    public static Map<OpportunityLineItem, List<Product2>> AddProductsToMap(Map<OpportunityLineItem, List<Product2>> NewProductsToAdd, Map<OpportunityLineItem, List<Product2>> ExistingProducts) {
        
        //for each key in new products to add, check against existing products
        Map<OpportunityLineItem, List<Product2>> ProductsAdded = new Map<OpportunityLineItem, List<Product2>>();
        List<OpportunityLineItem> NewProductsToAddKeySet = new List<OpportunityLineItem>(NewProductsToAdd.keyset());                        //get keyset of newProductsToAdd Map
        system.debug('NewProductsToAddKeySet:' + NewProductsToAddKeySet);
        for(OpportunityLineItem keyset : NewProductsToAddKeySet ){                                                      //for each keyset in the Map, cycle through
            
            boolean newProductKeyfound; 
            if (ExistingProducts.size() > 0){                                                           //check to see if the ExistingProductsMap Contains anything
                newProductKeyfound = ExistingProducts.containsKey(keyset);                                  //does the existing products map have the keyset of the new products                
            }else{
                newProductKeyfound = false;
            }
            system.debug('newProductKeyfound: ' + newProductKeyfound);                                                  //does the map have a keyset matching the NewProductsToAdd?
            List<Product2> tmpNewProductList = new List<Product2>();                    //create a tmpList to hold list returned from newProductsToadd
            List<Product2> tmpExistingProductList = new List<Product2>();                   //create a tmpList to hold list returned from newProductsToadd
            if (newProductKeyfound){        
                tmpExistingProductList = ExistingProducts.get(keyset);                              //get list from Existing productsList
            }   
            tmpNewProductList = NewProductsToAdd.get(keyset);   
            for (Product2 NewProductRec : tmpNewProductList ){
                tmpExistingProductList.add(NewProductRec);
            }   
            ProductsAdded.put(keyset,tmpExistingProductList);               
        }
        return ProductsAdded;
        
    }

        
}