Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.ComponentPropertiesFormPanel", {
    extend: "Ext.form.Panel",
    alias: 'widget.knitkitcomponentpropertiesformpanel',
    title: 'Properties Edit',
    autoDestroy: true,
    element: null,
    editableItems: [],
    tbar: [{
        xtype: 'button',
        itemId: 'componentPropertiesSaveButton',
        text: 'Save',
        hidden: true,
        iconCls: 'icon-save',
        handler: function(btn) {
            var me = btn.up('knitkitcomponentpropertiesformpanel');
            me.updateHtmlProperties(btn.up('form'));
        }
    }, {
        xtype: 'tbfill'
    }, {
        xtype: 'button',
        itemId: 'componentPropertiesResetButton',
        hidden: true,
        iconCls: 'icon-undo',
        iconAlign: 'right',
        text: 'Reset to original',
        handler: function(btn) {

        }
    }],
    autoScroll: true,
    boddyPadding: 10,
    style: {
        left: '10px'
    },
    defaults: {
        labelWidth: 80,
        width: 250
    },
    updateHtmlProperties: function(formPanel, params, successCallback) {
        var me = this;
        if (formPanel.isValid()) {
            values = formPanel.form.getValues();
            Ext.Array.each(me.editableItems, function(editableItem) {
                if (editableItem == 'content') {
                    me.element.innerHTML = values[editableItem];
                } else {
                    me.element.style[editableItem] = values[editableItem];
                }
            });
        }
    }

});
