({
    /**
     * Get Proposal
     * @param cmp Component
     * @param id Proposal Id
     */
    getProposal: function (cmp, id) {
        var action = cmp.get("c.getProposal");
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

                cmp.set('v.proposal', result);
                cmp.set('v.proposalId', result.Id);
                cmp.set('v.readOnly', false);

                /**
                 * Render download file link for table
                 * @param contentDocument
                 * @returns {string}
                 */
                function getLink(contentDocument) {
                    var link = location.origin + location.pathname +  '../sfc/servlet.shepherd/version/download/';
                    return '<a href="' + link + contentDocument.LatestPublishedVersionId + '" target="_blank">' +
                        contentDocument.Title + '</a>';
                }

                //Fieldset for SObjectListManager
                var fieldSet = [
                    {'name': 'ContentDocument.Title'},
                    {'name': 'ContentDocument.LatestPublishedVersionId'},
                    {'name': 'ContentDocument.ContentModifiedDate'},
                    {'name': 'ContentDocument.FileExtension'}
                ];

                //Fieldset for Student files table
                var fieldSetAttachmentStudent = [
                    {
                        'name': 'ContentDocument.LatestPublishedVersionId',
                        'label': 'Title',
                        'type': 'custom',
                        'fieldName': 'ContentDocument',
                        'action': getLink
                    },
                    {
                        'name': 'ContentDocument.ContentModifiedDate',
                        'label': 'Last Modified',
                        'type': 'custom',
                        'fieldName': 'ContentDocument',
                        'action': helper.getDate
                    }
                ];

                //Set params for SObjectListManager and TableRender Component
                cmp.set('v.wait', false);
                cmp.set('v.objectName', 'ContentDocumentLink');
                cmp.set('v.filterCode', 'ProposalFileList');
                cmp.set('v.fieldSet', fieldSet);
                cmp.set('v.fieldSetAttachmentStudent', fieldSetAttachmentStudent);
                cmp.set("v.filters", {"LinkedEntityId": result.Id});
                cmp.refreshTable();
            } else {
                console.log(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    /**
     * Save Proposal
     * @param cmp Component
     * @param status Proposal Status (0 - Saved by Student, 1 - Submitted by Student, 2 - Approved by Advisor)
     * @param callback Function after save
     */
    saveProposal: function (cmp, status, callback) {

        var proposal = cmp.get('v.proposal');

        //Set Status
        /*if(status === 1){
            plan['MAS_Status__c'] = 'Submitted';
        }else if(status === 2){
            plan['MAS_Status__c'] = 'Acknowledge by Advisor';
        }*/

        var action = cmp.get("c.updateProposal");
        action.setParams({
            "proposalObj": proposal
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
     * Format date
     * @param value
     * @returns {*}
     */
    getDate: function (value) {
        var dateFormat = function (dateObject, type) {
            var month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
            var a = dateObject.split(/[^0-9]/);
            var d = new Date(Date.UTC(a[0], a[1] - 1, a[2], a[3], a[4], a[5]));

            var day = d.getDate();
            var m = d.getMonth() + 1;
            var year = d.getFullYear();
            day = day < 10 ? "0" + day : day;
            m = m < 10 ? "0" + m : m;

            var hours = d.getHours();
            var minutes = d.getMinutes();
            var ampm = hours >= 12 ? 'PM' : 'AM';
            hours = hours % 12;
            hours = hours ? hours : 12;
            minutes = minutes < 10 ? '0' + minutes : minutes;
            var strTime = hours + ':' + minutes + ' ' + ampm;

            return type ? m + "/" + day + "/" + year : m + "/" + day + "/" + year + ' ' + strTime;
        };
        if (value != null && value.hasOwnProperty('ContentModifiedDate')) {
            return dateFormat(value.ContentModifiedDate);
        } else {
            return "";
        }
    },

    /**
     * Show toast message
     * @param title
     * @param type
     * @param message
     */
    showToast: function (title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})