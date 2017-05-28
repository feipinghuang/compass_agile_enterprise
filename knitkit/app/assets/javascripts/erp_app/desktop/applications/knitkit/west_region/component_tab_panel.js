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
                // Let the native drag and drop work for widgets
                onBeforeDrag: function(data, e) {
                    if (data.componentType == "widget") {
                        return false;
                    } else {

                        Ext.getCmp('knitkit').down('websitebuilderpanel').disableComponents();

                        return true;
                    }
                },
                afterDragDrop: function(target, e, id) {
                    Ext.getCmp('knitkit').down('websitebuilderpanel').enableComponents();
                },
                afterInvalidDrop: function(target, e, id) {
                    Ext.getCmp('knitkit').down('websitebuilderpanel').enableComponents();
                },
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
                            componentId: element.componentId,
                            componentType: element.componentType
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

        me.setupComponents().then(function() {
            me.add({
                xtype: 'knitkitaccordiancomponentpanel',
                title: 'Widgets',
                items: [{
                    xtype: 'knitkit_WidgetsPanel'
                }]
            });
        });

        me.callParent(arguments);
    },

    setupComponents: function() {
        var me = this;
        var dfd = Ext.create('Ext.ux.Deferred');
        Compass.ErpApp.Utility.ajaxRequest({
            method: "GET",
            url: '/knitkit/erp_app/desktop/website_builder/components.json',
            success: function(responseObj) {
                var components = responseObj.components;
                Ext.Object.each(components, function(component) {
                    var accordianComponentPanel = me.add({
                        xtype: 'knitkitaccordiancomponentpanel',
                        title: component.humanize().capitalize() + ' Blocks'
                    });
                    accordianComponentPanel.add({
                        xtype: 'knitkitdraggablepanel',
                        items: me.getThumbnailPanelArray(component, components[component])
                    });
                });

                dfd.resolve();
            },
            failure: function() {
                Ext.Msg.alert('Error', 'Error loading components');
                dfd.reject();
            }
        });

        return dfd.promise();
    },

    getThumbnailPanelArray: function(type, components) {
        return Ext.Array.map(components, function(data) {
            var html = '<div style="border: 1px solid #ececec;font-weight:bold">' + data.title + '</div>';

            if (data.thumbnail) {
                if (type == 'footer') {
                    html = '<img src="' + data.thumbnail + '"></img>';
                } else {
                    html = '<img style="height:89px;" src="' + data.thumbnail + '"></img>';
                }
            }

            return {
                xtype: 'panel',
                cls: 'draggable-image-display',
                layout: 'fit',
                autoScroll: true,
                componentId: data.iid,
                componentType: data.componentType,
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