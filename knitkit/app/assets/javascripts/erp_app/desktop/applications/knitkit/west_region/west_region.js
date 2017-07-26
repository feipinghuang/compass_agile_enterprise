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
    }
});