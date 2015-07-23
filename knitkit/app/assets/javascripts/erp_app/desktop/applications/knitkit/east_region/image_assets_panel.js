var imagesTreeStatus = {
    websiteImagesNodes: [],
    sharedImagesNodes: [],
    websitePreviewId: null,
    sharedPreviewId: null,

    setPreviewDirectory: function(nodeId, nodeType){
        var me = this,
            attributeName = nodeType + 'PreviewId';
        me[attributeName] = nodeId;
    },
    getNodes: function(nodeType){
        var me = this,
            nodes,
            attributeName = nodeType + 'ImagesNodes';

        nodes = me[attributeName];
        if(nodes == undefined){
            nodes = [];
        }
        return nodes;
    },
    updateNodes: function(nodes, nodeType){
        var me = this,
            attributeName = nodeType + 'ImagesNodes';

        if(me[attributeName]){
            me[attributeName] = nodes;
        }
    },
    isEmpty: function(nodeType){
        var me = this,
            attributeName = nodeType + 'ImagesNodes';

        if(me[attributeName]){
            return me[attributeName].length == 0;
        }else{
            return 0;
        }
    },
    addNode: function(node, nodeType){
        window.n = node;
        if(nodeType){
            var me = this,
                id = node.get('id'),
                isExpanded = node.get('expanded'),
                item = null,
                nodes = me.getNodes(nodeType);

            Ext.each(nodes, function(obj, index){
                if(obj.id == id){
                    item = obj;
                    return false;
                }
            });

            if(!item){
                nodes.push({
                    id: id,
                    isExpanded: isExpanded
                });
            }else{
                item['isExpanded'] = isExpanded;
            }

            me.updateNodes(nodes, nodeType);
        }
    }
};

Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsPanel", {
    extend: "Ext.tab.Panel",
    alias: 'widget.knitkit_ImageAssetsPanel',
    cls: 'image-assets-panel',

    constructor: function (config) {
        this.websiteId = null;
        var self = this;
        self.module = config.module;

        this.sharedImageAssetsDataView = Ext.create("Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsDataView", {
            url: '/knitkit/erp_app/desktop/image_assets/shared/get_images',
            uploadUrl: '/knitkit/erp_app/desktop/image_assets/shared/upload_file',
            module: config.module,
            listeners: {
                afterrender: function () {
                    if (currentUser.hasCapability('view', 'GlobalImageAsset')) {
                        self.sharedImageAssetsDataView.directory = 'root_node';
                        var store = self.sharedImageAssetsDataView.getStore();
                        store.load({
                            params: {
                                directory: 'root_node'
                            }
                        });
                    }
                },
                imageuploaded: function (comp) {
                    self.sharedImageAssetsTreePanel.getStore().load({
                        callback: function () {
                            self.sharedImageAssetsTreePanel.getView().refresh();
                        }
                    });
                }
            }
        });
        this.websiteImageAssetsDataView = Ext.create("Compass.ErpApp.Desktop.Applications.Knitkit.ImageAssetsDataView", {
            module: config.module,
            url: '/knitkit/erp_app/desktop/image_assets/website/get_images',
            uploadUrl: '/knitkit/erp_app/desktop/image_assets/website/upload_file',
            listeners: {
                imageuploaded: function (comp) {
                    var store = self.websiteImageAssetsTreePanel.getStore();
                    store.load({
                        callback: function () {
                            self.websiteImageAssetsDataView.getStore().load({
                                params: {
                                    directory: 'root_node',
                                    website_id: self.websiteId
                                }
                            });
                        }
                    });
                }
            }
        });

        this.sharedImageAssetsTreePanel = Ext.create("Compass.ErpApp.Shared.FileManagerTree", {
            region: 'north',
            rootText: 'Shared Images',
            collapsible: false,
            allowDownload: false,
            addViewContentsToContextMenu: false,
            showNewFileMenuItem: false,
            rootVisible: true,
            multiSelect: true,
            controllerPath: '/knitkit/erp_app/desktop/image_assets/shared',
            standardUploadUrl: '/knitkit/erp_app/desktop/image_assets/shared/upload_file',
            url: '/knitkit/erp_app/desktop/image_assets/shared/expand_directory',
            containerScroll: true,
            height: 200,
            additionalContextMenuItems: [
                {
                    nodeType: 'leaf',
                    text: 'Insert image at cursor',
                    iconCls: 'icon-add',
                    listeners: {
                        scope: self,
                        'click': function () {
                            var node = this.sharedImageAssetsTreePanel.selectedNode;

                            var imgTagHtml = '<img';
                            if (!Ext.isEmpty(node.data.width) && !Ext.isEmpty(node.data.height)) {
                                imgTagHtml += (' width="' + node.data.width + '" height="' + node.data.height + '"');
                            }
                            imgTagHtml += ' alt="' + node.get('name') + '" src="' + node.get('url') + '" >';
                            self.module.centerRegion.insertHtmlIntoActiveCkEditorOrCodemirror(imgTagHtml);
                        }
                    }
                }
            ],
            listeners: {
                'afteritemexpand': function(node, index, item, eOpts){
                    imagesTreeStatus.addNode(node, 'shared');
                },
                'afteritemcollapse': function(node, index, item, eOpts){
                    imagesTreeStatus.addNode(node, 'shared');
                },
                'load': function(tree, node, records, successful, eOpts){
                    var me = this;
                    var parentNode = tree.getRootNode();

                    if(!imagesTreeStatus.isEmpty('shared')){
                        Ext.each(imagesTreeStatus.sharedImagesNodes, function(nodeObject, index){
                            var node = parentNode.findChildBy(function(child){
                                    return child.get('id') == nodeObject['id'];
                                }, null, true),
                                isNodeExpanded = nodeObject['isExpanded'];

                            if(node){
                                if(isNodeExpanded){
                                    node.expand(false);
                                } else{
                                    node.collapse(false);
                                }
                            }
                        });
                    }

                    if(imagesTreeStatus.sharedPreviewId){
                        var previewNode = parentNode.findChildBy(function(child){
                            return child.get('id') == imagesTreeStatus.sharedPreviewId;
                        }, null, true);

                        if(previewNode){
                            me.getSelectionModel().select(previewNode, false);
                            me.fireEvent('fileUploaded', me, previewNode);
                        }
                    }
                },
                'allowdelete': function () {
                    return currentUser.hasCapability('delete', 'GlobalImageAsset');
                },
                'allowupload': function () {
                    return currentUser.hasCapability('upload', 'GlobalImageAsset');
                },
                'itemclick': function (view, record, item, index, e) {
                    e.stopEvent();
                    if (!record.data["leaf"]) {
                        self.sharedImageAssetsDataView.directory = record.data.id;
                        var store = self.sharedImageAssetsDataView.getStore();
                        store.load({
                            params: {
                                directory: record.data.id
                            }
                        });
                        imagesTreeStatus.setPreviewDirectory(record.get('id'), 'shared');
                    }
                    else {
                        return false;
                    }
                },
                'fileDeleted': function (fileTreePanel, node) {
                    var store = self.sharedImageAssetsDataView.getStore();
                    store.load({
                        params: {
                            directory: node.parentNode.data.id
                        }
                    });
                },
                'fileUploaded': function (fileTreePanel, node) {
                    var store = self.sharedImageAssetsDataView.getStore();
                    store.load({
                        params: {
                            directory: node.data.id
                        }
                    });
                },
                'downloadfile': function (fileTreePanel, node) {
                    window.open("/download/" + node.data.text + "?path=" + node.data.downloadPath + '&disposition=attachment', 'mywindow', 'width=400,height=200');
                    return false;
                }
            }
        });

        this.websiteImageAssetsTreePanel = Ext.create("Compass.ErpApp.Shared.FileManagerTree", {
            autoLoadRoot: false,
            region: 'north',
            rootText: 'Images',
            collapsible: false,
            allowDownload: false,
            addViewContentsToContextMenu: false,
            showNewFileMenuItem: false,
            rootVisible: true,
            multiSelect: true,
            controllerPath: '/knitkit/erp_app/desktop/image_assets/website',
            standardUploadUrl: '/knitkit/erp_app/desktop/image_assets/website/upload_file',
            url: '/knitkit/erp_app/desktop/image_assets/website/expand_directory',
            containerScroll: true,
            height: 200,
            additionalContextMenuItems: [
                {
                    nodeType: 'leaf',
                    text: 'Insert image at cursor',
                    iconCls: 'icon-add',
                    listeners: {
                        scope: self,
                        'click': function () {
                            var node = this.websiteImageAssetsTreePanel.selectedNode;

                            var imgTagHtml = '<img';
                            if (!Ext.isEmpty(node.data.width) && !Ext.isEmpty(node.data.height)) {
                                imgTagHtml += (' width="' + node.data.width + '" height="' + node.data.height + '"');
                            }
                            imgTagHtml += ' alt="' + node.get('name') + '" src="' + node.get('url') + '" >';
                            self.module.centerRegion.insertHtmlIntoActiveCkEditorOrCodemirror(imgTagHtml);
                        }
                    }
                }
            ],
            listeners: {
                'afteritemexpand': function(node, index, item, eOpts){
                    imagesTreeStatus.addNode(node, 'website');
                },
                'afteritemcollapse': function(node, index, item, eOpts){
                    imagesTreeStatus.addNode(node, 'website');
                },
                'load': function (store, node, records) {
                    store.getRootNode().data.text = self.websiteName;
                    self.websiteImageAssetsTreePanel.view.refresh();

                    var me = this,
                        tree = store;

                    if(!imagesTreeStatus.isEmpty('website')){
                        var parentNode = tree.getRootNode();

                        Ext.each(imagesTreeStatus.websiteImagesNodes, function(nodeObject, index){
                            var node = parentNode.findChildBy(function(child){
                                    return child.get('id') == nodeObject['id'];
                                }, null, true),
                                isNodeExpanded = nodeObject['isExpanded'];

                            if(node){
                                if(isNodeExpanded){
                                    node.expand(false);
                                } else{
                                    node.collapse(false);
                                }
                            }
                        });

                        if(imagesTreeStatus.websitePreviewId){
                            var previewNode = parentNode.findChildBy(function(child){
                                return child.get('id') == imagesTreeStatus.websitePreviewId;
                            }, null, true);

                            if(previewNode){
                                me.getSelectionModel().select(previewNode, false);
                                me.fireEvent('fileUploaded', me, previewNode);
                            }
                        }
                    }

                },
                'itemclick': function (view, record, item, index, e) {
                    if (self.websiteId !== null) {
                        e.stopEvent();
                        if (!record.data["leaf"]) {
                            self.websiteImageAssetsDataView.directory = record.data.id;
                            self.websiteImageAssetsDataView.websiteId = self.websiteId;
                            var store = self.websiteImageAssetsDataView.getStore();
                            store.load({
                                params: {
                                    directory: record.data.id,
                                    website_id: self.websiteId
                                }
                            });
                            imagesTreeStatus.setPreviewDirectory(record.get('id'), 'website');
                        }
                        else {
                            return false;
                        }
                    }
                },
                'fileDeleted': function (fileTreePanel, node) {
                    self.websiteImageAssetsDataView.getStore().load({
                        params: {
                            directory: node.parentNode.data.downloadPath,
                            website_id: self.websiteId
                        }
                    });
                },
                'fileUploaded': function (fileTreePanel, node) {
                    self.websiteImageAssetsDataView.getStore().load({
                        params: {
                            directory: node.data.id,
                            website_id: self.websiteId
                        }
                    });
                },
                'downloadfile': function (fileTreePanel, node) {
                    window.open("/download/" + node.data.text + "?path=" + node.data.downloadPath + '&disposition=attachment', 'mywindow', 'width=400,height=200');
                    return false;
                }
            }
        });

        var sharedImagesPanel = Ext.create('Ext.panel.Panel', {
            cls: 'image-assets',
            region: 'center',
            margins: '0 0 0 0',
            layout: 'fit',
            items: this.sharedImageAssetsDataView
        });

        var websiteImagesPanel = Ext.create('Ext.panel.Panel', {
            cls: 'image-assets',
            region: 'center',
            margins: '0 0 0 0',
            layout: 'fit',
            items: this.websiteImageAssetsDataView
        });

        var sharedImagesLayout = Ext.create('Ext.panel.Panel', {
            layout: 'border',
            title: 'Shared',
            items: [this.sharedImageAssetsTreePanel, sharedImagesPanel]
        });

        var websiteImagesLayout = Ext.create('Ext.panel.Panel', {
            autoRender: true,
            layout: 'border',
            title: 'Website',
            items: [this.websiteImageAssetsTreePanel, websiteImagesPanel],
            listeners: {
                scope: self,
                'show': function (panel) {
                    self.reloadWebsiteImageAssetsTreePanel(self.websiteId);
                }
            }
        });

        this.selectWebsite = function (website) {
            this.websiteId = website.id;
            this.websiteName = website.name;
            this.reloadWebsiteImageAssetsTreePanel(website.id);
        };

        this.clearWebsite = function () {
            this.websiteId = null;
            this.websiteName = null;

            this.websiteImageAssetsTreePanel.extraPostData = {
                website_id: null
            };
            this.websiteImageAssetsTreePanel.getStore().setProxy({
                type: 'ajax',
                url: '/knitkit/erp_app/desktop/file_assets/website/expand_directory',
                extraParams: {
                    website_id: null
                }
            });

            this.websiteImageAssetsTreePanel.getRootNode().removeAll(true);
        };

        this.reloadWebsiteImageAssetsTreePanel = function (websiteId) {
            this.websiteImageAssetsTreePanel.extraPostData = {
                website_id: websiteId
            };
            this.websiteImageAssetsTreePanel.getStore().setProxy({
                type: 'ajax',
                url: '/knitkit/erp_app/desktop/image_assets/website/expand_directory',
                extraParams: {
                    website_id: websiteId
                }
            });

            if (websiteId) {
                while (delNode = this.websiteImageAssetsTreePanel.getRootNode().childNodes[0]) {
                    this.websiteImageAssetsTreePanel.getRootNode().removeChild(delNode);
                }
                this.websiteImageAssetsTreePanel.getRootNode().expand();

                if (!this.websiteImageAssetsTreePanel.getStore().isLoading()) {
                    this.websiteImageAssetsTreePanel.getStore().load();
                    self.websiteImageAssetsDataView.directory = 'root_node';
                    self.websiteImageAssetsDataView.websiteId = websiteId;
                    self.websiteImageAssetsDataView.getStore().load({
                        params: {
                            directory: 'root_node',
                            website_id: websiteId
                        }
                    });
                }
            }
        };

        var items = [];
        if (currentUser.hasCapability('view', 'GlobalImageAsset')) {
            items.push(sharedImagesLayout);
        }

        if (currentUser.hasCapability('view', 'SiteImageAsset')) {
            items.push(websiteImagesLayout);
        }

        config = Ext.apply({
            deferredRender: false,
            layout: 'fit',
            title: 'Images',
            items: items,
            activeTab: 1,
            listeners: {
                afterrender: function (panel) {
                    // workaround for extJS rendering bug. set activetab 1 above and 0 afterrender
                    panel.setActiveTab(0);
                }
            }
        }, config);

        this.callParent([config]);

    }
});
