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

    public EligibleProductRateWrapper(){}
    public EligibleProductRateWrapper(List<EligibleProductQuoteResult> results) {
        buildGrid(results);
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
     * Purpose: This method builds full grid.
     */
    private void buildGrid(List<EligibleProductQuoteResult> results) {
        eligibleRates = new List<EligibleRateRow>();
        eligibleProducts = new List<EligibleProduct>();
        Map<Integer, List<EligibleRateCell>> coverageMap = new Map<Integer, List<EligibleRateCell>>();

        //Building cells
        for (EligibleProductQuoteResult result : results) {
            eligibleProducts.add(new EligibleProduct(result.productName, result.productCode, result.productCategory));
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
        
        //Sorted results based on coverage
        List<Integer> sortedKeys = new List<Integer>();

        if (coverageMap != null && !coverageMap.isEmpty()) {
            sortedKeys.addAll(coverageMap.keySet());
            sortedKeys.sort();
        }

        //Looping through each coveage and creating a new row
        for (Integer coverage : sortedKeys) {
            EligibleRateRow row = new EligibleRateRow();
            List<EligibleRateCell> cells = coverageMap.get(coverage);//Get all cells based on coverage
            row.coverage = String.valueOf(coverage);

            for (EligibleRateCell cell : cells) {
                if (row.productinfo == null) {
                    row.productinfo = new Map<String, EligibleRateCell>();
                }

                /**
                 * Find an existing cell.  Assign the premium values to the existingCell values
                 */
                EligibleRateCell existingCell = row.productinfo.get(cell.productlabel);
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
            eligibleRates.add(row);//Add the new row
        }
    }
}