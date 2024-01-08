//
//

public with sharing class ConsumerEligibleQuoteResponse {

    public class QuoteResponse {
		public List<ProductQuotes> productQuotes;
	}

	public class ProductQuotes {
		public String productCode;
		public Integer issueAge;
		public List<CoverageOptions> coverageOptions;
		public List<Riders> riders;
		public List<Errors> errors;
		public InsuranceProductDetails insuranceProductDetails;
		public List<String> frequency;
        public List<String> billingMethod;
	}

	public class RidersByEffectiveDateList {
		public String effectiveDate;
		public String name;
		public String effectiveMessage;
		public String effectiveAge;
		public Double singleMonthlyRateAmount;
		public Double familyMonthlyRateAmount;
		public IssueAgeRange issueAgeRange;
		public CoverageAmountRange coverageAmountRange;
	}

	public class ADnDInsuranceProductInfo {
		public Integer nonContributoryCoverageAmount;
		public String effectiveDate;
		public Double singleMonthlyRateAmount;
		public Boolean singleMonthlyRateAmountSpecified;
		public Double familyMonthlyRateAmount;
		public Boolean familyMonthlyRateAmountSpecified;
		public IssueAgeRange issueAgeRange;
		public CoverageAmountRange coverageAmountRange;
		public List<CoverageOptions> coverageOptions;
		public List<EligibleBillingOptionsList> eligibleBillingOptionsList;
		public EligibleRiderCoverage eligibleRiderCoverage;
	}
	
		


	public class InsuranceProductDetails {
		public String insuranceProductDisplayName;
		public List<String> endorsementList;
		public Boolean isEndorsed;
		public LifeInsuranceProductInfo lifeInsuranceProductInfo;
		public ADnDInsuranceProductInfo aDnDInsuranceProductInfo;
		public Integer issueAge;
		public Boolean cuNewIssueAllowed;
		public Boolean cuMemberConnectStatus;
		public Boolean cuMerged;
		public Boolean cuActive;
		public String issueStateCode;
		public String systemProductCode;
		public String quoteCoverageID;
		public String quotable;
		public String productType;
		public String lineOfBusiness;
		public String insuranceProductDescription;
		public Boolean returnFlagSpecified;
		public Boolean returnFlag;
		public String insuranceProductCode;
		public String productCategory;
		public Integer perLifeMaxAmount;
		
	}

	public class EligibleIssueAgesList {
		public String genderCode;
		public String tobaccoUseCode;
		public IssueAgeRange issueAgeRange;
	}

	public class IssueAgeRange {
		public String minimumIssueAge;
		public String maximumIssueAge;
	}


	public class EligibleBillingOptionsList {
		public String billingMethodCode;
		public List<String> billingFrequencyCodeList;
		public String effectiveDate;
	}

	public class EligibleCoverageAmountsList {
		public String genderCode;
		public String underwritingClassCode;
		public String coverageBasedOnCode;
		public IssueAgeRange issueAgeRange;
		public CoverageAmountRange coverageAmountRange;
	}

	public class EligibleRiderCoverage {
		public Boolean ridersAvailable;
		public String statusMessage;
		public List<RidersByEffectiveDateList> ridersByEffectiveDateList;
	}



	public class CoverageAmountRange {
		public Integer minimumCoverageAmount;
		public Integer maximumCoverageAmount;
		public Integer coverageIncrementAmount;
	}

	public class LifeInsuranceProductInfo {
		public List<EligibleIssueAgesList> eligibleIssueAgesList;
		public List<EligibleCoverageAmountsList> eligibleCoverageAmountsList;
		public List<EligibleUnderwritingClassList> eligibleUnderwritingClassList;
		public List<EligibleBillingOptionsList> eligibleBillingOptionsList;
	}

	public class FlatExtraAmounts {
		public Double minimumFlatExtraAmount;
		public Double maximumFlatExtraAmount;
	}


	public class EligibleUnderwritingClassList {
		public String underwritingClassCode;
		public String underwritingClassDescription;
		public String tobaccoUseCode;
		public FlatExtraAmounts flatExtraAmounts;
	}

	public class Errors {
		public String description;
		public String code;
	}

	
	public class Riders {
		public String riderName;
		public List<CoverageOptions> riderCoverageOptions;
	}


	
	public class CoverageOptions {
		public Integer coverage;
		public Double premium;
		public String frequency;
		public String productCode;
	}

	
	public static QuoteResponse parse(String json) {
		return (QuoteResponse) System.JSON.deserialize(json, QuoteResponse.class);
	}
}