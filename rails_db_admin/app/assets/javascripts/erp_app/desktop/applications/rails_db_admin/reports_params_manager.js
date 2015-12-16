Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReportsParamsManager", {
	extend: "Ext.panel.Panel",
	alias: 'widget.railsdbadminreportsparamsmanager',
	reportId: null,
	reportParams: null,
	title: 'Report Params',
	autoScroll: true,
	currentRecord: null,

	initComponent: function () {
		var me = this;
		me.dockedItems = [
			{
				xtype: 'toolbar',
				dock: 'top',
				items: [
					{
						xtype: 'button',
						text: 'Save',
						iconCls: 'icon-save',
						handler: function (btn) {
							var grid = btn.up('railsdbadminreportsparamsmanager').down('grid'),
								store = grid.getStore(),
								reportParams = Ext.Array.map(store.data.items, function (item) {
									return {
										display_name: item.get('display_name'),
										name: item.get('name'),
										type: item.get('type'),
										select_values: item.get('select_values')
									};
								});
							var myMask = new Ext.LoadMask(me, {msg: "Please wait..."});
							myMask.show();
							// save report params
							Ext.Ajax.request({
								url: '/rails_db_admin/erp_app/desktop/reports/update',
								method: 'POST',
								params: {
									id: me.reportId
								},
								jsonData: {
									report_params: reportParams
								},
								success: function (response) {
									var responseObj = Ext.decode(response.responseText);
									if (responseObj.success) {
										myMask.hide();
										var centerRegion = btn.up('window').down('#centerRegion'),
											queryPanel = centerRegion.getActiveTab();

										queryPanel.down('reportparamspanel').destroy();
										queryPanel.insert(
											0,
											{

												xtype: 'reportparamspanel',
												region: 'north',
												params: reportParams
											}
										);


									} else {
										myMask.hide();
										Ext.msg.alert('Error', 'Error saving report params');

									}
								},
								failure: function () {
									myMask.hide();
									Ext.msg.alert('Error', 'Error saving report params');
								}

							});
						}
					}
				]
			}
		];

		me.reportTypeStore = Ext.create('Ext.data.Store', {
			fields: ['type'],
			data: [
				{type: 'text'},
				{type: 'date'},
				{type: 'select'}
			]
		});

		me.callParent();
	},

	//sets the report params panels data,
	setReportData: function (reportId, reportParams) {
		var me = this;
		me.clearReport();
		me.reportId = reportId;
		me.reportParams = reportParams;
		var paramsGrid = me.buildReportData();
		me.add(paramsGrid);
		var addReportParamPanel = me.buildAddReportParam();
		me.add(
			{
				xtype: 'button',
				text: 'Add Param',
				itemId: 'addParamBtn',
				margin: '10 0 10 0',
				handler: function (btn) {
					me.add(addReportParamPanel);
					btn.hide();
				}
			}
		);
		me.updateLayout();
	},

	buildReportData: function () {
		var me = this;

		return Ext.create('Ext.grid.Panel', {
			columns: [
				{
					header: 'Display Name',
					flex: 1,
					dataIndex: 'display_name',
					editor: {
						xtype: 'textfield',
						allowBlank: false
					}
				},
				{
					header: 'Name',
					flex: 1,
					dataIndex: 'name',
					editor: {
						xtype: 'textfield',
						allowBlank: false,
						regex: /^(?!.*\s).*$/,
						regexText: 'Spaces not allowed'
					}
				},
				{
					header: 'Type',
					width: 50,
					dataIndex: 'type',
					editor: {
						xtype: 'combobox',
						store: me.reportTypeStore,
						queryMode: 'local',
						displayField: 'type',
						valueField: 'type',
						listeners: {
							select: function(combo, records, eOpts) {
								if (records[0].get('type') == 'select') {
									if (me.currentRecord.select_values == "") {
										me.currentRecord.select_values = ["All"];
									}
									me.buildMultiSelectField(me, me.currentRecord.select_values)
								}
								else {
									var selectField = me.down('applicationmanagementmultioptions');
									if (selectField){
										me.remove(selectField);
									}
								}
							}
						}
					}
				},
				{
					xtype: 'actioncolumn',
					width: 50,
					items: [
						{
							icon: '/assets/icons/delete/delete_16x16.png',
							tooltip: 'Delete',
							handler: function (grid, rowIndex, colIndex) {
								var record = grid.getStore().getAt(rowIndex);
								grid.getStore().remove(record);
							}
						}
					]
				}
			],
			padding: '0 0 35 0',
			selType: 'rowmodel',
			plugins: [
				Ext.create('Ext.grid.plugin.RowEditing', {
					clicksToEdit: 1,
					listeners: {
						edit: function (editor, context, eOpts) {
							paramSelectBox = me.down('applicationmanagementmultioptions');
							if (context.record.data.type == 'select'){
								context.record.data.select_values = paramSelectBox.getValue();
								me.remove(paramSelectBox);
							}
							else {
								context.record.data.select_values = "" ;
							}
							context.record.commit();
							me.down('#addParamBtn').show();
							me.currentRecord = null;
						},
						beforeedit: function(editor, context, eOpts) {
							me.down('#addParamBtn').hide();
							me.currentRecord = context.record.data;
							if (context.record.data.type == "select") {
								me.buildMultiSelectField(me, context.record.data.select_values)
							}
						},
						canceledit: function(editor, context, eOpts) {
							paramSelectBox = me.down('applicationmanagementmultioptions');
							if (paramSelectBox) {
								me.remove(paramSelectBox);
							}
							me.down('#addParamBtn').show();
							me.currentRecord = null;
						}
					}
				})
			],
			store: {
				fields: ['name', 'type', 'display_name', 'select_values'],
				data: me.reportParams
			}
		});
	},

	clearReport: function () {
		var me = this;
		me.removeAll();
		me.reportId = null;
		me.reportParams = null;
	},

	buildAddReportParam: function (param) {
		var me = this;

		return {
			xtype: 'form',
			itemId: 'addReportParam',
			bodyPadding: 10,
			labelWidth: 50,
			items: [
				{
					xtype: 'textfield',
					fieldLabel: 'Display Name',
					itemId: 'paramDisplayName',
					name: 'report_params["display_name"]',
					allowBlank: false
				},
				{
					xtype: 'textfield',
					fieldLabel: 'Name',
					itemId: 'paramName',
					regex: /^(?!.*\s).*$/,
					regexText: 'Spaces not allowed',
					name: 'report_params["name"]',
					allowBlank: false
				},
				{
					xtype: 'combobox',
					fieldLabel: 'Type',
					itemId: 'paramType',
					name: 'report_params["type"]',
					allowBlank: false,
					store: me.reportTypeStore,
					queryMode: 'local',
					displayField: 'type',
					valueField: 'type',
					listeners: {
						select: function(combo, records, eOpts) {
							if (records[0].get('type') == 'select') {
								me.buildMultiSelectField(me.down('form'), ["All"])
							}
							else {
								var selectField = me.down('applicationmanagementmultioptions');
								if (selectField){
									me.down('form').remove(selectField);
								}
							}
						}
					}
				}
			],
			buttons: [
				{
					text: 'Add',
					formBind: true,
					handler: function (btn) {
						// add entry to grid
						var panel = btn.up('railsdbadminreportsparamsmanager'),
							grid = panel.down('grid'),
							paramSelectBox = panel.down('applicationmanagementmultioptions');
							if (paramSelectBox) {
								grid.getStore().add({
									display_name: panel.down('#paramDisplayName').getValue(),
									name: panel.down('#paramName').getValue(),
									type: panel.down('#paramType').getValue(),
									select_values: paramSelectBox.getValue()
								});
							}
							else{
								grid.getStore().add({
									display_name: panel.down('#paramDisplayName').getValue(),
									name: panel.down('#paramName').getValue(),
									type: panel.down('#paramType').getValue(),
								});
							}
						me.remove(btn.up('#addReportParam'));
						me.down('#addParamBtn').show();
					}
				},
				{
					text: 'Cancel',
					handler: function (btn) {
						me.remove(btn.up('#addReportParam'));
						me.down('#addParamBtn').show();
					}
				}
			]
		};
	},

	buildMultiSelectField: function(container, values){
		container.add({
			xtype: 'applicationmanagementmultioptions',
			field: {
				xtype: 'combo',
				internalIdentifier: 'select',
				store: Ext.create('Ext.data.Store', {
          fields: ['display'],
          data: Ext.Array.map(eval(values), function (item) {
						return {
							display: item
						};
					})
        }),
        queryMode: 'local'
			}
		});
	}

});
