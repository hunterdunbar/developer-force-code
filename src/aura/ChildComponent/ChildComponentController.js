({
	HuntersMethod : function(component, event, helper) {
		console.log(event);
        var params = event.getParam('arguments');
        console.log(params.message);

	}
})