Compass.ErpApp.Widgets.ManageProfile = {
    template: new Ext.Template('<%= render_widget :manage_profile %>'),

    addManageProfile:function(){
        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror(Compass.ErpApp.Widgets.ManageProfile.template.apply());
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name:'Manage Profile',
    iconUrl:'/assets/icons/manage_profile/manage_profile_48x48.png',
    onClick:Compass.ErpApp.Widgets.ManageProfile.addManageProfile,
    about:'This widget allows users to manage their user information, password and contact information.'
});