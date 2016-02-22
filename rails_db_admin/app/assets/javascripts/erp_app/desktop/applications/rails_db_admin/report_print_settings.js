Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReportsPrintSettings", {
    extend: "Ext.form.Panel",
    alias: 'widget.railsdbadminreportsprintsettings',
    title: 'Report Print Settings',
    report: null,
    reportId: null,
    labelWidth: 110,
    frame: false,
    bodyStyle: 'padding:5px 5px 0',
    url: '/rails_db_admin/erp_app/desktop/reports/update',
    defaults: {
        width: 225
    },
    tbar: [
        {
            xtype: 'button',
            text: 'Save',
            iconCls: 'icon-save',
            handler: function(btn){
                var form = btn.up('railsdbadminreportsprintsettings');
                form.getForm().submit({
                    waitMsg: 'Updating Report...',
                    params: {
                        id: form.reportId
                    },
                    success: function (form, action) {
                        var obj = Ext.decode(action.response.responseText);
                        if (obj.success) {
                            Ext.getCmp('rails_db_admin').down('railsdbadmin_reportstreepanel').getStore().load();
                        }
                        else {
                            Ext.Msg.alert("Error", obj.msg);
                        }
                    },
                    failure: function (form, action) {
                        var obj = Ext.decode(action.response.responseText);
                        if (obj.msg) {
                            Ext.Msg.alert("Error", obj.msg);
                        }
                        else {
                            Ext.Msg.alert("Error", "Error updating report.");
                        }
                    }
                });
            }
        }
    ],

    initComponent: function(){
        var me = this;
        me.items =[];
        me.callParent();
    },

    setReportPrintSettings: function(report){
        var me = this,
            reportMetaData = report.get('reportMetaData') || report.parentNode.get('reportMetaData')
            reportId = report.get('reportId') || report.get('id');
        me.removeAll();
        me.report = report;
        me.reportId = reportId;
        me.add(
            {
                xtype: 'displayfield',
                fieldLabel: 'Report Name',
                value: report.get('reportName')
            },
            {
                xtype: 'checkbox',
                fieldLabel: 'Auto Execute',
                name: 'auto_execute',
                checked: reportMetaData.auto_execute
            },
            {
                xtype: 'combo',
                fieldLabel: 'Page Size',
                name: 'page_size',
                displayField: 'pageSize',
                valueField: 'size',
                store: {
                    fields: ['pageSize', 'size'],
                    data: [
                        {pageSize: 'A4', size: 'A4'},
                        {pageSize: 'A3', size: 'A3'},
                        {pageSize: 'A2', size: 'A2'},
                        {pageSize: 'A1', size: 'A1'},
                        {pageSize: 'A0', size: 'A0'}
                    ]
                },
                listeners: {
                    afterrender: function (combo, eOpts) {
                        var store = combo.getStore(),
                            pageSize = reportMetaData.print_page_size || 'A4';

                        combo.setValue(pageSize);
                    }
                }
            },
            {
                xtype: 'textfield',
                fieldLabel: 'Top Margin',
                name: 'margin_top',
                value: reportMetaData.print_margin_top || '10'
            },
            {
                xtype: 'textfield',
                fieldLabel: 'Right Margin',
                name: 'margin_right',
                value: reportMetaData.print_margin_right || '10'

            },
            {
                xtype: 'textfield',
                fieldLabel: 'Bottom Margin',
                name: 'margin_bottom',
                value: reportMetaData.print_margin_bottom || '10'
            },
            {
                xtype: 'textfield',
                fieldLabel: 'Left Margin',
                name: 'margin_left',
                value: reportMetaData.print_margin_left || '10'
            }
        );
    }
});
