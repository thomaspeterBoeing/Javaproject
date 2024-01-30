public with sharing class ILHRatePageRules {

/*
parameters :- State & Product
mapQDSkipstlst - has decisions(application,email summary,paper kit)  with skip state for all products.
productDecisionSkipstmap - decision with product & its skip states. 

*/    
private static Map<string,list<string>> mapQDSkipstlst;
private static Map<string,Map<string,list<string>>> productDecisionSkipstmap;
public static list<string> loadQuoteDecision(string state,string product){
    List<String> eligibleDecisions=new list<string>();
    if (mapQDSkipstlst==null || productDecisionSkipstmap==null){
        Quote_Decision_Option__mdt[] QuoteDecisions = [SELECT MasterLabel, Products__c, SkipStates__c FROM Quote_Decision_Option__mdt WHERE IsActive__c =: true ORDER BY MasterLabel];
        mapQDSkipstlst=new Map<string,list<string>>();
        productDecisionSkipstmap=new  Map<string,Map<string,list<string>>>();
        for (Quote_Decision_Option__mdt qd : QuoteDecisions) {
            List<String> skipStateList = new List<String>();
            if (!String.isBlank(qd.skipstates__C))
                skipStateList=qd.skipstates__C.split(',');
            if(qd.Products__c=='All Products'){
                mapQDSkipstlst.put(qd.Masterlabel,skipStateList);
            }else{
                if(!productDecisionSkipstmap.containsKey(qd.Masterlabel))
                    productDecisionSkipstmap.put(qd.Masterlabel,new Map<string,list<string>>());
                
                productDecisionSkipstmap.get(qd.Masterlabel).put(qd.Products__c,skipStateList);
            }
        }
    }    
    for (String decision:mapQDSkipstlst.keyset()){
        if(!mapQDSkipstlst.get(decision).contains(state))
            eligibleDecisions.add(decision);
    }
    for (String decision:productDecisionSkipstmap.keyset()){
        if(productDecisionSkipstmap.containsKey(decision) && productDecisionSkipstmap.get(decision).containsKey(product) && !productDecisionSkipstmap.get(decision).get(product).contains(state))
            eligibleDecisions.add(decision);
    }

    return eligibleDecisions;
}

}