Ext.define('Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion.FooterBlocks', {
    extend: "Ext.panel.Panel",
    alias: 'widget.knitkitfooterblock',
    dataObjects: [{
        src: '/website_builder/footer1.png',
        id: 'footer1'
    }, {
        src: '/website_builder/footer2.png',
        id: 'footer2'
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
                componentType: 'footer',
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
                        var element = Ext.getCmp(target.id);

                        var dragEl = element.getEl(); //document.createElement('div');
                        var height = element.getEl().getHeight(),
                            width = element.getEl().getWidth();

                        var d = dragEl.dom.cloneNode(true);
                        d.id = Ext.id();

                        Ext.fly(dragEl).setWidth(width);
                        Ext.fly(dragEl).setHeight(height);

                        return {
                            panelConfig: element.initialConfig,
                            panelId: element.id,
                            repairXY: element.getEl().getXY(),
                            ddel: d, //dragEl,
                            componentType: element.componentType,
                            componentId: element.imgId
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
