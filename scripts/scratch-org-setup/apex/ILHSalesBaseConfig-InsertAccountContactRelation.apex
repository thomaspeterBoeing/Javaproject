List<Account> accts = [SELECT Id, Name FROM Account WHERE Type = 'Credit Union'];
List<Contact> cnts = [SELECT Id, LastName FROM Contact WHERE IsPersonAccount = True];
List<AccountContactRelation> arcList = new List<AccountContactRelation>();
For(Account acc: accts){
  For(Contact cnt: cnts){
    
    If (cnt.LastName.left(1) == acc.Name.left(1)) 
      {
       AccountContactRelation arc = new AccountContactRelation(); 
       arc.AccountId = acc.Id;
       arc.ContactId = cnt.Id;
       arcList.add(arc);    
      }
  
  }
   
}
insert arcList;


