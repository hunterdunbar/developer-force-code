({
    /**
     * Get Table Data from DataTableController
     * @param cmp Component
     * @param pwObject Object with parameters
     */
    getTable: function (cmp, pwObject) {
        var action = cmp.get("c.getData");
        var pwJson = JSON.stringify(pwObject);
        action.setParams({
            "DataDescriptorJson": pwJson
        });
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state == "SUCCESS") {
                var result = JSON.parse(res.getReturnValue());
                console.log(result);
                var retRecords = result.sObjectRecords;

                cmp.set('v.objects', result.sObjectRecords);
                cmp.set('v.totalCount', result.total);
            }else{
                ////console.log(res.getError());
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * Delete object
     * @param cmp Component
     * @param object Object for delete
     * @param callback Function after delete
     */
    deleteObject:function(cmp, object, callback){
        var action = cmp.get("c.deleteObject");
        var objectJson = JSON.stringify(object);
        action.setParams({
            "objectJson": objectJson
        });

        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state == "SUCCESS") {
                var result = JSON.parse(res.getReturnValue());
                callback(result.success, result.errors);
            }else{
                callback(state, null, res.getError());
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * Save object
     * @param cmp Component
     * @param object Object for save
     * @param callback Function after save
     */
    saveObject:function(cmp, object, callback){
        var action = object.hasOwnProperty('Id') ? cmp.get("c.updateObject") : cmp.get("c.createObject");
        var objectJson = JSON.stringify(object);
        action.setParams({
            "objectJson": objectJson
        });
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state == "SUCCESS") {
                var result = JSON.parse(res.getReturnValue());
                callback(result.success, result.errorItems, result.errors);
            }else{
                callback(state, null, res.getError());
            }
        });
        $A.enqueueAction(action);
    }
})