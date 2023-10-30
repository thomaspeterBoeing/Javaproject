//Random Number for Username
Integer RandomNumber1 = Integer.valueof((Math.random() * 1000));	
String strNumber1 = String.valueOf(RandomNumber1);
Integer RandomNumber2 = Integer.valueof((Math.random() * 1000));	
String strNumber2 = String.valueOf(RandomNumber2);


Profile p = [SELECT Id FROM Profile where Name = 'ILH Sales Rep'];
User u = new User();
u.FirstName = 'Sam';
u.LastName = 'SalesRep';
u.ProfileId = p.id;
u.Username = 'sam.salespl' + strNumber1 + '@' + strNumber2 + 'example.com';
u.Alias = strNumber1 + strNumber2;
u.Email = 'test.salerep@example.com';
u.TimeZoneSidKey = 'America/Chicago';
u.LocaleSidKey = 'en_US';
u.LanguageLocaleKey = 'en_US';
u.EmailEncodingKey = 'UTF-8';

insert u;

PermissionSetGroup pg = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'ILHSalesRepresentativeRole'];
PermissionSetAssignment psa = new PermissionSetAssignment();
psa.AssigneeId= u.id;
psa.PermissionSetGroupId = pg.id;

insert psa;