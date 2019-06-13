/**
 * Created by Ivan on 12.04.2018.
 */

public with sharing class MASCO_SoqlQueryBuilder {
//
    //Constructors
    //
    public MASCO_SoqlQueryBuilder(String selectedFields, String objectName)
    {
        this.selectedFields = selectedFields;
        this.objectName = objectName;
    }
    //


    //
    //Constants
    //
    private static final String SEPARATOR_OF_SORTING_VALUES = ', ';
    //


    //
    //Public properties
    //
    public String selectedFields {get; set;}
    public String objectName  {get; set;}

    public String condition {get; set;}
    public String searchString {get; set;}

    public String groupByBlockValue {get; set;}
    public String groupByRollupBlockValue {get; set;}
    public String orderByBlockValue {get; set;}
    public String havingBlockValue {get; set;}

    public Integer limitOfResult {get; set;}
    public Integer offsetOfResult {get; set;}
    //


    //
    //Private static methods
    //
    private static String generateSortingValue(MASCO_SortingUtils.Parameter parameter)
    {
        if (parameter == null || String.isBlank(parameter.name))
        {
            return null;
        }

        //1) add sorting field name
        String sortingValue = parameter.name;

        //2) add sorting order
        if (parameter.sortingOrder == MASCO_SortingUtils.ORDER_ASCENDING)
        {
            sortingValue += ' ASC';
        }
        else if (parameter.sortingOrder == MASCO_SortingUtils.ORDER_DESCENDING)
        {
            sortingValue += ' DESC';
        }

        //3) add a strategy of sorting of null values
        if (parameter.nullValuesOrder == MASCO_SortingUtils.NULL_VALUES_FIRST)
        {
            sortingValue += ' NULLS FIRST';
        }
        else if (parameter.nullValuesOrder == MASCO_SortingUtils.NULL_VALUES_LAST)
        {
            sortingValue += ' NULLS LAST';
        }

        return sortingValue;
    }


    //
    //Public methods
    //
    public void setOrderByBlock(MASCO_SortingUtils.Parameter[] sortingParameters)
    {
        //check input parameters
        if (sortingParameters == null)
        {
            this.orderByBlockValue = null;
            return;
        }

        //generate all sorting values
        List<String> sortingValues = new List<String>();
        for (MASCO_SortingUtils.Parameter sortingParameter : sortingParameters)
        {
            String sortingValue = generateSortingValue(sortingParameter);
            if (String.isNotBlank(sortingValue))
            {
                sortingValues.add(sortingValue);
            }
        }

        //generate a final value for sorting
        this.orderByBlockValue = String.join(sortingValues, SEPARATOR_OF_SORTING_VALUES);
    }

    public void setOrderByBlock(MASCO_SortingUtils.Parameter sortingParameter)
    {
        this.setOrderByBlock(new MASCO_SortingUtils.Parameter[] {sortingParameter});
    }

    public String buildQuery()
    {
        //check required data
        if (String.isBlank(this.selectedFields) || String.isBlank(this.objectName))
        {
            return null;
        }

        //create main part of the query
        String soqlQuery = 'SELECT ' + this.selectedFields + ' FROM ' + this.objectName;

        //add WHERE section to the query
        if (String.isNotBlank(this.condition))
        {
            soqlQuery += ' WHERE ' + this.condition;
        }

        //NOTE: we do not need WITH section at this time

        //add GROUP BY or GROUP BY ROLLUP section to the query
        if (String.isNotBlank(this.groupByBlockValue))
        {
            soqlQuery += ' GROUP BY ' + this.groupByBlockValue;
        }
        else if (String.isNotBlank(this.groupByRollupBlockValue))
        {
            soqlQuery += ' GROUP BY ROLLUP (' + this.groupByRollupBlockValue + ')';
        }

        //add HAVING block to the query
        if (String.isNotBlank(this.havingBlockValue))
        {
            soqlQuery += ' HAVING ' + this.havingBlockValue;
        }

        //add ORDER BY block to the query
        if (String.isNotBlank(this.orderByBlockValue))
        {
            soqlQuery += ' ORDER BY ' + this.orderByBlockValue;
        }

        //add LIMIT block to the query (limit must be a non-negative value)
        if (this.limitOfResult >= 0)
        {
            soqlQuery += ' LIMIT ' + this.limitOfResult;
        }

        //add OFFSET block to the query (SOQL offset must be a non-negative value)
        if (this.offsetOfResult >= 0)
        {
            soqlQuery += ' OFFSET ' + this.offsetOfResult;
        }

        return soqlQuery;
    }

    public String buildCountQuery()
    {
        //check required data
        if (String.isBlank(this.objectName))
        {
            return null;
        }

        //create main part of the query
        String soqlQuery = 'SELECT Count() FROM ' + this.objectName;

        //add WHERE section to the query
        if (String.isNotBlank(this.condition))
        {
            soqlQuery += ' WHERE ' + this.condition;
        }


        //add GROUP BY or GROUP BY ROLLUP section to the query
        if (String.isNotBlank(this.groupByBlockValue))
        {
            soqlQuery += ' GROUP BY ' + this.groupByBlockValue;
        }
        else if (String.isNotBlank(this.groupByRollupBlockValue))
        {
            soqlQuery += ' GROUP BY ROLLUP (' + this.groupByRollupBlockValue + ')';
        }

        //add HAVING block to the query
        if (String.isNotBlank(this.havingBlockValue))
        {
            soqlQuery += ' HAVING ' + this.havingBlockValue;
        }

        return soqlQuery;
    }

}