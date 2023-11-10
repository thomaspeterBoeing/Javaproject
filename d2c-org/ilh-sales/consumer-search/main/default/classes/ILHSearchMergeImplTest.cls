/**
 * Copyright: TruStage
 * Purpose: Units tests for the ILHSearchMergeImpl class
 */
@isTest
public class ILHSearchMergeImplTest {
    @isTest 
    public static void Cps_when_matched_personId(){
        ILHConsumerResultsWrapper sfWrapper = new ILHConsumerResultsWrapper();
        ILHConsumerResultsWrapper cpsWrapper = new ILHConsumerResultsWrapper();
        
        sfWrapper.mySource = ILHConsumerResultsWrapper.Source.SALESFORCE;
        cpsWrapper.mySource = ILHConsumerResultsWrapper.Source.CPS;
        
        ILHConsumerResultsWrapper.SearchResult cps1 = new ILHConsumerResultsWrapper.SearchResult();
        cps1.personId = 'X123456';
        cps1.lastName = 'John';
        cps1.firstName = 'Deer';
        cps1.sourceSystemKeys = new List<String>{'Id1'};
        cps1.dateOfBirth = Date.newInstance(1980,1,1);
        cpsWrapper.results.add(cps1);

        ILHConsumerResultsWrapper.SearchResult cps2 = new ILHConsumerResultsWrapper.SearchResult();
        cps2.personId = 'X222222';
        cps2.lastName = 'James';
        cps2.firstName = 'John';
        cps2.sourceSystemKeys = new List<String>{'Id2'};       
        cps2.dateOfBirth = Date.newInstance(1980,2,1);
        cpsWrapper.results.add(cps2);

        ILHConsumerResultsWrapper.SearchResult sf1 = new ILHConsumerResultsWrapper.SearchResult();
        sf1.personId = 'X123456';
        sf1.lastName = 'Tom';
        sf1.firstName = 'Deer';
        sf1.sourceSystemKeys = new List<String>{'Id3'};
        sf1.dateOfBirth = Date.newInstance(1970,1,1);
        sfWrapper.results.add(sf1);

        List<ILHConsumerResultsWrapper> searchResults = new List<ILHConsumerResultsWrapper>{sfWrapper, cpsWrapper};
       
        Test.startTest();
        ILHConsumerResultsWrapper meargedResult = (new ILHSearchMergeImpl()).mergeResults(searchResults);
        Test.stopTest();        
        Assert.isFalse(meargedResult.results.contains(sf1), 'Salesforce record matched based on personId');
        
    }

    @isTest
    public static void sfresult_when_not_matched(){
        ILHConsumerResultsWrapper sfWrapper = new ILHConsumerResultsWrapper();
        ILHConsumerResultsWrapper cpsWrapper = new ILHConsumerResultsWrapper();
        
        sfWrapper.mySource = ILHConsumerResultsWrapper.Source.SALESFORCE;
        cpsWrapper.mySource = ILHConsumerResultsWrapper.Source.CPS;
        
        ILHConsumerResultsWrapper.SearchResult cps1 = new ILHConsumerResultsWrapper.SearchResult();
        cps1.personId = 'X123456';
        cps1.lastName = 'John';
        cps1.firstName = 'Deer';
        cps1.sourceSystemKeys = new List<String>{'Id1'};
        cps1.dateOfBirth = Date.newInstance(1980,1,1);
        cpsWrapper.results.add(cps1);

        ILHConsumerResultsWrapper.SearchResult cps2 = new ILHConsumerResultsWrapper.SearchResult();
        cps2.personId = 'X222222';
        cps2.lastName = 'James';
        cps2.firstName = 'John';
        cps2.sourceSystemKeys = new List<String>{'Id2'};       
        cps2.dateOfBirth = Date.newInstance(1980,2,1);
        cpsWrapper.results.add(cps2);

        ILHConsumerResultsWrapper.SearchResult sf2 = new ILHConsumerResultsWrapper.SearchResult();
        sf2.personId = 'X999999';
        sf2.lastName = 'Smith';
        sf2.firstName = 'Armstrong';
        sf2.sourceSystemKeys = new List<String>{'Id3'};
        sf2.dateOfBirth = Date.newInstance(1970,1,1);
        sfWrapper.results.add(sf2);

        List<ILHConsumerResultsWrapper> searchResults = new List<ILHConsumerResultsWrapper>{sfWrapper, cpsWrapper};
       
        Test.startTest();
        ILHConsumerResultsWrapper meargedResult = (new ILHSearchMergeImpl()).mergeResults(searchResults);
        Test.stopTest();

        Assert.isTrue(meargedResult.results.contains(sf2), 'Salesforce record not in CPS search result.');

    }

    @isTest
    public static void sfresult_when_matched_based_criteria(){
        ILHConsumerResultsWrapper sfWrapper = new ILHConsumerResultsWrapper();
        ILHConsumerResultsWrapper cpsWrapper = new ILHConsumerResultsWrapper();
        
        sfWrapper.mySource = ILHConsumerResultsWrapper.Source.SALESFORCE;
        cpsWrapper.mySource = ILHConsumerResultsWrapper.Source.CPS;
        
        ILHConsumerResultsWrapper.SearchResult cps1 = new ILHConsumerResultsWrapper.SearchResult();
        cps1.personId = 'X123456';
        cps1.lastName = 'John';
        cps1.firstName = 'Deer';
        cps1.sourceSystemKeys = new List<String>{'Id1'};
        cps1.dateOfBirth = Date.newInstance(1980,1,1);
        cpsWrapper.results.add(cps1);

        ILHConsumerResultsWrapper.SearchResult cps2 = new ILHConsumerResultsWrapper.SearchResult();
        cps2.personId = 'X222222';
        cps2.lastName = 'James';
        cps2.firstName = 'John';
        cps2.sourceSystemKeys = new List<String>{'Id2'};       
        cps2.dateOfBirth = Date.newInstance(1980,2,1);
        cpsWrapper.results.add(cps2);

        ILHConsumerResultsWrapper.SearchResult sf3 = new ILHConsumerResultsWrapper.SearchResult();
        sf3.personId = 'ttttttt';
        sf3.lastName = 'James';
        sf3.firstName = 'John';
        sf3.sourceSystemKeys = new List<String>{'Id2'};
        sf3.dateOfBirth = Date.newInstance(1980,2,1);
        sfWrapper.results.add(sf3);

        List<ILHConsumerResultsWrapper> searchResults = new List<ILHConsumerResultsWrapper>{sfWrapper, cpsWrapper};

        Test.startTest();
        ILHConsumerResultsWrapper meargedResult = (new ILHSearchMergeImpl()).mergeResults(searchResults);
        Test.stopTest();
        for(ILHConsumerResultsWrapper.SearchResult r: meargedResult.results){
            Assert.areNotEqual(r.personId, sf3.personId, 'Salesforce record doesnt exist.');
        }
    }

    @isTest
    public static void sfresult_with_no_person_id_same_sf_id(){
        ILHConsumerResultsWrapper sfWrapper = new ILHConsumerResultsWrapper();
        ILHConsumerResultsWrapper cpsWrapper = new ILHConsumerResultsWrapper();
        
        sfWrapper.mySource = ILHConsumerResultsWrapper.Source.SALESFORCE;
        cpsWrapper.mySource = ILHConsumerResultsWrapper.Source.CPS;
        
        ILHConsumerResultsWrapper.SearchResult cps1 = new ILHConsumerResultsWrapper.SearchResult();
        cps1.lastName = 'John';
        cps1.firstName = 'Deer';
        cps1.sourceSystemKeys = new List<String>{'Id1'};
        cps1.dateOfBirth = Date.newInstance(1980,1,1);
        cpsWrapper.results.add(cps1);

        ILHConsumerResultsWrapper.SearchResult cps2 = new ILHConsumerResultsWrapper.SearchResult();
        cps2.lastName = 'James';
        cps2.firstName = 'John';
        cps2.sourceSystemKeys = new List<String>{'Id2'};       
        cps2.dateOfBirth = Date.newInstance(1980,2,1);
        sfWrapper.results.add(cps2);

        ILHConsumerResultsWrapper.SearchResult cps3 = new ILHConsumerResultsWrapper.SearchResult();
        cps3.lastName = 'Smith';
        cps3.firstName = 'Joe';
        cps3.sourceSystemKeys = new List<String>{'Id2'};      
        cps3.dateOfBirth = Date.newInstance(1980,2,1);
        cpsWrapper.results.add(cps3);

        List<ILHConsumerResultsWrapper> searchResults = new List<ILHConsumerResultsWrapper>{sfWrapper, cpsWrapper};

        Test.startTest();
        ILHConsumerResultsWrapper meargedResult = (new ILHSearchMergeImpl()).mergeResults(searchResults);
        Test.stopTest();
        Assert.areEqual(2, meargedResult.results.size());
        Assert.areEqual(ILHConsumerResultsWrapper.Source.SALESFORCE, meargedResult.results[0].mySource, 'Result is from SF');
        Assert.areEqual(ILHConsumerResultsWrapper.Source.CPS, meargedResult.results[1].mySource, 'Result is from CPS');
    }

    @isTest
    public static void sfresult_when_matched_based_fn_ln_dob(){
        ILHConsumerResultsWrapper sfWrapper = new ILHConsumerResultsWrapper();
        ILHConsumerResultsWrapper cpsWrapper = new ILHConsumerResultsWrapper();
        
        sfWrapper.mySource = ILHConsumerResultsWrapper.Source.SALESFORCE;
        cpsWrapper.mySource = ILHConsumerResultsWrapper.Source.CPS;
        
        ILHConsumerResultsWrapper.SearchResult cps1 = new ILHConsumerResultsWrapper.SearchResult();
        cps1.personId = 'X123456';
        cps1.lastName = 'John';
        cps1.firstName = 'Deer';
        cps1.sourceSystemKeys = new List<String>{'Id1'};
        cps1.dateOfBirth = Date.newInstance(1980,1,1);
        cpsWrapper.results.add(cps1);

        ILHConsumerResultsWrapper.SearchResult sf3 = new ILHConsumerResultsWrapper.SearchResult();
        sf3.personId = 'ttttttt';
        sf3.lastName = 'John';
        sf3.firstName = 'Deer';
        sf3.sourceSystemKeys = new List<String>{'Id2'};
        sf3.dateOfBirth = Date.newInstance(1980,1,1);
        sfWrapper.results.add(sf3);

        List<ILHConsumerResultsWrapper> searchResults = new List<ILHConsumerResultsWrapper>{sfWrapper, cpsWrapper};

        Test.startTest();
        ILHConsumerResultsWrapper meargedResult = (new ILHSearchMergeImpl()).mergeResults(searchResults);
        Test.stopTest();
        Assert.areEqual(1, meargedResult.results.size());
        Assert.areEqual(ILHConsumerResultsWrapper.Source.SALESFORCE, meargedResult.results[0].mySource, 'Result is from SF');
    }

    @isTest
    public static void cps_records_with_multiple_person_contact_ids(){
        ILHConsumerResultsWrapper sfWrapper = new ILHConsumerResultsWrapper();
        ILHConsumerResultsWrapper cpsWrapper = new ILHConsumerResultsWrapper();
        
        sfWrapper.mySource = ILHConsumerResultsWrapper.Source.SALESFORCE;
        cpsWrapper.mySource = ILHConsumerResultsWrapper.Source.CPS;

        ILHConsumerResultsWrapper.SearchResult cps1 = new ILHConsumerResultsWrapper.SearchResult();
        cps1.lastName = 'John';
        cps1.firstName = 'Deer';
        cps1.sourceSystemKeys = new List<String>{'Id1', 'Id2'};
        cps1.dateOfBirth = Date.newInstance(1980,1,1);
        cpsWrapper.results.add(cps1);

        ILHConsumerResultsWrapper.SearchResult sf1 = new ILHConsumerResultsWrapper.SearchResult();
        sf1.lastName = 'James';
        sf1.firstName = 'John';
        sf1.sourceSystemKeys = new List<String>{'Id1'};       
        sf1.dateOfBirth = Date.newInstance(1980,2,1);
        sfWrapper.results.add(sf1);

        ILHConsumerResultsWrapper.SearchResult sf2 = new ILHConsumerResultsWrapper.SearchResult();
        sf2.lastName = 'Smith';
        sf2.firstName = 'Joe';
        sf2.sourceSystemKeys = new List<String>{'Id2'};      
        sf2.dateOfBirth = Date.newInstance(1980,2,1);
        sfWrapper.results.add(sf2);

        List<ILHConsumerResultsWrapper> searchResults = new List<ILHConsumerResultsWrapper>{sfWrapper, cpsWrapper};

        Test.startTest();
        ILHConsumerResultsWrapper meargedResult = (new ILHSearchMergeImpl()).mergeResults(searchResults);
        Test.stopTest();
        Assert.areEqual(2, meargedResult.results.size());
        for(ILHConsumerResultsWrapper.SearchResult r: meargedResult.results){
            Assert.areEqual(ILHConsumerResultsWrapper.Source.SALESFORCE, r.mySource, 'Record is from SF');
        }
    }
}