/**
 * Created by Ivan on 12.04.2018.
 */

public with sharing class MASCO_SoqlUtils {
    //
    //Data types
    //
    //This enumeration contains logic operators which are used in SOQL-queries
    public enum LogicOperator
    {
        AND_Operator,
        OR_Operator
    }

    //This enumeration contains all DML operations
    public enum DmlOperation
    {
        Deleting,
        Inserting,
        Updating,
        Undeleting,
        Upserting
    }

    public interface IQueryCreator
    {
        String createQuery();
    }

    public class DmlParameters
    {
        //
        //Constructors
        //
        public DmlParameters()
        {
            this.initialize();
        }

        public DmlParameters(Boolean disableTriggers)
        {
            this.initialize();
            this.disableTriggers = disableTriggers;
        }
        //

        //
        //Properties
        //
        /*this property allows us to temporary disable all triggers during the DML-
        operation (it's actual only for trigers that support disabling via the
        custom setting) . If it's set to true, then triggers will be disabled,
        if it's set to false then the state of triggers will depend on custom
        settigns. So, when it's set to false then it doesn't mean that triggers
        will be enabled, because we can disable all triggers in	custom settings*/
        public Boolean disableTriggers {get; set;}
        //

        //
        //Private methods
        //
        private void initialize()
        {
            this.disableTriggers = false;
        }
        //
    }
    //

    //
    //Constants
    //
    public static final List<String> SPECIAL_CHARS_FOR_LIKE_OPERATOR = new String[] {'%', '_', '\''};
    //

    //
    //Private static methods
    //
    @TestVisible
    private static String createSeparatorForConditions(LogicOperator logicOperator)
    {
        if (logicOperator == MASCO_SoqlUtils.LogicOperator.AND_Operator)
        {
            return ' AND ';
        }
        else if (logicOperator == MASCO_SoqlUtils.LogicOperator.OR_Operator)
        {
            return ' OR ';
        }
        else
        {
            return null;
        }
    }

    /**
     * Generate MASCO_DmlOperationResult from Dml exception
     */
    private static MASCO_DmlOperationResult parseErrors(MASCO_DmlOperationResult result, System.DmlException e, sObject objectValue)
    {
        result.errorItems = new List<MASCO_DmlOperationResult.ErrorFieldItem>();
        result.errors = new List<MASCO_DmlOperationResult.ErrorItem>();
        for (Integer i = 0; i < e.getNumDml(); i++)
        {
            if (e.getDmlType(i) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION)
            {
                if (e.getDmlFields(i).size() != 0)
                {
                    for (Integer j = 0; j < e.getDmlFields(i).size(); j++)
                    {
                        MASCO_DmlOperationResult.ErrorFieldItem ei = new MASCO_DmlOperationResult.ErrorFieldItem();
                        ei.fieldName = e.getDmlFields(i).get(j).getDescribe().getName();
                        ei.errorMessage = e.getDmlMessage(i);
                        result.errorItems.add(ei);
                    }
                }
                else
                {
                    MASCO_DmlOperationResult.ErrorItem ei = new MASCO_DmlOperationResult.ErrorItem();
                    ei.message = e.getDmlMessage(i);
                    result.errors.add(ei);
                }
            }
            else if (e.getDmlType(i) == StatusCode.REQUIRED_FIELD_MISSING)
            {
                //For REQUIRED_FIELD_MISSING status e.getDmlFields() returns null
                Map<String, Schema.SObjectField> m = objectValue.getSObjectType().getDescribe().fields.getMap();
                for (String key : m.keySet())
                {
                    for (Integer j = 0; j < e.getDmlFieldNames(i).size(); j++)
                    {
                        if (m.get(key).getDescribe().getLabel() == e.getDmlFieldNames(i).get(j))
                        {
                            MASCO_DmlOperationResult.ErrorFieldItem ei = new MASCO_DmlOperationResult.ErrorFieldItem();
                            ei.fieldName = m.get(key).getDescribe().getName();
                            ei.errorMessage = 'Required field is missing';
                            result.errorItems.add(ei);
                        }
                    }
                }
            }
            else if (e.getDmlType(i) == StatusCode.INVALID_EMAIL_ADDRESS)
            {
                for (Integer j = 0; j < e.getDmlFields(i).size(); j++)
                {
                    MASCO_DmlOperationResult.ErrorFieldItem ei = new MASCO_DmlOperationResult.ErrorFieldItem();
                    ei.fieldName = e.getDmlFields(i).get(j).getDescribe().getName();
                    ei.errorMessage = 'Invalid Email address';
                    result.errorItems.add(ei);
                }
            }
            else
            {
                MASCO_DmlOperationResult.ErrorItem ei = new MASCO_DmlOperationResult.ErrorItem();
                ei.message = e.getDmlMessage(i);
                result.errors.add(ei);
            }
        }
        return result;
    }

    //Method performs dml operation
    public static MASCO_DmlOperationResult performDmlOperation(DmlOperation dmlOperation, sObject objectValue)
    {
        MASCO_DmlOperationResult result = new MASCO_DmlOperationResult();
        if (dmlOperation == null || objectValue == null)
        {
            result.success = false;
            return result;
        }
        try
        {
            if (dmlOperation == MASCO_SoqlUtils.DmlOperation.Updating)
            {
                update objectValue;
                result.result = objectValue;
                result.success = true;
            }
            else if (dmlOperation == MASCO_SoqlUtils.DmlOperation.Inserting)
            {
                insert objectValue;
                result.result = objectValue;
                result.success = true;
            }
            else if (dmlOperation == MASCO_SoqlUtils.DmlOperation.Deleting)
            {
                delete objectValue;
                result.success = true;
            }
            else if (dmlOperation == MASCO_SoqlUtils.DmlOperation.Upserting)
            {
                upsert objectValue;
                result.success = true;
            }
        }
        catch (System.DmlException e)
        {
            System.debug(e);
            result.success = false;
            result = parseErrors(result, e, objectValue);
        }
        System.debug(result);
        return result;
    }

    public static void performDmlOperation(DmlOperation dmlOperation, List<sObject> objects)
    {
        callDmlOperation(dmlOperation, objects);
    }

    //method simply performs query but catches all possible problems and exceptions
    public static List<sObject> performQuery(String soqlCommand)
    {
        //check input parameters
        if (String.isBlank(soqlCommand))
        {
            return null;
        }

        List<sObject> listOfObjects;
        try
        {
            listOfObjects = Database.query(soqlCommand);
        }
        catch (System.QueryException e)
        {
            System.debug(Logginglevel.ERROR, e);
            listOfObjects = null;
        }

        return listOfObjects;
    }

    //method simply performs query but catches all possible problems and exceptions and returns single object  
    public static sObject performSingleResultQuery(String soqlCommand)
    {
        sObject resultObject = null;

        List<sObject> listOfsObjects = performQuery(soqlCommand);
        if (listOfsObjects != null && listOfsObjects.size() > 0)
        {
            resultObject = listOfsObjects[0];
        }

        return resultObject;
    }

    public static List<sObject> performQuery(MASCO_SoqlQueryBuilder queryBuilder)
    {
        if (queryBuilder == null)
        {
            return null;
        }

        return performQuery(queryBuilder.buildQuery());
    }

    public static sObject performSingleResultQuery(MASCO_SoqlQueryBuilder queryBuilder)
    {
        if (queryBuilder == null)
        {
            return null;
        }

        return performSingleResultQuery(queryBuilder.buildQuery());
    }

    public static Database.QueryLocator createQueryLocator(String queryString)
    {
        if (String.isBlank(queryString))
        {
            return null;
        }

        Database.QueryLocator queryLocator;
        try
        {
            queryLocator = Database.getQueryLocator(queryString);
        }
        catch (System.QueryException e)
        {
            System.debug(Logginglevel.ERROR, e);
            queryLocator = null;
        }
        return queryLocator;
    }

    public static Database.QueryLocator createEmptyQueryLocator()
    {
        //initialize a query locator which doesn't return objects
        return createQueryLocator('SELECT Id FROM Account LIMIT 0');
    }
    //

    //
    //Public static service methods
    //
    //method returns string with escaped special SOQL chars 
    public static String escapeSpecialCharsForLikeOperator(String sourceString)
    {
        if (sourceString == null)
        {
            return null;
        }

        String resultString = sourceString;
        for (String specialChar : SPECIAL_CHARS_FOR_LIKE_OPERATOR)
        {
            resultString = resultString.replace(specialChar, '\\' + specialChar);
        }
        return resultString;
    }

    public static String escapeSpecialCharsForSimpleCondition(String sourceString)
    {
        if (sourceString == null)
        {
            return null;
        }

        return String.escapeSingleQuotes(sourceString);
    }

    public static String joinConditions(List<String> listOfConditions, LogicOperator logicOperator)
    {
        //check input parameters
        if (listOfConditions == null || logicOperator == null)
        {
            return null;
        }

        //result condition
        String fullCondition = null;

        String separatorForConditions = createSeparatorForConditions(logicOperator);
        //if type of an operator is unknown then the method couldn't create a separator for it
        if (!String.isBlank(separatorForConditions))
        {
            Boolean conditionExpressionCreated = false;
            for (String condition : listOfConditions)
            {
                if (!String.isBlank(condition))
                {
                    if(conditionExpressionCreated)
                    {
                        fullCondition += separatorForConditions;
                    }
                    else
                    {
                        fullCondition = '';
                        conditionExpressionCreated = true;
                    }
                    fullCondition += '(' + condition + ')';
                }
            }
        }

        return fullCondition;
    }

    public static String joinStringsForINSection(List<String> listOfStrings)
    {
        //check input parameters
        if (listOfStrings == null)
        {
            return null;
        }

        Set<String> setOfStrings = new Set<String>(listOfStrings);
        //remove null and empty strings, because they are not useful for IN-conditions
        setOfStrings.remove(null);
        setOfStrings.remove('');

        String resultString = null;
        if (setOfStrings.size() > 0)
        {
            resultString = String.join(new List<String>(setOfStrings), '\',\'');
            //if result string contains chars then we should wrap it by quotes, because
            //they were not added by join-function
            if (String.isNotBlank(resultString))
            {
                resultString = '\'' + resultString + '\'';
            }
        }

        return resultString;
    }

    //this method formats date from Date object and set start time of the day
    public static String formatDateTime(Date sourceDate)
    {
        //check input parameters
        if (sourceDate == null)
        {
            return null;
        }

        Datetime sourceDateTime =
                DateTime.newInstanceGmt(sourceDate.year(), sourceDate.month(), sourceDate.day(), 0, 0, 0);
        return formatDateTime(sourceDateTime);
    }

    //this method formats date and time from DateTime object
    public static String formatDateTime(DateTime sourceDateTime)
    {
        //check input parameters
        if (sourceDateTime == null)
        {
            return null;
        }

        return sourceDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }

    //this method formats date from Date object
    public static String formatDate(Date sourceDate)
    {
        //check input parameters
        if (sourceDate == null)
        {
            return null;
        }
        Datetime sourceDateTime =
                DateTime.newInstance(sourceDate.year(), sourceDate.month(), sourceDate.day(), 0, 0, 0);
        return formatDate(sourceDateTime);
    }

    //this method formats date from DateTime object
    public static String formatDate(DateTime sourceDateTime)
    {
        //check input parameters
        if (sourceDateTime == null)
        {
            return null;
        }

        return sourceDateTime.format('yyyy-MM-dd');
    }
    //

    //NOTE: the following method processes standard and non-standard DML operations. All DML operations
    //can be performed for a list of objects, but it is important to know that non-standard DML
    //operations (upsert and undelete) can be performed only for lists which contain objects of
    //a concrete type. If you try to instantiate sObject-list in a code and then call
    //the method below for this list then System.TypeException will occur and you'll get false result.
    //THE FIRST WAY TO AVOID this problem is that you should use only lists which contain objects of
    //a concrete type when you want to perform an upsert or undelete operation.
    //ANOTHER WAY is to call these operations in for-loop for an every single object (this way is bad
    //because of the limit 'Total number of DML statements issued = 150', every DML statement
    //(for list or for single object) counts against the number of allowed DML queries. So it is more
    //effective to use the FIRST WAY).
    public static Boolean tryPerformDmlOperation(DmlOperation dmlOperation, sObject[] objects)
    {
        //1 STEP: check input parameters
        //we can't perform DML operation if some parameters are not correct
        if (dmlOperation == null || objects == null)
        {
            return false;
        }

        //2 STEP: perform DML operation
        Boolean isOperationSuccessful = true;
        try
        {
            //simply call DML operation
            callDmlOperation(dmlOperation, objects);
        }
        catch (System.Exception e)
        {
            System.debug(LoggingLevel.ERROR, e);
            isOperationSuccessful = false;
        }

        return isOperationSuccessful;
    }

    //method performs DML operation for sObject-list
    @TestVisible
    private static void callDmlOperation(DmlOperation dmlOperation, sObject[] objects)
    {
        if (dmlOperation == MASCO_SoqlUtils.DmlOperation.Updating)
        {
            update objects;
        }
        else if (dmlOperation == MASCO_SoqlUtils.DmlOperation.Inserting)
        {
            insert objects;
        }
        else if (dmlOperation == MASCO_SoqlUtils.DmlOperation.Deleting)
        {
            delete objects;
        }
        else if (dmlOperation == MASCO_SoqlUtils.DmlOperation.Upserting)
        {
            upsert objects;
        }
        else if (dmlOperation == MASCO_SoqlUtils.DmlOperation.Undeleting)
        {
            undelete objects;
        }
        else
        {
            throw new NullPointerException();
        }
    }
}