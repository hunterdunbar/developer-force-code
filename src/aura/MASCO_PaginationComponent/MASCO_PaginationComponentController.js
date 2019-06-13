({
    doInit: function (cmp, event, helper) {
        helper.startPagination(cmp);
    },
    Next: function (cmp, event, helper) {
        //Click Next button
        var page = cmp.get("v.page");
        var myEvent = $A.get("e.c:MASCO_PageChangeEvent");
        myEvent.setParams({"id": cmp.get("v.id"), "page": page + 1, "pageSize": cmp.get("v.pageSize")});
        myEvent.fire();
        helper.startPagination(cmp);
    },
    Previous: function (cmp, event, helper) {
        //Click on Previous button
        var page = cmp.get("v.page");
        var myEvent = $A.get("e.c:MASCO_PageChangeEvent");
        myEvent.setParams({"id": cmp.get("v.id"), "page": page - 1, "pageSize": cmp.get("v.pageSize")});
        myEvent.fire();
        helper.startPagination(cmp);
    },
    goToPage: function (cmp, event, helper) {
        //Click on Number button
        var page = $(event.target).attr('data-href');
        var myEvent = $A.get("e.c:MASCO_PageChangeEvent");
        myEvent.setParams({"id": cmp.get("v.id"), "page": +page, "pageSize": cmp.get("v.pageSize")});
        myEvent.fire();
        helper.startPagination(cmp);
    }
})