Ext.define('Compass.ErpApp.Desktop.Applications.Knitkit.WebsiteBuilderDropZoneContainer', {
    extend: 'Ext.Container',
    alias: 'widget.websitebuilderdropzonecontainer',
    autoRemovableDropZone: false,
    border: 1,
    margin: '1 1 1 1',
    style: {
        borderColor: '#e1e4e9',
        borderStyle: 'dotted'
    },
    empty: function() {
        return Ext.isEmpty(this.el.query('iframe'));
    },
    listeners: {
        afterrender: function(container) {
            container.update(
                new Ext.XTemplate(
                    '<div id="outer-{containerId}" class="website-builder-reorder-setting">',
                    '  <div class="icon-move pull-left" containerId = "{containerId}" style="margin-right:5px;"></div>',
                    '  <div class="icon-remove pull-left" style="margin-right:5px;"></div>',
                    '</div>'
                ).apply({
                    containerId: container.id
                })
            );


            $('#outer-' + container.id).on('mouseenter', function(){
                $(this).css('background-color', '#ccc');
                $(this).children().show();
            }).on('mouseleave', function(){
                $(this).children().hide();
                $(this).css('background-color', '');
            });

            container.el.down('.icon-remove').on('click', function(){
                container.destroy();
            })
        }
    }
});

Ext.define('Compass.ErpApp.Desktop.Applications.Knitkit.WebsiteBuilderDropZone', {
    extend: 'Ext.Component',
    alias: 'widget.websitebuilderdropzone',
    componentId: null,
    cls: 'website-builder-dropzone',
    height: 150,
    componentType: null,
    html: '<div>Drop Component Here</div>',
    autoRemovableDropZone: false,
    empty: false,
    border: 1,
    margin: '10 10 10 10',
    style: {
        borderColor: '#e1e4e9',
        borderStyle: 'solid'
    },
    listeners: {
        afterrender: function(comp) {
            if (!comp.autoRemovableDropZone && comp.empty) {
                comp.update('<div>Drop Component Here</div><div class="website-builder-reorder-setting"><div class="icon-remove pull-left" id="remove"></div></div>');

                Ext.get(comp.el.query('.icon-remove')).on('click', function() {
                    comp.destroy();
                });
            }
        }
    }
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
    rowHeights: {},
    matchWebsiteSectionContents: {},
    contentToLoad: [],

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

        if (me.savedScrollPos !== undefined) {
            console.log(me.savedScrollPos)
            var heightDiff = null;
            if (me.currentHeight) {
                heightDiff = Ext.get(me.el.query('.x-panel-body')).first().query('div').first().clientHeight - me.currentHeight;
            } else {
                heightDiff = 0;
            }

            me.body.scrollTo('top', me.savedScrollPos + heightDiff);
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
                                            xtype: 'websitebuilderdropzonecontainer',
                                            cls: 'dropzone-container',
                                            layout: 'hbox',
                                            items: [{
                                                xtype: 'websitebuilderdropzone',
                                                empty: true,
                                                componentType: 'content',
                                                flex: 1
                                            }]
                                        });
                                    }

                                    if (win.down('#twoCol').getValue()) {
                                        me.insert(indexToInsert, {
                                            xtype: 'websitebuilderdropzonecontainer',
                                            cls: 'dropzone-container',
                                            layout: 'hbox',
                                            items: [{
                                                xtype: 'websitebuilderdropzone',
                                                componentType: 'content',
                                                empty: true,
                                                contentBlock: true,
                                                flex: 1

                                            }, {
                                                xtype: 'websitebuilderdropzone',
                                                componentType: 'content',
                                                empty: true,
                                                contentBlock: true,
                                                flex: 1
                                            }]
                                        });
                                    }

                                    if (win.down('#threeCol').getValue()) {
                                        me.insert(indexToInsert, {
                                            xtype: 'websitebuilderdropzonecontainer',
                                            cls: 'dropzone-container',
                                            layout: 'hbox',
                                            items: [{
                                                xtype: 'websitebuilderdropzone',
                                                componentType: 'content',
                                                empty: true,
                                                contentBlock: true,
                                                flex: 1
                                            }, {
                                                xtype: 'websitebuilderdropzone',
                                                componentType: 'content',
                                                empty: true,
                                                contentBlock: true,
                                                flex: 1

                                            }, {
                                                xtype: 'websitebuilderdropzone',
                                                componentType: 'content',
                                                empty: true,
                                                contentBlock: true,
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
            if(!me.isThemeMode())
                me.resetContentEditorToolbar();
            Ext.getCmp('knitkitWestRegion').addComponentsTabPanel(me.isThemeMode());
        });

        me.on('deactivate', function() {
            if(!me.isThemeMode())
                me.resetContentEditorToolbar();
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
                    if (me.hasEmptyContainerOrContentBlock()){
                        Ext.Msg.alert('Error', 'Cannot move when there are empty content blocks');
                        return false;
                    } 
                    me.disableComponents();
                    if (data.isContainer) {
                        me.addAutoRemovableContainers(data.containerId);
                    } else {
                        me.addAutoRemovableDropZones(data.panelId);
                    }
                    me.dragStarted = true;
                },

                onMouseUp: function(e) {
                    if (me.dragStarted) {
                        me.enableComponents();
                        me.removeAutoRemovableDropZonesAndContainers();
                        me.dragStarted = false;
                    }
                        
                },
                
                afterDragDrop: function(target, e, id) {
                    me.enableComponents();
                    me.removeAutoRemovableDropZonesAndContainers();
                    me.dragStarted = false;
                },

                afterInvalidDrop: function(target, e, id) {
                    me.enableComponents();
                    me.removeAutoRemovableDropZonesAndContainers();
                    me.dragStarted = false;
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
                        dragElDom.querySelector('iframe').src = "";
                        this.proxy.el.dom.style.width = dragEl.dom.offsetWidth + "px";
                        return {
                            panelId: element.id,
                            repairXY: element.getEl().getXY(),
                            ddel: dragElDom,
                            websiteSectionContentId: element.websiteSectionContentId,
                            componentName: element.componentName,
                            componentType: element.componentType,
                            isMove: true,
                            isContainer: false,
                        };
                    } else {
                        if (moveEl) {
                            var containerId = moveEl.getAttribute('containerId');

                            if (containerId) {
                                var container = Ext.getCmp(containerId),
                                    dragElDom = container.getEl().dom.cloneNode(true);
                                
                                dragElDom.id = Ext.id();
                                Ext.each(dragElDom.querySelectorAll('iframe'), function(iframe){
                                    iframe.src = "";
                                });

                                var containerData = Ext.Array.map(container.query('websitebuilderdropzone'), function(element){
                                    return {
                                        websiteSectionContentId: element.websiteSectionContentId,
                                        componentName: element.componentName,
                                        componentType: element.componentType,
                                        isMove: true,
                                    };
                                });
                                
                                return {
                                    containerId: container.id,
                                    repairXY: container.getEl().getXY(),
                                    ddel: dragElDom,
                                    containerData: containerData,
                                    isContainer: true
                                }
                            }
                        }
                    }
                },

                getRepairXY: function() {
                    return this.dragData.repairXY;
                }
            });
            me.dragZone.proxy.addClass('website-builder-dragzone-ghost');
            
            me.dropZone = Ext.create('Ext.dd.DropZone', me.getEl(), {
                ddGroup: 'websiteBuilderPanelDDgroup',

                getTargetFromEvent: function(e) {
                    return e.getTarget('.website-builder-dropzone')||e.getTarget('.component');
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
                        if (data.isContainer) {
                            var draggedContainer = Ext.getCmp(data.containerId);
                            var dropContainer = Ext.getCmp(Ext.fly(target).dom.id).up('websitebuilderdropzonecontainer');
                            this.dropContainer(dropContainer, draggedContainer, data.containerData);
                        } else {
                            var draggedPanel = Ext.getCmp(data.panelId);
                            var dropPanel = Ext.getCmp(Ext.fly(target).dom.id);
                            
                            this.dropContentBlock(dropPanel, draggedPanel, data);
                        }
                    }
                },

                onNodeOver: function(target, dd, e, data) {
                    if (this.validDrop(target, data)) {
                        return Ext.dd.DropZone.prototype.dropAllowed;
                    } else {
                        return Ext.dd.DropZone.prototype.dropNotAllowed;
                    }
                },
                
                validContentBlockDrop: function(target, dragData) {
                    if (Ext.get(target).id.indexOf('websitebuilderdropzone') === -1) {
                        return false;
                    } else {
                        var dropPanel = Ext.getCmp(Ext.get(target).id);
                        if (dragData.componentType == dropPanel.componentType || dragData.componentType == 'widget') {
                            return true;
                        } else {
                            return false;
                        }
                    }
                },

                validContainerDrop: function(target, dragData) {
                    return !(Ext.get(target.parentNode).id.indexOf('websitebuilderdropzonecontainer') === -1);
                },


                validDrop: function(target, dragData) {
                    if (dragData.isContainer) {
                        return this.validContainerDrop(target, dragData);
                    } else {
                        return this.validContentBlockDrop(target, dragData);
                    }
                },


                dropContentBlock: function(dropPanel, draggedPanel, data) {
                    if (dropPanel.autoRemovableDropZone) {
                        dropPanel.autoRemovableDropZone = false;
                    }
                    
                    if (draggedPanel && draggedPanel.componentType) {
                        dropPanel.componentType = draggedPanel.componentType;
                    }

                    if (data.websiteSectionContentId) {
                        me.loadContentBlock(dropPanel, {
                            autoSave: true,
                            websiteSectionContentId: data.websiteSectionContentId
                        });

                        me.removeContentFromDraggedPanel(dropPanel, draggedPanel);

                    } else if (data.widgetName) {
                        me.loadContentBlock(dropPanel, {
                            autoSave: true,
                            widgetName: data.widgetName
                        });

                        dropPanel.componentType = 'widget';

                    } else {
                        me.loadContentBlock(dropPanel, {
                            autoSave: true,
                            componentName: data.componentName,
                            componentType: data.componentType
                        });

                        me.removeContentFromDraggedPanel(dropPanel, draggedPanel);
                    }

                    me.removeAutoRemovableDropZonesAndContainers();
                },


                dropContainer: function(dropContainer, draggedContainer, containerData) {
                    if (dropContainer.autoRemovableDropZone) {
                        dropContainer.autoRemovableDropZone = false;
                    }
                    Ext.each(containerData, function(data){
                        var dropPanel = dropContainer.down('websitebuilderdropzone[websiteSectionContentId="' + data.websiteSectionContentId + '"]');
                        if (dropPanel.autoRemovableDropZone) {
                            dropPanel.autoRemovableDropZone = false;
                        }
                        
                        if (data.websiteSectionContentId) {
                            me.loadContentBlock(dropPanel, {
                                autoSave: true,
                                websiteSectionContentId: data.websiteSectionContentId
                            });
                        } else if (data.widgetName) {
                            me.loadContentBlock(dropPanel, {
                                autoSave: true,
                                widgetName: data.widgetName
                            });

                            dropPanel.componentType = 'widget';

                        } else {
                            me.loadContentBlock(dropPanel, {
                                autoSave: true,
                                componentName: data.componentName,
                                componentType: data.componentType
                            });
                        }

                    });
                    draggedContainer.destroy();
                    me.removeAutoRemovableDropZonesAndContainers();
                    
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

        me.savedScrollPos = me.body.dom.scrollTop;
        
        var components = me.query('websitebuilderdropzonecontainer');
        
        me.currentHeight = Ext.get(me.el.query('.x-panel-body')).first().query('div').first().clientHeight;

        var draggedComponent = Ext.getCmp(panelId),
            container = draggedComponent.up('websitebuilderdropzonecontainer');

        dropZones = container.query('websitebuilderdropzone');
        for (var colIndex = 0; colIndex <= dropZones.length; colIndex++) {
            container.insert(colIndex*2, {
                xtype: 'websitebuilderdropzone',
                html: '<div style="margin-top:-20px;font-size:15px;">Drop Component Here</div>',
                componentType: 'content',
                autoRemovableDropZone: true,
                flex: 1
            });
        }
        
        var components = container.query('websitebuilderdropzone')
        var componentIndex = components.indexOf(draggedComponent);
        var componentsToDestroy = []
        if (components[componentIndex - 1] && components[componentIndex - 1].autoRemovableDropZone)
            componentsToDestroy.push(components[componentIndex - 1]);
        
        if (components[componentIndex + 1] && components[componentIndex + 1].autoRemovableDropZone)
            componentsToDestroy.push(components[componentIndex + 1]);
        
        Ext.each(componentsToDestroy, function(comp){
            comp.destroy();
        });


        me.suspendLayout = false;
        me.doLayout();
    },
    
    addAutoRemovableContainers: function(containerId) {
        var me = this;
        me.suspendLayout = true;

        me.savedScrollPos = me.body.dom.scrollTop;

        me.currentHeight = Ext.get(me.el.query('.x-panel-body')).first().query('div').first().clientHeight;
        
        var containers = me.query('websitebuilderdropzonecontainer');

        var container = Ext.getCmp(containerId),
            dropZones = container.query('websitebuilderdropzone');
        
        for(var rowIndex = 0; rowIndex <= containers.length; rowIndex++) {
            me.insert(rowIndex*2, {
                xtype: 'websitebuilderdropzonecontainer',
                cls: 'dropzone-container',
                layout: 'hbox',
                autoRemovableDropZone: true,
                items: Ext.Array.map(dropZones, function(dropZone){
                    return {
                        xtype: 'websitebuilderdropzone',
                        html: '<div style="margin-top:-20px;font-size:15px;">Drop Component Here</div>',
                        componentType: 'content',
                        autoRemovableDropZone: true,
                        websiteSectionContentId: dropZone.websiteSectionContentId,
                        flex: 1
                    };
                })
            });
        }

        containers = me.query('websitebuilderdropzonecontainer');
        var containerIndex = containers.indexOf(container);
        var containersToDestroy = []
        if (containers[containerIndex - 1] && containers[containerIndex - 1].autoRemovableDropZone)
            containersToDestroy.push(containers[containerIndex - 1]);
        
        if (containers[containerIndex + 1] && containers[containerIndex + 1].autoRemovableDropZone)
            containersToDestroy.push(containers[containerIndex + 1]);

        Ext.each(containersToDestroy, function(comp){
            comp.destroy();
        });

        me.suspendLayout = false;
        me.doLayout();
    },

    removeAutoRemovableDropZones: function() {
        var me = this;
        Ext.each(me.query('websitebuilderdropzonecontainer'), function(dropZoneContainer) {
            var dropZones = dropZoneContainer.query('websitebuilderdropzone');
            Ext.each(dropZones, function(dropZone){
                if (dropZone.autoRemovableDropZone) {
                    dropZone.destroy();
                }
            });
        });
    },
    
    removeAutoRemovableContainers: function() {
        var me = this;
        Ext.each(me.query('websitebuilderdropzonecontainer'), function(container){
            if (container.autoRemovableDropZone) {
                container.destroy();
            }
        });
        
    },

    removeAutoRemovableDropZonesAndContainers: function() {
        var me = this
        me.suspendLayout = true;
        this.removeAutoRemovableDropZones();
        this.removeAutoRemovableContainers();
        me.suspendLayout = false;
        me.doLayout();
    },

    getWebsiteId: function() {
        var websitesCombo = Ext.ComponentQuery.query("websitescombo").first();
        return websitesCombo.getValue();
    },
    
    getContentBlockSubmitableHTML: function(dropPanel) {
        var iframe = dropPanel.el.down('.iframe-container > iframe').el.dom,
            html = null;
        // content block should either have contents or a widget
        if (iframe.contentDocument.body.querySelector('.container > .row > .col-md-12')) {
            html =  iframe.contentDocument.body.querySelector('.container > .row > .col-md-12').innerHTML;
        } else if (iframe.contentDocument.body.querySelector('.compass_ae-widget')){
            widgetStatement = iframe.contentDocument.body.querySelector('.compass_ae-widget').parentElement.getAttribute('data-widget-statement');
            html = "<%= " + widgetStatement + "%>"
        }
        return html;
    },
    
    saveComponents: function(successCallback, failureCallback) {
        var me = this;

        if (me.isThemeMode()) {
            var headerComp = me.query("[cls=websitebuilder-component-panel][componentType^='header']").first(),
                footerComp = me.query("[cls=websitebuilder-component-panel][componentType^='footer']").first();

            var headerHTML = null,
                footerHTML = null;

            if (headerComp) {
                var headerFrame = headerComp.getEl().down('.iframe-container > iframe').el.dom;
                headerHTML = headerFrame.contentDocument.documentElement.getElementsByClassName('pen')[0].outerHTML;
            }

            if (footerComp) {
                var footerFrame = footerComp.getEl().down('.iframe-container > iframe').el.dom;
                footerHTML = footerFrame.contentDocument.documentElement.getElementsByClassName('pen')[0].outerHTML;
            }

            Compass.ErpApp.Utility.ajaxRequest({
                url: '/knitkit/erp_app/desktop/theme_builder/' + me.themeLayoutConfig.themeId + '/update_layout',
                method: 'PUT',
                params: {
                    headerSource: headerHTML,
                    footerSource: footerHTML
                },
                success: function(response) {
                    if (successCallback)
                        successCallback();
                }
            });
        } else {
            if (me.down('codemirror')) {
                Ext.Msg.alert('Error', 'You must save exit source view of all content blocks');
                return;
            }
            
            var containerPanels = me.query("websitebuilderdropzonecontainer");
            components = [];

            Ext.each(containerPanels, function(container, rowIndex) {
                Ext.each(container.query('websitebuilderdropzone'), function(component, columnIndex) {
                    if (component.el.down('.iframe-container > iframe')) {
                        var html = me.getContentBlockSubmitableHTML(component)
                        var matchId = Math.round(Math.random() * 10000000);
                        
                        me.matchWebsiteSectionContents[matchId] = component;

                        var data = {
                            position: rowIndex,
                            column: columnIndex,
                            body_html: html,
                            match_id: matchId,
                            website_section_content_id: component.websiteSectionContentId
                        };

                        components.push(data);
                    }
                });
            });
            Ext.Ajax.request({
                url: '/knitkit/erp_app/desktop/website_builder/save_website.json',
                method: 'POST',
                params: {
                    id: me.getWebsiteId(),
                    website_section_id: me.websiteSectionId,
                    content: JSON.stringify(components)
                },
                success: function(response) {
                    var responseObj = Ext.decode(response.responseText);

                    if (responseObj.success) {
                        // set the unique ids for the containers
                        Ext.each(responseObj.website_section_contents, function(websiteSectionContent) {
                            me.matchWebsiteSectionContents[websiteSectionContent.match_id].uniqueId = websiteSectionContent.website_section_content_id;
                            me.matchWebsiteSectionContents[websiteSectionContent.match_id].websiteSectionContentId = websiteSectionContent.website_section_content_id;
                            delete me.matchWebsiteSectionContents[websiteSectionContent.match_id];
                        });

                        if (successCallback)
                            successCallback();
                    } else {
                        if (failureCallback)
                            failureCallback();
                    }
                },

                failure: function(response) {
                    if (failureCallback)
                        failureCallback();
                }
            });
        }
    },

    buildContentBlockTemplate: function(dropPanel, options) {
        var me = this,
            websiteId = me.getWebsiteId();

        options = options || {};

        var canViewSource = (options.canViewSource === undefined) ? true : options.canViewSource,
            canMove = (options.canMove === undefined) ? true : options.canMove,
            canRemove = (options.canRemove === undefined) ? true : options.canRemove,
            componentName = options.componentName,
            componentType = options.componentType,
            websiteSectionContentId = options.websiteSectionContentId,
            source = options.source,
            isCustomLayout =  options.customLayout
            url = '/knitkit/erp_app/desktop/website_builder/render_component.html',
            params = {authenticity_token: Compass.ErpApp.AuthentictyToken};
        if (source) {
            Ext.apply(params, {
                source: encodeURIComponent(source),
                id: websiteId
            });
        } else if (isCustomLayout) {
            Ext.apply(params, {
                id: websiteId,
                website_section_id: me.websiteSectionId,
                custom_layout: true
            });
        } else if (componentName) {
            Ext.apply(params, {
                component_type: componentType,
                component_name: componentName,
                id: websiteId,
                website_section_id: me.websiteSectionId
            });

        } else if (websiteSectionContentId) {
            Ext.apply(params, {
                website_section_content_id: websiteSectionContentId,
                id: websiteId
            });

        } else if (componentType == 'header' || componentType == 'footer') {
            url = '/knitkit/erp_app/desktop/theme_builder/render_theme_component.html';
            Ext.apply(params, {
                website_id: websiteId,
                component_type: componentType
            });

        } else {
            Ext.apply(params, {
                id: websiteId
            });
        }
        // append a random param to prevent the browser from caching its contents when this is requested from an iframe
        url = url + '&cache_buster_token=' + new Date().getTime();

        return new Ext.XTemplate(
            '<div class="component" style="height:100%;width:100%;position:relative;">',
            '<tpl if="canViewSource || canMove || canRemove">',
            '<div id="inner-{panelId}" class="website-builder-reorder-setting">',
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
            '<iframe height="100%" width="100%" frameBorder="0" id="{iframeId}" name="{iframeId}"></iframe>',
            '</div>',
            '<tpl else>',
            '<div class="iframe-container">',
            '<iframe height="100%" width="100%" frameBorder="0" id="{iframeId}" name="{iframeId}"></iframe>',
            '</div>',
            '</tpl>',
            '<form action="{url}" method="POST" target="{iframeId}">',
            '<tpl foreach="params">',
            '<input type="hidden" name="{$}" value="{.}">',
            '</tpl>',
            '</form>',
            '</div>'
        ).apply({
            panelId: dropPanel.id,
            uniqueId: options.uniqueId,
            iframeId: 'frame-' + options.uniqueId + '-' + new Date().getTime(),
            url: url,
            canViewSource: canViewSource,
            canMove: canMove,
            canRemove: canRemove,
            params: params
        });
    },

    loadContentBlock: function(dropPanel, options) {
        var me = this;
        var uniqueId = null;

        if (options.componentType == "header" || options.componentType == "footer") {
            uniqueId = options.componentType;

        } else if (options.websiteSectionContentId) {
            uniqueId = options.websiteSectionContentId;
            dropPanel.websiteSectionContentId = options.websiteSectionContentId;

        } else {
            uniqueId = new Date().getTime();
        }
        options['uniqueId'] = uniqueId;
        
        dropPanel.removeCls('website-builder-dropzone');

        Ext.apply(dropPanel, {
            cls: "websitebuilder-component-panel"
        });

        if (options.autoSave) {
            var loadMask = new Ext.LoadMask(me, {
                msg: "Please wait..."
            });
            loadMask.show();
        }
        dropPanel.update(me.buildContentBlockTemplate(dropPanel, options));
        var iframe = Ext.get(dropPanel.el.down('div.iframe-container > iframe'));
        document.querySelector('form[target="' + iframe.dom.id + '"]').submit();

        me.attachContentBlockListeners(dropPanel, uniqueId);

        iframe.on('load', function() {
            if (options.autoSave)
                loadMask.hide();

            if (options.afterload && typeof options.afterload === "function")
                options.afterload();
            
            var iframeNode = iframe.el.dom;
            
            if (options.widgetName) {
                var widgetsPanel = me.up('window').down('knitkit_WidgetsPanel');
                var widgetData = widgetsPanel.getWidgetData(options.widgetName);

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
                                    // get the container frame from the insertion point
                                    var containerWindow = iframeNode.contentWindow,
                                        containerDocument = iframeNode.contentDocument || containerWindow.document;

                                    containerWindow.eval("if (window.__pen__) window.__pen__.destroy();");
                                    containerWindow.loadMe('<div>' + responseObj.source + '</div>');
                                    dropComponent = jQuery(containerDocument).find('.compass_ae-widget');

                                    // store widget render statement barring <%= %> in its parent data arribute
                                    // we leave out the <%= %> to prevent it from getting evalauated when it renders
                                    // in the builder view.
                                    dropComponent.parent().attr('data-widget-statement', content.match(/<%=(((.|[\s\S])*?))%>/)[1].replace('"', "'"));
                                    dropComponent.parent().wrap('<div class="container"><div class="row"><div class="col-md-12"></div></div></div>')

                                    // save the page
                                    if (options.autoSave) {
                                        // save the page
                                        me.saveComponents();
                                    }

                                } catch (e) {
                                    console.error(e);
                                }
                            },
                            errorMessage: "Error fetching widget source"
                        });
                    }
                });
            } else {
                if (options.customLayout || iframeNode.id.startsWith('header-frame') || iframeNode.id.startsWith('footer-frame')) {
                    // destroy contenteditable for headers and footers
                    iframeNode.contentWindow.eval("if (window.__pen__) window.__pen__.destroy();");
                } else {
                    var iframeDoc = iframeNode.contentDocument,
                        widgetNode = iframeDoc.querySelector('.compass_ae-widget');
                    if (widgetNode) {
                        // destroy contenteditable for widgets
                        iframeNode.contentWindow.eval("if (window.__pen__) window.__pen__.destroy();");
                    } else {
                        var css = iframeDoc.createElement("style");
                        css.type = "text/css";
                        css.innerHTML = "."+ iframeNode.id + "-enclose {outline: rgba(233, 94, 94, 0.5) solid 2px;  outline-offset: -2px;cursor: pointer;}";
                        iframeDoc.body.appendChild(css);
                        if (iframeNode.contentWindow.__pen__) {

                            // show properties panel on content editor select
                            iframeNode.contentDocument.addEventListener("contenteditorselect", function() {
                                var eastRegion = Ext.ComponentQuery.query('knitkit_eastregion').first();
                                var elemPropertiesPanel = eastRegion.down('knitkitcomponentpropertiesformpanel');
                                
                                elemPropertiesPanel.loadSelectedTextProperties(iframeNode);
                                elemPropertiesPanel.show();
                                eastRegion.expand();
                            }, false);

                            // rebind listeners to newly added line
                            iframeNode.contentDocument.addEventListener("contenteditorlinebreak", function(){
                                me.attachBlockElementListener(iframeNode);
                            });

                            // rebind listeners for any executed command
                            iframeNode.contentDocument.addEventListener("contenteditorcommandexecute", function(){
                                me.attachBlockElementListener(iframeNode);
                            });

                            if (options.websiteSectionContentId) {
                                Compass.ErpApp.Utility.ajaxRequest({
                                    url: '/knitkit/erp_app/desktop/website_builder/component_dynamic_status',
                                    method: 'GET',
                                    params: {
                                        website_section_content_id: options.websiteSectionContentId
                                    },
                                    success: function(responseObj) {
                                        if (responseObj.is_content_dynamic) {
                                            iframeNode.contentWindow.__pen__.setIframeId(iframeNode.id);
                                            iframeNode.contentWindow.__pen__.setParentWindow(window);
                                            iframeNode.contentWindow.eval("if (window.__pen__) window.__pen__.destroy();");
                                        } else {
                                            iframeNode.contentWindow.__pen__.setIframeId(iframeNode.id);
                                            iframeNode.contentWindow.__pen__.setParentWindow(window);
                                            me.attachBlockElementListener(iframeNode);
                                        }
                                    }
                                });
                            } else {
                                iframeNode.contentWindow.__pen__.setIframeId(iframeNode.id);
                                iframeNode.contentWindow.__pen__.setParentWindow(window);
                                me.attachBlockElementListener(iframeNode);
                            }
                        }
                    }
                }
                if (options.autoSave) {
                    // save the page
                    me.saveComponents();
                }
            }

            // start resize interval for iframe
            me.refershIntervals[iframeNode.id] = setInterval(function() {
                if (!iframeNode || !iframeNode.contentDocument || !iframeNode.contentDocument.body) {
                    clearInterval(me.refershIntervals[iframeNode.id]);
                } else {
                    if (!me.rowHeights[iframeNode.id]) {
                        me.rowHeights[iframeNode.id] = iframeNode.contentDocument.body.offsetHeight;
                        dropPanel.setHeight(iframeNode.contentDocument.body.offsetHeight);
                        me.updateLayout();
                    } else if (me.rowHeights[iframeNode.id] !== iframeNode.contentDocument.body.offsetHeight) {
                        me.rowHeights[iframeNode.id] = iframeNode.contentDocument.body.offsetHeight;
                        dropPanel.setHeight(iframeNode.contentDocument.body.offsetHeight);
                        me.updateLayout();
                    }
                }
            }, 300);

            if (options.websiteSectionContentId)
                Ext.Array.remove(me.contentToLoad, options.websiteSectionContentId);
        });
    },

    attachBlockElementListener: function(iframeNode) {
        var me = this,
            blockElem = "blockquote, section, center, div, fieldset, form, h1, h2, h3, h4, h5, h6, hr, ol, p, pre, table, ul, img",
            blockElems = blockElem.split(', ');
        function isElementBlock(element) {
            return blockElems.indexOf(element.tagName.toLowerCase()) > -1 ;
        }
        
        var blockElemSel = $(iframeNode.contentDocument.body).find('.container > .row > .col-md-12').find(blockElem);

        blockElemSel.unbind('mouseenter');
        blockElemSel.unbind('mouseleave');
        blockElemSel.unbind('click');
        
        blockElemSel.mouseenter(function(ev){
            ev.stopPropagation();
            var elem = isElementBlock(ev.target) ? ev.target : this;
            me.removeDesignAtrifacts(iframeNode);
            $(elem).addClass(iframeNode.id+ '-enclose');
        }).mouseleave(function(evt){
            evt.stopPropagation();
            var elem = isElementBlock(evt.target) ? evt.target : this;
            $(elem).removeClass(iframeNode.id + '-enclose');
            if (Compass.ErpApp.Utility.isBlank($(elem).attr('class')))
                $(elem).removeAttr('class');
        }).click(function(e){
            e.stopPropagation();
            var elem = isElementBlock(e.target) ? e.target : this;
            var eastRegion = Ext.ComponentQuery.query('knitkit_eastregion').first();
            var elemPropertiesPanel = eastRegion.down('knitkitcomponentpropertiesformpanel');
            elemPropertiesPanel.setWebsiteSectionId(me.websiteSectionId);
            elemPropertiesPanel.loadElementProperties(elem, iframeNode);
            elemPropertiesPanel.show();
            eastRegion.expand();
        });
    },

    attachContentBlockListeners: function(dropPanel, uniqueId) {
        var me = this;
        var sourceElem = Ext.get(uniqueId + '-source');
        if (sourceElem) {
            sourceElem.removeAllListeners();
            sourceElem.on('click', function(e) {
                e.stopEvent();
                console.log(dropPanel.cls);
                if (dropPanel.cls == 'websitebuilder-component-panel') {
                    me.resetContentEditorToolbar();
                    me.removeDesignAtrifacts(dropPanel.el.down('.iframe-container > iframe').el.dom);
                    me.fetchComponentSource(
                        dropPanel.id,
                        function(dropPanel, responseObj) {
                            var source = responseObj.component.html;
                            var parentContainer = dropPanel.up('container');
                            var componentType = dropPanel.componentType;
                            var websiteSectionContentId = dropPanel.websiteSectionContentId;
                            var dropPanelIndex = dropPanel.up('container').items.indexOf(dropPanel);
                            var componentType = dropPanel.componentType;
                            var opts = {
                                canViewSource: true,
                                canRemove: true
                            };

                            if (componentType) {
                                Ext.apply(opts, {
                                    canMove: false,
                                    componentType: componentType
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
                                height: me.getHeight(),
                                flex: 1,
                                tbarItems: [{
                                    text: 'Save & Show Design View',
                                    iconCls: 'icon-save',
                                    handler: function(btn) {
                                        var centerRegion = Ext.getCmp('knitkitCenterRegion');
                                        centerRegion.setWindowStatus('Saving...');
                                        var componentSource = btn.up('codemirror').codeMirrorInstance.getValue();

                                        me.saveComponentSource(componentSource, {
                                            componentType: componentType,
                                            websiteSectionContentId: dropPanel.websiteSectionContentId
                                        },
                                                               function() {
                                                                   var component = parentContainer.insert(dropPanelIndex, {
                                                                       xtype: 'websitebuilderdropzone',
                                                                       flex: 1,
                                                                       componentType: componentType,
                                                                       websiteSectionContentId: dropPanel.websiteSectionContentId,
                                                                       html: ''
                                                                   });

                                                                   btn.up('codemirror').destroy();
                                                                   var loadMsk = new Ext.LoadMask(component, {
                                                                       msg: "Please wait..."
                                                                   });
                                                                   loadMsk.show();
                                                                   var options = {
                                                                       websiteSectionContentId: dropPanel.websiteSectionContentId,
                                                                       componentType: componentType,
                                                                       afterload: function() {
                                                                           loadMsk.hide();
                                                                       }

                                                                   };

                                                                   if (me.isThemeMode()) {
                                                                       Ext.apply(options, {
                                                                           canViewSource: true,
                                                                           canMove: false,
                                                                           canDelete: true
                                                                       }); 
                                                                   } else {
                                                                       Ext.apply(options, {
                                                                           canViewSource: true,
                                                                           canMove: true,
                                                                           canDelete: true
                                                                       });
                                                                   }
                                                                   me.loadContentBlock(
                                                                       component, options
                                                                   );
                                                                   centerRegion.clearWindowStatus();
                                                               },
                                                               function() {
                                                                   Ext.Msg.alert('Error', 'Error saving source');
                                                               }
                                                              );
                                    }
                                }, {
                                    text: 'Close',
                                    iconCls: 'icon-delete',
                                    handler: function(btn) {
                                        var component = parentContainer.insert(dropPanelIndex, {
                                            xtype: 'websitebuilderdropzone',
                                            flex: 1,
                                            componentType: componentType,
                                            websiteSectionContentId: dropPanel.websiteSectionContentId,
                                            html: ''
                                        });
                                        var editorSource = btn.up('codemirror').codeMirrorInstance.getValue()
                                        var loadMsk = new Ext.LoadMask(component, {
                                            msg: "Please wait..."
                                        });
                                        loadMsk.show();
                                        btn.up('codemirror').destroy();
                                        if (me.isThemeMode()) {
                                            me.loadContentBlock(component, {
                                                componentType: componentType,
                                                canViewSource: true,
                                                canMove: false,
                                                canRemove: true,
                                                afterload: function() {
                                                    loadMsk.hide();
                                                }

                                            });
                                        } else {
                                            Compass.ErpApp.Utility.ajaxRequest({
                                                url: '/knitkit/erp_app/desktop/website_builder/component_dynamic_status',
                                                method: 'GET',
                                                params: {
                                                    website_section_content_id: dropPanel.websiteSectionContentId
                                                },
                                                success: function(respObj) {
                                                    var prms = {};
                                                    // if its a dynamic content we want to send website section content id so that it
                                                    // loads the stored content else for a static content the source current source
                                                    // should be sent so that it behaves like CKEDITOR design and source view
                                                    if (respObj.is_content_dynamic) {
                                                        Ext.apply(prms, { websiteSectionContentId: dropPanel.websiteSectionContentId });
                                                    } else {
                                                        Ext.apply(prms, {
                                                            source: editorSource ,
                                                            websiteSectionContentId: dropPanel.websiteSectionContentId
                                                        });
                                                    }
                                                    
                                                    Ext.apply(prms, {
                                                        afterload: function() {
                                                            loadMsk.hide();
                                                        }
                                                    })
                                                    me.loadContentBlock(component, prms);
                                                }
                                            });
                                        }
                                        
                                    }
                                }],
                                listeners: {
                                    save: function(codemirror, content) {
                                        var centerRegion = Ext.getCmp('knitkitCenterRegion');
                                        centerRegion.setWindowStatus('Saving...');
                                        me.saveComponentSource(
                                            content, {
                                                componentType: componentType,
                                                websiteSectionContentId: dropPanel.websiteSectionContentId
                                            },
                                            function() {
                                                centerRegion.clearWindowStatus();
                                            },
                                            function() {
                                                centerRegion.clearWindowStatus();
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
        }

        var removeElem = Ext.get(uniqueId + "-remove");
        if (removeElem) {
            removeElem.removeAllListeners();
            removeElem.on("click", function(e) {
                e.stopEvent();
                me.resetContentEditorToolbar();
                parentContainer = dropPanel.up('websitebuilderdropzonecontainer');
                if (dropPanel.cls == "websitebuilder-component-panel") {
                    parentContainer.insert(parentContainer.items.indexOf(dropPanel), {
                        xtype: 'websitebuilderdropzone',
                        empty: true,
                        componentType: dropPanel.componentType,
                        flex: 1
                    });

                    dropPanel.destroy();
                    clearInterval(me.refershIntervals[uniqueId]);
                }
            });
        }

        if (!dropPanel.empty) {
            $('#inner-' + dropPanel.id).on('mouseenter', function(){
                $(this).css('background-color', '#ccc');
                $(this).children().show();
            }).on('mouseleave', function(){
                $(this).children().hide();
                $(this).css('background-color', '');
            });
        }
    },
    
    fetchComponentSource: function(dropPanelId, success, failure) {
        var me = this;
        var dropPanel = Ext.getCmp(dropPanelId);
        var websiteSectionContentId = dropPanel.websiteSectionContentId;
        
        var params = {
            website_id: me.getWebsiteId()
        };
        // if there is a website section content id then this is a content block
        // else this is a layout component type header or footer
        if (websiteSectionContentId) {
            Compass.ErpApp.Utility.ajaxRequest({
                url: '/knitkit/erp_app/desktop/website_builder/component_dynamic_status',
                method: 'GET',
                params: {
                    website_section_content_id: websiteSectionContentId
                },
                success: function(responseObj) {
                    if (responseObj.is_content_dynamic) {
                        Ext.apply(params, {
                            website_section_content_id: websiteSectionContentId,
                        });
                    } else {
                        Ext.apply(params, {
                            website_section_content_id: websiteSectionContentId,
                            body_html: me.getContentBlockSubmitableHTML(dropPanel)
                        });
                    }
                    Compass.ErpApp.Utility.ajaxRequest({
                        url: '/knitkit/erp_app/desktop/website_builder/get_component_source',
                        method: 'POST',
                        params: params,
                        success: function(response) {
                            if (success) {
                                success(dropPanel, response);
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
                }
            })
        } else {
            Ext.apply(params, {
                component_type: dropPanel.componentType
            });

            Compass.ErpApp.Utility.ajaxRequest({
                url: '/knitkit/erp_app/desktop/website_builder/get_component_source',
                method: 'POST',
                params: params,
                success: function(response) {
                    if (success) {
                        success(dropPanel, response);
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
        }
        
    },

    saveComponentSource: function(componentSource, options, success, failure) {
        var me = this;

        Compass.ErpApp.Utility.ajaxRequest({
            url: '/knitkit/erp_app/desktop/website_builder/save_component_source',
            method: 'POST',
            params: {
                id: me.getWebsiteId(),
                website_section_content_id: options.websiteSectionContentId,
                component_type: options.componentType,
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

    removeContentFromDraggedPanel: function(dropPanel, draggedPanel) {
        var me = this,
            parentContainer = draggedPanel.up('websitebuilderdropzonecontainer');

        if (draggedPanel.cls == "websitebuilder-component-panel" && parentContainer.hasCls('dropzone-container')) {
            
            if (parentContainer.items.length > 2) {
                // parentContainer.insert(parentContainer.items.indexOf(draggedPanel), {
                //     xtype: 'websitebuilderdropzone',
                //     empty: true,
                //     componentType: 'content',
                //     flex: 1
                // });
                draggedPanel.destroy();
            } else {
                parentContainer.destroy();
            }
        }

        me.updateLayout();
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
                [{
                    xtype: 'websitebuilderdropzonecontainer',
                    cls: 'dropzone-container',
                    layout: 'hbox',
                    items: [me.buildLayoutConfig('header', options)]
                }, {
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
                    xtype: 'websitebuilderdropzonecontainer',
                    cls: 'dropzone-container',
                    layout: 'hbox',
                    items: [me.buildLayoutConfig('footer', options)]
                }]
            );

        } else {
            var loadMask = new Ext.LoadMask(me, {
                msg: "Please wait..."
            });
            loadMask.show();

            Compass.ErpApp.Utility.ajaxRequest({
                url: '/knitkit/erp_app/desktop/website_builder/section_components',
                method: 'GET',
                params: {
                    website_section_id: me.websiteSectionId
                },
                success: function(response) {
                    // if there is a custom layout render it else if there are content sections render them
                    if (!Compass.ErpApp.Utility.isBlank(response.layout)) {
                        var componentContainer = me.add({
                            xtype: 'websitebuilderdropzonecontainer',
                            cls: 'dropzone-container',
                            layout: 'hbox',
                            items: [{
                                xtype: 'websitebuilderdropzone',
                                flex: 1,
                                componentType: 'content',
                                html: ''
                            }]
                        });
                        
                        me.loadContentBlock(componentContainer.down('websitebuilderdropzone'), {
                            website_section_id: me.websiteSectionId,
                            customLayout: true,
                            canViewSource: false,
                            canMove: false,
                            canRemove: false,
                            afterload: function() {
                                loadMask.hide();
                            }
                        });

                    } else if(!Compass.ErpApp.Utility.isBlank(response.website_section_contents)) {
                        Ext.each(response.website_section_contents, function(columns) {
                            var componentContainer = me.add({
                                xtype: 'websitebuilderdropzonecontainer',
                                cls: 'dropzone-container',
                                layout: 'hbox',
                                items: []
                            });

                            Ext.each(columns, function(column) {
                                var component = componentContainer.add({
                                    xtype: 'websitebuilderdropzone',
                                    flex: 1,
                                    componentType: 'content',
                                    html: ''
                                });

                                me.loadContentBlock(component, {
                                    websiteSectionContentId: column.id
                                });

                                me.contentToLoad.push(column.id);
                            });
                        });

                        // wait for all content to load
                        var loadInterval = setInterval(function() {
                            if (me.contentToLoad.length === 0) {
                                clearInterval(loadInterval);
                                loadMask.hide();
                            }

                        }, 500);
                    } else {
                        loadMask.hide();
                    }
                }
            });
        }
    },

    buildLayoutConfig: function(componentType, options) {
        var me = this;

        options = options || {};

        // if is header or footer is already present render it as a component else render websitebuilderdropzone
        var layoutCompConfig = null;

        layoutCompConfig = {
            xtype: 'websitebuilderdropzone',
            isLayout: true,
            flex: 1,
            componentType: componentType,
            listeners: {
                render: function(comp) {
                    me.loadContentBlock(comp, Ext.apply(options, {
                        componentType: componentType
                    }));
                }
            }
        };

        return layoutCompConfig;
    },
    
    editContentKeydownListener: function(e) {
        var me = Ext.getCmp(e.data.websiteBuilderPanelId);
        if (e.keyCode === 13) {
            e.view.document.execCommand('insertHTML', false, '<br><br>');
            // prevent the default behaviour of return key pressed
            return false;
        } else if ((e.ctrlKey || e.metaKey) && (e.keyCode == 83)) {
            if (me.initialConfig.save)
                me.initialConfig.save(me);
            return false;
        }
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
    },

    resetContentEditorToolbar: function() {
        var me = this;
        var contentBlocks = me.query('websitebuilderdropzonecontainer');
        Ext.each(contentBlocks, function(block) {
            var iframeEl = block.el.down('.iframe-container > iframe');
            if (iframeEl) {
                iframeEl.dom.contentWindow.getSelection().removeAllRanges();
            }
        });
        var menu = jQuery('.pen-menu');
        if(menu.length != 0) {
            window.getSelection().removeAllRanges();
            menu.hide();
        }
    },
    
    removeDesignAtrifacts: function(iframe) {
        $(iframe.contentDocument.body).find('.' + iframe.id + '-enclose').removeClass(iframe.id + '-enclose');
    },

    hasEmptyContainerOrContentBlock: function() {
        var me = this,
            hasEmpty = false,
            containers = me.query('websitebuilderdropzonecontainer');
        
        for (var i = 0; i < containers.length; i++) {
            if (containers[i].empty()){
                hasEmpty = true;
                break;
            } else {
                var breakInnerLoop = false;
                var contentBlocks = containers[i].query('websitebuilderdropzone');
                for (var j = 0; j < contentBlocks.length; j++) {
                    if (contentBlocks[j].empty){
                        hasEmpty = true;
                        breakInnerLoop = true;
                        break;
                    }
                }
                if (breakInnerLoop) break;
            }
        }
        return hasEmpty
    }
    
});
