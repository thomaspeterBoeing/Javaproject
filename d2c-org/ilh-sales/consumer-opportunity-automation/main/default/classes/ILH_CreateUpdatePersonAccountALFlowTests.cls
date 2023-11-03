@isTest
public with sharing class ILH_CreateUpdatePersonAccountALFlowTests {
    @isTest 
    static void successFlowTest() {
        string flowVar = '[{"name": "inputTxt_ValueA","type": "String","value": "ABC"},{"name": "inputTxt_ValueB","type": "String","value": "DEF"}]';

        test.startTest();
    //        String outputVar = IlhAutoLaunchFlow.startFlow('ILH_CreateUpdatePersonAccountALF', flowVar, 'outputTxt_ValueC');
        test.stopTest();
       
        system.assertEquals('ABCDEF', 'outputVar', 'Error Output Variable Not Correct');

    }
    
}

        
   