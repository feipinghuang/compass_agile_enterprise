Ext.define('Compass.ErpApp.Shared.Party.ApplicationModel', {
    extend: 'Ext.data.Model',
    fields: [
        // ExtJs node fields
        {
            name: 'text',
            type: 'string',
            mapping: 'description'
        }, {
            name: 'leaf',
            type: 'boolean'
        }, {
            name: 'checked',
            type: 'boolean'
        }, {
            name: 'iconCls',
            type: 'string',
            mapping: 'icon'
        },
        // Custom fields
        {
            name: 'internalIdentifier',
            type: 'string',
            mapping: 'internal_identifier'
        }
    ]
});

Ext.define("CompassAE.ErpApp.Shared.Party.AppsInstalledPanel", {
    extend: 'Ext.form.Panel',
    alias: 'widget.partyappsinstalledpanel',

    title: 'Apps Installed',
    autoScroll: true,

    userId: null,
    availableTools: [],
    availableApps: [],
    fieldSetHeights: 250,

    layout: 'hbox',

    dockedItems: {
        xtype: 'toolbar',
        docked: 'top',
        items: [{
            text: 'Save',
            iconCls: 'icon-save',
            handler: function(btn) {
                btn.up('form').save(btn);
            }
        }]
    },

    initComponent: function() {
        var me = this;

        me.addEvents(
            /*
             * @event saved
             * Fires when view is saved
             * @param {CompassAE.ErpApp.Shared.Party.AppsInstalledPanel} this panel
             * @param {Array} Selected Application IIds
             */
            'saved'
        );

        me.callParent(arguments);

        me.add({
            xtype: 'fieldset',
            width: 450,
            title: 'Admin & Dev Tools',
            itemId: 'tools',
            style: {
                marginLeft: '10px',
                marginRight: '10px',
                padding: '5px'
            },
            items: [{
                xtype: 'treepanel',
                height: me.fieldSetHeights,
                itemId: 'toolsTree',
                store: {
                    autoLoad: false,
                    model: 'Compass.ErpApp.Shared.Party.ApplicationModel',
                    proxy: {
                        type: 'ajax',
                        url: '/api/v1/applications.tree',
                        root: 'applications',
                        extraParams: {
                            types: 'tool'
                        },
                        reader: {
                            root: 'applications'
                        }
                    },
                    root: {
                        expanded: false
                    }
                },
                rootVisible: false,
                animate: false,
                autoScroll: true,
                containerScroll: true,
                border: false,
                frame: false
            }]
        }, {
            xtype: 'fieldset',
            width: 450,
            title: 'End User Apps',
            itemId: 'apps',
            style: {
                marginLeft: '10px',
                marginRight: '10px',
                padding: '5px'
            },
            items: [{
                xtype: 'treepanel',
                height: me.fieldSetHeights,
                itemId: 'userAppsTree',
                store: {
                    autoLoad: false,
                    model: 'Compass.ErpApp.Shared.Party.ApplicationModel',
                    proxy: {
                        type: 'ajax',
                        url: '/api/v1/applications.tree',
                        root: 'applications',
                        extraParams: {
                            types: 'app'
                        },
                        reader: {
                            root: 'applications'
                        }
                    },
                    root: {
                        text: 'Applications',
                        expanded: false
                    }
                },
                rootVisible: false,
                animate: false,
                autoScroll: true,
                containerScroll: true,
                border: false,
                frame: false
            }]
        });

        me.on('activate', function() {
            me.setDbaOrganizationOnApplications();

            var loadToolsTree = function() {
                var dfd = Ext.create('Ext.ux.Deferred');

                me.down('#toolsTree').getRootNode().expand(false, function() {
                    dfd.resolve();
                });

                return dfd.promise();
            };

            var loadAppsTree = function() {
                var dfd = Ext.create('Ext.ux.Deferred');

                me.down('#userAppsTree').getRootNode().expand(false, function() {
                    dfd.resolve();
                });

                return dfd.promise();
            };

            if (me.userId) {
                var mask = new Ext.LoadMask({
                    msg: 'Please wait...',
                    target: me
                });
                mask.show();

                var loadCurrentTools = function() {
                    var dfd = Ext.create('Ext.ux.Deferred');

                    Compass.ErpApp.Utility.ajaxRequest({
                        url: '/api/v1/users/' + me.userId + '/applications',
                        method: 'GET',
                        params: {
                            types: 'tool'
                        },
                        errorMessage: 'Could not load installed Applications',
                        success: function(response) {
                            var applicationIids = Ext.Array.pluck(response.applications, 'internal_identifier');

                            if (me.down('#toolsTree')) {
                                me.down('#toolsTree').getRootNode().cascadeBy(function(node) {
                                    if (Ext.Array.contains(applicationIids, node.get('internalIdentifier'))) {
                                        node.set('checked', true);
                                    }
                                });
                            }

                            dfd.resolve();
                        },
                        failure: function() {
                            dfd.reject();
                        }
                    });

                    return dfd.promise();
                };

                var loadCurrentApps = function() {
                    var dfd = Ext.create('Ext.ux.Deferred');

                    Compass.ErpApp.Utility.ajaxRequest({
                        url: '/api/v1/users/' + me.userId + '/applications',
                        method: 'GET',
                        params: {
                            types: 'app'
                        },
                        errorMessage: 'Could not load installed Applications',
                        success: function(response) {
                            var applicationIids = Ext.Array.pluck(response.applications, 'internal_identifier');

                            if (me.down('#userAppsTree')) {
                                me.down('#userAppsTree').getRootNode().cascadeBy(function(node) {
                                    if (Ext.Array.contains(applicationIids, node.get('internalIdentifier'))) {
                                        node.set('checked', true);
                                    }
                                });
                            }

                            dfd.resolve();
                        },
                        failure: function() {
                            dfd.reject();
                        }
                    });

                    return dfd.promise();
                };

                Ext.ux.Deferred.when(loadToolsTree)
                    .then(loadAppsTree,
                        function() {
                            mask.hide();
                        })
                    .then(loadCurrentTools,
                        function() {
                            mask.hide();
                        })
                    .then(loadCurrentApps,
                        function() {
                            mask.hide();
                        })
                    .then(function(results) {
                        mask.hide();
                    }, function(errors) {
                        mask.hide();
                    });
            }
        });
    },

    save: function(btn) {
        var me = this;
        var toolsTree = me.down('#toolsTree');
        var userAppsTree = me.down('#userAppsTree');
        var selectedApplicationIids = [];

        btn.disable();

        toolsTree.getRootNode().cascadeBy(function(node) {
            if (node.get('checked')) {
                selectedApplicationIids.push(node.get('internalIdentifier'));
            }
        });

        userAppsTree.getRootNode().cascadeBy(function(node) {
            if (node.get('checked')) {
                selectedApplicationIids.push(node.get('internalIdentifier'));
            }
        });

        var mask = new Ext.LoadMask({
            msg: 'Please wait...',
            target: me
        });
        mask.show();

        Compass.ErpApp.Utility.ajaxRequest({
            url: '/api/v1/users/' + me.userId + '/applications/install',
            method: 'PUT',
            params: {
                application_iids: selectedApplicationIids.join(',')
            },
            errorMessage: 'Could not save installed Applications',
            success: function(response) {
                me.fireEvent('saved', me, selectedApplicationIids);

                btn.enable();
                mask.hide();
            },
            failure: function() {
                btn.enable();
                mask.hide();
            }
        });
    },

    setDbaOrganizationOnApplications: function() {
        var me = this;

        // set dba organization id for applications
        var dbaOrganizationId = currentUser.dbaOrganizationId;

        // if the parent module is a Party and it is an Organization that is the DbaOrganization
        if (me.up('businessmoduledetailview') && me.up('businessmoduledetailview').parentDetailView && me.up('businessmoduledetailview').parentRecordData.sub_module_record_type == 'Organization' && Ext.Array.contains(me.up('businessmoduledetailview').parentRecordData.role_types, 'dba_org')) {

            dbaOrganizationId = me.up('businessmoduledetailview').parentDetailView.recordData.id;
        }

        me.down('#userAppsTree').store.getProxy().setExtraParam('dba_organization_id', dbaOrganizationId);
        me.down('#toolsTree').store.getProxy().setExtraParam('dba_organization_id', dbaOrganizationId);
    }
});