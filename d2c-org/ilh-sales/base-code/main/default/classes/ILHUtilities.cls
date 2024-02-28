/**
 * Copyright: TruStage
 * Purpose: This class contains ILH Utility methods
 */
public with sharing class ILHUtilities {
    /**
     * Purpose: This method get DI Consumer containers by persona
     * @param persona Name of persona to search on
     * @return List of containers
     */
    public static List<DIConsumerContainer__mdt> getDIConsumerContainer(String persona, String factory) {
        List<DIConsumerContainer__mdt> containers = new List<DIConsumerContainer__mdt>();

        try {
            containers = [SELECT MasterLabel, DeveloperName, Dependencies__c, Persona__c FROM DIConsumerContainer__mdt 
                WHERE Persona__c =: persona AND MasterLabel =: factory WITH USER_MODE];
        } catch (Exception ex) {
            new ErrorLogger(ex, null, 'ILHUtilities.cls', null, 'getDIConsumerContainer', null, null, null);
        }
        return containers;
    }

    /**
     * Purpose: Gets rate comparison interval based on product category
     * @param productCategory Product category to query on
     * @return Rate comparison interval that was found in query
     */
    public static RateComparisonInterval__mdt getRateComparisonInterval(String productCategory) {
        RateComparisonInterval__mdt rci = new RateComparisonInterval__mdt();
        try {
            rci = [SELECT MasterLabel, Interval__c, LowerBound__c, UpperBound__c FROM RateComparisonInterval__mdt WHERE MasterLabel =: productCategory WITH USER_MODE];
        } catch (Exception ex) {
            new ErrorLogger(ex, null, 'ILHUtilities.cls', null, 'getRateComparisonInterval', null, null, null);
        }
        return rci;
    }

    /**
     * Purpose: Get product names and product codes, and the results in a map
     * @return A map of Product Code, Product Name
     */
    public static Map<String, String> getActiveProductsByProductCode() {
        Map<String, String> productMap = new Map<String, String>();
        try {
            List<Product2> products = new List<Product2>();
            products = [SELECT Name, ProductCode FROM Product2 WHERE IsActive =: true WITH USER_MODE];//Get all active products

            for (Product2 product : products) {//Itterate over products and put the name with the corresponding product code
                productMap.put(product.ProductCode, product.Name);
            }
        } catch (Exception ex) {
            new ErrorLogger(ex, null, 'ILHUtilities.cls', null, 'getActiveProductsByProductCode', null, null, null);
        }
        return productMap;
    }
}