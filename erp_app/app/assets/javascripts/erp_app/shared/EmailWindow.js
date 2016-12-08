Ext.define('Compass.ErpApp.Shared.EmailWindow', {
    extend: 'Ext.window.Window',
    alias: 'widget.emailwindow',

    modal: true,
    title: 'Send Email',
    buttonAlign: 'center',
    tasks: [],
    bodyPadding: 5,

    url: null,
    fileAssetHolderType: null,
    fileAssetHolderId: null,
    toEmail: null,
    fromEmail: null,
    ccEmail: null,
    subject: null,
    submitMethod: 'PUT',
    additionalData: {},

    buttons: [{
        text: 'Submit',
        handler: function(btn) {
            btn.up('emailwindow').submit();
        }
    }, {
        text: 'Cancel',
        handler: function(btn) {
            btn.up('emailwindow').close();
        }
    }],

    initComponent: function() {
        var me = this;

        var required = '<span style="color:red;font-weight:bold" data-qtip="Required">*</span>';
        var emailRegex = /^([\w+-.%]+@[\w-.]+\.[A-Za-z]{2,4},?;?)+$/;

        me.addEvents(
            // fired when an email is successfully sent
            'emailsent',

            // fired when an email has an error
            'emailerror'
        );

        var formItems = [{
            xtype: 'textfield',
            fieldLabel: 'From',
            regex: /^([\w+-.%]+@[\w-.]+\.[A-Za-z]{2,4},?;?)+$/,
            regexText: 'Invalid email(s)',
            name: 'from_email',
            value: me.fromEmail,
            afterLabelTextTpl: required,
            allowBlank: false
        }, {
            xtype: 'textfield',
            fieldLabel: 'To',
            regex: emailRegex,
            regexText: 'Invalid email(s)',
            name: 'to_email',
            value: me.toEmail,
            afterLabelTextTpl: required,
            allowBlank: false
        }, {
            xtype: 'textfield',
            fieldLabel: 'CC',
            regex: emailRegex,
            regexText: 'Invalid email(s)',
            name: 'cc_email',
            value: me.ccEmail
        }, {
            xtype: 'textfield',
            fieldLabel: 'Subject',
            name: 'subject',
            value: me.subject,
            afterLabelTextTpl: required,
            allowBlank: false
        }, {
            xtype: 'htmleditor',
            name: 'message',
            fieldLabel: 'Message',
            height: 200,
            allowBlank: false
        }];

        if (me.fileAssetHolderType && me.fileAssetHolderId) {
            formItems.splice(3, 0, {
                xtype: 'container',
                layout: 'hbox',
                width: 800,
                items: [{
                    xtype: 'button',
                    text: 'Attach Files',
                    iconCls: 'icon-documents',
                    width: 100,
                    handler: me.attachFiles,
                    style: {
                        marginRight: '5px'
                    }
                }, {
                    xtype: 'displayfield',
                    itemId: 'selectedFileNames',
                    style: {
                        marginLeft: '5px'
                    }
                }, {
                    xtype: 'hiddenfield',
                    name: 'file_attachment_ids',
                    itemId: 'selectedFileIds'
                }]
            });
        }

        Ext.each(me.additionalFields, function(item) {
            formItems.unshift(item);
        });

        me.items = [{
            xtype: 'form',
            layout: {
                type: 'vbox'
            },
            defaultFocus: 'subject',
            border: false,
            bodyPadding: 10,
            fieldDefaults: {
                labelAlign: 'top',
                labelWidth: 100,
                width: 800,
                labelStyle: 'font-weight:bold'
            },
            items: formItems
        }];

        me.callParent(arguments);
    },

    submit: function() {
        var me = this;

        if (me.down('form').isValid()) {
            me.down('form').submit({
                url: me.url,
                method: me.submitMethod,
                waitMsg: 'Please wait...',
                params: me.additionalData,
                success: function(form, action) {
                    if (action.result.success) {
                        if (me.fireEvent('emailsent') !== false) {
                            window.close();
                        }
                    } else {
                        Ext.Msg.alert('Failure', action.result.message);
                    }

                    Ext.Msg.alert('Success', 'Email sent');

                    me.fireEvent('emailsent');

                    me.close();
                },
                failure: function(form, action) {
                    me.fireEvent('emailerror');

                    Compass.ErpApp.Utility.handleFormFailure(action);
                }
            });
        }
    },

    attachFiles: function(btn) {
        var me = btn.up('emailwindow');

        var window = Ext.widget('window', {
            title: 'Select Documents',
            modal: true,
            buttonAlign: 'center',
            items: [{
                xtype: 'emailwindowattachfilesgrid',
                file_asset_holder_type: me.fileAssetHolderType,
                file_asset_holder_id: me.fileAssetHolderId
            }],
            buttons: [{
                text: 'Submit',
                handler: function(btn) {
                    var grid = window.down('emailwindowattachfilesgrid');
                    var records = grid.getSelectionModel().getSelection();

                    me.selectFiles(records);
                    window.close();
                }
            }, {
                text: 'Cancel',
                handler: function(btn) {
                    window.close();
                }
            }]
        });

        window.show();
    },

    selectFiles: function(selectedFiles) {
        var me = this;

        me.down('#selectedFileNames').setValue();
        me.down('#selectedFileIds').setValue();

        me.down('#selectedFileNames').setValue(Ext.Array.map(selectedFiles, function(item) {
            return item.get('name');
        }).join(', '));
        me.down('#selectedFileIds').setValue(Ext.Array.map(selectedFiles, function(item) {
            return item.get('id');
        }).join(', '));
    }
});

Ext.define('Compass.ErpApp.Shared.EmailWindow.AttachFilesGrid', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.emailwindowattachfilesgrid',

    width: 600,
    height: 300,
    selType: 'checkboxmodel',
    columns: [{
        header: 'Preview',
        dataIndex: 'thumbnail_src',
        sortable: false,
        width: 75,
        style: 'text-align:center;',
        renderer: function(value, metaData, record) {
            return "<img src='" + value + "' height='50px' width='50px' />";
        }
    }, {
        header: 'Description',
        dataIndex: 'description',
        flex: 1
    }, {
        header: 'File Name',
        dataIndex: 'name',
        flex: 1
    }, {
        header: 'Tags',
        dataIndex: 'tags',
        sortable: false,
        width: 75
    }],

    initComponent: function() {
        var me = this;

        me.store = Ext.create('Ext.data.Store', {
            method: 'GET',
            proxy: {
                type: 'ajax',
                url: '/api/v1/file_assets',
                extraParams: {
                    query_filter: Ext.encode({
                        file_asset_holder_type: me.file_asset_holder_type,
                        file_asset_holder_id: me.file_asset_holder_id
                    })
                },
                reader: {
                    type: 'json',
                    root: 'file_assets',
                    totalProperty: 'total_count'
                }
            },
            fields: [
                'description',
                'id',
                'tags',
                'name',
                'thumbnail_src'
            ]
        });

        me.dockedItems = [{
            xtype: 'pagingtoolbar',
            dock: 'bottom',
            pageSize: 25,
            store: me.store,
            displayInfo: true,
            displayMsg: 'Displaying {0} - {1} of {2}',
            emptyMsg: "No Files"
        }];

        me.callParent([arguments]);

        me.store.load();
    }
});