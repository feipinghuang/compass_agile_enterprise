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
		itemId: 'date'
	}, {
		xtype: 'timefield',
		increment: 30,
		flex: 1,
		itemId: 'time'
	}],

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

	setValue: function(value) {
		var me = this;

		if (value) {
			me.dateField.setValue(value);
			me.timeField.setValue(Ext.Date.format(value, 'g:i A'));
		}
	}
});