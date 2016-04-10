Ext.define("Compass.ErpApp.Desktop.Applications.ApplicationManagement.MultiOptions", {
    alias: 'widget.applicationmanagementmultioptions',
    extend: 'Ext.grid.Panel',

    mixins: {
        field: 'Ext.form.field.Field'
    },

    fieldLabel: false,

    name: 'options',

    multiSelect: false,

    /**
     * @cfg {Object} field
     * Field Object
     */
    field: null,

    fieldSelectOptions: null,

    title: 'Options',

    columns: [{
        header: 'Name',
        dataIndex: 'name',
        flex: 1,
        sortable: false,
        menuDisabled: true,
        editor: {
            xtype: 'textfield',
            allowBlank: false
        }
    }, {
        xtype: 'actioncolumn',
        width: 30,
        sortable: false,
        menuDisabled: true,
        items: [{
            icon: '/assets/icons/delete/delete_16x16.png',
            tooltip: 'Remove Option',
            scope: this,
            handler: function(grid, rowIndex) {
                grid.getStore().removeAt(rowIndex);
            }
        }]
    }],

    dockedItems: [{
        xtype: 'toolbar',
        items: [{
            text: 'Add',
            iconCls: 'icon-add',
            handler: function(btn) {
                var grid = btn.up('grid');
                grid.getStore().insert(0, {
                    name: ''
                });
                grid.getPlugin().startEditByPosition({
                    row: 0,
                    column: 0
                });
            }
        }]
    }],

    plugins: {
        ptype: 'cellediting',
        clicksToEdit: 1,
        listeners: {
            edit: function(editor, context) {
                context.record.commit();
            }
        }
    },

    viewConfig: {
        plugins: {
            ptype: 'gridviewdragdrop',
            dragGroup: 'optionsGrid',
            dropGroup: 'optionsGrid'
        }
    },

    initComponent: function() {
        var me = this;

        me.store = Ext.create('Ext.data.ArrayStore', {
            fields: ['name'],
            data: {
                options: me.getOptions()
            },
            proxy: {
                type: 'memory',
                reader: {
                    type: 'json',
                    root: 'options'
                }
            }
        });

        me.callParent(arguments);
    },

    getOptions: function() {
        var me = this;
        var options = [];

        switch (me.field.internalIdentifier) {
            case 'radio':
            case 'check':
                Ext.each(me.field.items.items, function(item, index) {
                    options.push({
                        name: item.boxLabel
                    });
                });
                break;
            case 'select':
                Ext.each(me.field.store.data.items, function(item, index) {
                    options.push({
                        name: item.data.display
                    });
                });
                break;
            case 'question':
                Ext.each(me.field.answers, function(answer, index) {
                    options.push({
                        name: answer
                    });
                });
                break;
        }

        return options;
    },

    getValue: function() {
        return Ext.encode(this.getStore().collect('name'));
    },

    getSubmitData: function() {
        var me = this,
            data = null;
        if (!me.disabled && me.submitValue) {
            data = {};
            data[me.getName()] = me.getValue();
        }
        return data;
    }
});