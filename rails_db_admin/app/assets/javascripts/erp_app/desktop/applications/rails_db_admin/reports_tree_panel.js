Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReportsTreePanel", {
    extend: "Compass.ErpApp.Shared.FileManagerTree",
    alias: 'widget.railsdbadmin_reportstreepanel',

    newReport: function () {
        var me = this;

        Ext.create("Ext.window.Window", {
            title: 'New Report',
            plain: true,
            buttonAlign: 'center',
            defaultFocus: 'title',
            items: Ext.create('Ext.FormPanel', {
                labelWidth: 110,
                frame: false,
                bodyStyle: 'padding:5px 5px 0',
                url: '/rails_db_admin/erp_app/desktop/reports/create',
                defaults: {
                    width: 225
                },
                items: [
                    {
                        xtype: 'textfield',
                        fieldLabel: 'Title',
                        allowBlank: false,
                        name: 'name',
                        itemId: 'title'
                    },
                    {
                        xtype: 'textfield',
                        fieldLabel: 'Unique Name',
                        allowBlank: false,
                        name: 'internal_identifier'
                    }
                ]
            }),
            buttons: [
                {
                    text: 'Submit',
                    listeners: {
                        'click': function (button) {
                            var window = button.up('window');
                            var formPanel = window.down('form');
                            formPanel.getForm().submit({
                                waitMsg: 'Creating Report...',
                                success: function (form, action) {
                                    var obj = Ext.decode(action.response.responseText);
                                    if (obj.success) {
                                        button.up('window').close();
                                        me.getStore().load();
                                    }
                                    else {
                                        Ext.Msg.alert("Error", obj.msg);
                                    }
                                },
                                failure: function (form, action) {
                                    var obj = Ext.decode(action.response.responseText);
                                    if (obj.msg) {
                                        Ext.Msg.alert("Error", obj.msg);
                                    }
                                    else {
                                        Ext.Msg.alert("Error", "Error creating report.");
                                    }
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
    },

    uploadReport: function () {
        var me = this;
        Ext.create("Ext.window.Window", {
            modal: true,
            title: 'New Report',
            buttonAlign: 'center',
            items: {
                xtype: 'form',
                timeout: 300,
                frame: false,
                bodyStyle: 'padding:5px 5px 0',
                fileUpload: true,
                url: '/rails_db_admin/erp_app/desktop/reports/create',
                items: [
                    {
                        xtype: 'fileuploadfield',
                        width: '350px',
                        fieldLabel: 'Upload Report',
                        buttonText: 'Upload',
                        buttonOnly: false,
                        allowBlank: true,
                        name: 'report_data'
                    }
                ]
            },
            buttons: [
                {
                    text: 'Submit',
                    listeners: {
                        'click': function (button) {
                            var window = this.up('window'),
                                form = window.query('form')[0].getForm();

                            if (form.isValid()) {
                                form.submit({
                                    timeout: 300000,
                                    waitMsg: 'Creating report...',
                                    success: function (form, action) {
                                        var obj = Ext.decode(action.response.responseText);
                                        if (obj.success) {
                                            me.getStore().load();
                                        }
                                        window.close();
                                    },
                                    failure: function (form, action) {
                                        Ext.Msg.alert("Error", "Error creating report");
                                    }
                                });
                            }
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

    },

    editReportMetaData: function (node) {
        var me = this;
        Ext.create("Ext.window.Window", {
            title: 'Edit Report Print Settings',
            plain: true,
            buttonAlign: 'center',
            items: Ext.create('Ext.FormPanel', {
                labelWidth: 110,
                frame: false,
                bodyStyle: 'padding:5px 5px 0',
                url: '/rails_db_admin/erp_app/desktop/reports/update',
                defaults: {
                    width: 225
                },
                items: [
                    {
                        xtype: 'combo',
                        fieldLabel: 'Page Size',
                        name: 'page_size',
                        displayField: 'pageSize',
                        valueField: 'size',
                        store: {
                            fields: ['pageSize', 'size'],
                            data: [
                                {pageSize: 'A4', size: 'A4'},
                                {pageSize: 'A3', size: 'A3'},
                                {pageSize: 'A2', size: 'A2'},
                                {pageSize: 'A1', size: 'A1'},
                                {pageSize: 'A0', size: 'A0'}
                            ]
                        },
                        listeners: {
                            afterrender: function (combo, eOpts) {
                                var store = combo.getStore(),
                                    pageSize = node.data.reportMetaData.print_page_size || 'A4';

                                combo.setValue(pageSize);
                            }
                        }
                    },
                    {
                        xtype: 'textfield',
                        fieldLabel: 'Top Margin',
                        name: 'margin_top',
                        value: node.data.reportMetaData.print_margin_top || '10'
                    },
                    {
                        xtype: 'textfield',
                        fieldLabel: 'Right Margin',
                        name: 'margin_right',
                        value: node.data.reportMetaData.print_margin_right || '10'

                    },
                    {
                        xtype: 'textfield',
                        fieldLabel: 'Bottom Margin',
                        name: 'margin_bottom',
                        value: node.data.reportMetaData.print_margin_bottom || '10'
                    },
                    {
                        xtype: 'textfield',
                        fieldLabel: 'Left Margin',
                        name: 'margin_left',
                        value: node.data.reportMetaData.print_margin_left || '10'
                    }
                ],
                buttons: [
                    {
                        text: 'Submit',
                        listeners: {
                            'click': function (button) {
                                var window = button.up('window');
                                var formPanel = window.down('form');
                                formPanel.getForm().submit({
                                    waitMsg: 'Updating Report...',
                                    params: {
                                        id: node.data.id
                                    },
                                    success: function (form, action) {
                                        var obj = Ext.decode(action.response.responseText);
                                        if (obj.success) {
                                            button.up('window').close();
                                            me.getStore().load();
                                        }
                                        else {
                                            Ext.Msg.alert("Error", obj.msg);
                                        }
                                    },
                                    failure: function (form, action) {
                                        var obj = Ext.decode(action.response.responseText);
                                        if (obj.msg) {
                                            Ext.Msg.alert("Error", obj.msg);
                                        }
                                        else {
                                            Ext.Msg.alert("Error", "Error updating report.");
                                        }
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

            })
        }).show();


    },

    deleteReport: function (id) {
        var me = this;

        Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this report?', function (btn) {
            if (btn === 'no') {
                return false;
            }
            else if (btn === 'yes') {
                var waitMsg = Ext.Msg.wait("Deleting report...", "Status");
                Ext.Ajax.request({
                    url: '/rails_db_admin/erp_app/desktop/reports/delete',
                    params: {
                        id: id
                    },
                    success: function (responseObject) {
                        waitMsg.close();
                        var obj = Ext.decode(responseObject.responseText);
                        if (obj.success) {
                            me.getStore().load();
                        }
                        else {
                            Ext.Msg.alert('Status', 'Error deleting report');
                        }
                    },
                    failure: function () {
                        waitMsg.close();
                        Ext.Msg.alert('Status', 'Error deleting report');
                    }
                });
            }
        });
    },

    editQuery: function (reportId) {
        var me = this;
        var waitMsg = Ext.Msg.wait("Loading query...", "Status");
        Ext.Ajax.request({
            url: '/rails_db_admin/erp_app/desktop/reports/edit',
            params: {
                id: reportId
            },
            success: function (responseObject) {
                waitMsg.close();
                var obj = Ext.decode(responseObject.responseText);
                if (obj.success) {
                    me.initialConfig.module.editQuery(obj.report);
                }
                else {
                    Ext.Msg.alert('Status', 'Error deleting report');
                }
            },
            failure: function () {
                waitMsg.close();
                Ext.Msg.alert('Status', 'Error deleting report');
            }
        });
    },


    exportReport: function (reportId) {
        var self = this;
        var waitMsg = Ext.Msg.wait("Exporting Report...", "Status");
        window.open('/rails_db_admin/erp_app/desktop/reports/export?id=' + reportId, '_blank');
        waitMsg.hide();
    },

    constructor: function (config) {
        var me = this;

        config = Ext.apply({
            autoLoadRoot: true,
            rootVisible: true,
            multiSelect: true,
            handleRootContextMenu: true,
            addViewContentsToContextMenu: true,
            title: 'Reports',
            rootText: 'Reports',
            autoScroll: true,
            allowDownload: true,
            url: '/rails_db_admin/erp_app/desktop/reports/index',
            controllerPath: '/rails_db_admin/erp_app/desktop/reports',
            standardUploadUrl: '/rails_db_admin/erp_app/desktop/reports/upload_file',
            fields: [
                'text',
                'iconCls',
                'leaf',
                'id',
                'reportIid',
                'reportId',
                'isReport',
                'handleContextMenu',
                'uniqueName',
                'reportName',
                {name: 'reportMetaData', type: 'object'}
            ],
            animate: false,
            listeners: {
                'showImage': function (fileManager, node, themeId) {
                    var reportId = null;
                    var reportNode = node;
                    while (reportId == null && !Compass.ErpApp.Utility.isBlank(reportNode.parentNode)) {
                        if (reportNode.data.isReport) {
                            reportId = reportNode.data.id;
                        }
                        else {
                            reportNode = reportNode.parentNode;
                        }
                    }
                    me.initialConfig.module.showImage(node, reportId);
                },
                'contentLoaded': function (fileManager, node, content) {
                    var itemId = Compass.ErpApp.Utility.Encryption.MD5(node.data.id);
                    var centerRegion = Ext.getCmp('rails_db_admin').down('#centerRegion');
                    var item = centerRegion.getComponent(itemId);
                    var mode = Compass.ErpApp.Shared.CodeMirror.determineCodeMirrorMode(node.data.text);

                    if (Compass.ErpApp.Utility.isBlank(item)) {
                        item = Ext.create('Compass.ErpApp.Shared.CodeMirror', {
                            mode: mode,
                            sourceCode: content,
                            title: node.data.text,
                            closable: true,
                            itemId: itemId,
                            listeners: {
                                'save': function (codeMirror, content) {
                                    var waitMsg = Ext.Msg.wait("Saving Report...", "Status");
                                    Ext.Ajax.request({
                                        url: '/rails_db_admin/erp_app/desktop/reports/update_file',
                                        method: 'POST',
                                        params: {
                                            node: node.data.id,
                                            content: content
                                        },
                                        success: function (responseObject) {
                                            waitMsg.close();
                                            var obj = Ext.decode(responseObject.responseText);
                                            if (!obj.success) {
                                                Ext.Msg.alert('Status', 'Error saving report');
                                            }
                                        },
                                        failure: function () {
                                            waitMsg.close();
                                            Ext.Msg.alert('Status', 'Error saving report');
                                        }
                                    });
                                }
                            }
                        })
                        centerRegion.add(item);
                    }
                    centerRegion.setActiveTab(item);
                },
                'itemclick': function (view, record, item, index, e) {
                    e.stopEvent();
                    if (record.data.leaf && record.data.text == 'Query') {
                        me.editQuery(record.data.reportId);
                    }
                    else if (record.data.leaf) {
                        var msg = Ext.Msg.wait("Loading", "Retrieving contents...");
                        Ext.Ajax.request({
                            url: '/rails_db_admin/erp_app/desktop/reports/get_contents',
                            method: 'POST',
                            params: {
                                node: record.data.id
                            },
                            success: function (response) {
                                msg.hide();
                                me.fireEvent('contentLoaded', me, record, response.responseText);
                            },
                            failure: function () {
                                Ext.Msg.alert('Status', 'Error loading contents');
                                msg.hide();
                            }
                        });
                    }
                },
                'handleContextMenu': function (fileManager, node, e) {
                    var items = [];
                    if (node.isRoot()) {
                        items.push(
                            {
                                text: "New Report",
                                iconCls: 'icon-settings',
                                listeners: {
                                    'click': function () {
                                        me.newReport();
                                    }
                                }
                            },
                            {
                                text: "Upload",
                                iconCls: 'icon-theme-upload',
                                listeners: {
                                    'click': function () {
                                        me.uploadReport();
                                    }
                                }
                            });
                    }
                    else if (node.data.isReport) {
                        items.push(
                            {
                                text: "Report Print Settings",
                                iconCls: 'icon-edit',
                                listeners: {
                                    scope: node,
                                    'click': function () {
                                        me.editReportMetaData(node);
                                    }
                                }

                            },
                            {
                                text: "Delete Report",
                                iconCls: 'icon-delete',
                                listeners: {
                                    scope: node,
                                    'click': function () {
                                        me.deleteReport(node.data.id);
                                    }
                                }
                            },
                            {
                                text: "Info",
                                iconCls: 'icon-info',
                                listeners: {
                                    scope: node,
                                    'click': function () {
                                        Ext.Msg.alert('Details', 'Title: ' + node.data.text +
                                            '<br /> Unique Name: ' + node.data.uniqueName
                                        );
                                    }
                                }
                            },
                            {
                                text: 'Export',
                                iconCls: 'icon-document_out',
                                listeners: {
                                    'click': function () {
                                        me.exportReport(node.data.id);
                                    }
                                }
                            }
                        );
                    }
                    var contextMenu = Ext.create('Ext.menu.Menu', {
                        items: items
                    });
                    contextMenu.showAt(e.xy);
                    return false;
                }
            }
        }, config);

        this.callParent([config]);
    }
});

