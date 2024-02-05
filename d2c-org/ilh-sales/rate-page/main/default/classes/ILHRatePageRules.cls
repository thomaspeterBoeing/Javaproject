public with sharing class ILHRatePageRules {

/*
parameters :- State & Product
mapQDSkipstlst - has decisions(application,email summary,paper kit)  with skip state for all products.
productDecisionSkipstmap - decision with product & its skip states. 

*/    
private static Map<string,list<string>> mapQDSkipstlst;
private static Map<string,Map<string,list<string>>> productDecisionSkipstmap;
private static Map<string,list<string>> partnerQtDecisionmap;
public static list<string> loadQuoteDecision(string state,string product){
    List<String> eligibleDecisions=new list<string>();
    if (mapQDSkipstlst==null || productDecisionSkipstmap==null){
        Quote_Decision_Option__mdt[] QuoteDecisions = [SELECT MasterLabel,enabledForPartners__c, Products__c, SkipStates__c FROM Quote_Decision_Option__mdt order by MasterLabel];
        partnerQtDecisionmap=new Map<string,list<string>>();
        mapQDSkipstlst=new Map<string,list<string>>();
        productDecisionSkipstmap=new  Map<string,Map<string,list<string>>>();
        for (Quote_Decision_Option__mdt qd : QuoteDecisions) {
            List<String> skipStateList = new List<String>();
            list<String> qdPartnerlist=new list<string>();
            if (!string.isEmpty(qd.enabledForPartners__c))
                qdPartnerlist=qd.enabledForPartners__c.split(',');
            if (!String.isBlank(qd.skipstates__C))
                skipStateList=qd.skipstates__C.split(',');
            if(qd.Products__c=='All Products'){
                mapQDSkipstlst.put(qd.Masterlabel,skipStateList);
            }else{
                if(!productDecisionSkipstmap.containsKey(qd.Masterlabel))
                    productDecisionSkipstmap.put(qd.Masterlabel,new Map<string,list<string>>());
                
                productDecisionSkipstmap.get(qd.Masterlabel).put(qd.Products__c,skipStateList);
            }
            partnerQtDecisionmap.put(qd.MasterLabel,qdPartnerlist);
        }
    }    
    List<string> eligibleQDForPartners = new list<String>();

    for (String decision:partnerQtDecisionmap.keySet()) {
        if (partnerQtDecisionmap.get(decision).contains('All Partners') ||partnerQtDecisionmap.get(decision).contains(userinfo.getUserEmail())) 
            eligibleQDForPartners.add(decision);

    }
    for (String decision:mapQDSkipstlst.keyset()){
        if(!mapQDSkipstlst.get(decision).contains(state) && eligibleQDForPartners.contains(decision))
            eligibleDecisions.add(decision);
    }
    for (String decision:productDecisionSkipstmap.keyset()){
        if(eligibleQDForPartners.contains(decision) && productDecisionSkipstmap.containsKey(decision) && productDecisionSkipstmap.get(decision).containsKey(product) && !productDecisionSkipstmap.get(decision).get(product).contains(state))
            eligibleDecisions.add(decision);
    }
    return eligibleDecisions;
}

}