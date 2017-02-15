Ext.define('Compass.ErpApp.Desktop.Applications.ApplicationManagement.WebsiteBuilderDropZone', {
    extend: 'Ext.Component',
    alias: 'widget.websitebuilderdropzone',
    lastDropZone: false,
    componentId: null,
    cls: 'website-builder-dropzone',
    height: 150,
    html: '<div>Drop Component Here</div>'
});


Ext.define('Compass.ErpApp.Shared.WebsiteBuilderPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.websitebuilderpanel',
    title: "Website Builder",
    autoScroll: true,
    themeId: null,
    items: [],
    initComponent: function() {
        var me = this;

        if (!me.themeId) {
            me.dockedItems = [{
                xtype: 'toolbar',
                items: [{
                    text: 'Add Row',
                    iconCls: 'icon-add',
                    handler: function(btn) {
                        var me = btn.up('websitebuilderpanel');

                        Ext.widget('window', {
                            title: 'Add Row',
                            buttonAlign: 'center',
                            items: [{
                                bodyPadding: '5px',
                                xtype: 'container',
                                layout: 'hbox',
                                items: [{
                                    xtype: 'container',
                                    layout: 'vbox',
                                    align: 'center',
                                    items: [{
                                        xtype: 'label',
                                        text: 'One Column',
                                        width: 100,
                                        style: {
                                            textAlign: 'center'
                                        }
                                    }, {
                                        xtype: 'image',
                                        src: '/website_builder/page_layouts/one_col.png',
                                        height: 100,
                                        width: 100,
                                        style: {
                                            padding: '5px'
                                        }
                                    }, {
                                        xtype: 'radio',
                                        height: 50,
                                        width: 100,
                                        itemId: 'oneCol',
                                        checked: true,
                                        name: 'cols',
                                        style: {
                                            textAlign: 'center'
                                        }
                                    }]
                                }, {
                                    xtype: 'container',
                                    layout: 'vbox',
                                    align: 'center',
                                    items: [{
                                        xtype: 'label',
                                        text: 'Two Column',
                                        width: 100,
                                        style: {
                                            textAlign: 'center'
                                        }
                                    }, {
                                        xtype: 'image',
                                        src: '/website_builder/page_layouts/two_col.png',
                                        height: 100,
                                        width: 100,
                                        style: {
                                            padding: '5px'
                                        }
                                    }, {
                                        xtype: 'radio',
                                        height: 50,
                                        width: 100,
                                        itemId: 'twoCol',
                                        name: 'cols',
                                        style: {
                                            textAlign: 'center'
                                        }
                                    }]
                                }, {
                                    xtype: 'container',
                                    layout: 'vbox',
                                    align: 'center',
                                    items: [{
                                        xtype: 'label',
                                        text: 'Three Column',
                                        width: 100,
                                        style: {
                                            textAlign: 'center'
                                        }
                                    }, {
                                        xtype: 'image',
                                        src: '/website_builder/page_layouts/three_col.png',
                                        height: 100,
                                        width: 100,
                                        style: {
                                            padding: '5px'
                                        }
                                    }, {
                                        xtype: 'radio',
                                        height: 50,
                                        width: 100,
                                        itemId: 'threeCol',
                                        name: 'cols',
                                        style: {
                                            textAlign: 'center'
                                        }
                                    }]
                                }]
                            }],
                            buttons: [{
                                text: 'Select',
                                handler: function(btn) {
                                    var win = btn.up('window')
                                    indexToInsert = me.items.getCount() - 1;

                                    if (win.down('#oneCol').getValue()) {
                                        me.insert(indexToInsert, {
                                            xtype: 'websitebuilderdropzone',
                                            flex: 1

                                        });
                                    }

                                    if (win.down('#twoCol').getValue()) {
                                        me.insert(indexToInsert, {
                                            xtype: 'container',
                                            layout: 'hbox',
                                            items: [{
                                                xtype: 'websitebuilderdropzone',
                                                flex: 1

                                            }, {
                                                xtype: 'websitebuilderdropzone',
                                                flex: 1

                                            }]
                                        });
                                    }

                                    if (win.down('#threeCol').getValue()) {
                                        me.insert(indexToInsert, {
                                            xtype: 'container',
                                            layout: 'hbox',
                                            items: [{
                                                xtype: 'websitebuilderdropzone',
                                                flex: 1

                                            }, {
                                                xtype: 'websitebuilderdropzone',
                                                flex: 1

                                            }, {
                                                xtype: 'websitebuilderdropzone',
                                                flex: 1

                                            }]
                                        });
                                    }

                                    win.close();
                                }
                            }, {
                                text: 'Cancel',
                                handler: function(btn) {
                                    btn.up('window').close();
                                }
                            }],
                        }).show();
                    }
                }]
            }];
        }

        me.on('beforerender', function() {
            me.setWebsiteTheme();
        });

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
                    return e.getTarget('.website-builder-dropzone');
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
                        var panel = Ext.getCmp(data.panelId),
                            containerPanel = Ext.ComponentQuery.query('websitebuilderpanel').first();

                        var dropPanel = Ext.getCmp(Ext.fly(target).dom.id);

                        Ext.Ajax.request({
                            method: "GET",
                            url: '/api/v1/website_builder/get_component.json',
                            params: {
                                id: data.componentId
                            },
                            success: function(response) {
                                var responseObj = Ext.decode(response.responseText);

                                if (responseObj.success) {
                                    var responseData = responseObj.data;

                                    me.replaceDropPanelWithContent(dropPanel, responseData.iid, responseData.height);

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

    replaceDropPanelWithContent: function(dropPanel, componentIid, height) {
        var me = this;
        var websitesCombo = Ext.ComponentQuery.query("websitescombo").first();
        var websiteId = websitesCombo.getValue();
        var containerPanel = Ext.ComponentQuery.query('websitebuilderpanel').first();

        dropPanel.removeCls('website-builder-dropzone');

        Ext.apply(dropPanel, {
            cls: "websitebuilder-component-panel"
        });

        dropPanel.update(new Ext.XTemplate('<div style="height:100%;width:100%;position:relative;"><div class="website-builder-reorder-setting" id="componentSetting"><div class="icon-move pull-left" style="margin-right:5px;"></div><div class="icon-remove pull-left" id="{panelId}-remove" itemId="{panelId}"></div></div><iframe height="100%" width="100%" frameBorder="0" id="{panelId}-frame" src="{htmlSrc}"></iframe></div>').apply({
            htmlSrc: '/api/v1/website_builder/render_component.html?component_iid=' + componentIid + '&id=' + websiteId,
            panelId: dropPanel.id
        }));

        Ext.apply(dropPanel, {
            height: height,
            componentId: componentIid
        });

        Ext.get(dropPanel.id + "-remove").on("click", function() {
            me.insert(me.items.indexOf(dropPanel), {
                xtype: 'websitebuilderdropzone',
                flex: 1
            });

            dropPanel.destroy();
        });

        // Assigning click event inside iFrame content
        var iframe = Ext.get(dropPanel.id + "-frame");

        iframe.on('load', function() {
            var iframePanel = this,
                editableElements = Ext.get(iframePanel.el.dom.contentDocument.documentElement).query("[data-selector]"),
                websiteBuilderEditConfig = Compass.ErpApp.Desktop.Applications.Knitkit.WebsiteBuilder.config;

            // // Loading websitebuilder CSS & JS dynamically
            // Ext.ux.Loader.load(mediumCssUrls,
            //     function() {
            //         // callback when finished loading
            //     },
            //     iframePanel // scope
            // );

            Ext.Array.each(editableElements, function(editableElement) {
                editableElement = Ext.get(editableElement);

                editableElement.on('mouseover', function(event) {
                    if (!editableElement.dom.isContentEditable) {
                        me.highlightElement(editableElement.dom);
                    }
                });
                editableElement.on('mouseout', function(event) {
                    if (!editableElement.dom.isContentEditable) {
                        me.deHighlightElement(editableElement.dom);
                    }
                });
                editableElement.on('click', function(event) {
                    event.preventDefault();

                    if (!editableElement.dom.isContentEditable) {
                        var contentEditableElements = Ext.get(iframePanel.el.dom.contentDocument.documentElement).query("[data-selector]");
                        Ext.Array.each(contentEditableElements, function(element) {
                            me.removeEditable(element);
                            me.deHighlightElement(element);
                        });
                    }

                    me.buildPropertiesEditForm(this.dom);
                });
            });

        });

        // containerPanel.removeFieldDropZone(target);
        // containerPanel.remove(panel);
        // containerPanel.addFieldDropZones();
        containerPanel.updateLayout();
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
    },

    highlightElement: function(element) {
        element.style.outline = 'rgba(233, 94, 94, 0.498039) solid 2px';
        element.style['outline-offset'] = '-2px';
        element.cursor = 'pointer';
    },

    deHighlightElement: function(element) {
        element.style.outline = 'none';
        element.style['outline-offset'] = '0px';
        element.cursor = 'pointer';
    },

    enableMediumEditor: function(element, websiteBuilderEditConfig) {
        rangy.init();
        var HighlighterButton = MediumEditor.extensions.button.extend({
            name: 'highlighter',
            tagNames: ['mark'], // nodeName which indicates the button should be 'active' when isAlreadyApplied() is called
            contentDefault: '<b>H</b>', // default innerHTML of the button
            contentFA: '<i class="fa fa-paint-brush"></i>', // innerHTML of button when 'fontawesome' is being used
            aria: 'Hightlight', // used as both aria-label and title attributes
            action: 'highlight', // used as the data-action attribute of the button
            iframeWin: {},
            init: function() {
                MediumEditor.extensions.button.prototype.init.call(this);
                this.classApplier = rangy.createClassApplier('highlight', {
                    elementTagName: 'mark',
                    normalize: true
                });
                this.iframeWin = rangy.dom.getIframeWindow(this.window.frameElement);
            },
            handleClick: function(event) {
                this.classApplier.toggleSelection(this.iframeWin);
                return false;
            }
        });

        if (!element.hasAttribute('medium-editor-index')) {
            var theWindow = element.ownerDocument.defaultView,
                theDoc = element.ownerDocument,
                editor = new MediumEditor(element, {
                    ownerDocument: theDoc,
                    contentWindow: theWindow,
                    buttonLabels: 'fontawesome',
                    toolbar: {
                        buttons: websiteBuilderEditConfig.mediumButtons
                    },
                    extensions: {
                        'highlighter': HighlighterButton
                    }

                });
        }
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

        me.highlightElement(element);

        propertiesEditFormPanel.add({
            xtype: 'label',
            text: "Editing " + dataSelector,
            cls: 'website-builder-form-header',
            margin: '5  0 20 0'
        });
        if (dataSelector == '.editContent') {
            me.makeEditable(element);
            me.enableMediumEditor(element, websiteBuilderEditConfig);
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
        });

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

    removeFieldDropZone: function(target) {
        var me = this;
        // me.suspendLayout = true;
        // Ext.each(me.query('websitebuilderdropzone'), function(dropZone) {
        //     // remove the drop zones
        //     dropZone.destroy();
        // });
        dropZonePanel = Ext.get(target.id);
        dropZonePanel.destroy();
        // me.suspendLayout = false;
        // me.doLayout();
    },

    addFieldDropZones: function() {
        var me = this;
        
        if (me.themeId) {
            me.add([{
                xtype: 'websitebuilderdropzone',
                html: '<iframe src="' + me.templatePreviewURL('/shared/knitkit/_header', 'header') + '" width="100%" height="100%" frameborder="0">' 
            }, {
                xtype: 'component',
                flex: 1,
                cls: '',
                style: {
                    'text-align': 'center',
                    'font-size': '20px',
                    'font-weight': 'bold',
                    'border': '1px solid grey',
                    'padding': '50px',
                    'margin': '25px'
                },
                html: '<div>Contents</div>'
            }, {
                xtype: 'websitebuilderdropzone',
                html: '<iframe src="' + me.templatePreviewURL('/shared/knitkit/_footer', 'footer') + '" width="100%" height="100%" frameborder="0">' 
            }]);

        } else {
            me.add([{
                xtype: 'component',
                itemId: 'header',
                constrain: true,
                flex: 1,
                html: '<iframe src="' + me.templatePreviewURL('/shared/knitkit/_header', 'header') + '" width="100%" height="100%">',
                listeners: {
                    render: function(comp) {
                        Ext.get(comp.el.query('iframe')).on('load', function() {
                            var iframe = this;

                            comp.setHeight(iframe.contentWindow.document.body.clientHeight + 5);
                        });
                    }
                }
            }, {
                xtype: 'websitebuilderdropzone',
                flex: 1

            }, {
                xtype: 'component',
                constrain: true,
                flex: 1,
                html: '<iframe src="' + me.templatePreviewURL('/shared/knitkit/_footer', 'footer') + '" width="100%" height="100%" frameborder="0">',
                listeners: {
                    render: function(comp) {
                        Ext.get(comp.el.query('iframe')).on('load', function() {
                            var iframe = this;

                            comp.setHeight(iframe.contentWindow.document.body.clientHeight + 5);
                        });
                    }
                }
            }]);

        }

    },

    templatePreviewURL: function(templatePath, templateType) {
        var me = this;
        var websitesCombo = Ext.ComponentQuery.query("websitescombo").first();
        var websiteId = websitesCombo.getValue();
        var url = "";

        url = '/knitkit/erp_app/desktop/theme_builder/render_theme_component?website_id=' + websiteId + '&template_path=' + templatePath + '&template_type=' + templateType;

        if(me.themeId) {
            url = url + '&theme_id=' + me.themeId;
        }

        return url;
    },

    buildLayoutConfig: function(layoutType) {
        var me = this,
            layoutPath = null;
        if(layoutType == "header") {
            layoutPath = '/shared/knitkit/_header';
        } else if(layoutPath == "footer") {
            layoutPath = '/shared/knitkit/_footer';
        }
        
        return {
            xtype: 'websitebuilderdropzone',
            itemId: 'header',
            constrain: true,
            flex: 1,
            html: '<iframe src="' + me.templatePreviewURL(layoutPath, layoutType) + '" width="100%" height="100%">',
            listeners: {
                render: function(comp) {
                    Ext.get(comp.el.query('iframe')).on('load', function() {
                        var iframe = this;
                        
                        comp.setHeight(iframe.contentWindow.document.body.clientHeight + 5);
                    });
                }
            }
        };

    },

    setWebsiteTheme: function() {
        var me = this,
            websitesCombo = Ext.ComponentQuery.query("websitescombo").first(),
            websiteId = websitesCombo.getValue();

        Ext.Ajax.request({
            method: "GET",
            url: '/api/v1/website_builder/' + websiteId + '/active_website_theme.json',
            async: false,
            success: function(response) {
                var responseObj = Ext.decode(response.responseText);
                console.log(JSON.stringify(responseObj));
                if (responseObj.success && responseObj.theme !== "") {
                    me.theme = responseObj.theme;
                }
            },
            failure: function() {
                // TODO: Could not load message count, should we display an error?
            }
        });
    }

});
