Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion", {
    extend: "Ext.tab.Panel",
    id: 'knitkitWestRegion',
    alias: 'widget.knitkit_westregion',

    module: null,

    constructor: function(config) {
        this.siteStructureTabPanel = Ext.create('Compass.ErpApp.Desktop.Applications.Knitkit.SiteStructureTabPanel', {
            module: config.module
        });

        this.items = [this.siteStructureTabPanel];

        config = Ext.apply({
            deferredRender: false,
            id: 'knitkitWestRegion',
            region: 'west',
            width: 280,
            split: true,
            collapsible: true,
            activeTab: 0
        }, config);

        this.callParent([config]);
    },

    addComponentsTabPanel: function(isTheme) {
        if (this.down('knitkit_componenttabpanel')) {
            this.down('knitkit_componenttabpanel').destroy();
        }

        this.componentTabPanel = this.add(Ext.create('Compass.ErpApp.Desktop.Applications.Knitkit.ComponentTabPanel', {
            module: this.module,
            isTheme: isTheme
        }));

        this.setActiveTab(this.componentTabPanel);
    },

    removeComponentsTabPanel: function() {
        this.down('knitkit_componenttabpanel').destroy();
    },

    selectWebsite: function(website) {
        this.siteStructureTabPanel.selectWebsite(website);
    },

    clearWebsite: function() {
        this.siteStructureTabPanel.clearWebsite();
    },

    changeSecurity: function (node, updateUrl, id) {
        Ext.Ajax.request({
            url: '/api/v1/security_roles',
            method: 'GET',
            params:{
                parent: 'website_builder',
                include_admin: true
            },
            success: function (response) {
                var obj = Ext.decode(response.responseText);
                if (obj.success) {
                    Ext.create('widget.selectroleswindow', {
                        baseParams: {
                            id: id,
                            site_id: node.get('siteId')
                        },
                        url: updateUrl,
                        currentSecurity: node.get('roles'),
                        availableRoles: obj.security_roles,
                        listeners: {
                            success: function (window, response) {
                                node.set('roles', response.roles);
                                if (response.secured) {
                                    node.set('iconCls', 'icon-section_lock');
                                }
                                else {
                                    if (node.get('isBlog')) {
                                        node.set('iconCls', 'icon-blog');
                                    }
                                    else {
                                        node.set('iconCls', 'icon-section');
                                    }
                                }
                                node.set('isSecured', response.secured);
                                node.commit();
                            },
                            failure: function () {
                                Ext.Msg.alert('Error', 'Could not update security');
                            }
                        }
                    }).show();
                }
                else {
                    Ext.Msg.alert('Error', 'Could not load available roles');
                }
            },
            failure: function (response) {
                Ext.Msg.alert('Error', 'Could not load available roles');
            }
        });
    }
});
