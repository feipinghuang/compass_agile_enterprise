Ext.define('Compass.ErpApp.Desktop.Applications.Knitkit.DraggablePanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.knitkitdraggablepanel',
    cls: "draggableImages",
    header: false,
    initComponent: function() {
        var me = this;
        me.on('render', function() {
            me.dragZone = Ext.create('Ext.dd.DragZone', me.getEl(), {
                ddGroup: 'websiteBuilderPanelDDgroup',
                getDragData: function(e) {
                    var target = e.getTarget('.draggable-image-display');
                    if (target) {
                        var element = Ext.getCmp(target.id),
                            dragEl = element.getEl(),
                            d = dragEl.dom.cloneNode(true);
                        d.id = Ext.id();

                        return {
                            panelConfig: element.initialConfig,
                            panelId: element.id,
                            repairXY: element.getEl().getXY(),
                            ddel: d,
                            componentId: element.componentId
                        };
                    }
                },

                getRepairXY: function() {
                    return this.dragData.repairXY;
                }
            });
        });

        me.callParent();
    }

});

Ext.define('Compass.ErpApp.Desktop.Applications.Knitkit.AccordianComponentPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.knitkitaccordiancomponentpanel',
    autoScroll: true,
    items: []
});

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

        Ext.Ajax.request({
            method: "GET",
            url: '/api/v1/website_builder/components.json',
            success: function(response) {
                var responseObj = Ext.decode(response.responseText);

                if (responseObj.success) {
                    var components = responseObj.components;
                    for (var component in components) {
                        if (components.hasOwnProperty(component)) {
                            accordianComponentPanel = me.add({
                                xtype: 'knitkitaccordiancomponentpanel',
                                title: Ext.String.capitalize(component) + ' Blocks'
                            });

                            accordianComponentPanel.add({
                                xtype: 'knitkitdraggablepanel',
                                items: me.getThumbnailPanelArray(components[component])
                            })
                        }
                    }
                }
            },
            failure: function() {
                // TODO: Could not load message count, should we display an error?
            }
        });


        me.dockedItems = [{
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

        me.callParent(arguments);
    },

    getThumbnailPanelArray: function(components) {
        return Ext.Array.map(components, function(data) {
            return {
                xtype: 'panel',
                cls: 'draggable-image-display',
                layout: 'fit',
                autoScroll: true,
                componentId: data.iid,
                componentHeight: data.height,
                html: '<img src="' + data.thumbnail + '"></img>'
            };
        });
    },

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
