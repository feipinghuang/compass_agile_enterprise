Ext.define('Compass.ErpApp.Shared.Party.SecurityTree', {
	extend: 'Ext.data.Model',
	fields: [
		// ExtJs node fields
		{
			name: 'text',
			type: 'string'
		}, {
			name: 'leaf',
			type: 'boolean'
		}, {
			name: 'checked',
			type: 'boolean'
		},
		// Custom fields
		{
			name: 'internalIdentifier',
			type: 'string',
			mapping: 'internal_identifier'
		}
	]
});

Ext.define("CompassAE.ErpApp.Shared.Party.SecurityPanel", {
	extend: 'Ext.form.Panel',
	alias: 'widget.partysecuritypanel',

	title: 'Security',
	autoScroll: true,

	includeAdmin: false,
	partyId: null,
	parentSecurityRole: null,
	fieldSetHeights: 250,

	layout: 'hbox',

	dockedItems: {
		xtype: 'toolbar',
		docked: 'top',
		items: [{
			text: 'Save',
			iconCls: 'icon-save',
			handler: function(btn) {
				btn.up('form').save(btn);
			}
		}]
	},

	initComponent: function() {
		var me = this;

		me.addEvents(
			/*
			 * @event saved
			 * Fires when view is saved
			 * @param {CompassAE.ErpApp.Shared.Party.AppsInstalledPanel} this panel
			 * @param {Array} Selected Application IIds
			 */
			'saved'
		);

		var securityRolesExtraParams = {};

		if (me.parentSecurityRole) {
			securityRolesExtraParams['parent'] = me.parentSecurityRole;
		}

		if (me.includeAdmin) {
			securityRolesExtraParams['include_admin'] = me.includeAdmin;
		}

		me.callParent(arguments);

		me.on('boxready', function() {
			var mask = new Ext.LoadMask({
				msg: 'Please wait...',
				target: me
			});
			mask.show();

			me.add({
				xtype: 'fieldset',
				width: 250,
				title: 'Security Roles',
				itemId: 'securityRolesFieldSet',
				style: {
					marginLeft: '10px',
					marginRight: '10px',
					padding: '5px'
				},
				items: [{
					xtype: 'treepanel',
					height: me.fieldSetHeights,
					itemId: 'securityRolesTree',
					store: {
						model: 'Compass.ErpApp.Shared.Party.SecurityTree',
						autoLoad: false,
						proxy: {
							type: 'ajax',
							url: '/api/v1/security_roles.tree',
							extraParams: securityRolesExtraParams,
							reader: {
								type: 'treereader',
								root: 'security_roles'
							}
						},
						root: {
							expanded: false
						}
					},
					rootVisible: false,
					animate: false,
					autoScroll: true,
					containerScroll: true,
					border: false,
					frame: false
				}]
			}, {
				xtype: 'fieldset',
				width: 250,
				title: 'User Groups',
				itemId: 'userGroupsFieldSet',
				style: {
					marginLeft: '10px',
					marginRight: '10px',
					padding: '5px'
				},
				items: [{
					xtype: 'treepanel',
					height: me.fieldSetHeights,
					itemId: 'userGroupsTree',
					store: {
						autoLoad: false,
						model: 'Compass.ErpApp.Shared.Party.SecurityTree',
						proxy: {
							type: 'ajax',
							url: '/api/v1/groups.tree',
							reader: {
								type: 'treereader',
								root: 'groups'
							}
						},
						root: {
							expanded: false
						}
					},
					rootVisible: false,
					animate: false,
					autoScroll: true,
					containerScroll: true,
					border: false,
					frame: false
				}]
			}, {
				xtype: 'fieldset',
				width: 250,
				title: 'Capabilities',
				itemId: 'capabilitiesFieldSet',
				style: {
					marginLeft: '10px',
					marginRight: '10px',
					padding: '5px'
				},
				items: [{
					xtype: 'treepanel',
					height: me.fieldSetHeights,
					itemId: 'capabilitiesTree',
					store: {
						autoLoad: false,
						model: 'Compass.ErpApp.Shared.Party.SecurityTree',
						proxy: {
							type: 'ajax',
							url: '/api/v1/capabilities.tree',
							reader: {
								type: 'treereader',
								root: 'capabilities'
							}
						},
						root: {
							expanded: false
						}
					},
					rootVisible: false,
					animate: false,
					autoScroll: true,
					containerScroll: true,
					border: false,
					frame: false
				}]
			}, {
				xtype: 'fieldset',
				width: 250,
				height: (me.fieldSetHeights + 30),
				title: 'Effective Security',
				itemId: 'effectiveSecurityFieldSet',
				style: {
					marginLeft: '10px',
					marginRight: '10px'
				}
			});

			var loadSecurityRoles = function() {
				var dfd = Ext.create('Ext.ux.Deferred');
				me.down('#securityRolesTree').getRootNode().expand(false,
					function(records, operation, success) {
						dfd.resolve(records);
					});
				return dfd.promise();
			};

			var loadUserGroups = function() {
				var dfd = Ext.create('Ext.ux.Deferred');
				me.down('#userGroupsTree').getRootNode().expand(false,
					function(records, operation, success) {
						dfd.resolve(records);
					});
				return dfd.promise();
			};

			var loadCapabilities = function() {
				var dfd = Ext.create('Ext.ux.Deferred');
				me.down('#capabilitiesTree').getRootNode().expand(false,
					function(records, operation, success) {
						dfd.resolve(records);
					});
				return dfd.promise();
			};

			// set global window variable for this panel
			window.securityPanel = me;

			Ext.ux.Deferred.when(loadUserGroups,
					loadCapabilities,
					loadSecurityRoles,
					me.load)
				.then(function(results) {
					mask.hide();
					// clear global window variable for this panel
					window.securityPanel = null;
				}, function(errors) {
					// clear global window variable for this panel
					window.securityPanel = null;
					mask.hide();
				});
		});
	},

	load: function() {
		var me = window.securityPanel;
		var dfd = Ext.create('Ext.ux.Deferred');

		Ext.ux.Deferred.when(me.loadEffectiveSecurityDefered, me.loadCurrentSecurity)
			.then(function(results) {
				dfd.resolve();
			}, function(errors) {
				dfd.reject();
			});

		return dfd.promise();
	},

	loadCurrentSecurity: function() {
		var me = window.securityPanel;
		var dfdOuter = Ext.create('Ext.ux.Deferred');

		var loadSecurityRoles = function() {
			var dfd = Ext.create('Ext.ux.Deferred');
			Compass.ErpApp.Utility.ajaxRequest({
				url: '/api/v1/parties/' + me.partyId + '/security_roles',
				method: 'GET',
				errorMessage: 'Could not load Security Roles',
				success: function(response) {
					var securityRoles = Ext.Array.pluck(response.security_roles, 'internal_identifier');
					var tree = me.down('#securityRolesTree');
					var rootNode = tree.getRootNode();

					rootNode.cascadeBy(function(node) {
						if (Ext.Array.contains(securityRoles, node.get('internalIdentifier'))) {
							node.set('checked', true);

							var parent = node.parentNode;
							while (parent.internalId != rootNode.internalId) {
								parent.expand();
								parent = parent.parentNode;
							}
						}
					}, true);

					dfd.resolve();
				},
				failure: function() {
					dfd.reject();
				}
			});

			return dfd.promise();
		};

		var loadGroups = function() {
			var dfd = Ext.create('Ext.ux.Deferred');
			Compass.ErpApp.Utility.ajaxRequest({
				url: '/api/v1/parties/' + me.partyId + '/groups',
				method: 'GET',
				errorMessage: 'Could not load User Groups',
				success: function(response) {
					var groups = Ext.Array.pluck(response.groups, 'id');
					var tree = me.down('#userGroupsTree');

					tree.getRootNode().cascadeBy(function(node) {
						if (Ext.Array.contains(groups, parseInt(node.get('internalIdentifier'), 10))) {
							node.set('checked', true);
						}
					}, true);

					dfd.resolve();
				},
				failure: function() {
					dfd.reject();
				}
			});
			return dfd.promise();
		};

		var loadCapabilities = function() {
			var dfd = Ext.create('Ext.ux.Deferred');
			Compass.ErpApp.Utility.ajaxRequest({
				url: '/api/v1/parties/' + me.partyId + '/capabilities',
				method: 'GET',
				errorMessage: 'Could not load Capabilities',
				success: function(response) {
					var capabilities = Ext.Array.pluck(response.capabilities, 'id');

					me.down('#capabilitiesTree').getRootNode().cascadeBy(function(node) {
						if (Ext.Array.contains(capabilities, parseInt(node.get('internalIdentifier'), 10))) {
							node.set('checked', true);
						}
					}, true);

					dfd.resolve();
				},
				failure: function() {
					dfd.reject();
				}
			});
			return dfd.promise();
		};

		Ext.ux.Deferred.when(loadSecurityRoles, loadGroups, loadCapabilities)
			.then(function(results) {
				dfdOuter.resolve();
			}, function(errors) {
				dfdOuter.reject();
			});

		return dfdOuter.promise();
	},

	loadEffectiveSecurityDefered: function() {
		var dfd = Ext.create('Ext.ux.Deferred');

		window.securityPanel.loadEffectiveSecurity(function() {
			dfd.resolve();
		}, function() {
			dfd.reject();
		});

		return dfd.promise();
	},

	loadEffectiveSecurity: function(success, failure) {
		me = this;

		Compass.ErpApp.Utility.ajaxRequest({
			url: '/api/v1/parties/' + me.partyId + '/effective_security',
			method: 'GET',
			errorMessage: 'Could not load effective security',
			success: function(response) {
				var capabilities = Ext.widget('box', {
					xtype: 'panel',
					itemId: 'capabilities',
					title: 'Capabilities',
					height: 250,
					autoScroll: true,
					tpl: new Ext.XTemplate(
						'<ul>',
						'<tpl for=".">',
						'<li>{capability_type_iid} {capability_resource_type}</li>',
						'</tpl>',
						'</ul>'
					)
				});

				if (response.capabilities.length > 0) {
					capabilities.update(response.capabilities);
				} else {
					capabilities.update("No capabilities.");
				}

				me.down('#effectiveSecurityFieldSet').removeAll();
				me.down('#effectiveSecurityFieldSet').add(capabilities);

				if (success)
					success();
			},
			failure: function() {
				if (failure)
					failure();
			}
		});
	},

	save: function(btn) {
		var me = this;
		var securityRolesTree = me.down('#securityRolesTree');
		var userGroupsTree = me.down('#userGroupsTree');
		var capabilitiesTree = me.down('#capabilitiesTree');

		var selectedSecurityRoles = [],
			selectedGroups = [],
			selectedCapabilities = [];

		btn.disable();

		securityRolesTree.getRootNode().cascadeBy(function(node) {
			if (node.get('checked')) {
				selectedSecurityRoles.push(node.get('internalIdentifier'));
			}
		});

		userGroupsTree.getRootNode().cascadeBy(function(node) {
			if (node.get('checked')) {
				selectedGroups.push(node.get('internalIdentifier'));
			}
		});

		capabilitiesTree.getRootNode().cascadeBy(function(node) {
			if (node.get('checked')) {
				selectedCapabilities.push(node.get('internalIdentifier'));
			}
		});

		var mask = new Ext.LoadMask({
			msg: 'Please wait...',
			target: me
		});
		mask.show();

		Compass.ErpApp.Utility.ajaxRequest({
			url: '/api/v1/parties/' + me.partyId + '/update_security',
			method: 'PUT',
			params: {
				security_role_iids: selectedSecurityRoles.join(','),
				group_ids: selectedGroups.join(','),
				capability_ids: selectedCapabilities.join(',')
			},
			errorMessage: 'Could not save security updates',
			success: function(response) {
				me.fireEvent('saved', me, selectedSecurityRoles, selectedGroups, selectedCapabilities);

				me.loadEffectiveSecurity();
				btn.enable();
				mask.hide();
			},
			failure: function() {
				btn.enable();
				mask.hide();
			}
		});
	}
});