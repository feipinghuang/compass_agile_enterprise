Ext.define('Compass.ErpApp.Desktop.Applications.ApplicationManagement.WebsiteBuilderDropZone', {
    extend: 'Ext.Component',
    alias: 'widget.websitebuilderdropzone',
    lastDropZone: false,
    cls: 'websiteBuilderDropZone',
    listeners: {
        render: function(comp) {
            comp.lastDropZone ? comp.el.setStyle('height', '25px') : comp.el.setStyle('height', '10px');
            comp.el.setStyle('marginBottom', '5px');
        }
    }
});


Ext.define('Compass.ErpApp.Shared.WebsiteBuilderPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.websitebuilderpanel',
    title: "Website Builder",
    autoScroll: true,
    items: [],
    initComponent: function() {
        var me = this;

        me.on('render', function() {
            me.dragZone = Ext.create('Ext.dd.DragZone', me.getEl(), {
                ddGroup: 'websiteBuilderPanelDDgroup',
                getDragData: function(e) {
                    var target = e.getTarget('.websitebuilder-component-panel');

                    if (target) {
                        var element = Ext.getCmp(target.id),
                            dragEl = element.getEl(),
                            height = element.getEl().getHeight(),
                            width = element.getEl().getWidth(),
                            d = dragEl.dom.cloneNode(true);
                        d.id = Ext.id();
                        Ext.fly(d).setHTML('<img src="' + element.imgSrc + '" style="width:186px;height:80px">');
                        Ext.fly(d).setWidth(186);
                        Ext.fly(d).setHeight(80);

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
            me.dropZone = Ext.create('Ext.dd.DropZone', me.getEl(), {
                ddGroup: 'websiteBuilderPanelDDgroup',
                getTargetFromEvent(e) {
                    return e.getTarget('.websiteBuilderDropZone');
                },

                // On entry into a target node, highlight that node.
                onNodeEnter: function(target, dd, e, dragData) {
                    if (this.validDrop(target, dragData)) {
                        var dropComponent = Ext.getCmp(target.id);
                        if (dropComponent) {
                            Ext.fly(target).addCls('website-builder-move-component-hover');
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
                            Ext.fly(target).removeCls('website-builder-move-component-hover');
                        }
                    }
                },

                onNodeDrop: function(target, dd, e, data) {
                    if (this.validDrop(target, data)) {
                        var indexToDrop = parseInt(target.attributes['data-row'].value),
                            panel = Ext.getCmp(data.panelId),
                            containerPanel = Ext.ComponentQuery.query('websitebuilderpanel').first();
                        Ext.Ajax.request({
                            method: "GET",
                            url: '/api/v1/website_builder/get_component.json',
                            params: {
                                id: data.componentId
                            },
                            success: function(response) {
                                var responseObj = Ext.decode(response.responseText);

                                if (responseObj.success) {
                                    var responseData = responseObj.data
                                    containerPanel.insert(indexToDrop, {
                                        xtype: 'panel',
                                        cls: "websitebuilder-component-panel",
                                        layout: 'fit',
                                        height: responseData.height,
                                        imgSrc: responseData.thumbnail,
                                        componentId: responseData.iid,
                                        listeners: {
                                            render: function(panel) {
                                                // assigning click event to remove icon
                                                panel.update(new Ext.XTemplate('<div class="website-builder-reorder-setting" id="componentSetting"><div class="icon-move pull-left" style="margin-right:5px;"></div><div class="icon-remove pull-left" id="{panelId}-remove" itemId="{panelId}"></div></div><div style="height: 100%" id="iframeDiv"><iframe height="100%" width="100%" frameBorder="0" id="{panelId}-frame" src="{htmlSrc}"></iframe></div>').apply({
                                                    componetId: responseData.id,
                                                    htmlSrc: responseData.url,
                                                    panelId: panel.id
                                                }));

                                                Ext.get(panel.id + "-remove").on("click", function() {
                                                    panel.destroy();
                                                });

                                                // Assigning click event inside iFrame content
                                                var iframe = Ext.get(panel.id + "-frame");
                                                iframe.on('load', function() {
                                                    editContents = this.el.dom.contentDocument.getElementsByClassName('editContent');
                                                    Ext.Array.each(editContents, function(editContent) {
                                                        editContent.addEventListener('click', function() {
                                                            var propertiesEditForm = Ext.ComponentQuery.query("knitkitcomponentpropertiesformpanel").first(),
                                                                eastRegionPanel = propertiesEditForm.up('knitkit_eastregion'),
                                                                tabpanel = propertiesEditForm.up('tabpanel');
                                                            eastRegionPanel.expand();
                                                            tabpanel.setActiveTab(propertiesEditForm);
                                                            propertiesEditForm.removeAll();
                                                            propertiesEditForm.add({
                                                                xtype: 'label',
                                                                forId: 'myFieldId',
                                                                text: this.tagName + " editable element clicked",
                                                                margin: '20 0 0 10'
                                                            });
                                                            propertiesEditForm.down('#componentPropertiessaveButton').show();
                                                            propertiesEditForm.down('#componentPropertiesAdvanceEdit').show();
                                                        });
                                                    });
                                                });
                                            }
                                        }
                                    });

                                    containerPanel.removeFieldDropZones();
                                    containerPanel.remove(panel);
                                    containerPanel.addFieldDropZones();
                                    containerPanel.updateLayout();
                                }
                            },
                            failure: function() {
                                // TODO: Could not able to drop component, should we display an error?
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
        Ext.each(me.query('websitebuilderdropzone'), function(dropZone) {
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
                xtype: 'websitebuilderdropzone',
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
                        xtype: 'websitebuilderdropzone',
                        autoEl: {
                            tag: 'div',
                            'data-row': 0
                        }
                    });
                }

                rowIndex += 2;

                me.insert(rowIndex, {
                    xtype: 'websitebuilderdropzone',
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
