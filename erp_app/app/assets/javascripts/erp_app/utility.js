// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require_self

var Compass = window['Compass'] || {};
Compass['ErpApp'] = Compass['ErpApp'] || {};
Compass.ErpApp['Utility'] = Compass.ErpApp['Utility'] || {};

//helper to create namespaces
Compass.ErpApp.Utility.createNamespace = function (namespaces) {
    var spaces = namespaces.split('.'),
        currentNamespace = null;

    for (var i = 0; i < spaces.length; i++) {
        var space = spaces[i];

        if (currentNamespace) {
            currentNamespace = currentNamespace[space] = currentNamespace[space] || {}
        }
        else {
            currentNamespace = window[space] = window[space] || {};
        }
    }
};

//handle session timeout
Compass.ErpApp.Utility.SessionTimeout = {
    enabled: false,
    redirectTo: null,
    warnInMilliseconds: null,
    warnTimer: null,
    redirectInMilliseconds: null,
    redirectTimer: null,

    setForceRedirectTimer: function (action) {
        switch (action) {
            case 'start':
                var self = this;
                this.redirectTimer = window.setTimeout(function () {
                    if (window['Ext']) {
                        Ext.Ajax.request({
                            method: 'GET',
                            url: '/session/is_alive',
                            success: function (response, request) {
                                var result = Ext.decode(response.responseText);
                                if (result.success) {
                                    self.reset();
                                }
                                else {
                                    window.location = self.redirectTo;
                                }
                            }
                        });
                    }
                    else {
                        jQuery.ajax({
                            method: 'GET',
                            url: '/session/is_alive',
                            success: function (result, request) {
                                if (result.success) {
                                    self.reset();
                                }
                                else {
                                    window.location = self.redirectTo;
                                }
                            }
                        });
                    }
                }, this.redirectInMilliseconds);
                break;
            case 'stop':
                clearTimeout(this.redirectTimer);
                break;
        }
    },
    setWarnTimer: function (action) {
        switch (action) {
            case 'start':
                var self = this;
                this.warnTimer = window.setTimeout(function () {
                    if (window['Ext']) {
                        Ext.MessageBox.confirm('Confirm', 'Your session is about to expire due to inactivity. Do you wish to continue this session?', function (btn) {
                            if (btn == 'no') {
                                window.location = self.redirectTo;
                            }
                            else if (btn == 'yes') {
                                Ext.Ajax.request({
                                    method: 'POST',
                                    url: '/session/keep_alive',
                                    success: function (response, request) {
                                        var responseObj = Ext.decode(response.responseText);
                                        if (responseObj.success) {
                                            self.reset();
                                        }
                                        else {
                                            window.location = self.redirectTo;
                                        }
                                    }
                                });
                            }
                        });
                    }
                    else {
                        var warningModal = jQuery('<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true"></div>'),
                            modalDialog = jQuery('<div class="modal-dialog"></div>'),
                            modalContent = jQuery('<div class="modal-content"></div>'),
                            modalHeader = jQuery('<div class="modal-header"><h4 class="modal-title" id="myModalLabel">Please Confirm</h4></div>'),
                            modalBody = jQuery('<div class="modal-body">Your session is about to expire due to inactivity. Do you wish to continue this session?</div>'),
                            footer = jQuery('<div class="modal-footer"></div>'),
                            yesBtn = jQuery('<button type="button" class="btn btn-default" data-dismiss="modal">Yes</button>'),
                            noBtn = jQuery('<button type="button" class="btn btn-primary" data-dismiss="modal">No</button>');

                        footer.append(yesBtn);
                        footer.append(noBtn);
                        modalContent.append(modalHeader);
                        modalContent.append(modalBody);
                        modalContent.append(footer);
                        modalDialog.append(modalContent);
                        warningModal.append(modalDialog);

                        noBtn.bind('click', function () {
                            warningModal.modal('hide');
                            warningModal.remove();
                            window.location = self.redirectTo;
                        });

                        yesBtn.bind('click', function () {
                            warningModal.modal('hide');
                            warningModal.remove();

                            jQuery.ajax({
                                method: 'POST',
                                url: '/session/keep_alive',
                                success: function (result, request) {
                                    self.reset();
                                }
                            });
                        });

                        jQuery("body").append(warningModal);

                        warningModal.modal({backdrop: false});
                    }

                }, this.warnInMilliseconds);
                break;
            case 'stop':
                clearTimeout(this.warnTimer);
                break;
        }
    },
    setupSessionTimeout: function (warnInMilliseconds, redirectInMilliseconds, redirectTo) {
        if (window['Ext']) {
            Ext.Ajax.addListener('requestcomplete', function (conn, response, options) {
                if (options.url != '/session/is_alive') {
                    this.reset();
                }
            }, this);
        }

        this.enabled = true;
        this.redirectTo = redirectTo;
        this.warnInMilliseconds = warnInMilliseconds;
        this.redirectInMilliseconds = redirectInMilliseconds;

        this.setForceRedirectTimer('start');
        this.setWarnTimer('start');
    },
    reset: function () {
        this.resetWarning();
        this.resetRedirect();
    },
    resetWarning: function () {
        this.setWarnTimer('stop');
        this.setWarnTimer('start');
    },
    resetRedirect: function () {
        this.setForceRedirectTimer('stop');
        this.setForceRedirectTimer('start');
    }

};
//end handle session timeout

Compass.ErpApp.Utility.confirmBrowserNavigation = function (additionalMessage) {
    var me = this;

    additionalMessage = additionalMessage || null;
    window.onbeforeunload = function () {
        return me.isBlank(additionalMessage) ? '' : additionalMessage;
    }
};

Compass.ErpApp.Utility.disableEnterSubmission = function () {
    jQuery(function () {
        jQuery("form").bind("keypress", function (e) {
            if (e.keyCode == 13) return false;
        });
    });
};

Compass.ErpApp.Utility.promptReload = function () {
    if (window['Ext']) {
        Ext.MessageBox.confirm('Confirm', 'Page must reload for changes to take affect. Reload now?', function (btn) {
            if (btn == 'no') {
                return false;
            }
            else {
                window.location.reload();
            }
        });
    }
};

Compass.ErpApp.Utility.preventBrowserBack = function () {
    // Push some history into this windows history to help prevent back button
    for (var i = 0; i < 10; i++) {
        window.history.pushState("history", 'CompassAE Desktop', "#" + i * new Date().getMilliseconds());
    }
};

Compass.ErpApp.Utility.setupErpAppLogoutRedirect = function () {
    if (window['Ext']) {
        var runner = new Ext.util.TaskRunner(),
            task = runner.start({
                run: function () {
                    Ext.Ajax.request({
                        url: '/session/is_alive',
                        method: 'GET',
                        success: function (response) {
                            var responseObj = Ext.decode(response.responseText);
                            if (!responseObj.alive) {
                                window.location = '/erp_app/login';
                            }
                        },
                        failure: function () {
                            // Log or alert
                        }
                    });
                },
                interval: 60000
            });
    }
};

Compass.ErpApp.Utility.handleFormFailure = function (action) {
    if (window['Ext']) {
        switch (action.failureType) {
            case Ext.form.action.Action.CLIENT_INVALID:
                Ext.Msg.alert('Failure', 'Form fields may not be submitted with invalid values');
                break;
            case Ext.form.action.Action.CONNECT_FAILURE:
                Ext.Msg.alert('Failure', 'Ajax communication failed');
                break;
            case Ext.form.action.Action.SERVER_INVALID:
                Ext.Msg.alert('Failure', (action.result.msg || action.result.message));
        }
    }
};

Compass.ErpApp.Utility.randomString = function (length) {
    var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";
    var randomString = '';
    for (var i = 0; i < length; i++) {
        var randomNumber = Math.floor(Math.random() * chars.length);
        randomString += chars.substring(randomNumber, randomNumber + 1);
    }
    return randomString
};

Compass.ErpApp.Utility.roundNumber = function (num) {
    var twoDPString = "0.00";
    if (!Compass.ErpApp.Utility.isBlank(num) && !isNaN(num)) {
        var dnum = Math.round(num * 100) / 100;
        twoDPString = dnum + "";
        if (twoDPString.indexOf(".") == -1) {
            twoDPString += ".00"
        }
        if (twoDPString.indexOf(".") == twoDPString.length - 2) {
            twoDPString += "0"
        }

    }
    return twoDPString;
};

Compass.ErpApp.Utility.numbersOnly = function (e, decimal) {
    var key;
    var keychar;

    if (window.event) {
        key = window.event.keyCode;
    }
    else if (e) {
        key = e.which;
    }
    else {
        return true;
    }
    keychar = String.fromCharCode(key);

    if ((key == null) || (key == 0) || (key == 8) || (key == 9) || (key == 13) || (key == 27)) {
        return true;
    }
    else if ((("0123456789").indexOf(keychar) > -1)) {
        return true;
    }
    else if (decimal && (keychar == ".")) {
        return true;
    }
    else
        return false;
};

Compass.ErpApp.Utility.addCommas = function (nStr) {
    nStr += '';
    var x = nStr.split('.');
    var x1 = x[0];
    var x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
        x1 = x1.replace(rgx, '$1' + ',' + '$2');
    }
    return x1 + x2;
};

Compass.ErpApp.Utility.isBlank = function (obj) {
    if (window['Ext']) {
        return Ext.isEmpty(obj);
    }
    else {
        return (!obj || jQuery.trim(obj) === "" || obj.length == 0);
    }
};

Compass.ErpApp.Utility.removeDublicates = function (arrayName) {
    var newArray = [];
    label:for (var i = 0; i < arrayName.length; i++) {
        for (var j = 0; j < newArray.length; j++) {
            if (newArray[j].unit_id == arrayName[i].unit_id)
                continue label;
        }
        newArray[newArray.length] = arrayName[i];
    }
    return newArray;
};

Compass.ErpApp.Utility.isArray = function (o) {
    return Object.prototype.toString.call(o) === '[object Array]';
}

Compass.ErpApp.Utility.wait = function (ms) {
    ms += new Date().getTime();
    while (new Date() < ms) {
    }
};

Compass.ErpApp.Utility.limitTextArea = function (textArea, limit) {
    var value = textArea.value;
    if (value.length > limit) {
        textArea.value = value.substring(0, limit);
    }
    return true;
};

Compass.ErpApp.Utility.formatCurrency = function (num) {
    num = num.toString().replace(/\$|\,/g, '');
    if (isNaN(num))
        num = "0";
    var sign = (num == (num = Math.abs(num)));
    num = Math.floor(num * 100 + 0.50000000001);
    var cents = num % 100;
    num = Math.floor(num / 100).toString();
    if (cents < 10)
        cents = "0" + cents;
    for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3); i++)
        num = num.substring(0, num.length - (4 * i + 3)) + ',' +
        num.substring(num.length - (4 * i + 3));
    return (((sign) ? '' : '-') + '$' + num + '.' + cents);
};

Compass.ErpApp.Utility.addEventHandler = function (obj, evt, handler) {
    if (obj.addEventListener) {
        // W3C method
        obj.addEventListener(evt, handler, false);
    } else if (obj.attachEvent) {
        // IE method.
        obj.attachEvent('on' + evt, handler);
    } else {
        // Old school method.
        obj['on' + evt] = handler;
    }
};

function OnDemandLoadByAjax() {
    this.load = function (components, callback) {
        this.components = components;
        this.successCallBack = callback;
        this.attempts = 0;
        this.scriptsToLoad = [];

        if (!Compass.ErpApp.Utility.isArray(this.components)) {
            this.components = [this.components];
        }

        for (var i = 0; i < this.components.length; i++) {
            this.scriptsToLoad.push({
                url: this.components[i],
                status: 'pending'
            });
        }

        for (var t = 0; t < this.scriptsToLoad.length; t++) {
            this.loadScript(this.scriptsToLoad[t]);
        }
    };

    this.allScriptsDone = function () {
        for (var i = 0; i < this.scriptsToLoad.length; i++) {
            if (this.scriptsToLoad[i].status == 'pending')
                return false;
        }
        return true;
    };

    this.scriptDone = function () {
        if (this.allScriptsDone()) {
            this.onSuccess();
        }
    };

    this.loadScript = function (scriptToLoad) {
        var self = this;
        var ss = document.getElementsByTagName("script");
        for (i = 0; i < ss.length; i++) {
            if (ss[i].src && ss[i].src.indexOf(scriptToLoad.url) != -1) {
                scriptToLoad.status = 'success';
                self.scriptDone();
                return;
            }
        }

        var s = document.createElement("script");
        s.type = "text/javascript";
        s.async = true;
        s.src = scriptToLoad.url;
        var head = document.getElementsByTagName("head")[0];
        head.appendChild(s);
        s.onload = s.onreadystatechange = function () {
            if (this.readyState && this.readyState == "loading")
                return;
            scriptToLoad.status = 'success';
            self.scriptDone();
        };
        s.onerror = function () {
            head.removeChild(s);
            scriptToLoad.status = 'failure';
            self.scriptDone();
        }
    };

    this.onSuccess = function () {
        if (this.successCallBack) {
            this.successCallBack();
        }
    };

    this.onFailure = function () {
    };
}

//Javascript Extensions

//Array Extensions
Array.prototype.split = function (n) {
    var len = this.length, out = [], i = 0;
    while (i < len) {
        var size = Math.ceil((len - i) / n--);
        out.push(this.slice(i, i + size));
        i += size;
    }
    return out;
};

Array.prototype.contains = function (element) {
    for (var i = 0; i < this.length; i++) {
        if (this[i] == element) {
            return true;
        }
    }
    return false;
};

Array.prototype.find = function (find_statement) {
    try {
        for (var i = 0; i < this.length; i++) {
            var statement = "this[i]." + find_statement;
            if (eval(statement)) {
                return this[i];
            }
        }
    }
    catch (ex) {
        return null;
    }
    return null;
};

Array.prototype.select = function (find_statement) {
    var sub_array = [];
    try {
        for (var i = 0; i < this.length; i++) {
            var statement = "this[i]." + find_statement;
            if (eval(statement)) {
                sub_array.push(this[i]);
            }
        }
    }
    catch (ex) {
        return null;
    }
    return sub_array;
};

Array.prototype.first = function () {
    if (this[0] == undefined) {
        return null;
    }
    else {
        return this[0];
    }
};

Array.prototype.last = function () {
    if (this[this.length - 1] == undefined) {
        return null;
    }
    else {
        return this[this.length - 1];
    }
};

//Lazy enumerator methods for Array

Array.prototype.next = function () {
    if (this.currentIndex == undefined) {
        this.currentIndex = -1;
    }

    if (this[this.currentIndex + 1] != undefined) {
        return this[++this.currentIndex];
    } else {
        return false;
    }

};

Array.prototype.prev = function () {
    if (this.currentIndex == undefined) {
        this.currentIndex = -1;
    }

    if (this[this.currentIndex - 1] != undefined) {
        return this[--this.currentIndex];
    } else {
        return false;
    }

};

Array.prototype.current = function () {
    if (this.currentIndex == undefined) {
        this.currentIndex = -1;
    }
    return this[this.currentIndex];
};

Array.prototype.reset = function () {
    this.currentIndex = -1;
    return this[this.currentIndex];
};

Array.prototype.peek = function () {
    return this[this.currentIndex + 1];
};

Array.prototype.seek = function () {
    this.currentIndex = 0;
    return this[this.currentIndex];
};

//End of lazy enumerator methods for Array  

Array.prototype.collect = function (item) {
    var items = [];
    try {
        for (var i = 0; i < this.length; i++) {
            items.push(this[i][item]);
        }
    }
    catch (ex) {
        return null;
    }
    return items;
};

Array.prototype.empty = function () {
    return (this.length == 0);
};

Array.prototype.eachSlice = function (size, callback) {
    for (var i = 0, l = this.length; i < l; i += size) {
        callback.call(this, this.slice(i, i + size));
    }
};

//String Extensions
String.prototype.contains = function () {
    return String.prototype.indexOf.apply(this, arguments) !== -1;
};

String.prototype.downcase = function () {
    return this.toLowerCase();
};

String.prototype.upcase = function () {
    return this.toUpperCase();
};

String.prototype.capitalize = function () {
    return this.charAt(0).toUpperCase() + this.slice(1);
};

//Function Extensions

Function.prototype.bindToEventHandler = function bindToEventHandler() {
    var handler = this;
    var boundParameters = Array.prototype.slice.call(arguments);
    //create closure
    return function (e) {
        e = e || window.event; // get window.event if e argument missing (in IE)
        boundParameters.unshift(e);
        handler.apply(this, boundParameters);
    }
};

var stringToObject = function (str) {
    var arr = str.split(".");

    var fn = (window || this);
    for (var i = 0, len = arr.length; i < len; i++) {
        if (fn === undefined)
            return undefined;

        fn = fn[arr[i]];
    }

    if (typeof fn !== "object") {
        return undefined;
    }

    return fn;
};

var stringToFunction = function (str) {
    var arr = str.split(".");

    var fn = (window || this);
    for (var i = 0, len = arr.length; i < len; i++) {
        if (fn === undefined)
            return undefined;

        fn = fn[arr[i]];
    }

    if (typeof fn !== "function") {
        return undefined;
    }

    return fn;
};


