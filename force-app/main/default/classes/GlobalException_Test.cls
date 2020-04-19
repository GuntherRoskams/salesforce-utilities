/**
 * @Package: GlobalException_Test.cls
 * @Version: 1.0
 * @Author: Gunther Roskams
 * @Copyright: 2020 Forward
 * @Uses: 
 *
 * -------------------------------------------------------------------
 * Description: unit tests to test the logic for the class GlobalException.cls
 *
 * Created: 19/04/2020
 * Last Modified: 19/04/2020
 *
 * Changelog: 
 *
 */

@IsTest
private class GlobalException_Test {
    
    /**
     * @description of the test: test the custom (Global) Exception
     * Outcome: the message, configured in the GlobalException parameter, should be the message in the exception
     */
    @IsTest
    private static void test_GlobalException_Regular() {
        String sMessage = 'This is a test message';
        
        Test.startTest();
        GlobalException gEx = new GlobalException(sMessage);
        Test.stopTest();
        
        System.assertEquals(sMessage, gEx.getMessage());
    }
    
    /**
     * @description of the test: test the extended exception with the error code and error message
     * Outcome: the message in the exception is a concatenation of the error code and the error message (separated by a colom)
     */
    @IsTest
    private static void test_GlobalException_ErrorCode() {
        String sMessage = 'This is a test message';
        String sErrorCode = 'ERR_CODE';
        
        Test.startTest();
        GlobalException gEx = new GlobalException(sErrorCode, sMessage);
        Test.stopTest();
        
        System.assertEquals(sErrorCode + ': ' + sMessage, gEx.getMessage());
    }
}