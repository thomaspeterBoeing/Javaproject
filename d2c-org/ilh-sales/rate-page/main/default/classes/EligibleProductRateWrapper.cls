/***
Copyright: TruStage
Purpose: This class builds a rate grid for the rate page
1.0 - Adam Perschke-Ely   - 1/2/2024  - Created for new D2C Salesfore instance.
***/
public class EligibleProductRateWrapper {
    @AuraEnabled
    public List<EligibleProduct> eligibleProducts {get;set;}
    @AuraEnabled
    public List<EligibleRateRow> eligibleRates {get;set;}
    @AuraEnabled
    public Set<String> eligibleBillingMethods {get;set;}
    @AuraEnabled
    public Map<String, EligibleBillingOption> eligibleBillingOptions {get;set;}

    //public EligibleProductRateWrapper();
    public EligibleProductRateWrapper(List<EligibleProductQuoteResult> results) {
        wrapResults(results);
    }

    /**
     * Purpose: This inner class builds a row for rate grid
     */
    public class EligibleRateRow {
        @AuraEnabled
        public String coverage {get;set;}
        @AuraEnabled
        public Map<String, EligibleRateCell> productinfo {get;set;}//Product Name as key.  Cell as value
    }

    /**
     * Purpose: This inner class builds a cell for rate grid
     */
    public class EligibleRateCell {
        @AuraEnabled
        public Integer coverage {get;set;}
        @AuraEnabled
        public Decimal annual {get;set;}
        @AuraEnabled
        public Decimal monthly {get;set;}
        @AuraEnabled
        public Decimal quarterly {get;set;}
        @AuraEnabled
        public Decimal semiannual {get;set;}
        @AuraEnabled
        public String productcode {get;set;}
        @AuraEnabled
        public String productlabel {get;set;}
    }

    public class EligibleBillingOption {
        @AuraEnabled
        public String effectiveDate {get;set;}
        @AuraEnabled
        public Set<String> billingFrequencies {get;set;}
    }

    /**
     * Purpose: Inner class that contains eligible products to return
     */
    public class EligibleProduct {
        @AuraEnabled
        public String productCategory;
    
        @AuraEnabled
        public String label;
    
        @AuraEnabled
        public String value;
    
        public EligibleProduct(String value, String label, String productCategory) {
            this.value = value;
            this.label = label;

            if (String.isNotEmpty(productCategory)) {
                if (productCategory.equalsIgnoreCase('ADD') || productCategory.equalsIgnoreCase('Conversion')) {
                    this.productCategory = productCategory;
                } else {
                    this.productCategory = 'Life';
                }
            }
        }
    }

    /**
     * Purpose: Wraps quote results in a format that can be consumed by UI
     * @param results Results from quote service
     */
    private void wrapResults(List<EligibleProductQuoteResult> results) {
        Map<Integer, List<EligibleRateCell>> coverageMap = new Map<Integer, List<EligibleRateCell>>();
        List<Integer> coverages = new List<Integer>();//Sorted results based on coverage
        eligibleRates = new List<EligibleRateRow>();
        eligibleProducts = new List<EligibleProduct>();
        eligibleBillingMethods = new Set<String>();
        eligibleBillingOptions = new Map<String, EligibleBillingOption>();

        //Building cells
        for (EligibleProductQuoteResult result : results) {
            eligibleProducts.add(new EligibleProduct(result.productName, result.productCode, result.productCategory));
            buildCoverageOptions(result, coverageMap);
            buildBillingOptions(result, eligibleBillingMethods, eligibleBillingOptions);
        }

        if (coverageMap != null && !coverageMap.isEmpty()) {
            coverages.addAll(coverageMap.keySet());//Add all coverages
            coverages.sort();//Sort coverages
        }

        eligibleRates = buildRates(coverages, coverageMap);//Assign eligible rates
    }

    /**
     * Purpose: Builds coverage options for wrapper class
     * @param result Result from quote service
     * @param coverageMap Contains list of cells for each coverage
     */
    private void buildCoverageOptions(EligibleProductQuoteResult result, Map<Integer,List<EligibleProductRateWrapper.EligibleRateCell>> coverageMap) {
        for (EligibleProductQuoteResult.CoverageOption co : result.coverages) {
            List<EligibleRateCell> cells = coverageMap.get(co.coverage);//Get any existing cells based on coverage
            EligibleRateCell cell = new EligibleRateCell();

            if (cells == null) {
                cells = new List<EligibleRateCell>();
            }

            cell.productlabel = result?.productName;
            cell.productcode = result?.productCode;
            cell.coverage = co?.coverage;

            if (co.frequency == 'Annual') {
                cell.annual = co.premium;
            } else if (co.frequency == 'Monthly') {
                cell.monthly = co.premium;
            } else if (co.frequency == 'Quarterly') {
                cell.quarterly = co.premium;
            } else if (co.frequency == 'Semiannual') {
                cell.semiannual = co.premium;
            }
                    
            cells.add(cell);//Adding new cell to list of cells
            coverageMap.put(co.coverage, cells);//Add cells to map based on coverage
        }
    }

    /**
     * Purpose: Builds rates for wrapper class
     * @param coverages Represents list of coverages
     * @param coverageMap Contains list of cells for each coverage
     */
    private List<EligibleRateRow> buildRates(List<Integer> coverages, Map<Integer,List<EligibleProductRateWrapper.EligibleRateCell>> coverageMap) {
        List<EligibleRateRow> rates = new List<EligibleRateRow>();
        //Looping through each coveage and creating a new row
        for (Integer coverage : coverages) {
            EligibleRateRow row = new EligibleRateRow();
            List<EligibleRateCell> cells = coverageMap.get(coverage);//Get all cells based on coverage
            row.coverage = String.valueOf(coverage);
            buildRateInfo(cells, row);
            rates.add(row);//Add the new row
        }
        return rates;
    }

    /**
     * Purpose: Builds rate info for rate cells
     * @param cells Cells that have been built.  We will additional information to these cells
     * @param row Pass-by-value parameter
     */
    private void buildRateInfo(List<EligibleRateCell> cells, EligibleRateRow row) {
        for (EligibleRateCell cell : cells) {
            if (row.productinfo == null) {
                row.productinfo = new Map<String, EligibleRateCell>();
            }

            EligibleRateCell existingCell = row.productinfo.get(cell.productlabel);//Find an existing cell.  Assign the premium values to the existingCell values
            if (existingCell != null) {
                if (cell.annual != null) {
                    existingCell.annual = cell.annual;
                } else if (cell.monthly != null) {
                    existingCell.monthly = cell.monthly;
                } else if (cell.quarterly != null) {
                    existingCell.quarterly = cell.quarterly;
                } else if (cell.semiannual != null) {
                    existingCell.semiannual = cell.semiannual;
                }
                row.productinfo.put(cell.productlabel, existingCell);//Updating the existing cell
            } else {
                row.productinfo.put(cell.productlabel, cell);//We don't have an existing cell, so add the new cell
            }
        }
    }

    /**
     * Purpose: Builds billing options for wrapper class
     * @param result Result from quote service
     * @param eligibleBillingMethods Pass-by-value parameter
     * @param eligibleBillingOptions Pass-by-value parameter
     */
    private void buildBillingOptions(EligibleProductQuoteResult result, Set<String> eligibleBillingMethods, Map<String, EligibleBillingOption> eligibleBillingOptions) {
        for (EligibleProductQuoteResult.BillingOption bo : result.billingOptions) {
            EligibleBillingOption currentBo = eligibleBillingOptions.get(bo.billingMethod);//Get a billing option based on current billing method

            if (currentBo == null) {
                currentBo = new EligibleBillingOption();
            }

            currentBo.effectiveDate = bo?.effectiveDate;//Set effective date for current billing option
            eligibleBillingOptions.put(bo.billingMethod, currentBo);//Add the current billing option and associate it to the current billing method
            eligibleBillingMethods.add(bo.billingMethod);//Add the current billing method to list of eligible billing methods
        }
    }
}