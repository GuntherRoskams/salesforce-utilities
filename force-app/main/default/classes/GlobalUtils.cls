/**
 * @Package: GlobalUtils.cls
 * @Version: 1.0
 * @Author: Gunther Roskams
 * @Copyright: 2020 Forward
 * @Uses: GlobalException.cls
 *
 * -------------------------------------------------------------------
 * Description: Utilities used over the different functionalities
 *
 * Created: 19/04/2020
 * Last Modified: 19/04/2020
 *
 * Unit tests: GlobalUtils_Test.cls
 *
 * Changelog: 
 *
 */

public with sharing class GlobalUtils {
    
    /**
     * @description this function replaces placeholders by pieces of dynamic text
     * Example:
     * --------
     * String sMessage = 'this is {0} {1}';
     * sMessage = GlobalUtils.replairPlaceHolders(sMessage, new Map<String, String>{'{0}' => 'a', '{1}' => 'test'});
     * ==> the function returns 'this is a test'
     *
     * @param sMessage the message with the placeholders
     * @param replacementByPlaceholders the placeholders with their respective content
     *
     * @return the text with the replaced placeholders
     */
    public static String repairPlaceHolders(String sMessage, Map<String, String> replacementByPlaceholders){
        if (String.isNotBlank(sMessage)){
            String sFinalMessage = sMessage;
            for (String sVariableName : replacementByPlaceholders.keySet()){
                String sVariableValue = replacementByPlaceholders.get(sVariableName);sFinalMessage = sFinalMessage.replace(sVariableName, sVariableValue);
            }
            
            return sFinalMessage;
        }
        
        throw new GlobalException('ERR_NO_TEXT', Label.NO_TEXT_FOR_REPLACEMENT);
    }
}