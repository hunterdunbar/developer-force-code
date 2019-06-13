/**
 * Created by Ivan on 12.04.2018.
 */

public with sharing class MASCO_DataTableController {

    @AuraEnabled
    public static String getDataTest(DataDescriptor DataDescriptorJson)
    {
        DataDescriptor dd = DataDescriptorJson;

        if(dd.filterCode == 'SummerPlan') {
            dd.sortingFields = new Map<String, Integer>();
            dd.sortingFields.put('MAS_Title__c', 1);
            if(dd.sortingField == 'studentName') {
                dd.sortingFields.put('MAS_Student__r.Name', dd.sortingOrder);
            } else if(dd.sortingField == 'sp1Status') {
                dd.sortingFields.put('MAS_Status__c', dd.sortingOrder);
            } else if(dd.sortingField == 'sp2Status') {
                dd.sortingFields.put('MAS_Title__c', 0);
                dd.sortingFields.put('MAS_Status__c', dd.sortingOrder);
            }
            dd.sortingField = '';
            dd.sortingOrder = null;
        }

        MASCO_SoqlQueryBuilder queryBuilder = new MASCO_SoqlQueryBuilder(dd.fieldSet, dd.objectName);

        if (dd.filterCode != null)
        {
            MASCO_FilterUtils.Filter filter = MASCO_FilterUtils.getFilterByCode(dd.filterCode);
            queryBuilder.condition = filter.buildCondition(dd.filters);
        }

        MASCO_SortingUtils.Parameter sortingParameter = null;
        if (String.isNotBlank(dd.sortingField) && dd.sortingOrder != null)
        {
            sortingParameter = new MASCO_SortingUtils.Parameter(dd.sortingField, dd.sortingOrder);
            queryBuilder.setOrderByBlock(sortingParameter);
        } else if (dd.sortingFields != null && !dd.sortingFields.isEmpty()) {
            List<MASCO_SortingUtils.Parameter> sortingParameters = new List<MASCO_SortingUtils.Parameter>();
            for (String key : dd.sortingFields.keySet()) {
                sortingParameters.add(new MASCO_SortingUtils.Parameter(key, dd.sortingFields.get(key)));
            }
            queryBuilder.setOrderByBlock(sortingParameters);
        }

        if (dd.pageNumber == null)
        {
            dd.pageNumber = 1;
        }
        if (dd.pageSize == null)
        {
            dd.pageSize = 10;
        }
        Integer offsetOfResult = (dd.pageNumber - 1) * dd.pageSize;
        queryBuilder.offsetOfResult = offsetOfResult;
        queryBuilder.limitOfResult = dd.pageSize;

        DataResult dr = new DataResult();
        if(dd.filterCode == 'SummerPlan') {
            return MAS_SummerPlanController.createSummerPlanList(Database.query(queryBuilder.buildQuery()));
        } else {
            dr.sObjectRecords = Database.query(queryBuilder.buildQuery());
            dr.total = Database.countQuery(queryBuilder.buildCountQuery());
        }

        String resultJson = JSON.serialize(dr);
        return resultJson;
    }

    @AuraEnabled
    public static String getData(String DataDescriptorJson)
    {
        DataDescriptor dd = (DataDescriptor)JSON.deserialize(DataDescriptorJson, DataDescriptor.class);

        if(dd.filterCode == 'SummerPlan') {
            dd.sortingFields = new Map<String, Integer>();
            dd.sortingFields.put('MAS_Title__c', 1);
            if(dd.sortingField == 'studentName') {
                dd.sortingFields.put('MAS_Student__r.Name', dd.sortingOrder);
            } else if(dd.sortingField == 'sp1Status') {
                dd.sortingFields.put('MAS_Status__c', dd.sortingOrder);
            } else if(dd.sortingField == 'sp2Status') {
                dd.sortingFields.put('MAS_Title__c', 0);
                dd.sortingFields.put('MAS_Status__c', dd.sortingOrder);
            }
            dd.sortingField = '';
            dd.sortingOrder = null;
        }

        MASCO_SoqlQueryBuilder queryBuilder = new MASCO_SoqlQueryBuilder(dd.fieldSet, dd.objectName);

        if (dd.filterCode != null)
        {
            MASCO_FilterUtils.Filter filter = MASCO_FilterUtils.getFilterByCode(dd.filterCode);
            queryBuilder.condition = filter.buildCondition(dd.filters);
        }

        MASCO_SortingUtils.Parameter sortingParameter = null;
        if (String.isNotBlank(dd.sortingField) && dd.sortingOrder != null)
        {
            sortingParameter = new MASCO_SortingUtils.Parameter(dd.sortingField, dd.sortingOrder);
            queryBuilder.setOrderByBlock(sortingParameter);
        } else if (dd.sortingFields != null && !dd.sortingFields.isEmpty()) {
            List<MASCO_SortingUtils.Parameter> sortingParameters = new List<MASCO_SortingUtils.Parameter>();
            for (String key : dd.sortingFields.keySet()) {
                sortingParameters.add(new MASCO_SortingUtils.Parameter(key, dd.sortingFields.get(key)));
            }
            queryBuilder.setOrderByBlock(sortingParameters);
        }

        if (dd.pageNumber == null)
        {
            dd.pageNumber = 1;
        }
        if (dd.pageSize == null)
        {
            dd.pageSize = 10;
        }
        Integer offsetOfResult = (dd.pageNumber - 1) * dd.pageSize;
        queryBuilder.offsetOfResult = offsetOfResult;
        queryBuilder.limitOfResult = dd.pageSize;

        DataResult dr = new DataResult();

        System.debug(queryBuilder.buildQuery());

        if(dd.filterCode == 'SummerPlan') {
            return MAS_SummerPlanController.createSummerPlanList(Database.query(queryBuilder.buildQuery()));
        } else {
            dr.sObjectRecords = Database.query(queryBuilder.buildQuery());
            dr.total = Database.countQuery(queryBuilder.buildCountQuery());
        }

        String resultJson = JSON.serialize(dr);
        return resultJson;
    }

    //Method for updating a contact. This method returns
    //serialized updated contact, or serialized null in case of an error.
    @AuraEnabled
    public static String updateObject(String objectJson)
    {
        sObject updObject = (sObject)JSON.deserialize(objectJson, sObject.class);
        return JSON.serialize(MASCO_SoqlUtils.performDmlOperation(MASCO_SoqlUtils.DmlOperation.Updating, updObject));
    }

    //Class for storing all required fields for pagination
    public class DataDescriptor
    {
        public String objectName {get; set;}
        public String fieldSet {get; set;}

        public Integer pageNumber {get; set;}
        public Integer pageSize {get; set;}

        public String sortingField {get; set;}
        public Integer sortingOrder {get; set;}

        public Map<String, Integer> sortingFields {get; set;}

        public String filterCode {get; set;}
        public Map<String, String> filters {get; set;}
    }

    //Class for storing result
    public class DataResult
    {
        public List<sObject> sObjectRecords {get; set;}
        public Integer total {get; set;}
    }
}