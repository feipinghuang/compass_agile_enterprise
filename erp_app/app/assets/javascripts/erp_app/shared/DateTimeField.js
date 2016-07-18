/**
 * @author Russell Holmes
 */

Ext.define('Ext.ux.form.DateTimeField', {
    extend: "Ext.form.FieldContainer",
    alias: 'widget.datetimefield',

    mixins: {
        field: 'Ext.form.field.Field'
    },
    layout: 'hbox',
    items: [{
        xtype: 'datefield',
        flex: 1,
        itemId: 'date',
        listeners: {
            change: function(comp, newValue, oldValue) {
                var me = comp.up('datetimefield');

                var value = me.timeField.getValue();

                if (newValue && value) {
                    if (oldValue) {
                        value.setMonth(oldValue.getMonth());
                        value.setFullYear(oldValue.getFullYear());
                        value.setDate(oldValue.getDate());

                        oldValue = value;
                    }

                    value = me.timeField.getValue();

                    value.setMonth(newValue.getMonth());
                    value.setFullYear(newValue.getFullYear());
                    value.setDate(newValue.getDate());

                    newValue = value;

                    me.fireEvent('change', me, newValue, oldValue);
                }
            }
        }
    }, {
        xtype: 'timefield',
        increment: 30,
        flex: 1,
        itemId: 'time',
        listeners: {
            change: function(comp, newValue, oldValue) {
                var me = comp.up('datetimefield');

                var dateValue = me.dateField.getValue();

                if (newValue && dateValue) {
                    if (oldValue) {
                        oldValue.setMonth(dateValue.getMonth());
                        oldValue.setFullYear(dateValue.getFullYear());
                        oldValue.setDate(dateValue.getDate());
                    }

                    newValue.setMonth(dateValue.getMonth());
                    newValue.setFullYear(dateValue.getFullYear());
                    newValue.setDate(dateValue.getDate());

                    me.fireEvent('change', me, newValue, oldValue);
                }
            }
        }
    }],

    format: 'c',

    initComponent: function() {
        var me = this;

        me.callParent(arguments);

        me.dateField = me.down('#date');
        me.timeField = me.down('#time');

        me.dateField.allowBlank = me.allowBlank;
        me.timeField.allowBlank = me.allowBlank;
    },

    getValue: function() {
        var me = this;
        var value = null;

        if (me.dateField.getValue()) {
            value = me.timeField.getValue();
            var dateValue = me.dateField.getValue();

            value.setMonth(dateValue.getMonth());
            value.setFullYear(dateValue.getFullYear());
            value.setDate(dateValue.getDate());
        }

        return value;
    },

    getSubmitData: function() {
        var me = this,
            data = null,
            format = this.submitFormat || this.format,
            value = this.getValue();

        value = value ? Ext.Date.format(value, format) : '';

        if (!me.disabled && me.submitValue) {
            data = {};
            data[me.getName()] = '' + value;
        }
        return data;
    },

    setValue: function(value) {
        var me = this;

        if (value) {
            me.dateField.setValue(value);
            me.timeField.setValue(Ext.Date.format(value, 'g:i A'));
        }
    }
});