Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.ComponentPropertiesFormPanel", {
    extend: "Ext.form.Panel",
    alias: 'widget.knitkitcomponentpropertiesformpanel',
    title: 'Properties Edit',
    autoDestroy: true,
    tbar: [{
        xtype: 'button',
        itemId: 'componentPropertiessaveButton',
        text: 'Save',
        hidden: true,
        iconCls: 'icon-save',
        handler: function(btn) {
            var me = btn.up('knitkitcomponentpropertiesformpanel');

            me.saveFieldProperties(btn.up('form'));
        }
    }, {
        xtype: 'tbfill'
    }, {
        xtype: 'button',
        itemId: 'componentPropertiesAdvanceEdit',
        hidden: true,
        iconCls: 'icon-edit',
        iconAlign: 'right',
        text: 'Edit Advanced',
        handler: function(btn) {
            var me = btn.up('knitkitcomponentpropertiesformpanel');
            Ext.create('widget.componentpropertieseditwindow', {
                field: me.field,
                eastRegion: me,
                title: "Edit Advanced Properties (" + me.field.fieldLabel + ")"
            }).show();
        }
    }],
    autoScroll: true,
    boddyPadding: 10,
    style: {
        left: '10px'
    },
    defaults: {
        labelWidth: 100,
        width: 275
    }

});
