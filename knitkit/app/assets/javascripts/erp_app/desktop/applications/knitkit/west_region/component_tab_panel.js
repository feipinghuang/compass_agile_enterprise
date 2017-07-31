Ext.define('Compass.ErpApp.Desktop.Applications.Knitkit.DraggablePanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.knitkitdraggablepanel',
    cls: "draggable-images",
    header: false,
    initComponent: function() {
        var me = this;
        me.on('render', function() {
            me.dragZone = Ext.create('Ext.dd.DragZone', me.getEl(), {
                ddGroup: 'websiteBuilderPanelDDgroup',
                // Let the native drag and drop work for widgets
                onBeforeDrag: function(data, e) {
                    var centerRegion = Ext.getCmp('knitkit').down('knitkit_centerregion');
                    if (centerRegion.workArea.getActiveTab() && centerRegion.workArea.getActiveTab().xtype == "websitebuilderpanel")
                        centerRegion.workArea.getActiveTab().disableComponents();

                    return true;
                },

                afterDragDrop: function(target, e, id) {
                    var centerRegion = Ext.getCmp('knitkit').down('knitkit_centerregion');
                    if (centerRegion.workArea.getActiveTab() && centerRegion.workArea.getActiveTab().xtype == "websitebuilderpanel")
                        centerRegion.workArea.getActiveTab().enableComponents();
                },

                afterInvalidDrop: function(target, e, id) {
                    var centerRegion = Ext.getCmp('knitkit').down('knitkit_centerregion');
                    if (centerRegion.workArea.getActiveTab() && centerRegion.workArea.getActiveTab().xtype == "websitebuilderpanel")
                        centerRegion.workArea.getActiveTab().enableComponents();
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
                            componentName: element.componentName,
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

    module: null,
    isTheme: false,

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
            params: {
                is_theme: me.isTheme,
                id: me.module.currentWebsite.id,
            },
            success: function(responseObj) {
                var components = responseObj.components;

                // clear any current accordions
                me.removeAll(true);

                if (me.isTheme) {
                    componentsObj = {header: [], footer: []};
                } else {
                    componentsObj = {content: []};
                }
                
                Ext.each(components, function(component) {
                    componentsObj[component.type].push(component);
                });

                Ext.Object.each(componentsObj, function(componentType){
                    var accordianComponentPanel = me.add({
                        xtype: 'knitkitaccordiancomponentpanel',
                        title: componentType == 'content' ? 'Content Blocks' : componentType.capitalize().pluralize()
                    });
                    
                    accordianComponentPanel.add({
                        xtype: 'knitkitdraggablepanel',
                        items: me.getThumbnailPanelArray(componentsObj[componentType])
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

    getThumbnailPanelArray: function(components) {
        return Ext.Array.map(components, function(data) {
            return {
                xtype: 'panel',
                cls: 'draggable-image-display',
                layout: 'fit',
                autoScroll: true,
                componentName: data.name,
                componentType: data.type,
                html: '<img style="height:89px;width:100%;" src="' + data.thumbnail_url + '"></img>'
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
