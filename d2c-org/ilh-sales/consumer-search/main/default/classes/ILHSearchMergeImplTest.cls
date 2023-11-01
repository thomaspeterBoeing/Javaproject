/**********************************************************************************
 * Title:  Search Merge Unit Tests
 * Date:   Sept 2023
 * 
 * Description:  Unit Tests for Results Dedupe   
 *  
 *          
 * Modifications:
 *************************************************************************************/
/**
 * @Author: Bernie Shishaye
 * @Create Time: 2023-09-12 12:49:32
 * @Modified by: Bernie Shishaye
 * @Modified time: 2023-09-13 00:28:59
 * @Description: Unit Test for Merging logic- covers all cases.
 */

@isTest
public class ILHSearchMergeImplTest {
    @isTest 
    public static void Cps_when_matched_personId(){
        List<ILHConsumerResultsWrapper> searchResults = new List<ILHConsumerResultsWrapper>();
        
        ILHConsumerResultsWrapper cps1 = new ILHConsumerResultsWrapper();
        cps1.personId = 'X123456';
        cps1.lastName = 'John';
        cps1.firstName = 'Deer';
        cps1.sourceSystemKeys = new List<String>{'Id1'};
        cps1.dateOfBirth = Date.newInstance(1980,1,1);
        cps1.mySource= ILHConsumerResultsWrapper.Source.CPS;
        searchResults.add(cps1);
        ILHConsumerResultsWrapper cps2 = new ILHConsumerResultsWrapper();
        cps2.personId = 'X222222';
        cps2.lastName = 'James';
        cps2.firstName = 'John';
        cps2.sourceSystemKeys = new List<String>{'Id2'};       
        cps2.dateOfBirth = Date.newInstance(1980,2,1);
        cps2.mySource= ILHConsumerResultsWrapper.Source.CPS;
        searchResults.add(cps2);

        ILHConsumerResultsWrapper sf1 = new ILHConsumerResultsWrapper();
        sf1.personId = 'X123456';
        sf1.lastName = 'Tom';
        sf1.firstName = 'Deer';
        sf1.sourceSystemKeys = new List<String>{'Id3'};
        sf1.dateOfBirth = Date.newInstance(1970,1,1);
        sf1.mySource= ILHConsumerResultsWrapper.Source.SALESFORCE;
        searchResults.add(sf1);
       
        Test.startTest();
        List<ILHConsumerResultsWrapper> meargedResults = (new ILHSearchMergeImpl()).mergeResults(searchResults);
        Test.stopTest();        
        Assert.isFalse(meargedResults.contains(sf1), 'Salesforce record matched based on personId');
        
    }

    @isTest
    public static void sfresult_when_not_matched(){
        List<ILHConsumerResultsWrapper> searchResults = new List<ILHConsumerResultsWrapper>();
        
        ILHConsumerResultsWrapper cps1 = new ILHConsumerResultsWrapper();
        cps1.personId = 'X123456';
        cps1.lastName = 'John';
        cps1.firstName = 'Deer';
        cps1.sourceSystemKeys = new List<String>{'Id1'};
        cps1.dateOfBirth = Date.newInstance(1980,1,1);
        cps1.mySource= ILHConsumerResultsWrapper.Source.CPS;
        searchResults.add(cps1);
        ILHConsumerResultsWrapper cps2 = new ILHConsumerResultsWrapper();
        cps2.personId = 'X222222';
        cps2.lastName = 'James';
        cps2.firstName = 'John';
        cps2.sourceSystemKeys = new List<String>{'Id2'};       
        cps2.dateOfBirth = Date.newInstance(1980,2,1);
        cps2.mySource= ILHConsumerResultsWrapper.Source.CPS;
        searchResults.add(cps2);

       
        ILHConsumerResultsWrapper sf2 = new ILHConsumerResultsWrapper();
        sf2.personId = 'X999999';
        sf2.lastName = 'Smith';
        sf2.firstName = 'Armstrong';
        sf2.sourceSystemKeys = new List<String>{'Id3'};
        sf2.dateOfBirth = Date.newInstance(1970,1,1);
        sf2.mySource= ILHConsumerResultsWrapper.Source.SALESFORCE;
        searchResults.add(sf2);
       
        Test.startTest();
        List<ILHConsumerResultsWrapper> meargedResults = (new ILHSearchMergeImpl()).mergeResults(searchResults);
        Test.stopTest();

        Assert.isTrue(meargedResults.contains(sf2), 'Salesforce record not in CPS search result.');

    }

    @isTest
    public static void sfresult_when_matched_based_criteria(){
        List<ILHConsumerResultsWrapper> searchResults = new List<ILHConsumerResultsWrapper>();
        
        ILHConsumerResultsWrapper cps1 = new ILHConsumerResultsWrapper();
        cps1.personId = 'X123456';
        cps1.lastName = 'John';
        cps1.firstName = 'Deer';
        cps1.sourceSystemKeys = new List<String>{'Id1'};
        cps1.dateOfBirth = Date.newInstance(1980,1,1);
        cps1.mySource= ILHConsumerResultsWrapper.Source.CPS;
        searchResults.add(cps1);
        ILHConsumerResultsWrapper cps2 = new ILHConsumerResultsWrapper();
        cps2.personId = 'X222222';
        cps2.lastName = 'James';
        cps2.firstName = 'John';
        cps2.sourceSystemKeys = new List<String>{'Id2'};       
        cps2.dateOfBirth = Date.newInstance(1980,2,1);
        cps2.mySource= ILHConsumerResultsWrapper.Source.CPS;
        searchResults.add(cps2);

        ILHConsumerResultsWrapper sf3 = new ILHConsumerResultsWrapper();
        sf3.personId = 'ttttttt';
        sf3.lastName = 'James';
        sf3.firstName = 'John';
        sf3.sourceSystemKeys = new List<String>{'Id2'};
        sf3.dateOfBirth = Date.newInstance(1980,2,1);
        sf3.mySource= ILHConsumerResultsWrapper.Source.SALESFORCE;
        searchResults.add(sf3);
        Test.startTest();
        List<ILHConsumerResultsWrapper> meargedResults = (new ILHSearchMergeImpl()).mergeResults(searchResults);
        Test.stopTest();
        for(ILHConsumerResultsWrapper r: meargedResults){
            Assert.areNotEqual(r.personId, sf3.personId, 'Salesforce record doesnt exist.');
        }
    }

    @isTest
    public static void sfresult_with_no_person_id_same_sf_id(){
        List<ILHConsumerResultsWrapper> searchResults = new List<ILHConsumerResultsWrapper>();
        
        ILHConsumerResultsWrapper cps1 = new ILHConsumerResultsWrapper();
        cps1.lastName = 'John';
        cps1.firstName = 'Deer';
        cps1.sourceSystemKeys = new List<String>{'Id1'};
        cps1.dateOfBirth = Date.newInstance(1980,1,1);
        cps1.mySource= ILHConsumerResultsWrapper.Source.CPS;
        searchResults.add(cps1);

        ILHConsumerResultsWrapper cps2 = new ILHConsumerResultsWrapper();
        cps2.lastName = 'James';
        cps2.firstName = 'John';
        cps2.sourceSystemKeys = new List<String>{'Id2'};       
        cps2.dateOfBirth = Date.newInstance(1980,2,1);
        cps2.mySource= ILHConsumerResultsWrapper.Source.SALESFORCE;
        searchResults.add(cps2);

        ILHConsumerResultsWrapper cps3 = new ILHConsumerResultsWrapper();
        cps3.lastName = 'Smith';
        cps3.firstName = 'Joe';
        cps3.sourceSystemKeys = new List<String>{'Id2'};      
        cps3.dateOfBirth = Date.newInstance(1980,2,1);
        cps3.mySource= ILHConsumerResultsWrapper.Source.CPS;
        searchResults.add(cps3);

        Test.startTest();
        List<ILHConsumerResultsWrapper> meargedResults = (new ILHSearchMergeImpl()).mergeResults(searchResults);
        Test.stopTest();
        Assert.areEqual(2, meargedResults.size());
        for(ILHConsumerResultsWrapper r: meargedResults){
            Assert.areEqual(ILHConsumerResultsWrapper.Source.CPS, r.mySource, 'Result is from CPS');
        }
    }

    @isTest
    public static void sfresult_when_matched_based_fn_ln_dob(){
        List<ILHConsumerResultsWrapper> searchResults = new List<ILHConsumerResultsWrapper>();
        
        ILHConsumerResultsWrapper cps1 = new ILHConsumerResultsWrapper();
        cps1.personId = 'X123456';
        cps1.lastName = 'John';
        cps1.firstName = 'Deer';
        cps1.sourceSystemKeys = new List<String>{'Id1'};
        cps1.dateOfBirth = Date.newInstance(1980,1,1);
        cps1.mySource= ILHConsumerResultsWrapper.Source.CPS;
        searchResults.add(cps1);

        ILHConsumerResultsWrapper sf3 = new ILHConsumerResultsWrapper();
        sf3.personId = 'ttttttt';
        sf3.lastName = 'John';
        sf3.firstName = 'Deer';
        sf3.sourceSystemKeys = new List<String>{'Id2'};
        sf3.dateOfBirth = Date.newInstance(1980,1,1);
        sf3.mySource= ILHConsumerResultsWrapper.Source.SALESFORCE;
        searchResults.add(sf3);
        Test.startTest();
        List<ILHConsumerResultsWrapper> meargedResults = (new ILHSearchMergeImpl()).mergeResults(searchResults);
        Test.stopTest();
        Assert.areEqual(1, meargedResults.size());
        Assert.areEqual(ILHConsumerResultsWrapper.Source.CPS, meargedResults[0].mySource, 'Result is from SF');
    }
}