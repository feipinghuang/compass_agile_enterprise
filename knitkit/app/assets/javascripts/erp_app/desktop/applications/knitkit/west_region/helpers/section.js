Compass.ErpApp.Desktop.Applications.Knitkit.addSectionOptions = function(self, items, record) {
    var sectionId = record.get('recordId');
    var knitkitModule = compassDesktop.getModule('knitkit-win');
    var websiteId = knitkitModule.currentWebsite.id;

    // Update Security
    if (currentUser.hasCapability('unsecure', 'WebsiteSection') || currentUser.hasCapability('secure', 'WebsiteSection')) {
        items.push({
            text: 'Security',
            iconCls: 'icon-document_lock',
            listeners: {
                'click': function() {
                    var westRegion = Ext.getCmp('knitkitWestRegion');
                    westRegion.changeSecurity(record, '/knitkit/erp_app/desktop/section/update_security', sectionId);
                }
            }
        });
    }

    // Create Section
    if (currentUser.hasCapability('create', 'WebsiteSection')) {
        if (record.get('isBlog')) {
            // Add Article
            items.push({
                text: 'Add Article',
                iconCls: 'icon-document',
                listeners: {
                    'click': function () {

                        var addFormItems = [
                            {
                                xtype: 'textfield',
                                fieldLabel: 'Title',
                                allowBlank: false,
                                name: 'title',
                                itemId: 'title'
                            },
                            {
                                xtype: 'radiogroup',
                                fieldLabel: 'Display title?',
                                name: 'display_title',
                                columns: 2,
                                items: [
                                    {
                                        boxLabel: 'Yes',
                                        name: 'display_title',
                                        inputValue: 'yes',
                                        checked: true
                                    },

                                    {
                                        boxLabel: 'No',
                                        name: 'display_title',
                                        inputValue: 'no'
                                    }
                                ]
                            },
                            {
                                xtype: 'textfield',
                                fieldLabel: 'Content Area',
                                allowBlank: true,
                                name: 'content_area'
                            },
                            {
                                xtype: 'textfield',
                                fieldLabel: 'Tags',
                                allowBlank: true,
                                name: 'tags'
                            },
                            {
                                xtype: 'textfield',
                                fieldLabel: 'Internal ID',
                                allowBlank: true,
                                name: 'internal_identifier'
                            }
                        ];

                        Ext.widget('window', {
                            modal: true,
                            title: 'Create New Article',
                            buttonAlign: 'center',
                            defaultFocus: 'title',
                            items: {
                                xtype: 'form',
                                frame: false,
                                bodyStyle: 'padding:5px 5px 0',
                                url: '/knitkit/erp_app/desktop/articles/new/' + sectionId,
                                items: addFormItems
                            },
                            buttons: [
                                {
                                    text: 'Submit',
                                    listeners: {
                                        'click': function (button) {
                                            var window = button.findParentByType('window');
                                            var formPanel = window.query('form')[0];

                                            var loadMask = new Ext.LoadMask(window, {msg: 'Please wait...'});

                                            formPanel.getForm().submit({
                                                reset: true,
                                                success: function (form, action) {
                                                    loadMask.hide();
                                                    var obj = Ext.decode(action.response.responseText);
                                                    if (obj.success) {
                                                        obj.node.createdAt = obj.node.created_at;
                                                        obj.node.updatedAt = obj.node.updated_at;
                                                        record.appendChild(Ext.create('SiteContentsModel', obj.node));
                                                    }
                                                    else {
                                                        Ext.Msg.alert("Error", obj.msg);
                                                    }
                                                    window.close();
                                                },
                                                failure: function (form, action) {
                                                    loadMask.hide();
                                                    Ext.Msg.alert("Error", "Error creating article");
                                                }
                                            });
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
                    }
                }
            });

            // Attach Article
            items.push({
                text: 'Attach Article',
                iconCls: 'icon-copy',
                listeners: {
                    'click': function () {
                        var window = Ext.widget('window', {
                            modal: true,
                            title: 'Attach Existing Article',
                            plain: true,
                            buttonAlign: 'center',
                            items: {
                                xtype: 'form',
                                frame: false,
                                bodyStyle: 'padding:5px 5px 0',
                                url: '/knitkit/erp_app/desktop/articles/add_existing/' + sectionId,
                                items: [
                                    {
                                        itemId: 'available_articles_filter_combobox',
                                        xtype: 'combo',
                                        hiddenName: 'website_id',
                                        name: 'website_id',
                                        loadingText: 'Retrieving Websites...',
                                        store: Ext.create('Ext.data.Store', {
                                            autoLoad: true,
                                            proxy: {
                                                type: 'ajax',
                                                reader: {
                                                    type: 'json',
                                                    root: 'websites'
                                                },
                                                extraParams: {
                                                    section_id: sectionId
                                                },
                                                url: '/knitkit/erp_app/desktop/section/available_articles_filter'
                                            },
                                            fields: [
                                                {
                                                    name: 'id'
                                                },
                                                {
                                                    name: 'internal_identifier'

                                                },
                                                {
                                                    name: 'name'

                                                }
                                            ],
                                            listeners: {
                                                'load': function (store) {
                                                    available_articles_filter_combobox = window.down('#available_articles_filter_combobox');
                                                    available_articles_filter_combobox.select(0);
                                                    available_articles_filter_combobox.fireEvent('select');
                                                }
                                            }
                                        }),
                                        forceSelection: true,
                                        fieldLabel: 'Filter By',
                                        queryMode: 'local',
                                        autoSelect: true,
                                        typeAhead: true,
                                        displayField: 'name',
                                        valueField: 'id',
                                        triggerAction: 'all',
                                        allowBlank: false,
                                        listeners: {
                                            'select': function (combo, records) {
                                                available_articles_combobox = window.down('#available_articles_combobox');
                                                available_articles_combobox.getStore().load({
                                                    params: {
                                                        section_id: sectionId,
                                                        website_id: window.down('#available_articles_filter_combobox').getValue()
                                                    }
                                                });
                                            }
                                        }
                                    },
                                    {
                                        xtype: 'combo',
                                        itemId: 'available_articles_combobox',
                                        hiddenName: 'article_id',
                                        name: 'article_id',
                                        loadingText: 'Retrieving Articles...',
                                        store: Ext.create('Ext.data.Store', {
                                            autoLoad: false,
                                            remoteFilter: true,
                                            proxy: {
                                                type: 'ajax',
                                                reader: {
                                                    type: 'json',
                                                    root: 'articles'
                                                },
                                                extraParams: {
                                                    section_id: sectionId
                                                },
                                                url: '/knitkit/erp_app/desktop/section/available_articles'
                                            },
                                            fields: [
                                                {
                                                    name: 'id'
                                                },
                                                {
                                                    name: 'internal_identifier'

                                                },
                                                {
                                                    name: 'combobox_display_value'
                                                }
                                            ],
                                            listeners: {
                                                'beforeload': function (store) {
                                                    Ext.apply(store.getProxy().extraParams, {
                                                        website_id: window.down('#available_articles_filter_combobox').getValue()
                                                    });
                                                },
                                                'load': function (store, records) {
                                                    if (records.length > 0) {
                                                        available_articles_combobox = window.down('#available_articles_combobox');
                                                        available_articles_combobox.setValue(records.first().get('id'));
                                                    }
                                                }
                                            }
                                        }),
                                        queryMode: 'local',
                                        forceSelection: true,
                                        fieldLabel: 'Article',
                                        autoSelect: true,
                                        typeAhead: true,
                                        displayField: 'combobox_display_value',
                                        valueField: 'id',
                                        triggerAction: 'all',
                                        allowBlank: false,
                                        loadMask: false
                                    }
                                ]
                            },
                            buttons: [
                                {
                                    text: 'Submit',
                                    listeners: {
                                        'click': function (button) {
                                            var window = button.findParentByType('window');
                                            var formPanel = window.query('form')[0];

                                            var loadMask = new Ext.LoadMask(window, {msg: 'Please wait...'});

                                            formPanel.getForm().submit({
                                                reset: true,
                                                success: function (form, action) {
                                                    loadMask.hide();
                                                    var obj = Ext.decode(action.response.responseText);
                                                    if (obj.success) {
                                                        obj.article.createdAt = obj.article.created_at;
                                                        obj.article.updatedAt = obj.article.updated_at;

                                                        record.appendChild(Ext.create('SiteContentsModel', obj.article));

                                                        window.close();
                                                    } else {
                                                        Ext.Msg.alert("Error", "Error Attaching article");
                                                    }
                                                },
                                                failure: function (form, action) {
                                                    loadMask.hide();
                                                    Ext.Msg.alert("Error", "Error Attaching article");
                                                }
                                            });
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
                        });
                        window.show();
                    }
                }
            });
        } else {
            items.push({
                text: 'Add Page',
                iconCls: 'icon-add',
                listeners: {
                    'click': function() {
                        Ext.widget("window", {
                            modal: true,
                            title: 'New Page',
                            buttonAlign: 'center',
                            defaultFocus: 'title',
                            items: {
                                xtype: 'form',
                                frame: false,
                                bodyStyle: 'padding:5px 5px 0',
                                url: '/knitkit/erp_app/desktop/section/new',
                                items: [{
                                    xtype: 'textfield',
                                    fieldLabel: 'Title',
                                    allowBlank: false,
                                    name: 'title',
                                    itemId: 'title'
                                }, {
                                    xtype: 'textfield',
                                    fieldLabel: 'Internal ID',
                                    allowBlank: true,
                                    name: 'internal_identifier'
                                }, {
                                    xtype: 'combo',
                                    forceSelection: true,
                                    store: [
                                        ['Page', 'Page'],
                                        ['Blog', 'Blog']
                                    ],
                                    value: 'Page',
                                    fieldLabel: 'Type',
                                    name: 'type',
                                    allowBlank: false,
                                    triggerAction: 'all'
                                }, {
                                    xtype: 'radiogroup',
                                    fieldLabel: 'Display in menu?',
                                    name: 'in_menu',
                                    columns: 2,
                                    items: [{
                                        boxLabel: 'Yes',
                                        name: 'in_menu',
                                        inputValue: 'yes',
                                        checked: true
                                    },

                                            {
                                                boxLabel: 'No',
                                                name: 'in_menu',
                                                inputValue: 'no'
                                            }
                                           ]
                                }, {
                                    xtype: 'radiogroup',
                                    fieldLabel: 'Render with Base Layout?',
                                    name: 'render_with_base_layout',
                                    columns: 2,
                                    items: [{
                                        boxLabel: 'Yes',
                                        name: 'render_with_base_layout',
                                        inputValue: 'yes',
                                        checked: true
                                    },

                                            {
                                                boxLabel: 'No',
                                                name: 'render_with_base_layout',
                                                inputValue: 'no'
                                            }
                                           ]
                                }, {
                                    xtype: 'hidden',
                                    name: 'website_section_id',
                                    value: sectionId
                                }, {
                                    xtype: 'hidden',
                                    name: 'website_id',
                                    value: record.data.siteId
                                }]
                            },
                            buttons: [{
                                text: 'Submit',
                                listeners: {
                                    'click': function(button) {
                                        var window = button.findParentByType('window');
                                        var formPanel = window.query('.form')[0];

                                        var loadMask = new Ext.LoadMask(window, {
                                            msg: 'Please wait...'
                                        });

                                        formPanel.getForm().submit({
                                            reset: true,
                                            success: function(form, action) {
                                                loadMask.hide();
                                                var obj = Ext.decode(action.response.responseText);
                                                if (obj.success) {
                                                    record.appendChild(obj.node);
                                                    window.close();
                                                } else {
                                                    Ext.Msg.alert("Error", obj.message);
                                                }
                                            },
                                            failure: function(form, action) {
                                                loadMask.hide();
                                                var obj = Ext.decode(action.response.responseText);
                                                if (obj.message) {
                                                    Ext.Msg.alert("Error", obj.message);
                                                } else {
                                                    Ext.Msg.alert("Error", "Error creating page.");
                                                }
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
                    }
                }
            });
        }
        }
        

    // Edit Section
    if (currentUser.hasCapability('edit', 'WebsiteSection')) {
        items.push({
            text: 'Update ' + record.data["type"],
            iconCls: 'icon-edit',
            listeners: {
                'click': function() {
                    Ext.widget("window", {
                        modal: true,
                        title: 'Update Page',
                        buttonAlign: 'center',
                        items: {
                            xtype: 'form',
                            frame: false,
                            bodyStyle: 'padding:5px 5px 0',
                            url: '/knitkit/erp_app/desktop/section/update',
                            items: [{
                                xtype: 'textfield',
                                fieldLabel: 'Title',
                                value: record.data.text,
                                name: 'title'
                            }, {
                                xtype: 'textfield',
                                fieldLabel: 'Internal ID',
                                allowBlank: true,
                                name: 'internal_identifier',
                                value: record.data.internal_identifier
                            }, {
                                xtype: 'radiogroup',
                                fieldLabel: 'Display in menu?',
                                name: 'in_menu',
                                columns: 2,
                                items: [{
                                        boxLabel: 'Yes',
                                        name: 'in_menu',
                                        inputValue: 'yes',
                                        checked: record.data.inMenu
                                    },

                                    {
                                        boxLabel: 'No',
                                        name: 'in_menu',
                                        inputValue: 'no',
                                        checked: !record.data.inMenu
                                    }
                                ]
                            }, {
                                xtype: 'radiogroup',
                                fieldLabel: 'Render with Base Layout?',
                                name: 'render_with_base_layout',
                                columns: 2,
                                items: [{
                                        boxLabel: 'Yes',
                                        name: 'render_with_base_layout',
                                        inputValue: 'yes',
                                        checked: record.data.renderWithBaseLayout
                                    },

                                    {
                                        boxLabel: 'No',
                                        name: 'render_with_base_layout',
                                        inputValue: 'no',
                                        checked: !record.data.renderWithBaseLayout
                                    }
                                ]
                            }, {
                                xtype: 'displayfield',
                                fieldLabel: 'Path',
                                name: 'path',
                                value: record.data.path
                            }, {
                                xtype: 'hidden',
                                name: 'id',
                                value: sectionId
                            }]
                        },
                        buttons: [{
                            text: 'Submit',
                            listeners: {
                                'click': function(button) {
                                    var window = button.findParentByType('window');
                                    var formPanel = window.query('.form')[0];

                                    var loadMask = new Ext.LoadMask(window, {
                                        msg: 'Please wait...'
                                    });

                                    formPanel.getForm().submit({
                                        success: function(form, action) {
                                            loadMask.hide();
                                            var values = formPanel.getValues();
                                            record.set('title', values.title);
                                            record.set('text', values.title);
                                            record.set('internal_identifier', values.internal_identifier);
                                            record.set("inMenu", (values.in_menu == 'yes'));
                                            record.set("renderWithBaseLayout", (values.render_with_base_layout == 'yes'));
                                            record.commit();
                                            window.close();
                                        },
                                        failure: function(form, action) {
                                            loadMask.hide();
                                            var obj = Ext.decode(action.response.responseText);
                                            Ext.Msg.alert("Error", obj.msg);
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
                }
            }
        });
    }

    // Edit / Update Layout
    // no layouts for blogs.
    if (Compass.ErpApp.Utility.isBlank(record.data['isBlog']) && record.data['hasLayout']) {
        if (currentUser.hasCapability('edit', 'WebsiteSectionLayout')) {
            items.push({
                text: 'Edit Layout',
                iconCls: 'icon-edit',
                listeners: {
                    'click': function() {
                        var sectionPanel = Ext.ComponentQuery.query('#knitkitSiteContentsTreePanel').first();
                        sectionPanel.editSectionLayout(record.data.text, sectionId, record.data.siteId);
                    }
                }
            });
        }

    } else if (Compass.ErpApp.Utility.isBlank(record.data['isBlog'])) {
        if (currentUser.hasCapability('create', 'WebsiteSectionLayout')) {
            items.push({
                text: 'Add Layout',
                iconCls: 'icon-add',
                listeners: {
                    'click': function() {
                        Ext.Ajax.request({
                            url: '/knitkit/erp_app/desktop/section/add_layout',
                            method: 'POST',
                            params: {
                                id: sectionId
                            },
                            success: function(response) {
                                var obj = Ext.decode(response.responseText);
                                if (obj.success) {
                                    record.data.hasLayout = true;

                                    var sectionPanel = Ext.ComponentQuery.query('#knitkitSiteContentsTreePanel').first();
                                    sectionPanel.editSectionLayout(record.data.text, sectionId, record.data.siteId);
                                } else {
                                    Ext.Msg.alert('Status', obj.message);
                                }
                            },
                            failure: function(response) {
                                Ext.Msg.alert('Status', 'Error adding layout.');
                            }
                        });
                    }
                }
            });
        }

        if (currentUser.hasCapability('edit', 'WebsiteSectionLayout') && !record.data.source_enabled) {
            items.push({
                text: 'Edit Page Source',
                iconCls: 'icon-edit',
                listeners: {
                    'click': function() {
                        Ext.Msg.confirm('Confirm', 'Editing the page source will disbable the Website Builder for this Page. Continue?', function(btn) {
                            if (btn == 'yes' || btn == 'ok') {
                                var sectionPanel = Ext.ComponentQuery.query('#knitkitSiteContentsTreePanel').first();
                                sectionPanel.editSectionSource(record.data.text, sectionId, record.data.siteId);
                                record.set('source_enabled', true);
                                record.commit();
                            }
                        });
                    }
                }
            });
        }
    }

    // Copy Section
    items.push({
        text: 'Copy ' + record.data["type"],
        iconCls: 'icon-copy',
        listeners: {
            'click': function() {
                Ext.widget("window", {
                    modal: true,
                    title: 'Copy' + record.data["type"],
                    buttonAlign: 'center',
                    items: {
                        xtype: 'form',
                        frame: false,
                        bodyStyle: 'padding:5px 5px 0',
                        url: '/knitkit/erp_app/desktop/section/copy',
                        items: [{
                            xtype: 'combo',
                            name: 'parent_section_id',
                            loadingText: 'Retrieving Pages...',
                            store: Ext.create("Ext.data.Store", {
                                proxy: {
                                    type: 'ajax',
                                    url: '/knitkit/erp_app/desktop/section/existing_sections',
                                    reader: {
                                        type: 'json'
                                    },
                                    extraParams: {
                                        exclude_document_sections: true,
                                        website_id: websiteId
                                    }
                                },
                                autoLoad: true,
                                fields: [{
                                    name: 'id'
                                }, {
                                    name: 'title_permalink'

                                }]
                            }),
                            forceSelection: true,
                            allowBlank: true,
                            fieldLabel: 'Parent Page',
                            mode: 'local',
                            displayField: 'title_permalink',
                            valueField: 'id',
                            triggerAction: 'all'
                        }, {
                            xtype: 'textfield',
                            fieldLabel: 'Title',
                            value: record.data.text,
                            name: 'title'
                        }, {
                            xtype: 'hidden',
                            name: 'id',
                            value: sectionId
                        }, {
                            xtype: 'hidden',
                            name: 'website_id',
                            value: websiteId
                        }]
                    },
                    buttons: [{
                        text: 'Submit',
                        listeners: {
                            'click': function(button) {
                                var window = button.findParentByType('window');
                                var formPanel = window.query('.form')[0];

                                var loadMask = new Ext.LoadMask(window, {
                                    msg: 'Copying page...'
                                });

                                formPanel.getForm().submit({
                                    success: function(form, action) {
                                        var obj = Ext.decode(action.response.responseText);
                                        var values = formPanel.getValues();
                                        var parentNode = record.getOwnerTree().getRootNode();

                                        loadMask.hide();

                                        if (!Ext.isEmpty(values.parent_section_id)) {
                                            parentNode = parentNode.findChildBy(function(node) {
                                                if (node.get('recordType') == 'WebsiteSection' && node.get('recordId') == values.parent_section_id) {
                                                    return true;
                                                }
                                            }, this, true);
                                        }

                                        if (parentNode && parentNode != record.getOwnerTree().getRootNode() && parentNode.isExpanded()) {
                                            record.getOwnerTree().getStore().load({
                                                node: parentNode
                                            });
                                        }

                                        window.close();
                                    },
                                    failure: function(form, action) {
                                        loadMask.hide();

                                        var obj = Ext.decode(action.response.responseText);
                                        Ext.Msg.alert("Error", obj.message);
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
            }
        }
    });

    // Delete Section
    if (currentUser.hasCapability('delete', 'WebsiteSection')) {
        items.push({
            text: 'Delete ' + record.data["type"],
            iconCls: 'icon-delete',
            listeners: {
                'click': function() {
                    Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete the page?<h3>' + record.data["text"] + '</h3> NOTE: Articles belonging to this page will be orphaned.<br><br>', function(btn) {
                        if (btn == 'no') {
                            return false;
                        } else if (btn == 'yes') {
                            Ext.Ajax.request({
                                url: '/knitkit/erp_app/desktop/section/delete',
                                method: 'POST',
                                params: {
                                    id: sectionId
                                },
                                success: function(response) {

                                    var obj = Ext.decode(response.responseText);
                                    if (obj.success) {
                                        record.remove();
                                        // remove tab if opened
                                        var centerRegion = knitkitModule.centerRegion;
                                        if (centerRegion) {
                                            var websiteSectionBuilder = centerRegion.workArea.getComponent('websiteSection' + sectionId),
                                                layoutPanel = centerRegion.workArea.getComponent('section-' + sectionId);

                                            if (websiteSectionBuilder)
                                                websiteSectionBuilder.destroy();
                                            
                                            if (layoutPanel)
                                                layoutPanel.destroy();
                                        }

                                        var eastRegion = Ext.getCmp('knitkitEastRegion'),
                                            compPropPanel = eastRegion.down('knitkitcomponentpropertiesformpanel');
                                        if (compPropPanel) {
                                            if (compPropPanel.getWebsiteSectionId() == sectionId)
                                                compPropPanel.removeAll();
                                        }
                                        
                                    } else {
                                        Ext.Msg.alert('Error', 'Error deleting page');
                                    }
                                },
                                failure: function(response) {
                                    Ext.Msg.alert('Error', 'Error deleting page');
                                }
                            });
                        }
                    });
                }
            }
        });
    }

    return items;
};
