Ext.define("Compass.ErpApp.Desktop.Applications.SystemManagement", {
	extend: "Ext.ux.desktop.Module",
	id: 'system_management-win',
	init: function() {
		this.launcher = {
			text: 'System Management',
			iconCls: 'icon-settings',
			handler: this.createWindow,
			scope: this
		};
	},

	createWindow: function() {
		var desktop = this.app.getDesktop();
		var win = desktop.getWindow('system_management');
		if (!win) {
			win = desktop.createWindow({
				id: 'system_management',
				title: 'System Management',
				iconCls: 'icon-settings-light',
				maximized: true,
				width: 1200,
				height: 550,
				shim: false,
				animCollapse: false,
				constrainHeader: true,
				layout: 'border',
				items: [{
					region: 'west',
					itemId: 'systemTabs',
					xtype: 'tabpanel',
					style: {
						borderRadius: '5px'
					},
					split: true,
					width: 300,
					items: [{
						xtype: 'treepanel',
						title: 'ERP Types',
						rootVisible: true,
						store: Ext.create('SystemManagementTypeTreeNodeStore'),
						viewConfig: {
							markDirty: false
						},
						listeners: {
							'itemcontextmenu': function(view, record, item, index, e) {
								e.stopEvent();

								var contextMenu = Ext.create('Ext.menu.Menu', {
									items: [{
										text: 'Add Child',
										iconCls: 'icon-add',
										handler: function() {
											var systemManagementWindow = Ext.getCmp('system_management');
											var centerPanel = systemManagementWindow.down('#centerPanel');
											var itemId, form, newNode = null;

											// check if this is an actual record or the class itself
											if (record.get('serverId')) {
												itemId = 'add' + record.get('klass') + 'parent' + record.get('serverId');
												form = centerPanel.down('#' + itemId);

												if (!form) {
													form = centerPanel.add({
														xtype: 'systemmanagement-form',
														isAdd: true,
														klass: record.get('klass'),
														parentId: record.get('serverId'),
														title: 'Add ' + record.get('klass') + ' - Parent: ' + record.get('text'),
														itemId: itemId,
														listeners: {
															saved: function(form, nodeData) {
																newNode = Ext.create('SystemManagementTypeTreeNode', {
																	serverId: nodeData.id,
																	text: nodeData.description,
																	internalIdentifier: nodeData.internal_identifier,
																	klass: nodeData.klass
																});

																record.appendChild(newNode);
																form.close();
															}
														}
													});
												}
											} else {
												itemId = 'add' + record.get('klass') + 'parent';
												form = centerPanel.down('#' + itemId);

												if (!form) {
													form = centerPanel.add({
														xtype: 'systemmanagement-form',
														isAdd: true,
														klass: record.get('klass'),
														title: 'Add ' + record.get('text'),
														itemId: itemId,
														listeners: {
															saved: function(form, nodeData) {
																newNode = Ext.create('SystemManagementTypeTreeNode', {
																	serverId: nodeData.id,
																	text: nodeData.description,
																	internalIdentifier: nodeData.internal_identifier,
																	klass: nodeData.klass
																});

																record.appendChild(newNode);
																form.close();
															}
														}
													});
												}
											}

											centerPanel.setActiveTab(form);
										}
									}, {
										text: 'Delete',
										iconCls: 'icon-delete',
										handler: function() {
											Ext.Msg.confirm('Please Confirm', 'Delete type ' + record.get('text') + '?', function(btn) {
												if (btn == 'ok' || btn == 'yes') {
													view.setLoading({
														msg: "Please wait..."
													});

													Ext.Ajax.request({
														url: '/erp_app/desktop/system_management/types/' + record.get('serverId'),
														method: 'DELETE',
														params: {
															klass: record.get('klass')
														},
														success: function(response) {
															view.setLoading(false);

															record.remove();
														},
														failure: function() {
															view.setLoading(false);
															Ext.Msg.alert('Error', 'Could not delete type ' + record.get('text'));
														}
													});
												}
											});
										}
									}]
								});
								contextMenu.showAt(e.xy);
							},
							'itemclick': function(tree, record) {
								if (record.get('serverId')) {
									var systemManagementWindow = Ext.getCmp('system_management');
									var centerPanel = systemManagementWindow.down('#centerPanel');
									var itemId = record.get('klass') + record.get('serverId');

									var form = centerPanel.down('#' + itemId);

									if (!form) {
										form = centerPanel.add({
											xtype: 'systemmanagement-form',
											klass: record.get('klass'),
											title: 'Edit ' + record.get('text'),
											itemId: itemId,
											serverId: record.get('serverId'),
											listeners: {
												saved: function(form, nodeData) {
													record.set('text', nodeData.description);
													record.set('internalIdentifier', nodeData.internal_identifier);
												}
											}
										});
									}

									form.getForm().setValues({
										description: record.get('text'),
										internal_identifier: record.get('internalIdentifier')
									});

									centerPanel.setActiveTab(form);
								}
							}
						}
					}]
				}, {
					region: 'center',
					plugins: Ext.create('Ext.ux.TabCloseMenu', {
						extraItemsTail: [
							'-', {
								text: 'Closable',
								checked: true,
								hideOnClick: true,
								handler: function(item) {
									currentItem.tab.setClosable(item.checked);
								}
							}
						],
						listeners: {
							aftermenu: function() {
								currentItem = null;
							},
							beforemenu: function(menu, item) {
								var menuitem = menu.child('*[text="Closable"]');
								currentItem = item;
								menuitem.setChecked(item.closable);
							}
						}
					}),
					style: {
						borderRadius: '5px'
					},
					itemId: 'centerPanel',
					xtype: 'tabpanel'
				}]
			});
		}
		win.show();
	}
});