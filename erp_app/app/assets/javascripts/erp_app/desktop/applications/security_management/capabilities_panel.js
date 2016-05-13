Ext.define("Compass.ErpApp.Desktop.Applications.SecurityManagement.CapabilitiesPanel", {
	extend: "Ext.panel.Panel",
	alias: 'widget.security_management_capabilitiespanel',

	title: 'Capabilities',
	autoScroll: true,
	layout: 'fit',

	setCapability: function(record) {
		var assign_to_id = record.get('id');
		var assign_to_description = record.get('description');

		var security_management_capabilitiespanel = this;
		var southPanel = Ext.ComponentQuery.query('security_management_southpanel').first();

		var security_management_groupswidget = southPanel.down('security_management_groupswidget');
		security_management_groupswidget.assign_to_id = assign_to_id;
		security_management_groupswidget.assign_to_description = assign_to_description;

		var security_management_roleswidget = southPanel.down('security_management_roleswidget');
		security_management_roleswidget.assign_to_id = assign_to_id;
		security_management_roleswidget.assign_to_description = assign_to_description;
	},

	constructor: function(config) {
		var self = this;

		config = Ext.apply({
			items: [{
				xtype: 'security_management_capability_grid',
				itemId: 'all_capabilities',
				listeners: {
					afterrender: function(grid) {
						// autoLoad was causing erroneous calls to /erp_app/desktop/true so we manually load here
						grid.getStore().load();
					},
					itemclick: function(grid, record, index, eOpts) {
						self.setCapability(record);

						// get active tabpanel
						var southPanel = Ext.ComponentQuery.query('security_management_southpanel').first();
						var activeTabPanel = southPanel.down('tabpanel').getActiveTab();
						activeTabPanel.refreshWidget();
						activeTabPanel.updateTitle();
					}
				}
			}]

		}, config);

		this.callParent([config]);
	}

});