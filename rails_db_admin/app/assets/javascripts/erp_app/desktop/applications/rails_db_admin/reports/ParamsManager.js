Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.Reports.ParamsManager", {
    extend: "Ext.panel.Panel",
    alias: 'widget.railsdbadminreportsparamsmanager',
    report: null,
    title: 'Report Params',
    autoScroll: true,
    currentRecord: null,

    initComponent: function() {
        var me = this;
        me.dockedItems = [{
            xtype: 'toolbar',
            dock: 'top',
            items: [{
                xtype: 'button',
                text: 'Add',
                iconCls: 'icon-add',
                handler: function() {
                    Ext.widget('railsdbadminreportsparamwindow', {
                        paramsManager: me,
                        isAdd: true
                    }).show();
                }
            }]
        }];

        me.callParent();
    },

    setReportData: function(report) {
        var me = this;

        me.clearReport();

        me.report = report;

        me.add(me.buildReportData());
    },

    buildReportData: function() {
        var me = this;
        return Ext.create('Ext.grid.Panel', {
            viewConfig: {
                plugins: {
                    ptype: 'gridviewdragdrop',
                    dragGroup: 'optionsGrid',
                    dropGroup: 'optionsGrid'
                },
                listeners: {
                    drop: function() {
                        me.save();
                    }
                }
            },
            columns: [{
                header: 'Display Name',
                flex: 1,
                dataIndex: 'display_name'
            }, {
                header: 'Name',
                flex: 1,
                dataIndex: 'name'
            }, {
                xtype: 'actioncolumn',
                width: 75,
                items: [{
                    icon: '/assets/icons/edit/edit_16x16.png',
                    tooltip: 'Edit',
                    handler: function(grid, rowIndex, colIndex) {
                        var record = grid.getStore().getAt(rowIndex);
                        Ext.widget('railsdbadminreportsparamwindow', {
                            paramsManager: me,
                            report: record
                        }).show();
                    }
                }, {
                    icon: '/assets/icons/edit/edit_16x16.png',
                    tooltip: 'Set Default',
                    handler: function(grid, rowIndex, colIndex) {
                        var record = grid.getStore().getAt(rowIndex);
                        Ext.widget('railsdbadminreportssetdefaultwindow', {
                            paramsManager: me,
                            report: record
                        }).show();
                    }
                }, {
                    icon: '/assets/icons/delete/delete_16x16.png',
                    tooltip: 'Delete',
                    handler: function(grid, rowIndex, colIndex) {
                        var record = grid.getStore().getAt(rowIndex);
                        grid.getStore().remove(record);

                        me.save();
                    }
                }]
            }],
            padding: '0 0 35 0',
            selType: 'rowmodel',
            store: {
                fields: ['name', 'type', 'display_name', 'options', 'default_value', 'required'],
                data: me.report.get('reportMetaData').params
            }
        });
    },

    clearReport: function() {
        var me = this;
        me.removeAll();
        me.report = null;
    },

    save: function() {
        var me = this,
            grid = me.down('grid'),
            store = grid.getStore();

        var reportParams = Ext.Array.map(store.data.items, function(item) {
            return {
                display_name: item.get('display_name'),
                name: item.get('name'),
                type: item.get('type'),
                options: item.get('options'),
                required: item.get('required'),
                default_value: item.get('default_value')
            };
        });

        var metaData = me.report.get('reportMetaData');
        metaData.params = reportParams;
        me.report.set('reportMetaData', metaData);
        me.report.commit(false);

        var myMask = new Ext.LoadMask(me, {
            msg: "Please wait..."
        });
        myMask.show();

        // save report params
        Ext.Ajax.request({
            url: '/rails_db_admin/erp_app/desktop/reports/update',
            method: 'POST',
            params: {
                id: me.report.get('reportId')
            },
            jsonData: {
                report_params: reportParams
            },
            success: function(response) {
                var responseObj = Ext.decode(response.responseText);
                if (responseObj.success) {
                    myMask.hide();
                    var centerRegion = me.up('window').down('#centerRegion'),
                        queryPanel = centerRegion.down('#' + me.report.get('internalIdentifier') + '-query');

                    if (queryPanel) {
                        queryPanel.down('reportparamspanel').destroy();
                        queryPanel.insert(
                            0, {
                                xtype: 'reportparamspanel',
                                region: 'north',
                                params: reportParams,
                                slice: 3
                            }
                        );
                    }
                } else {
                    myMask.hide();
                    Ext.msg.alert('Error', 'Error saving report params');
                }
            },
            failure: function() {
                myMask.hide();
                Ext.msg.alert('Error', 'Error saving report params');
            }
        });
    }
});
