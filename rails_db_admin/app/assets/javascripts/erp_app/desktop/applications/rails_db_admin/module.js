Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin", {
    extend: "Ext.ux.desktop.Module",
    id: 'rails_db_admin-win',

    getWindow: function () {
        return this.app.getDesktop().getWindow('rails_db_admin');
    },

    queriesTreePanel: function () {
        return this.accordion.down('.railsdbadmin_queriestreemenu');
    },

    setWindowStatus: function (status) {
        this.getWindow().setStatus(status);
    },

    clearWindowStatus: function () {
        this.getWindow().clearStatus();
    },

    getTableData: function (table) {
        var self = this,
            id = 'ext-' + table + '-data';

        var grid = self.container.down('#' + id);

        if (Ext.isEmpty(grid)) {
            grid = Ext.create('Compass.ErpApp.Shared.DynamicEditableGridLoaderPanel', {
                id: id,
                title: table,
                setupUrl: '/rails_db_admin/erp_app/desktop/base/setup_table_grid/' + table,
                dataUrl: '/rails_db_admin/erp_app/desktop/base/table_data/' + table,
                editable: true,
                searchable: true,
                page: true,
                pageSize: 25,
                displayMsg: 'Displaying {0} - {1} of {2}',
                emptyMsg: 'Empty',
                loadErrorMessage: 'Tables Without Ids Can Not Be Edited',
                closable: true,
                params: {
                    database: self.getDatabase()
                },
                grid_listeners: {
                    validateedit: {
                        fn: function (editor, e) {
                            this.store.proxy.setOldModel(e.record);
                        }
                    }
                },
                proxy: {
                    type: 'rest',
                    url: '/rails_db_admin/erp_app/desktop/base/table_data/' + table,
                    //private var to store the previous model in an
                    //update operation
                    oldModel: null,
                    setOldModel: function (old_model) {
                        this.oldModel = old_model.copy();
                    },
                    update: function (operation, callback, scope) {
                        operation.records.push(this.oldModel);
                        Ext.data.proxy.Rest.superclass.update.call(this, operation, callback, scope);
                    },
                    reader: {
                        type: 'json',
                        successProperty: 'success',
                        root: 'data',
                        messageProperty: 'message'
                    },
                    writer: {
                        type: 'json',
                        writeAllFields: true,
                        root: 'data'
                    },
                    listeners: {
                        exception: function (proxy, response, operation) {
                            var msg;
                            if (operation.getError() === undefined) {
                                var responseObject = Ext.JSON.decode(response.responseText);
                                msg = responseObject.exception;
                            } else {
                                msg = operation.getError();
                            }
                            Ext.MessageBox.show({
                                title: 'REMOTE EXCEPTION',
                                msg: msg,
                                icon: Ext.MessageBox.ERROR,
                                buttons: Ext.Msg.OK
                            });
                        }
                    }
                }
            });

            self.container.add(grid);
        }

        self.container.setActiveTab(grid);
    },

    selectTopFifty: function (table) {
        this.setWindowStatus('Selecting Top 50 from ' + table + '...');
        var self = this;

        Ext.Ajax.request({
            url: '/rails_db_admin/erp_app/desktop/queries/select_top_fifty/' + table,
            timeout: 60000,
            params: {
                database: self.getDatabase()
            },
            success: function (responseObject) {
                self.clearWindowStatus();
                var response = Ext.decode(responseObject.responseText);
                var sql = response.sql;
                var columns = response.columns;
                var fields = response.fields;
                var data = response.data;

                var readOnlyDataGrid = Ext.create('Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReadOnlyTableDataGrid', {
                    region: 'south',
                    split: true,
                    columns: columns,
                    fields: fields,
                    data: data,
                    collapseDirection: 'bottom',
                    height: '50%',
                    collapsible: true
                });

                var queryPanel = Ext.create('Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueryPanel', {
                    module: self,
                    closable: true,
                    sqlQuery: sql,
                    southRegion: readOnlyDataGrid
                });

                self.container.add(queryPanel);
                self.container.setActiveTab(queryPanel.id);

                //queryPanel.gridContainer.add(readOnlyDataGrid);
                //queryPanel.gridContainer.getLayout().setActiveItem(0);
            },
            failure: function () {
                self.clearWindowStatus();
                Ext.Msg.alert('Status', 'Error loading grid');
            }
        });
    },

    addConsolePanel: function () {
        this.container.add({
            xtype: 'compass_ae_console_panel',
            module: this
        });
        this.container.setActiveTab(this.container.items.length - 1);

    },

    addNewQueryTab: function () {
        this.container.add({
            xtype: 'railsdbadmin_querypanel',
            module: this
        });
        this.container.setActiveTab(this.container.items.length - 1);
    },

    connectToDatabase: function () {
        var database = this.getDatabase();
        var tablestreePanelStore = this.accordion.down('.railsdbadmin_tablestreemenu').store;
        var queriesTreePanelStore = this.accordion.down('.railsdbadmin_queriestreemenu').store;

        tablestreePanelStore.setProxy({
            type: 'ajax',
            url: '/rails_db_admin/erp_app/desktop/base/tables',
            extraParams: {
                database: database
            }
        });
        tablestreePanelStore.load();

        queriesTreePanelStore.setProxy({
            type: 'ajax',
            url: '/rails_db_admin/erp_app/desktop/queries/saved_queries_tree',
            extraParams: {
                database: database
            }
        });
        queriesTreePanelStore.load();
    },

    getDatabase: function () {
        return Ext.getCmp('databaseCombo').getValue();
    },

    deleteQuery: function (queryName) {
        var self = this;
        Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this query?', function (btn) {
            if (btn === 'no') {
                return false;
            }
            else if (btn === 'yes') {
                self.setWindowStatus('Deleting ' + queryName + '...');
                var database = self.getDatabase();
                Ext.Ajax.request({
                    url: '/rails_db_admin/erp_app/desktop/queries/delete_query/',
                    params: {
                        database: database,
                        query_name: queryName
                    },
                    success: function (responseObject) {
                        self.clearWindowStatus();
                        var response = Ext.decode(responseObject.responseText);
                        if (response.success) {
                            Ext.Msg.alert('Error', 'Query deleted');
                            var queriesTreePanelStore = self.accordion.down('.railsdbadmin_queriestreemenu').store;
                            queriesTreePanelStore.setProxy({
                                type: 'ajax',
                                url: '/rails_db_admin/erp_app/desktop/queries/saved_queries_tree',
                                extraParams: {
                                    database: database
                                }
                            });
                            queriesTreePanelStore.load();
                        }
                        else {
                            Ext.Msg.alert('Error', response.exception);
                        }

                    },
                    failure: function () {
                        self.clearWindowStatus();
                        Ext.Msg.alert('Status', 'Error deleting query');
                    }
                });
            }
        });
    },

    displayAndExecuteQuery: function (queryName) {
        this.setWindowStatus('Executing ' + queryName + '...');
        var self = this;
        var database = this.getDatabase();
        Ext.Ajax.request({
            url: '/rails_db_admin/erp_app/desktop/queries/open_and_execute_query/',
            params: {
                database: database,
                query_name: queryName
            },
            success: function (responseObject) {
                var response = Ext.decode(responseObject.responseText);
                var query = response.query;

                var queryPanel = null;

                if (response.success) {
                    self.clearWindowStatus();
                    var columns = response.columns;
                    var fields = response.fields;
                    var data = response.data;

                    var readOnlyDataGrid = Ext.create('Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReadOnlyTableDataGrid', {
                        region: 'south',
                        columns: columns,
                        fields: fields,
                        data: data,
                        collapseDirection: 'bottom',
                        height: '50%',
                        collapsible: true
                    });

                    queryPanel = Ext.create('Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueryPanel', {
                        module: self,
                        sqlQuery: query,
                        southRegion: readOnlyDataGrid,
                        closable: true
                    });

                    self.container.add(queryPanel);
                    self.container.setActiveTab(queryPanel.id);
                }
                else {
                    Ext.Msg.alert('Error', response.exception);
                    queryPanel = Ext.create('Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueryPanel', {
                        module: self,
                        closable: true,
                        sqlQuery: query
                    });

                    self.container.add(queryPanel);
                    self.container.setActiveTab(self.container.items.length - 1);
                }

            },
            failure: function () {
                self.clearWindowStatus();
                Ext.Msg.alert('Status', 'Error loading query');
            }
        });
    },

    //************ Reporting ************************************************

    editQuery: function (reportObj) {
        var me = this;

        me.container.add({
            xtype: 'railsdbadmin_querypanel',
            module: me,
            hideSave: true,
            title: 'Query' + ' - ' + reportObj.title,
            sqlQuery: reportObj.query,
            reportId: reportObj.id,
            template: reportObj.template,
            internalIdentifier: reportObj.internalIdentifier,
            closable: true
        });
        me.container.setActiveTab(me.container.items.length - 1);
    },

    //***********************************************************************

    init: function () {
        this.launcher = {
            text: 'Database Tools',
            iconCls: 'icon-rails_db_admin',
            handler: this.createWindow,
            scope: this

        };
    },

    displayQuery: function (queryName) {
        this.setWindowStatus('Retrieving ' + queryName + '...');
        var self = this;
        var database = this.getDatabase();
        Ext.Ajax.request({
            url: '/rails_db_admin/erp_app/desktop/queries/open_query/',
            params: {
                database: database,
                query_name: queryName
            },
            success: function (responseObject) {
                var response = Ext.decode(responseObject.responseText);
                var query = response.query;

                var queryPanel = null;

                if (response.success) {
                    self.clearWindowStatus();

                    queryPanel = Ext.create('Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueryPanel', {
                        module: self,
                        closable: true,
                        sqlQuery: query
                    });

                    self.container.add(queryPanel);
                    self.container.setActiveTab(self.container.items.length - 1);
                }
                else {
                    Ext.Msg.alert('Error', response.exception);
                    queryPanel = Ext.create('Compass.ErpApp.Desktop.Applications.RailsDbAdmin.QueryPanel', {
                        module: self,
                        closable: true,
                        sqlQuery: query
                    });

                    self.container.add(queryPanel);
                    self.container.setActiveTab(self.container.items.length - 1);
                }

            },
            failure: function () {
                self.clearWindowStatus();
                Ext.Msg.alert('Status', 'Error loading query');
            }
        });
    },

    openIframeInTab: function (title, url) {
        var self = this;

        var item = Ext.create('Ext.panel.Panel', {
            iframeId: 'tutorials_iframe',
            closable: true,
            layout: 'fit',
            title: title,
            html: '<iframe id="themes_iframe" height="100%" width="100%" frameBorder="0" src="' + url + '"></iframe>'
        });

        self.container.add(item);
        self.container.setActiveTab(item);
    },

    createWindow: function () {
        var self = this;
        var desktop = this.app.getDesktop();
        var win = desktop.getWindow('rails_db_admin');
        if (!win) {
            this.container = Ext.create('Ext.tab.Panel', {
                itemId: 'centerRegion',
                region: 'center',
                margins: '0 0 0 0',
                border: false,
                minsize: 300
            });

            this.accordion = Ext.create('Ext.panel.Panel', {
                dockedItems: [
                    {
                        xtype: 'toolbar',
                        dock: 'top',
                        items: [
                            {
                                text: 'Database:'
                            },
                            {
                                xtype: 'railsdbadmin_databasecombo',
                                module: self
                            }
                        ]
                    }
                ],
                ui: 'rounded-panel',
                region: 'west',
                margins: '0 0 0 0',
                cmargins: '0 0 0 0',
                width: 300,
                collapsible: true,
                header: false,
                split: true,
                layout: 'accordion',
                items: [
                    {
                        xtype: 'railsdbadmin_tablestreemenu',
                        module: this
                    },
                    {
                        xtype: 'railsdbadmin_queriestreemenu',
                        module: this
                    },
                    {
                        xtype: 'railsdbadmin_reportstreepanel',
                        module: this
                    }
                ]
            });

            win = desktop.createWindow({
                id: 'rails_db_admin',
                title: 'RailsDBAdmin',
                width: 1200,
                height: 550,
                maximized: true,
                iconCls: 'icon-rails_db_admin-light',
                shim: false,
                animCollapse: false,
                constrainHeader: true,
                layout: 'border',
                items: [this.accordion, this.container]
            });

            win.addListener('render', function (win) {
                win.down('#centerRegion').add({
                    xtype: 'railsdbadmin_splash_screen',
                    module: self,
                    closable: true
                });

                win.down('#centerRegion').setActiveTab(win.down('#centerRegion').items.length - 1);
            });
        }
        win.show();
    }
});

Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.BooleanEditor", {
    extend: "Ext.form.ComboBox",
    alias: 'widget.booleancolumneditor',
    initComponent: function () {
        this.store = Ext.create('Ext.data.ArrayStore', {
            fields: ['display', 'value'],
            data: [
                ['False', false],
                ['True', true]
            ]
        });

        this.callParent(arguments);
    },
    constructor: function (config) {
        config = Ext.apply({
            valueField: 'value',
            displayField: 'display',
            triggerAction: 'all',
            forceSelection: true,
            mode: 'local'
        }, config);

        this.callParent([config]);
    }
});

Compass.ErpApp.Desktop.Applications.RailsDbAdmin.renderBooleanColumn = function (v) {
    return (v == 1) ? "True" : "False";
};
