Ext.define("Compass.ErpApp.Desktop.Applications.SecurityManagement.Mixins.Widget", {

    refreshWidget: function(tab) {
        if (tab === undefined) tab = this;

        var available_grid = tab.down('#available');
        var selected_grid = tab.down('#selected');
        if (tab.assign_to_id) {
            var extraParams = {
                type: tab.assign_to,
                id: tab.assign_to_id
            };

            available_grid.getStore().getProxy().extraParams = extraParams;
            available_grid.getStore().load();

            selected_grid.getStore().getProxy().extraParams = extraParams;
            selected_grid.getStore().load();
        } else {
            available_grid.getStore().getProxy().extraParams = {};
            selected_grid.getStore().getProxy().extraParams = {};
        }

    },

    clearWidget: function() {
        var me = this,
            availableGrid = me.down('#available'),
            selectedGrid = me.down('#selected');

        if(availableGrid)
            availableGrid.getStore().removeAll();

        if(selectedGrid)
            selectedGrid.getStore().removeAll();

    }

});
