({
    doInit: function (cmp) {
        var url = window.location.href;
        var foundStr = 's/';
        var foundStrPos = url.indexOf('s/') + foundStr.length;
        if (url.length > foundStrPos && url.substring(foundStrPos, foundStrPos + 1) != '#') {
           // window.location.href='/s';
        }

        //Change active item
        $(window).on('hashchange', function () {
            var items = cmp.get("v.items");
            var url = window.location.hash.split('?')[0].replace('#', '');
            for (var i = 1; i < items.length; i++) {
                var findedInOtherUrl = items[i].hasOwnProperty('otherUrl') ? (items[i].otherUrl.filter(function (v) {
                    return v == url;
                }).length > 0) : false;
                if (url == items[i].url || findedInOtherUrl) {
                    cmp.set("v.active", items[i].id);
                    break;
                } else if (i == items.length - 1) {
                    cmp.set("v.active", 0);
                }
            }
        });

        //Fix double click for Ipad
        var device = navigator.userAgent.toLowerCase();
        var ios = device.match(/(iphone|ipod|ipad)/);
        if(ios) {
            $('a').on('click touchend', function (e) {
                var el = $(this);
                var link = el.attr('href');
                window.location.hash = link;
            });
        }
    },

    routeChange: function (cmp) {

        //Set default Active item
        var items = cmp.get("v.items");
        var url = window.location.hash.split('?')[0].replace('#', '');
        for (var i = 1; i < items.length; i++) {
            var findedInOtherUrl = items[i].hasOwnProperty('otherUrl') ? (items[i].otherUrl.filter(function (v) {
                return v == url;
            }).length > 0) : false;
            if (url == items[i].url || findedInOtherUrl) {
                cmp.set("v.active", items[i].id);
                break;
            } else if (i == items.length - 1) {
                cmp.set("v.active", 0);
            }
        }
    }
})