@isTest
public with sharing class CMGFinancialAccountTests {
	@isTest
    static void testCMGFinancialAccount() {
		CMGFinancialAccount.FinancialAccountType FAT = new CMGFinancialAccount.FinancialAccountType();
        FAT.AccountType='tastat';
        FAT.AccountNumber='5454';
        FAT.AccountStatus ='Active'; 
        FAT.EffectiveDate=system.today();
        FAT.TerminationDate=system.today();
        FAT.OriginalBalance=2.3;
        FAT.CurrentBalance=2.5;
        FAT.InterestRate=2.6;
       	FAT.FixedRateFlag=true;
        FAT.OpenEndIndicatorCode='tstoec';    
        
		CMGFinancialAccount.InsuranceProducerType IPT = new CMGFinancialAccount.InsuranceProducerType();
        IPT.Code='tst';
        IPT.Name='tstname';
        
		CMGFinancialAccount.LoanOfficerType LOT = new CMGFinancialAccount.LoanOfficerType();
        LOT.Code='tst';
        LOT.Name='tstname';
	}
}