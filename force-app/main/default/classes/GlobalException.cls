/**
 * @Package: GlobalException.cls
 * @Version: 1.0
 * @Author: Gunther Roskams
 * @Copyright: See MIT License
 * @Uses: 
 *
 * -------------------------------------------------------------------
 * Description: Custom exception handling model.
 * This exception can be used in any type of custom exception handling
 *
 * This code covers the issue #10
 *
 * Created: 19/04/2020
 * Last Modified: 19/04/2020
 *
 * Unit tests:
 *
 * Changelog: 
 *
 */

public with sharing class GlobalException extends Exception{
    
    /**
     * @description constructor to create an exception with an error code and error message
     * During debug, you can easily find the code, which causes the exception (if you keep your code unique)
     *
     * @param sErrorCode a uniaue error code
     * @param sErrorMessage the error message to display
     */
    public GlobalException(String sErrorCode, String sErrorMessage){
        String sCompleteMessage = sErrorCode + ': ' + sErrorMessage;
        this.setMessage(sCompleteMessage);
    }
}