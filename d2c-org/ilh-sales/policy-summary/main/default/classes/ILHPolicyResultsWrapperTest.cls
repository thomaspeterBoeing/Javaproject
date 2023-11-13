@isTest
public with sharing class ILHPolicyResultsWrapperTest {

    @isTest
    public static void constructorTest(){
        // Creating a mock CMGProductSummary object to simulate the data
        CMGProductSummary.ConsumerProductSummaryType mockProductSummary = new CMGProductSummary.ConsumerProductSummaryType();
        mockProductSummary.ProductNumber = '51LC0234688';
        mockProductSummary.SourceSystemProductKey = 'ISWLN17';
        mockProductSummary.Status ='PENDING';
        mockProductSummary.SourceSystemId = 'EBIXLIFE';
        mockProductSummary.ProductRelationship = 2; 

        // Call getProductRelationshipDescription to populate ProductRelationshipDescription
        String productRelationshipDescription = new ILHPolicyResultsWrapper().getProductRelationshipDescription(String.valueOf(mockProductSummary.ProductRelationship));

        // Create a mock response object to simulate the behavior
        PolicySearchResponse resp = new PolicySearchResponse();
        resp.ConsumerProfileList = new List<CMGCommon.ConsumerProfileType>();

        // Mocking the ConsumerProductSummaryList in ConsumerProfileList
        CMGCommon.ConsumerProfileType consumerProfile = new CMGCommon.ConsumerProfileType();
        consumerProfile.ConsumerProductSummaryList = new List<CMGProductSummary.ConsumerProductSummaryType>();
        consumerProfile.ConsumerProductSummaryList.add(mockProductSummary);

        resp.ConsumerProfileList.add(consumerProfile);

        ILHPolicyResultsWrapper ilhPolResult = new ILHPolicyResultsWrapper(mockProductSummary); // Passing the mock data directly

        // Assert statements based on the values set in the mock object
        System.assertNotEquals(null, ilhPolResult, 'is not null');
        System.assertEquals(mockProductSummary.SourceSystemId, ilhPolResult.SourceSystemId);
        System.assertEquals(mockProductSummary.Status, ilhPolResult.Status);
        System.assertEquals(mockProductSummary.ProductNumber, ilhPolResult.ProductNumber);
        System.assertEquals('Insured', ilhPolResult.ProductRelationshipDescription);
    }

    

}
