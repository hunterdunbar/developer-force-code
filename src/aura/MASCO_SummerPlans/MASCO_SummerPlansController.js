({
    /**
     * Initialize component
     * @param cmp
     * @param event
     * @param helper
     */
    doInit: function (cmp, event, helper) {

        var role = cmp.get('v.userRole');
        var summerPlanType = cmp.get('v.summerPlanType');
        if (role === 'Student') {

            //Render detail page for Student
            helper.getSummerPlan(cmp, summerPlanType, '');
        } else if (role === 'Advisor') {
            var summerPlanId = cmp.get('v.summerPlanId');
            if (summerPlanId === '') {
                //Render Table for Advisor
                cmp.set('v.wait', false);
                cmp.refreshTable();
            } else {

                //Render detail page for Advisor
                helper.getSummerPlan(cmp, summerPlanType, summerPlanId);
            }
        }
    },

    /**
     * Save Summer Plan by Student
     * @param cmp
     * @param event
     * @param helper
     */
    savePlan: function (cmp, event, helper) {
        helper.savePlan(cmp, 0, function (status) {
            if (status) {
                helper.showToast("Success", "success", "Summer Plan has been successfully saved.");
            } else {
                helper.showToast("Error", "error", "Summer Plan saving error.");
            }
        });
    },

    /**
     * Submit Plan by Student
     * @param cmp
     * @param event
     * @param helper
     */
    submitPlan: function (cmp, event, helper) {
        helper.savePlan(cmp, 1, function (status) {
            if (status) {
                helper.showToast("Success", "success", "Summer Plan has been successfully submitted.");
                var summerPlanType = cmp.get('v.summerPlanType');
                helper.getSummerPlan(cmp, summerPlanType, '');
            } else {
                helper.showToast("Error", "error", "Summer Plan submit error.");
            }
        });
    },

    /**
     * Approve Plan by Advisor
     * @param cmp
     * @param event
     * @param helper
     */
    approvePlan: function (cmp, event, helper) {
        helper.savePlan(cmp, 2, function (status) {
            if (status) {
                helper.showToast("Success", "success", "Summer Plan has been successfully approved.");
                location.hash = '#summer-plans';
            } else {
                helper.showToast("Error", "error", "Summer Plan approve error.");
            }
        });
    }
})