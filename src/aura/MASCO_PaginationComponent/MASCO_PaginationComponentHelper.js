({
    /**
     * Calculate page numbers buttons
     * @param cmp Component
     */
    startPagination: function (cmp) {
        //Total count of items
        var totalCount = cmp.get("v.totalCount");

        //Count of items per page
        var pageSize = cmp.get("v.pageSize");

        //Current page
        var page = cmp.get("v.page");

        //Convert current page to number
        page = +page;

        //Calculate count of pages
        var pageCount = Math.ceil(totalCount / pageSize);

        var buttonList = [];

        //First displayed number button
        var min = pageCount > 5 ? page - 2 : 1;
        if (min < 1) {
            min = 1;
        }

        //Last displayed number button
        var max = min + 5 <= pageCount ? min + 4 : pageCount;

        //Set buttons
        for (var i = max; i >= min; i--) {
            var button = {};
            button.label = i;
            button.value = i;
            button.current = i == page;
            buttonList.push(button);
        }
        cmp.set("v.pageCount", pageCount);
        cmp.set("v.next", page >= pageCount);
        cmp.set("v.prev", page - 1 <= 0);
        cmp.set("v.buttonList", buttonList);
    }
})