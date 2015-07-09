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

Ext.define("Compass.ErpApp.Login.ResetPassword", {
    extend: "Ext.window.Window",
    alias: "compass.erpapp.login.resetpassword",
    requires: ["Ext.Window"],
    width: 400,
    height: 300,
    defaultButton: 'reset',
    buttonAlign: 'center',
    closable: false,
    ui: 'main-login-window',
    submitForm: function () {
        var me = this;
        var form = me.down('form');
        var basicForm = form.getForm();
        if (basicForm.isValid()) {
            basicForm.submit({
                waitMsg: 'Resetting password...',
                params:{
                    token: me.initialConfig.token
                },
                success: function (form, action) {
                    var result = Ext.decode(action.response.responseText);
                    if (result.success) {
                        window.location = '/erp_app/login';
                    }
                    else {
                        Ext.Msg.alert("Error", result.message);
                    }
                },
                failure: function (form, action) {
                    var result = Ext.decode(action.response.responseText);

                    if (result['message']) {
                        Ext.Msg.alert("Error", result.message);
                    }
                    else {
                        Ext.Msg.alert("Error", "Login failed. Try again");
                    }
                }
            });
        }
    },
    constructor: function (config) {
        var me = this;

        var formPanel = Ext.create("Ext.FormPanel", {
            labelWidth: 75,
            frame: false,
            bodyStyle: 'padding:5px 5px 0',
            url: '/erp_app/update_password',
            fieldDefaults: {
                labelAlign: 'top',
                msgTarget: 'side'
            },
            items: [
                {
                    xtype: 'label',
                    itemId: 'errorMessage',
                    cls: 'error_message',
                    text: config.message
                },
                me.applicationContainerCombo,
                {
                    xtype: 'textfield',
                    fieldLabel: 'Password',
                    inputType: 'password',
                    width: 375,
                    allowBlank: false,
                    id: 'password',
                    name: 'password',
                    listeners: {
                        'specialkey': function (field, e) {
                            if (e.getKey() == e.ENTER) {
                                me.submitForm();
                            }
                        }
                    }
                },
                {
                    xtype: 'textfield',
                    fieldLabel: 'Password Confirmation',
                    inputType: 'password',
                    width: 375,
                    allowBlank: false,
                    id: 'passwordConfirmation',
                    name: 'password_confirmation',
                    listeners: {
                        'specialkey': function (field, e) {
                            if (e.getKey() == e.ENTER) {
                                me.submitForm();
                            }
                        }
                    }
                }
            ]
        });

        config = Ext.apply({
            title: 'Reset Password' || config['title'],
            items: formPanel,
            buttons: [
                {
                    text: 'Submit',
                    listeners: {
                        'click': function (button) {
                            me.submitForm();
                        }
                    }
                }
            ]
        }, config);
        this.callParent([config]);
    }
});