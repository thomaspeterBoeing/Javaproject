/**
 * @Author: Bernie Shishaye
 * @Create Time: 2023-09-21 21:59:46
 * @Modified by: Bernie Shishaye
 * @Modified time: 2023-09-24 23:12:14
 * @Description:
 */

public with sharing class quoteRequest {
    //int	0-Female; 1- Male
   public Enum GENDER_ENUM {FEMALE, MALE}

    public GENDER_ENUM gender {get; set;}
/*
    gender	Yes	int	0-Female; 1- Male
residentState	conditional	string	Resident State/Postal Code is required
postalCode	conditional	string	Resident State/Postal Code is required
issueAge	conditional	int	Issue Age/Birth Date is required
birthDate	conditional	DateTime	Issue Age/Birth Date is required
channel	No	string	name of ProductQuoteRequestDefaultConfiguration ; default- trustage.com 
requestingSystemName	No	string	source application ; default -trustage.com
contractNumber	No - But pass as empty string	string	Required For ADnD
organizationId	No - But pass as empty string	string	Required For ADnD
asOfDate	No	DateTime	
tobaccoUse	No	int	0-Yes, 1-No
frequency	No	string	"Monthly", "Quarterly", "Semiannual", or "Annual"
billingMethod	No	string	"ACH", "AutomaticWithdrawal", "CheckFree", "CouponBilling", "CreditCard", "DirectBill", "FamilyGroup", "GovernmentAllotment", "ListBill", "NotBilled", "PAC", or "StatementByMail"
partnerCode	No	string	"NA", "LIBERTY MUTUAL", "LIBERTY MUTUAL WEB", "SELECTQUOTE", "ETHOS", "LIVEOPS", "SUTHERLAND", "HEALTHIQ"
agentId	No	string	
sequenceNumber	No	string	
externalTrackingID	No	string	*/
}