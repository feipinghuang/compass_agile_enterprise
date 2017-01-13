Ext.namespace('Compass.ErpApp.Desktop.Applications.Knitkit.WebsiteBuilder').config = {
    pageContainer: "#page",
    editableItems: {
        'span.fa': ['color', 'font-size'],
        '.bg.bg1': ['background-color'],
        'nav a': ['color', 'font-weight', 'text-transform'],
        'img': ['border-top-left-radius', 'border-top-right-radius', 'border-bottom-left-radius', 'border-bottom-right-radius', 'border-color', 'border-style', 'border-width'],
        'hr.dashed': ['border-color', 'border-width'],
        '.divider > span': ['color', 'font-size'],
        'hr.shadowDown': ['margin-top', 'margin-bottom'],
        '.footer a': ['color'],
        '.social a': ['color'],
        '.bg.bg1, .bg.bg2, .header10, .header11': ['background-image', 'background-color'],
        '.frameCover': [],
        '.editContent': ['content', 'color', 'font-size', 'background-color', 'font-family'],
        'a.btn, button.btn': ['border-radius', 'font-size', 'background-color'],
        '#pricing_table2 .pricing2 .bottom li': ['content']
    },
    editableItemOptions: {
        'nav a : font-weight': ['400', '700'],
        'a.btn, button.btn : border-radius': ['0px', '4px', '10px'],
        'img : border-style': ['none', 'dotted', 'dashed', 'solid'],
        'img : border-width': ['1px', '2px', '3px', '4px'],
        'h1, h2, h3, h4, h5, p : font-family': ['default', 'Lato', 'Helvetica', 'Arial', 'Times New Roman'],
        'h2 : font-family': ['default', 'Lato', 'Helvetica', 'Arial', 'Times New Roman'],
        'h3 : font-family': ['default', 'Lato', 'Helvetica', 'Arial', 'Times New Roman'],
        'p : font-family': ['default', 'Lato', 'Helvetica', 'Arial', 'Times New Roman'],
    },
    inlineEditableSettings: [{
        'attrName': 'contenteditable',
        'attrValue': 'true'
    }, {
        'attrName': 'spellcheck',
        'attrValue': 'true'
    }, {
        'attrName': 'data-medium-editor-element',
        'attrValue': 'true'
    }, {
        'attrName': 'role',
        'attrValue': 'textbox'
    }, {
        'attrName': 'medium-editor-index',
        'attrValue': '0'
    }, {
        'attrName': 'data-placeholder',
        'attrValue': 'Type your text'
    }, {
        'attrName': 'data-medium-focused',
        'attrValue': 'true'
    }],
    responsiveModes: {
        desktop: '97%',
        mobile: '480px',
        tablet: '1024px'
    },
    mediumCssUrls: [
        '//cdn.jsdelivr.net/medium-editor/latest/css/medium-editor.min.css',
        '../css/medium-bootstrap.css'
    ],
    mediumButtons: ['bold', 'italic', 'underline', 'anchor', 'orderedlist', 'unorderedlist', 'h1', 'h2', 'h3', 'h4', 'removeFormat'],
    externalJS: [
        'js/builder_in_block.js'
    ]
};

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
                getTargetFromEvent: function(e) {
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
                                                    var iframePanel = this,
                                                        editContents = this.el.dom.contentDocument.documentElement.querySelectorAll("[data-selector]");
                                                    Ext.Array.each(editContents, function(editContent) {
                                                        editContent.addEventListener('mouseover', function(event) {
                                                            if (!editContent.isContentEditable) {
                                                                me.hightlightElement(editContent);
                                                            }
                                                        });
                                                        editContent.addEventListener('mouseout', function(event) {
                                                            if (!editContent.isContentEditable) {
                                                                me.deHightlightElement(editContent);
                                                            }
                                                        });
                                                        editContent.addEventListener('click', function(event) {
                                                            if (!editContent.isContentEditable) {
                                                                event.preventDefault();
                                                                contentEditableElements = iframePanel.el.dom.contentDocument.documentElement.querySelectorAll("[contenteditable]");
                                                                Ext.Array.each(contentEditableElements, function(element) {
                                                                    me.removeEditable(element)
                                                                })
                                                                me.buildPropertiesEditForm(this);
                                                            }
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

    makeEditable: function(element) {
        var websiteBuilderEditConfig = Compass.ErpApp.Desktop.Applications.Knitkit.WebsiteBuilder.config;
        Ext.Array.each(websiteBuilderEditConfig.inlineEditableSettings, function(setting) {
            element.setAttribute(setting.attrName, setting.attrValue);
        });
    },

    removeEditable: function(element) {
        var websiteBuilderEditConfig = Compass.ErpApp.Desktop.Applications.Knitkit.WebsiteBuilder.config;
        Ext.Array.each(websiteBuilderEditConfig.inlineEditableSettings, function(setting) {
            element.removeAttribute(setting.attrName, setting.attrValue);
        });
        this.deHightlightElement(element);
    },

    hightlightElement: function(element) {
        element.style.outline = 'rgba(233, 94, 94, 0.498039) solid 2px';
        element.style['outline-offset'] = '-2px';
        element.cursor = 'pointer';
    },

    deHightlightElement: function(element) {
        element.style.outline = 'none';
        element.style['outline-offset'] = '0px';
        element.cursor = 'pointer';
    },

    buildPropertiesEditForm: function(element) {
        var me = this,
            dataSelector = element.getAttribute('data-selector'),
            websiteBuilderEditConfig = Compass.ErpApp.Desktop.Applications.Knitkit.WebsiteBuilder.config,
            editableItems = websiteBuilderEditConfig.editableItems[dataSelector],
            propertiesEditFormPanel = Ext.ComponentQuery.query("knitkitcomponentpropertiesformpanel").first(),
            eastRegionPanel = propertiesEditFormPanel.up('knitkit_eastregion'),
            tabpanel = propertiesEditFormPanel.up('tabpanel');
        eastRegionPanel.expand();
        tabpanel.setActiveTab(propertiesEditFormPanel);
        propertiesEditFormPanel.removeAll();
        propertiesEditFormPanel.element = element;
        propertiesEditFormPanel.editableItems = editableItems;
        propertiesEditFormPanel.add({
            xtype: 'label',
            text: "Editing " + dataSelector,
            cls: 'website-builder-form-header',
            margin: '5  0 20 0'
        });
        if (dataSelector == '.editContent') {
            me.makeEditable(element);
        }

        Ext.Array.each(editableItems, function(editableAttr) {
            options = websiteBuilderEditConfig.editableItemOptions[dataSelector + " : " + editableAttr];
            data = Ext.String.trim(editableAttr == 'content' ? element.innerHTML : window.getComputedStyle(element).getPropertyValue(editableAttr));
            if (Ext.isDefined(options)) {
                propertiesEditFormPanel.add({
                    xtype: "combo",
                    name: editableAttr,
                    queryMode: 'local',
                    store: options,
                    fieldLabel: Ext.String.capitalize(editableAttr),
                    value: data
                });
            } else {
                if (editableAttr != 'content') {
                    if (editableAttr.includes('color')) {
                        propertiesEditFormPanel.add([{
                            layout: 'vbox',
                            items: [{
                                xtype: 'hiddenfield',
                                name: editableAttr,
                                itemId: editableAttr + "-color"
                            }, {
                                xtype: 'label',
                                forId: editableAttr,
                                text: Ext.String.capitalize(editableAttr) + ":"
                            }, {
                                xtype: 'colorpicker',
                                listeners: {
                                    select: function(picker, selColor) {
                                        propertiesEditForm = propertiesEditFormPanel.getForm();
                                        hiddenField = propertiesEditForm.findField(editableAttr);
                                        hiddenField.setValue('#' + selColor);
                                    }
                                }
                            }]
                        }]);
                    } else {
                        propertiesEditFormPanel.add({
                            xtype: 'textfield',
                            name: editableAttr,
                            fieldLabel: Ext.String.capitalize(editableAttr),
                            value: data,
                            allowBlank: false
                        });
                    }
                }
            }
        })
        propertiesEditFormPanel.down('#componentPropertiesSaveButton').show();
        propertiesEditFormPanel.down('#componentPropertiesResetButton').show();

    },

    convertRgbToHex: function(rgbColorString) {
        // var [r, g, b] = rgbColorString.match(/\d+/g);
        // return this.componentToHex(r) + this.componentToHex(g) + this.componentToHex(b);
    },
    componentToHex: function(data) {
        var hex = data.toString(16);
        return hex.length == 1 ? "0" + hex : hex;
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
