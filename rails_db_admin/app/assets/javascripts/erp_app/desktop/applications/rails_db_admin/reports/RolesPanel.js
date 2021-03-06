Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.Reports.RolesPanel", {
    extend: "Ext.panel.Panel",
    alias: 'widget.railsdbadminreportsrolespanel',
    title: 'Security/Visibility',
    reportId: null,
    reportRoles: null,
    tbar: [
        {
            xtype: 'button',
            text: 'Save',
            iconCls: 'icon-save',
            handler: function(btn){
                var panel = btn.up('railsdbadminreportsrolespanel'),
                    reportRoles = panel.down('typeselectiontree').getSelectedTypes(),
                    waitMsg = Ext.Msg.wait("Loading roles...");

                Ext.Ajax.request({
                    url:'/rails_db_admin/erp_app/desktop/reports/update',
                    method: 'POST',
                    params: {
                        id: panel.reportId,
                        report_roles: reportRoles.join(',')
                    },
                    success: function(response){
                        waitMsg.close();
                        var responseObj = Ext.decode(response.responseText);
                        if(responseObj.success){

                        }else{
                            waitMsg.close();
                            Ext.msg.alert('Error', 'Erorr setting roles');
                        }
                    },
                    failure: function(){
                        waitMsg.close();
                        Ext.msg.alert('Error', 'Erorr setting roles');
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

    setReportRoles: function(report){
        var me = this;

        me.removeAll();
        me.reportId = report.get('reportId');
        me.add({
            xtype: 'typeselectiontree',
            title: 'Select Roles',
            typesUrl: '/api/v1/role_types',
            typesRoot: 'role_types',
            canCreate: true,
            cascadeSelectionDown: true,
            availableTypes: [],
            defaultParentType: 'report'
        });
        var roleTypesTree = me.down('typeselectiontree'),
            availableRoleTypes = [],
            waitMsg = Ext.Msg.wait("Loading roles...");

        Ext.Ajax.request({
            url: '/api/v1/role_types.tree',
            method: 'GET',
            params: {
                parent: 'report'
            },
            success: function (response) {
                waitMsg.close();
                var responseObj = Ext.decode(response.responseText);
                if (responseObj.success) {
                    availableRoleTypes = responseObj.role_types;
                    roleTypesTree.setAvailableTypes(availableRoleTypes);
                    roleTypesTree.setSelectedTypes(report.get('reportMetaData').roles || []);

                }else{
                    waitMsg.close();
                    Ext.msg.alert('Error', 'Error loading roles');
                }
            },
            failure: function(){
                waitMsg.close();
                Ext.msg.alert('Error', 'Error loading roles');
            }
        });
    }
});
