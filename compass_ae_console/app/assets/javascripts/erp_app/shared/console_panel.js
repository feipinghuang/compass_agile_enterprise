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

Ext.define("Compass.ErpApp.Desktop.Applications.CompassAeConsole.ConsolePanel", {
    extend: "Ext.panel.Panel",
    alias: 'widget.compass_ae_console_panel',
    title: 'CompassAE Console',
    closable: true,
    layout: 'border',

    desktop_console_history: [],
    desktop_console_history_index: 0,
    startup_heading: "<div class='compassConsoleHistory'><span style='color:goldenrod;'><b>Compass Console</b>&nbsp;(<span style='color:white;'>-help</span> for Help)</span></div>",

    listeners: {
        afterrender: function(comp) {
            comp.sendCommand('-clear');
        },
        show: function(comp) {
            comp.down('textarea').focus();
        },
        activate: function(comp) {
            comp.down('textarea').focus();
        }
    },

    initComponent: function() {
        var self = this;

        self.items = [{
            xtype: 'panel',
            itemId: 'console_history_panel',
            region: 'center',
            bodyStyle: "background-color:#000;padding:5px;",
            autoScroll: true,
            html: self.startup_heading
        }, {
            xtype: 'textarea',
            region: 'south',
            autoscroll: true,
            itemId: "console_text_area",
            enableKeyEvents: true,
            listeners: {
                afterrender: function(field) {
                    field.focus();
                },
                // use key-up for textarea since ENTER does not affect focus traversal
                keyup: function(field, e) {
                    if (e.getKey() == e.ENTER) {

                        self.sendCommand(field.getValue());
                        // add to history
                        self.desktop_console_history[self.desktop_console_history.length] = field.getValue().substring(0, field.getValue().length - 1);
                        //update index
                        self.desktop_console_history_index = self.desktop_console_history.length;
                        field.setValue("");
                    } else if (e.getKey() == e.UP) {

                        if (self.desktop_console_history.length === 0) {
                            // no history to display
                        } else {
                            self.desktop_console_history_index--;
                            if (self.desktop_console_history_index >= 0) {

                            } else {
                                self.desktop_console_history_index = self.desktop_console_history.length - 1;
                            }
                            field.setValue(self.desktop_console_history[self.desktop_console_history_index]);
                        }

                    } else if (e.getKey() == e.DOWN) {

                        if (self.desktop_console_history.length === 0) {
                            // no history to display
                        } else {
                            self.desktop_console_history_index++;
                            if (self.desktop_console_history_index >= (self.desktop_console_history.length)) {
                                self.desktop_console_history_index = 0;
                            }
                            field.setValue(self.desktop_console_history[self.desktop_console_history_index]);
                        }
                    }
                }
            }
        }];

        this.callParent();
    },

    sendCommand: function(command, includeOriginalCommand) {
        var self = this;

        if (Ext.isEmpty(includeOriginalCommand)) {
            includeOriginalCommand = true;
        }

        if (includeOriginalCommand)
            self.update_history_panel("<span style='color:white'>" + command + "</span>");

        if (Ext.String.startsWith(command, "-clear")) {
            self.clear_history_panel(self.startup_heading);
        } else {

            Ext.Ajax.request({
                url: '/compass_ae_console/erp_app/desktop/command',
                params: {

                    command_message: command
                },
                success: function(response) {
                    var text = response.responseText;
                    var result = Ext.JSON.decode(text);
                    self.update_history_panel("<div style='color:yellow;'>" + result.success + "</div>");
                }
            });
        }
    },

    clear_history_panel: function(text) {
        var self = this,
            panel = self.down('#console_history_panel'),
            historyDiv = panel.el.query('div.compassConsoleHistory').first();

        historyDiv.innerHTML = text;

        var d = panel.body.dom;
        d.scrollTop = d.scrollHeight - d.offsetHeight + 10;
        panel.doLayout();

        self.sendCommand('"Ruby version: #{RUBY_VERSION}, Rails version: #{Rails.version}, CompassAeConsole version: #{CompassAeConsole.version}"', false);
    },

    update_history_panel: function(text) {
        var self = this,
            panel = self.down('#console_history_panel'),
            historyDiv = panel.el.query('div.compassConsoleHistory').first();

        historyDiv.innerHTML = historyDiv.innerHTML + text + "<br>";

        var d = panel.body.dom;
        d.scrollTop = d.scrollHeight - d.offsetHeight + 10;
        panel.doLayout();
    }
});