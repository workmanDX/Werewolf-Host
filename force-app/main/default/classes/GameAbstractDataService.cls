/**
 * @description       : 
 * @author            : steven.workman@logmein.com
 * @group             : 
 * @last modified on  : 11-14-2020
 * @last modified by  : steven.workman@logmein.com
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   11-14-2020   steven.workman@logmein.com   Initial Version
**/
public virtual class GameAbstractDataService {
    public sObject getSingleRecord(String objectName, List<sObject> objects) {
        Integer count = objects.size();
        if (count == 0) {
            throw new NoRecordFoundException(
                'No ' +
                objectName +
                ' record found'
            );
        }
        if (count > 1) {
            throw new TooManyRecordFoundException(
                'Too many records, expected single ' +
                objectName +
                ' record'
            );
        }
        return objects.get(0);
    }

    public class NoRecordFoundException extends Exception {
    }
    public class TooManyRecordFoundException extends Exception {
    }
}