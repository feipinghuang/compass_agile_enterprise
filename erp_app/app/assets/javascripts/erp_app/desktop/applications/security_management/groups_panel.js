Ext.define("Compass.ErpApp.Desktop.Applications.SecurityManagement.GroupsPanel", {
    extend: "Ext.panel.Panel",
    alias: 'widget.security_management_groupspanel',

    title: 'Groups',
    autoScroll: true,
    layout: 'fit',

    setGroup: function(record) {
	var assign_to_id = record.get('id');
	var assign_to_description = record.get('description');

	var security_management_groupspanel = this;
	var southPanel = Ext.ComponentQuery.query('security_management_southpanel').first();

	var security_management_roleswidget = southPanel.down('security_management_roleswidget');
	security_management_roleswidget.assign_to_id = assign_to_id;
	security_management_roleswidget.assign_to_description = assign_to_description;

	var security_management_capabilitieswidget = southPanel.down('security_management_capabilitieswidget');
	security_management_capabilitieswidget.assign_to_id = assign_to_id;
	security_management_capabilitieswidget.assign_to_description = assign_to_description;

	var security_management_groupseffectivesecurity = southPanel.down('security_management_groupseffectivesecurity');
	security_management_groupseffectivesecurity.assign_to_id = assign_to_id;
	security_management_groupseffectivesecurity.assign_to_description = assign_to_description;
    },

    unsetGroup: function() {
	var security_management_rolespanel = this;
	var southPanel = Ext.ComponentQuery.query('security_management_southpanel').first();

	var security_management_roleswidget = southPanel.down('security_management_roleswidget');
	delete security_management_roleswidget.assign_to_id;
	delete security_management_roleswidget.assign_to_description;

	var security_management_capabilitieswidget = southPanel.down('security_management_capabilitieswidget');
	delete security_management_capabilitieswidget.assign_to_id;
	delete security_management_capabilitieswidget.assign_to_description;

	var security_management_groupseffectivesecurity = southPanel.down('security_management_groupseffectivesecurity');
	delete security_management_groupseffectivesecurity.assign_to_id;
	delete security_management_groupseffectivesecurity.assign_to_description;
    },

    constructor: function(config) {
	var self = this;

	config = Ext.apply({
	    tbar: [{
		text: 'New Group',
		iconCls: 'icon-add',
		handler: function(btn) {
		    var newWindow = Ext.create("Ext.window.Window", {
			title: 'New Group',
			modal: true,
			buttonAlign: 'center',
			defaultFocus: 'description',
			items: Ext.create('Ext.form.Panel', {
			    labelWidth: 110,
			    frame: false,
			    bodyStyle: 'padding:5px 5px 0',
			    defaults: {
				width: 400
			    },
			    items: [{
				xtype: 'textfield',
				fieldLabel: 'Group Name',
				allowBlank: false,
				name: 'description',
				itemId: 'description',
				listeners: {
				    afterrender: function(field) {
					field.focus(false, 200);
				    },
				    specialkey: function(field, e) {
					if (e.getKey() == e.ENTER) {
					    var button = field.findParentByType('window').down('#submitButton');
					    button.fireEvent('click', button);
					}
				    }
				}
			    }]
			}),
			buttons: [{
			    text: 'Submit',
			    itemId: 'submitButton',
			    listeners: {
				'click': function(button) {
				    var formPanel = button.findParentByType('window').down('form');

				    formPanel.getForm().submit({
					waitMsg: 'Please Wait...',
					url: '/api/v1/groups',
					success: function(form, action) {
					    var obj = Ext.decode(action.response.responseText);
					    if (obj.success) {
						var all_groups = self.down('#all_groups').down('gridview');
						all_groups.getStore().load();
						newWindow.close();
					    } else {
						Ext.Msg.alert("Error", obj.message);
					    }
					},
					failure: function(form, action) {
					    var obj = Ext.decode(action.response.responseText);
					    if (obj !== null) {
						Ext.Msg.alert("Error", obj.message);
					    } else {
						Ext.Msg.alert("Error", "Error importing website");
					    }
					}
				    });
				}
			    }
			}, {
			    text: 'Close',
			    handler: function() {
				newWindow.close();
			    }
			}]
		    });
		    newWindow.show();
		}
	    }, {
		text: 'Edit Group',
		iconCls: 'icon-edit',
		handler: function(btn) {
		    var all_groups = self.down('#all_groups').down('gridview');
		    var selection = all_groups.getSelectionModel().getSelection().first();
		    if (Ext.isEmpty(selection)) {
			Ext.Msg.alert('Error', 'Please make a selection.');
			return false;
		    }
		    var newWindow = Ext.create("Ext.window.Window", {
			title: 'Edit Group',
			modal: true,
			buttonAlign: 'center',
			defaultFocus: 'description',
			items: Ext.create('Ext.form.Panel', {
			    labelWidth: 110,
			    frame: false,
			    bodyStyle: 'padding:5px 5px 0',
			    defaults: {
				width: 400
			    },
			    items: [{
				xtype: 'textfield',
				fieldLabel: 'Group Name',
				allowBlank: false,
				name: 'description',
				itemId: 'description',
				value: selection.get('description'),
				listeners: {
				    afterrender: function(field) {
					field.focus(true, 200);
				    },
				    specialkey: function(field, e) {
					if (e.getKey() == e.ENTER) {
					    var button = field.findParentByType('window').down('#submitButton');
					    button.fireEvent('click', button);
					}
				    }
				}
			    }]
			}),
			buttons: [{
			    text: 'Submit',
			    itemId: 'submitButton',
			    listeners: {
				'click': function(button) {
				    var formPanel = button.findParentByType('window').down('form');

				    formPanel.getForm().submit({
					method: 'PUT',
					waitMsg: 'Please Wait...',
					url: '/api/v1/groups/' + selection.get('id'),
					success: function(form, action) {
					    var obj = Ext.decode(action.response.responseText);
					    if (obj.success) {
						var all_groups = self.down('#all_groups').down('gridview');
						all_groups.getStore().load();
						newWindow.close();
					    } else {
						Ext.Msg.alert("Error", obj.message);
					    }
					},
					failure: function(form, action) {
					    var obj = Ext.decode(action.response.responseText);
					    if (obj !== null) {
						Ext.Msg.alert("Error", obj.message);
					    } else {
						Ext.Msg.alert("Error", "Error importing website");
					    }
					}
				    });
				}
			    }
			}, {
			    text: 'Close',
			    handler: function() {
				newWindow.close();
			    }
			}]
		    });
		    newWindow.show();
		}
	    }, {
		text: 'Delete Group',
		iconCls: 'icon-delete',
		handler: function(btn) {
		    var all_groups = self.down('#all_groups').down('gridview');
		    var selection = all_groups.getSelectionModel().getSelection().first();
		    if (Ext.isEmpty(selection)) {
			Ext.Msg.alert('Error', 'Please make a selection.');
			return false;
		    }
		    Ext.MessageBox.confirm('Confirm', 'Are you sure?', function(btn) {
			if (btn == 'no') {
			    return false;
			} else if (btn == 'yes') {
			    Ext.Ajax.request({
				url: '/api/v1/groups/' + selection.get('id'),
				method: 'DELETE',
				success: function(response) {
				    var json_response = Ext.decode(response.responseText);
				    if (json_response.success) {
                                        var southPanel = Ext.ComponentQuery.query('security_management_southpanel').first(),
                                            activeTabPanel = southPanel.down('tabpanel').getActiveTab();
                                        
					self.unsetGroup();
					activeTabPanel.clearWidget();
					all_groups.getStore().load();
				    } else {
					Ext.Msg.alert('Error', Ext.decode(response.responseText).message);
				    }
				},
				failure: function(response) {
				    Ext.Msg.alert('Error', 'Error Retrieving Effective Security');
				}
			    });
			}
		    });
		}
	    }],
	    items: [{
		xtype: 'security_management_group_grid',
		itemId: 'all_groups',
		height: '100%',
		listeners: {
		    afterrender: function(grid) {
			// autoLoad was causing erroneous calls to /erp_app/desktop/true so we manually load here
			grid.getStore().load();
		    },
		    itemclick: function(grid, record, index, eOpts) {
			self.setGroup(record);

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
