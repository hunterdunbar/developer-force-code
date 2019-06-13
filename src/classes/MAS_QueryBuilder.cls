/**
 * Created by Ivan on 04.04.2018.
 */
public with sharing class MAS_QueryBuilder {

    public String tableName { get; set; }
    public String fieldsTable { get; set; }
    public String whereExpression { get; set; }
    public Integer limitOfResult { get; set; }
    public Integer offsetOfResult { get; set; }

    public static List<String> getFields(String tableName) {
        SObjectType objType = Schema.getGlobalDescribe().get(tableName);
        Map<String, Schema.SObjectField> objMap = objType.getDescribe().fields.getMap();
        List<String> listStrings = new List<String>();
        for (Schema.SObjectField f : objMap.values()) {
            Schema.DescribeFieldResult rfield = f.getDescribe();
            String n = rfield.getName();
            listStrings.add(n);
        }
        return listStrings;
    }

    public String getSelect(String tableName) {
        List<String> listStrings = getFields(tableName);
        String queryString = 'SELECT ';
        if(this.fieldsTable == null) {
            Integer size = listStrings.size() - 1;
            for (Integer i = 0; i <= size; i++) {
                queryString += listStrings[i];
                if (i < size) queryString += ', ';
            }
        } else {
            queryString += ' ' + fieldsTable;
        }
        queryString += ' FROM ' + tableName;
        return queryString;
    }

    public String buildQuery() {
        String queryString = getSelect(tableName);

        if(whereExpression != null) {
            queryString += '  WHERE ' + whereExpression;
        }

        if (limitOfResult >= 0)
        {
            queryString += ' LIMIT ' + limitOfResult;
        }
        if (offsetOfResult >= 0)
        {
            queryString += ' OFFSET ' + offsetOfResult;
        }
        return queryString;
    }

}