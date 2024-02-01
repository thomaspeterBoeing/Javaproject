//Updating my user record
User myUser = [SELECT id FROM User WHERE id =: UserInfo.getUserId()];
myUser.Persona__c = 'System Admin';
update myUser;