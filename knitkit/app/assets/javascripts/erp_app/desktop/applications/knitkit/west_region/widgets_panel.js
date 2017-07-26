Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.WidgetsPanel", {
    extend: "Ext.panel.Panel",
    alias: 'widget.knitkit_WidgetsPanel',

    constructor: function(config) {
        var widgetsStore = Ext.create('Ext.data.Store', {
            autoDestroy: true,
            fields: ['name', 'iconUrl', 'addWidget', 'about'],
            data: Compass.ErpApp.Widgets.AvailableWidgets
        });

        this.widgetsDataView = Ext.create("Ext.view.View", {
            style: 'overflow:auto',
            itemSelector: 'div.thumb-wrap',
            store: widgetsStore,
            tpl: [
                '<tpl for=".">',
                '<div data-qtip="{about}" class="thumb-wrap" id="{name}">',
                '<div class="thumb"><img src="{iconUrl}" class="thumb-img"></div>',
                '<span>{name}</span></div>',
                '</tpl>',
                '<div class="x-clear"></div>'
            ],
            listeners: {
                itemcontextmenu: function(view, record, htmlitem, index, e, options) {
                    e.stopEvent();
                    var contextMenu = Ext.create("Ext.menu.Menu", {
                        items: [{
                            text: 'Add Widget',
                            iconCls: 'icon-add',
                            handler: function(btn) {
                                record.data.addWidget({
                                    websiteBuilder: false,
                                    success: function(content) {
                                        //add rendered template to center region editor
                                        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror(content);
                                    }
                                });
                            }
                        }]
                    });
                    contextMenu.showAt(e.xy);
                },

                render: function(dataView) {
                    new Ext.dd.DragZone(dataView.getEl(), {
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
                            var sourceEl = e.getTarget(dataView.itemSelector, 10);

                            if (sourceEl) {
                                d = sourceEl.cloneNode(true);
                                d.id = Ext.id();

                                var draggedRecord = dataView.getRecord(sourceEl);

                                return {
                                    ddel: d,
                                    sourceEl: sourceEl,
                                    repairXY: Ext.fly(sourceEl).getXY(),
                                    sourceStore: dataView.store,
                                    widgetName: draggedRecord.get('name'),
                                    componentType: 'widget'
                                };
                            }
                        },

                        getRepairXY: function() {
                            return this.dragData.repairXY;
                        }
                    });
                }
            }
        });

        config = Ext.apply({
            id: 'widgets',
            autoDestroy: true,
            margins: '5 5 5 0',
            layout: 'fit',
            items: this.widgetsDataView
        }, config);

        this.callParent([config]);
    },

    getWidgetData: function(widgetName) {
        var me = this;
        store = me.widgetsDataView.getStore();
        return store.findRecord('name', widgetName).data;
    }
});