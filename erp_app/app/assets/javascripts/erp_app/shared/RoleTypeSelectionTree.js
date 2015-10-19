Ext.define('TreeReader', {
    extend: 'Ext.data.reader.Json',
    alias: 'reader.treereader',

    buildExtractors: function () {
        var me = this,
            metaProp = me.metaProperty;

        me.callParent(arguments);

        me.getRoot = function (node) {
            // Special cases
            if (node['children']) {
                return node['children'];
            }
            else {
                return node[me.root]
            }
        };
    }
});

Ext.define('Compass.ErpApp.Shared.RoleTypeSelectionModel', {
    extend: 'Ext.data.Model',
    fields: [
        // ExtJs node fields
        {name: 'text', type: 'string'},
        {name: 'leaf', type: 'boolean'},
        {name: 'checked', type: 'boolean'},
        {name: 'children'},
        // Custom fields
        {name: 'internalIdentifier', type: 'string', mapping: 'internal_identifier'}
    ]
});

Ext.define("Compass.ErpApp.Shared.RoleTypeSelectionTree", {
    extend: "Ext.tree.Panel",
    alias: 'widget.roletypeselectiontree',

    title: 'Select Roles',
    height: 200,
    maxHeight: 200,
    width: '100%',
    autoScroll: true,
    rootVisible: false,
    availableRoleTypes: [],
    selectedRoleTypes: [],
    cascadeSelectionUp: false,
    cascadeSelectionDown: false,

    // true to all users to create a role type
    canCreate: false,

    // default parent role type if no parent is selected
    defaultParentRoleType: null,

    listeners: {
        'checkchange': function (node, checked) {
            var me = this;

            if (me.cascadeSelectionUp) {
                var rootNode = me.getRootNode();
                var parentNode = node;
                var childChecked = false;

                while (parentNode != rootNode) {
                    childChecked = false;

                    parentNode.eachChild(function (child) {
                        if (child.get('checked')) {
                            childChecked = true;
                        }
                    });

                    if (!checked && !childChecked) {
                        parentNode.set('checked', checked);
                    }

                    if (!checked && childChecked) {
                        parentNode.set('checked', !checked);
                    }

                    if (checked && childChecked) {
                        parentNode.set('checked', checked);
                    }

                    parentNode = parentNode.parentNode;
                }
            }

            if (me.cascadeSelectionDown) {
                if (node.get('checked')) {
                    node.cascadeBy(function (childNode) {
                        childNode.set('checked', true);
                    });
                }
            }
        }
    },

    initComponent: function () {
        var me = this;

        me.store = Ext.create('Ext.data.TreeStore', {
            model: 'Compass.ErpApp.Shared.RoleTypeSelectionModel',
            folderSort: true,
            sorters: [
                {
                    property: 'text',
                    direction: 'ASC'
                }
            ]
        });

        me.store.setRootNode({text: '', children: me.availableRoleTypes});

        if (me.canCreate) {
            me.dockedItems = [
                {
                    xtype: 'toolbar',
                    items: [
                        {
                            xtype: 'button',
                            text: 'Create New Role',
                            iconCls: 'icon-add',
                            handler: function () {
                                me.showCreateRoleType();
                            }
                        }
                    ]
                }
            ]
        }

        me.callParent(arguments);

        me.collapseAll();

        if (me.selectedRoleTypes) {
            me.setSelectedRoleTypes(me.selectedRoleTypes);
        }
    },

    showCreateRoleType: function () {
        var me = this;

        var window = Ext.widget('window', {
            title: 'Create Role Type',
            modal: true,
            layout: 'fit',
            plain: true,
            buttonAlign: 'center',
            items: [
                {
                    xtype: 'form',
                    url: '/api/v1/role_types',
                    defaults: {
                        width: 375,
                        xtype: 'textfield'
                    },
                    bodyStyle: 'padding:5px 5px 0',
                    items: [
                        {
                            xtype: 'combo',
                            name: 'parent',
                            itemId: 'parentRoleType',
                            emptyText: 'No Parent',
                            width: 320,
                            loadingText: 'Retrieving Role Types...',
                            store: Ext.create("Ext.data.Store", {
                                proxy: {
                                    type: 'ajax',
                                    url: '/api/v1/role_types.json',
                                    reader: {
                                        type: 'json',
                                        root: 'role_types'
                                    },
                                    extraParams: {
                                        parent: me.defaultParentRoleType
                                    }
                                },
                                fields: [
                                    {
                                        name: 'internal_identifier'
                                    },
                                    {
                                        name: 'description'

                                    }
                                ]
                            }),
                            forceSelection: true,
                            allowBlank: true,
                            editable: false,
                            fieldLabel: 'Parent Role',
                            mode: 'remote',
                            displayField: 'description',
                            valueField: 'internal_identifier',
                            triggerAction: 'all',
                            listConfig: {
                                tpl: '<div class="my-boundlist-item-menu">No Parent</div><tpl for="."><div class="x-boundlist-item">{description}</div></tpl>',
                                listeners: {
                                    el: {
                                        delegate: '.my-boundlist-item-menu',
                                        click: function () {
                                            window.down('#parentRoleType').clearValue();
                                        }
                                    }
                                }
                            }
                        },
                        {
                            fieldLabel: 'Name',
                            allowBlank: false,
                            name: 'description'
                        }
                    ]
                }
            ],
            buttons: [
                {
                    text: 'Submit',
                    listeners: {
                        'click': function (button) {
                            var window = button.findParentByType('window');
                            var formPanel = window.down('form');

                            if (formPanel.isValid()) {
                                formPanel.getForm().submit({
                                    timeout: 30000,
                                    waitMsg: 'Creating role type...',
                                    params: {
                                        default_parent: me.defaultParentRoleType
                                    },
                                    success: function (form, action) {
                                        var responseObj = Ext.decode(action.response.responseText);

                                        if (responseObj.success) {
                                            var values = formPanel.getValues();
                                            var parentNode = me.getRootNode();

                                            if (!Ext.isEmpty(values.parent)) {
                                                parentNode = parentNode.findChildBy(function (node) {
                                                    if (node.data.internalIdentifier == values.parent) {
                                                        return true;
                                                    }
                                                }, this, true);
                                            }

                                            parentNode.set('leaf', false);
                                            parentNode.appendChild({
                                                text: responseObj.role_type.description,
                                                internalIdentifier: responseObj.role_type.internal_identifier,
                                                checked: false,
                                                leaf: true,
                                                children: []
                                            });

                                            window.close();
                                        }
                                        else {
                                            Ext.Msg.alert("Error", responseObj.message);
                                        }
                                    },
                                    failure: function (form, action) {
                                        Compass.ErpApp.Utility.handleFormFailure(action);
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
        });
        window.show();
    },

    getSelectedRoleTypes: function () {
        var me = this;
        var roleTypes = [];

        me.getRootNode().cascadeBy(function (node) {
            if (me.cascadeSelectionUp) {
                var childChecked = false;
                node.eachChild(function (child) {
                    if (child.get('checked')) {
                        childChecked = true;
                    }
                });
                if (node.get('checked') && !childChecked) {
                    roleTypes.push(node.get('internalIdentifier'));
                }
            }
            else {
                if (node.get('checked')) {
                    roleTypes.push(node.get('internalIdentifier'));
                }
            }
        });
        return Ext.Array.clean(roleTypes);
    },

    setAvailableRoleTypes: function (roleTypes) {
        var me = this;

        me.store.setRootNode({text: '', children: roleTypes});
    },

    setSelectedRoleTypes: function (roleTypes) {
        var me = this;

        roleTypes = Ext.Array.clean(roleTypes.split(','));

        me.getRootNode().cascadeBy(function (node) {
            if (Ext.Array.contains(roleTypes, node.get('internalIdentifier'))) {
                node.set('checked', true);
                var parentNode = node.parentNode;

                if (me.cascadeSelectionUp) {
                    while (parentNode != me.getRootNode()) {
                        parentNode.set('checked', true);
                        parentNode.expand();
                        parentNode = parentNode.parentNode;
                    }
                }

                // expand nodes
                while (parentNode != me.getRootNode()) {
                    parentNode.expand();
                    parentNode = parentNode.parentNode;
                }
            }
        });
    }
});
