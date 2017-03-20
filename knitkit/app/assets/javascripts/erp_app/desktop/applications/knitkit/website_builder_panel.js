Ext.define('Compass.ErpApp.Desktop.Applications.ApplicationManagement.WebsiteBuilderDropZone', {
    extend: 'Ext.Component',
    alias: 'widget.websitebuilderdropzone',
    autoRemovableDropZone: false,
    replaceContentOfDraggedPanel: true,
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

        if (!me.isThemeMode()) {
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
                                    var win = btn.up('window');
                                    var indexToInsert = me.items.getCount() - 1;

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

        me.on('render', function() {

            me.dragZone = Ext.create('Ext.dd.DragZone', me.getEl(), {
                ddGroup: 'websiteBuilderPanelDDgroup',
                getDragData: function(e) {
                    Ext.each(me.el.query('.iframe-cover'), function(el) {
                        Ext.get(el).addCls('move');
                    });

                    var ele = e.getTarget('.icon-move'),
                        targetId = null;

                    if (ele) {
                        targetId = ele.getAttribute('panelId');
                    }
                    if (targetId) {
                        var element = Ext.getCmp(targetId),
                            dragEl = element.getEl(),
                            height = element.getEl().getHeight(),
                            width = element.getEl().getWidth(),
                            d = dragEl.dom.cloneNode(true);
                        d.id = Ext.id();
                        Ext.fly(d).setHTML('<img src="' + element.thumbnail + '" style="width:186px;height:80px">');
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
                    Ext.each(me.el.query('.iframe-cover'), function(el) {
                        Ext.get(el).removeCls('move');
                    });

                    me.removeAutoRemovableDropZones();

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
                    if (Ext.fly(target).hasCls('component')) {
                        me.removeAutoRemovableDropZones();
                        var targetPanelId = target.getAttribute('panelId'),
                            targetPanel = Ext.getCmp(targetPanelId),
                            parentContainer = targetPanel.up('container'),
                            websiteBuilderPanel = parentContainer.up('websitebuilderpanel');
                        if (targetPanel.cls == "websitebuilder-component-panel" &&
                            parentContainer.hasCls('dropzone-container') &&
                            targetPanel.id !== dragData.panelId) {
                            var targetIndex = websiteBuilderPanel.items.indexOf(parentContainer);
                            websiteBuilderPanel.insert(targetIndex, {
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
                            websiteBuilderPanel.insert(targetIndex + 2, {
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
                            websiteBuilderPanel.doLayout();
                        }
                    }

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

                        Ext.each(me.el.query('.iframe-cover'), function(el) {
                            Ext.get(el).removeCls('move');
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

            me.addFieldDropZones();
        });

        me.callParent();
    },

    getWebsiteId: function() {
        var websitesCombo = Ext.ComponentQuery.query("websitescombo").first();
        return websitesCombo.getValue();
    },

    replaceDropPanelWithContent: function(dropPanel, componentIid, height, thumbnail) {
        var me = this;
        var websiteId = me.getWebsiteId();
        var containerPanel = Ext.ComponentQuery.query('websitebuilderpanel').first();

        dropPanel.removeCls('website-builder-dropzone');
        Ext.apply(dropPanel, {
            cls: "websitebuilder-component-panel",
            thumbnail: thumbnail
        });

        dropPanel.update(new Ext.XTemplate('<div class="component" style="height:100%;width:100%;position:relative;" panelId="{panelId}" >',
                                           '<div class="website-builder-reorder-setting" id="componentSetting">',
                                           '<div class="icon-move pull-left" panelId="{panelId}" style="margin-right:5px;"></div>',
                                           '<div class="icon-remove pull-left" id="{componentId}-remove" itemId="{panelId}"></div>',
                                           '</div>',
                                           '<div class="iframe-container">',
                                           '<div class="iframe-cover"></div>',
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

        Ext.get(componentIid + "-remove").on("click", function() {
            parentContainer = dropPanel.up('container');
            if (dropPanel.cls == "websitebuilder-component-panel" && parentContainer.hasCls('dropzone-container')) {
                parentContainer.insert(parentContainer.items.indexOf(dropPanel), {
                    xtype: 'websitebuilderdropzone',
                    flex: 1
                });

                dropPanel.destroy();
            }
        });

        // Assigning click event inside iFrame content
        var iframe = Ext.get(componentIid + "-frame");

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

            //setup widget drop listeners
            me.setupIframeDragDropListeners(iframe.el.dom.contentWindow);

        });


        // containerPanel.removeFieldDropZone(target);
        // containerPanel.addFieldDropZones();
        containerPanel.updateLayout();
    },

    // setup iframe drag and drop
    setupIframeDragDropListeners: function(iframeWindow) {
        var me = this;
        var currentElement, currentElementChangeFlag, elementRectangle, countdown, dragoverqueue_processtimer;
        
        var dragImg = new Image();
        dragImg.src = '/assets/image/knitkit/website_builder/drag.png';
        
        //Add CSS File to iFrame
        var style = jQuery("<style data-reserved-styletag></style>").html(GetInsertionCSS());
        jQuery(iframeWindow.document.head).append(style);

        var win = Ext.getCmp('knitkit');
        
        jQuery(iframeWindow.document).find('html,body')
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
                DragDropFunctions.AddEntryToDragOverQueue(currentElement, elementRectangle, mousePosition);
            }).on('drop', function(event) {
                event.preventDefault();
                event.stopPropagation();
                var iframe = jQuery(this);
                var websiteId = me.getWebsiteId();
                var uid = event.originalEvent.dataTransfer.getData('drag-uid');
                var componentIid = event.originalEvent.dataTransfer.getData('componentIid');
                // if this is a drop but the componentiid is blank it must be a move from the iframe
                if (uid && Compass.ErpApp.Utility.isBlank(componentIid)) {
                    try {
                        var insertionPoint = jQuery("iframe").contents().find(".drop-marker");
                        var dropComponent = jQuery(event.originalEvent.dataTransfer.getData('componentHTML'));
                        var previousComponent = iframe.find('[drag-uid=' + uid + ']');
                        previousComponent.remove();
                        insertionPoint.after(dropComponent);
                        dropComponent.css('cursor', 'move');
                        dropComponent.attr('drag-uid', new Date().getTime());
                        dropComponent.attr('draggable', true);
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
                        console.log(e);
                    }
                } else {
                    // this is a drop from the west region so load the component source from its iid
                    me.fetchComponentSource(
                        event.originalEvent.dataTransfer.getData('componentIid'),
                        function(response) {
                            var componentHTML = response.component.html;
                            try {
                                var insertionPoint = jQuery("iframe").contents().find(".drop-marker");
                                var dropComponent = jQuery(componentHTML);
                                insertionPoint.after(dropComponent);
                                dropComponent.css('cursor', 'move');
                                dropComponent.attr('drag-uid', new Date().getTime());
                                dropComponent.attr('draggable', true);
                                insertionPoint.remove();

                                // attach drag listener
                                me.attachIframeDragStartListener(iframeWindow);


                                
                            } catch (e) {
                                console.log(e);
                            }
                        }
                    );
                }
                
                
            });

        me.attachIframeDragStartListener(iframeWindow);
        
    },


    fetchComponentSource: function(componentIid, success) {
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
            }
        });
            
    },

    attachIframeDragStartListener: function(iframeWindow) {
        var win = Ext.getCmp('knitkit');
        var dragImg = new Image();
        dragImg.src = '/assets/image/knitkit/website_builder/drag.png';

        jQuery(iframeWindow.document).find('[draggable=true]').unbind('dragstart');
        jQuery(iframeWindow.document).find('[draggable=true]').on('dragstart', function(event) {
            var draggableElem = jQuery(this);
            var uid = draggableElem.attr('drag-uid');
            if(uid) {
                if (!win.dragoverqueueProcessTimerTask) {
                    win.dragoverqueueProcessTimerTask = new Compass.ErpApp.Utility.TimerTask(function() {
                        DragDropFunctions.ProcessDragOverQueue();
                    }, 100);
                    win.dragoverqueueProcessTimerTask.start();
                }
                event.originalEvent.dataTransfer.setData("componentHtml", jQuery("<div />").append(draggableElem.clone()).html());
                event.originalEvent.dataTransfer.setData("drag-uid", uid);
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

    addFieldDropZones: function() {
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
                        Ext.each(components, function(component){
                            console.log(component);
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

    isThemeMode: function() {
        return this.isForTheme && !Compass.ErpApp.Utility.isBlank(this.themeLayoutConfig);
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
