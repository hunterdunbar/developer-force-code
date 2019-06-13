({
    /**
     * Render Button
     * @param cmp Component
     * @param id Id of object for Event
     * @param name Button title
     * @param action Name of action for event
     * @returns {Element}
     */
    renderButton: function (cmp, id, name, action) {
        var button = document.createElement("button");
        button.className = "slds-button slds-button--neutral";
        button.setAttribute("data-href", id);
        button.innerText = name;
        button.addEventListener('click', function () {
            var myEvent = cmp.getEvent("actionEvent");
            myEvent.setParams({"actionName": action, 'parameters': [{'id': id}]});
            myEvent.fire();
        });
        return button;
    },

    /**
     * Render link with action
     * @param cmp Component
     * @param id If of object for event
     * @param name Title of link
     * @param action Action name for event
     * @returns {Element}
     */
    renderActionLink: function (cmp, id, name, action) {
        var link = document.createElement("a");
        link.setAttribute("data-href", id);
        link.innerText = name;
        link.addEventListener('click', function () {
            var myEvent = cmp.getEvent("actionEvent");
            myEvent.setParams({"actionName": action, 'parameters': [{'id': id}]});
            myEvent.fire();
        });
        return link;
    },

    /**
     * Render link with real url address
     * @param cmp Component
     * @param path URL of component
     * @param id Id of object for URL param
     * @param name Title of Link
     * @param customParams array of params for add to url
     * @returns {*}
     */
    renderRealLink: function (cmp, path, id, name, customParams) {
        var link;
        if (id == null) {
            link = this.truncateText(name);
        } else {
            link = document.createElement("a");
            var params = '';
            if (customParams) {
                for (var i = 0; i < customParams.length; i++) {
                    params += '&' + customParams[i].name + '=' + customParams[i].value;
                }
            }
            var url = '#' + path + '?id=' + id + params;
            link.setAttribute("href", url);
            link.appendChild(this.truncateText(name));
        }
        return link;
    },

    /**
     * Render input with action
     * @param cmp Component
     * @param id Id of object for event
     * @param value Input value
     * @param action Action name for event
     * @returns {Element}
     */
    renderInput: function (cmp, id, value, action) {
        var input = document.createElement("input");
        //Call Event on input change
        input.addEventListener('change', function (e) {
            var myEvent = cmp.getEvent("actionEvent");
            myEvent.setParams({"actionName": action, 'parameters': [{'id': id, 'value': e.target.value}]});
            myEvent.fire();
        });
        input.setAttribute("type", "text");
        if (typeof value != "undefined") {
            input.setAttribute("value", value);
        }
        if (typeof id != "undefined") {
            input.setAttribute("data-id", id);
        }
        input.className = "slds-input";
        return input;
    },

    /**
     * Render truncated text
     * @param value Text or Object
     * @returns {Element}
     */
    truncateText: function (value) {
        var truncate = document.createElement("div");
        truncate.className = "slds-truncate";
        if (typeof value != "object") {
            truncate.setAttribute("title", value);
            truncate.innerText = value;
        } else {
            truncate.appendChild(value);
        }
        return truncate;
    }
})