({
	doInit : function(cmp){
        console.log("Here"+cmp);
		var action = cmp.get("c.getCDAs");
        console.log('action+'+action);
        action.setCallback(this, function(response){

            var state = response.getState();
			console.log('response++'+response.getReturnValue());			
            if (state === "SUCCESS") {

                cmp.set("v.myObject", response.getReturnValue());
				var items = [];
                var nestedData = [];
                for(var i=0;i<response.getReturnValue().length;i++){
                    var x = {
                        "label": response.getReturnValue()[i].Name,
                        "name":1,
                        "expanded":false,
                        "items":[]
                    }
                    items.push(x);
                    var y = {
                        "name":response.getReturnValue()[i].Name+i,
                        "critDayName":response.getReturnValue()[i].Name,
                        "unavailable":response.getReturnValue()[i].Unavailable__c.toString()
                    }
        			console.log(y);
                    nestedData.push(y);
                }
                cmp.set("v.items",items);
                var cols = [{type: 'text',fieldName: 'critDayName',label:'Crit Day Name'},
                            {type: 'text',fieldName: 'unavailable',label:'Unavailable?'}];
                console.log(cols);
                console.log(nestedData);
                cmp.set("v.gridColumns",cols);
                cmp.set("v.gridData",nestedData);
                var expandedRows = [];
				cmp.set('v.gridExpandedRows', expandedRows);

            }

        });

     $A.enqueueAction(action);


	}
    
})