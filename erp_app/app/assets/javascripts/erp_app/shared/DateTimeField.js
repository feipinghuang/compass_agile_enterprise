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
            change: function(field, newValue, oldValue) {
                var fieldContainer = field.up('datetimefield');

                var _oldValue = fieldContainer.timeField.getValue();
                var _newValue = Ext.clone(_oldValue);

                if (_oldValue) {
                    _oldValue.setMonth(oldValue.getMonth());
                    _oldValue.setFullYear(oldValue.getFullYear());
                    _oldValue.setDate(oldValue.getDate());
                }

                if (_newValue) {
                    _newValue.setMonth(newValue.getMonth());
                    _newValue.setFullYear(newValue.getFullYear());
                    _newValue.setDate(newValue.getDate());
                }

                if (fieldContainer.fireEvent('change', fieldContainer, _newValue, _oldValue) === false) {
                    field.setValue(oldValue);
                }
            }
        }
    }, {
        xtype: 'timefield',
        increment: 30,
        flex: 1,
        itemId: 'time',
        listConfig: {
            initDate: Ext.Date.format(Ext.Date.add(new Date(), Ext.Date.MONTH, -1), "Y,n,j").split(",")
        },
        listeners: {
            change: function(field, newValue, oldValue) {
                var fieldContainer = field.up('datetimefield');

                var _oldValue = oldValue;
                var _newValue = newValue;

                var date = fieldContainer.dateField.getValue();

                if (_oldValue) {
                    _oldValue.setMonth(date.getMonth());
                    _oldValue.setFullYear(date.getFullYear());
                    _oldValue.setDate(date.getDate());
                }

                if (_newValue) {
                    _newValue.setMonth(date.getMonth());
                    _newValue.setFullYear(date.getFullYear());
                    _newValue.setDate(date.getDate());
                }

                if (fieldContainer.fireEvent('change', fieldContainer, _newValue, _oldValue) === false) {
                    field.setValue(oldValue);
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

        if (me.dateField.getValue() && me.timeField.getValue()) {
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