Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion", {
    extend: "Ext.tab.Panel",
    id: 'knitkitWestRegion',
    alias: 'widget.knitkit_westregion',

    constructor: function(config) {
        this.siteStructureTabPanel = Ext.create('Compass.ErpApp.Desktop.Applications.Knitkit.SiteStructureTabPanel', {
            module: config.module
        });
        this.componentTabPanel = Ext.create('Compass.ErpApp.Desktop.Applications.Knitkit.ComponentTabPanel', {
            module: config.module
        });
        this.items = [];

        this.items.push(this.siteStructureTabPanel);
        this.items.push(this.componentTabPanel);

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
    }
});
