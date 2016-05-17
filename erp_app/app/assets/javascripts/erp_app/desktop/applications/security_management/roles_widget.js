Ext.define("Compass.ErpApp.Desktop.Applications.SecurityManagement.RolesWidget", {
	extend: "Ext.panel.Panel",
	alias: 'widget.security_management_roleswidget',

	updateTitle: function() {
		if (this.assign_to_description) {
			this.down('#assignment').setTitle('Assign Roles to ' + this.assign_to + ' ' + this.assign_to_description);
		}
	},

	refreshWidget: function(tab) {
		if (tab === undefined) tab = this;

		setTimeout(function() {
			var available_grid = tab.down('#available');
			var selected_grid = tab.down('#selected');
			if (tab.assign_to_id) {
				var extraParams = {
					type: tab.assign_to,
					id: tab.assign_to_id
				};

				available_grid.getStore().getProxy().extraParams = extraParams;
				available_grid.getStore().load();

				selected_grid.getStore().getProxy().extraParams = extraParams;
				selected_grid.getStore().load();
			} else {
				available_grid.getStore().getProxy().extraParams = {};
				selected_grid.getStore().getProxy().extraParams = {};
			}
		}, 900);
	},

	constructor: function(config) {
		var self = this,
			commonWidgetProperties = Compass.ErpApp.Desktop.Applications.SecurityManagement.CommonWidget.properties;

		var available_grid = Ext.apply(commonWidgetProperties.available_grid, {
			itemId: 'available',
			xtype: 'security_management_role_grid',
			title: 'Available Security Roles',
			url: '/api/v1/security_roles/available'
		});

		var selected_grid = Ext.apply(commonWidgetProperties.selected_grid, {
			itemId: 'selected',
			xtype: 'security_management_role_grid',
			title: 'Selected Security Roles',
			url: '/api/v1/security_roles/selected'
		});

		var assignment = Ext.apply(commonWidgetProperties.assignment, {
			xtype: 'panel',
			title: 'Manage Security Roles',
			layout: 'hbox',
			items: [
				available_grid, {
					xtype: 'container',
					width: 22,
					bodyPadding: 5,
					items: [{
						xtype: 'SecurityManagement-AddRoleButton'
					}, {
						xtype: 'SecurityManagement-RemoveRoleButton'
					}]
				},
				selected_grid
			]
		});

		config = Ext.apply({
			title: 'Security Roles',
			assign_to: (config.assign_to || 'User'),
			items: [
				assignment
			],
			listeners: {
				activate: function(tab) {
					self.refreshWidget(tab);
					self.updateTitle();
				}
			}

		}, config);

		this.callParent([config]);
	}
});

Ext.define("Compass.ErpApp.Desktop.Applications.SecurityManagement.RoleGrid", {
	extend: "Ext.grid.Panel",
	alias: 'widget.security_management_role_grid',

	columns: [{
		header: 'Security Role Name',
		dataIndex: 'description',
		flex: 1
	}, {
		header: 'Internal ID',
		dataIndex: 'internalIdentifier',
		flex: 1
	}, {
		header: 'Parent',
		dataIndex: 'parentDescription',
		flex: 1
	}],

	initComponent: function() {
		var me = this;

		me.store = Ext.create('Ext.data.Store', {
			pageSize: 10,
			fields: [
				'id', 'description', {
					name: 'internalIdentifier',
					mapping: 'internal_identifier',
				}, {
					name: 'parentDescription',
					mapping: 'parent.description',
				}
			],
			proxy: {
				type: 'ajax',
				url: (me.initialConfig.url || '/api/v1/security_roles'),
				reader: {
					type: 'json',
					root: 'security_roles',
					totalProperty: 'total_count'
				}
			}
		});

		me.dockedItems = [{
			xtype: 'toolbar',
			dock: 'top',
			items: [{
				fieldLabel: '<span data-qtitle="Search" data-qwidth="200" data-qtip="">Search</span>',
				itemId: 'searchValue',
				xtype: 'textfield',
				width: 400,
				value: '',
				listeners: {
					specialkey: function(field, e) {
						if (e.getKey() == e.ENTER) {
							var grid = field.findParentByType('security_management_role_grid');
							var button = grid.query('#searchButton').first();
							button.fireEvent('click', button);
						}
					}
				}
			}, {
				xtype: 'tbspacer',
				width: 1
			}, {
				xtype: 'button',
				itemId: 'searchButton',
				iconCls: 'x-btn-icon icon-search',
				listeners: {
					click: function(button) {
						if (button.findParentByType('security_management_roleswidget') && !button.findParentByType('security_management_roleswidget').assign_to_id) return;
						var grid = button.findParentByType('security_management_role_grid');
						var value = grid.query('#searchValue').first().getValue();
						grid.getStore().load({
							params: {
								query_filter: value
							}
						});
					}
				}
			}]
		}, {
			xtype: 'pagingtoolbar',
			dock: 'bottom',
			store: me.store,
			displayMsg: 'Displaying {0} - {1} of {2}',
			emptyMsg: 'Empty',
		}];

		me.callParent(arguments);
	}
});

Ext.define('Compass.ErpApp.Desktop.Applications.SecurityManagement.AddRoleButton', {
	extend: 'Ext.button.Button',
	alias: 'widget.SecurityManagement-AddRoleButton',
	itemId: 'AddRoleButton',
	style: 'margin-top: 100px !important;',
	cls: 'clean-image-icon',
	iconCls: 'icon-arrow-right-blue',
	formBind: false,
	tooltip: 'Add to Selected',
	listeners: {
		click: function(button) {
			var security_management_roleswidget = button.findParentByType('security_management_roleswidget');
			var available_grid = security_management_roleswidget.query('#available').first().down('gridview');
			var selected_grid = security_management_roleswidget.query('#selected').first().down('gridview');
			var selection = available_grid.getSelectionModel().getSelection();
			if (security_management_roleswidget.assign_to_id && selection.length > 0) {
				var selected = [];
				Ext.each(selection, function(s) {
					selected.push(s.data.id);
				});

				Ext.Ajax.request({
					url: '/api/v1/security_roles/add',
					method: 'PUT',
					params: {
						type: security_management_roleswidget.assign_to,
						id: security_management_roleswidget.assign_to_id,
						security_role_ids: Ext.encode(selected)
					},
					success: function(response) {
						var json_response = Ext.decode(response.responseText);
						if (json_response.success) {
							available_grid.getStore().load();
							selected_grid.getStore().load();
						} else {
							Ext.Msg.alert('Error', Ext.decode(response.responseText).message);
						}
					},
					failure: function(response) {
						Ext.Msg.alert('Error', 'Error Adding Security Role');
					}
				});
			} else {
				Ext.Msg.alert('Error', 'Please make a selection.');
			}
		}
	}
});

Ext.define('Compass.ErpApp.Desktop.Applications.SecurityManagement.RemoveRoleButton', {
	extend: 'Ext.button.Button',
	alias: 'widget.SecurityManagement-RemoveRoleButton',
	itemId: 'RemoveRoleButton',
	cls: 'clean-image-icon',
	iconCls: 'icon-arrow-left-blue',
	formBind: false,
	tooltip: 'Remove from Selected',
	listeners: {
		click: function(button) {
			var security_management_roleswidget = button.findParentByType('security_management_roleswidget');
			var available_grid = security_management_roleswidget.query('#available').first().down('gridview');
			var selected_grid = security_management_roleswidget.query('#selected').first().down('gridview');
			var selection = selected_grid.getSelectionModel().getSelection();
			if (security_management_roleswidget.assign_to_id && selection.length > 0) {
				var selected = [];
				Ext.each(selection, function(s) {
					selected.push(s.data.id);
				});

				Ext.Ajax.request({
					url: '/api/v1/security_roles/remove',
					method: 'PUT',
					params: {
						type: security_management_roleswidget.assign_to,
						id: security_management_roleswidget.assign_to_id,
						security_role_ids: Ext.encode(selected)
					},
					success: function(response) {
						var json_response = Ext.decode(response.responseText);
						if (json_response.success) {
							available_grid.getStore().load();
							selected_grid.getStore().load();
						} else {
							Ext.Msg.alert('Error', Ext.decode(response.responseText).message);
						}
					},
					failure: function(response) {
						Ext.Msg.alert('Error', 'Error Removing Security Role');
					}
				});
			} else {
				Ext.Msg.alert('Error', 'Please make a selection.');
			}
		}
	}
});