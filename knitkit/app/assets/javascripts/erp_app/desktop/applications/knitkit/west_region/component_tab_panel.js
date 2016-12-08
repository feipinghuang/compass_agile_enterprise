Ext.define('Compass.ErpApp.Desktop.Applications.Knitkit.ComponentTabPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.knitkit_componenttabpanel',
    title: "Components",
    layout: 'accordion',


    initComponent: function() {

        var headerPanel = Ext.create('Ext.panel.Panel', {
            title: 'Header Blocks',
            autoScroll: true,
            items: [{
                xtype: 'knitkitheaderblock',
                centerRegion: this.initialConfig['module'].centerRegion,
                header: false
            }]
        });


        var contentSectionPanel = Ext.create('Ext.panel.Panel', {
            title: 'Content Section Blocks',
            autoScroll: true,
            items: [{
                xtype: 'knitkitcontentsectionblock',
                centerRegion: this.initialConfig['module'].centerRegion,
                header: false
            }]
        });

        var footerPanel = Ext.create('Ext.panel.Panel', {
            title: 'Footer Blocks',
            autoScroll: true,
            items: [{
                xtype: 'knitkitfooterblock',
                centerRegion: this.initialConfig['module'].centerRegion,
                header: false
            }]
        });

        this.items = [headerPanel, contentSectionPanel, footerPanel];

        this.callParent(arguments);
    },


    constructor: function(config) {
        config = Ext.apply({

            region: 'west',
            split: true,
            width: 300,
            collapsible: true

        }, config);

        this.callParent([config]);
    }
});
