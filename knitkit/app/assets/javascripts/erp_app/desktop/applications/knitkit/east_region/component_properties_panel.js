Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.ComponentPropertiesFormPanel", {
    extend: "Ext.form.Panel",
    alias: 'widget.knitkitcomponentpropertiesformpanel',
    title: 'Properties Edit',
    autoDestroy: true,
    
    
    loadElementProperties: function(element, iframe) {
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
                width: 250,
                emptyText: 'none'
            },
            tbar: [{
                xtype: 'button',
                itemId: 'saveButton',
                text: 'Apply',
                iconCls: 'icon-save',
                handler: function(btn) {
                    var formPanel = btn.up('form');

                    if (formPanel.isValid()) {
                        var properties = formPanel.getValues();

                        if (iframe.contentDocument.getElementById(properties.id)) {
                            Ext.Msg.alert('Error', 'There is an element with this ID');
                            return;
                        }
                        
                        for(var attr in properties) {
                            if (attr == 'id') {
                                element.id = id
                            } else if (attr == 'className') {
                                element.className = className;
                            } else {
                                element.style[attr] = properties[attr];
                            }
                        }
                        
                        if (iframeWindow.__pen__) iframe.contentWindow__pen__._menu.style.display = 'none';
                        

                    }
                }
            }],
            items: [{
                xtype: 'displayfield',
                fieldLabel: 'Element Type',
                value: element.tagName
            }, {
                xtype: 'textfield',
                fieldLabel: 'ID',
                name: 'id',
                value: element.id
            }, {
                xtype: 'textfield',
                fieldLabel: 'Class',
                name: 'className',
                value: element.className
            }, {
                xtype: 'textfield',
                fieldLabel: 'Height',
                name: 'height',
                emptyText: '10px',
                regex: /^(\d)+(px)$/,
                regexText: 'Invalid height',
                value: element.offsetHeight + 'px'
            }, {
                xtype: 'textfield',
                fieldLabel: 'Width',
                name: 'width',
                emptyText: '10px',
                regex: /^(\d)+(px)$/,
                regexText: 'Invalid width',
                value: element.offsetWidth + 'px'
            }, {
                xtype: 'textfield',
                fieldLabel: 'Color',
                name: 'color',
                value: element.style.color
            },{
                xtype: 'textfield',
                fieldLabel: 'Background Color',
                name: 'backgroundColor',
                value: element.style.backgroundColor

            }, {
                xtype: 'textfield',
                fieldLabel: 'Font Family',
                name: 'fontFamily',
                value: element.style.fontFamily
            }]
        });
    }
});
