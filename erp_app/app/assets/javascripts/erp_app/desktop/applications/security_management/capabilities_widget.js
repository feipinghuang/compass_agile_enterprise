Ext.define("Compass.ErpApp.Desktop.Applications.SecurityManagement.CapabilitiesWidget", {
    extend: "Ext.panel.Panel",
    alias: 'widget.security_management_capabilitieswidget',
    mixins: [
        'Compass.ErpApp.Desktop.Applications.SecurityManagement.Mixins.Widget'
    ],

    updateTitle: function() {
	if (this.assign_to_description) {
	    this.down('#assignment').setTitle('Assign Capabilities to ' + this.assign_to + ' ' + this.assign_to_description);
	}
    },

    constructor: function(config) {
	var self = this,
	    commonWidgetProperties = Compass.ErpApp.Desktop.Applications.SecurityManagement.CommonWidget.properties;

	var available_grid = Ext.apply(commonWidgetProperties.available_grid, {
	    itemId: 'available',
	    xtype: 'security_management_capability_grid',
	    title: 'Available Capabilities',
	    url: '/api/v1/capabilities/available'
	});

	var selected_grid = Ext.apply(commonWidgetProperties.selected_grid, {
	    itemId: 'selected',
	    xtype: 'security_management_capability_grid',
	    title: 'Selected Capabilities',
	    url: '/api/v1/capabilities/selected'
	});

	var assignment = Ext.apply(commonWidgetProperties.assignment, {
	    xtype: 'panel',
	    title: 'Manage Capabilities',
	    layout: 'hbox',
	    items: [
		available_grid, {
		    xtype: 'container',
		    width: 22,
		    bodyPadding: 5,
		    items: [{
			xtype: 'SecurityManagement-AddCapabilityButton'
		    }, {
			xtype: 'SecurityManagement-RemoveCapabilityButton'
		    }]
		},
		selected_grid
	    ]
	});

	config = Ext.apply({
	    title: 'Capabilities',
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

Ext.define("Compass.ErpApp.Desktop.Applications.SecurityManagement.CapabilityGrid", {
    extend: "Ext.grid.Panel",
    alias: 'widget.security_management_capability_grid',

    columns: [{
	header: 'Description',
	dataIndex: 'description',
	flex: 1
    }],

    initComponent: function() {
	var me = this;

	me.store = Ext.create('Ext.data.Store', {
	    pageSize: 10,
	    fields: [
		'id', 'description'
	    ],
	    proxy: {
		type: 'ajax',
		url: (me.initialConfig.url || '/api/v1/capabilities'),
		reader: {
		    type: 'json',
		    root: 'capabilities',
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
			    var grid = field.findParentByType('security_management_capability_grid');
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
			if (button.findParentByType('security_management_capabilitieswidget') && !button.findParentByType('security_management_capabilitieswidget').assign_to_id) return;
			var grid = button.findParentByType('security_management_capability_grid');
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

Ext.define('Compass.ErpApp.Desktop.Applications.SecurityManagement.AddCapabilityButton', {
    extend: 'Ext.button.Button',
    alias: 'widget.SecurityManagement-AddCapabilityButton',
    itemId: 'AddCapabilityButton',
    style: 'margin-top: 100px !important;',
    cls: 'clean-image-icon',
    iconCls: 'icon-arrow-right-blue',
    formBind: false,
    tooltip: 'Add to Selected',
    listeners: {
	click: function(button) {
	    var security_management_capabilitieswidget = button.findParentByType('security_management_capabilitieswidget');
	    var available_grid = security_management_capabilitieswidget.query('#available').first().down('gridview');
	    var selected_grid = security_management_capabilitieswidget.query('#selected').first().down('gridview');
	    var selection = available_grid.getSelectionModel().getSelection();
	    if (security_management_capabilitieswidget.assign_to_id && selection.length > 0) {
		var selected = [];
		Ext.each(selection, function(s) {
		    selected.push(s.data.id);
		});

		Ext.Ajax.request({
		    url: '/api/v1/capabilities/add',
		    method: 'PUT',
		    params: {
			type: security_management_capabilitieswidget.assign_to,
			id: security_management_capabilitieswidget.assign_to_id,
			capability_ids: Ext.encode(selected)
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
			Ext.Msg.alert('Error', 'Error Adding Capability');
		    }
		});
	    } else {
		Ext.Msg.alert('Error', 'Please make a selection.');
	    }
	}
    }
});

Ext.define('Compass.ErpApp.Desktop.Applications.SecurityManagement.RemoveCapabilityButton', {
    extend: 'Ext.button.Button',
    alias: 'widget.SecurityManagement-RemoveCapabilityButton',
    itemId: 'RemoveCapabilityButton',
    cls: 'clean-image-icon',
    iconCls: 'icon-arrow-left-blue',
    formBind: false,
    tooltip: 'Remove from Selected',
    listeners: {
	click: function(button) {
	    var security_management_capabilitieswidget = button.findParentByType('security_management_capabilitieswidget');
	    var available_grid = security_management_capabilitieswidget.query('#available').first().down('gridview');
	    var selected_grid = security_management_capabilitieswidget.query('#selected').first().down('gridview');
	    var selection = selected_grid.getSelectionModel().getSelection();
	    if (security_management_capabilitieswidget.assign_to_id && selection.length > 0) {
		var selected = [];
		Ext.each(selection, function(s) {
		    selected.push(s.data.id);
		});

		Ext.Ajax.request({
		    url: '/api/v1/capabilities/remove',
		    method: 'PUT',
		    params: {
			type: security_management_capabilitieswidget.assign_to,
			id: security_management_capabilitieswidget.assign_to_id,
			capability_ids: Ext.encode(selected)
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
			Ext.Msg.alert('Error', 'Error Removing Capability');
		    }
		});
	    } else {
		Ext.Msg.alert('Error', 'Please make a selection.');
	    }
	}
    }
});
