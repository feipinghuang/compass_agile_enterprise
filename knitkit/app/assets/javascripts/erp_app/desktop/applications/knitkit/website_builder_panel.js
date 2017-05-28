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

        me.containerConfig = {};

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
                        var draggedPanel = Ext.getCmp(data.panelId),
                            containerPanel = Ext.ComponentQuery.query('websitebuilderpanel').first();

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

                                    me.replaceDropPanelWithContent(dropPanel, responseData.iid, responseData.height, responseData.thumbnail);
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

    addContainerConfig: function(iid, config) {
        this.containerConfig[iid] = {
            height: config.height,
            thumbnail: config.thumbnail
        };
    },

    deleteContainerConfig: function(iid) {
        delete this.containerConfig[iid];
    },

    getContainerConfig: function(iid) {
        return this.containerConfig[iid];
    },

    buildContainersPayload: function() {
        var me = this,
            containerPanels = me.query("[cls=websitebuilder-component-panel]");
        return Ext.Array.map(containerPanels, function(container, index) {
            var iframe = container.el.query("#" + container.componentId + "-frame").first(),
                containerHTML = iframe.contentDocument.documentElement.getElementsByClassName('page')[0].outerHTML,
                containerElem = jQuery(containerHTML);
            // containerElem.find('.compass_ae-widget').replaceWith(function(){
            //     return jQuery(jQuery(this).data('widget-content'));
            // });
            return {
                position: index,
                content_iid: container.componentId,
                body_html: Ext.String.htmlDecode(containerElem[0].outerHTML)
            };
        });
    },

    replaceDropPanelWithContent: function(dropPanel, componentIid, height, thumbnail) {
        var me = this;
        var websiteId = me.getWebsiteId();
        var containerPanel = Ext.ComponentQuery.query('websitebuilderpanel').first();

        me.addContainerConfig(componentIid, {
            height: height,
            thumbnail: thumbnail
        });

        dropPanel.removeCls('website-builder-dropzone');
        Ext.apply(dropPanel, {
            cls: "websitebuilder-component-panel",
            thumbnail: thumbnail
        });

        dropPanel.update(new Ext.XTemplate('<div class="component" style="height:100%;width:100%;position:relative;" panelId="{panelId}" >',
            '<div class="website-builder-reorder-setting" id="componentSetting">',
            '<div class="icon-edit-code pull-left" id="{componentId}-source" style="margin-right:5px;"></div>',

            '<div class="icon-move pull-left" panelId="{panelId}" style="margin-right:5px;"></div>',
            '<div class="icon-remove pull-left" id="{componentId}-remove" itemId="{panelId}"></div>',
            '</div>',
            '<div class="iframe-container">',
            '<iframe height="100%" width="100%" frameBorder="0" id="{componentId}-frame" src="{htmlSrc}"></iframe>',
            '</div>',
            '</div>').apply({
            htmlSrc: '/knitkit/erp_app/desktop/website_builder/render_component.html?component_iid=' + componentIid + '&id=' + websiteId + '&website_section_id=' + me.websiteSectionId + '&cache_buster_token=' + Math.round(Math.random() * 10000000),
            panelId: dropPanel.id,
            componentId: componentIid
        }));

        Ext.apply(dropPanel, {
            height: height,
            componentId: componentIid
        });

        Ext.get(componentIid + '-source').on('click', function() {
            if (dropPanel.cls == 'websitebuilder-component-panel') {
                me.fetchComponentSource(
                    componentIid,
                    function(responseObj) {
                        console.log(responseObj.is_content_saved);
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
                                            var componentConfig = me.getContainerConfig(componentIid);
                                            me.replaceDropPanelWithContent(
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
                                    var componentConfig = me.getContainerConfig(componentIid);
                                    me.replaceDropPanelWithContent(
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
                me.deleteContainerConfig(componentIid);
            }
        });

        // Assigning click event inside iFrame content
        var iframe = Ext.get(componentIid + "-frame");

        iframe.on('load', function() {
            var iframePanel = this,
                editableElements = Ext.get(iframePanel.el.dom.contentDocument.documentElement).query("[data-selector]"),
                websiteBuilderEditConfig = Compass.ErpApp.Desktop.Applications.Knitkit.WebsiteBuilder.config;

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

            //setup widget drop listeners
            me.setupIframeDragDropListeners(iframe.el.dom.contentWindow);

        });

        containerPanel.updateLayout();
    },

    // setup iframe drag and drop
    setupIframeDragDropListeners: function(iframeWindow) {
        var me = this;
        var currentElement, currentElementChangeFlag, elementRectangle, countdown, dragoverqueue_processtimer;

        var dragImg = new Image();
        dragImg.src = '/assets/knitkit/website_builder/drag.png';

        //Add CSS File to iFrame
        var style = jQuery("<style data-reserved-styletag></style>").html(GetInsertionCSS());
        jQuery(iframeWindow.document.head).append(style);

        var win = Ext.getCmp('knitkit');

        jQuery(iframeWindow.document).find('html,body').find('.dnd-drop-target')
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
                    if (win.dragoverqueueProcessTimerTask && win.dragoverqueueProcessTimerTask.isRunning()) {
                        win.dragoverqueueProcessTimerTask.stop();
                        DragDropFunctions.removePlaceholder();
                        DragDropFunctions.ClearContainerContext();
                        win.dragoverqueueProcessTimerTask = null;
                    }
                    return;
                }
            }).on('drop', function(event) {
                event.preventDefault();
                event.stopPropagation();
                var dropTarget = jQuery(this);
                var insertionPoint = jQuery("iframe").contents().find(".drop-marker");
                //don't let the component drop before the drop markers appear
                if (insertionPoint.length == 0) {
                    if (win.dragoverqueueProcessTimerTask && win.dragoverqueueProcessTimerTask.isRunning()) {
                        win.dragoverqueueProcessTimerTask.stop();
                        DragDropFunctions.removePlaceholder();
                        DragDropFunctions.ClearContainerContext();
                        win.dragoverqueueProcessTimerTask = null;
                    }
                    return;
                }
                var uuid = event.originalEvent.dataTransfer.getData('uuid');
                if (uuid) {
                    try {
                        var widgetStatement = event.originalEvent.dataTransfer.getData('widget-statement');
                        Compass.ErpApp.Utility.ajaxRequest({
                            url: '/knitkit/erp_app/desktop/website_builder/widget_source',
                            method: 'GET',
                            params: {
                                content: '<%=' + widgetStatement + '%>'
                            },
                            success: function(responseObj) {
                                var dropComponent = jQuery(responseObj.source);
                                var previousComponent = dropTarget.parents('body').find('#' + uuid);
                                // don't drop a component is dropped over itself
                                if (previousComponent.parent()[0] == dropTarget[0]) {
                                    return;
                                }

                                previousComponent.parent().removeAttr('data-widget-statement');
                                previousComponent.parent().removeClass('dnd-drop-target-occupied');
                                previousComponent.remove();
                                insertionPoint.after(dropComponent);
                                dropComponent.parent().addClass('dnd-drop-target-occupied');
                                dropComponent.parent().attr('data-widget-statement', widgetStatement);
                                insertionPoint.remove();

                                if (win.dragoverqueueProcessTimerTask && win.dragoverqueueProcessTimerTask.isRunning()) {
                                    win.dragoverqueueProcessTimerTask.stop();
                                    DragDropFunctions.removePlaceholder();
                                    DragDropFunctions.ClearContainerContext();
                                    win.dragoverqueueProcessTimerTask = null;
                                }

                                // attach drag listener
                                me.attachIframeDragStartListener(iframeWindow);
                            }
                        });

                    } catch (e) {
                        console.log(e);
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
                                method: 'GET',
                                params: {
                                    content: content
                                },
                                success: function(responseObj) {
                                    try {
                                        insertionPoint = jQuery("iframe").contents().find(".drop-marker");
                                        dropComponent = jQuery(responseObj.source);
                                        insertionPoint.after(dropComponent);
                                        dropComponent.parent().addClass('dnd-drop-target-occupied');
                                        // store widget render statement barring <%= %> in its parent data arribute
                                        // we leave out the <%= %> to prevent it from getting evalauated when it renders
                                        // in the builder view.
                                        dropComponent.parent().attr('data-widget-statement', content.match(/<%=(((.|[\s\S])*?))%>/)[1]);
                                        insertionPoint.remove();

                                        if (win.dragoverqueueProcessTimerTask && win.dragoverqueueProcessTimerTask.isRunning()) {
                                            win.dragoverqueueProcessTimerTask.stop();
                                            DragDropFunctions.removePlaceholder();
                                            DragDropFunctions.ClearContainerContext();
                                            win.dragoverqueueProcessTimerTask = null;
                                        }


                                        // attach drag listener
                                        me.attachIframeDragStartListener(iframeWindow);

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

        me.attachIframeDragStartListener(iframeWindow);
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

    attachIframeDragStartListener: function(iframeWindow) {
        var win = Ext.getCmp('knitkit');
        var dragImg = new Image();
        dragImg.src = '/assets/knitkit/website_builder/drag.png';

        jQuery(iframeWindow.document).find('[draggable=true]').unbind('dragstart');
        jQuery(iframeWindow.document).find('[draggable=true]').on('dragstart', function(event) {
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
                    //extensions: {
                    //    'highlighter': HighlighterButton
                    // }

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

                            me.addContainerConfig(component.iid, {
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

                            me.replaceDropPanelWithContent(componentContainer.down('component'), component.iid, component.height, component.thumbnail);
                        });
                    }
                }
            });

        }
    },

    buildLayoutConfig: function(templateType) {
        var me = this;
        if (!me.isThemeMode()) {
            throw ("can't call this function for anything other than a theme builder");
        }
        // templateType can be header or footer for now and we assume that its in a shared partial
        // in the themes view path
        var templatePath = '/shared/knitkit/_' + templateType;
        var layoutCompConfig = null;

        // if is header or footer is already present render it as a component else render websitebuilderdropzone
        var componentIid = me.themeLayoutConfig[templateType + 'ComponentIid'],
            componentHeight = me.themeLayoutConfig[templateType + 'ComponentHeight'];

        if (componentIid) {
            layoutCompConfig = {
                xtype: 'component',
                componentId: componentIid,
                cls: 'websitebuilder-component-panel',
                html: new Ext.XTemplate('<div style="height:100%;width:100%;position:relative;"><div class="website-builder-reorder-setting" id="componentSetting"><div class="icon-move pull-left" style="margin-right:5px;" id="{compId}-move"></div><div class="icon-remove pull-left" id="{compId}-remove"></div></div><iframe id="{compId}-frame" src="' + me.templatePreviewURL(templatePath) + '" width="100%" height="100%" frameborder="0">').apply({
                    compId: componentIid
                }),
                listeners: {
                    render: function(comp) {
                            Ext.apply(comp, {
                                height: componentHeight,
                                componentId: componentIid
                            });
                            Ext.get(componentIid + '-remove').on('click', function() {
                                me.insert(me.items.indexOf(comp), {
                                    xtype: 'websitebuilderdropzone',
                                    itemId: 'layout' + templateType.capitalize(),
                                    flex: 1
                                });
                                comp.destroy();
                            });

                            var iframe = Ext.get(componentIid + "-frame");

                            iframe.on('load', function() {
                                var iframePanel = this,
                                    editableElements = Ext.get(iframePanel.el.dom.contentDocument.documentElement).query("[data-selector]"),
                                    websiteBuilderEditConfig = Compass.ErpApp.Desktop.Applications.Knitkit.WebsiteBuilder.config;
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
        return this.isForTheme && !Compass.ErpApp.Utility.isBlank(this.themeLayoutConfig);
    },

    templatePreviewURL: function(templatePath) {
        var me = this;
        var websiteId = me.getWebsiteId();
        var url = "";

        url = '/knitkit/erp_app/desktop/theme_builder/render_theme_component?website_id=' + websiteId + '&template_path=' + templatePath;
        // append a random param to prevent the browser from caching its contents when this is requested from an iframe
        url = url + '&cache_buster_token=' + Math.round(Math.random() * 10000000);
        return url;
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