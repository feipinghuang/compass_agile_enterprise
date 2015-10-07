Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueryPanel", {
    extend: "Ext.panel.Panel",
    alias: 'widget.railsdbadmin_querypanel',

    getSql: function () {
        return this.down('codemirror').getValue();
    },

    initComponent: function () {
        var self = this;
        var messageBox = null;

        var savedQueriesJsonStore = Ext.create('Ext.data.Store', {
            proxy: {
                type: 'ajax',
                url: '/rails_db_admin/erp_app/desktop/queries/saved_queries',
                reader: {
                    type: 'json',
                    root: 'data'
                }
            },
            fields: [
                {
                    name: 'value'
                },
                {
                    name: 'display'
                }
            ]
        });

        var tbarItems = [
            {
                text: 'Execute',
                iconCls: 'icon-playpause',
                handler: function (button) {
                    var textarea = self.query('.codemirror')[0];
                    var sql = textarea.getValue();
                    var selected_sql = textarea.getSelection();
                    var cursor_pos = textarea.getCursor().line;
                    var database = self.module.getDatabase();

                    messageBox = Ext.Msg.wait('Status', 'Executing..');

                    Ext.Ajax.request({
                        url: '/rails_db_admin/erp_app/desktop/queries/execute_query',
                        params: {
                            sql: sql,
                            database: database,
                            cursor_pos: cursor_pos,
                            selected_sql: selected_sql
                        },
                        method: 'post',
                        success: function (responseObject) {
                            messageBox.hide();
                            var response = Ext.decode(responseObject.responseText);

                            if (response.success) {
                                var columns = response.columns;
                                var fields = response.fields;
                                var data = response.data;

                                if (!Ext.isEmpty(self.down('railsdbadmin_readonlytabledatagrid'))) {
                                    var jsonStore = new Ext.data.JsonStore({
                                        fields: fields,
                                        data: data
                                    });

                                    self.down('railsdbadmin_readonlytabledatagrid').reconfigure(jsonStore, columns);
                                }
                                else {
                                    var readOnlyDataGrid = Ext.create('Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReadOnlyTableDataGrid', {
                                        layout: 'fit',
                                        columns: columns,
                                        fields: fields,
                                        data: data
                                    });

                                    var cardPanel = self.down('#resultCardPanel');
                                    cardPanel.removeAll(true);
                                    cardPanel.add(readOnlyDataGrid);
                                    cardPanel.getLayout().setActiveItem(readOnlyDataGrid);
                                }
                            }
                            else {
                                Ext.Msg.alert("Error", response.exception);
                            }

                        },
                        failure: function () {
                            messageBox.hide();
                            Ext.Msg.alert('Status', 'Error loading grid');
                        }
                    });
                }
            },
            {
                text: 'Save Query',
                iconCls: 'icon-save',
                handler: function (btn) {
                    var textarea = self.query('.codemirror')[0];
                    var sql = textarea.getValue();

                    if(self.initialConfig.reportId){
                        var waitMsg = Ext.Msg.wait("Saving Report...", "Status");
                        Ext.Ajax.request({
                            url: '/rails_db_admin/erp_app/desktop/reports/save_query',
                            params: {
                                id: self.initialConfig.reportId,
                                query: sql
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
                    else{
                        var waitMsg = Ext.Msg.wait("Saving Query...", "Status");
                        Ext.Ajax.request({
                            url: '/rails_db_admin/erp_app/desktop/queries/save_query',
                            params: {
                                query: sql,
                                query_name: self.initialConfig.title
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
            }
        ];

        if (!this.initialConfig['hideSave']) {
            tbarItems.push({
                text: 'Save',
                iconCls: 'icon-save',
                handler: function () {
                    var textarea = self.down('.codemirror');
                    var save_window = new Ext.Window({
                        layout: 'fit',
                        width: 375,
                        title: 'Save Query',
                        height: 125,
                        buttonAlign: 'center',
                        closeAction: 'hide',
                        plain: true,
                        items: {
                            xtype: 'form',
                            frame: false,
                            bodyStyle: 'padding:5px 5px 0',
                            width: 500,
                            items: [
                                {
                                    xtype: 'combo',
                                    fieldLabel: 'Query Name',
                                    name: 'query_name',
                                    allowBlank: false,
                                    store: savedQueriesJsonStore,
                                    valueField: 'value',
                                    displayField: 'display',
                                    triggerAction: 'all',
                                    forceSelection: false,
                                    mode: 'remote'
                                },
                                {
                                    xtype: 'hidden',
                                    value: textarea.getValue(),
                                    name: 'query'
                                },
                                {
                                    xtype: 'hidden',
                                    value: self.module.getDatabase(),
                                    name: 'database'
                                }
                            ]
                        },
                        buttons: [
                            {
                                text: 'Save',
                                handler: function (btn) {
                                    var fp = this.up('window').down('.form');
                                    if (fp.getForm().isValid()) {
                                        fp.getForm().submit({
                                            url: '/rails_db_admin/erp_app/desktop/queries/save_query',
                                            waitMsg: 'Saving Query...',
                                            success: function (fp, o) {
                                                Ext.Msg.alert('Success', 'Saved Query');
                                                var database = self.module.getDatabase();
                                                self.module.queriesTreePanel().store.setProxy({
                                                    type: 'ajax',
                                                    url: '/rails_db_admin/erp_app/desktop/queries/saved_queries_tree',
                                                    extraParams: {
                                                        database: database
                                                    }
                                                });
                                                self.module.queriesTreePanel().store.load();
                                                btn.up('window').hide();
                                            }
                                        });
                                    }
                                }
                            },
                            {
                                text: 'Cancel',
                                handler: function (btn) {
                                    btn.up('window').hide();
                                }
                            }
                        ]

                    }).show();
                }
            });
        }

        var codeMirrorPanel = {
            region: 'center',
            xtype: 'codemirror',
            mode: 'sql',
            split: true,
            tbarItems: tbarItems,
            sourceCode: this.initialConfig['sqlQuery'],
            disableSave: true
        };

        this.items = [codeMirrorPanel];

        if (!Ext.isEmpty(this.initialConfig['southRegion'])) {
            this.items.push(this.initialConfig['southRegion']);
        }
        else {
            this.items.push({
                layout: 'card',
                region: 'south',
                margins: '0 0 0 0',
                autoScroll: true,
                split: true,
                collapsible: true,
                collapseDirection: 'bottom',
                height: '50%',
                itemId: 'resultCardPanel',
                items: []
            })
        }

        this.callParent(arguments);
    },

    constructor: function (config) {
        config = Ext.applyIf({
            layout: 'border',
            border: false,
            closable: true
        }, config);
        if (config.title == null){
            config = Ext.applyIf({
                title: 'New Query'
            }, config);
        }
        this.callParent([config]);
    }
});
