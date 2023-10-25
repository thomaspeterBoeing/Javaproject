List<Opportunity> opptylist = New List<Opportunity>();
List<Contact> cntList = [SELECT Id, LastName, AccountId FROM Contact WHERE IsPersonAccount = True];
List<AccountContactRelation> acrList = [SELECT Id,AccountID,ContactID FROM AccountContactRelation];

Map<String,String> acrMap = new Map<String,String>();
For(AccountContactRelation acr : acrList) {
  acrMap.put(acr.ContactId,acr.AccountId);

}


RecordType rt = 
[SELECT Id, Name
  FROM RecordType
  WHERE SobjectType = 'Opportunity' AND DeveloperName = 'ILHSales'];

For(Contact cnt: cntList){    
    
       Opportunity oppty = new Opportunity(); 
       oppty.Name = cnt.LastName + ' Opportunity';
       oppty.CloseDate = System.today();
       oppty.AccountId = cnt.AccountId;
       oppty.RecordTypeId = rt.id;
       oppty.StageName = 'Needs Assessment';
       oppty.Amount = 25000;
       oppty.InsurancePurpose__c = 'Final Expenses';
       oppty.HealthAssessment__c = 'No Health Issues';
       oppty.Affiliation__c = acrMap.get(cnt.id);
       opptylist.add(oppty);      
  
  }
   

insert opptylist;


