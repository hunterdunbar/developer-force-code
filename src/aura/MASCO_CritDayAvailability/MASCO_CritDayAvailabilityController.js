({
	doInit: function (cmp, event, helper) {
console.log('----- CritDayAvailability: doInit -----');

		helper.isSubmitted(cmp);
	},
    
    openModal: function (cmp, event, helper) {
        $A.util.addClass(cmp.find('modal'), 'slds-fade-in-open');
		helper.getAvailabilityItems(cmp, helper);
    },
    closeModal: function (cmp, event, helper) {
        $A.util.removeClass(cmp.find('modal'), 'slds-fade-in-open');
    },
    
    submit: function (cmp, event, helper) {
		var action = cmp.get("c.setCritDayAvailabilityObj");
			action.setParams({
				critDayAvailabilitiesList: helper.processDataForSubmit(cmp)
	        });
			action.setCallback(this, function (res) {
                var state = res.getState();
                if (state == "SUCCESS") {
//                    var result = res.getReturnValue();
//console.dir(result);
			        $A.util.removeClass(cmp.find('modal'), 'slds-fade-in-open');
			        cmp.set("v.isSubmitted", true); // fake update

                } else if (state === "ERROR") {
                    console.log(res.getError());
                }
            });
            $A.enqueueAction(action);
    }
})