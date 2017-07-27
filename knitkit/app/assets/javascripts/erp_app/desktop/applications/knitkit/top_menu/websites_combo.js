Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.WebsitesComboBox", {
    extend: "Ext.form.field.ComboBox",
    alias: 'widget.websitescombo',
    initComponent: function () {
        var self = this;

        var websiteJsonStore = Ext.create('Ext.data.Store', {
            timeout: 60000,
            proxy: {
                type: 'ajax',
                url: '/knitkit/erp_app/desktop/site/index',
                reader: {
                    type: 'json',
                    root: 'sites'
                }
            },
            fields: [
                'name',
                'title',
                'subtitle',
                'id',
                'url',
                {name: 'configurationId', mapping: 'configuration_id'}
            ]
        });

        self.store = websiteJsonStore;

        self.callParent(arguments);

        websiteJsonStore.load({
            callback: function (records, operation, succes) {
                if (records.length > 0) {
                    self.select(records.first());

                    var knitkitWin = compassDesktop.getModule('knitkit-win');

                    knitkitWin.selectWebsite(records.first());
                }
            }
        });
    },

    constructor: function (config) {
        config = Ext.apply({
            id: 'websiteCombo',
            emptyText: 'No Websites',
            fieldStyle: {
                borderRadius: '0px !important'
            },
            valueField: 'id',
            displayField: 'name',
            triggerAction: 'all',
            editable: false,
            forceSelection: true,
            queryMode: 'local',
            listeners: {
                'select': function (combo, records) {
                    var knitkitModule = compassDesktop.getModule('knitkit-win');

                    knitkitModule.selectWebsite(records.first());
                },
                render: function (combo) {
                    combo.getStore().load();
                }
            }
        }, config);

        this.callParent([config]);
    }
});
