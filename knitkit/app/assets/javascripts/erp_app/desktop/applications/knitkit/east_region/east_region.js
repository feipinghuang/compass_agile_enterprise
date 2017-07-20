Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.EastRegion", {
    extend: "Ext.tab.Panel",
    alias: 'widget.knitkit_eastregion',

    constructor: function(config) {
        this.imageAssetsPanel = Ext.create('Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsPanel', {
            module: config.module
        });
        this.fileAssetsPanel = Ext.create('Compass.ErpApp.Desktop.Applications.Knitkit.FileAssetsPanel', {
            module: config.module
        });
        this.componentPropertiesPanel = Ext.create('Compass.ErpApp.Desktop.Applications.Knitkit.ComponentPropertiesFormPanel', {
            module: config.module
        });

        this.items = [];

        if (currentUser.hasCapability('view', 'GlobalImageAsset') || currentUser.hasCapability('view', 'SiteImageAsset')) {
            this.items.push(this.imageAssetsPanel);
        }

        if (currentUser.hasCapability('view', 'GlobalFileAsset') || currentUser.hasCapability('view', 'SiteFileAsset')) {
            this.items.push(this.fileAssetsPanel);
        }

        // this.items.push(this.widgetsPanel);
        this.items.push(this.componentPropertiesPanel);

        config = Ext.apply({
            deferredRender: false,
            id: 'knitkitEastRegion',
            region: 'east',
            width: 280,
            split: true,
            collapsible: true,
            activeTab: 0
        }, config);

        this.callParent([config]);
    },

    selectWebsite: function(website) {
        this.fileAssetsPanel.selectWebsite(website);
        this.imageAssetsPanel.selectWebsite(website);
    },

    clearWebsite: function() {
        this.fileAssetsPanel.clearWebsite();
        this.imageAssetsPanel.clearWebsite();
    }
});