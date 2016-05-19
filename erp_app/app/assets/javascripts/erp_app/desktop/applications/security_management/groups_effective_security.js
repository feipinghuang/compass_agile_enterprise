Ext.define("Compass.ErpApp.Desktop.Applications.SecurityManagement.GroupsEffectiveSecurity", {
	extend: "Ext.panel.Panel",
	alias: 'widget.security_management_groupseffectivesecurity',

	bodyPadding: '10px',
	autoScroll: true,
	layout: 'vbox',

	updateTitle: function() {
		if (this.assign_to_description) {
			this.down('#effectiveTitle').update('<div style="font-weight:bold;margin-bottom:10px;">Effective Security for Group: ' + this.assign_to_description + '</div>');
		}
	},

	refreshWidget: function(tab) {
		if (tab === undefined) tab = this;

		if (tab.assign_to_id) {

			Ext.Ajax.request({
				url: '/api/v1/groups/' + tab.assign_to_id + '/effective_security',
				method: 'GET',
				success: function(response) {
					var reponseObj = Ext.decode(response.responseText);
					if (reponseObj.success) {
						if (reponseObj.capabilities.length > 0) {
							tab.down('#effective').update(tab.capabilitiesTpl.apply(reponseObj.capabilities));
						} else {
							tab.down('#effective').update("No capabilities.");
						}
					} else {
						Ext.Msg.alert('Error', Ext.decode(response.responseText).message);
					}
				},
				failure: function(response) {
					Ext.Msg.alert('Error', 'Error Retrieving Effective Security');
				}
			});
		}
	},

	constructor: function(config) {
		var me = this;

		me.capabilitiesTpl = new Ext.XTemplate(
			'<tpl for=".">',
			'<tpl if="xindex==xcount">{.}',
			'{capability_type_iid} {capability_resource_type}',
			'<tpl else>',
			'{capability_type_iid} {capability_resource_type}, ',
			'</tpl>',
			'</tpl>'
		);

		config = Ext.apply({
			title: 'Effective Security',
			items: [{
				xtype: 'component',
				width: '80%',
				itemId: 'effectiveTitle',
				autoEl: 'div',
				html: '',
			}, {
				xtype: 'component',
				itemId: 'effective',
				width: '80%',
				autoEl: 'div',
				html: 'Please Select A Group'
			}],
			listeners: {
				activate: function(tab) {
					me.refreshWidget(tab);
					me.updateTitle();
				}
			}
		}, config);

		this.callParent([config]);
	}
});