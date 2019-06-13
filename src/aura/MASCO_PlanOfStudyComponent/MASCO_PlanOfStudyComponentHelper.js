({
    /**
     * Get Plan of Study
     * @param cmp Component
     * @param id Plan of Study id
     */
    getPOS: function (cmp, id) {
        var action = cmp.get("c.getPlanOfStudy");
        var helper = this;
        if (id) {
            action.setParams({
                "studentId": id
            });
        }
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var result = res.getReturnValue();

                //Fill POS object and POS id
                cmp.set('v.pos', result);
                cmp.set('v.posId', result.Id);

                //Make form readonly if User Role = Advisor or POS Status != Unreviewed
                var readonly = id || (result.hasOwnProperty('MAS_Status__c') &&
                    result.MAS_Status__c !== 'Unreviewed');
                cmp.set('v.readonly', readonly);

                //Set Advisor and Student Names in top detail block
                helper.getContactName(cmp, result.MAS_Advisor__c, function(name){
                    cmp.set('v.advisor', name);
                });
                helper.getContactName(cmp, result.MAS_Student__c, function(name){
                    cmp.set('v.student', name);
                });
            } else {
                console.log(res.getError());
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * Get Name of Contact by ContactId
     * @param cmp Component
     * @param contactId Contact Id
     * @param callback function after query
     */
    getContactName: function (cmp, contactId, callback) {
        var action = cmp.get("c.getContactName");
        action.setParams({
            "contactId": contactId
        });
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var result = res.getReturnValue();
                callback(result);
            } else {
                console.log(res.getError());
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * Save Plan of Study
     * @param cmp
     * @param status Saving status (0 - Save by Student, 1 - Submit by Student, 2 - Approve by Advisor)
     * @param callback Function after saving
     */
    savePOS: function (cmp, status, callback) {
        var pos = cmp.get('v.pos');
        if (status === 1) {
            pos.MAS_Status__c = 'Student Submitted';
        } else if (status === 2) {
            pos.MAS_Status__c = 'Advisor Approved';
        }
        var action = cmp.get("c.updatePlanOfStudy");
        action.setParams({
            "plan": pos
        });
        action.setCallback(this, function (res) {
            var state = res.getState();
            callback(state === 'SUCCESS');
            if (state !== "SUCCESS") {
                console.log(res.getError());
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * Get Plan of Study fields
     * @returns {string[]}
     */
    getFields: function () {
        return [
            'MAS_1_Alt_Title__c',
            'MAS_1_Alt_Subject__c',
            'MAS_2_Alt_Title__c',
            'MAS_2_Alt_Subject__c',
            'MAS_3_Alt_Title__c',
            'MAS_3_Alt_Subject__c',
            'MAS_1_1_Title__c',
            'MAS_1_1_Subject__c',
            'MAS_1_2_Title__c',
            'MAS_1_2_Subject__c',
            'MAS_2_1_Title__c',
            'MAS_2_1_Subject__c',
            'MAS_2_2_Title__c',
            'MAS_2_2_Subject__c',
            'MAS_3_1_Title__c',
            'MAS_3_1_Subject__c',
            'MAS_3_2_Title__c',
            'MAS_3_2_Subject__c'
        ];
    },

    /**
     * Validate form
     * @param cmp
     * @returns {boolean}
     */
    validateForm : function (cmp) {
        var posFields = this.getFields();
        var validate = true;
        for (var i = 0; i < posFields.length; i++) {
            var inputCmp = cmp.find(posFields[i]);
            var value = inputCmp.get("v.value");
            if (!value || value === '') {
                validate = false;
                inputCmp.set("v.errors", [{message: "Is required field"}]);
            } else {
                inputCmp.set("v.errors", null);
            }
        }
        return validate;
    },

    /**
     * Show toats message
     * @param title
     * @param type
     * @param message
     */
    showToast : function (title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            'duration': 3000
        });
        toastEvent.fire();
    }

})