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
                                    if(me.isLayoutIncluded) {
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
                },{
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
                            height = element.getEl().getHeight(),
                            width = element.getEl().getWidth(),
                            dragElDom = dragEl.dom.cloneNode(true);

                        dragElDom.id = Ext.id();

                        Ext.fly(dragElDom).setHTML('<img src="' + element.thumbnail + '" style="width:186px;height:80px">');
                        Ext.fly(dragElDom).setWidth(186);
                        Ext.fly(dragElDom).setHeight(80);

                        return {
                            panelConfig: element.initialConfig,
                            panelId: element.id,
                            repairXY: element.getEl().getXY(),
                            ddel: dragElDom,
                            componentId: element.componentId,
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

                        Ext.Ajax.request({
                            method: "GET",
                            url: '/knitkit/erp_app/desktop/website_builder/get_component.json',
                            params: {
                                id: data.componentId
                            },
                            success: function(response) {
                                var responseObj = Ext.decode(response.responseText);

                                if (responseObj.success) {
                                    var responseData = responseObj.data;

                                    me.loadContentBlock(dropPanel, responseData.iid, responseData.height, responseData.thumbnail);
                                    me.removeContentFromDraggedPanel(dropPanel, draggedPanel);

                                    if (me.isThemeMode()) {
                                        if (Ext.String.startsWith(responseData.iid, 'header')) {
                                            me.themeLayoutConfig.headerComponentIid = responseData.iid;
                                            me.themeLayoutConfig.headerComponentHeight = responseData.height;
                                        }

                                        if (Ext.String.startsWith(responseData.iid, 'footer')) {
                                            me.themeLayoutConfig.footerComponentIid = responseData.iid;
                                            me.themeLayoutConfig.footerComponentHeight = responseData.height;
                                        }
                                    }
                                }
                            },
                            failure: function() {
                                // TODO: Could not able to drop component, should we display an error?
                            }
                        });

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
                    return true;
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

    addContentBlockConfig: function(iid, config) {
        this.contentBlocksConfig[iid] = {
            height: config.height,
            thumbnail: config.thumbnail
        };
    },

    deleteContentBlockConfig: function(iid) {
        delete this.contentBlocksConfig[iid];
    },

    getContentBlockConfig: function(iid) {
        return this.contentBlocksConfig[iid];
    },

    buildContentBlocksPayload: function() {
        var me = this,
            containerPanels = me.query("[cls=websitebuilder-component-panel]");
        return Ext.Array.map(containerPanels, function(container, index) {
            var iframe = container.el.down('.iframe-container > iframe').el.dom,
                containerHTML = iframe.contentDocument.documentElement.getElementsByClassName('page')[0].outerHTML,
                containerElem = jQuery(containerHTML);
            return {
                position: index,
                content_iid: container.componentId,
                body_html: Ext.String.htmlDecode(containerElem[0].outerHTML)
            };
        });
    },

    buildContentBlockTemplate: function(componentIid) {
        var me = this,
            websiteId = me.getWebsiteId();
        
        if(componentIid == 'header' || componentIid == 'footer') {
            var componentPath = '/shared/knitkit/_' + componentIid;
            var url = '/knitkit/erp_app/desktop/theme_builder/render_theme_component?website_id=' + websiteId + '&template_path=' + componentPath;
            
        } else {
            var url = '/knitkit/erp_app/desktop/website_builder/render_component.html?component_iid=' + componentIid + '&id=' + websiteId + '&website_section_id=' + me.websiteSectionId;
        }
        
        // append a random param to prevent the browser from caching its contents when this is requested from an iframe
        url = url + '&cache_buster_token=' + Math.round(Math.random() * 10000000);
        
        var iframeUuid = new Date().getTime(),
            iframeId = componentIid + '-frame' + iframeUuid;
        
        return new Ext.XTemplate(
            '<div class="component" style="height:100%;width:100%;position:relative;" panelId="{panelId}" >',
            '<div class="website-builder-reorder-setting" id="componentSetting">',
            '<div class="icon-edit-code pull-left" id="{componentIid}-source" style="margin-right:5px;"></div>',
            
            '<div class="icon-move pull-left" id="{componentIid}-move" style="margin-right:5px;"></div>',
            '<div class="icon-remove pull-left" id="{componentIid}-remove"></div>',
            '</div>',
            '<div class="iframe-container">',
            '<iframe height="100%" width="100%" frameBorder="0" id="{iframeId}" src="{url}"></iframe>',
            '</div>',
            '</div>'
        ).apply({
            componentIid: componentIid,
            iframeId: iframeId,
            url: url
        });
    },
    
    loadContentBlock: function(dropPanel, componentIid, height, thumbnail) {
        var me = this;
        var containerPanel = Ext.ComponentQuery.query('websitebuilderpanel').first();

        me.addContentBlockConfig(componentIid, {
            height: height,
            thumbnail: thumbnail
        });

        dropPanel.removeCls('website-builder-dropzone');
        Ext.apply(dropPanel, {
            cls: "websitebuilder-component-panel",
            thumbnail: thumbnail
        });

        var loadMask = new Ext.LoadMask(me, {
            msg: "Please wait..."
        });
        loadMask.show();

        dropPanel.setHeight(height);
        dropPanel.componentId = componentIid;
        
        dropPanel.update(me.buildContentBlockTemplate(componentIid));
        
        Ext.get(componentIid + '-source').on('click', function() {
            if (dropPanel.cls == 'websitebuilder-component-panel') {
                me.fetchComponentSource(
                    componentIid,
                    function(responseObj) {
                        if (!responseObj.is_content_saved) {
                            Ext.Msg.alert('Error', 'The section must be saved to edit the source');
                            return;
                        }
                        var source = responseObj.component.html;
                        var parentContainer = dropPanel.up('container');
                        var dropPanelIndex = parentContainer.items.indexOf(dropPanel);
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
                                    me.saveComponentSource(
                                        componentIid,
                                        componentSource,
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
                                            var componentConfig = me.getContentBlockConfig(componentIid);
                                            me.loadContentBlock(
                                                componentContainer.down('component'),
                                                componentIid,
                                                componentConfig.height,
                                                componentConfig.thumbnail
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
                                    var componentConfig = me.getContentBlockConfig(componentIid);
                                    me.loadContentBlock(
                                        componentContainer.down('component'),
                                        componentIid,
                                        componentConfig.height,
                                        componentConfig.thumbnail
                                    );
                                }
                            }],
                            listeners: {
                                save: function(codemirror, content) {
                                    var myMask = new Ext.LoadMask(me, {
                                        msg: "Please wait..."
                                    });
                                    myMask.show();
                                    me.saveComponentSource(
                                        componentIid,
                                        content,
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
                    }
                );
            }
        });

        Ext.get(componentIid + "-remove").on("click", function() {
            parentContainer = dropPanel.up('container');
            if (dropPanel.cls == "websitebuilder-component-panel") {
                parentContainer.insert(parentContainer.items.indexOf(dropPanel), {
                    xtype: 'websitebuilderdropzone',
                    flex: 1
                });

                dropPanel.destroy();
                me.deleteContentBlockConfig(componentIid);
            }
        });

        var iframe = Ext.get(dropPanel.el.down('div.iframe-container > iframe'));
        
        iframe.on('load', function() {
            loadMask.hide();
            var iframeNode = iframe.el.dom;
            var editableElements = Ext.get(iframeNode.contentDocument.documentElement).query("[data-selector]");

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
                        var contentEditableElements = Ext.get(iframeNode.contentDocument.documentElement).query("[data-selector]");
                        Ext.Array.each(contentEditableElements, function(element) {
                            me.removeEditable(element);
                            me.deHighlightElement(element);
                        });
                    }

                    me.buildPropertiesEditForm(this.dom);
                });
            });

            //setup widget drop listeners
            me.setupIframeDragDropListeners(iframeNode);

        });

        containerPanel.updateLayout();
    },

    // setup iframe drag and drop
    setupIframeDragDropListeners: function(iframeNode) {
        var me = this;
        var currentElement, currentElementChangeFlag, elementRectangle, countdown, dragoverqueue_processtimer;

        var dragImg = new Image();
        dragImg.src = '/assets/knitkit/website_builder/drag.png';

        var iframeUuid = jQuery(iframeNode).attr('id').match(/^.*?-frame(\d+)$/)[1];
        jQuery(iframeNode.contentDocument.body).find('.page > .item.content').attr('data-frame-uuid', iframeUuid);

        //Add CSS File to iFrame
        var style = jQuery("<style data-reserved-styletag></style>").html(GetInsertionCSS());
        jQuery(iframeNode.contentDocument.head).append(style);

        var win = Ext.getCmp('knitkit');

        jQuery(iframeNode.contentDocument).find('html,body').find('.dnd-drop-target')
            .on('dragenter', function(event) {
                console.log('drag enter');
                event.stopPropagation();
                currentElement = jQuery(event.target);
                elementRectangle = event.target.getBoundingClientRect();
                countdown = 1;

            }).on('dragover', function(event) {
                console.log('drag over');
                event.preventDefault();
                event.stopPropagation();
                if (countdown % 15 != 0 && currentElementChangeFlag == false) {
                    countdown = countdown + 1;
                    return;
                }

                event = event || window.event;

                var x = event.originalEvent.clientX;
                var y = event.originalEvent.clientY;
                countdown = countdown + 1;
                currentElementChangeFlag = false;
                var mousePosition = {
                    x: x,
                    y: y
                };
                if (!win.dragoverqueueProcessTimerTask) {
                    win.dragoverqueueProcessTimerTask = new Compass.ErpApp.Utility.TimerTask(function() {
                        DragDropFunctions.ProcessDragOverQueue();
                    }, 100);
                    win.dragoverqueueProcessTimerTask.start();
                }
                DragDropFunctions.AddEntryToDragOverQueue(currentElement, elementRectangle, mousePosition);
            }).on('dragleave', function(event) {
                console.log('drag leave');
                //return and remove placeholders if dropped out drop target
                if (jQuery(event.target).parents('div[class="dnd-drop-target"]').length == 0) {
                    me.endWidgetDragDrop();
                    return;
                }
            }).on('drop', function(event) {
                event.preventDefault();
                event.stopPropagation();
                var dropTarget = jQuery(this);
                var insertionPoint = jQuery("iframe").contents().find(".drop-marker");
                //don't let the component drop before the drop markers appear
                if (insertionPoint.length == 0) {
                    me.endWidgetDragDrop();
                    return;
                }
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
                                var previousComponent = dropTarget.parents('body').find('#' + uuid);
                                // don't drop a component is dropped over itself
                                if (previousComponent.parent()[0] == dropTarget[0]) {
                                    return;
                                }

                                previousComponent.parent().removeAttr('data-widget-statement');
                                previousComponent.parent().removeClass('dnd-drop-target-occupied');
                                previousComponent.remove();
                                
                                var dropComponent = me.insertWidget(responseObj.source);
                                dropComponent.parent().addClass('dnd-drop-target-occupied');
                                dropComponent.parent().attr('data-widget-statement', widgetStatement);

                                me.endWidgetDragDrop();

                                // attach drag listener
                                me.attachIframeDragStartListener(iframeNode);
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
                                        dropComponent.parent().addClass('dnd-drop-target-occupied');
                                        // store widget render statement barring <%= %> in its parent data arribute
                                        // we leave out the <%= %> to prevent it from getting evalauated when it renders
                                        // in the builder view.
                                        dropComponent.parent().attr('data-widget-statement', content.match(/<%=(((.|[\s\S])*?))%>/)[1]);

                                        me.endWidgetDragDrop();
                                        
                                        // attach drag listener
                                        me.attachIframeDragStartListener(iframeNode);

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

        me.attachIframeDragStartListener(iframeNode);
    },

    
    endWidgetDragDrop: function() {
        var win = this.up('window');
        if (win.dragoverqueueProcessTimerTask && win.dragoverqueueProcessTimerTask.isRunning()) {
            win.dragoverqueueProcessTimerTask.stop();
            DragDropFunctions.removePlaceholder();
            DragDropFunctions.ClearContainerContext();
            win.dragoverqueueProcessTimerTask = null;
        }
    },
    
    insertWidget: function(widgetSource) {
        // get the drop markers
        var insertionPoint = jQuery("iframe").contents().find(".drop-marker");

        var itemContent = insertionPoint.parents('.item.content'),
            iframeId = itemContent.data('container') + '-frame' + itemContent.data('frame-uuid');
        // get the container frame from the insertion point
        var containerFrame = document.getElementById(iframeId),
            containerWindow = containerFrame.contentWindow,
            containerDocument = containerFrame.contentDocument || containerWindow.document;

        // The widget source contains DOM elements and script tags which needs
        // to be executed in the context of the container iframe.
        
        var dropComponent = jQuery(widgetSource);
        // accumulate scripts
        scripts = [];
        dropComponent.children().filter('script').each(function(){
            scripts.push(jQuery(this).detach().html());
        });
        // insert widget DOM
        insertionPoint.after(dropComponent);
        
        // execute accumulated scripts
        scripts.forEach(function(script){
            var expression = 'return function(window, document){\n' + script + '\n}',
                scriptFunc = new Function(expression)();
            scriptFunc.apply(containerWindow, [containerWindow, containerDocument]);
        });

        //remove drop markers 
        insertionPoint.remove();
        
        return dropComponent;
    },
    
    fetchComponentSource: function(componentIid, success, failure) {
        var me = this;
        Compass.ErpApp.Utility.ajaxRequest({
            url: '/knitkit/erp_app/desktop/website_builder/get_component_source',
            method: 'GET',
            params: {
                website_id: me.getWebsiteId(),
                website_section_id: me.websiteSectionId,
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

    saveComponentSource: function(componentIid, componentSource, success, failure) {
        var me = this;
        Compass.ErpApp.Utility.ajaxRequest({
            url: '/knitkit/erp_app/desktop/website_builder/save_component_source',
            method: 'POST',
            params: {
                website_id: me.getWebsiteId(),
                website_section_id: me.websiteSectionId,
                component_iid: componentIid,
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
                    Ext.Msg.alert('Error', 'Error saving source');
                }
            }
        });
    },

    attachIframeDragStartListener: function(iframeNode) {
        var win = Ext.getCmp('knitkit');
        var dragImg = new Image();
        dragImg.src = '/assets/knitkit/website_builder/drag.png';

        jQuery(iframeNode.contentDocument).find('[draggable=true]').unbind('dragstart');
        jQuery(iframeNode.contentDocument).find('[draggable=true]').on('dragstart', function(event) {
            var draggableElem = jQuery(this);
            var uuid = draggableElem.attr('id');
            if (uuid) {
                if (!win.dragoverqueueProcessTimerTask) {
                    win.dragoverqueueProcessTimerTask = new Compass.ErpApp.Utility.TimerTask(function() {
                        DragDropFunctions.ProcessDragOverQueue();
                    }, 100);
                    win.dragoverqueueProcessTimerTask.start();
                }
                event.originalEvent.dataTransfer.setData("uuid", uuid);
                event.originalEvent.dataTransfer.setData("widget-statement", draggableElem.parent().data('widget-statement'))
                event.originalEvent.dataTransfer.setDragImage(dragImg, 10, 10);
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
            me.add(
                [
                    me.buildLayoutConfig('header'), {
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
                    me.buildLayoutConfig('footer')
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
                    if (Compass.ErpApp.Utility.isBlank(response.components)) {
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
                        var components = Ext.Array.flatten(Ext.Object.getValues(response.components));
                        Ext.each(components, function(component) {

                            me.addContentBlockConfig(component.iid, {
                                height: component.height,
                                thumbnail: component.thumbnail
                            });

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

                            me.loadContentBlock(componentContainer.down('component'), component.iid, component.height, component.thumbnail);
                        });
                    }
                }
            });

        }
    },

    buildLayoutConfig: function(templateType) {
        var me = this;
        
        // if is header or footer is already present render it as a component else render websitebuilderdropzone
        var componentIid = me.themeLayoutConfig[templateType + 'ComponentIid'],
            componentHeight = me.themeLayoutConfig[templateType + 'ComponentHeight'];

        if (componentIid) {
            layoutCompConfig = {
                xtype: 'component',
                componentId: componentIid,
                isLayout: true,
                cls: 'websitebuilder-component-panel',
                html: me.buildContentBlockTemplate(componentIid),
                listeners: {
                    render: function(comp) {
                        comp.setHeight(componentHeight);
                        comp.componentId = componentIid;
                        
                        var loadMask = new Ext.LoadMask(comp, {
                            msg: "Please wait..."
                        });
                        loadMask.show();
                        
                        Ext.get(componentIid + '-remove').on('click', function() {
                            me.insert(me.items.indexOf(comp), {
                                xtype: 'websitebuilderdropzone',
                                itemId: 'layout' + templateType.capitalize(),
                                flex: 1
                            });
                            comp.destroy();
                        });
                        
                        var iframe = Ext.get(comp.el.down('div.iframe-container > iframe'));
                        
                        iframe.on('load', function() {
                            loadMask.hide();
                            var iframeNode = iframe.el.dom;
                            var editableElements = Ext.get(iframeNode.contentDocument.documentElement).query("[data-selector]");
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
                                        var contentEditableElements = Ext.get(iframeNode.contentDocument.documentElement).query("[data-selector]");
                                        Ext.Array.each(contentEditableElements, function(element) {
                                            me.removeEditable(element);
                                            me.deHighlightElement(element);
                                        });
                                    }
                                    
                                    me.buildPropertiesEditForm(this.dom);
                                });
                            });
                            
                        }); // iframe load
                    } // render
                } // listeners
            }; // comp
        } else {
            layoutCompConfig = {
                xtype: 'websitebuilderdropzone',
                flex: 1,
                html: '<div>Drop' + templateType.capitalize() + 'Here</div>'
            };
        }

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

    isThemeMode: function() {
        return this.isForTheme;
    },
    
    toggleLayout: function() {
        var me = this;

        if(me.isThemeMode()) {
            return;
        }
        
        if(me.isLayoutIncluded == undefined) {
            me.isLayoutIncluded = false;
        }
        
        if(!me.isLayoutIncluded) {
            me.isLayoutIncluded = true;
            me.insert(0, me.buildLayoutConfig('header'));
            me.add(me.buildLayoutConfig('footer'));
        } else {
            me.isLayoutIncluded = false;
            Ext.each(me.query('[isLayout=true]'), function(item){
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
