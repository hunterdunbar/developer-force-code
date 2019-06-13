({
    /**
     * Component Initialization
     * @param cmp
     */
    doInit: function (cmp) {
        //Generate random table Id
        if (cmp.get("v.tableId") == "") {
            var id = Math.random().toString(36).substring(5);
            cmp.set("v.tableId", id);
        }
    },

    /**
     * Render table
     * @param cmp
     * @param event
     * @param helper
     */
    renderTable: function (cmp, event, helper) {

        //If component complete render
        if (cmp.get("v.allow")) {

            //Generated table id
            var id = cmp.get("v.tableId");

            //Set of objects (rows)
            var objectSet = cmp.get("v.objectSet");

            //Set of fields (columns)
            var fieldSet = cmp.get("v.fieldSet");

            //Pagination parameters
            var pageSet = cmp.get("v.pageSet");

            //Clear table
            document.getElementById(id).innerHTML = "";

            //Rows iteration
            objectSet.forEach(function (s, rowNumber) {

                //Create row element
                var tableRow = document.createElement('tr');

                //Set id of object to row attribute
                tableRow.setAttribute("data-id", s["Id"]);

                //Columns Iteration
                fieldSet.forEach(function (field, fieldNumber) {

                    //If first column, create TH, else create TD
                    var tableData = fieldNumber == 0 ? document.createElement('th') : document.createElement('td');

                    //Add additional classes to column
                    if (field.class != null)tableData.className = field.class;

                    //Check on null value
                    var fieldValue = typeof s[field.name] == "undefined" ? "" : s[field.name];
                    fieldValue = fieldValue == null || fieldValue == "null" ? "" : fieldValue;

                    //Render column in case of column type
                    var tableDataNode;
                    switch (field.type) {
                        /**
                         * List of Buttons [{'title': 'title 1', 'action': 'action 1' }, {...}, {...}]
                         */
                        case "buttonList":
                            field.values.forEach(function (btn) {
                                tableDataNode = helper.renderButton(cmp, s["Id"], btn.title, btn.action);
                                tableData.appendChild(tableDataNode);
                            });
                            break;

                        /**
                         * Link with Name of current Column value
                         * {'name': 'Link Title', 'action': 'Action name for Event', 'dataField': null}
                         * If data field == null, Id for event = Row Id, else - dataField value
                         */
                        case "link":
                            tableDataNode = helper.renderActionLink(cmp, field.dataField != null ? s[field.dataField] : s["Id"], s[field.name], field.action);
                            tableData.appendChild(helper.truncateText(tableDataNode));
                            break;

                        /**
                         * Link with real url address
                         * {'link': 'urlofcomponent', 'dataField': 'idvalue', 'name': 'title of link'}
                         * result: <a href="#urlofcomponent?id=idvalue">title of link</a>
                         */
                        case "realLink":
                            tableDataNode = helper.renderRealLink(cmp,
                                field.link,
                                field.dataField != null ? s[field.dataField] : s["Id"],
                                field.staticName ? field.staticName : s[field.name],
                                field.customParams);
                            tableData.appendChild(tableDataNode);
                            break;

                        /**
                         * Render element in root component function
                         */
                        case "custom":
                            //Get value from current column or from custom column
                            if (field != null && field.hasOwnProperty('fieldName')) {
                                fieldValue = s[field.fieldName] == null ? s : s[field.fieldName];
                            }
                            var action = field.action;
                            if (fieldValue != null && fieldValue != "null") {
                                tableDataNode = action(fieldValue);
                                if (typeof tableDataNode != "object") {
                                    tableData.innerHTML = tableDataNode;
                                } else {
                                    tableData.appendChild(tableDataNode);
                                }
                            }
                            break;

                        /**
                         * Render date in local timezone
                         */
                        case "localDate":
                            var dateFormat = function (dateObject) {
                                var month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                                var a = dateObject.split(/[^0-9]/);
                                var d = a.length > 3 ? new Date(Date.UTC(a[0], a[1] - 1, a[2], a[3], a[4], a[5])) : new Date(Date.UTC(a[0], a[1] - 1, a[2]));
                                var day = d.getDate();
                                var m = d.getMonth() + 1;
                                var year = d.getFullYear();
                                day = day < 10 ? "0" + day : day;
                                m = m < 10 ? "0" + m : m;

                                var hours = d.getHours();
                                var minutes = d.getMinutes();
                                var ampm = hours >= 12 ? 'PM' : 'AM';
                                hours = hours % 12;
                                hours = hours ? hours : 12;
                                minutes = minutes < 10 ? '0' + minutes : minutes;
                                var strTime = hours + ':' + minutes + ' ' + ampm;
                                return m + "/" + day + "/" + year;
                            };

                            var textDate = "";
                            var truncate = document.createElement("div");
                            truncate.className = "slds-truncate";

                            if (fieldValue != null && fieldValue.length >= 10) {
                                textDate = dateFormat(fieldValue);
                                truncate.setAttribute("title", fieldValue);
                            }
                            tableDataNode = document.createTextNode(textDate);
                            truncate.appendChild(tableDataNode);
                            tableData.appendChild(truncate);
                            break;

                        /**
                         * Render current date
                         */
                        case "currentDate":
                            var dateFormat = function (dateObject) {
                                var month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                                var d = new Date(dateObject);
                                var day = d.getDate();
                                var m = d.getMonth() + 1;
                                var year = d.getFullYear();
                                day = day < 10 ? "0" + day : day;
                                m = m < 10 ? "0" + m : m;
                                return m + "/" + day + "/" + year;
                            };

                            var textDate = dateFormat(new Date());
                            tableDataNode = document.createTextNode(textDate);
                            tableData.appendChild(helper.truncateText(tableDataNode));
                            break;

                        /**
                         * First number column (counter)
                         */
                        case "number":
                            tableData.className = "numberTd";
                            var firstNum = pageSet.length > 0 ? (pageSet[0].pageNumber - 1) * pageSet[0].pageSize : 0;
                            tableDataNode = document.createTextNode('' + (firstNum + rowNumber + 1));
                            tableData.appendChild(helper.truncateText(tableDataNode));
                            break;

                        /**
                         * Render value of field with children fields
                         */
                        case "object":
                            var params = field.params;
                            fieldValue = typeof s[params.object] == "undefined" ? s[field.name] : s[params.object];
                            field.params.field.forEach(function (v) {
                                fieldValue = fieldValue != null && fieldValue.hasOwnProperty(v) ? fieldValue[v] : "";
                            });
                            tableData.appendChild(helper.truncateText(fieldValue));
                            break;

                        /**
                         * Render Input
                         */
                        case "input":
                            tableDataNode = helper.renderInput(cmp, s["Id"], s[field.name], field.action);
                            tableData.appendChild(helper.truncateText(tableDataNode));
                            break;

                        /**
                         * Render truncated text
                         */
                        default:
                            tableData.appendChild(helper.truncateText(fieldValue));
                            break;
                    }

                    //If column has buttons, added class
                    if ($(tableData).find('.slds-button').length > 0 && !$(tableData).hasClass('buttonsTd')) {
                        $(tableData).addClass('buttonsTd')
                    }
                    tableRow.appendChild(tableData);
                });
                document.getElementById(id).appendChild(tableRow);
            });

            //Call event after table render finished
            var myEvent = cmp.getEvent("actionEvent");
            myEvent.setParams({"actionName": "tableRenderComplete", 'parameters': [{'tableId': cmp.get("v.tableId")}]});
            myEvent.fire();
        }
    }
})