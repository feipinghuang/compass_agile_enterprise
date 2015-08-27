Ext.define('SystemManagementTypeTreeNode', {
    extend: 'Ext.data.Model',
    fields: [
        // ExtJs node fields
        {name: 'serverId', type: 'integer', mapping: 'id', useNull: true},
        {name: 'text', type: 'string', mapping: 'description'},
        {name: 'leaf', type: 'boolean'},
        {name: 'children'},
        // Custom fields
        {name: 'klass', type: 'string'},
        {name: 'internalIdentifier', type: 'string', mapping: 'internal_identifier'}
    ]
});

Ext.define('SystemManagementTypeTreeNodeStore', {
    autoLoad: true,
    extend: 'Ext.data.TreeStore',
    model: 'SystemManagementTypeTreeNode',
    folderSort: true,
    sorters: [
        {
            property: 'text',
            direction: 'ASC'
        }
    ],
    proxy: {
        type: 'ajax',
        url: '/erp_app/desktop/system_management/types',
        reader: {
            type: 'json',
            successProperty: 'success',
            root: 'types'
        }
    },
    root: {
        text: 'Types',
        expanded: true
    },
    listeners: {
        beforeexpand: function (node, eOpts) {
            if (!node.isRoot()) {
                var tree = node.getOwnerTree();
                tree.getStore().getProxy().setExtraParam('parent_id', node.get('serverId'));
                tree.getStore().getProxy().setExtraParam('klass', node.get('klass'));
            }
        }
    }
});