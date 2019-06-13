({
    /**
     * Link Attachment to Proposal
     * @param cmp Component
     * @param id Id of Attachment
     * @param parentId Id of Object for attaching file
     */
    upload: function (cmp, id, parentId) {
        var action = cmp.get("c.addFile");
        action.setParams({
            'contentVersionId': id,
            'proposalId': parentId
        });
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var result = JSON.parse(res.getReturnValue());
                this.showToast("Success", "Attachment added successfully", "success");
                var myEvent = cmp.getEvent("actionEvent");
                myEvent.setParams({"actionName": 'attachmentUploaded'});
                myEvent.fire();
            } else {
                this.showToast('Error', 'Attachment uploading error', 'error');
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
    changeViewMode: function (cmp) {
    }
})