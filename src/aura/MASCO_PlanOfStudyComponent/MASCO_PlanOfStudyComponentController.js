({
    /**
     * Initialize component
     * @param cmp
     * @param event
     * @param helper
     */
    doInit: function (cmp, event, helper) {
        //Filling of object fields with empty values
        var posFields = helper.getFields();
        var pos = {};
        for (var i = 0; i < posFields.length; i++) {
            pos[posFields[i]] = '';
        }
        cmp.set('v.pos', pos);

        var role = cmp.get('v.userRole');
        if (role === 'Student') {

            //Show detail page for Student
            helper.getPOS(cmp);
        } else if (role === 'Advisor') {
            var posId = cmp.get('v.posId');
            if (posId === "") {

                //Show Table for Advisor
                cmp.set('v.wait', false);
                cmp.refreshTable();
            } else {

                //Show detail page for Advisor
                helper.getPOS(cmp, posId);
            }
        }
    },

    /**
     * Save Plan of Study by Student
     * @param cmp
     * @param event
     * @param helper
     */
    savePOS: function (cmp, event, helper) {
        if (helper.validateForm(cmp)) {
            helper.savePOS(cmp, 0, function (status) {
                if (status) {
                    helper.showToast("Success", "success", "Plan of Study has been successfully saved.");
                } else {
                    helper.showToast("Error", "error", "Plan of Study saving error.");
                }
            });
        }
    },

    /**
     * CHange input event for form validation
     * @param cmp
     * @param event
     */
    inputChange: function (cmp, event) {
        var inputId = event.getSource().getLocalId();
        var inputCmp = cmp.find(inputId);
        var value = inputCmp.get("v.value");
        if (!value || value === '') {
            inputCmp.set("v.errors", [{message: "Is required field"}]);
        } else {
            inputCmp.set("v.errors", null);
        }
    },

    /**
     * Submit Plan of Study by Student
     * @param cmp
     * @param event
     * @param helper
     */
    submitPOS: function (cmp, event, helper) {
        if (helper.validateForm(cmp)) {
            helper.savePOS(cmp, 1, function (status) {
                if (status) {
                    helper.showToast("Success", "success", "Plan of Study has been successfully submitted.");
                    helper.getPOS(cmp);
                } else {
                    helper.showToast("Error", "error", "Plan of Study saving error.");
                }
            });
        }
    },

    /**
     * Approve Plan of Study by Advisor
     * @param cmp
     * @param event
     * @param helper
     */
    approvePOS: function (cmp, event, helper) {
        helper.savePOS(cmp, 2, function (status) {
            if (status) {
                helper.showToast("Success", "success", "Plan of Study has been successfully approved.");
                location.hash = '#plan-of-study';
            } else {
                helper.showToast("Error", "error", "Plan of Study saving error.");
            }
        });
    }
})