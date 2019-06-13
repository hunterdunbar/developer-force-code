({
    isSubmitted: function(cmp) {
        var isSubmitted = false;
        // some actions....
        cmp.set("v.isSubmitted", isSubmitted);

        if (!isSubmitted) {
	        // Submit By

            // some actions....
	        cmp.set("v.submitBy", new Date());
        }
    },
    getAvailabilityItems: function(cmp, helper) {
        var data = [];

        var action = cmp.get("c.getCritDayAvailabilityObj");
            action.setCallback(this, function(res) {
                var state = res.getState();
                if (state == "SUCCESS") {
                    var result = res.getReturnValue();
console.dir(result);
					
                    // process 2 columns

                    var tmp = {};
                    result.forEach(function(item){
                        var split = item.MAS_Start_Time_Text__c.split(' '),
                            date = split[0],
                            time = split[1]+' '+split[2];
                        
                        if (tmp[date] === undefined)
                            tmp[date] = [];
                        
                        tmp[date].push(item);
                    });

                    Object.values(tmp).forEach(function(item){
                        data.push({
                            day: item[0].MAS_Start_Time__c,
                            items: helper.sortByDate(item, 'MAS_Start_Time__c')
                        });
                    });
                    helper.sortByDate(data, 'day')
console.dir(data);
                    cmp.set("v.availabilityData", data);

                } else if (state === "ERROR") {
                    console.log(res.getError());
                }
            });
            $A.enqueueAction(action);
    },
    processDataForSubmit: function(cmp) {
        var data = [];

        cmp.get("v.availabilityData").forEach(function(col){
            col.items.forEach(function(item){
                data.push({
                    'Id': item.Id,
                    'MAS_IsAvailable__c': item.MAS_IsAvailable__c
                });
            });
        });
console.log(data);
        return data;
    },


    sortByDate: function(arr, f){
        return arr.sort(function(a, b){
            if ( Date.parse(a[f]) > Date.parse(b[f]) )
                return 1;
            else
                return -1;
            
            return 0;
        });
    }
})