Ext.define("Compass.ErpApp.Shared.DynamicEditableGrid", {
    extend: "Ext.grid.Panel",
    alias: 'widget.shared_dynamiceditablegrid',
    initComponent: function () {
        var config = this.initialConfig;
        //set a default proxy if none provided
        if (config.proxy === undefined ||
            config.proxy === null) {
            config.proxy = {
                type: 'rest',
                url: config.url,
                reader: {
                    type: 'json',
                    successProperty: 'success',
                    root: 'data',
                    messageProperty: 'message'
                },
                timeout: (config.timeout || 30000),
                writer: {
                    type: 'json',
                    writeAllFields: true,
                    root: 'data'
                },
                listeners: {
                    exception: function (proxy, response, operation) {
                        Ext.MessageBox.show({
                            title: 'REMOTE EXCEPTION',
                            msg: operation.getError(),
                            icon: Ext.MessageBox.ERROR,
                            buttons: Ext.Msg.OK
                        });
                    }
                }
            };
        }
        var store = Ext.create('Ext.data.Store', {
            model: ((config.editable) ? config.model : undefined),
            listeners: config.store_listeners,
            fields: config['fields'],
            remoteSort: config['remoteSort'],
            autoSync: true,
            pageSize: config['pageSize'],
            proxy: config.proxy,
            storeId: config['storeId'],
            autoLoad: false
        });

        this.store = store;

        if (config.page === true) {
            this.bbar = new Ext.PagingToolbar({
                store: store,
                displayInfo: true,
                displayMsg: config.displayMsg,
                emptyMsg: config.emptyMsg
            });
        }

        this.callParent(arguments);
    },

    constructor: function (config) {
        var me = this,
            plugins = [];

        if (config['editable']) {
            var tbar = {};
            this.editing = Ext.create('Ext.grid.plugin.RowEditing', {
                clicksToMoveEditor: 1
            });

            var Model = Ext.define(config.model, {
                extend: 'Ext.data.Model',
                fields: config.fields,
                validations: config.validations,
                idProperty: ((config.id_property !== undefined) ? config.id_property : "id")
            });
            plugins.push(this.editing);

            config = Ext.apply({
                plugins: plugins
            }, config);

            if (config.showEditorToolbar) {
                tbar = {
                    items: [
                        {
                            text: 'Add',
                            iconCls: 'icon-add',
                            handler: function (button) {
                                var grid = button.findParentByType('shared_dynamiceditablegrid');
                                var edit = grid.editing;
                                grid.store.insert(0, new Model());
                                edit.startEdit(0, 0);
                            }
                        },
                        '-',
                        {
                            text: 'Delete',
                            iconCls: 'icon-delete',
                            handler: function (button) {
                                var grid = button.findParentByType('shared_dynamiceditablegrid');
                                var selection = grid.getView().getSelectionModel().getSelection()[0];
                                if (selection) {
                                    grid.store.remove(selection);
                                }
                            }
                        }
                    ]
                };

                if (config.searchable){
                    var searchable_toolbar = [
                        '-',
                        'Search',
                        {
                            xtype: 'textfield',
                            emptyText: 'Find',
                            width: 200,
                            listeners: {
                                specialkey: function (field, e) {
                                    if (e.getKey() == e.ENTER) {
                                        var button = field.up('toolbar').down('#searchbtn');
                                        button.fireEvent('click', button);
                                    }
                                }
                            }
                        },
                        {
                            xtype: 'button',
                            itemId: 'searchbtn',
                            icon: '/assets/erp_app/organizer/applications/crm/toolbar_find.png',
                            listeners: {
                                click: function (button, e, eOpts) {
                                    var value = this.up().down('textfield').getValue();
                                    me.store.load({
                                        params: {
                                            query_filter: value
                                        }
                                    });
                                }
                            }
                        }
                    ]

                }
                else{
                    var searchable_toolbar = [];
                }

                tbar.items = tbar.items.concat(searchable_toolbar);
                config = Ext.apply({
                    tbar: tbar
                }, config);

            }
        }

        if (config['cell_editable']) {
            this.cell_editing = Ext.create('Ext.grid.plugin.CellEditing', {
                clicksToEdit: 2
            });

            plugins.push(this.cell_editing);

            config = Ext.apply({
                plugins: plugins,
                selType: 'cellmodel'
            }, config);
        }

        config = Ext.apply({
            layout: 'fit',
            frame: false,
            autoScroll: true,
            loadMask: true
        }, config);

        this.callParent([config]);
    }
});