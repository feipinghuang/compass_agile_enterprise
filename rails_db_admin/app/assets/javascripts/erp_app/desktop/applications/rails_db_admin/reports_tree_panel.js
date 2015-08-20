Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReportsTreePanel", {
    extend:"Compass.ErpApp.Shared.FileManagerTree",
    alias:'widget.railsdbadmin_reportstreepanel',

    newReport:function () {
        var me = this;

        Ext.create("Ext.window.Window", {
            title:'New Report',
            plain:true,
            buttonAlign:'center',
            items:Ext.create('Ext.FormPanel', {
                labelWidth:110,
                frame:false,
                bodyStyle:'padding:5px 5px 0',
                url:'/rails_db_admin/erp_app/desktop/reports/create',
                defaults:{
                    width:225
                },
                items:[
                    {
                        xtype:'textfield',
                        fieldLabel:'Title',
                        allowBlank:false,
                        name:'name'
                    },
                    {
                        xtype:'textfield',
                        fieldLabel:'Unique Name',
                        allowBlank:false,
                        name:'internal_identifier'
                    }
                ]
            }),
            buttons:[
                {
                    text:'Submit',
                    listeners:{
                        'click':function (button) {
                            var window = button.up('window');
                            var formPanel = window.down('form');
                            formPanel.getForm().submit({
                                waitMsg:'Creating Report...',
                                success:function (form, action) {
                                    var obj = Ext.decode(action.response.responseText);
                                    if (obj.success) {
                                        button.up('window').close();
                                        me.getStore().load();
                                    }
                                    else {
                                        Ext.Msg.alert("Error", obj.msg);
                                    }
                                },
                                failure:function (form, action) {
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
                    text:'Close',
                    handler:function (btn) {
                        btn.up('window').close();
                    }
                }
            ]
        }).show();
    },

    deleteReport:function (id) {
        var me = this;

        Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this report?', function (btn) {
            if (btn === 'no') {
                return false;
            }
            else if (btn === 'yes') {
                Ext.Ajax.request({
                    url:'/rails_db_admin/erp_app/desktop/reports/delete',
                    params:{
                        id:id
                    },
                    success:function (responseObject) {
                        var obj = Ext.decode(responseObject.responseText);
                        if (obj.success) {
                            me.getStore().load();
                        }
                        else {
                            Ext.Msg.alert('Status', 'Error deleting report');
                        }
                    },
                    failure:function () {
                        Ext.Msg.alert('Status', 'Error deleting report');
                    }
                });
            }
        });
    },

    editQuery:function (reportId) {
        var me = this;

        var waitMsg = Ext.Msg.wait("Loading query...", "Status");
        Ext.Ajax.request({
            url:'/rails_db_admin/erp_app/desktop/reports/edit',
            params:{
                id:reportId
            },
            success:function (responseObject) {
                waitMsg.close();
                var obj = Ext.decode(responseObject.responseText);
                if (obj.success) {
                    me.initialConfig.module.editQuery(obj.report);
                }
                else {
                    Ext.Msg.alert('Status', 'Error deleting report');
                }
            },
            failure:function () {
                waitMsg.close();
                Ext.Msg.alert('Status', 'Error deleting report');
            }
        });
    },

    constructor:function (config) {
        var me = this;

        config = Ext.apply({
            autoLoadRoot: true,
            rootVisible: true,
            multiSelect: true,
            handleRootContextMenu: true,
            addViewContentsToContextMenu: true,
            title:'Reports',
            rootText: 'Reports',
            autoScroll:true,
            url:'/rails_db_admin/erp_app/desktop/reports/index',
            controllerPath: '/rails_db_admin/erp_app/desktop/reports',
            standardUploadUrl: '/rails_db_admin/erp_app/desktop/reports/upload_file',
            fields:[
                'text',
                'iconCls',
                'leaf',
                'id',
                'reportIid',
                'reportId',
                'isReport',
                'handleContextMenu'
            ],
            animate:false,
            listeners:{
                'contentLoaded': function (fileManager, node, content) {
                    var centerRegion = Ext.getCmp('rails_db_admin').down('#centerRegion')
                    var nodeName = node.data.text;
                    var path = node.data.id
                    centerRegion.add({
                        xtype: 'codemirror',
                        parser: 'rb',
                        sourceCode: content,
                        title: nodeName,
                        closable: true,
                        itemId: nodeName,
                        listeners: {
                                    'save': function (codeMirror, content) {
                                        var waitMsg = Ext.Msg.wait("Saving Report...", "Status");
                                        Ext.Ajax.request({
                                            url: '/rails_db_admin/erp_app/desktop/reports/update_file',
                                            method: 'POST',
                                            params: {
                                                node: path,
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
                    centerRegion.setActiveTab(nodeName);
                },
                'itemclick':function (view, record, item, index, e) {
                    e.stopEvent();
                    if (record.data.leaf && record.data.text == 'Query') {
                        me.editQuery(record.data.reportId);
                    }
                    else if(record.data.leaf && record.data.text == 'Preview Report'){
                        var module = compassDesktop.getModule('rails_db_admin-win');
                        var reportTitle = 'Report' + ' - ' + record.data.reportIid;
                        module.openIframeInTab(reportTitle , '/reports/display/' + record.data.reportIid);
                    }
                    else if(record.data.leaf){
                        var msg = Ext.Msg.wait("Loading", "Retrieving contents...");
                            Ext.Ajax.request({
                                url: '/rails_db_admin/erp_app/desktop/reports/get_contents',
                                method: 'POST',
                                params: {
                                    node: record.data.id
                                },
                                success: function (response) {
                                    msg.hide();
                                    me.fireEvent('contentLoaded',me, record, response.responseText);
                                },
                                failure: function () {
                                    Ext.Msg.alert('Status', 'Error loading contents');
                                    msg.hide();
                                }
                            });
                    }
                },
                'handleContextMenu':function (fileManager, node, e) {
                    var items = [];
                    if (node.isRoot()) {
                        items.push({
                            text: "New Report",
                            iconCls: 'icon-settings',
                            listeners:{
                                'click':function () {
                                    me.newReport();
                                }
                            }
                        });
                    }
                    else if(node.data.isReport){
                        items.push(
                            {
                                text:"Delete Report",
                                iconCls:'icon-delete',
                                listeners:{
                                    scope:node,
                                    'click':function () {
                                        me.deleteReport(node.data.id);
                                    }
                                }
                            },
                            {
                                text:"Info",
                                iconCls:'icon-info',
                                listeners:{
                                    scope:node,
                                    'click':function () {
                                        Ext.Msg.alert('Details', 'Title: '+node.data.text +
                                            '<br /> Unique Name: '+node.data.uniqueName
                                        );
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

