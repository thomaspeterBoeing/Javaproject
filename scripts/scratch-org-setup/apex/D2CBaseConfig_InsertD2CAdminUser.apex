//Random Number for Username
Integer RandomNumber1 = Integer.valueof((Math.random() * 1000));	
String strNumber1 = String.valueOf(RandomNumber1);
Integer RandomNumber2 = Integer.valueof((Math.random() * 1000));	
String strNumber2 = String.valueOf(RandomNumber2);


Profile p = [SELECT Id FROM Profile where Name = 'D2C Administrator'];
UserRole r = [SELECT Id FROM UserRole where Name = 'D2C Admin'];
User u = new User();
u.FirstName = 'Jake';
u.LastName = 'D2CAdmin';
u.ProfileId = p.id;
u.UserRoleId = r.id;
u.Username = 'Jake.D2CAdmin' + strNumber1 + '@' + strNumber2 + 'example.com';
u.Alias = strNumber1 + strNumber2;
u.Email = 'test.d2cAdmin@example.com';
u.TimeZoneSidKey = 'America/Chicago';
u.LocaleSidKey = 'en_US';
u.LanguageLocaleKey = 'en_US';
u.EmailEncodingKey = 'UTF-8';

insert u;
