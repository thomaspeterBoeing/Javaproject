RecordType rt = 
[SELECT Id, Name
  FROM RecordType
  WHERE SobjectType = 'Account' AND DeveloperName = 'Consumer'];
 
List<Account> persons = [SELECT Id FROM Account WHERE Type <> 'Credit Union' and RecordTypeID <> ''];
for(Account acc: persons){
    acc.RecordTypeId = rt.id;
 
}

update persons;
