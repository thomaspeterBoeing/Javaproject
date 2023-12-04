User autoUser = [SELECT Id FROM User where Name = 'Automated Process'];

PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'API_Connect_Principal_Access'];

PermissionSetAssignment psa = new PermissionSetAssignment();
psa.AssigneeId= autoUser.id;
psa.PermissionSetId = ps.id;

insert psa;
