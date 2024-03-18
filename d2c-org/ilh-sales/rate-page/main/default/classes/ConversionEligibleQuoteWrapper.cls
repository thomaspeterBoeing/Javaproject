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
		@AuraEnabled
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
		@AuraEnabled
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
		@AuraEnabled
		public Name name;
		@AuraEnabled
		public String birthDate;
		@AuraEnabled
		public String gender;
	}

	public class Name {
		@AuraEnabled
		public String firstName;
		public String middleName;
		@AuraEnabled
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

	// New field to indicate whether to include quotes
    public Boolean includeQuotes;

    // Parse method to deserialize JSON response and return different response nodes based on includeQuotes
	// Conversion CheckEligibility functionality does not need quotes. 
    public static ConversionEligibleQuoteWrapper parseFromJSON(String jsonResponse, Boolean includeQuotes) {
        ConversionEligibleQuoteWrapper wrapper = (ConversionEligibleQuoteWrapper) JSON.deserialize(jsonResponse, ConversionEligibleQuoteWrapper.class);
        if (!includeQuotes) {
            if (wrapper.conversionEligibilityDetails.fullConversion != null) {
                wrapper.conversionEligibilityDetails.fullConversion.quotes = null;
            }
            if (wrapper.conversionEligibilityDetails.partialConversion != null) {
                wrapper.conversionEligibilityDetails.partialConversion.quotes = null;
            }
        }
        return wrapper;
    }
}
