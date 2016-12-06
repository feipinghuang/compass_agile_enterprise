Ext.define('Compass.ErpApp.Desktop.Applications.ApplicationManagement.ReorderableDropZone', {
    extend: 'Ext.Component',
    alias: 'widget.reorderabledropzone',

    lastDropZone: false,
    cls: 'reorderableDropZone',
    height: '1px',
    listeners: {
        render: function(comp) {
            if (comp.lastDropZone) {
                comp.el.setStyle('height', '25px');
                comp.el.setStyle('marginBottom', '5px');
            }
        }
    }
});


Ext.define('Compass.ErpApp.Shared.ReOrderablePanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.reorderablepanel',
    title: "Drag Drop panel",
    autoScroll: true,
    items: [],
    initComponent: function() {
        var me = this;

        me.on('render', function() {
            me.dragZone = Ext.create('Ext.dd.DragZone', me.getEl(), {
                ddGroup: 'reorderablePanelDDgroup',
                getDragData: function(e) {
                    var target = e.getTarget('.reorderable-component-panel');

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
                            ddel: d //dragEl
                        };
                    }
                },

                getRepairXY: function() {
                    return this.dragData.repairXY;
                }
            });
            me.dropZone = Ext.create('Ext.dd.DropZone', me.getEl(), {
                ddGroup: 'reorderablePanelDDgroup',
                getTargetFromEvent(e) {
                    return e.getTarget('.reorderableDropZone');
                },

                // On entry into a target node, highlight that node.
                onNodeEnter: function(target, dd, e, dragData) {
                    if (this.validDrop(target, dragData)) {
                        var dropComponent = Ext.getCmp(target.id);
                        if (dropComponent) {
                            Ext.fly(target).addCls('application-management-move-field-hover');
                        }
                    } else {
                        return Ext.dd.DropZone.prototype.dropNotAllowed;
                    }
                },

                // On exit from a target node, unhighlight that node.
                onNodeOut: function(target, dd, e, dragData) {
                    if (target) {
                        var dropComponent = Ext.getCmp(target.id);
                        if (dropComponent) {
                            Ext.fly(target).removeCls('application-management-move-field-hover');
                        }
                    }
                },

                onNodeDrop: function(target, dd, e, data) {
                    if (this.validDrop(target, data)) {
                        var row = parseInt(target.attributes['data-row'].value),
                            indexToDrop = (row == 0) ? 0 : row - 1,
                            panel = Ext.getCmp(data.panelId),
                            containerPanel = Ext.ComponentQuery.query('reorderablepanel').first();

                        Ext.Ajax.request({
                            method: "GET",
                            url: '/api/v1/website_builder/get_' + data.componentType + '_dom_url.json',
                            params: {
                                id: data.componentId
                            },
                            success: function(response) {
                                var responseObj = Ext.decode(response.responseText);

                                if (responseObj.success) {
                                    debugger;
                                    containerPanel.removeFieldDropZones();
                                    containerPanel.insert(indexToDrop, {
                                        xtype: 'panel',
                                        cls: "reorderable-component-panel",
                                        layout: 'fit',
                                        height: data.componentHeight,
                                        html: '<iframe height="100%" width="100%" frameBorder="0" src="' + responseObj.html_src + '"></iframe>'
                                    });
                                    containerPanel.remove(panel);
                                    containerPanel.addFieldDropZones();
                                    containerPanel.updateLayout();
                                }
                            },
                            failure: function() {
                                // TODO: Could not load message count, should we display an error?
                            }
                        });

                    }
                },

                onNodeOver: function(target, dd, e, data) {
                    if (this.validDrop(target, data)) {
                        return Ext.dd.DropZone.prototype.dropAllowed;
                    } else {
                        return Ext.dd.DropZone.prototype.dropNotAllowed;
                    }
                },

                validDrop: function(target, dragData) {
                    return true;
                }

            });

            me.addFieldDropZones();
        });
        me.callParent();
    },

    removeFieldDropZones: function() {
        var me = this;
        me.suspendLayout = true;
        Ext.each(me.query('reorderabledropzone'), function(dropZone) {
            // remove the drop zones
            dropZone.destroy();
        });
        me.suspendLayout = false;
        me.doLayout();
    },

    addFieldDropZones: function() {
        var me = this,
            rowIndex = 0,
            itemCount = me.items.items.length;

        me.suspendLayout = true;
        if (itemCount === 0) {
            me.insert(0, {
                xtype: 'reorderabledropzone',
                lastDropZone: true,
                autoEl: {
                    tag: 'div',
                    'data-row': 0
                }
            });
        } else {
            var lastIndex = (me.items.length - 1);

            for (var i = 0; i < itemCount; i++) {
                if (i === 0) {
                    me.insert(0, {
                        xtype: 'reorderabledropzone',
                        autoEl: {
                            tag: 'div',
                            'data-row': 0
                        }
                    });
                }

                rowIndex += 2;

                me.insert(rowIndex, {
                    xtype: 'reorderabledropzone',
                    lastDropZone: (i == lastIndex),
                    autoEl: {
                        tag: 'div',
                        'data-row': rowIndex
                    }
                });
            }
        }
        me.suspendLayout = false;
        me.doLayout();
    },

});
