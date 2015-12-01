Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.VersionsGridPanel", {
    extend: "Ext.grid.Panel",
    initComponent: function () {
        this.callParent(arguments);
        this.getStore().load();
    },

    constructor: function (config) {
        var overiddenColumns = [
            {
                header: 'Version',
                dataIndex: 'version',
                sortable: true,
                width: 75
            },
            {
                header: 'Timestamp',
                dataIndex: 'updated_at',
                sortable: true,
                renderer: Ext.util.Format.dateRenderer('m/d/Y H:i:s'),
                flex: 1
            },
            {
                header: 'Published By',
                dataIndex: 'publisher',
                flex: 1
            }
        ];

        if (!Compass.ErpApp.Utility.isBlank(config['columns'])) {
            overiddenColumns = overiddenColumns.concat(config['columns']);
        }

        overiddenColumns = overiddenColumns.concat([
            {
                header: 'Active',
                dataIndex: 'active',
                sortable: true,
                align: 'center',
                flex: 0.5,
                renderer: function () {
                    var rec = arguments[2];
                    if (rec.get('active')) {
                        return '<img class="x-action-col-0 active-col" ext:qtip="Active" src="data:image/gif;base64,R0lGODlhAQABAID/AMDAwAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==" alt="">';
                    }
                    else {
                        return '<img class="x-action-col-0 activate-col" ext:qtip="Not Active" src="data:image/gif;base64,R0lGODlhAQABAID/AMDAwAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==" alt="">';
                    }
                }
            },
            {
                menuDisabled: true,
                resizable: false,
                xtype: 'actioncolumn',
                header: 'Action',
                align: 'center',
                flex: 0.5,
                items: [
                    {
                        icon: '/assets/icons/eye/eye_16x16.png',
                        tooltip: 'View',
                        getClass: function (v, meta, rec) {
                            return 'x-action-col-icon';
                        },
                        handler: function (grid, rowIndex, colIndex) {
                            var rec = grid.getStore().getAt(rowIndex);
                            grid.ownerCt.viewVersionedContent(rec);
                        }
                    },
                    {
                        icon: '/assets/icons/document_down/document_down_16x16.png',
                        tooltip: 'Revert',
                        getClass: function (v, meta, rec) {
                            return 'x-action-col-icon';
                        },
                        handler: function (grid, rowIndex, colIndex) {
                            var rec = grid.getStore().getAt(rowIndex);
                            grid.ownerCt.revert(rec);
                        }
                    },
                    {
                        getTip: function (value, meta, rec) {
                            if (rec.get('published')) {
                                return 'Published';
                            } else {
                                return 'Publish';
                            }
                        },
                        getClass: function (v, meta, rec) {  // Or return a class from a function
                            if (rec.get('published')) {
                                return 'published-col x-action-col-icon';
                            } else {
                                return 'publish-col x-action-col-icon';
                            }
                        },
                        handler: function (grid, rowIndex, colIndex) {
                            var rec = grid.getStore().getAt(rowIndex);
                            if (rec.get('published')) {
                                return false;
                            }
                            else {
                                grid.ownerCt.publish(rec);
                            }

                        }
                    }
                ]
            }
        ]);

        config['columns'] = overiddenColumns;
        config = Ext.apply({
            collapsed: true,
            bbar: Ext.create("Ext.PagingToolbar", {
                pageSize: 15,
                title: 'Version History',
                store: config['store'],
                displayInfo: true,
                displayMsg: '{0} - {1} of {2}',
                emptyMsg: "Empty"
            })
        }, config);

        this.callParent([config]);
    }
});

Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.VersionsArticleGridPanel", {
    extend: "Compass.ErpApp.Desktop.Applications.Knitkit.VersionsGridPanel",
    alias: 'widget.knitkit_versionsarticlegridpanel',
    collapsed: true,
    viewVersionedContent: function (rec) {
        this.initialConfig['centerRegion'].viewContent(rec.get('title') + " - Revision " + rec.get('version'), rec.get('body_html'));
    },

    revert: function (rec) {
        if (currentUser.hasCapability('revert_version', 'Content')) {
            var self = this;
            self.initialConfig['centerRegion'].setWindowStatus('Reverting...');

            Ext.Ajax.request({
                url: '/knitkit/erp_app/desktop/versions/revert_content',
                method: 'POST',
                params: {
                    id: rec.get('id'),
                    version: rec.get('version')
                },
                success: function (response) {
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    var obj = Ext.decode(response.responseText);
                    if (obj.success) {
                        self.initialConfig['centerRegion'].replaceHtmlInActiveCkEditor(rec.get('body_html'));
                        self.getStore().load();
                    }
                    else {
                        Ext.Msg.alert('Error', 'Error reverting');
                    }
                },
                failure: function (response) {
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    Ext.Msg.alert('Error', 'Error reverting');
                }
            });

        } else {
            currentUser.showInvalidAccess();
        }
    },

    publish: function (rec) {
        if (currentUser.hasCapability('publish', 'Content')) {
            var self = this;

            var publishWindow = Ext.create('Compass.ErpApp.Desktop.Applications.Knitkit.PublishWindow', {
                baseParams: {
                    id: rec.get('id'),
                    site_id: self.initialConfig.siteId,
                    version: rec.get('version')
                },
                url: '/knitkit/erp_app/desktop/versions/publish_content',
                listeners: {
                    'publish_success': function (window, response) {
                        if (response.success) {
                            self.initialConfig['centerRegion'].clearWindowStatus();
                            self.getStore().load();
                        }
                        else {
                            Ext.Msg.alert('Error', 'Error publishing');
                            self.initialConfig['centerRegion'].clearWindowStatus();
                        }
                    },
                    'publish_failure': function (window, response) {
                        self.initialConfig['centerRegion'].clearWindowStatus();
                        Ext.Msg.alert('Error', 'Error publishing');
                    }
                }
            });

            publishWindow.show();
        } else {
            currentUser.showInvalidAccess();
        }
    },

    constructor: function (config) {
        config = Ext.apply({
            title: 'Version History',
            store: Ext.create("Ext.data.Store", {
                proxy: {
                    type: 'ajax',
                    url: '/knitkit/erp_app/desktop/versions/content_versions',
                    reader: {
                        type: 'json',
                        root: 'data'
                    },
                    extraParams: {
                        id: config['contentId'],
                        site_id: config['siteId']
                    }
                },
                idProperty: 'id',
                remoteSort: true,
                fields: [
                    {
                        name: 'published'
                    },
                    {
                        name: 'id'
                    },
                    {
                        name: 'version'
                    },
                    {
                        name: 'title'
                    },
                    {
                        name: 'excerpt_html'
                    },
                    {
                        name: 'body_html'
                    },
                    {
                        name: 'active'
                    },
                    {
                        name: 'updated_at',
                        type: 'date'
                    },
                    {
                        name: 'publisher'
                    }
                ]
            })
        }, config);

        this.callParent([config]);
    }
});

Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.VersionsBlogGridPanel", {
    extend: "Compass.ErpApp.Desktop.Applications.Knitkit.VersionsGridPanel",
    alias: 'widget.knitkit_versionsbloggridpanel',

    viewVersionedContent: function (rec) {
        this.initialConfig['centerRegion'].viewContent(rec.get('title') + " - Revision " + rec.get('version'), rec.get('body_html'));
    },

    revert: function (rec) {
        if (currentUser.hasCapability('revert_version', 'Content')) {
            var self = this;
            self.initialConfig['centerRegion'].setWindowStatus('Reverting...');
            Ext.Ajax.request({
                url: '/knitkit/erp_app/desktop/versions/revert_content',
                method: 'POST',
                params: {
                    id: rec.get('id'),
                    version: rec.get('version')
                },
                success: function (response) {
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    var obj = Ext.decode(response.responseText);
                    if (obj.success) {
                        self.initialConfig['centerRegion'].replaceHtmlInActiveCkEditor(rec.get('body_html'));
                        self.getStore().load();
                    }
                    else {
                        Ext.Msg.alert('Error', 'Error reverting');
                    }
                },
                failure: function (response) {
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    Ext.Msg.alert('Error', 'Error reverting');
                }
            });
        }
    },

    publish: function (rec) {
        var self = this;

        var publishWindow = Ext.create('Compass.ErpApp.Desktop.Applications.Knitkit.PublishWindow', {
            baseParams: {
                id: rec.get('id'),
                site_id: self.initialConfig.siteId,
                version: rec.get('version')
            },
            url: '/knitkit/erp_app/desktop/versions/publish_content',
            listeners: {
                'publish_success': function (window, response) {
                    if (response.success) {
                        self.initialConfig['centerRegion'].clearWindowStatus();
                        self.getStore().load();
                    }
                    else {
                        Ext.Msg.alert('Error', 'Error publishing');
                        self.initialConfig['centerRegion'].clearWindowStatus();
                    }
                },
                'publish_failure': function (window, response) {
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    Ext.Msg.alert('Error', 'Error publishing');
                }
            }
        });

        publishWindow.show();
    },

    constructor: function (config) {
        config = Ext.apply({
            title: 'Version History',
            store: Ext.create("Ext.data.Store", {
                proxy: {
                    type: 'ajax',
                    url: '/knitkit/erp_app/desktop/versions/content_versions',
                    reader: {
                        type: 'json',
                        root: 'data'
                    },
                    extraParams: {
                        id: config['contentId'],
                        site_id: config['siteId']
                    }
                },
                idProperty: 'id',
                remoteSort: true,
                fields: [
                    {
                        name: 'id'
                    },
                    {
                        name: 'version'
                    },
                    {
                        name: 'title'
                    },
                    {
                        name: 'excerpt_html'
                    },
                    {
                        name: 'body_html'
                    },
                    {
                        name: 'active'
                    },
                    {
                        name: 'updated_at',
                        type: 'date'
                    },
                    {
                        name: 'published'
                    },
                    {
                        name: 'publisher'
                    }
                ]
            })
        }, config);

        this.callParent([config]);
    }
});

Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.VersionsWebsiteSectionGridPanel", {
    extend: "Compass.ErpApp.Desktop.Applications.Knitkit.VersionsGridPanel",
    alias: 'widget.knitkit_versionswebsitesectiongridpanel',

    viewVersionedContent: function (rec) {
        this.initialConfig['centerRegion'].setWindowStatus('Loading template...');
        var self = this;
        Ext.Ajax.request({
            url: '/knitkit/erp_app/desktop/versions/get_website_section_version',
            method: 'POST',
            params: {
                id: rec.get('id'),
                version: rec.get('version')
            },
            success: function (response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                var template = response.responseText;
                self.initialConfig['centerRegion'].viewSectionLayout(rec.get('title'), template);
            },
            failure: function (response) {
                self.initialConfig['centerRegion'].clearWindowStatus();
                Ext.Msg.alert('Error', 'Error loading tempalte');
            }
        });
    },

    revert: function (rec) {
        if (currentUser.hasCapability('revert_version', 'Content')) {
            var self = this;
            self.initialConfig['centerRegion'].setWindowStatus('Reverting...');
            Ext.Ajax.request({
                url: '/knitkit/erp_app/desktop/versions/revert_website_section',
                method: 'POST',
                params: {
                    id: rec.get('id'),
                    version: rec.get('version')
                },
                success: function (response) {
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    var obj = Ext.decode(response.responseText);
                    if (obj.success) {
                        self.initialConfig['centerRegion'].replaceContentInActiveCodeMirror(obj.body_html);
                        self.getStore().load();
                    }
                    else {
                        Ext.Msg.alert('Error', 'Error reverting');
                    }
                },
                failure: function (response) {
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    Ext.Msg.alert('Error', 'Error reverting');
                }
            });
        }
    },

    publish: function (rec) {
        var self = this;

        var publishWindow = Ext.create('Compass.ErpApp.Desktop.Applications.Knitkit.PublishWindow', {
            baseParams: {
                id: rec.get('id'),
                site_id: self.initialConfig.siteId,
                version: rec.get('version')
            },
            url: '/knitkit/erp_app/desktop/versions/publish_website_section',
            listeners: {
                'publish_success': function (window, response) {
                    if (response.success) {
                        self.initialConfig['centerRegion'].clearWindowStatus();
                        self.getStore().load();
                    }
                    else {
                        Ext.Msg.alert('Error', 'Error publishing');
                        self.initialConfig['centerRegion'].clearWindowStatus();
                    }
                },
                'publish_failure': function (window, response) {
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    Ext.Msg.alert('Error', 'Error publishing');
                }
            }
        });

        publishWindow.show();
    },

    constructor: function (config) {
        config = Ext.apply({
            title: 'Version History',
            store: Ext.create("Ext.data.Store", {
                proxy: {
                    type: 'ajax',
                    url: '/knitkit/erp_app/desktop/versions/website_section_layout_versions',
                    reader: {
                        type: 'json',
                        root: 'data'
                    },
                    extraParams: {
                        id: config['websiteSectionId'],
                        site_id: config['siteId']
                    }
                },
                idProperty: 'id',
                remoteSort: true,
                fields: [
                    {
                        name: 'id'
                    },
                    {
                        name: 'version'
                    },
                    {
                        name: 'title'
                    },
                    {
                        name: 'updated_at',
                        type: 'date'
                    },
                    {
                        name: 'active'
                    },
                    {
                        name: 'published'
                    },
                    {
                        name: 'publisher'
                    }
                ]
            })
        }, config);

        this.callParent([config]);
    }
});

Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.NonPublishedVersionsGridPanel", {
    extend: "Ext.grid.Panel",
    alias: 'widget.knitkit_nonpublishedversionswebsitesectiongridpanel',
    viewVersionedContent: function (rec) {
        this.initialConfig['centerRegion'].viewContent(rec.get('title') + " - Revision " + rec.get('version'), rec.get('body_html'));
    },

    revert: function (rec) {
        if (currentUser.hasCapability('revert_version', 'Content')) {
            var self = this;
            self.initialConfig['centerRegion'].setWindowStatus('Reverting...');
            Ext.Ajax.request({
                url: '/knitkit/erp_app/desktop/versions/revert_content',
                method: 'POST',
                params: {
                    id: rec.get('id'),
                    version: rec.get('version')
                },
                success: function (response) {
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    var obj = Ext.decode(response.responseText);
                    if (obj.success) {
                        self.initialConfig['centerRegion'].replaceHtmlInActiveCkEditor(rec.get('body_html'));
                        self.getStore().load();
                    }
                    else {
                        Ext.Msg.alert('Error', 'Error reverting');
                    }
                },
                failure: function (response) {
                    self.initialConfig['centerRegion'].clearWindowStatus();
                    Ext.Msg.alert('Error', 'Error reverting');
                }
            });
        }
    },

    initComponent: function () {
        this.callParent(arguments);
        this.getStore().load();
    },

    constructor: function (config) {
        var store = Ext.create("Ext.data.Store", {
            title: 'Version History',
            proxy: {
                type: 'ajax',
                url: '/knitkit/erp_app/desktop/versions/non_published_content_versions',
                reader: {
                    type: 'json',
                    root: 'data'
                },
                extraParams: {
                    id: config['contentId']
                }
            },
            idProperty: 'id',
            remoteSort: true,
            fields: [
                {
                    name: 'id'
                },
                {
                    name: 'version'
                },
                {
                    name: 'title'
                },
                {
                    name: 'excerpt_html'
                },
                {
                    name: 'body_html'
                },
                {
                    name: 'updated_at',
                    type: 'date'
                }
            ]
        });

        config = Ext.apply({
            columns: [
                {
                    header: 'Version',
                    dataIndex: 'version',
                    style: {
                        textAlign: 'center'
                    },
                    sortable: true,
                    width: 75
                },
                {
                    header: 'Timestamp',
                    dataIndex: 'updated_at',
                    sortable: true,
                    renderer: Ext.util.Format.dateRenderer('m/d/Y H:i:s'),
                    flex: 1
                },
                {
                    menuDisabled: true,
                    resizable: false,
                    xtype: 'actioncolumn',
                    header: 'Action',
                    align: 'center',
                    flex: 0.5,
                    items: [
                        {
                            icon: '/assets/icons/eye/eye_16x16.png',
                            tooltip: 'View',
                            getClass: function (v, meta, rec) {
                                return 'x-action-col-icon';
                            },
                            handler: function (grid, rowIndex, colIndex) {
                                var rec = grid.getStore().getAt(rowIndex);
                                grid.ownerCt.viewVersionedContent(rec);
                            }
                        },
                        {
                            icon: '/assets/icons/document_down/document_down_16x16.png',
                            tooltip: 'Revert',
                            getClass: function (v, meta, rec) {
                                return 'x-action-col-icon';
                            },
                            handler: function (grid, rowIndex, colIndex) {
                                var rec = grid.getStore().getAt(rowIndex);
                                grid.ownerCt.revert(rec);
                            }
                        }
                    ]
                }
            ],
            store: store,
            bbar: Ext.create("Ext.PagingToolbar", {
                pageSize: 15,
                store: store,
                displayInfo: true,
                displayMsg: '{0} - {1} of {2}',
                emptyMsg: "Empty"
            })
        }, config);

        this.callParent([config]);
    }
});
