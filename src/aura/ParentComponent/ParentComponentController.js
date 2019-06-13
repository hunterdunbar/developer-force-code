({
	callChildMethod : function(component, event, helper) {
		var childComp = component.find("child");
        childComp.HuntersMethod("something","somethingelse");
        
        var childComp2 = component.find("child2");
        childComp2.HuntersMethod("child2","child2else");
	}
})