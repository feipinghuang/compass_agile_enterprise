Ext.define("Compass.ErpApp.Desktop.Applications.SecurityManagement.SouthPanel", {
    extend: "Ext.Panel",
    alias: 'widget.security_management_southpanel',
    id: 'security_management_south_region',
    flex: 1,
    constructor: function(config) {
	config = Ext.apply({
	    items: [{
		xtype: 'tabpanel',
		items: [{
		    xtype: 'security_management_groupswidget',
		    assign_to: 'SecurityRole'
		}, {
		    xtype: 'security_management_capabilitieswidget',
		    assign_to: 'SecurityRole'
		}]
	    }]

	}, config);
	this.callParent([config]);
    },

    setbyParentTab: function(tab) {
	var southPanel = this;

	southPanel.removeAll();

	switch (tab.xtype) {
	case 'security_management_groupspanel':
	    southPanel.add({
		xtype: 'tabpanel',
		items: [{
		    xtype: 'security_management_roleswidget',
		    assign_to: 'Group'
		}, {
		    xtype: 'security_management_capabilitieswidget',
		    assign_to: 'Group'
		}, {
		    xtype: 'security_management_groupseffectivesecurity'
		}]
	    });
	    break;
	case 'security_management_rolespanel':
	    southPanel.add({
		xtype: 'tabpanel',
		items: [{
		    xtype: 'security_management_groupswidget',
		    assign_to: 'SecurityRole'
		}, {
		    xtype: 'security_management_capabilitieswidget',
		    assign_to: 'SecurityRole'
		}]
	    });
	    break;
	case 'security_management_capabilitiespanel':
	    southPanel.add({
		xtype: 'tabpanel',
		items: [{
		    xtype: 'security_management_groupswidget',
		    assign_to: 'Capability'
		}, {
		    xtype: 'security_management_roleswidget',
		    assign_to: 'Capability'
		}]
	    });
	    break;
	}
    }

});
