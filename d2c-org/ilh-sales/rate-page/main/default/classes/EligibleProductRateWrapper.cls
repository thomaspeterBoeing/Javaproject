/***
Copyright: TruStage
Purpose: This class builds a rate grid for the rate page
1.0 - Adam Perschke-Ely   - 1/2/2024  - Created for new D2C Salesfore instance.
***/
public class EligibleProductRateWrapper {
    private static Map<String, String> productMap {get;set;}

    @AuraEnabled
    public List<EligibleProduct> eligibleProducts {get;set;}
    @AuraEnabled
    public List<EligibleRateRow> eligibleRates {get;set;}
    @AuraEnabled
    public Set<EligibleBillingOption> eligibleBillingOptions {get;set;}

    //public EligibleProductRateWrapper();
    public EligibleProductRateWrapper(List<EligibleProductQuoteResult> results) {
        productMap = ILHUtilities.getActiveProductsByProductCode();
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
        public String billingMethod {get;set;}
        @AuraEnabled
        public String effectiveDate {get;set;}

        /**
         * Purpose: Returns the hashcode corresponding to this set and its contents.
         */
        @TestVisible
        public Integer hashCode() {
            return ((String.isNotBlank(billingMethod)? billingMethod: '').toLowerCase() + (String.isNotBlank(effectiveDate)? effectiveDate: '')).hashCode();
        }

        /**
         * Purpose: Compares this set with the specified set and returns true if both sets are equal; otherwise, returns false.
         */
        @TestVisible
        public Boolean equals(Object other) {
            EligibleBillingOption option = (EligibleBillingOption) other;
            if ((option.billingMethod.equalsIgnoreCase(billingMethod) && String.isEmpty(effectiveDate) && String.isNotEmpty(option.effectiveDate)) ||
                !option.billingMethod.equalsIgnoreCase(billingMethod)) {
                return false;
            } else {
                return true;
            }
        }
    }

    /**
     * Purpose: Inner class that contains eligible products to return
     */
    public class EligibleProduct {
        @AuraEnabled
        public String productName;
    
        @AuraEnabled
        public String productCode;
    
        public EligibleProduct(String productName, String productCode) {
            this.productName = productName;
            this.productCode = productCode;
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
        eligibleBillingOptions = new Set<EligibleBillingOption>();

        //Building cells
        for (EligibleProductQuoteResult result : results) {
            String productName = productMap.get(result?.productCode);//Get product name from map

            eligibleProducts.add(new EligibleProduct(productName, result.productCode));
            buildCoverageOptions(result, coverageMap);
            buildBillingOptions(result, eligibleBillingOptions);
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
            String productName = productMap.get(result?.productCode);//Get product name from map
            EligibleRateCell cell = new EligibleRateCell();

            if (cells == null) {
                cells = new List<EligibleRateCell>();
            }

            cell.productlabel = productName;
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
     * @param eligibleBillingOptions Pass-by-value parameter
     */
    private void buildBillingOptions(EligibleProductQuoteResult result, Set<EligibleBillingOption> eligibleBillingOptions) {
        for (EligibleProductQuoteResult.BillingOption billOption : result?.billingOptions) {
            EligibleBillingOption newBillOption = new EligibleBillingOption();
            newBillOption.effectiveDate = billOption?.effectiveDate;
            newBillOption.billingMethod = billOption?.billingMethod;
            eligibleBillingOptions.add(newBillOption);
        }
    }
}