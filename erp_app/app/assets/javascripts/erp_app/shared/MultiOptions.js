Ext.define("Compass.ErpApp.Shared.MultiOptions", {
    alias: 'widget.sharedmultioptions',
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
                options: me.getOptions(me.field)
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

    setOptions: function(field) {
        var me = this;

        me.getStore().loadData(me.getOptions(field));
    },

    getOptions: function(field) {
        var me = this;
        var options = [];

        if (field) {
            switch (field.internalIdentifier) {
                case 'radio':
                case 'check':
                    if (field.items) {
                        Ext.each(field.items.items, function(item, index) {
                            options.push({
                                name: item.boxLabel
                            });
                        });
                    }
                    break;
                case 'select':
                    if (field.getStore) {
                        Ext.each(field.getStore().data.items, function(item, index) {
                            options.push({
                                name: item.data.display
                            });
                        });
                    } else if (field.store) {
                        Ext.each(field.store.data, function(item, index) {
                            options.push({
                                name: item['display']
                            });
                        });
                    }
                    break;
                case 'question':
                    if (field.answers) {
                        Ext.each(field.answers, function(answer, index) {
                            options.push({
                                name: answer
                            });
                        });
                    }
                    break;
            }
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
    },

    validate: function() {
        var valid = true;

        if (!this.allowBlank) {
            if (this.getStore().count() === 0) {
                valid = false;
                if (this.getView().getEl())
                    this.getView().getEl().setStyle('border', 'solid 1px red');
            } else {
                if (this.getView().getEl())
                    this.getView().getEl().setStyle('border', '');
            }
        }

        return valid;
    }
});