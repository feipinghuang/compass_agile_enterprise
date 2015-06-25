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

if (jQuery) {
    Compass.ErpApp.Utility.createNamespace("Compass.ErpApp.JQuerySupport");

    jQuery(document).ready(function () {
        Compass.ErpApp.JQuerySupport.setupHtmlReplace();
    });

    Compass.ErpApp.JQuerySupport.setupHtmlReplace = function () {
        jQuery(document).unbind('ajaxSuccess', Compass.ErpApp.JQuerySupport.handleHtmlUpdateResponse).bind('ajaxSuccess', Compass.ErpApp.JQuerySupport.handleHtmlUpdateResponse);
    };

    Compass.ErpApp.JQuerySupport.handleHtmlUpdateResponse = function (e, xhr, options, data) {
        var utility = Compass.ErpApp.Utility;

        //reset SessionTimeout
        if (utility.SessionTimeout.enabled) {
            utility.SessionTimeout.reset();
        }
        if (!utility.isBlank(data) && !utility.isBlank(data.htmlId)) {
            var updateDiv = $('#' + data.htmlId);
            try {
                updateDiv.closest('div.compass_ae-widget').unmask();
            }
            catch (ex) {
                //messy catch for no update div
            }

            updateDiv.html(data.html);
        }
    };
}