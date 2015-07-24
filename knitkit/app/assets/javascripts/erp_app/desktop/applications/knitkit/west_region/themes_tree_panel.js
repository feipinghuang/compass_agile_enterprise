var themeTreeStatus = {
    nodes: [],
    addNodeState: function(node){
        var me = this,
            id = node.get('id'),
            parentId = node.get('parentId'),
            isExpanded = node.get('expanded'),
            item = null;

        Ext.each(me.nodes, function(obj, index){
            if(obj.id == id && obj.parentId == parentId){
                item = obj;
                return false;
            }
        });

        if(!item){
            me.nodes.push({
                id: id,
                parentId: parentId,
                isExpanded: isExpanded
            });
        } else{
            item['isExpanded'] = isExpanded;
        }

    },
    isEmpty: function(){
        var me = this;
        return me.nodes.length == 0;
    },
    reset: function(){
        var me = this;
        me.nodes = [];
    }
};
Ext.define("Compass.ErpApp.Desktop.Applications.ThemesTreePanel", {
    extend: "Compass.ErpApp.Shared.FileManagerTree",
    alias: 'widget.knitkit_themestreepanel',
    itemId: 'themesTreePanel',

    clearWebsite: function () {
        var store = this.getStore();
        store.getProxy().extraParams = {};
        store.load();
    },

    selectWebsite: function (website) {
        var store = this.getStore();
        store.getProxy().extraParams = {
            website_id: website.id
        };
        store.load();
    },

    themeWidget: function (node) {
        var self = this;

        Ext.create("Ext.window.Window", {
            layout: 'fit',
            modal: true,
            width: 375,
            title: 'Theme Widget',
            plain: true,
            buttonAlign: 'center',
            items: Ext.create('widget.form', {
                labelWidth: 110,
                frame: false,
                bodyStyle: 'padding:5px 5px 0',
                fileUpload: true,
                url: '/knitkit/erp_app/desktop/theme/theme_widget',
                defaults: {
                    width: 300
                },
                items: [
                    {
                        xtype: 'hidden',
                        name: 'site_id',
                        value: node.get('siteId')
                    },
                    {
                        xtype: 'hidden',
                        name: 'theme_id',
                        value: node.get('themeId')
                    },
                    {
                        xtype: 'combo',
                        hiddenName: 'widget_id',
                        name: 'widget_id',
                        store: Ext.create("Ext.data.Store", {
                            proxy: {
                                url: '/knitkit/erp_app/desktop/theme/available_widgets',
                                type: 'ajax',
                                reader: {
                                    type: 'json',
                                    root: 'widgets'
                                },
                                extraParams: {
                                    theme_id: node.get('themeId')
                                }
                            },
                            fields: [
                                {
                                    name: 'name'
                                },
                                {
                                    name: 'id'
                                }
                            ]
                        }),
                        forceSelection: true,
                        editable: false,
                        fieldLabel: 'Widget',
                        emptyText: 'Select Widget...',
                        typeAhead: false,
                        mode: 'remote',
                        displayField: 'name',
                        valueField: 'id',
                        allowBlank: false
                    }
                ]
            }),
            buttons: [
                {
                    text: 'Submit',
                    listeners: {
                        'click': function (button) {
                            var window = this.up('window'),
                                form = window.query('form')[0].getForm();

                            if (form.isValid()) {
                                form.submit({
                                    waitMsg: 'Generating layout files for widget...',
                                    success: function (form, action) {
                                        var obj = Ext.decode(action.response.responseText);
                                        if (obj.success) {
                                            self.getStore().load({
                                                node: node,
                                                callback: function(){
                                                    node.expand();
                                                }
                                            });
                                        }
                                        window.close();
                                    },
                                    failure: function (form, action) {
                                        Ext.Msg.alert("Error", "Error generating layouts");
                                    }
                                });
                            }
                        }
                    }
                },
                {
                    text: 'Close',
                    handler: function (btn) {
                        btn.up('window').close();
                    }
                }
            ]
        }).show();
    },

    updateThemeActiveStatus: function (node, active) {
        var self = this;

        self.initialConfig['centerRegion'].setWindowStatus('Updating Status...');

        Ext.Ajax.request({
            url: '/knitkit/erp_app/desktop/theme/change_status',
            method: 'POST',
            params: {
                theme_id: node.data.id,
                website_id: node.data.siteId,
                active: active
            },
            success: function (response) {
                var obj = Ext.decode(response.responseText);
                if (obj.success) {
                    self.initialConfig['centerRegion'].clearWindowStatus();

                    if (active) {
                        // first update icon for all other theme nodes as they are now deactive
                        var rootNode = node.getOwnerTree().getRootNode();
                        rootNode.eachChild(function (childNode) {
                            childNode.set('iconCls', 'icon-delete');
                            childNode.set('isActive', false);
                        });

                        // then update this node to be active
                        node.set('iconCls', 'icon-add');
                        node.set('isActive', true);
                    }
                    else {
                        node.set('iconCls', 'icon-delete');
                        node.set('isActive', false);
                    }
                }
                else {
                    Ext.Msg.alert('Error', 'Error updating status');
                    self.initialConfig['centerRegion'].clearWindowStatus();
                }
            },
            failure: function (response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                Ext.Msg.alert('Error', 'Error updating status');
            }
        });
    },

    deleteTheme: function (themeId) {
        var self = this;
        self.initialConfig['centerRegion'].setWindowStatus('Deleting theme...');
        Ext.Ajax.request({
            url: '/knitkit/erp_app/desktop/theme/delete',
            method: 'POST',
            params: {
                theme_id: themeId
            },
            success: function (response) {
                var obj = Ext.decode(response.responseText);
                if (obj.success) {
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    self.getStore().load({
                        node: self.getRootNode()
                    });
                }
                else {
                    Ext.Msg.alert('Error', 'Error deleting theme');
                    self.initialConfig['centerRegion'].clearWindowStatus();
                }
            },
            failure: function (response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                Ext.Msg.alert('Error', 'Error deleting theme');
            }
        });
    },

    exportTheme: function (themeId) {
        var self = this;
        self.initialConfig['centerRegion'].setWindowStatus('Exporting theme...');
        window.open('/knitkit/erp_app/desktop/theme/export?id=' + themeId, '_blank');
        self.initialConfig['centerRegion'].clearWindowStatus();
    },

    constructor: function (config) {
        var self = this;

        config = Ext.apply({
            autoLoadRoot: true,
            rootVisible: true,
            multiSelect: true,
            title: 'Themes',
            rootText: 'Themes',
            handleRootContextMenu: true,
            controllerPath: '/knitkit/erp_app/desktop/theme',
            autoDestroy: true,
            allowDownload: true,
            addViewContentsToContextMenu: true,
            standardUploadUrl: '/knitkit/erp_app/desktop/theme/upload_file',
            url: '/knitkit/erp_app/desktop/theme/index',
            fields: [
                'isTheme',
                'themeId',
                'isActive',
                'siteId',
                'text',
                'id',
                'url',
                'leaf',
                'handleContextMenu',
                'contextMenuDisabled'
            ],
            scroll: 'vertical',
            //containerScroll: true,
            listeners: {
                'afteritemexpand': function(node, index, item, eOpts){
                    themeTreeStatus.addNodeState(node);
                },
                'afteritemcollapse': function(node, index, item, eOpts){
                    themeTreeStatus.addNodeState(node);
                },
                'load': function (store) {
                    var parentNode = store.getRootNode();
                    parentNode.expandChildren();

                    if(!themeTreeStatus.isEmpty()){
                        Ext.each(themeTreeStatus.nodes, function(nodeObject, index){
                            var node = parentNode.findChildBy(function(child){
                                    return (child.get('id') == nodeObject['id'] &&
                                        child.get('parentId') == nodeObject['parentId']);
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

                },
                'showImage': function (fileManager, node, themeId) {
                    var themeId = null;
                    var themeNode = node;
                    while (themeId == null && !Compass.ErpApp.Utility.isBlank(themeNode.parentNode)) {
                        if (themeNode.data.isTheme) {
                            themeId = themeNode.data.id;
                        }
                        else {
                            themeNode = themeNode.parentNode;
                        }
                    }
                    self.initialConfig['centerRegion'].showImage(node, themeId);
                },
                'contentLoaded': function (fileManager, node, content) {
                    var themeId = null;
                    var themeNode = node;
                    while (themeId == null && !Compass.ErpApp.Utility.isBlank(themeNode.parentNode)) {
                        if (themeNode.data.isTheme) {
                            themeId = themeNode.data.id;
                        }
                        else {
                            themeNode = themeNode.parentNode;
                        }
                    }
                    self.initialConfig['centerRegion'].editTemplateFile(node, content, [], themeId);
                },
                'handleContextMenu': function (fileManager, node, e) {
                    var items = [];

                    if (node.isRoot()) {
                        items.push(Compass.ErpApp.Desktop.Applications.Knitkit.newThemeMenuItem);
						items.push(Compass.ErpApp.Desktop.Applications.Knitkit.uploadThemeMenuItem);
                    }
                    else if (node.data['isTheme']) {
                        if (node.data['isActive']) {
                            items.push({
                                text: 'Deactivate',
                                iconCls: 'icon-delete',
                                listeners: {
                                    'click': function () {
                                        self.updateThemeActiveStatus(node, false);
                                    }
                                }
                            });
                        }
                        else {
                            items.push({
                                text: 'Activate',
                                iconCls: 'icon-add',
                                listeners: {
                                    'click': function () {
                                        self.updateThemeActiveStatus(node, true);
                                    }
                                }
                            });
                        }
                        items.push({
                            text: 'Delete Theme',
                            iconCls: 'icon-delete',
                            listeners: {
                                'click': function () {
                                    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this theme?', function (btn) {
                                        if (btn == 'no') {
                                            return false;
                                        }
                                        else if (btn == 'yes') {
                                            self.deleteTheme(node.data.id);
                                        }
                                    });
                                }
                            }
                        });
                        items.push({
                            text: 'Export',
                            iconCls: 'icon-document_out',
                            listeners: {
                                'click': function () {
                                    self.exportTheme(node.data.id);
                                }
                            }
                        });
                    }
                    else if (node.get('text') == 'Widgets') {
                        items.push({
                            text: 'Theme Widget',
                            iconCls: 'icon-picture',
                            handler: function (btn) {
                                fileManager.themeWidget(node);
                            }
                        });
                    }

                    var contextMenu = Ext.create('Ext.menu.Menu', {
                        items: items
                    });
                    contextMenu.showAt(e.xy);
                    return false;
                }
            }
        }, config);

        this.callParent([config]);
    }
});

