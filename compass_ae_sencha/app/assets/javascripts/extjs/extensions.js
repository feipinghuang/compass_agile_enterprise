Ext.define('TreeReader', {
    extend: 'Ext.data.reader.Json',
    alias: 'reader.treereader',

    buildExtractors: function() {
        var me = this,
            metaProp = me.metaProperty;

        me.callParent(arguments);

        me.getRoot = function(node) {
            // Special cases
            if (node['children']) {
                return node['children'];
            } else {
                return node[me.root];
            }
        };
    }
});