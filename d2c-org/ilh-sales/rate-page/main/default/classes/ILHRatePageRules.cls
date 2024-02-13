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

/**
     * Purpose: Calculate the expiration date based on specified rules
     * @param birthdate : Birthdate of the insured
     * @param coverageAmount : Coverage amount of the quote
     * @return : Number of days until expiration
     */
    public static Integer getSIWLQuoteExpiration(Integer age,Integer coverage,Date dob) {

        Integer expirationDays = calculateExpirationDays(dob);
    
        if (expirationDays < 30 && (age == 70 || age == 75 || age == 85)) {
            if ((age == 70 && coverage > 50000) ||
                (age == 75 && coverage > 50000) ||
                (age == 85 && coverage > 25000)) {
                //quote.ExpirationDate = Date.today().addDays(expirationDays - 1);
                expirationDays=expirationDays-1;
                //quote.Expiration_Message__c = 'SIWL quote expires in ' + expirationDays + ' days.';
            } else if ((expirationDays - 182) > 0 && (expirationDays - 182) < 30) {
                expirationDays=expirationDays-183;
                //quote.Expiration_Message__c = 'SIWL quote expires in ' + (expirationDays - 182) + ' days.';
            }
        } else {
            expirationDays=30;
        }
    
        return expirationDays;
    }
    
    private static Integer calculateExpirationDays(Date birthdate) {
        Date birthdateThisYear = Date.newInstance(Date.today().year(), birthdate.month(), birthdate.day());
        Date rightNow=Date.today();
        if (rightNow.daysBetween(birthdateThisYear)< 0) {
            birthdateThisYear = birthdateThisYear.addYears(1);
        }
        return rightNow.daysBetween(birthdateThisYear);
    }
    
    


}