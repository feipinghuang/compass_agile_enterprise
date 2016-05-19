Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.Reports.SetDefaultWindow", {
	extend: 'Ext.window.Window',
	alias: 'widget.railsdbadminreportssetdefaultwindow',
	title: 'Set Default',
	modal: true,
	height: 300,
	width: 400,
	buttonAlign: 'center',

	paramsManager: null,
	param: null,

	buttons: [{
		text: 'Save',
		handler: function(btn) {
			var me = btn.up('window');

			var grid = me.paramsManager.down('grid');
			var form = me.down('form');

			if (form.isValid()) {
				var values = form.getValues();

				me.param.set('default_value', values.default_value);
				me.param.commit(false);

				me.paramsManager.save();

				me.hide();
			}
		}
	}, {
		text: 'Cancel',
		handler: function(btn) {
			var window = btn.up('window');

			window.hide();
		}
	}],

	initComponent: function() {
		var me = this;

		me.items = [{
			xtype: 'form',
			bodyPadding: 10,
			layout: 'form',
			items: []
		}];

		this.callParent(arguments);

		me.setType(me.param.get('type'));
	},

	setType: function(type) {
		var me = this;
		var form = me.down('form');

		switch (type) {
			case 'text':
				form.add(me.buildDefaultTextField());
				break;
			case 'date':
				form.add(me.buildDefaultDateField());
				break;
			case 'time':
				form.add(me.buildDefaultTimeField());
				break;
			case 'select':
				form.add(me.buildDefaultSelectField());
				break;
			case 'data_record':
				form.add(me.buildDefaultDataRecordField());
				break;
			case 'service':
				form.add(me.buildDefaultServiceUrlField());
				break;
		}
	},

	/**
	 * Builds default textfield.
	 */
	buildDefaultTextField: function() {
		var me = this;
		var defaultValue = null;

		if (me.param) {
			defaultValue = me.param.get('default_value');
		}

		return [{
			xtype: 'textfield',
			fieldLabel: 'Default Value',
			name: 'default_value',
			value: defaultValue
		}];
	},

	buildDefaultDateField: function() {
		var me = this;
		var defaultValue = 'current_date';
		var displayName = null;

		if (me.param) {
			defaultValue = me.param.get('default_value');
			options = me.param.get('options');
		}

		if (options.onlyWeeks == 'on') {
			displayName = 'Week';

		} else if (options.onlyMonths == 'on') {
			displayName = 'Month';

		} else {
			displayName = 'Day';
		}

		return [{
			xtype: 'combo',
			fieldLabel: 'Default Value',
			name: 'default_value',
			displayField: 'display',
			valueField: 'value',
			store: Ext.create('Ext.data.Store', {
				fields: ['display', 'value'],
				data: [{
					display: 'Current ' + displayName,
					value: 'current'
				}, {
					display: 'Previous ' + displayName,
					value: 'previous'
				}, {
					display: 'Next ' + displayName,
					value: 'next'
				}]
			}),
			queryMode: 'local',
			value: defaultValue
		}];
	},

	buildDefaultTimeField: function() {
		var me = this;
		var defaultValue = '';

		if (me.param) {
			defaultValue = me.param.get('default_value');
		}

		return [{
			xtype: 'timefield',
			fieldLabel: 'Default Value',
			name: 'default_value',
			value: defaultValue
		}];
	},

	buildDefaultSelectField: function() {
		var me = this;
		var defaultValue = null;
		var options = {
			values: []
		};

		if (me.param) {
			defaultValue = me.param.get('default_value');
			options = me.param.get('options');
		}

		return [{
			xtype: 'combo',
			fieldLabel: 'Default Value',
			queryMode: 'local',
			store: eval((options.values || '[]')),
			name: 'default_value',
			value: defaultValue
		}];
	},

	buildDefaultDataRecordField: function() {
		var me = this;
		var defaultValue = null;
		var options = {};

		if (me.param) {
			defaultValue = me.param.get('default_value');
			options = me.param.get('options');
		}

		return [{
			xtype: 'businessmoduledatarecordfield',
			fieldLabel: 'Default Value',
			extraParams: {
				business_module_iid: options.businessModule
			},
			name: 'default_value',
			value: defaultValue
		}];
	},

	buildDefaultServiceUrlField: function() {
		var me = this;
		var defaultValue = null;
		var options = {};

		if (me.param) {
			defaultValue = me.param.get('default_value');
			options = me.param.get('options');
		}

		// make sure we have all the options we need
		if (options.root && options.displayField && options.valueField) {
			return [{
				xtype: 'combo',
				fieldLabel: 'Default Value',
				name: 'default_value',
				value: defaultValue,
				displayField: options.displayField,
				valueField: options.valueField,
				queryMode: 'remote',
				store: {
					proxy: {
						type: 'ajax',
						url: options.url,
						reader: {
							type: 'json',
							root: options.root
						}
					},
					fields: [
						options.displayField,
						options.valueField
					],
					autoLoad: true
				}
			}];
		} else {
			return null;
		}
	}
});