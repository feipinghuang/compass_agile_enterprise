Compass.ErpApp.Desktop.Applications.Knitkit.addArticleOptions = function (self, items, record) {
    items.push({
        text: 'Edit Article Attributes',
        iconCls: 'icon-edit',
        listeners: {
            'click': function () {
                var itemId = 'editArticle-' + record.get('recordId'),
                    editArticleWindow = Ext.ComponentQuery.query('#' + itemId).first();

                if (Compass.ErpApp.Utility.isBlank(editArticleWindow)) {
                    editArticleWindow = Ext.widget("window", {
                        modal: true,
                        title: 'Edit Article',
                        itemId: itemId,
                        buttonAlign: 'center',
                        items: {
                            xtype: 'form',
                            labelWidth: 110,
                            frame: false,
                            bodyStyle: 'padding:5px 5px 0',
                            url: '/knitkit/erp_app/desktop/articles/update/',
                            defaults: {width: 225},
                            items: [
                                {
                                    xtype: 'textfield',
                                    fieldLabel: 'Title',
                                    allowBlank: false,
                                    name: 'title',
                                    value: record.data.text
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
                                            checked: record.data.display_title
                                        },

                                        {
                                            boxLabel: 'No',
                                            name: 'display_title',
                                            inputValue: 'no',
                                            checked: !record.data.display_title
                                        }
                                    ]
                                },
                                {
                                    xtype: 'textfield',
                                    fieldLabel: 'Internal ID',
                                    allowBlank: true,
                                    name: 'internal_identifier',
                                    value: record.data.internal_identifier
                                },
                                {
                                    xtype: 'textfield',
                                    fieldLabel: 'Tags',
                                    allowBlank: true,
                                    name: 'tags',
                                    itemId: 'tag_list',
                                    value: record.data.tag_list
                                },
                                {
                                    xtype: 'textfield',
                                    fieldLabel: 'Content Area',
                                    allowBlank: true,
                                    name: 'content_area',
                                    value: record.data.content_area
                                },
                                {
                                    xtype: 'displayfield',
                                    fieldLabel: 'Created At',
                                    name: 'created_at',
                                    value: Ext.Date.format(record.data.createdAt, 'm-d-Y g:i A')
                                },
                                {
                                    xtype: 'displayfield',
                                    fieldLabel: 'Updated At',
                                    name: 'updated_at',
                                    value: Ext.Date.format(record.data.updatedAt, 'm-d-Y g:i A')
                                },
                                {
                                    xtype: 'hidden',
                                    allowBlank: false,
                                    name: 'id',
                                    itemId: 'record_id',
                                    value: record.get('recordId')
                                },
                                {
                                    xtype: 'hidden',
                                    allowBlank: false,
                                    name: 'section_id',
                                    value: record.data.parentItemId
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
                                        var values = formPanel.getValues();
                                        formPanel.getForm().submit({
                                            reset: false,
                                            success: function (form, action) {
                                                var obj = Ext.decode(action.response.responseText);
                                                if (obj.success) {
                                                    record.set('text', values.title);
                                                    record.set('display_title', !Ext.isEmpty(values.display_title));
                                                    record.set('content_area', values.content_area);
                                                    record.set('internal_identifier', values.internal_identifier);

                                                    if (formPanel.getForm().findField('tags')) {
                                                        var tag_list = formPanel.getForm().findField('tags').getValue();
                                                        record.set('tag_list', tag_list);
                                                    }
                                                    window.close();
                                                }
                                                else {
                                                    Ext.Msg.alert("Error", obj.msg);
                                                }
                                            },
                                            failure: function (form, action) {
                                                Ext.Msg.alert("Error", "Error updating article");
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
                }
                editArticleWindow.show();
            }
        }
    });

    if (record.get('canEditExcerpt')) {
        items.push({
            text: 'Edit Excerpt',
            iconCls: 'icon-edit',
            listeners: {
                'click': function () {
                    var centerRegion = Ext.getCmp('knitkitCenterRegion'),
                        websiteId = compassDesktop.getModule('knitkit-win').currentWebsite.id;

                    var url = '/knitkit/erp_app/desktop/articles/show/' + record.get('recordId');

                    Ext.Ajax.request({
                        url: url,
                        method: 'GET',
                        extraParams: {
                            id: record.get('recordId')
                        },
                        timeout: 90000,
                        success: function (response) {
                            var article = Ext.decode(response.responseText);
                            centerRegion.editExcerpt(article.title + ' - Excerpt', record.get('recordId'), article.excerpt_html, websiteId);
                        }
                    });
                }
            }
        });

        items.push({
            text: 'View Comments',
            iconCls: 'icon-eye',
            listeners: {
                'click': function () {
                    var centerRegion = Ext.getCmp('knitkitCenterRegion');

                    centerRegion.viewContentComments(record.get('recordId'), record.get('title') + ' - Comments');
                }
            }
        });
    }

    items.push({
        text: 'Detach Article',
        iconCls: 'icon-delete',
        listeners: {
            'click': function () {

                Ext.MessageBox.confirm('Confirm', 'Are you sure you want to remove this article from the page?', function (btn) {
                    if (btn == 'no') {
                        return false;
                    }
                    else if (btn == 'yes') {

                        Ext.Ajax.request({
                            url: '/knitkit/erp_app/desktop/section/detach_article',
                            method: 'POST',
                            params: {
                                id: record.data.parentItemId,
                                article_id: record.get('recordId')
                            },
                            success: function (response) {
                                var obj = Ext.decode(response.responseText);
                                if (obj.success) {
                                    record.remove(true);

                                }
                                else {
                                    Ext.Msg.alert('Error', 'Error detaching Article');
                                }
                            },
                            failure: function (response) {
                                Ext.Msg.alert('Error', 'Error detaching Article');
                            }
                        });
                    }
                });
            }
        }
    });

    return items;
};