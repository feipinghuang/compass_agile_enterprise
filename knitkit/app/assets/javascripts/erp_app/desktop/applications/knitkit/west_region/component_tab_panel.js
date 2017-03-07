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
                    if(data.componentType == "widget") {
                        return false;
                    } else {
                        return true;
                    }
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

        Ext.Ajax.request({
            method: "GET",
            url: '/knitkit/erp_app/desktop/website_builder/components.json',
            success: function(response) {
                var responseObj = Ext.decode(response.responseText);

                if (responseObj.success) {
                    var components = responseObj.components;
                    for (var component in components) {
                        if (components.hasOwnProperty(component)) {
                            var accordianComponentPanel = me.add({
                                xtype: 'knitkitaccordiancomponentpanel',
                                title: Ext.String.capitalize(component) + ' Blocks'
                            });

                            
                            accordianComponentPanel.add({
                                xtype: 'knitkitdraggablepanel',
                                items: me.getThumbnailPanelArray(components[component])
                            });
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

            var config = {
                xtype: 'panel',
                cls: 'draggable-image-display',
                layout: 'fit',
                autoScroll: true,
                componentId: data.iid,
                componentType: data.componentType,
                componentHeight: data.height,
                html: html
            };
            // if this is a widget then attach drag listeners to make it droppable in an iframe
            if(data.componentType == 'widget') {
                Ext.apply(config,{
                    listeners: {
                        render: function(me) {
                            var elem = document.getElementById(me.id);
                            elem.setAttribute('draggable', true);

                            jQuery(elem).on('dragstart', function(event) {
                                console.log("Drag Started");
                                me.dragoverqueue_processtimer = setInterval(function() {
                                    DragDropFunctions.ProcessDragOverQueue();
                                }, 100);

                                // widgets component IID would be used to set retrive its Source in the iFrame
                                event.originalEvent.dataTransfer.setData("componentIid", me.componentId);
                            });
                            jQuery(elem).on('dragend', function() {
                                console.log("Drag End");
                                // clearInterval(me.dragoverqueue_processtimer);
                                // DragDropFunctions.removePlaceholder();
                                // DragDropFunctions.ClearContainerContext();
                            });
                            
                        }
                    }
                });
            }
            
            return config;
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
