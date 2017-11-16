Ext.define('SiteContentsModel', {
    extend: 'Ext.data.TreeModel',
    fields: [
        'recordType',
        'recordId',
        'objectType',
        'text',
        'iconCls',
        'parentItemId',
        'isBlog',
        'display_title',
        'leaf',
        'isSection',
        'source_enabled',
        'isDocument',
        'contentInfo',
        'content_area',
        'isSecured',
        'url',
        'path',
        'inMenu',
        'hasLayout',
        'siteId',
        'type',
        'name',
        'title',
        'subtitle',
        'websiteId',
        'isSectionRoot',
        'siteName',
        'internal_identifier',
        'configurationId',
        'renderWithBaseLayout',
        'roles',
        'useMarkdown',
        'parentItemId',
        'tag_list',
        // if an article is part of a blog then you can edit the excerpt
        'canEditExcerpt', {
            name: 'createdAt',
            mapping: 'created_at',
            type: 'date'
        }, {
            name: 'updatedAt',
            mapping: 'updated_at',
            type: 'date'
        }
    ]
});

var siteContentsStore = Ext.create('Ext.data.TreeStore', {
    model: 'SiteContentsModel',
    proxy: {
        type: 'ajax',
        url: '/knitkit/erp_app/desktop/site/build_content_tree',
        timeout: 90000,
        reader: {
            type: 'json'
        }
    },
    root: {
        text: 'Sections/Web Pages',
        iconCls: 'icon-ia',
        expanded: true
    },
    listeners: {
        beforeexpand: function(node, eOpts) {
            if (!node.isRoot()) {
                var tree = node.getOwnerTree();
                tree.getStore().getProxy().setExtraParam('record_type', node.get('recordType'));
                tree.getStore().getProxy().setExtraParam('record_id', node.get('recordId'));
            }
        }
    }
});

var pluginItems = [];

pluginItems.push({
    ptype: 'treeviewdragdrop'
});

var viewConfigItems = {
    markDirty: false,
    plugins: pluginItems,
    listeners: {
        'beforedrop': function(dom, data, overModel, dropPosition, dropHandlers, options) {
            var record = data.records.first();

            if (record.get('objectType') == 'Article') {
                if (overModel.get('isSection')) {
                    return false;
                }
            }
        },
        'drop': function(dom, data, overModel, dropPosition, options) {
            var positionArray = [],
                record = data.records.first(),
                result = true,
                counter = 0;

            if (record.get('isSection') || record.get('isDocument')) {
                // if the record is modified and the parentId has changed we need to change
                // the section parent
                var parentNode = null;

                if (dropPosition == 'append') {
                    positionArray.push({
                        id: record.get('recordId'),
                        parent_id: overModel.get('recordId'),
                        position: 0
                    });

                    parentNode = overModel;
                } else {
                    parentNode = overModel.parentNode;
                }

                parentNode.eachChild(function(node) {
                    if (node.get('isSection') || record.get('isDocument')) {
                        positionArray.push({
                            id: node.get('recordId'),
                            parent_id: node.parentNode.get('recordId'),
                            position: counter
                        });

                        counter++;
                    }
                });

                Ext.Ajax.request({
                    url: '/knitkit/erp_app/desktop/position/update_section_position',
                    method: 'PUT',
                    jsonData: {
                        position_array: positionArray
                    },
                    success: function(response) {
                        var obj = Ext.decode(response.responseText);
                        if (!obj.success) {
                            Ext.Msg.alert("Error", obj.message);
                            result = false;
                        }
                    },
                    failure: function(response) {
                        Ext.Msg.alert('Error', 'Error saving positions.');
                        result = false;
                    }
                });
            }
            // this is an article
            else {
                if (record.modified && record.modified.parentId) {
                    result = false;
                } else {
                    overModel.parentNode.eachChild(function(node) {
                        positionArray.push({
                            id: node.get('recordId'),
                            position: counter
                        });
                        counter++;
                    });

                    Ext.Ajax.request({
                        url: '/knitkit/erp_app/desktop/position/update_article_position',
                        method: 'PUT',
                        jsonData: {
                            position_array: positionArray
                        },
                        params: {
                            section_id: record.parentNode.get('recordId')
                        },
                        success: function(response) {
                            var obj = Ext.decode(response.responseText);
                            if (!obj.success) {
                                Ext.Msg.alert("Error", obj.message);
                                result = false;
                            }
                        },
                        failure: function(response) {
                            Ext.Msg.alert('Error', 'Error saving positions.');
                            result = false;
                        }
                    });
                }
            }

            return result;
        }
    }
};

Ext.define("Compass.ErpApp.Desktop.Applications.SiteContentsTreePanel", {

    extend: "Ext.tree.Panel",
    id: 'knitkitSiteContentsTreePanel',
    itemId: 'knitkitSiteContentsTreePanel',
    alias: 'widget.knitkit_sitecontentstreepanel',
    header: false,

    viewConfig: viewConfigItems,
    store: siteContentsStore,
    enableDD: true,

    editSectionLayout: function(sectionName, sectionId, websiteId) {
        var self = this;

        Ext.Ajax.request({
            url: '/knitkit/erp_app/desktop/section/get_layout',
            method: 'POST',
            params: {
                id: sectionId
            },
            success: function(response) {
                self.initialConfig['centerRegion'].editSectionLayout(
                    sectionName,
                    websiteId,
                    sectionId,
                    response.responseText, [{
                        text: 'Insert Content Area',
                        handler: function(btn) {
                            var codeMirror = btn.findParentByType('codemirror');
                            Ext.MessageBox.prompt('New File', 'Please enter content area name:', function(btn, text) {
                                if (btn == 'ok') {
                                    codeMirror.insertContent('<%=render_content_area(:' + text + ')%>');
                                }

                            });
                        }
                    }]);
            },
            failure: function(response) {
                Ext.Msg.error('Error', 'Error loading section layout.');
            }
        });
    },

    editSectionSource: function(sectionName, sectionId, websiteId) {
        var self = this;

        Ext.Ajax.request({
            url: '/knitkit/erp_app/desktop/section/enable_source_edit',
            method: 'put',
            params: {
                id: sectionId
            },
            success: function(response) {
                self.initialConfig['centerRegion'].editSectionSource(
                    sectionName,
                    websiteId,
                    sectionId,
                    response.responseText, []);
            },
            failure: function(response) {
                Ext.Msg.error('Error', 'Error loading section source');
            }
        });
    },

    clearWebsite: function() {
        this.theme = null;
        var store = this.getStore();
        store.getProxy().extraParams = {};
        store.load();
    },

    selectWebsite: function(website) {
        this.theme = website.theme;
        var store = this.getStore();
        store.getProxy().extraParams = {
            website_id: website.id
        };
        store.load();
    },

    listeners: {
        itemclick: function(view, record, htmlItem, index, e) {
            var url = null;
            var self = this;

            e.stopEvent();
                
            if (record.get('type') == 'Page') {
                if (record.get('source_enabled')) {
                    self.editSectionLayout(record.data.text, record.data.recordId, record.data['siteId']);
                } else {
                    self.initialConfig['centerRegion'].openWebsiteBuilderInTab(record.data.text, record.data.recordId, self.theme);
                }
            } else if (record.get('type') == 'Blog') {
                url = '/blogs/' + record.get('recordId');
                self.initialConfig['centerRegion'].openIframeInTab(record.get('text'), url)
            }  else if (record.get('objectType') == 'Article') {
                url = '/knitkit/erp_app/desktop/articles/show/' + record.get('recordId');
                
                Ext.Ajax.request({
                    url: url,
                    method: 'GET',
                    timeout: 90000,
                    success: function(response) {
                        var article = Ext.decode(response.responseText);
                        self.initialConfig['centerRegion'].editContent(record.data.text, record.get('recordId'), article.body_html, record.data['siteId'], 'article');
                    },
                    failure: function() {
                        Ext.Msg.alert('Error', 'Could not load content');
                    }
                });
            }

        },
        itemcontextmenu: function(view, record, htmlItem, index, e) {
            e.stopEvent();
            var items = [];

            if (record.isRoot() && record.hasChildNodes()) {
                items = [
                    Compass.ErpApp.Desktop.Applications.Knitkit.newSectionMenuItem,
                    Compass.ErpApp.Desktop.Applications.Knitkit.editWebsiteMenuItem(false),
                    Compass.ErpApp.Desktop.Applications.Knitkit.configureWebsiteMenuItem(false),
                    Compass.ErpApp.Desktop.Applications.Knitkit.exportWebsiteMenuItem(false),
                    Compass.ErpApp.Desktop.Applications.Knitkit.websitePublicationsMenuItem(false),
                    Compass.ErpApp.Desktop.Applications.Knitkit.websitePublishMenuItem(false),
                    Compass.ErpApp.Desktop.Applications.Knitkit.websiteInquiresMenuItem(false)
                ];
            }

            if (record.data['objectType'] === "Article") {

                items = Compass.ErpApp.Desktop.Applications.Knitkit.addArticleOptions(self, items, record);
            }

            if (record.data['isSection']) {
                items = Compass.ErpApp.Desktop.Applications.Knitkit.addSectionOptions(self, items, record);
            } else if (record.data['isWebsite']) {
                items = Compass.ErpApp.Desktop.Applications.Knitkit.addWebsiteOptions(self, items, record);
            }

            if (items.length !== 0) {
                var contextMenu = Ext.create("Ext.menu.Menu", {
                    items: items
                });
                contextMenu.showAt(e.xy);
            }
        }
    }
});
