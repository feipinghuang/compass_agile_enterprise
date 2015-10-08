Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReportsParamsManager", {
    extend: "Ext.panel.Panel",
    alias: 'widget.railsdbadminreportsparamsmanager',
    reportId: null,
    reportParams: null,
    title: 'Report Params',

    initComponent: function(){
        var me = this;
        me.dockedItems = [
            {
                xtype: 'toolbar',
                dock: 'top',
                items: [
                    {
                        xtype: 'button',
                        text: 'Save',
                        iconCls: 'icon-save',
                        handler: function(btn){
                            var grid = btn.up('railsdbadminreportsparamsmanager').down('grid'),
                                store = grid.getStore(),
                                reportParams = Ext.Array.map(store.data.items, function(item){
                                    return {
                                        name: item.get('name'),
                                        type: item.get('type')
                                    };
                                });
                            var myMask = new Ext.LoadMask(me, {msg: "Please wait..."});
                            myMask.show();
                            // save report params
                            Ext.Ajax.request({
                                url: '/rails_db_admin/erp_app/desktop/reports/update',
                                type: 'GET',
                                params: {
                                    id: me.reportId
                                },
                                jsonData: {
                                    report_params: reportParams
                                },
                                success: function(response){
                                    var responseObj = Ext.decode(response.responseText);
                                    if(responseObj.success){
                                        myMask.hide();
                                        var centerRegion = btn.up('window').down('#centerRegion'),
                                            queryPanel = centerRegion.getActiveTab();

                                        queryPanel.down('reportparamspanel').destroy();
                                        queryPanel.insert(
                                            0,
                                            {
                                            
                                                xtype: 'reportparamspanel',
                                                region: 'north',
                                                params: reportParams
                                            }
                                        );
                                        
                                        
                                    }else{
                                        myMask.hide();
                                        Ext.msg.alert('Error', 'Error saving report params');

                                    }
                                },
                                failure: function(){
                                    myMask.hide();
                                    Ext.msg.alert('Error', 'Error saving report params');
                                }
                                
                            });
                        }
                    }
                ]
            }
        ];

        me.reportTypeStore = Ext.create('Ext.data.Store', {
            fields: ['type'],
            data : [
                {type: 'text'},
                {type: 'date'},
            ]
        });        

        me.callParent();
    },

    //sets the report params panels data,
    setReportData: function(reportId, reportParams){
        var me = this;
        me.clearReport();
        me.reportId = reportId;
        me.reportParams = reportParams;
        var paramsGrid = me.buildReportData();
        me.add(paramsGrid);
        var addReportParamPanel = me.buildAddReportParam();
        me.add(addReportParamPanel);
        me.add(
            {
                xtype: 'button',
                text: 'Add Param',
                margin: '10 0 10 0',
                handler: function(btn){
                    var panel = btn.up('railsdbadminreportsparamsmanager'),
                        addParamPanel = panel.down('#addReportParam'),
                        grid = panel.down('grid');
                    addParamPanel.show();
                    
                }
            }
        );
        me.updateLayout();
    },

    buildReportData: function(){
        var me = this;        

        var paramsGrid = Ext.create('Ext.grid.Panel', {
            columns: [
                {
                    header: 'Name',
                    dataIndex: 'name',
                    editor: {
                        xtype: 'textfield',
                        allowBlank: false,
                        regex: /^(?!.*\s).*$/,
                        regexText: 'Spaces not allowed'
                    }
                },
                {
                    header: 'Type',
                    dataIndex: 'type',
                    editor: {
                        xtype: 'combobox',
                        store: me.reportTypeStore,
                        queryMode: 'local',
                        displayField: 'type',
                        valueField: 'type'
                    }
                },
                {
                    xtype: 'actioncolumn',
                    width: 50,
                    items: [
                        {
                            icon: '/assets/icons/delete/delete_16x16.png',
                            tooltip: 'Delete',
                            handler: function(grid, rowIndex, colIndex){
                                var record = grid.getStore().getAt(rowIndex);
                                grid.getStore().remove(record);
                                
                                
                            }
                        }
                    ]
                }
            ],
            selType: 'rowmodel',
            plugins: [
                Ext.create('Ext.grid.plugin.RowEditing', {
                    clicksToEdit: 1,
                    listeners: {
                        edit: function(editor, context, eOpts){
                            context.record.commit();
                        }
                    }
                })
            ],
            store: {
                fields: ['name', 'type'],
                data: me.reportParams
            }

        });

        return paramsGrid;
    },

    clearReport: function(){
        var me = this;
        me.removeAll();
        me.reportId = null;
        me.reportParams = null;
    },
    

    buildAddReportParam: function(param){
        var me = this;
        return {
            xtype: 'panel',
            itemId: 'addReportParam',
            bodyPadding: 10,
            hidden: true,
            labelWidth: 50,
            layout: {
                type: 'vbox'
            },
            items: [
                {
                    xtype: 'textfield',
                    fieldLabel: 'Name',
                    itemId: 'paramName',
                    regex: /^(?!.*\s).*$/,
                    regexText: 'Spaces not allowed',
                    name: 'report_params["name"]',
                    allowBlank: false
                },
                {
                    xtype: 'combobox',
                    fieldLabel: 'Type',
                    itemId: 'paramType',
                    name: 'report_params["type"]',
                    allowBlank: false,
                    store: me.reportTypeStore,
                    queryMode: 'local',
                    displayField: 'type',
                    valueField: 'type'
                }
            ],
            buttons: [
                {
                    text: 'Add',
                    formBind: true,
                    handler: function(btn){
                        // add entry to grid
                        var panel = btn.up('railsdbadminreportsparamsmanager'),
                            grid = panel.down('grid'),
                            paramNameField = panel.down('#paramName'),
                            paramTypeField = panel.down('#paramType');
                        grid.getStore().add({
                            name: paramNameField.getValue(),
                            type: paramTypeField.getValue()
                        });

                        paramNameField.setValue('');
                        paramTypeField.setValue('');
                        
                        btn.up('#addReportParam').hide();
                    }
                },
                {
                    text: 'Cancel',
                    handler: function(btn){
                        btn.up('#addReportParam').hide();
                    }
                }
            ]
        };
        
    }
});
