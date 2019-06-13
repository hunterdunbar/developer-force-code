({
    /**
     * Get Summer Plan List for Advisor
     * @param cmp Component
     * @param summerPlanType Summer Plan Type 1 or 2
     * @param studentId Id of Student (for Advisor mode)
     */
    getSummerPlan: function (cmp, summerPlanType, studentId) {
        var that = this;
        if (summerPlanType !== '1' && summerPlanType !== '2') {
            summerPlanType = '1';
            cmp.set('v.summerPlanType', '1');
        }
        var action = cmp.get("c.getSummerPlan");
        action.setParams({
            "summerNumS": summerPlanType,
            "studentId": studentId
        });
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var result = res.getReturnValue();
                if (result) {
                    var readOnly = studentId || (result.hasOwnProperty('MAS_Status__c') &&
                        result.MAS_Status__c !== 'Unreviewed');
                    cmp.set('v.readOnly', readOnly);
                    cmp.set('v.summerPlan', result);
                    cmp.set('v.summerPlanId', result.Id);
                } else {
                    that.showToast('Error', 'error', 'Record not found');
                }
            } else {
                console.log(res.getError());
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * Save Summer Plan
     * @param cmp Component
     * @param status Summer Plan Status (0 - Saved by Student, 1 - Submitted by Student, 2 - Approved by Advisor)
     * @param callback Function after save
     */
    savePlan: function (cmp, status, callback) {

        //Fill Summer Plan object from form fields values
        var plan = cmp.get('v.summerPlan');
        var checkboxFields = [
            'MAS_1_Staying_at_MIT__c',
            'MAS_2_Leaving_MIT__c',
            'MAS_3_Complicated__c',
            'MAS_4_Graduating__c',
            'MAS_7_Getting_CPTOPT__c',
            'MAS_8_Received_CPTOPT__c',
            'MAS_9_NotStarted_CPTOPT__c'
        ];
        $.each(checkboxFields, function (i, v) {
            plan[v] = $('#' + v).is(':checked');
        });
        plan['MAS_10_Thesis_Situation__c'] = $('#MAS_10_Thesis_Situation__c').val();

        //Set Status
        if(status === 1){
            plan['MAS_Status__c'] = 'Submitted';
        }else if(status === 2){
            plan['MAS_Status__c'] = 'Acknowledge by Advisor';
        }

        var action = cmp.get("c.updateSummerPlan");
        action.setParams({
            "plan": plan
        });
        action.setCallback(this, function (res) {
            var state = res.getState();
            callback(state === "SUCCESS");
            if (state !== "SUCCESS") {
                console.log(res.getError());
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * Show Toast Message
     * @param title
     * @param type
     * @param message
     */
    showToast: function (title, type, message) {
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