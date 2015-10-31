Ext.define("Compass.ErpApp.Desktop.SelectRolesWindow", {
    extend: "Ext.window.Window",
    alias: 'widget.selectroleswindow',

    /*
     * @param baseParams
     * Object
     * Base params to add to url post
     */
    baseParams: {},

    /*
     * @param url
     * String
     * Url to call to save roles
     */
    url: null,

    /*
     * @param availableRoles
     * Array
     * Array of available roles
     */
    availableRoles: [],

    /*
     * @param currentSecurity
     * Array / Object
     * Current security settings, can be a list of roles or broken down by capabilities
     * ['admin','manager']
     * or
     * {
     *   create: ['admin','manager'],
     *   edit: ['admin','manager'],
     *   delete: ['admin','manager']
     * }
     */
    currentSecurity: [],

    /*
     * @param capabilities
     * Array
     * Capabilities to show, if nothing is passed no capabilities will be shown but if
     * capabilities are passed an accordion view will be built for each capability as a
     * section in the accordion
     */
    capabilities: [],

    initComponent: function () {

        this.addEvents(
            /**
             * @event success
             * Fired after success response is received from server
             * @param {Compass.ErpApp.Desktop.SelectRolesWindow} this Object
             * @param {Object} Server Response
             */
            "success",
            /**
             * @event failure
             * Fired after response is received from server with error
             * @param {Compass.ErpApp.Desktop.SelectRolesWindow} this Object
             * @param {Object} Server Response
             */
            "failure"
        );

        this.callParent(arguments);
    },

    constructor: function (config) {
        var currentSecurity = config['currentSecurity'] || [],
            capabilities = config['capabilities'] || [],
            availableRoles = config['availableRoles'],
            baseParams = config['baseParams'] || {},
            url = config['url'],
            checkBoxes = [],
            panel = [];

        Ext.each(availableRoles, function (role) {
            checkBoxes.push({
                name: role['internal_identifier'],
                boxLabel: role['description']
            })
        });

        if (capabilities.length > 0) {
            panel = Ext.create('widget.panel', {
                itemId: 'securityPanel',
                layout: 'accordion'
            });

            Ext.each(capabilities, function (capability) {
                var form = panel.add({
                    title: 'Can ' + capability.humanize(),
                    itemId: capability,
                    xtype: 'form',
                    labelWidth: 110,
                    bodyPadding: '5px',
                    autoScroll: true,
                    frame: false,
                    defaults: {
                        width: 225
                    },
                    items: [
                        {
                            xtype: 'fieldset',
                            autoScroll: true,
                            checkboxToggle: true,
                            collapsed: true,
                            title: 'Enable Security',
                            defaultType: 'checkbox',
                            items: checkBoxes,
                            listeners:{
                                collapse: function(fieldset){
                                    Ext.each(fieldset.query('checkbox'), function(checkbox){
                                        checkbox.setValue(false);
                                    });
                                }
                            }
                        }
                    ]
                });

                if (!Ext.isEmpty(currentSecurity[capability])) {
                    form.down('fieldset').toggle();
                }

                if(currentSecurity[capability]){
                    form.down('fieldset').checkboxCmp.setValue(true);
                }

                // check current selected roles
                form.getForm().getFields().each(function (field) {
                    if (currentSecurity[capability] && currentSecurity[capability].contains(field.getName())) {
                        field.setValue(true);
                    }
                });
            });
        }
        else {
            panel = Ext.create('widget.form', {
                itemId: 'securityPanel',
                timeout: 130000,
                autoScroll: true,
                labelWidth: 110,
                bodyPadding: '5px',
                frame: false,
                layout: 'fit',
                url: config['url'],
                defaults: {
                    width: 225
                },
                items: [
                    {
                        xtype: 'fieldset',
                        autoScroll: true,
                        title: 'Select Roles',
                        defaultType: 'checkbox',
                        items: checkBoxes
                    }
                ]
            });

            // check current selected roles
            panel.getForm().getFields().each(function (field) {
                if (currentSecurity.contains(field.getName())) {
                    field.setValue(true);
                }
            });
        }

        config = Ext.apply({
            layout: 'vbox',
            modal: true,
            title: 'Secure',
            iconCls: 'icon-document_lock',
            width: 250,
            height: 600,
            buttonAlign: 'center',
            plain: true,
            items: panel,
            buttons: [
                {
                    text: 'Submit',
                    itemId: 'submitButton',
                    listeners: {
                        'click': function (button) {
                            var win = button.up('selectroleswindow');
                            var securityPanel = win.down('#securityPanel');
                            var security = null;

                            if (capabilities.length > 0) {
                                security = {};

                                Ext.each(capabilities, function (capability) {
                                    if(securityPanel.down('#' + capability).down('fieldset').checkboxCmp.getValue()){
                                        security[capability] = [];

                                        securityPanel.down('#' + capability).getForm().getFields().each(function (field) {
                                            if (field.getValue() && field.cls != 'x-fieldset-header-checkbox') {
                                                security[capability].push(field.getName());
                                            }
                                        });
                                    }
                                });
                            }
                            else {
                                security = [];

                                securityPanel.getForm().getFields().each(function (field) {
                                    if (field.getValue()) {
                                        security.push(field.getName());
                                    }
                                });
                            }

                            var params = Ext.apply({
                                security: Ext.encode(security)
                            }, baseParams);

                            var waitMsg = Ext.Msg.wait('Please Wait...', 'Saving');

                            Ext.Ajax.request({
                                method: 'PUT',
                                url: url,
                                params: params,
                                success: function (response) {
                                    waitMsg.close();
                                    var responseObj = Ext.decode(response.responseText);

                                    if (responseObj.success) {
                                        win.fireEvent('success', win, responseObj);
                                        win.close();
                                    }
                                    else {
                                        win.fireEvent('failure', win, responseObj);
                                    }

                                },
                                failure: function (response) {
                                    waitMsg.close();
                                    var responseObj = Ext.decode(response.responseText);

                                    win.fireEvent('failure', win, responseObj);
                                }
                            });
                        }
                    }
                },
                {
                    text: 'Cancel',
                    listeners: {
                        'click': function (button) {
                            var win = button.up('selectroleswindow');
                            win.close();
                        }
                    }
                }
            ]
        }, config);

        this.callParent([config]);
    }

});