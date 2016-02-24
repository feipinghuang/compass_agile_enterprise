Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReportsParamsManager", {
    extend: "Ext.panel.Panel",
    alias: 'widget.railsdbadminreportsparamsmanager',
    reportId: null,
    reportParams: null,
    title: 'Report Params',
    autoScroll: true,
    currentRecord: null,

    initComponent: function () {
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
                        handler: function (btn) {
                            var grid = btn.up('railsdbadminreportsparamsmanager').down('grid'),
                                store = grid.getStore();
                            me.reportParams = Ext.Array.map(store.data.items, function (item) {
                                return {
                                    display_name: item.get('display_name'),
                                    name: item.get('name'),
                                    type: item.get('type'),
                                    select_values: item.get('select_values'),
                                    app_id: item.get('app_id'),
                                    module_iid: item.get('module_iid'),
                                    default_value: item.get('default_value')
                                };
                            });
                            var myMask = new Ext.LoadMask(me, {msg: "Please wait..."});
                            myMask.show();
                            // save report params
                            Ext.Ajax.request({
                                url: '/rails_db_admin/erp_app/desktop/reports/update',
                                method: 'POST',
                                params: {
                                    id: me.reportId
                                },
                                jsonData: {
                                    report_params: me.reportParams
                                },
                                success: function (response) {
                                    var responseObj = Ext.decode(response.responseText);
                                    if (responseObj.success) {
                                        myMask.hide();
                                        var centerRegion = btn.up('window').down('#centerRegion'),
                                            queryPanel = centerRegion.getActiveTab();

                                        if (queryPanel) {
                                            queryPanel.down('reportparamspanel').destroy();
                                            queryPanel.insert(
                                                0,
                                                {
                                                    xtype: 'reportparamspanel',
                                                    region: 'north',
                                                    params: me.reportParams,
                                                    slice: 2
                                                }
                                            );
                                        }
                                    }
                                    else {
                                        myMask.hide();
                                        Ext.msg.alert('Error', 'Error saving report params');
                                    }
                                },
                                failure: function () {
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
            data: [
                {type: 'text'},
                {type: 'date'},
                {type: 'select'},
                {type: 'data record'}
            ]
        });
        me.callParent();
    },

    setReportData: function (report) {
        var me = this;
        me.clearReport();
        me.reportId = report.get('id');
        me.reportParams = report.get('reportMetaData').params || {};
        me.add(
            me.buildReportData(),
            {
                xtype: 'button',
                text: 'Add Param',
                itemId: 'addParamBtn',
                margin: '10 0 10 0',
                handler: function (btn) {
                    me.removeSpecialFields(me);
                    me.add(me.buildAddReportParam());
                    btn.hide();
                }
            }
        );
        me.updateLayout();
    },
    buildReportData: function () {
        var me = this;
        return Ext.create('Ext.grid.Panel', {
            columns: [
                {
                    header: 'Display Name',
                    flex: 1,
                    dataIndex: 'display_name',
                    editor: {
                        xtype: 'textfield',
                        allowBlank: false
                    }
                },
                {
                    header: 'Name',
                    flex: 1,
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
                    flex: 1,
                    dataIndex: 'type',
                    editor: {
                        xtype: 'combobox',
                        store: me.reportTypeStore,
                        queryMode: 'local',
                        displayField: 'type',
                        valueField: 'type',
                        listeners: {
                            select: function (combo, records, eOpts) {
                                me.removeSpecialFields(me);
                                var type = records[0].get('type');
                                switch (type) {
                                    case 'select':
                                        if (me.currentRecord.select_values == null) {
                                            me.currentRecord.select_values = ["All"];
                                        }
                                        me.buildMultiSelectField(me, me.currentRecord.select_values);
                                        break;
                                    case 'data record':
                                        me.buildDataRecordField(me, me.currentRecord.app_id, me.currentRecord.module_iid);
                                        break;
                                }
                            }
                        }
                    }
                },
                {
                    xtype: 'actioncolumn',
                    width: 50,
                    items: [
                        {
                            icon: '/assets/icons/delete/delete_16x16.png',
                            tooltip: 'Delete',
                            handler: function (grid, rowIndex, colIndex) {
                                var record = grid.getStore().getAt(rowIndex);
                                grid.getStore().remove(record);
                            }
                        }
                    ]
                }
            ],
            listeners: {
                itemcontextmenu: function (view, record, item, index, e, eOpts) {
                    e.stopEvent();
                    var contextMenu = Ext.create('Ext.menu.Menu', {
                        items: [
                            {
                                text: 'Edit Default',
                                iconCls: 'icon-edit',
                                handler: function (e) {
                                    me.remove(me.down('#addReportParam'));
                                    me.remove(me.down('#buildDefaultField'));
                                    me.remove(me.down('applicationmanagementmultioptions'));
                                    me.remove(me.down('#applicationSelect'));
                                    me.remove(me.down('#module'));
                                    switch (record.data.type) {
                                        case 'text':
                                        case 'date':
                                            me.add(me.buildDefaultField(me, null, record, index));
                                            break;
                                        case 'select':
                                            me.add(me.buildDefaultComboField(me, null, record, index));
                                            break;
                                        case 'data record':
                                            me.add(me.buildDefaultDataRecordField(me, null, record, index));
                                            break;
                                    }
                                }
                            }
                        ]
                    });
                    contextMenu.showAt(e.xy);
                }
            },
            padding: '0 0 35 0',
            selType: 'rowmodel',
            plugins: [
                Ext.create('Ext.grid.plugin.RowEditing', {
                    clicksToEdit: 2,
                    listeners: {
                        edit: function (editor, context, eOpts) {
                            var type = context.record.data.type;
                            switch (type) {
                                case 'select':
                                    context.record.set('select_values', me.down('applicationmanagementmultioptions').getValue());
                                    context.record.set('app_id', null);
                                    context.record.set('module_iid', null);
                                    break;
                                case 'data record':
                                    context.record.set('app_id', me.down('#applicationSelect').getValue());
                                    context.record.set('module_iid', me.down('#module').getValue());
                                    context.record.set('select_values', null);
                                    break;
                                default:
                                    context.record.set('select_values', null);
                                    context.record.set('app_id', null);
                                    context.record.set('module_iid', null);
                                    break;
                            }
                            context.record.set('default_value', null);
                            me.removeSpecialFields(me);
                            context.record.commit();
                            me.down('#addParamBtn').show();
                            me.currentRecord = null;
                        },
                        beforeedit: function (editor, context, eOpts) {
                            me.down('#addParamBtn').hide();
                            me.removeSpecialFields(me);
                            var form = me.down('#addReportParam');
                            if (form) {
                                me.remove(form);
                            }
                            me.currentRecord = context.record.data;
                            if (context.record.data.type == "select") {
                                me.buildMultiSelectField(me, me.currentRecord.select_values)
                            }
                            else if (context.record.data.type == "data record") {
                                me.buildDataRecordField(me, me.currentRecord.app_id, me.currentRecord.module_iid)
                            }
                        },
                        canceledit: function (editor, context, eOpts) {
                            me.removeSpecialFields(me);
                            me.down('#addParamBtn').show();
                            me.currentRecord = null;
                        }
                    }
                })
            ],
            store: {
                fields: ['name', 'type', 'display_name', 'select_values', 'app_id', 'module_iid', 'default_value'],
                data: me.reportParams
            }
        });
    },
    clearReport: function () {
        var me = this;
        me.removeAll();
        me.reportId = null;
        me.reportParams = null;
    },
    buildAddReportParam: function (param) {
        var me = this;
        return {
            xtype: 'form',
            itemId: 'addReportParam',
            bodyPadding: 10,
            labelWidth: 50,
            items: [
                {
                    xtype: 'textfield',
                    fieldLabel: 'Display Name',
                    itemId: 'paramDisplayName',
                    name: 'report_params["display_name"]',
                    width: 250,
                    labelAlign: 'left',
                    labelWidth: 50,
                    allowBlank: false
                },
                {
                    xtype: 'textfield',
                    fieldLabel: 'Name',
                    itemId: 'paramName',
                    regex: /^(?!.*\s).*$/,
                    regexText: 'Spaces not allowed',
                    name: 'report_params["name"]',
                    width: 250,
                    labelAlign: 'left',
                    labelWidth: 50,
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
                    width: 250,
                    labelAlign: 'left',
                    labelWidth: 50,
                    displayField: 'type',
                    valueField: 'type',
                    listeners: {
                        select: function (combo, records, eOpts) {
                            var type = records[0].get('type'),
                                form = me.down('form');
                            me.removeSpecialFields(form);
                            switch (type) {
                                case 'select':
                                    me.buildMultiSelectField(form, ["All"]);
                                    break;
                                case 'data record':
                                    me.buildDataRecordField(form);
                                    break;
                            }
                        }
                    }
                }
            ],
            buttons: [
                {
                    text: 'Add',
                    formBind: true,
                    handler: function (btn) {
                        // add entry to grid
                        var panel = btn.up('railsdbadminreportsparamsmanager'),
                            grid = panel.down('grid'),
                            paramSelectBox = panel.down('applicationmanagementmultioptions'),
                            appSelect = panel.down('#applicationSelect'),
                            moduleType = panel.down('#module'),
                            type = panel.down('#paramType').getValue();

                        grid.getStore().add({
                            display_name: panel.down('#paramDisplayName').getValue(),
                            name: panel.down('#paramName').getValue(),
                            type: type,
                            select_values: (!paramSelectBox ? null : paramSelectBox.getValue()),
                            app_id: (!appSelect ? null : appSelect.getValue()),
                            module_iid: (!moduleType ? null : moduleType.getValue())
                        });

                        me.remove(btn.up('#addReportParam'));
                        switch (type) {
                            case 'date':
                            case 'text':
                                me.add(me.buildDefaultField(me, grid));
                                break;
                            case 'select':
                                me.add(me.buildDefaultComboField(me, grid));
                                break;
                            case 'data record':
                                me.add(me.buildDefaultDataRecordField(me, grid));
                                break;
                        }
                    }
                },
                {
                    text: 'Cancel',
                    handler: function (btn) {
                        me.remove(btn.up('#addReportParam'));
                        me.down('#addParamBtn').show();
                    }
                }
            ]
        };
    },

    /**
     * Builds applicationmanagementmultioptions (grid panel)
     * @container {Object} The container which has this grid panel (either form or panel)
     * @values {Array} Initial value to populate the grid
     */
    buildMultiSelectField: function (container, values) {
        container.add({
            xtype: 'applicationmanagementmultioptions',
            field: {
                xtype: 'combo',
                internalIdentifier: 'select',
                store: Ext.create('Ext.data.Store', {
                    fields: ['display'],
                    data: Ext.Array.map(eval(values), function (item) {
                        return {
                            display: item
                        };
                    })
                }),
                queryMode: 'local'
            }
        });
    },

    /**
     * Builds two select fields Select Application and Select Module
     * @container {Object} The container which has these fields (either form or panel)
     * @app_id {Integer} sets the value for Select Application field
     * @module_iid (String) sets the value for Select Module field
     */
    buildDataRecordField: function (container, app_id, module_iid) {
        var me = this;
        container.add(
            {
                xtype: 'combo',
                fieldLabel: 'App',
                itemId: 'applicationSelect',
                emptyText: 'Select Application',
                flex: 1,
                allowBlank: false,
                name: 'app_type',
                store: {
                    autoLoad: true,
                    proxy: {
                        type: 'ajax',
                        method: 'GET',
                        url: '/erp_app/desktop/application_management/applications',
                        reader: {
                            type: 'json',
                            root: 'applications'
                        }
                    },
                    fields: [
                        'description',
                        'id'
                    ],
                    listeners: {
                        load: function () {
                            if (app_id) {
                                var appSelect = container.down('#applicationSelect');
                                appSelect.setValue(app_id);
                            }
                        }
                    }
                },
                forceSelection: true,
                labelAlign: 'left',
                labelWidth: 50,
                width: 250,
                typeAhead: true,
                queryMode: 'remote',
                displayField: 'description',
                valueField: 'id',
                listeners: {
                    select: function (combo, records, eOpts) {
                        me.down('#module').enable();
                        me.down('#module').store.load({params: {application_id: records[0].get('id')}})
                    },
                    change: function (combo, newValue, oldValue, eOpts) {
                        me.down('#module').enable();
                        me.down('#module').store.load({params: {application_id: newValue}})
                    }
                }
            },
            {
                xtype: 'combo',
                itemId: 'module',
                disabled: true,
                forceSelection: true,
                emptyText: 'Select Module',
                store: {
                    autoLoad: false,
                    proxy: {
                        url: '/erp_app/desktop/application_management/business_modules/existing_application_modules',
                        type: 'ajax',
                        reader: {
                            type: 'json',
                            root: 'business_modules'
                        }
                    },
                    fields: [
                        {name: 'description'},
                        {name: 'internalIdentifier', mapping: 'internal_identifier'}
                    ],
                    listeners: {
                        load: function () {
                            if (module_iid) {
                                var moduleType = container.down('#module');
                                moduleType.setValue(module_iid);
                            }
                        }
                    }
                },
                displayField: 'description',
                valueField: 'internalIdentifier',
                labelAlign: 'left',
                labelWidth: 50,
                width: 250,
                fieldLabel: 'Module',
                allowBlank: false,
                triggerAction: 'all',
                queryMode: 'local',
                name: 'businessModule'
            }
        );
    },
    removeSpecialFields: function (container) {
        var selectField = container.down('applicationmanagementmultioptions'),
            appSelect = container.down('#applicationSelect'),
            moduleType = container.down('#module'),
            defaultField = container.down('#buildDefaultField');
        if (appSelect) {
            container.remove(appSelect);
            container.remove(moduleType);
        }
        if (selectField) {
            container.remove(selectField);
        }
        if (defaultField) {
            container.remove(defaultField);
        }
    },

    /**
     * Builds either textfield or datefield to set the default value of a param.
     * @container {Object} The container which has this field (either form or panel)
     * @grid {Object} The report params grid panel
     * @record (Object) The current record being editted
     * @index (Integer) The index of current record in the grid's store
     */
    buildDefaultField: function (container, grid, record, index) {
        container.down('#addParamBtn').hide();
        var data = (!grid) ? record.data : grid.getStore().data.items.last().data;
        if (data.type == 'date') {
            var value = (!data.default_value) ? null : new Date(data.default_value)
        }
        else {
            var value = (!data.default_value) ? null : data.default_value
        }
        return {
            xtype: 'form',
            itemId: 'buildDefaultField',
            bodyPadding: 10,
            items: [
                {
                    xtype: data.type + 'field',
                    fieldLabel: 'Default value (' + data.display_name + ')',
                    itemId: 'defaultField',
                    width: 260,
                    labelAlign: 'left',
                    labelWidth: 110,
                    value: value
                }
            ],
            buttons: [
                {
                    text: 'Add',
                    handler: function (btn) {
                        var default_value = btn.up('#buildDefaultField').down('#defaultField').getValue();
                        if (grid) {
                            grid.getStore().data.items.last().set('default_value', default_value);
                        }
                        else {
                            container.down('grid').getStore().getAt(index).set('default_value', default_value);
                        }
                        container.remove(btn.up('#buildDefaultField'));
                        container.down('#addParamBtn').show();
                    }
                },
                {
                    text: 'Cancel',
                    handler: function (btn) {
                        container.remove(btn.up('#buildDefaultField'));
                        container.down('#addParamBtn').show();
                    }
                }
            ]
        }
    },

    /**
     * Builds select field to set the default value of param of type select.
     * @container {Object} The container which has this field (either form or panel)
     * @grid {Object} The report params grid panel
     * @record (Object) The current record being editted
     * @index (Integer) The index of current record in the grid's store
     */
    buildDefaultComboField: function (container, grid, record, index) {
        container.down('#addParamBtn').hide();
        var data = (!grid) ? record.data : grid.getStore().data.items.last().data,
            value = (!data.default_value) ? null : data.default_value;
        return {
            xtype: 'form',
            itemId: 'buildDefaultField',
            bodyPadding: 10,
            items: [
                {
                    xtype: 'combo',
                    fieldLabel: 'Default value (' + data.display_name + ')',
                    itemId: 'defaultField',
                    width: 260,
                    queryMode: 'local',
                    labelAlign: 'left',
                    labelWidth: 116,
                    store: eval(data.select_values),
                    value: value
                }
            ],
            buttons: [
                {
                    text: 'Add',
                    handler: function (btn) {
                        var default_value = btn.up('#buildDefaultField').down('#defaultField').getValue();
                        if (grid) {
                            grid.getStore().data.items.last().set('default_value', default_value);
                        }
                        else {
                            container.down('grid').getStore().getAt(index).set('default_value', default_value);
                        }
                        container.remove(btn.up('#buildDefaultField'));
                        container.down('#addParamBtn').show();
                    }
                },
                {
                    text: 'Cancel',
                    handler: function (btn) {
                        container.remove(btn.up('#buildDefaultField'));
                        container.down('#addParamBtn').show();
                    }
                }
            ]
        }
    },

    /**
     * Builds a data record field to set the default value of param of type data record
     * @container {Object} The container which has this field (either form or panel)
     * @grid {Object} The report params grid panel
     * @record (Object) The current record being editted
     * @index (Integer) The index of current record in the grid's store
     */
    buildDefaultDataRecordField: function (container, grid, record, index) {
        container.down('#addParamBtn').hide();
        var data = (!grid) ? record.data : grid.getStore().data.items.last().data,
            value = (!data.default_value) ? null : data.default_value;
        return {
            xtype: 'form',
            itemId: 'buildDefaultField',
            bodyPadding: 10,
            items: [
                {
                    xtype: 'businessmoduledatarecordfield',
                    fieldLabel: 'Default value (' + data.display_name + ')',
                    itemId: 'defaultField',
                    width: 260,
                    labelAlign: 'left',
                    labelWidth: 110,
                    extraParams: data.module_iid,
                    value: value
                }
            ],
            buttons: [
                {
                    text: 'Add',
                    handler: function (btn) {
                        var default_value = btn.up('#buildDefaultField').down('#defaultField').getValue();
                        if (grid) {
                            grid.getStore().data.items.last().set('default_value', default_value);
                        }
                        else {
                            container.down('grid').getStore().getAt(index).set('default_value', default_value);
                        }
                        container.remove(btn.up('#buildDefaultField'));
                        container.down('#addParamBtn').show();
                    }
                },
                {
                    text: 'Cancel',
                    handler: function (btn) {
                        container.remove(btn.up('#buildDefaultField'));
                        container.down('#addParamBtn').show();
                    }
                }
            ]
        }
    }
});
