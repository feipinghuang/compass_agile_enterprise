Compass.ErpApp.Desktop.Applications.Knitkit.addHostOptions = function (self, items, record) {
    if (currentUser.hasCapability('edit', 'WebsiteHost')) {
        items.push({
            text: 'Update',
            iconCls: 'icon-edit',
            listeners: {
                'click': function () {
                    Ext.create("Ext.window.Window", {
                        title: 'Update Host',
                        modal: true,
                        buttonAlign: 'center',
                        items: Ext.create("Ext.form.Panel", {
                            labelWidth: 50,
                            frame: false,
                            bodyStyle: 'padding:5px 5px 0',
                            url: '/knitkit/erp_app/desktop/website_host/' + record.data.websiteHostId,
                            defaults: {
                                width: 300
                            },
                            items: [
                                {
                                    xtype: 'textfield',
                                    fieldLabel: 'Host',
                                    id: 'knitkitUpdateWebsiteHostHost',
                                    name: 'host',
                                    value: record.data.host,
                                    allowBlank: false
                                }
                            ]
                        }),
                        buttons: [
                            {
                                text: 'Submit',
                                listeners: {
                                    'click': function (button) {
                                        var window = button.findParentByType('window');
                                        var formPanel = window.query('form')[0];

                                        formPanel.getForm().submit({
                                            method: 'PUT',
                                            waitMsg: 'Please wait...',
                                            success: function (form, action) {
                                                var obj = Ext.decode(action.response.responseText);
                                                if (obj.success) {
                                                    var newHost = Ext.getCmp('knitkitUpdateWebsiteHostHost').getValue();
                                                    record.set('host', newHost);
                                                    record.set('text', newHost);
                                                    window.close();
                                                }
                                                else {
                                                    Ext.Msg.alert("Error", obj.msg);
                                                }
                                            },
                                            failure: function (form, action) {
                                                var obj = Ext.decode(action.response.responseText);
                                                var message = obj.message.indexOf('Host') == 0 ? obj.message : "Error Updating Host"
                                                Ext.Msg.alert("Error", message);
                                            }
                                        });
                                    }
                                }
                            },
                            {
                                text: 'Close',
                                handler: function (btn) {
                                    btn.up('window').close();
                                }
                            }
                        ]
                    }).show();
                }
            }
        });
    }

    if (currentUser.hasCapability('delete', 'WebsiteHost')) {
        items.push({
            text: 'Delete',
            iconCls: 'icon-delete',
            listeners: {
                'click': function () {
                    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this Host?', function (btn) {
                        if (btn == 'no') {
                            return false;
                        }
                        else if (btn == 'yes') {

                            Ext.Ajax.request({
                                url: '/knitkit/erp_app/desktop/website_host/' + record.data.websiteHostId,
                                method: 'DELETE',
                                success: function (response) {
                                    var obj = Ext.decode(response.responseText);
                                    if (obj.success) {
                                        record.remove();
                                    }
                                    else {
                                        Ext.Msg.alert('Error', 'Error deleting Host');
                                    }
                                },
                                failure: function (response) {
                                    Ext.Msg.alert('Error', 'Error deleting Host');
                                }
                            });
                        }
                    });
                }
            }
        });
    }

    return items;
};