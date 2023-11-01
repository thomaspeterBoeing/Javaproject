public class CMGFinancialAccount {
    
    public class FinancialAccountType {
        public string AccountType { get; set; }
        public string AccountNumber { get; set; }
        public string AccountStatus { get; set; }
        public Date EffectiveDate { get; set; }
        public Date TerminationDate { get; set; }
        public decimal OriginalBalance { get; set; }
        public decimal CurrentBalance { get; set; }
        public decimal InterestRate { get; set; }
        public boolean FixedRateFlag { get; set; }
        public string OpenEndIndicatorCode { get; set; }
    }
    
    public class InsuranceProducerType {
        public string Code { get; set; }
        public string Name { get; set; }
    }
    
    public class LoanOfficerType {
        public string Code { get; set; }
        public string Name { get; set; }
    }
}