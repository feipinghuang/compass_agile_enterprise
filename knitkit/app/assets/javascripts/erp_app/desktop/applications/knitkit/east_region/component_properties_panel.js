Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.ComponentPropertiesFormPanel", {
    extend: "Ext.form.Panel",
    alias: 'widget.knitkitcomponentpropertiesformpanel',
    title: 'Properties Edit',
    autoDestroy: true,
    
    
    loadElementProperties: function(element) {
        var me = this;
        me.removeAll();
        
        me.add({
            xtype: 'form',
            autoScroll: true,
            boddyPadding: 10,
            style: {
                left: '10px'
            },
            defaults: {
                labelWidth: 75,
                width: 275
            },
            tbar: [{
                xtype: 'button',
                itemId: 'saveButton',
                text: 'Save',
                iconCls: 'icon-save'
            }],
            items: [{
                xtype: 'displayfield',
                fieldLabel: 'Element Type',
                value: element.tagName
            }, {
                xtype: 'textfield',
                fieldLabel: 'ID',
                value: element.ID
            }, {
                xtype: 'textfield',
                fieldLabel: 'Class',
                value: element.className
            }, {
                xtype: 'textfield',
                fieldLabel: 'Style',
                value: element.style.cssTxt
            }, {
                xtype: 'textfield',
                fieldLabel: 'Height',
                value: element.style.height
            }, {
                xtype: 'textfield',
                fieldLabel: 'Width',
                value: element.style.width
            }, {
                xtype: 'textfield',
                fieldLabel: 'Text Align',
                value: element.style.textAlign
            }, {
                xtype: 'textfield',
                fieldLabel: 'Color',
                value: element.style.color

            }, {
                xtype: 'textfield',
                fieldLabel: 'Font Family',
                value: element.style.fontFamily
            }]
        });
    }
});
