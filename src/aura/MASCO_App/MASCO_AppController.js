({
    doInit: function (cmp, event, helper) {
        var urlParams = window.location.hash.split('?');
        var token = urlParams[0].replace('#', '');
        helper.getUserRole(cmp, function(role){
            cmp.set('v.userRole', role);
            helper.updateLocation(cmp, token, urlParams[1]);
        });
    },
    locationChange: function (cmp, event, helper) {
        var token = event.getParam("token");
        helper.updateLocation(cmp, token, event.getParam("querystring"));
    },
    hideSpinner: function (cmp, event, helper) {
        var spinner = cmp.find('spinner');
        $A.util.addClass(spinner, "slds-hide");
    }
})