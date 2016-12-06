Ext.define('Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion.HeaderBlocks', {
    extend: "Ext.panel.Panel",
    alias: 'widget.knitkitheaderblock',
    dataObjects: [{
        src: '/website_builder/header1.png',
        id: 'header1',
        height: 480
    }, {
        src: '/website_builder/header2.png',
        id: 'header2',
        height: 498
    }],
    cls: "draggableImages",
    items: [],
    initComponent: function() {
        var me = this;

        Ext.each(me.dataObjects, function(data) {
            me.items.push({
                xtype: 'panel',
                cls: 'draggable-image-display',
                layout: 'fit',
                autoScroll: true,
                componentType: 'header',
                imgId: data.id,
                html: '<img src="' + data.src + '"></img>'
            });
        });
        me.on('render', function() {
            me.dragZone = Ext.create('Ext.dd.DragZone', me.getEl(), {
                ddGroup: 'reorderablePanelDDgroup',
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
                            componentType: element.componentType,
                            componentId: element.imgId,
                            componentHeight: element.height
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
