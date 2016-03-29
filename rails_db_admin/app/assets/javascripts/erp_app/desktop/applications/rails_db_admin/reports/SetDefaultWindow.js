Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.Reports.SetDefaultWindow", {
    extend: 'Ext.window.Window',
    alias: 'widget.railsdbadminreportssetdefaultwindow',
    title: 'Set Default',
    modal: true,
    height: 300,
    width: 400,
    buttonAlign: 'center',

    paramsManager: null,
    report: null,

    buttons: [
        {
            text: 'Save',
            handler: function (btn) {
                var me = btn.up('window');

                var grid = me.paramsManager.down('grid');
                var form = me.down('form');

                if (form.isValid()) {
                    var values = form.getValues();

                    me.report.set('default_value', values.default_value);
                    me.report.commit(false);

                    me.paramsManager.save();

                    me.hide();
                }
            }
        },
        {
            text: 'Cancel',
            handler: function (btn) {
                var window = btn.up('window');

                window.hide();
            }
        }
    ],

    initComponent: function () {
        var me = this;

        var reportTypeStore = Ext.create('Ext.data.Store', {
            fields: ['name', 'type'],
            data: [
                {name: 'Text', type: 'text'},
                {name: 'Date', type: 'date'},
                {name: 'Select', type: 'select'},
                {name: 'Data Record', type: 'data_record'},
                {name: 'Service', type: 'service'}
            ]
        });

        me.items = [
            {
                xtype: 'form',
                itemId: 'addReportParam',
                bodyPadding: 10,
                layout: 'form',
                items: []
            }
        ];

        this.callParent(arguments);

        me.setType(me.report.get('type'));
    },

    setType: function (type) {
        var me = this;
        var form = me.down('form');

        switch (type) {
            case 'text':
                form.add(me.buildDefaultTextField(me.report));
                break;
            case 'date':
                form.add(me.buildDefaultDateField(me.report));
                break;
            case 'select':
                form.add(me.buildDefaultSelectField(me.report));
                break;
            case 'data_record':
                form.add(me.buildDefaultDataRecordField(me.report));
                break;
            case 'service':
                form.add(me.buildDefaultServiceUrlField(me.report));
                break;
        }
    },

    /**
     * Builds default textfield.
     * @report (Object) The current report being edited
     */
    buildDefaultTextField: function (report) {
        var defaultValue = null;

        if (report) {
            defaultValue = report.get('default_value');
        }

        return [{
            xtype: 'textfield',
            fieldLabel: 'Default Value',
            name: 'default_value',
            value: defaultValue
        }];
    },

    /**
     * Builds date field.
     * @report (Object) The current report being edited
     */
    buildDefaultDateField: function (report) {
        var defaultValue = 'current_date';

        if (report) {
            defaultValue = report.get('default_value');
        }

        return [{
            xtype: 'combo',
            fieldLabel: 'Default Value',
            name: 'default_value',
            displayField: 'display',
            valueField: 'value',
            store: Ext.create('Ext.data.Store', {
                fields: ['display', 'value'],
                data: [
                    {display: 'Current Date', value: 'current_date'}
                ]
            }),
            queryMode: 'local',
            value: defaultValue
        }];
    },

    /**
     * Builds select field to set the default value of param of type select.
     * @report (Object) The current report being edited
     */
    buildDefaultSelectField: function (report) {
        var defaultValue = null;
        var options = {values: []};

        if (report) {
            defaultValue = report.get('default_value');
            options = report.get('options');
        }

        return [{
            xtype: 'combo',
            fieldLabel: 'Default Value',
            queryMode: 'local',
            store: eval((options.values || '[]')),
            name: 'default_value',
            value: defaultValue
        }];
    },

    /**
     * Builds a data report field to set the default value of param of type data report
     * @report (Object) The current report being edited
     */
    buildDefaultDataRecordField: function (report) {
        var defaultValue = null;
        var options = {};

        if (report) {
            defaultValue = report.get('default_value');
            options = report.get('options');
        }

        return [{
            xtype: 'businessmoduledatarecordfield',
            fieldLabel: 'Default Value',
            extraParams: {business_module_iid: options.businessModule},
            name: 'default_value',
            value: defaultValue
        }];
    },

    /**
     * Builds a data report field to set the default value of param of type data report
     * @report (Object) The current report being edited
     */
    buildDefaultServiceUrlField: function (report) {
        var defaultValue = null;
        var options = {};

        if (report) {
            defaultValue = report.get('default_value');
            options = report.get('options');
        }

        // make sure we have all the options we need
        if (options.root && options.displayField && options.valueField) {
            return [{
                xtype: 'combo',
                fieldLabel: 'Default Value',
                name: 'default_value',
                value: defaultValue,
                displayField: options.displayField,
                valueField: options.valueField,
                queryMode: 'remote',
                store: {
                    proxy: {
                        type: 'ajax',
                        url: options.url,
                        reader: {
                            type: 'json',
                            root: options.root
                        }
                    },
                    fields: [
                        options.displayField,
                        options.valueField
                    ],
                    autoLoad: true
                }
            }];
        }
        else {
            return null;
        }
    }
});