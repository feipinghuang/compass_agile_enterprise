Ext.define("Compass.ErpApp.Shared.DynamicEditableGridLoaderPanel", {
    extend: "Ext.Panel",
    alias: 'widget.shared_dynamiceditablegridloaderpanel',
    setupGrid: function () {
        var self = this;
        var config = this.initialConfig;
        Ext.Ajax.request({
            url: config['setupUrl'],
            method: 'POST',
            params: config['params'],
            success: function (responseObject) {
                var response = Ext.decode(responseObject.responseText);
                if (response.success) {
                    self.add({
                        editable: config['editable'],
                        url: config['dataUrl'],
                        page: config['page'],
                        cell_editable: config['cell_editable'],
                        searchable: config['searchable'],
                        remoteSort: config['remoteSort'],
                        pageSize: config['pageSize'],
                        displayMsg: config['displayMsg'],
                        emptyMsg: config['emptyMsg'],
                        xtype: 'shared_dynamiceditablegrid',
                        columns: response.columns,
                        fields: response.fields,
                        model: response.model,
                        id_property: response.id_property,
                        validations: response.validations,
                        proxy: config.proxy,
                        listeners: config.grid_listeners,
                        store_listeners: config.grid_store_listeners,
                        storeId: config['storeId'],
                        selType: (config.selType || 'rowmodel'),
                        multiSelect: (config.multiSelect || false),
                        allowDeselect: (config.allowDeselect || false),
                        timeout: (config.timeout || 30000),
                        showEditorToolbar: (config.showEditorToolbar === false ? false : true)
                    });
                    if (config.autoLoad !== false) self.down('shared_dynamiceditablegrid').getStore().load();
                }
                else {
                    var message = response.message;
                    if (Compass.ErpApp.Utility.isBlank(message)) {
                        message = config['loadErrorMessage'];
                    }
                    Ext.Msg.alert('Error', message);
                }
            },
            failure: function () {
                Ext.Msg.alert('Error', 'Could not load grid.');
            }
        });
    },

    onRender: function () {
        this.callParent(arguments);
        this.setupGrid();
    },

    constructor: function (config) {
        config = Ext.apply({layout: 'card'}, config);
        this.callParent([config]);
    }
});