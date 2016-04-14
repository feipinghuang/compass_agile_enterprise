Ext.define("Compass.ErpApp.Shared.ReportsParams", {
    extend: "Ext.form.Panel",
    alias: 'widget.reportparamspanel',
    params: [],
    bodyPadding: '0 0 0 10',
    layout: {
        type: 'vbox'
    },
    items: [],
    slice: 3,

    initComponent: function() {
        var me = this;
        me.items = [];

        me.params.eachSlice(me.slice, function(slice) {
            var container = {
                xtype: 'container',
                layout: 'hbox',
                style: {
                    marginBottom: '5px'
                },
                defaults: {
                    labelWidth: 80,
                    style: {
                        marginRight: '20px'
                    }
                },
                items: []
            };

            Ext.each(slice, function(param) {
                var defaultValue = param.default_value;

                switch (param.type) {
                    case 'text':
                        container.items.push({
                            xtype: 'textfield',
                            fieldLabel: param.display_name,
                            allowBlank: (param.required !== true),
                            style: {
                                marginRight: '20px'
                            },
                            name: param.name,
                            value: param.default_value
                        });
                        break;
                    case 'date':
                        var today = new Date();
                        var defaultDate = null;

                        if (param.options.onlyWeeks == 'on') {
                            defaultDate = new Date(today.getFullYear(), today.getMonth(), (today.getDate() - today.getDay() + 1));

                            if (defaultValue == 'previous') {
                                defaultDate = Ext.Date.subtract(defaultDate, Ext.Date.DAY, 7);
                            } else if (defaultValue == 'next') {
                                defaultDate = Ext.Date.add(defaultDate, Ext.Date.DAY, 7);
                            }

                            container.items.push({
                                xtype: 'datefield',
                                allowBlank: (param.required !== true),
                                labelWidth: 80,
                                style: {
                                    marginRight: '20px'
                                },
                                format: 'm/d/Y',
                                fieldLabel: param.display_name,
                                name: param.name,
                                disabledDays: [0, 2, 3, 4, 5, 6],
                                value: defaultDate
                            });

                        } else if (param.options.onlyMonths == 'on') {
                            defaultDate = new Date(today.getFullYear(), today.getMonth(), 1);

                            if (defaultValue == 'previous') {
                                defaultDate = Ext.Date.subtract(defaultDate, Ext.Date.MONTH, 1);
                            } else if (defaultValue == 'next') {
                                defaultDate = Ext.Date.add(defaultDate, Ext.Date.MONTH, 1);
                            }

                            container.items.push({
                                xtype: 'monthfield',
                                allowBlank: (param.required !== true),
                                labelWidth: 80,
                                style: {
                                    marginRight: '20px'
                                },
                                format: 'm/d/Y',
                                fieldLabel: param.display_name,
                                name: param.name,
                                value: defaultDate
                            });

                        } else {
                            defaultDate = new Date();

                            if (defaultValue == 'previous') {
                                defaultDate = Ext.Date.subtract(defaultDate, Ext.Date.DAY, 1);
                            } else if (defaultValue == 'next') {
                                defaultDate = Ext.Date.add(defaultDate, Ext.Date.DAY, 1);
                            }

                            container.items.push({
                                xtype: 'datefield',
                                allowBlank: (param.required !== true),
                                labelWidth: 80,
                                style: {
                                    marginRight: '20px'
                                },
                                format: 'm/d/Y',
                                fieldLabel: param.display_name,
                                name: param.name,
                                value: defaultDate
                            });
                        }

                        break;
                    case 'select':
                        var values = (!param.options.values) ? [] : eval(param.options.values);
                        var storeData = [];
                        for (var i = 0; i < values.length; i++) {
                            storeData.push([values[i]]);
                        }

                        var arrayStore = Ext.create('Ext.data.ArrayStore', {
                            fields: ['name'],
                            data: storeData
                        });

                        container.items.push({
                            xtype: 'combo',
                            allowBlank: (param.required !== true),
                            queryMode: 'local',
                            multiSelect: (param.options.multiSelect == 'on'),
                            displayField: 'name',
                            valueField: 'name',
                            fieldLabel: param.display_name,
                            name: param.name,
                            store: arrayStore,
                            value: defaultValue,
                            listeners: {
                                select: function(combo, records) {
                                    if (combo.value.length > 1 && Ext.Array.contains(combo.value, "All")) {
                                        combo.setValue('All');
                                    }
                                }
                            }
                        });
                        break;
                    case 'data_record':
                        // make sure we have all the options we need
                        if (param.options && param.options.businessModule) {
                            container.items.push({
                                xtype: 'businessmoduledatarecordfield',
                                itemId: param.name,
                                multiSelect: (param.options.multiSelect == 'on'),
                                allowBlank: (param.required !== true),
                                fieldLabel: param.display_name,
                                extraParams: {
                                    business_module_iid: param.options.businessModule
                                },
                                name: param.name,
                                value: defaultValue,
                                listeners: {
                                    afterrender: function(combo) {
                                        combo.store.load();
                                    },
                                    select: function(combo, records) {
                                        if (combo.value.length > 1 && Ext.Array.contains(combo.value, "All")) {
                                            combo.setValue('All');
                                        }
                                    }
                                }
                            });
                        }

                        break;
                    case 'service':
                        // make sure we have all the options we need
                        if (param.options.root && param.options.displayField && param.options.valueField) {
                            container.items.push({
                                xtype: 'combo',
                                fieldLabel: param.display_name,
                                name: param.name,
                                allowBlank: (param.required !== true),
                                value: defaultValue,
                                multiSelect: (param.options.multiSelect == 'on'),
                                displayField: param.options.displayField,
                                valueField: param.options.valueField,
                                queryMode: 'remote',
                                store: {
                                    proxy: {
                                        type: 'ajax',
                                        url: param.options.url,
                                        reader: {
                                            type: 'json',
                                            root: param.options.root
                                        }
                                    },
                                    fields: [
                                        param.options.displayField,
                                        param.options.valueField
                                    ],
                                    autoLoad: true
                                }
                            });
                        }

                        break;
                }
            });

            me.items.push(container);
        });

        me.callParent();
    },

    getReportParams: function() {
        var me = this,
            paramsObj = {};

        Ext.Array.each(me.query('field'), function(field) {
            // if field has no value set it to empty string to make the erb parser happy
            if (field.value) {
                switch (field.xtype) {
                    case 'textfield':
                        paramsObj[field.name] = Ext.String.trim(field.value);
                        break;
                    case 'combo':
                    case 'businessmoduledatarecordfield':
                        var fieldName = (field.xtype == 'combo' ? 'name' : 'id');
                        if (Ext.Array.contains(field.value, "All")) {
                            var allValues = Ext.Array.remove(field.store.collect(fieldName), "All");
                            paramsObj[field.name] = allValues.join(',');
                        } else {
                            if (field.value.constructor === Array) {
                                paramsObj[field.name] = (field.value.length === 0) ? 'null' : field.value.join(',');
                            } else {
                                paramsObj[field.name] = field.value;
                            }
                        }
                        break;
                    case 'datefield':
                    case 'monthfield':
                        var date = new Date(field.value);
                        date.setHours(23, 59, 59);
                        paramsObj[field.name] = date.toPgDateString();
                        break;
                }
            } else {
                paramsObj[field.name] = '';
            }
        });

        return paramsObj;
    },

    clearReportParams: function() {
        var me = this;
        Ext.each(me.query('field'), function(field) {
            field.setValue('');
        });
    }
});