public class ConversionEligibleQuoteWrapper {
	@AuraEnabled    
    public CurrentTermPolicyInfo currentTermPolicyInfo;
	@AuraEnabled    
	public ConversionEligibilityDetails conversionEligibilityDetails;
	
	public class Owner {
		public Person person;
		public Organization organization;
	}

	public class Organization {
		public String operationalName;
		public String contractNumber;
	}

	public class CurrentTermPolicyInfo {
		@AuraEnabled    
		public String contractStatus;
		public Insured insured;
		public Owner owner;
		@AuraEnabled
		public String coverageAmount;
		@AuraEnabled
		public String underwritingClass;
		public String paidToDate;
		@AuraEnabled
		public String paymentMethod;
		public String achAccountNumber;
		public String achRoutingNumber;
		@AuraEnabled
		public String paymentFrequency;
		public String reinsuranceIndicator;
		public String planMarketingMethod;
		public String agentId;
		public String contractNumber;
		public String specialHandlingCode;
	}

	public class Quotes {
		@AuraEnabled
		public List<ConversionDateQuotes> primaryConversionDateQuotes;
		@AuraEnabled
		public List<ConversionDateQuotes> secondaryConversionDateQuotes;
	}

	public class Conversion {
		@AuraEnabled
		public CoverageAmounts coverageAmounts;
		@AuraEnabled
		public Quotes quotes;
	}

	public class Insured {
		public Name name;
		public String birthDate;
		public String gender;
	}

	public class Name {
		public String firstName;
		public String middleName;
		public String lastName;
		public String suffix;
	}

	public class ConversionDateQuotes {
		@AuraEnabled
		public String coverageAmount;
		@AuraEnabled
		public String monthlyPremiumAmount;
		@AuraEnabled
		public String quarterlyPremiumAmount;
		@AuraEnabled
		public String semiAnnualPremiumAmount;
		@AuraEnabled
		public String annualPremiumAmount;
	}

	public class CoverageAmounts {
		@AuraEnabled
		public String minimumCoverageAmount;
		@AuraEnabled
		public String maximumCoverageAmount;
	}

	public class IsNotEligibleReasons {
		@AuraEnabled
		public String errorCode;
		@AuraEnabled
		public String errorDescription;
	}

	public class Person {
		public Name name;
	}

	public class EligibleBillingOptions {
		@AuraEnabled
		public String billingMethod;
		@AuraEnabled
		public List<String> billingFrequencies;
	}

	public class ConversionEligibilityDetails {
		@AuraEnabled    
		public String productCode;
		public String eligibilityStartDate;
		public String eligibilityEndDate;
		@AuraEnabled
		public String primaryConversionDate;
		@AuraEnabled
		public String secondaryConversionDate;
		@AuraEnabled
		public Boolean isEligible;
		@AuraEnabled
		public List<IsNotEligibleReasons> isNotEligibleReason;
		@AuraEnabled
		public String underwritingClassCode;
		@AuraEnabled
		public String underwritingClass;
		@AuraEnabled
		public Conversion fullConversion;
		@AuraEnabled
		public Conversion partialConversion;
		@AuraEnabled
		public List<EligibleBillingOptions> eligibleBillingOptions;
	}

    // Parse method to deserialize JSON response
    public static ConversionEligibleQuoteWrapper parseFromJSON(String jsonResponse) {
        return (ConversionEligibleQuoteWrapper) JSON.deserialize(jsonResponse, ConversionEligibleQuoteWrapper.class);
    }
}
