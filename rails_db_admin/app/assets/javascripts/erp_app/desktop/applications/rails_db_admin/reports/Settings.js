Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.Reports.Settings", {
	extend: "Ext.form.Panel",
	alias: 'widget.railsdbadminreportssettings',
	title: 'Report Settings',
	report: null,
	reportId: null,
	labelWidth: 110,
	frame: false,
	bodyStyle: 'padding:5px 5px 0',
	url: '/rails_db_admin/erp_app/desktop/reports/update',
	tbar: [{
		xtype: 'button',
		text: 'Save',
		iconCls: 'icon-save',
		handler: function(btn) {
			var me = btn.up('railsdbadminreportssettings');

			if (me.isValid()) {
				me.getForm().submit({
					waitMsg: 'Updating Report...',
					params: {
						id: me.reportId
					},
					success: function(form, action) {
						if (action.result.success) {
							var values = form.getValues();

							me.report.set('internalIdentifier', values['report_iid']);
							me.report.set('text', values['report_name']);
							me.report.set('reportName', values['report_name']);
							me.report.set('reportMetaData', values);
							me.report.commit(false);

							if (!values.can_print) {
								me.down('#printSettings').disable();
							} else {
								me.down('#printSettings').enable();
							}

						} else {
							Ext.Msg.error("Error", obj.message);
						}
					},
					failure: function(form, action) {
						if (action.result.message) {
							Ext.Msg.error("Error", action.result.message);
						} else {
							Ext.Msg.error("Error", "Error updating report.");
						}
					}
				});
			}
		}
	}],

	items: [{
		xtype: 'textfield',
		fieldLabel: 'Report Name',
		name: 'report_name',
		allowBlank: false
	}, {
		xtype: 'textfield',
		fieldLabel: 'Unique Name',
		name: 'report_iid',
		allowBlank: false
	}, {
		xtype: 'checkbox',
		fieldLabel: 'Auto Execute',
		name: 'auto_execute'
	}, {
		xtype: 'checkbox',
		fieldLabel: 'Can Download CSV',
		name: 'can_download_csv'
	}, {
		xtype: 'checkbox',
		fieldLabel: 'Can Email',
		name: 'can_email'
	}, {
		xtype: 'checkbox',
		fieldLabel: 'Can Print',
		name: 'can_print',
		listeners: {
			change: function(field, newValue, oldValue) {
				var printSettings = field.up('form').down('#printSettings');

				if (newValue) {
					printSettings.enable();
				} else {
					printSettings.disable();
				}
			}
		}
	}, {
		xtype: 'fieldset',
		title: 'Print Settings',
		itemId: 'printSettings',
		defaults: {
			width: 245
		},
		items: [{
			xtype: 'combo',
			fieldLabel: 'Orientation',
			name: 'print_orientation',
			queryMode: 'local',
			forceSelection: true,
			selectOnFocus: true,
			displayField: 'orientation',
			valueField: 'orientation',
			store: new Ext.data.ArrayStore({
				fields: ['orientation'],
				data: [
					['Portrait'],
					['Landscape']
				]
			})
		}, {
			xtype: 'combo',
			fieldLabel: 'Page Size',
			name: 'print_page_size',
			displayField: 'pageSize',
			valueField: 'size',
			store: {
				fields: ['pageSize', 'size'],
				data: [{
					pageSize: 'Letter',
					size: 'Letter'
				}, {
					pageSize: 'A4',
					size: 'A4'
				}, {
					pageSize: 'A3',
					size: 'A3'
				}, {
					pageSize: 'A2',
					size: 'A2'
				}, {
					pageSize: 'A1',
					size: 'A1'
				}, {
					pageSize: 'A0',
					size: 'A0'
				}]
			}
		}, {
			xtype: 'textfield',
			fieldLabel: 'Top Margin',
			name: 'print_margin_top'
		}, {
			xtype: 'textfield',
			fieldLabel: 'Right Margin',
			name: 'print_margin_right'

		}, {
			xtype: 'textfield',
			fieldLabel: 'Bottom Margin',
			name: 'print_margin_bottom'
		}, {
			xtype: 'textfield',
			fieldLabel: 'Left Margin',
			name: 'print_margin_left'
		}]
	}],

	setReportSettings: function(report) {
		var me = this,
			reportMetaData = Ext.clone(report.get('reportMetaData'));

		me.report = report;
		me.reportId = report.get('reportId');

		reportMetaData = Ext.applyIf(reportMetaData, {
			report_name: report.get('reportName'),
			report_iid: report.get('internalIdentifier'),
			can_download_csv: false,
			can_email: false,
			can_print: false,
			print_page_size: 'A4',
			print_margin_top: 10,
			print_margin_right: 10,
			print_margin_bottom: 10,
			print_margin_left: 10,
			print_orientation: 'Portrait',
			auto_execute: false
		});

		if (!reportMetaData.can_print) {
			me.down('#printSettings').disable();
		} else {
			me.down('#printSettings').enable();
		}

		me.getForm().setValues(reportMetaData);
	}
});