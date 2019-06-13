({
    /**
     * Get User role
     * @param cmp
     * @param callback
     */
    getUserRole: function (cmp, callback) {
        var action = cmp.get("c.getUserRole");
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var result = res.getReturnValue();
                var role = JSON.parse(result);
                if (role === 'Student' || role === 'Advisor') {
                    cmp.set('v.userRole', role);
                    callback(role);
                }
            } else {
                console.log(res.getError());
            }
        });
        $A.enqueueAction(action);
    },
    /**
     * Get params from url
     * @param query Url for parsing
     * @param variable Name of variable
     * @returns {*} Value of variable
     */
    getUrlParams: function (query, variable) {
        if (query != null) {
            var vars = query.split('&');
            for (var i = 0; i < vars.length; i++) {
                var pair = vars[i].split('=');
                if (decodeURIComponent(pair[0]) == variable) {
                    return decodeURIComponent(pair[1]);
                }
            }
        }
        return "";
    },

    /**
     * Rerender page if location changed
     * @param cmp Component
     * @param token Token - Name of page (#nameofpage)
     * @param queryString String with params (#nameofpage?querystring)
     */
    updateLocation: function (cmp, token, queryString) {
        var id = this.getUrlParams(queryString, 'id');
        var type = this.getUrlParams(queryString, 'type');
        var back = this.getUrlParams(queryString, 'back');

        //Scroll to top
        window.scrollTo(0, 0);
        var location = cmp.get("v.location");
        cmp.set("v.param", id);
        cmp.set("v.type", type);
        cmp.set("v.back", back);
        for (var i = 0; i < location.length; i++) {
            if (location[i].url === token) {
                location[i].current = true;
                var prefix = cmp.get("v.prefix");
                document.title = prefix + location[i].title;
                if (i > 0 && i < 6) {
                    var spinner = cmp.find('spinner');
                    $A.util.removeClass(spinner, "slds-hide");
                    this.createComponent(cmp, i);
                } else {
                    this.showToast('Error', 'error', 'Page not found');
                }
            } else {
                location[i].current = false;
            }
        }
        cmp.set("v.location", location);
    },

    /**
     * Create component after location change
     * @param cmp Component
     * @param id Id of component
     */
    createComponent: function (cmp, id) {
        var componentName;
        var params = {};
        var param = cmp.get("v.param");
        var type = cmp.get("v.type");
        var userRole = cmp.get('v.userRole');
        console.log(userRole);
        switch (id) {
            case 1:
                componentName = "c:MASCO_PlanOfStudyComponent";
                params = {"posId": param, 'userRole': userRole};
                break;
            case 2:
                componentName = "c:MASCO_SummerPlans";
                params = {"summerPlanId": param, "summerPlanType": type, 'userRole': userRole};
                break;
            case 3:
                componentName = "c:MASCO_Abstract";
                params = {"abstractId": param, 'userRole': userRole};
                break;
            case 4:
                componentName = "c:MASCO_CritDay";
                params = {'userRole': userRole};
                break;
            case 5:
                componentName = "c:MASCO_Proposal";
                params = {"proposalId": param, 'userRole': userRole, 'proposalTab' : type};
                break;
            default:
                this.showToast('Error', 'error', 'Page not found');
                break;
        }
        var body = cmp.get("v.body");
        if (componentName) {
            $A.createComponent(
                componentName,
                params,
                function (newComponent, status, errorMessage) {
                    if (status === "SUCCESS") {
                        body[0] = newComponent;
                        cmp.set("v.body", body);
                    }
                    else if (status === "INCOMPLETE") {
                    }
                    else if (status === "ERROR") {
                    }
                }
            );
        }
    },

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