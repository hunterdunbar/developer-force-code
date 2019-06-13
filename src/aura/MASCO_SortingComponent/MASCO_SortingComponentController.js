({
    /**
     * Click on sorting item
     * @param cmp
     * @param event
     */
    sortBy: function (cmp, event) {
        //Sorting direction
        var asc = cmp.get("v.asc");
        //Clicked item
        var sortBy = event.target.nodeName == "TH" ? $(event.target).attr("data-href") : $(event.target).parents("th").attr("data-href");

        //Current sorting field
        var defaultSortBy = cmp.get("v.sortingField");

        //If clicked item = Current sorting field, just change sorting direction
        if (sortBy == defaultSortBy) {
            asc = !asc;
        } else {
            asc = true;
        }
        cmp.set("v.sortingField", sortBy);
        cmp.set("v.asc", asc);
        var myEvent = $A.get("e.c:MASCO_SortingEvent");
        myEvent.setParams({"sortingField": sortBy, "asc": asc});
        myEvent.fire();
    }
})