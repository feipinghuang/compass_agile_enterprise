Ext.define('Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion.FooterBlocks', {
    extend: "Ext.panel.Panel",
    alias: 'widget.knitkitfooterblock',
    cls: "draggableImages",
    items: [],
    initComponent: function() {
        var me = this;
        Ext.Ajax.request({
            method: "GET",
            url: '/api/v1/website_builder/footers.json',
            success: function(response) {
                var responseObj = Ext.decode(response.responseText);

                if (responseObj.success) {
                    Ext.each(responseObj.srcs, function(data) {
                        me.add({
                            xtype: 'panel',
                            cls: 'draggable-image-display',
                            layout: 'fit',
                            autoScroll: true,
                            componentType: 'footer',
                            imgId: data.id,
                            componentHeight: data.height,
                            html: '<img src="' + data.img_src + '"></img>'
                        });
                    });
                }
            },
            failure: function() {
                // TODO: Could not load message count, should we display an error?
            }
        });

        me.on('render', function() {
            me.dragZone = Ext.create('Ext.dd.DragZone', me.getEl(), {
                ddGroup: 'websiteBuilderPanelDDgroup',
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
