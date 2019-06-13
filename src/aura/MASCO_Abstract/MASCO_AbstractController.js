({
    /**
     * Initialize component
     * @param cmp
     * @param event
     * @param helper
     */
    doInit: function (cmp, event, helper) {

        //Search readers fields
        var readerFields = [
            {
                'id': '0',
                'title': 'Reader 2',
                'selected': false,
                'selectedId': false,
                'readers': []
            },
            {
                'id': '1',
                'title': 'Reader 3',
                'selected': false,
                'selectedId': false,
                'readers': []
            }
        ];
        cmp.set('v.readerFields', readerFields);

        var role = cmp.get('v.userRole');
        if (role === 'Student') {

            //Detail view for student
            helper.getAbstract(cmp);
        } else if (role === 'Advisor') {
            var abstractId = cmp.get('v.abstractId');
            if (abstractId === '') {

                //Table for Advisor
                cmp.set('v.wait', false);
                cmp.refreshTable();
            } else {

                //Detail view for Advisor
                helper.getAbstract(cmp, abstractId);
            }
        }
    },

    /**
     * Search reader
     * @param cmp
     * @param event
     * @param helper
     */
    search: function (cmp, event, helper) {
        var input = $(event.target);
        var searchString = input.val();
        if (searchString.length > 2) {
            helper.findReaders(cmp, searchString, function (result) {
                if (result.length > 0) {
                    var readerFields = cmp.get('v.readerFields');
                    readerFields[input.data('id')].readers = result;
                    input.closest('.slds-dropdown-trigger').addClass('slds-is-open');
                    cmp.set('v.readerFields', readerFields);
                } else {
                    input.closest('.slds-dropdown-trigger').removeClass('slds-is-open');
                }
            });
        }
    },

    /**
     * Select Reader from dropdown list
     * @param cmp
     * @param event
     * @param helper
     */
    selectReader: function (cmp, event, helper) {
        var option = $(event.target).closest('.slds-media');
        var fieldId = $(event.target).closest('.mas-reader-field').data('field-id');
        var readerFields = cmp.get('v.readerFields');
        readerFields[fieldId].selected = option.data('reader-name');
        readerFields[fieldId].selectedId = option.data('reader-id');
        cmp.set('v.readerFields', readerFields);

        $('#readerSearch' + fieldId).closest('.slds-dropdown-trigger').removeClass('slds-is-open');
    },

    /**
     * Remove Reader from field
     * @param cmp
     * @param event
     * @param helper
     */
    clearReaderSearch: function (cmp, event, helper) {
        var fieldId = $(event.target).closest('.mas-reader-field').data('field-id');
        var readerFields = cmp.get('v.readerFields');
        readerFields[fieldId].selected = false;
        readerFields[fieldId].selectedId = false;
        $('#readerSearch' + fieldId).val('');
        cmp.set('v.readerFields', readerFields);
    },

    /**
     * Save Abstract by Student
     * @param cmp
     * @param event
     * @param helper
     */
    saveAbstract: function (cmp, event, helper) {
        helper.saveAbstract(cmp, 0, function (status) {
            if (status) {
                helper.showToast("Success", "success", "Abstract has been successfully saved.");
            } else {
                helper.showToast("Error", "error", "Abstract saving error.");
            }
        });
    },

    /**
     * Submit Abstract by Student
     * @param cmp
     * @param event
     * @param helper
     */
    submitAbstract: function (cmp, event, helper) {
        if (helper.validateForm(cmp, 'Abstract')) {
            helper.saveAbstract(cmp, 1, function (status) {
                if (status) {
                    helper.showToast("Success", "success", "Abstract has been successfully submitted.");
                    helper.getAbstract(cmp);
                } else {
                    helper.showToast("Error", "error", "Abstract saving error.");
                }
            });
        } else {
            helper.showToast("Error", "error", "Please fill out all required fields.");
        }
    },

    /**
     * Change Abstract status by Advisor for allow student to resubmit
     * @param cmp
     * @param event
     * @param helper
     */
    resubmitAbstract: function (cmp, event, helper) {
        if (helper.validateForm(cmp, 'Abstract')) {
            helper.saveAbstract(cmp, 3, function (status) {
                if (status) {
                    helper.showToast("Success", "success", "Abstract has been successfully updated.");
                    location.hash = '#abstract';
                } else {
                    helper.showToast("Error", "error", "Abstract saving error.");
                }
            });
        } else {
            helper.showToast("Error", "error", "Please fill out all required fields.");
        }
    },

    /**
     * Approve Abstract by Advisor
     * @param cmp
     * @param event
     * @param helper
     */
    approveAbstract: function (cmp, event, helper) {
        if (helper.validateForm(cmp, 'Abstract')) {
            helper.saveAbstract(cmp, 2, function (status) {
                if (status) {
                    helper.showToast("Success", "success", "Abstract has been successfully approved.");
                    location.hash = '#abstract';
                } else {
                    helper.showToast("Error", "error", "Abstract saving error.");
                }
            });
        } else {
            helper.showToast("Error", "error", "Please fill out all required fields.");
        }
    },

    /**
     * Show Add reader modal
     * @param cmp
     * @param event
     * @param helper
     */
    showModal: function (cmp, event, helper) {
        var fieldId = $(event.target).closest('.mas-reader-field').data('field-id');
        console.log(fieldId);
        cmp.set('v.showModal', true);
        cmp.set('v.newReaderType', fieldId);
    },

    /**
     * Hide Add reader modal
     * @param cmp
     * @param event
     * @param helper
     */
    hideModal: function (cmp, event, helper) {
        helper.hideModal(cmp);

    },

    /**
     * Click on Save reader button in modal window
     * @param cmp
     * @param event
     * @param helper
     */
    addNewReader: function (cmp, event, helper) {
        if (helper.validateForm(cmp, 'Reader')) {
            var fieldId = cmp.get('v.newReaderType');
            helper.addNewReader(cmp, fieldId, function (contact) {
                if (contact) {
                    var readerFields = cmp.get('v.readerFields');
                    readerFields[fieldId].selected = contact.Name;
                    readerFields[fieldId].selectedId = contact.Id;
                    cmp.set('v.readerFields', readerFields);
                    helper.hideModal(cmp);
                    helper.showToast('Success', 'Success', 'New Reader has been successfully added.');
                } else {
                    helper.showToast('Error', 'error', 'Create reader error');
                }
            });
        } else {
            helper.showToast("Error", "error", "Please fill out all required fields.");
        }
    },

    /**
     * Change input event for form validation
     * @param cmp
     * @param event
     * @param helper
     */
    inputChange: function (cmp, event, helper) {
        var inputId = event.getSource().getLocalId();
        helper.setFieldError(cmp, inputId);
    },

    /**
     * Change email input event for form validation
     * @param cmp
     * @param event
     * @param helper
     */
    inputChangeEmail: function (cmp, event, helper) {
        var inputId = event.getSource().getLocalId();
        helper.setFieldError(cmp, inputId, true);
    }
})