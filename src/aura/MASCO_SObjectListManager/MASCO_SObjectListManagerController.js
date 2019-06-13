({
    /**
     * Compile all page parameters to object for DatatableController
     * @param cmp
     * @param event
     * @param helper
     */
    renderTable: function (cmp, event, helper) {
        if (!cmp.get("v.wait")) {
            var objectName = cmp.get("v.objectName");

            //Pagination parameters
            var pageSet = cmp.get("v.pageSet");
            var page = pageSet[0].pageNumber;
            var pageSize = pageSet[0].pageSize;

            //Sorting parameters for Sort by one field
            var sortSetString = cmp.get("v.sortSet");
            var sortSet = {};
            if (typeof sortSetString == "string") {
                var sortSetStringArr = sortSetString.split("'");
                sortSetString = sortSetStringArr.join('"');
                sortSet = JSON.parse(sortSetString);
            } else {
                sortSet = sortSetString;
            }
            var sortField = sortSet != null ? sortSet.sortingField : null;
            var asc = sortSet != null ? sortSet.asc : null;

            //Sorting parameters for sort by list of fields
            var sortingFields = cmp.get("v.sortingFields");

            //Filters
            var filters = cmp.get("v.filters");
            var filterCode = cmp.get("v.filterCode");

            //Field Set
            var fieldSet = cmp.get("v.fieldSet");
            var fields = [];
            var fieldsCount = fieldSet.length;
            for (var i = 0; i < fieldsCount; i++) {
                if (fieldSet[i].forBase != false) {
                    fields.push(fieldSet[i].name);
                }
            }

            //Object for DataTableController
            var pwObject = {
                "objectName": objectName,
                "fieldSet": fields.join(', '),
                "pageNumber": page,
                "pageSize": pageSize,
                "filters": filters,
                "filterCode": filterCode
            };

            //Set sorting parameters to object
            if (sortField != null || sortingFields == null) {
                pwObject['sortingField'] = sortField;
                pwObject['sortingOrder'] = asc ? 1 : 2;
            } else {
                pwObject['sortingFields'] = sortingFields;
            }

            helper.getTable(cmp, pwObject);
        }
    },

    /**
     * Change Sorting
     * @param cmp
     * @param event
     */
    sortBy: function (cmp, event) {
        var asc = event.getParam("asc");
        var sortingField = event.getParam("sortingField");
        var sortSet = {
            "sortingField": sortingField,
            "asc": asc
        };
        cmp.set("v.sortSet", sortSet);
        cmp.refreshTable();
    },

    /**
     * Change pagination
     * @param cmp
     * @param event
     */
    pageChange: function (cmp, event) {
        //If pagination event associated with current component
        var id = event.getParam("id");
        if (id == cmp.get("v.id")) {
            var pageNumber = event.getParam("page");
            var pageSize = event.getParam("pageSize");
            var pageSet = {
                "pageNumber": pageNumber,
                "pageSize": pageSize
            };
            cmp.set("v.pageSet", pageSet);
            cmp.refreshTable();
        }
    }
})