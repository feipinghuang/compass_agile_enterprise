Ext.define("Compass.ErpApp.Desktop.Applications.SecurityManagement", {
	extend: "Ext.ux.desktop.Module",
	id: 'security_management-win',
	init: function() {
		this.launcher = {
			text: 'Security Management',
			iconCls: 'icon-key',
			handler: this.createWindow,
			scope: this
		};
	},

	createWindow: function() {
		var desktop = this.app.getDesktop();
		var win = desktop.getWindow('security_management');
		if (!win) {
			var items = this.build();
			win = desktop.createWindow({
				id: 'security_management',
				title: 'Security Management',
				maximized: true,
				width: 1000,
				height: 550,
				bodyPadding: '10px',
				iconCls: 'icon-key-light',
				shim: false,
				animCollapse: false,
				constrainHeader: true,
				layout: 'border',
				items: items
			});
		}
		win.show();
	},

	build: function() {
		var tabPanel = Ext.create('Ext.Panel', {
			layout: {
				type: 'vbox',
				align: 'center'
			},
			items: []
		});

		var tabItemConfigs = [{
			xtype: 'security_management_rolespanel',
			iconSrc: location.origin + '/assets/erp_app/desktop/applications/security_management/manage_roles.png',
			title: 'Manage Security Roles'
		}, {
			xtype: 'security_management_groupspanel',
			iconSrc: location.origin + '/assets/erp_app/desktop/applications/security_management/manage_groups.png',
			title: 'Manage Groups'
		}, {
			xtype: 'security_management_capabilitiespanel',
			iconSrc: location.origin + '/assets/erp_app/desktop/applications/security_management/manage_capabilities.png',
			title: 'Manage Cababilites'
		}];

		Ext.each(tabItemConfigs, function(tabItemConfig) {
			tabPanel.add({
				xtype: 'image',
				src: tabItemConfig.iconSrc,
				style: {
					cursor: 'pointer'
				},
				height: 64,
				width: 64,
				margin: 5,
				html: tabItemConfig.title,
				listeners: {
					render: function(component) {
						component.getEl().on('click', function(e) {
							var northPanel = Ext.getCmp('security_management_north_region'),
								tab = northPanel.down(tabItemConfig.xtype);
							northPanel.setActiveTab(tab);
						}, component);
					}
				}
			});

			tabPanel.add({
				xtype: 'label',
				text: tabItemConfig.title,
				style: {
					cursor: 'pointer'
				}
			});

		});

		var westPanel = Ext.create('Ext.Panel', {
			id: 'security_management_west_region',
			style: {
				borderRadius: '5px'
			},
			region: 'west',
			width: 200,
			split: true,
			layout: 'fit',
			items: [tabPanel]
		});

		var centerPanel = Ext.create('Ext.Panel', {
			id: 'security_management_center_region',
			autoScroll: true,
			layout: 'vbox',
			bodyStyle: {
				background: '#537697'
			},
			style: {
				marginRight: '20px',
				borderBottomLeftRadius: '5px',
				borderBottomRightRadius: '5px'
			},
			region: 'center',
			items: [{
				xtype: 'security_management_northpanel',
				width: '100%',
				flex: 0.75,
				style: {
					marginBottom: '20px',
					borderBottomLeftRadius: '5px',
					borderBottomRightRadius: '5px'
				}
			}, {
				xtype: 'security_management_southpanel',
				width: '100%',
				flex: 1,
				style: {
					borderRadius: '5px'
				}
			}]
		});

		return [westPanel, centerPanel];
	}

});

Ext.define('Compass.ErpApp.Desktop.Applications.SecurityManagement.SearchBox', {
	extend: 'Compass.ErpApp.Shared.DynamicRelatedSearchBox',
	alias: 'widget.SecurityManagement-searchbox',

	constructor: function(config) {
		config = Ext.apply({
			url: '/erp_app/desktop/security_management/search',
			display_template: config.display_template,
			fields: config.fields,
			extraParams: {
				model: (config.model || 'User')
			}

		}, config);
	}
});