Ext.define('Compass.ErpApp.Desktop.Applications.Knitkit.WebsiteBuilderDropZone', {
    extend: 'Ext.Component',
    alias: 'widget.websitebuilderdropzone',
    autoRemovableDropZone: false,
    replaceContentOfDraggedPanel: true,
    componentId: null,
    cls: 'website-builder-dropzone',
    height: 150,
    html: '<div>Drop Component Here</div>'
});

Ext.define('Compass.ErpApp.Desktop.Applications.Knitkit.WebsiteBuilderPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.websitebuilderpanel',
    title: "Website Builder",
    autoScroll: true,
    isForTheme: false,
    websiteSectionId: null,
    themeLayoutConfig: {},
    items: [],
    refershIntervals: {},

    beforeLayout: function() {
        var me = this;

        me.callParent(arguments);
        if (me.getEl().dom) {
            me.savedScrollPos = me.body.dom.scrollTop;
        }
    },

    afterLayout: function() {
        var me = this;

        me.callParent(arguments);
        if (me.savedScrollPos) {
            me.body.scrollTo('top', me.savedScrollPos);
        }
    },

    initComponent: function() {
        var me = this;

        me.contentBlocksConfig = {};

        if (!me.isThemeMode()) {
            me.dockedItems = [{
                xtype: 'toolbar',
                items: [{
                    text: 'Add Row',
                    iconCls: 'icon-add',
                    handler: function(btn) {
                        Ext.widget('window', {
                            modal: true,
                            title: 'Add Row',
                            buttonAlign: 'center',
                            items: [{
                                xtype: 'container',
                                layout: 'hbox',
                                items: [{
                                    xtype: 'container',
                                    bodyPadding: '10px',
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
                                    var win = btn.up('window');
                                    var indexToInsert = me.items.getCount();

                                    // if footer is present insert before it
                                    if (me.isLayoutIncluded) {
                                        indexToInsert = indexToInsert - 1;
                                    }

                                    if (win.down('#oneCol').getValue()) {
                                        me.insert(indexToInsert, {
                                            xtype: 'container',
                                            cls: 'dropzone-container',
                                            layout: 'hbox',
                                            items: [{
                                                xtype: 'websitebuilderdropzone',
                                                flex: 1

                                            }]
                                        });
                                    }

                                    if (win.down('#twoCol').getValue()) {
                                        me.insert(indexToInsert, {
                                            xtype: 'container',
                                            cls: 'dropzone-container',
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
                                            cls: 'dropzone-container',
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
                }, {
                    xtype: 'checkbox',
                    boxLabel: 'Include Layout',
                    boxLabelCls: 'website-builder-toolbar-text',
                    listeners: {
                        change: function() {
                            me.toggleLayout();
                        }
                    }
                }]
            }];
        }

        me.on('activate', function() {
            Ext.getCmp('knitkitWestRegion').addComponentsTabPanel(me.isThemeMode());
        });

        me.on('deactivate', function() {
            Ext.getCmp('knitkitWestRegion').removeComponentsTabPanel();
        });

        me.on('beforerender', function() {
            me.setWebsiteTheme();
        });

        /*
         * Handle drag and drop of components from the west panel onto a page
         */
        me.on('render', function() {
            me.dragZone = Ext.create('Ext.dd.DragZone', me.getEl(), {
                ddGroup: 'websiteBuilderPanelDDgroup',
                onBeforeDrag: function(data, e) {
                    me.disableComponents();
                    me.addAutoRemovableDropZones(data.panelId);
                },

                afterDragDrop: function(target, e, id) {
                    me.enableComponents();
                    me.removeAutoRemovableDropZones();
                },

                afterInvalidDrop: function(target, e, id) {
                    me.enableComponents();
                    me.removeAutoRemovableDropZones();
                },

                getDragData: function(e) {
                    var moveEl = e.getTarget('.icon-move'),
                        targetId = null;

                    if (moveEl) {
                        targetId = moveEl.getAttribute('panelId');
                    }

                    if (targetId) {
                        var element = Ext.getCmp(targetId),
                            dragEl = element.getEl(),
                            dragElDom = dragEl.dom.cloneNode(true);

                        dragElDom.id = Ext.id();

                        Ext.fly(dragElDom).setWidth(186);
                        Ext.fly(dragElDom).setHeight(80);

                        return {
                            panelConfig: element.initialConfig,
                            panelId: element.id,
                            repairXY: element.getEl().getXY(),
                            ddel: dragElDom,
                            uniqueId: element.uniqueId,
                            isMove: true
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
                    return e.getTarget('.website-builder-dropzone') || e.getTarget('.component');
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
                        var draggedPanel = Ext.getCmp(data.panelId);
                        var dropPanel = Ext.getCmp(Ext.fly(target).dom.id);

                        Ext.apply(dropPanel, {
                            autoRemovableDropZone: false
                        });

                        if (data.uniqueId && data.uniqueId.toString().indexOf('_componentIid_') === -1) {
                            me.loadContentBlock(dropPanel, {
                                websiteSectionContentId: data.uniqueId
                            });

                            me.removeContentFromDraggedPanel(dropPanel, draggedPanel);

                        } else {
                            if (data.uniqueId && data.uniqueId.toString().indexOf('_componentIid_') !== -1) {
                                componentIid = data.uniqueId.toString().split('_componentIid_')[0];

                            } else {
                                componentIid = data.componentId;
                            }

                            Ext.Ajax.request({
                                method: "GET",
                                url: '/knitkit/erp_app/desktop/website_builder/get_component.json',
                                params: {
                                    id: componentIid
                                },
                                success: function(response) {
                                    var responseObj = Ext.decode(response.responseText);

                                    if (responseObj.success) {
                                        var responseData = responseObj.data;

                                        if (me.isThemeMode()) {
                                            me.loadContentBlock(dropPanel, {
                                                templateType: responseData.iid
                                            });

                                        } else {
                                            me.loadContentBlock(dropPanel, {
                                                componentIid: responseData.iid
                                            });

                                        }

                                        me.removeContentFromDraggedPanel(dropPanel, draggedPanel);
                                    }
                                },
                                failure: function() {
                                    // TODO: Could not able to drop component, should we display an error?
                                }
                            });
                        }

                        me.removeAutoRemovableDropZones();
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
                    if (Ext.get(target).id.indexOf('websitebuilderdropzone') === -1) {
                        return false;
                    } else {
                        return true;
                    }
                }
            });

            me.addCurrentComponents();
        });

        me.callParent();
    },

    disableComponents: function() {
        var me = this;

        Ext.each(me.el.query('.component'), function(component) {
            Ext.get(component).mask();
        });
    },

    enableComponents: function() {
        var me = this;

        Ext.each(me.el.query('.component'), function(component) {
            Ext.get(component).unmask();
        });
    },

    addAutoRemovableDropZones: function(panelId) {
        var me = this;
        me.suspendLayout = true;

        var components = Ext.Array.filter(me.query('container'), function(container) {
            return (!Ext.isEmpty(container.el.query('.component')) && Ext.isEmpty(container.query('#' + panelId)));
        });

        Ext.each(components, function(component, index) {
            var componentIndex = me.items.indexOf(component);

            me.insert(componentIndex, {
                xtype: 'container',
                cls: 'dropzone-container',
                layout: '',
                items: [{
                    xtype: 'websitebuilderdropzone',
                    flex: 1,
                    autoRemovableDropZone: true,
                    replaceContentOfDraggedPanel: false
                }]
            });

            if (index === (components.length - 1)) {
                if (me.items.getAt(componentIndex + 1) && !Ext.isEmpty(me.items.getAt(componentIndex + 1).el.query('.component'))) {
                    me.insert(componentIndex + 2, {
                        xtype: 'container',
                        cls: 'dropzone-container',
                        layout: '',
                        items: [{
                            xtype: 'websitebuilderdropzone',
                            flex: 1,
                            autoRemovableDropZone: true,
                            replaceContentOfDraggedPanel: false
                        }]
                    });
                }
            }
        });
        me.suspendLayout = false;
        me.doLayout();
    },

    removeAutoRemovableDropZones: function() {
        var me = this;
        me.suspendLayout = true;
        Ext.each(me.query('websitebuilderdropzone'), function(dropZone) {
            if (dropZone.autoRemovableDropZone) {
                // remove the removable drop zones
                dropZone.destroy();
            }
        });
        me.suspendLayout = false;
        me.doLayout();
    },

    getWebsiteId: function() {
        var websitesCombo = Ext.ComponentQuery.query("websitescombo").first();
        return websitesCombo.getValue();
    },

    buildContentBlocksPayload: function() {
        var me = this,
            containerPanels = me.query("[cls=websitebuilder-component-panel][isLayout!=true]");

        return Ext.Array.map(containerPanels, function(container, index) {
            var iframe = container.el.down('.iframe-container > iframe').el.dom,
                containerHTML = iframe.contentDocument.documentElement.getElementsByClassName('page')[0].outerHTML,
                containerElem = jQuery(containerHTML);

            var data = {
                position: index,
                body_html: Ext.String.htmlDecode(containerElem[0].outerHTML)
            };

            // check if we are loading a compnent before it has been saved
            if (container.uniqueId.toString().indexOf('_componentIid_') !== -1) {
                data['component_iid'] = container.uniqueId.toString().split('_componentIid_')[0];
            } else {
                data['website_section_content_id'] = container.uniqueId;
            }

            return data;
        });
    },

    buildContentBlockTemplate: function(dropPanel, options) {
        var me = this,
            websiteId = me.getWebsiteId();

        options = options || {};

        var canViewSource = (options.canViewSource === undefined) ? true : options.canViewSource,
            canMove = (options.canMove === undefined) ? true : options.canMove,
            canRemove = (options.canRemove === undefined) ? true : options.canRemove,
            templateType = options.templateType,
            componentIid = options.componentIid,
            websiteSectionContentId = options.websiteSectionContentId,
            url = null;

        if (templateType == 'header' || templateType == 'footer') {
            url = '/knitkit/erp_app/desktop/theme_builder/render_theme_component?website_id=' + websiteId + '&template_type=' + templateType;

        } else if (websiteSectionContentId) {
            url = '/knitkit/erp_app/desktop/website_builder/render_component.html?website_section_content_id=' + websiteSectionContentId + '&id=' + websiteId;

        } else {
            url = '/knitkit/erp_app/desktop/website_builder/render_component.html?component_iid=' + componentIid + '&id=' + websiteId + '&website_section_id=' + me.websiteSectionId;
        }

        // append a random param to prevent the browser from caching its contents when this is requested from an iframe
        url = url + '&cache_buster_token=' + new Date().getTime();

        return new Ext.XTemplate(
            '<div class="component" style="height:100%;width:100%;position:relative;">',
            '<tpl if="canViewSource || canMove || canRemove">',
            '<div class="website-builder-reorder-setting" id="componentSetting">',
            '<tpl if="canViewSource">',
            '<div class="icon-edit-code pull-left" id="{uniqueId}-source" style="margin-right:5px;"></div>',
            '</tpl>',
            '<tpl if="canMove">',
            '<div class="icon-move pull-left" id="{uniqueId}-move" style="margin-right:5px;" panelId="{panelId}"></div>',
            '</tpl>',
            '<tpl if="canRemove">',
            '<div class="icon-remove pull-left" id="{uniqueId}-remove"></div>',
            '</tpl>',
            '</div>',
            '<div class="iframe-container">',
            '<iframe height="100%" width="100%" frameBorder="0" id="{iframeId}" src="{url}"></iframe>',
            '</div>',
            '<tpl else>',
            '<div class="iframe-container">',
            '<iframe height="100%" width="100%" frameBorder="0" id="{iframeId}" src="{url}"></iframe>',
            '</div>',
            '</tpl>',
            '</div>'
        ).apply({
            panelId: dropPanel.id,
            uniqueId: options.uniqueId,
            iframeId: options.uniqueId + '-frame' + new Date().getTime(),
            url: url,
            canViewSource: canViewSource,
            canMove: canMove,
            canRemove: canRemove
        });
    },

    loadContentBlock: function(dropPanel, options) {
        var me = this;
        var containerPanel = Ext.ComponentQuery.query('websitebuilderpanel').first();
        var uniqueId = null;

        if (options.templateType) {
            uniqueId = options.templateType;

        } else if (options.websiteSectionContentId) {
            uniqueId = options.websiteSectionContentId;

        } else {
            uniqueId = options.componentIid + '_componentIid_' + Math.round(Math.random() * 10000000);
        }

        dropPanel.removeCls('website-builder-dropzone');

        Ext.apply(dropPanel, {
            cls: "websitebuilder-component-panel"
        });

        var loadMask = new Ext.LoadMask(me, {
            msg: "Please wait..."
        });
        loadMask.show();

        dropPanel.uniqueId = uniqueId;
        options['uniqueId'] = uniqueId;

        dropPanel.update(me.buildContentBlockTemplate(dropPanel, options));

        var iframe = Ext.get(dropPanel.el.down('div.iframe-container > iframe'));

        var sourceElem = Ext.get(uniqueId + '-source');
        if (sourceElem) {
            sourceElem.on('click', function() {
                if (dropPanel.cls == 'websitebuilder-component-panel') {
                    me.fetchComponentSource(
                        uniqueId,
                        function(responseObj) {
                            var source = responseObj.component.html;
                            var parentContainer = dropPanel.up('container');
                            var dropPanelIndex = dropPanel.up('websitebuilderpanel').items.indexOf(parentContainer);
                            var templateType = options.templateType;
                            var opts = {
                                canViewSource: true,
                                canRemove: true
                            };

                            if (templateType) {
                                Ext.apply(opts, {
                                    canMove: false,
                                    templateType: templateType
                                });
                            } else {
                                Ext.apply(opts, {
                                    canMove: true
                                });
                            }

                            parentContainer.insert(dropPanelIndex, {
                                xtype: 'codemirror',
                                mode: 'rhtml',
                                showMode: false,
                                sourceCode: source,
                                width: 1300,
                                height: 500,
                                tbarItems: [{
                                    text: 'Save & Show Design View',
                                    iconCls: 'icon-save',
                                    handler: function(btn) {
                                        var myMask = new Ext.LoadMask(me, {
                                            msg: "Please wait..."
                                        });
                                        myMask.show();

                                        var componentSource = btn.up('codemirror').codeMirrorInstance.getValue();

                                        me.saveComponentSource(componentSource, {
                                                templateType: templateType,
                                                websiteSectionContentId: uniqueId
                                            },
                                            function() {
                                                var componentContainer = me.insert(dropPanelIndex, {
                                                    xtype: 'container',
                                                    cls: 'dropzone-container',
                                                    layout: 'hbox',
                                                    items: [{
                                                        xtype: 'component',
                                                        flex: 1,
                                                        html: ''

                                                    }]
                                                });
                                                btn.up('codemirror').destroy();

                                                me.loadContentBlock(
                                                    componentContainer.down('component'), {
                                                        websiteSectionContentId: uniqueId
                                                    }
                                                );
                                                myMask.hide();
                                            },
                                            function() {
                                                myMask.hide();
                                                Ext.Msg.alert('Error', 'Error saving source');
                                            }
                                        );
                                    }
                                }, {
                                    text: 'Close',
                                    iconCls: 'icon-delete',
                                    handler: function(btn) {
                                        var componentContainer = me.insert(dropPanelIndex, {
                                            xtype: 'container',
                                            cls: 'dropzone-container',
                                            layout: 'hbox',
                                            items: [{
                                                xtype: 'component',
                                                flex: 1,
                                                html: ''

                                            }]
                                        });
                                        btn.up('codemirror').destroy();

                                        me.loadContentBlock(
                                            componentContainer.down('component'), {
                                                websiteSectionContentId: uniqueId
                                            }
                                        );
                                    }
                                }],
                                listeners: {
                                    save: function(codemirror, content) {
                                        var myMask = new Ext.LoadMask(me, {
                                            msg: "Please wait..."
                                        });
                                        myMask.show();

                                        me.saveComponentSource(content, {
                                                templateType: templateType,
                                                websiteSectionContentId: uniqueId
                                            },
                                            function() {
                                                myMask.hide();
                                            },
                                            function() {
                                                myMask.hide();
                                            }
                                        );
                                    }
                                }
                            });

                            dropPanel.destroy();
                        },
                        function() {
                            Ext.Msg.alert('Error', 'The section must be saved to edit the source');
                        }
                    );
                }
            });
        }

        var removeElem = Ext.get(uniqueId + "-remove");
        if (removeElem) {
            removeElem.on("click", function() {
                parentContainer = dropPanel.up('container');
                if (dropPanel.cls == "websitebuilder-component-panel") {
                    parentContainer.insert(parentContainer.items.indexOf(dropPanel), {
                        xtype: 'websitebuilderdropzone',
                        flex: 1
                    });

                    dropPanel.destroy();
                    clearInterval(containerPanel.refershIntervals[uniqueId]);
                }
            });
        }

        iframe.on('load', function() {
            loadMask.hide();
            var iframeNode = iframe.el.dom;

            //setup editable content listeners
            me.setupEditableContentListeners(iframeNode);

            //setup widget drop listeners
            me.setupIframeDragDropListeners(iframeNode);

            //setup widget listeners
            me.attachIframeWidgetListeners(iframeNode);

            //disable navagation links
            jQuery(iframeNode).contents().find("a").each(function() {
                jQuery(this).attr("href", "#");
            });

            // start resize interval for iframe
            containerPanel.refershIntervals[uniqueId] = setInterval(function() {
                if (!iframeNode || !iframeNode.contentDocument || !iframeNode.contentDocument.body) {
                    clearInterval(containerPanel.refershIntervals[uniqueId]);
                } else {
                    dropPanel.setHeight(iframeNode.contentDocument.body.offsetHeight);
                    containerPanel.updateLayout();
                }
            }, 300);
        });
    },

    setupEditableContentListeners: function(iframeNode) {
        var me = this;
        var editableElements = Ext.get(iframeNode.contentDocument.documentElement).query("[data-selector]");

        Ext.Array.each(editableElements, function(editableElement) {
            editableElement = Ext.get(editableElement);

            editableElement.on('mouseover', function(event) {
                me.highlightElement(event.target);
            });

            editableElement.on('mouseout', function(event) {
                if (event.target != me.selectedEditableContent)
                    me.deHighlightElement(event.target);
            });

            editableElement.on('click', function(event) {
                event.preventDefault();

                var contentEditableElements = Ext.get(iframeNode.contentDocument.documentElement).query("[data-selector]");
                Ext.Array.each(contentEditableElements, function(element) {
                    me.removeEditable(element);
                    me.deHighlightElement(element);
                });

                me.selectedEditableContent = event.target;
                me.buildPropertiesEditForm(event.target);
            });
        });
    },

    // setup iframe drag and drop
    setupIframeDragDropListeners: function(iframeNode) {
        var me = this;
        var currentElement, currentElementChangeFlag, elementRectangle, countdown;

        var dragImg = new Image();
        dragImg.src = '/assets/knitkit/website_builder/drag.png';

        jQuery(iframeNode.contentDocument.body).find('.page > .item.content, .page > .item.header, .page > .item.footer').attr('data-frame-uuid', jQuery(iframeNode).attr('id'));

        //Add CSS to iFrame
        var styles = '.dnd-drop-target{border:1px solid #666;}';
        styles += '.dnd-drop-target-occupied{border:4px solid #00FFFF !important;}';
        styles += '.website-builder-reorder-setting{background-color: #ccc;padding: 10px;top: 0;right: 17px;height: 36px;border-radius: 5px;z-index: 500;position: absolute;}';
        styles += '.icon-remove{background-image: url(/assets/icons/delete/delete_16x16.png) !important;filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(src="/assets/icons/delete/delete_16x16.png", sizingMethod="crop");height: 16px;width: 16px;cursor: pointer;float:left;}';
        styles += '.icon-move{background-image: url(/assets/knitkit/icons/move-component.png) !important;filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(src="/assets/knitkit/icons/move-component.png", sizingMethod="crop");height: 16px;width: 16px;cursor: move;margin-right:5px;float:left;}';

        var style = jQuery("<style data-reserved-styletag></style>").html(styles);
        jQuery(iframeNode.contentDocument.head).append(style);

        var win = Ext.getCmp('knitkit');

        jQuery(iframeNode.contentDocument).find('html,body').find('.dnd-drop-target')
            .off('dragover').on('dragover', function(event) {
                event.preventDefault();
                event.stopPropagation();

                jQuery(this).addClass('dnd-drop-target-occupied');

            }).off('dragleave').on('dragleave', function(event) {
                event.preventDefault();
                event.stopPropagation();

                jQuery(this).removeClass('dnd-drop-target-occupied');

            }).off('drop').on('drop', function(event) {
                event.preventDefault();
                event.stopPropagation();

                var dropTarget = jQuery(this);
                var insertionPoint = jQuery("iframe").contents().find(".dnd-drop-target-occupied");
                var uuid = event.originalEvent.dataTransfer.getData('uuid');

                if (uuid) {
                    try {
                        var widgetStatement = event.originalEvent.dataTransfer.getData('widget-statement');
                        Compass.ErpApp.Utility.ajaxRequest({
                            url: '/knitkit/erp_app/desktop/website_builder/widget_source',
                            method: 'POST',
                            params: {
                                content: '<%=' + widgetStatement + '%>'
                            },
                            success: function(responseObj) {
                                var previousComponent = null;
                                jQuery('iframe').each(function(index, iframe) {
                                    previousComponent = jQuery(iframe).contents().find('#' + uuid);
                                    if (previousComponent.length > 0) {
                                        return false;
                                    }
                                });

                                // don't drop a component is dropped over itself
                                if (previousComponent.parent()[0] == dropTarget[0]) {
                                    return;
                                }

                                previousComponent.parent().removeClass('dnd-drop-target-occupied');
                                previousComponent.parent().append($('<div class="col dnd-drop-target"></div>'));
                                me.setupIframeDragDropListeners(document.getElementById(previousComponent.parents('.item.content, .item.header, .item.footer').attr('data-frame-uuid')));

                                previousComponent.remove();

                                var dropComponent = me.insertWidget(responseObj.source);
                                dropComponent.parent().attr('data-widget-statement', widgetStatement);

                                me.attachIframeWidgetListeners(iframeNode);
                            }
                        });

                    } catch (e) {
                        console.error(e);
                    }
                } else {
                    var widgetName = event.originalEvent.dataTransfer.getData('widget-name');
                    var widgetsPanel = me.up('window').down('knitkit_WidgetsPanel');
                    var widgetData = widgetsPanel.getWidgetData(widgetName);
                    widgetData.addWidget({
                        websiteBuilder: true,
                        success: function(content) {
                            Compass.ErpApp.Utility.ajaxRequest({
                                url: '/knitkit/erp_app/desktop/website_builder/widget_source',
                                method: 'POST',
                                params: {
                                    content: content
                                },
                                success: function(responseObj) {
                                    try {
                                        var dropComponent = me.insertWidget(responseObj.source);
                                        // store widget render statement barring <%= %> in its parent data arribute
                                        // we leave out the <%= %> to prevent it from getting evalauated when it renders
                                        // in the builder view.
                                        dropComponent.parent().attr('data-widget-statement', content.match(/<%=(((.|[\s\S])*?))%>/)[1]);

                                        me.attachIframeWidgetListeners(iframeNode);

                                    } catch (e) {
                                        console.error(e);
                                    }
                                },
                                errorMessage: "Error fetching widget source"
                            });
                        }
                    });
                }
            });
    },

    insertWidget: function(widgetSource) {
        // get the drop markers
        var insertionPoint = jQuery("iframe").contents().find(".dnd-drop-target-occupied");

        var itemContent = insertionPoint.parents('.item.content, .item.header, .item.footer'),
            iframeId = itemContent.attr('data-frame-uuid'),
            componentId = itemContent.attr('data-container');

        // get the container frame from the insertion point
        var containerFrame = document.getElementById(iframeId),
            containerWindow = containerFrame.contentWindow,
            containerDocument = containerFrame.contentDocument || containerWindow.document;

        // The widget source contains DOM elements and script tags which needs
        // to be executed in the context of the container iframe.

        var dropComponent = jQuery(widgetSource);

        // accumulate scripts
        scripts = [];
        dropComponent.children().filter('script').each(function() {
            scripts.push(jQuery(this).detach().html());
        });

        // insert widget DOM
        insertionPoint.after(dropComponent);

        var expression = 'return function(window, document){$ = window.$}',
            scriptFunc = new Function(expression)();
        scriptFunc.apply(containerWindow, [containerWindow, containerDocument]);
        // execute accumulated scripts
        scripts.forEach(function(script) {
            var expression = 'return function(window, document){\n' + script + '\n}',
                scriptFunc = new Function(expression)();
            scriptFunc.apply(containerWindow, [containerWindow, containerDocument]);
        });

        //remove drop markers 
        insertionPoint.remove();

        return dropComponent;
    },

    fetchComponentSource: function(uniqueId, success, failure) {
        var me = this;
        var componentIid = null;
        var websiteSectionContentId = null;

        // check if we are loading a compnent before it has been saved
        if (uniqueId.toString().indexOf('_componentIid_') !== -1) {
            componentIid = uniqueId.toString().split('_componentIid_')[0];
        } else {
            websiteSectionContentId = uniqueId;
        }

        Compass.ErpApp.Utility.ajaxRequest({
            url: '/knitkit/erp_app/desktop/website_builder/get_component_source',
            method: 'GET',
            params: {
                website_id: me.getWebsiteId(),
                website_section_id: me.websiteSectionId,
                website_section_content_id: websiteSectionContentId,
                component_iid: componentIid
            },
            success: function(response) {
                if (success) {
                    success(response);
                }
            },
            failure: function() {
                if (failure) {
                    failure();
                } else {
                    Ext.Msg.alert('Error', 'Error fetching source');
                }
            }
        });
    },

    saveComponentSource: function(componentSource, options, success, failure) {
        var me = this;

        Compass.ErpApp.Utility.ajaxRequest({
            url: '/knitkit/erp_app/desktop/website_builder/save_component_source',
            method: 'POST',
            params: {
                id: me.getWebsiteId(),
                website_section_content_id: options.websiteSectionContentId,
                template_type: options.templateType,
                source: componentSource
            },
            success: function(response) {
                if (success) {
                    success(response);
                }
            },
            failure: function(response) {
                if (failure) {
                    failure(response);
                } else {
                    Ext.Msg.error('Error', 'Error saving source');
                }
            }
        });
    },

    attachIframeWidgetListeners: function(iframeNode) {
        var me = this;

        // add remove buttons
        jQuery(iframeNode.contentDocument).find('.compass_ae-widget > .website-builder-reorder-setting > .icon-remove').off('click');
        jQuery(iframeNode.contentDocument).find('.compass_ae-widget > .website-builder-reorder-setting > .icon-move').off('dragstart');
        jQuery(iframeNode.contentDocument).find('.compass_ae-widget > .website-builder-reorder-setting').remove();
        jQuery(iframeNode.contentDocument).find('.compass_ae-widget').append('<div class="website-builder-reorder-setting"><div class="icon-move" draggable=true id="-remove"></div><div class="icon-remove" id="-remove"></div></div>');

        jQuery(iframeNode.contentDocument).find('.compass_ae-widget > .website-builder-reorder-setting > .icon-remove').click(function() {
            var uuid = $(this).parents('.compass_ae-widget').attr('id');
            var previousComponent = $(this).parents('.compass_ae-widget').parents('body').find('#' + uuid);

            previousComponent.parent().removeClass('dnd-drop-target-occupied');
            previousComponent.parent().append($('<div class="col dnd-drop-target"></div>'));
            me.attachIframeWidgetListeners(document.getElementById(previousComponent.parents('.item.content, .item.header, .item.footer').attr('data-frame-uuid')));

            previousComponent.remove();
        });

        jQuery(iframeNode.contentDocument).find('.compass_ae-widget > .website-builder-reorder-setting > .icon-move').on('dragstart', function(event) {
            var draggableElem = jQuery(this).parents('.compass_ae-widget');
            var uuid = draggableElem.attr('id');
            if (uuid) {
                event.originalEvent.dataTransfer.setData("uuid", uuid);
                event.originalEvent.dataTransfer.setData("widget-statement", draggableElem.parent().attr('data-widget-statement'));
            }
        });
    },

    removeContentFromDraggedPanel: function(dropPanel, draggedPanel) {
        var me = this,
            parentContainer = draggedPanel.up('container');

        if (draggedPanel.cls == "websitebuilder-component-panel" && parentContainer.hasCls('dropzone-container')) {
            if (dropPanel.replaceContentOfDraggedPanel) {
                parentContainer.insert(parentContainer.items.indexOf(draggedPanel), {
                    xtype: 'websitebuilderdropzone',
                    flex: 1
                });
            }
            draggedPanel.destroy();
        }

        me.updateLayout();
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
                    }
                });
        }
    },

    addCurrentComponents: function() {
        var me = this;
        if (me.isThemeMode()) {
            var options = {
                canViewSource: true,
                canMove: false,
                canRemove: true
            };

            me.add(
                [
                    me.buildLayoutConfig('header', options), {
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

                    },
                    me.buildLayoutConfig('footer', options)
                ]
            );

        } else {
            Compass.ErpApp.Utility.ajaxRequest({
                url: '/knitkit/erp_app/desktop/website_builder/section_components',
                method: 'GET',
                params: {
                    website_section_id: me.websiteSectionId
                },
                success: function(response) {
                    if (Compass.ErpApp.Utility.isBlank(response.website_section_contents)) {
                        me.add({
                            xtype: 'container',
                            cls: 'dropzone-container',
                            layout: 'hbox',
                            items: [{
                                xtype: 'websitebuilderdropzone',
                                flex: 1

                            }]
                        });
                    } else {
                        Ext.each(response.website_section_contents, function(websiteSectionContent) {
                            var componentContainer = me.add({
                                xtype: 'container',
                                cls: 'dropzone-container',
                                layout: 'hbox',
                                items: [{
                                    xtype: 'component',
                                    flex: 1,
                                    html: ''
                                }]
                            });

                            me.loadContentBlock(
                                componentContainer.down('component'), {
                                    websiteSectionContentId: websiteSectionContent.id
                                }
                            );
                        });
                    }
                }
            });

        }
    },

    buildLayoutConfig: function(templateType, options) {
        var me = this;

        options = options || {};

        // if is header or footer is already present render it as a component else render websitebuilderdropzone
        var layoutCompConfig = null;

        layoutCompConfig = {
            xtype: 'component',
            isLayout: true,
            cls: 'websitebuilder-component-panel',
            listeners: {
                render: function(comp) {
                    me.loadContentBlock(comp, Ext.apply(options, {
                        templateType: templateType
                    }));
                }
            }
        };

        return layoutCompConfig;
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

            if (editableAttr == 'src') {
                data = jQuery(element).attr('src');
            } else {
                data = Ext.String.trim(editableAttr == 'content' ? element.innerHTML : window.getComputedStyle(element).getPropertyValue(editableAttr));
            }

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
    },

    isThemeMode: function() {
        return this.isForTheme;
    },

    toggleLayout: function() {
        var me = this;

        if (me.isThemeMode()) {
            return;
        }

        if (me.isLayoutIncluded === undefined) {
            me.isLayoutIncluded = false;
        }

        if (!me.isLayoutIncluded) {
            me.isLayoutIncluded = true;
            var options = {
                canViewSource: false,
                canMove: false,
                canRemove: false
            };
            me.insert(0, me.buildLayoutConfig('header', options));
            me.add(me.buildLayoutConfig('footer', options));

        } else {
            me.isLayoutIncluded = false;
            Ext.each(me.query('[isLayout=true]'), function(item) {
                item.destroy();
            });

        }
    },

    setWebsiteTheme: function() {
        var me = this,
            websiteId = me.getWebsiteId();

        Ext.Ajax.request({
            method: "GET",
            url: '/knitkit/erp_app/desktop/website_builder/' + websiteId + '/active_website_theme.json',
            async: false,
            success: function(response) {
                var responseObj = Ext.decode(response.responseText);

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