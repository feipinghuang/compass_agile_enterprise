Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.ReportsRolesPanel", {
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
                    reportRoles = panel.down('roletypeselectiontree').getSelectedRoleTypes(),
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

    setReportRoles: function(reportId, reportRoles){
        var me = this;
        
        me.removeAll();
        me.reportId = reportId;
        me.add({
            xtype: 'roletypeselectiontree',
            canCreate: true,
            cascadeSelectionDown: true,
            defaultParentRoleType: 'report'
        });
        var roleTypesTree = me.down('roletypeselectiontree'),
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
                    roleTypesTree.setAvailableRoleTypes(availableRoleTypes);
                    roleTypesTree.setSelectedRoleTypes(reportRoles);
                    
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
