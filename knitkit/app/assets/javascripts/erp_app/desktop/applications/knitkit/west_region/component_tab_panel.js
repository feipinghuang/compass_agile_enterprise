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

        me.callParent(arguments);
    },

    getThumbnailPanelArray: function(components) {
        return Ext.Array.map(components, function(data) {
            var html = '<div style="border: 1px solid #ececec;font-weight:bold">' + data.title + '</div>';
            if (data.thumbnail) {
                html = '<img src="' + data.thumbnail + '"></img>';
            }

            return {
                xtype: 'panel',
                cls: 'draggable-image-display',
                layout: 'fit',
                autoScroll: true,
                componentId: data.iid,
                componentHeight: data.height,
                html: html
            };
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
