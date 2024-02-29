/**********************************************************************************
 * Title:  ConversionEligibleQuoteResponse
 * Date:   Jan 2024
 * 
 * Description:  Response class for the ConversionEligibleQuote endpoint  
 * 
 *************************************************************************************/
public with sharing class ConversionEligibleQuoteResponse {

	public CurrentTermPolicyInfo currentTermPolicyInfo;
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
		public String contractStatus;
		public Insured insured;
		public Owner owner;
		public String coverageAmount;
		public String underwritingClass;
		public String paidToDate;
		public String paymentMethod;
		public String achAccountNumber;
		public String achRoutingNumber;
		public String paymentFrequency;
		public String reinsuranceIndicator;
		public String planMarketingMethod;
		public String agentId;
		public String contractNumber;
		public String specialHandlingCode;
	}

	public class Quotes {
		public List<ConversionDateQuotes> primaryConversionDateQuotes;
		public List<ConversionDateQuotes> secondaryConversionDateQuotes;
	}

	public class Conversion {
		public CoverageAmounts coverageAmounts;
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
		public String coverageAmount;
		public String monthlyPremiumAmount;
		public String quarterlyPremiumAmount;
		public String semiAnnualPremiumAmount;
		public String annualPremiumAmount;
	}

	public class CoverageAmounts {
		public String minimumCoverageAmount;
		public String maximumCoverageAmount;
	}

	public class IsNotEligibleReasons {
		public String ErrorCode;
		public String ErrorDescription;
	}

	public class Person {
		public Name name;
	}

	public class EligibleBillingOptions {
		public String billingMethod;
		public List<String> billingFrequencies;
	}

	public class ConversionEligibilityDetails {
		public String productCode;
		public String eligibilityStartDate;
		public String eligibilityEndDate;
		public String primaryConversionDate;
		public String secondaryConversionDate;
		public Boolean isEligible;
		public List<IsNotEligibleReasons> isNotEligibleReason;
		public String underwritingClassCode;
		public String underwritingClass;
		public Conversion fullConversion;
		public Conversion partialConversion;
		public List<EligibleBillingOptions> eligibleBillingOptions;
	}

	
	public static ConversionEligibleQuoteResponse parse(String json) {
		return (ConversionEligibleQuoteResponse) System.JSON.deserialize(json, ConversionEligibleQuoteResponse.class);
	}
}