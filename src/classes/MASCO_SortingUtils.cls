/**
 * Created by Ivan on 12.04.2018.
 */

public with sharing class MASCO_SortingUtils {
//
    //Constants
    //
    public static final Integer ORDER_ASCENDING = 1;
    public static final Integer ORDER_DESCENDING = 2;

    public static final Integer NULL_VALUES_FIRST = 1;
    public static final Integer NULL_VALUES_LAST = 2;
    //

    //
    //Public static methods
    //
    /*public static BRSS_SortingUtils.Parameter deserializeParameter(String parameterInJson)
    {
        return (BRSS_SortingUtils.Parameter)SMF_JsonUtils.deserialize(
            parameterInJson, BRSS_SortingUtils.Parameter.class);
    }*/
    //

    //
    //Data types
    //
    /*this class encapsulates details of a sorting field*/
    public class Parameter
    {
        //
        //Constructors
        //
        public Parameter(String name)
        {
            this(name, ORDER_ASCENDING);
        }

        public Parameter(String name, Integer sortingOrder)
        {
            this(name, sortingOrder, NULL_VALUES_FIRST);
        }

        public Parameter(String name, Integer sortingOrder, Integer nullValuesOrder)
        {
            this.name = name;
            this.sortingOrder = sortingOrder;
            this.nullValuesOrder = nullValuesOrder;
        }
        //

        //
        //Properties
        //
        public String name {get; set;}
        public Integer sortingOrder {get; set;}
        public Integer nullValuesOrder {get; set;}
        //

        //
        //Public methods
        //
        public void reverseSortingOrder()
        {
            if (this.sortingOrder == ORDER_ASCENDING)
            {
                this.sortingOrder = ORDER_DESCENDING;
            }
            else if (this.sortingOrder == ORDER_DESCENDING)
            {
                this.sortingOrder = ORDER_ASCENDING;
            }
        }
        //
    }
    //
}