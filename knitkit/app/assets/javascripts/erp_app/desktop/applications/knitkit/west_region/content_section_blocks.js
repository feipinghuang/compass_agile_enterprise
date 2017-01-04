Ext.define('Compass.ErpApp.Desktop.Applications.Knitkit.WestRegion.ContentSectionBlocks', {
    extend: "Ext.panel.Panel",
    alias: 'widget.knitkitcontentsectionblock',
    cls: "draggableImages",
    items: [],
    initComponent: function() {
        var me = this;
        Ext.Ajax.request({
            method: "GET",
            url: '/api/v1/website_builder/content_section_data.json',
            success: function(response) {
                var responseObj = Ext.decode(response.responseText);

                if (responseObj.success) {
                    Ext.each(responseObj.srcs, function(data) {
                        me.add({
                            xtype: 'panel',
                            cls: 'draggable-image-display',
                            layout: 'fit',
                            autoScroll: true,
                            componentId: data.iid,
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
