({
    doInit: function (cmp, event, helper) {
        //Get Id of WorkOrder
        var parentId = cmp.get("v.parentId");

        //Set listener for IFrame
        window.addEventListener('message', function(event){
            if (event.origin !== document.location.origin) {
                return;
            }
            if(typeof event.data === 'string'){

                var data = JSON.parse(event.data);
                if(data.success){
                    helper.upload(cmp, data.id, parentId);
                }else{
                    helper.showToast('Error', 'Attachment uploading error', 'error');
                }
                cmp.set("v.loading", 0);
            }else {
                cmp.set("v.loading", event.data);
            }
        }, false);

        if (parentId != null) {
            //Load Table
            helper.changeViewMode(cmp);
        }
    },
    changeViewMode: function (cmp, event, helper) {
        helper.changeViewMode(cmp);
    },
    hideSpinner: function (cmp) {
        var spinner = cmp.find('spinner');
        $A.util.addClass(spinner, "slds-hide");
    }
})