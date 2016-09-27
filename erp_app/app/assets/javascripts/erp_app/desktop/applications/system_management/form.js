Ext.define('Compass.ErpApp.Desktop.Applications.SystemManagement.Form', {
    extend: 'Ext.form.Panel',
    alias: 'widget.systemmanagement-form',
    closable: true,
    bodyPadding: '5px',

    // custom properties
    serverId: null,
    parentId: null,
    klass: null,
    isAdd: false,

    dockedItems: [
        {
            dock: 'top',
            xtype: 'toolbar',
            items: [
                {
                    xtype: 'button',
                    text: 'Save',
                    iconCls: 'icon-save',
                    handler: function (btn) {
                        var method = null;
                        var url = '/erp_app/desktop/system_management/types';
                        var form = btn.up('form');
                        var params = {};

                        if (form.parentId) {
                            params['parent_id'] = form.parentId;
                        }

                        if (form.klass) {
                            params['klass'] = form.klass;
                        }

                        if (form.isAdd) {
                            method = 'POST';
                        }
                        else {
                            method = 'PUT';
                            url += '/' + form.serverId
                        }

                        if (form.isValid()) {
                            var myMask = new Ext.LoadMask({
                                msg: 'Please wait...',
                                target: form
                            });
                            myMask.show();

                            params = Ext.apply(params, form.getValues());

                            Ext.Ajax.request({
                                url: url,
                                method: method,
                                params: params,
                                success: function (response) {
                                    var responseObj = Ext.decode(response.responseText);
                                    myMask.hide();
                                    if (responseObj.success) {
                                        form.fireEvent('saved', form, responseObj.type);
                                    }
                                    else {
                                        Ext.Msg.alert('Error', responseObj.message);
                                    }
                                },
                                failure: function () {
                                    myMask.hide();
                                    Ext.Msg.alert('Error', 'Application Error');
                                }
                            });
                        }
                    }
                }
            ]
        }
    ],
    defaults: {
        xtype: 'textfield',
        allowBlank: false,
        labelWidth: 125,
        width: 400
    },
    items: [
        {
            name: 'internal_identifier',
            fieldLabel: 'Internal Identifier'
        },
        {
            name: 'description',
            fieldLabel: 'Description'
        }
    ],

    initialize: function () {
        this.addEvent('saved');

        this.callParent();
    }
});