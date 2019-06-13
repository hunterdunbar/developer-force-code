({
    /**
     * Initialize component
     * @param cmp
     * @param event
     * @param helper
     */
    doInit: function (cmp, event, helper) {
        var role = cmp.get('v.userRole');
        if (role === 'Student') {

            //Detail view for student
            var tab = cmp.get('v.proposalTab');
            if (tab !== '1' && tab !== '2') {
                cmp.set('v.proposalTab', '1');
            }
            helper.getProposal(cmp);
        } else if (role === 'Advisor') {
            var proposalId = cmp.get('v.proposalId');
            if (proposalId === '') {

                //Table for Advisor
                cmp.set('v.wait', false);
                cmp.refreshTable();
            } else {

                //Detail view for Advisor
                helper.getProposal(cmp, proposalId);
            }
        }
    },

    /**
     * MASCO_ActionEvent listener
     * @param cmp
     * @param event
     */
    actionEvent: function (cmp, event) {
        var actionName = event.getParam("actionName");
        var parameters = event.getParam("parameters");
        if (actionName === 'attachmentUploaded') {

            //Update Attachments table after uploading new file
            cmp.refreshTable();
        }
    },

    /**
     * Set file type icons for attachments list
     * @param cmp
     * @param event
     * @param helper
     */
    setIcons: function (cmp, event, helper) {
        var role = cmp.get('v.userRole');
        var proposalId = cmp.get('v.proposalId');

        //Only for Advisor detail view
        if (role === 'Advisor' && proposalId !== '') {

            var objects = cmp.get('v.objects');

            //If not updated before
            if (!objects[0].hasOwnProperty('icon')) {
                $.each(objects, function (i, v) {
                    var icon;
                    switch (v.ContentDocument.FileExtension) {
                        case 'png':
                        case 'jpg':
                        case 'jpeg':
                            icon = 'image';
                            break;
                        case 'doc':
                        case 'docx':
                            icon = 'word';
                            break;
                        case 'pdf':
                            icon = 'pdf';
                            break;
                        case 'txt':
                            icon = 'txt';
                            break;
                        default:
                            icon = 'unknown';
                    }
                    //Set icon
                    v.icon = icon;

                    //Set download file link
                    v.downloadLink = location.origin + location.pathname + '../sfc/servlet.shepherd/version/download/' + v.ContentDocument.LatestPublishedVersionId;
                });
                cmp.set('v.objects', objects);
            }
        }
    },

    /**
     * Save Proposal by Student
     * @param cmp
     * @param event
     * @param helper
     */
    saveProposal: function (cmp, event, helper) {
        helper.saveProposal(cmp, 0, function (status) {
            if (status) {
                helper.showToast("Success", "success", "Proposal has been successfully saved.");
            } else {
                helper.showToast("Error", "error", "Proposal saving error.");
            }
        });
    },

    /**
     * Submit Proposal by Student
     * @param cmp
     * @param event
     * @param helper
     */
    submitProposal: function (cmp, event, helper) {
        helper.saveProposal(cmp, 1, function (status) {
            if (status) {
                helper.showToast("Success", "success", "Proposal has been successfully submitted.");
                helper.getProposal(cmp);
            } else {
                helper.showToast("Error", "error", "Proposal submit error.");
            }
        });
    },

    /**
     * Approve Proposal by Advisor
     * @param cmp
     * @param event
     * @param helper
     */
    approveProposal: function (cmp, event, helper) {
        helper.saveProposal(cmp, 2, function (status) {
            if (status) {
                helper.showToast("Success", "success", "Proposal has been successfully approved.");
                location.hash = '#proposal';
            } else {
                helper.showToast("Error", "error", "Proposal approve error.");
            }
        });
    }
})