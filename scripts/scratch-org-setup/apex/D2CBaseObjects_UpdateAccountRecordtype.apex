RecordType rt = 
[SELECT Id, Name
  FROM RecordType
  WHERE SobjectType = 'Account' AND DeveloperName = 'Affiliation'];
List<Account> creditunions = [SELECT Id FROM Account WHERE Type = 'Credit Union'];
for(Account acc: creditunions){
    acc.RecordTypeId = rt.id;
}
update creditunions;
