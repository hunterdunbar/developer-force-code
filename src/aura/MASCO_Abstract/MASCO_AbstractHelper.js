({
    /**
     * Get Abstract
     * @param cmp Component
     * @param id Abstract Id
     */
    getAbstract: function (cmp, id) {
        var action = cmp.get("c.getAbstract");
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

                cmp.set('v.abstract', result);
                cmp.set('v.abstractId', result.Id);

                var readonly = id || (result.hasOwnProperty('MAS_Status__c') &&
                    result.MAS_Status__c !== 'Unreviewed' && result.MAS_Status__c !== 'Reviewed with Comments');
                cmp.set('v.readOnly', readonly);

                var readerFields = cmp.get('v.readerFields');

                if (result.hasOwnProperty('MAS_Reader_Two__c')) {
                    readerFields[0].selected = result.MAS_Reader_Two__r.Name;
                    readerFields[0].selectedId = result.MAS_Reader_Two__c;
                }
                if (result.hasOwnProperty('MAS_Reader_Three__c')) {
                    readerFields[1].selected = result.MAS_Reader_Three__r.Name;
                    readerFields[1].selectedId = result.MAS_Reader_Three__c;
                }
                cmp.set('v.readerFields', readerFields);
            } else {
                console.log(res.getError());
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * Find readers by search string
     * @param cmp
     * @param searchString String for search
     * @param callback Function after query
     */
    findReaders: function (cmp, searchString, callback) {
        var action = cmp.get("c.findReaderObj");
        action.setParams({
            "searchString": searchString
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
     * Save Abstract to server
     * @param cmp
     * @param status Abstract Status (0 - Save by Student, 1 - Submit by Student, 2 - Approve by Student, 3 - Resubmit by Student)
     * @param callback Function after Save
     */
    saveAbstract: function (cmp, status, callback) {
        var abstract = cmp.get('v.abstract');
        var readerFields = cmp.get('v.readerFields');
        abstract.MAS_Reader_Two__c = readerFields[0].selectedId;
        abstract.MAS_Reader_Three__c = readerFields[1].selectedId;
        abstract.MAS_1st_Choice_Area_of_Concentration__c = $('#MAS_1st_Choice_Area_of_Concentration__c').val();
        abstract.MAS_2nd_Choice_Area_of_Concentration__c = $('#MAS_2nd_Choice_Area_of_Concentration__c').val();

        switch (status){
            case 1:
                abstract.MAS_Status__c = 'Submitted';
                break;
            case 2:
                abstract.MAS_Status__c = 'Acknowledge by Advisor';
                break;
            case 3:
                abstract.MAS_Status__c = 'Reviewed with Comments';
                break;
            default:
                abstract.MAS_Status__c = 'Unreviewed';
                break;
        }

        var action = cmp.get("c.updateAbstract");
        action.setParams({
            "abstractObj": abstract
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
     * Create new Reader
     * @param cmp
     * @param fieldId Reader type (Reader 2 or Reader 3)
     * @param callback
     */
    addNewReader: function (cmp, fieldId, callback) {
        var action = cmp.get("c.createReaderContact");
        var reader = cmp.get('v.newReader');

        action.setParams({
            "contact": reader
        });
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var result = res.getReturnValue();
                var resultObject = JSON.parse(result);
                var status = resultObject.status;
                if (status === 'Ok') {
                    callback(resultObject.contact);
                } else {
                    callback();
                }
            } else {
                callback();
                console.log(res.getError());
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * Hide modal window
     * @param cmp
     */
    hideModal: function (cmp) {
        //Hide modal
        cmp.set('v.showModal', false);

        //Reset reader type
        cmp.set('v.newReaderType', "");

        //Reset reader object
        var newReader = cmp.get('v.newReader');
        newReader.FirstName = '';
        newReader.LastName = '';
        newReader.Email = '';
        newReader.MAS_Reader_Bio__c = '';
        cmp.set('v.newReader', newReader);
    },

    /**
     * Form validation
     * @param cmp
     * @param form Form type (Abstract or Reader)
     * @returns {boolean}
     */
    validateForm: function (cmp, form) {
        var helper = this;
        var validate = true;
        if (form === 'Reader') {
            var fields = [
                'FirstName',
                'LastName',
                'Email',
                'MAS_Reader_Bio__c'
            ];
            $.each(fields, function (i, v) {
                if (!helper.setFieldError(cmp, v)) {
                    validate = false;
                }
            });
        } else if (form === 'Abstract') {
            var readerFields = cmp.get('v.readerFields');
            if (!helper.setFieldError(cmp, 'MAS_Title__c')) {
                validate = false;
            }
            if (!helper.setFieldError(cmp, 'MAS_Abstract__c')) {
                validate = false;
            }
            if ($('#MAS_1st_Choice_Area_of_Concentration__c').val() === "" ||
                $('#MAS_2nd_Choice_Area_of_Concentration__c').val() === "" ||
                !readerFields[0].selectedId || !readerFields[1].selectedId
            ) {
                validate = false;
            }

        }
        return validate;
    },

    /**
     * Set error for field
     * @param cmp
     * @param auraId field aura:id
     * @param emailValidate boolean
     * @returns {boolean}
     */
    setFieldError: function (cmp, auraId, emailValidate) {
        function isEmail(email) {
            var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
            return regex.test(email);
        }

        var inputCmp = cmp.find(auraId);
        var value = inputCmp.get("v.value");
        if (!value || value === '') {
            inputCmp.set("v.errors", [{message: "Is required field"}]);
            return false;
        }
        else if (emailValidate && !isEmail(value)) {
            inputCmp.set("v.errors", [{message: "Please Enter valid Email Address"}]);
            return false;
        } else {
            inputCmp.set("v.errors", null);
            return true;
        }

    },


    /**
     * Show toats message
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