Ext.define("Compass.ErpApp.Desktop.Applications.SecurityManagement.RolesPanel", {
    extend: "Ext.panel.Panel",
    alias: 'widget.security_management_rolespanel',

    setRole: function (record) {
        var assign_to_id = record.get('id');
        var assign_to_description = record.get('description');

        var security_management_rolespanel = this;
        var southPanel = Ext.ComponentQuery.query('security_management_southpanel').first();

        var security_management_userswidget = southPanel.down('security_management_userswidget');

        security_management_userswidget.assign_to_id = assign_to_id;
        security_management_userswidget.assign_to_description = assign_to_description;

        var security_management_groupswidget = southPanel.down('security_management_groupswidget');
        security_management_groupswidget.assign_to_id = assign_to_id;
        security_management_groupswidget.assign_to_description = assign_to_description;

        var security_management_capabilitieswidget = southPanel.down('security_management_capabilitieswidget');
        security_management_capabilitieswidget.assign_to_id = assign_to_id;
        security_management_capabilitieswidget.assign_to_description = assign_to_description;
    },

    unsetRole: function () {
        var security_management_rolespanel = this;
        var southPanel = Ext.ComponentQuery.query('security_management_southpanel').first();

        var security_management_userswidget = southPanel.down('security_management_userswidget');
        delete security_management_userswidget.assign_to_id;
        delete security_management_userswidget.assign_to_description;

        var security_management_groupswidget = southPanel.down('security_management_groupswidget');
        delete security_management_groupswidget.assign_to_id;
        delete security_management_groupswidget.assign_to_description;

        var security_management_capabilitieswidget = southPanel.down('security_management_capabilitieswidget');
        delete security_management_capabilitieswidget.assign_to_id;
        delete security_management_capabilitieswidget.assign_to_description;
    },

    constructor: function (config) {
        var self = this;

        config = Ext.apply({
            width: 460,
            title: 'Roles',
            autoScroll: true,
            tbar: [
                {
                    text: 'New Role',
                    iconCls: 'icon-add',
                    handler: function (btn) {
                        var newWindow = Ext.create("Ext.window.Window", {
                            layout: 'fit',
                            width: 375,
                            title: 'New Role',
                            plain: true,
                            buttonAlign: 'center',
                            items: Ext.create('Ext.form.Panel', {
                                labelWidth: 110,
                                frame: false,
                                bodyStyle: 'padding:5px 5px 0',
                                url: '/erp_app/desktop/security_management/roles/create',

                                defaults: {
                                    width: 225
                                },
                                items: [
                                    {
                                        xtype: 'combobox',
                                        submitValue: false,
                                        store: {
                                            fields: [
                                                {name: "description", type: "string"},
                                                {name: "internal_identifier", type: "string"}
                                            ],
                                            autoLoad: true,
                                            proxy: {
                                                url: '/erp_app/desktop/security_management/roles/security_role_roots',
                                                method: 'get',
                                                type: "ajax",
                                                reader: {
                                                    type: 'json',
                                                    root: 'roots'
                                                }
                                            }
                                        },
                                        queryMode: 'local',
                                        displayField: 'description',
                                        valueField: 'internal_identifier',
                                        forceSelection: true,
                                        typeAhead: true,
                                        minChars: 2,
                                        fieldLabel: 'Parent Role',
                                        allowBlank: false,
                                        clearIcon: false,
                                        afterLabelTextTpl: requiredStar,
                                        listeners: {
                                            render: function (field) {
                                                field.getStore().load();
                                            }
                                        }
                                    },
                                    {
                                        xtype: 'textfield',
                                        fieldLabel: 'Role Name',
                                        allowBlank: false,
                                        name: 'description',
                                        listeners: {
                                            afterrender: function (field) {
                                                field.focus(false, 200);
                                            },
                                            specialkey: function (field, e) {
                                                if (e.getKey() == e.ENTER) {
                                                    var button = field.findParentByType('window').down('#submitButton');
                                                    button.fireEvent('click', button);
                                                }
                                            }
                                        }
                                    },
                                    {
                                        xtype: 'textfield',
                                        fieldLabel: 'Internal ID',
                                        allowBlank: false,
                                        name: 'internal_identifier',
                                        vtype: 'alphanum',
                                        listeners: {
                                            specialkey: function (field, e) {
                                                if (e.getKey() == e.ENTER) {
                                                    var button = field.findParentByType('window').down('#submitButton');
                                                    button.fireEvent('click', button);
                                                }
                                            }
                                        }
                                    }
                                ]
                            }),
                            buttons: [
                                {
                                    text: 'Submit',
                                    itemId: 'submitButton',

                                    listeners: {
                                        'click': function (button) {
                                            var formPanel = button.findParentByType('window').down('form');
                                            var parent = formPanel.items.items[0].value;

                                            formPanel.getForm().submit({

                                                params: {
                                                    parent_iid: parent
                                                },
                                                success: function (form, action) {
                                                    var obj = Ext.decode(action.response.responseText);

                                                    if (obj.success) {
                                                        var all = self.down('#all_roles').down('shared_dynamiceditablegrid');
                                                        Ext.Msg.alert('Status', obj.message);
                                                        all.getStore().load();
                                                        newWindow.close();
                                                    }
                                                    else {
                                                        Ext.Msg.alert("Error", obj.message);
                                                    }
                                                },
                                                failure: function (form, action) {
                                                    var obj = Ext.decode(action.response.responseText);

                                                    if (obj !== null) {
                                                        Ext.Msg.alert("Error", obj.message);
                                                    }
                                                    else {
                                                        Ext.Msg.alert("Error", "Error creating role");
                                                    }
                                                }
                                            });
                                        }
                                    }
                                },
                                {
                                    text: 'Close',
                                    handler: function () {
                                        newWindow.close();
                                    }
                                }
                            ]
                        });
                        newWindow.show();
                    }
                },
                {
                    text: 'Edit Role',
                    iconCls: 'icon-edit',
                    handler: function (btn) {
                        var all_roles = self.down('#all_roles').down('shared_dynamiceditablegrid');
                        var selection = all_roles.getSelectionModel().getSelection().first();
                        if (Ext.isEmpty(selection)) {
                            Ext.Msg.alert('Error', 'Please make a selection.');
                            return false;
                        }
                        var newWindow = Ext.create("Ext.window.Window", {
                            layout: 'fit',
                            width: 375,
                            title: 'Edit Role',
                            plain: true,
                            buttonAlign: 'center',
                            defaultFocus: 'role_name',
                            items: Ext.create('Ext.form.Panel', {
                                labelWidth: 110,
                                frame: false,
                                bodyStyle: 'padding:5px 5px 0',
                                url: '/erp_app/desktop/security_management/roles/update',
                                defaults: {
                                    width: 225
                                },
                                items: [
                                    {
                                        xtype: 'textfield',
                                        fieldLabel: 'Role Name',
                                        allowBlank: false,
                                        name: 'description',
                                        itemId: 'role_name',
                                        value: selection.get('description'),
                                        listeners: {
                                            afterrender: function (field) {
                                                field.focus(true, 200);
                                            },
                                            specialkey: function (field, e) {
                                                if (e.getKey() == e.ENTER) {
                                                    var button = field.findParentByType('window').down('#submitButton');
                                                    button.fireEvent('click', button);
                                                }
                                            }
                                        }
                                    }
                                ]
                            }),
                            buttons: [
                                {
                                    text: 'Submit',
                                    itemId: 'submitButton',
                                    listeners: {
                                        'click': function (button) {
                                            var formPanel = button.findParentByType('window').down('form');
                                            formPanel.getForm().submit({
                                                params: {
                                                    id: selection.get('id')
                                                },
                                                success: function (form, action) {
                                                    var obj = Ext.decode(action.response.responseText);
                                                    if (obj.success) {
                                                        var all = self.down('#all_roles').down('shared_dynamiceditablegrid');
                                                        all.getStore().load();
                                                        newWindow.close();
                                                    }
                                                    else {
                                                        Ext.Msg.alert("Error", obj.message);
                                                    }
                                                },
                                                failure: function (form, action) {
                                                    var obj = Ext.decode(action.response.responseText);
                                                    if (obj !== null) {
                                                        Ext.Msg.alert("Error", obj.message);
                                                    }
                                                    else {
                                                        Ext.Msg.alert("Error", "Error importing website");
                                                    }
                                                }
                                            });
                                        }
                                    }
                                },
                                {
                                    text: 'Close',
                                    handler: function () {
                                        newWindow.close();
                                    }
                                }
                            ]
                        });
                        newWindow.show();
                    }
                },
                {
                    text: 'Delete Role',
                    iconCls: 'icon-delete',
                    handler: function (btn) {
                        var all_roles = self.down('#all_roles').down('shared_dynamiceditablegrid');
                        var selection = all_roles.getSelectionModel().getSelection().first();
                        if (Ext.isEmpty(selection)) {
                            Ext.Msg.alert('Error', 'Please make a selection.');
                            return false;
                        }
                        Ext.MessageBox.confirm('Confirm', 'Are you sure?', function (btn) {
                            if (btn == 'no') {
                                return false;
                            }
                            else if (btn == 'yes') {
                                Ext.Ajax.request({
                                    url: '/erp_app/desktop/security_management/roles/delete',
                                    method: 'POST',
                                    params: {
                                        id: selection.get('id')
                                    },
                                    success: function (response) {
                                        var json_response = Ext.decode(response.responseText);
                                        if (json_response.success) {
                                            self.unsetRole();
                                            var all_roles = self.down('#all_roles').down('shared_dynamiceditablegrid');
                                            all_roles.getStore().load();
                                        } else {
                                            Ext.Msg.alert('Error', Ext.decode(response.responseText).message);
                                        }
                                    },
                                    failure: function (response) {
                                        Ext.Msg.alert('Error', 'Error Retrieving Effective Security');
                                    }
                                });
                            }
                        });
                    }
                }
            ],
            items: [
                {
                    xtype: 'security_management_role_grid',
                    itemId: 'all_roles',
                    height: 275,
                    setupUrl: '/erp_app/desktop/security_management/roles/available_setup',
                    dataUrl: '/erp_app/desktop/security_management/roles/available',
                    multiSelect: false,
                    grid_listeners: {
                        afterrender: function (grid) {
                            // autoLoad was causing erroneous calls to /erp_app/desktop/true so we manually load here
                            grid.getStore().load();
                        },
                        itemclick: function (grid, record, index, eOpts) {
                            self.setRole(record);

                            // get active tabpanel
                            var southPanel = Ext.ComponentQuery.query('security_management_southpanel').first();
                            var activeTabPanel = southPanel.down('tabpanel').getActiveTab();
                            activeTabPanel.refreshWidget();
                            activeTabPanel.updateTitle();
                        }
                    }
                }
            ]

        }, config);

        this.callParent([config]);
    }

});
