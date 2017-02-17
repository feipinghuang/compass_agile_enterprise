Ext.define("Compass.ErpApp.Desktop.Applications.ThemesTreePanel", {
    extend: "Compass.ErpApp.Shared.FileManagerTree",
    alias: 'widget.knitkit_themestreepanel',
    itemId: 'themesTreePanel',

    clearWebsite: function() {
        var store = this.getStore();
        store.getProxy().extraParams = {};
        store.load();
    },

    selectWebsite: function(website) {
        var store = this.getStore();
        store.getProxy().extraParams = {
            website_id: website.id
        };
        store.load();
    },

    themeWidget: function(node) {
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
                items: [{
                    xtype: 'hidden',
                    name: 'site_id',
                    value: node.get('siteId')
                }, {
                    xtype: 'hidden',
                    name: 'theme_id',
                    value: node.get('themeId')
                }, {
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
                        fields: [{
                            name: 'name'
                        }, {
                            name: 'id'
                        }]
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
                }]
            }),
            buttons: [{
                text: 'Submit',
                listeners: {
                    'click': function(button) {
                        var window = this.up('window'),
                            form = window.query('form')[0].getForm();

                        if (form.isValid()) {
                            form.submit({
                                waitMsg: 'Generating layout files for widget...',
                                success: function(form, action) {
                                    var obj = Ext.decode(action.response.responseText);
                                    if (obj.success) {
                                        self.getStore().load({
                                            node: node,
                                            callback: function() {
                                                node.expand();
                                            }
                                        });
                                    }
                                    window.close();
                                },
                                failure: function(form, action) {
                                    Ext.Msg.alert("Error", "Error generating layouts");
                                }
                            });
                        }
                    }
                }
            }, {
                text: 'Close',
                handler: function(btn) {
                    btn.up('window').close();
                }
            }]
        }).show();
    },

    updateThemeActiveStatus: function(node, active) {
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
            success: function(response) {
                var obj = Ext.decode(response.responseText);
                if (obj.success) {
                    self.initialConfig['centerRegion'].clearWindowStatus();

                    if (active) {
                        // first update icon for all other theme nodes as they are now deactive
                        var rootNode = node.getOwnerTree().getRootNode();
                        rootNode.eachChild(function(childNode) {
                            childNode.set('iconCls', 'icon-delete');
                            childNode.set('isActive', false);
                        });

                        // then update this node to be active
                        node.set('iconCls', 'icon-add');
                        node.set('isActive', true);
                    } else {
                        node.set('iconCls', 'icon-delete');
                        node.set('isActive', false);
                    }
                } else {
                    Ext.Msg.alert('Error', 'Error updating status');
                    self.initialConfig['centerRegion'].clearWindowStatus();
                }
            },
            failure: function(response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                Ext.Msg.alert('Error', 'Error updating status');
            }
        });
    },

    showUpdateThemeForm: function(node) {
        Ext.create("Ext.window.Window", {
            layout: 'fit',
            modal: true,
            title: 'Rename Theme',
            width: 360,
            plain: true,
            buttonAlign: 'center',
            defaultFocus: 'name',
            items: Ext.create('widget.form', {
                labelWidth: 110,
                frame: false,
                bodyStyle: 'padding:5px 5px 0',
                fileUpload: true,
                url: '/knitkit/erp_app/desktop/theme/update',
                defaults: {
                    width: 320
                },
                items: [{
                    xtype: 'hidden',
                    name: 'id',
                    value: node.get('id')
                }, {
                    xtype: 'textfield',
                    fieldLabel: 'Name',
                    value: node.get('name'),
                    allowBlank: false,
                    name: 'name',
                    itemId: 'name'
                }]
            }),
            buttons: [{
                text: 'Submit',
                listeners: {
                    'click': function(button) {
                        var window = button.findParentByType('window'),
                            formPanel = window.query('form')[0],

                            westRegion = Ext.ComponentQuery.query('#knitkitWestRegion').first(),
                            themesTreePanel = westRegion.down('#themesTreePanel');


                        var loading = new Ext.LoadMask(window, {
                            msg: 'Please wait...'
                        });
                        loading.show();

                        formPanel.getForm().submit({
                            reset: true,
                            timeout: 300000,
                            success: function(form, action) {
                                loading.hide();
                                window.close();

                                var obj = Ext.decode(action.response.responseText);
                                if (obj.success) {
                                    // update node
                                    node.set('name', obj.theme.name);
                                    node.set('text', obj.theme.text);
                                    node.commit();
                                }
                            },
                            failure: function(form, action) {
                                loading.hide();

                                Ext.Msg.alert("Error", "Error updating theme");
                            }
                        });
                    }
                }
            }, {
                text: 'Close',
                handler: function(btn) {
                    btn.up('window').close();
                }
            }]
        }).show();
    },


    showThemeBuilderPanel: function(node) {
        var me = this,
            centerPanel = Ext.ComponentQuery.query("knitkit_centerregion").first(),
            centerTabPanel = centerPanel.down('tabpanel');

        var themeBuilderPanel = centerTabPanel.add({
            xtype: 'websitebuilderpanel',
            itemId: 'themeBuilder' + node.get('id'),
            closable: true,
            isForTheme: true,
            themeLayoutConfig: {
                themeId: node.get('id'),
                headerComponentIid: node.get('headerComponentIid'),
                headerComponentHeight: node.get('headerComponentHeight'),
                footerComponentIid: node.get('footerComponentIid'),
                footerComponentHeight: node.get('footerComponentHeight')
            },
            title: 'Theme Builder',
            save: function(comp) {
                var mask = new Ext.LoadMask(me, {
                    msg: 'Please wait...'
                });
                mask.show();

                var headerComp = comp.query("[cls=websitebuilder-component-panel][componentId^='header']").first(),
                    footerComp = comp.query("[cls=websitebuilder-component-panel][componentId^='footer']").first();

                var headerHTML = null,
                    footerHTML = null;
                
                if(headerComp) {
                    var headerFrame = headerComp.getEl().query("#" + headerComp.id + "-frame").first();
                    headerHTML = headerFrame.contentDocument.documentElement.getElementsByClassName('page')[0].outerHTML;
                }

                if(footerComp) {
                    var footerFrame = footerComp.getEl().query("#" + footerComp.id + "-frame").first();
                    footerHTML = footerFrame.contentDocument.documentElement.getElementsByClassName('page')[0].outerHTML;
                }

                var params = {};

                if(!Compass.ErpApp.Utility.isBlank(headerHTML)) {
                    params.header = Ext.encode({
                        source: headerHTML,
                        component_iid: comp.themeLayoutConfig.headerComponentIid,
                        component_height: comp.themeLayoutConfig.headerComponentHeight
                    });
                }

                if(!Compass.ErpApp.Utility.isBlank(footerHTML)) {
                    params.footer = Ext.encode({
                        source: footerHTML,
                        component_iid: comp.themeLayoutConfig.footerComponentIid,
                        component_height: comp.themeLayoutConfig.footerComponentHeight
                    });
                }
                
                Compass.ErpApp.Utility.ajaxRequest({
                    url: '/knitkit/erp_app/desktop/theme_builder/' + node.get('id') + '/update_layout',
                    method: 'PUT',
                    params: params,
                    success: function(response) {
                        mask.hide();
                        // update website builder config
                        if(response.result.header) {
                            comp.themeLayoutConfig.headerComponentIid = response.result.header.component_iid;
                            comp.themeLayoutConfig.headerComponentHeight = response.result.header.component_height;

                            node.set('headerComponentIid', response.result.header.component_iid);
                            node.set('headerComponentHeight', response.result.header.component_height);
                            node.commit();

                            
                        }

                        if(response.result.footer) {
                            comp.themeLayoutConfig.footerComponentIid = response.result.footer.component_iid;
                            comp.themeLayoutConfig.footerComponentHeight = response.result.footer.component_height;
                            
                            node.set('footerComponentIid', response.result.footer.component_iid);
                            node.set('footerComponentheight', response.result.footer.component_height);
                            node.commit();
                        }
                        
                    }
                });
            }
        });

        centerTabPanel.setActiveTab(themeBuilderPanel);

    },

    deleteTheme: function(theme) {
        var self = this,
            themeId = theme.get('id');

        self.initialConfig['centerRegion'].setWindowStatus('Deleting theme...');
        Ext.Ajax.request({
            url: '/knitkit/erp_app/desktop/theme/delete',
            method: 'POST',
            params: {
                theme_id: themeId
            },
            success: function(response) {
                var obj = Ext.decode(response.responseText);
                if (obj.success) {
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    theme.parentNode.removeChild(theme);
                } else {
                    Ext.Msg.alert('Error', 'Error deleting theme');
                    self.initialConfig['centerRegion'].clearWindowStatus();
                }
            },
            failure: function(response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                Ext.Msg.alert('Error', 'Error deleting theme');
            }
        });
    },

    exportTheme: function(themeId) {
        var self = this;
        self.initialConfig['centerRegion'].setWindowStatus('Exporting theme...');
        window.open('/knitkit/erp_app/desktop/theme/export?id=' + themeId, '_blank');
        self.initialConfig['centerRegion'].clearWindowStatus();
    },

    constructor: function(config) {
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
                'name',
                'isActive',
                'siteId',
                'text',
                'id',
                'url',
                'headerComponentIid',
                'headerComponentHeight',
                'footerComponentIid',
                'footerComponentHeight',
                'leaf',
                'handleContextMenu',
                'contextMenuDisabled'
            ],
            scroll: 'vertical',
            //containerScroll: true,
            listeners: {
                'showImage': function(fileManager, node, themeId) {
                    var themeId = null;
                    var themeNode = node;
                    while (themeId == null && !Compass.ErpApp.Utility.isBlank(themeNode.parentNode)) {
                        if (themeNode.data.isTheme) {
                            themeId = themeNode.data.id;
                        } else {
                            themeNode = themeNode.parentNode;
                        }
                    }
                    self.initialConfig['centerRegion'].showImage(node, themeId);
                },
                'contentLoaded': function(fileManager, node, content) {
                    var themeId = null;
                    var themeNode = node;
                    while (themeId == null && !Compass.ErpApp.Utility.isBlank(themeNode.parentNode)) {
                        if (themeNode.data.isTheme) {
                            themeId = themeNode.data.id;
                        } else {
                            themeNode = themeNode.parentNode;
                        }
                    }
                    self.initialConfig['centerRegion'].editTemplateFile(node, content, [], themeId);
                },
                'handleContextMenu': function(fileManager, node, item, index, e) {
                    var items = [];

                    if (node.isRoot()) {
                        items.push(Compass.ErpApp.Desktop.Applications.Knitkit.newThemeMenuItem);
                        items.push(Compass.ErpApp.Desktop.Applications.Knitkit.uploadThemeMenuItem);
                    } else if (node.data['isTheme']) {
                        if (node.data['isActive']) {
                            items.push({
                                text: 'Deactivate',
                                iconCls: 'icon-delete',
                                listeners: {
                                    'click': function() {
                                        self.updateThemeActiveStatus(node, false);
                                    }
                                }
                            });
                        } else {
                            items.push({
                                text: 'Activate',
                                iconCls: 'icon-add',
                                listeners: {
                                    'click': function() {
                                        self.updateThemeActiveStatus(node, true);
                                    }
                                }
                            });
                        }
                        items.push({
                            text: 'Delete Theme',
                            iconCls: 'icon-delete',
                            listeners: {
                                'click': function() {
                                    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this theme?', function(btn) {
                                        if (btn == 'no') {
                                            return false;
                                        } else if (btn == 'yes') {
                                            self.deleteTheme(node);
                                        }
                                    });
                                }
                            }
                        });
                        items.push({
                            text: 'Rename Theme',
                            iconCls: 'icon-edit',
                            listeners: {
                                'click': function() {
                                    self.showUpdateThemeForm(node);
                                }
                            }
                        });
                        items.push({
                            text: 'Build Theme',
                            iconCls: 'icon-edit',
                            listeners: {
                                'click': function() {
                                    self.showThemeBuilderPanel(node);
                                }
                            }
                        });

                        items.push({
                            text: 'Export',
                            iconCls: 'icon-document_out',
                            listeners: {
                                'click': function() {
                                    self.exportTheme(node.data.id);
                                }
                            }
                        });
                    } else if (node.get('text') == 'Widgets') {
                        items.push({
                            text: 'Theme Widget',
                            iconCls: 'icon-picture',
                            handler: function(btn) {
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
