RecordType rt = 
[SELECT Id, Name
  FROM RecordType
  WHERE SobjectType = 'Campaign' AND DeveloperName = 'ILHSalesMarketing'];
List<Campaign> campaigns = [SELECT Id FROM Campaign];
for(Campaign cmp: campaigns){
    cmp.RecordTypeId = rt.id;
}
update campaigns;
