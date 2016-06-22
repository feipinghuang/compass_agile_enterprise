Ext.define("Compass.ErpApp.Desktop.Applications.SecurityManagement.GroupsWidget", {
    extend: "Ext.panel.Panel",
    alias: 'widget.security_management_groupswidget',
    mixins: [
        'Compass.ErpApp.Desktop.Applications.SecurityManagement.Mixins.Widget'
    ],

    
    updateTitle: function() {
	if (this.assign_to_description) {
	    this.down('#assignment').setTitle('Assign Groups to ' + this.assign_to + ' ' + this.assign_to_description);
	}
    },

    constructor: function(config) {
	var self = this,
	    commonWidgetProperties = Compass.ErpApp.Desktop.Applications.SecurityManagement.CommonWidget.properties;

	var available_grid = Ext.apply(commonWidgetProperties.available_grid, {
	    xtype: 'security_management_group_grid',
	    itemId: 'available',
	    url: '/api/v1/groups/available',
	    title: 'Available Groups'
	});

	var selected_grid = Ext.apply(commonWidgetProperties.selected_grid, {
	    xtype: 'security_management_group_grid',
	    title: 'Selected Groups',
	    url: '/api/v1/groups/selected',
	    itemId: 'selected'
	});

	var assignment = Ext.apply(commonWidgetProperties.assignment, {
	    xtype: 'panel',
	    title: 'Manage Groups',
	    layout: 'hbox',
	    items: [
		available_grid, {
		    xtype: 'container',
		    width: 22,
		    bodyPadding: 5,
		    items: [{
			xtype: 'SecurityManagement-AddGroupButton'
		    }, {
			xtype: 'SecurityManagement-RemoveGroupButton'
		    }]
		},
		selected_grid
	    ]
	});

	config = Ext.apply({
	    title: 'Groups',
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

Ext.define("Compass.ErpApp.Desktop.Applications.SecurityManagement.GroupGrid", {
    extend: "Ext.grid.Panel",
    alias: 'widget.security_management_group_grid',

    columns: [{
	header: 'Group Name',
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
		url: (me.initialConfig.url || '/api/v1/groups'),
		reader: {
		    type: 'json',
		    root: 'groups',
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
			    var grid = field.findParentByType('security_management_group_grid');
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
			if (button.findParentByType('security_management_groupswidget') && !button.findParentByType('security_management_groupswidget').assign_to_id) return;
			var grid = button.findParentByType('security_management_group_grid');
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

Ext.define('Compass.ErpApp.Desktop.Applications.SecurityManagement.AddGroupButton', {
    extend: 'Ext.button.Button',
    alias: 'widget.SecurityManagement-AddGroupButton',
    itemId: 'AddGroupButton',
    style: 'margin-top: 100px !important;',
    cls: 'clean-image-icon',
    iconCls: 'icon-arrow-right-blue',
    formBind: false,
    tooltip: 'Add to Selected',
    listeners: {
	click: function(button) {
	    var security_management_groupswidget = button.findParentByType('security_management_groupswidget');
	    var available_grid = security_management_groupswidget.query('#available').first().down('gridview');
	    var selected_grid = security_management_groupswidget.query('#selected').first().down('gridview');
	    var selection = available_grid.getSelectionModel().getSelection();
	    if (security_management_groupswidget.assign_to_id && selection.length > 0) {
		var selected_groups = [];
		Ext.each(selection, function(s) {
		    selected_groups.push(s.data.id);
		});

		Ext.Ajax.request({
		    url: '/api/v1/groups/add',
		    method: 'PUT',
		    params: {
			type: security_management_groupswidget.assign_to,
			id: security_management_groupswidget.assign_to_id,
			group_ids: Ext.encode(selected_groups)
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
			Ext.Msg.alert('Error', 'Error Adding Group');
		    }
		});
	    } else {
		Ext.Msg.alert('Error', 'Please make a selection.');
	    }
	}
    }
});

Ext.define('Compass.ErpApp.Desktop.Applications.SecurityManagement.RemoveGroupButton', {
    extend: 'Ext.button.Button',
    alias: 'widget.SecurityManagement-RemoveGroupButton',
    itemId: 'RemoveGroupButton',
    cls: 'clean-image-icon',
    iconCls: 'icon-arrow-left-blue',
    formBind: false,
    tooltip: 'Remove from Selected',
    listeners: {
	click: function(button) {
	    var security_management_groupswidget = button.findParentByType('security_management_groupswidget');
	    var available_grid = security_management_groupswidget.query('#available').first().down('gridview');
	    var selected_grid = security_management_groupswidget.query('#selected').first().down('gridview');
	    var selection = selected_grid.getSelectionModel().getSelection();
	    if (security_management_groupswidget.assign_to_id && selection.length > 0) {
		var selected_groups = [];
		Ext.each(selection, function(s) {
		    selected_groups.push(s.data.id);
		});

		Ext.Ajax.request({
		    url: '/api/v1/groups/remove',
		    method: 'PUT',
		    params: {
			type: security_management_groupswidget.assign_to,
			id: security_management_groupswidget.assign_to_id,
			group_ids: Ext.encode(selected_groups)
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
			Ext.Msg.alert('Error', 'Error Removing Group');
		    }
		});
	    } else {
		Ext.Msg.alert('Error', 'Please make a selection.');
	    }
	}
    }
});
