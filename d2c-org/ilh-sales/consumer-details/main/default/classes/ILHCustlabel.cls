public with sharing class ILHCustlabel {
    @AuraEnabled(cacheable=true)
    public static List<sobject> getAllRecords(String mdtobj){
        

        Schema.sObjectType objectType = Schema.getGlobalDescribe().get(mdtobj);
            Schema.DescribeSObjectResult r = objectType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        String dsql='Select ';
        for(String fieldName : MapofField.keySet())
        {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult F = field.getDescribe();
            System.debug('Field Name: '+F.getName()); 
                dsql=dsql+F.getName()+', ';
        }
        dsql = dsql.substring(0, dsql.lastIndexof(','));
        dsql += ' FROM ' + objectType;
      
            
        

        return Database.query(dsql);
       
}
}