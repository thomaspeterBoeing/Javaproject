/**********************************************************************************
 * Title:  ILHPolicy Search Result Wrapper
 * Date:   Oct 2023
 * 
 * Description:  Responses from Consumer Profile Service  -> Product Summary  
 * * 
 *************************************************************************************/

public class ILHPolicyResultsWrapper {
    @AuraEnabled    
    public String ProductNumber;
    @AuraEnabled
    public String SourceSystemProductKey;
    @AuraEnabled    
    public String SourceSystemId;
    @AuraEnabled    
    public String ProductRelationship;
    @AuraEnabled    
    public String ProductRelationshipDescription; // field for the description which will be used in LWC
    @AuraEnabled    
    public String Status;
    @AuraEnabled    
    public String EffectiveDate;
    @AuraEnabled    
    public Date TerminationDate;
    @AuraEnabled    
    public String ContractNumber;
    
    public ILHPolicyResultsWrapper(){        
    }

    /**Constructor that parses service response from CPS to populate inner structure  */
    public ILHPolicyResultsWrapper(CMGProductSummary.ConsumerProductSummaryType productSummary) {
      ProductNumber = productSummary.ProductNumber;
      SourceSystemProductKey = productSummary.SourceSystemProductKey;
      SourceSystemId = productSummary.SourceSystemId;
      ProductRelationship = String.valueOf(productSummary.ProductRelationship);
            
      // Set the description directly in the constructor
      ProductRelationshipDescription = getProductRelationshipDescription(ProductRelationship); 

      Status = productSummary.Status;
      EffectiveDate = String.valueOf(productSummary.EffectiveDate);
      TerminationDate = productSummary.TerminationDate;
      if (productSummary.Organization != null) {
          ContractNumber = productSummary.Organization.ContractNumber;
      }
  }
  
    // Method to get the description based on the integer value
    @TestVisible private String getProductRelationshipDescription(String relationshipValue) {
      if (relationshipValue.equals('0')) {
          return 'blank';
      } else if (relationshipValue.equals('1')) {
          return 'Owner';
      } else if (relationshipValue.equals('2')) {
          return 'Insured';
      } else if (relationshipValue.equals('3')) {
          return 'Account holder';
      } else if (relationshipValue.equals('4')) {
          return 'Quote';
      } else if (relationshipValue.equals('5')) {
          return 'Borrower';
      } else {
          return 'Undefined'; 
      }
  }
 }