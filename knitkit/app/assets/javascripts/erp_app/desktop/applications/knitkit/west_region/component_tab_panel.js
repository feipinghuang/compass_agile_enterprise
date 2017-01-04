Ext.define('Compass.ErpApp.Desktop.Applications.Knitkit.ComponentTabPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.knitkit_componenttabpanel',
    title: "Components",
    layout: 'accordion',

    setWindowStatus: function(status) {
        this.findParentByType('statuswindow').setStatus(status);
    },

    clearWindowStatus: function() {
        this.findParentByType('statuswindow').clearStatus();
    },

    initComponent: function() {
        var me = this;
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
        this.dockedItems = [{
            dock: 'top',
            xtype: 'container',
            layout: {
                type: 'hbox',
                align: 'stretch'
            },
            items: [{
                    xtype: 'button',
                    flex: 1,
                    text: 'Build Website',
                    handler: function() {
                        centerPanel = Ext.ComponentQuery.query("knitkit_centerregion").first();
                        centerTabPanel = centerPanel.down('tabpanel');
                        websitesCombo = Ext.ComponentQuery.query("websitescombo").first();
                        websiteId = websitesCombo.getValue();

                        websiteBuilderPanel = Ext.createWidget('websitebuilderpanel', {
                            closable: true,
                            centerRegion: region,
                            save: function(comp) {
                                var componentPanels = comp.query("panel[cls=websitebuilder-component-panel]"),
                                    components = [];
                                Ext.Array.each(componentPanels, function(component, index) {
                                    iframe = component.el.query("#" + component.id + "-frame").first();
                                    page = iframe.contentDocument.documentElement.getElementsByClassName('page')[0];
                                    components.push({
                                        position: index,
                                        content_iid: component.componentId
                                    });
                                });
                                me.saveWebsiteLayout(websiteId, JSON.stringify(components));
                            }
                        });

                        centerTabPanel.add(websiteBuilderPanel);
                        centerTabPanel.setActiveTab(websiteBuilderPanel);
                    }
                }, {
                    xtype: 'button',
                    flex: 1,
                    text: 'Preview Website',
                    handler: function() {
                        var win = window.open('/website_preview', '_blank');
                        win.focus();
                    }
                }] // eo container items
        }]
        this.callParent(arguments);
    },
    /* sections */

    saveWebsiteLayout: function(id, components) {
        var me = this;
        me.setWindowStatus('Saving...');
        Ext.Ajax.request({
            url: '/api/v1/website_builder/save_website.json',
            method: 'POST',
            params: {
                id: id,
                content: components
            },
            success: function(response) {
                me.clearWindowStatus();
                var obj = Ext.decode(response.responseText);
                if (obj.success) {
                    knitkitWindow = Ext.getCmp('knitkit');
                    knitkitWindow.dockedItems.add({
                        text: 'Preview',
                        handler: function(btn) {
                            // debugger;
                        }
                    })
                } else {
                    Ext.Msg.alert('Error', obj.message);
                }
            },
            failure: function(response) {
                me.clearWindowStatus();
                Ext.Msg.alert('Error', 'Error saving layout');
            }
        });
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
