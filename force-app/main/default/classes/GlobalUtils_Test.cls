/**
 * @Package: GlobalUtils_Test.cls
 * @Version: 1.0
 * @Author: Gunther Roskams
 * @Copyright: 2020 Forward
 * @Uses: 
 *
 * -------------------------------------------------------------------
 * Description: unit tests to test the logic in the global utils
 *
 * Created: 19/04/2020
 * Last Modified: 19/04/2020
 *
 * Changelog: 
 *
 */

@IsTest
private class GlobalUtils_Test {
    
    /**
     * @description of the test: test of the repairPlaceHolders functionality. The text provided, should be in the initial texts
     * Outcome: the function should return a full replaced string, the placeholders should replaced by the map values
     */
    @IsTest
    private static void testRepairPlaceHolders() {
        String sInitialText = 'Hello {name}, and welcome in the world of {0}';
        Map<String, String> mapReplacements = new Map<String, String>{'{name}' => UserInfo.getName(), '{0}' => 'Salesforce'};
        
        Test.startTest();
        String sReplacedText = GlobalUtils.repairPlaceHolders(sInitialText, mapReplacements);
        Test.stopTest();
        
        System.assertEquals('Hello ' + UserInfo.getName() + ', and welcome in the world of Salesforce', sReplacedText);
    }
    
    /**
     * @description of the test: test of the repairPlaceHolders functionality, without an initial text
     * Outcome: the test should throw an exception
     */
    @IsTest
    private static void testRepairPlaceHoldersWithoutText() {
        String sInitialText = null;
        Map<String, String> mapReplacements = new Map<String, String>{'{name}' => UserInfo.getName(), '{1}' => 'Salesforce'};
        
        Test.startTest();
        try {
            String sReplacedText = GlobalUtils.repairPlaceHolders(sInitialText, mapReplacements);
            System.assert(false);
        } catch (GlobalException ex){
            System.assert(ex.getMessage().containsIgnoreCase(Label.NO_TEXT_FOR_REPLACEMENT));
            System.assert(ex.getMessage().containsIgnoreCase('ERR_NO_TEXT'));
        }
        
        Test.stopTest();
    }
}