Ext.define("CompassAE.ErpApp.Shared.Party.UserTypePanel", {
	extend: 'Ext.form.Panel',
	alias: 'widget.partyusertypepanel',

	title: 'User Type',
	autoScroll: true,

	partyId: null,
	availableRoleTypes: null,
	selectedRoleTypes: [],
	fieldSetHeights: 250,

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
			 * Fires when the roles type are saved
			 * @param {CompassAE.ErpApp.Shared.Party.UserTypePanel} this panel
			 * @param {Compass.ErpApp.Shared.TypeSelectionTree} Type selection tree
			 * @param {Array} Selected types
			 */
			'saved'
		);

		me.callParent(arguments);

		me.on('boxready', function() {
			var mask = new Ext.LoadMask({
				msg: 'Please wait...',
				target: me
			});
			mask.show();

			me.add({
				xtype: 'fieldset',
				width: 450,
				style: {
					marginLeft: '10px',
					marginRight: '10px',
					padding: '5px'
				}
			}, {
				xtype: 'box',
				itemId: 'instructions',
				autoEl: 'div',
				width: 450,
				hidden: true,
				style: {
					marginLeft: '10px',
					marginRight: '10px',
					padding: '5px'
				},
				html: '<p>User Types (also called Party Roles) control what types of relationships this party can have in the application. Are they a buyer, seller or employee? It also controls which lists in which a party will appear. </p>'
			});

			var params = {};

			if (me.availableRoleTypes) {
				params['ids'] = me.availableRoleTypes;
			}

			var loadUserTypes = function() {
				var dfd = Ext.create('Ext.ux.Deferred');

				Compass.ErpApp.Utility.ajaxRequest({
					method: 'GET',
					url: '/api/v1/role_types.tree',
					params: params,
					errorMessage: 'Could not load User Types',
					success: function(response) {
						me.down('fieldset').add({
							header: false,
							xtype: 'typeselectiontree',
							typesUrl: '/api/v1/role_types',
							typesRoot: 'role_types',
							allowBlank: false,
							height: me.fieldSetHeights,
							availableTypes: response.role_types
						});

						me.down('#instructions').show();
						dfd.resolve();
					},
					failure: function() {
						me.down('#instructions').hide();
						dfd.reject();
					}
				});

				return dfd.promise();
			};

			var loadPartyUserTypes = function() {
				var dfd = Ext.create('Ext.ux.Deferred');

				Compass.ErpApp.Utility.ajaxRequest({
					method: 'GET',
					url: '/api/v1/parties/' + me.partyId + '/role_types',
					params: params,
					errorMessage: 'Could not load User Types',
					success: function(response) {
						var roleTypeInternalIdentifiers = Ext.Array.pluck(response.role_types, 'internal_identifier');
						var tree = me.down('typeselectiontree');
						var rootNode = tree.getRootNode();

						rootNode.cascadeBy(function(node) {
							if (Ext.Array.contains(roleTypeInternalIdentifiers, node.get('internalIdentifier'))) {
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

			window.userTypePanel = me;
			window.userTypePanelMask = mask;

			Ext.ux.Deferred.when(loadUserTypes)
				.then(loadPartyUserTypes, me.loadError)
				.then(function(results) {
					window.userTypePanel.down('#instructions').show();
					window.userTypePanelMask.hide();

					window.userTypePanel = null;
					window.userTypePanelMask = null;
				}, me.loadError);
		});
	},

	loadError: function() {
		window.userTypePanel.down('#instructions').hide();
		window.userTypePanelMask.hide();

		window.userTypePanel = null;
		window.userTypePanelMask = null;
	},

	save: function(btn) {
		var me = this;
		var tree = me.down('typeselectiontree');

		if (me.isValid()) {
			btn.disable();

			var mask = new Ext.LoadMask({
				msg: 'Please wait...',
				target: me
			});
			mask.show();

			Compass.ErpApp.Utility.ajaxRequest({
				url: '/api/v1/parties/' + me.partyId + '/update_roles',
				method: 'PUT',
				params: {
					role_type_iids: tree.getSubmitData()
				},
				errorMessage: 'Could not save User Type',
				success: function(response) {
					me.fireEvent('saved', me, tree, tree.getSelectedTypes());

					btn.enable();
					mask.hide();
				},
				failure: function() {
					btn.enable();
					mask.hide();
				}
			});
		}
	}
});