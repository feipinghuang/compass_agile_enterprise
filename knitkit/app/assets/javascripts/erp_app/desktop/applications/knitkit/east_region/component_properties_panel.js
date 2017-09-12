Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.ComponentPropertiesFormPanel", {
    extend: "Ext.form.Panel",
    alias: 'widget.knitkitcomponentpropertiesformpanel',
    title: 'Properties Edit',
    autoDestroy: true,
    
    
    loadElementProperties: function(element, iframe) {
        var me = this,
            win = iframe.contentWindow,
            elemComputedStyles = win.getComputedStyle(element, null);
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

                        for(var attr in properties) {
                            
                            if (attr == 'id') {
                                element.id = properties.id
                            } else if (attr == 'className') {
                                element.className = properties.className;
                            } else {
                                element.style[attr] = properties[attr];
                            }
                        }
                        // close the toolbar
                        if (iframe.contentWindow.__pen__) iframe.contentWindow.__pen__._menu.style.display = 'none';

                        buttonConfig = this
                        me.down('#applyStatus').setText('Applied Successfully')
                        me.down('#applyStatus').show();
                        setTimeout(function(){
                            me.down('#applyStatus').hide();
                            me.down('#applyStatus').setText('');
                        }, 3000)

                    }
                }
            },{
                xtype: 'label',
                itemId: 'applyStatus',
                hidden: true,
                style: {
                    color: 'green'
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
                value: element.className.match(iframe.id + '-enclose') ? element.className.replace(iframe.id + '-enclose', '') : element.className
            }, {
                xtype: 'textfield',
                fieldLabel: 'Height',
                name: 'height',
                emptyText: elemComputedStyles.height,
                regex: /^(\d)+(px)$/,
                regexText: 'Invalid height',
                value: element.style.height
            }, {
                xtype: 'textfield',
                fieldLabel: 'Width',
                name: 'width',
                emptyText: elemComputedStyles.width,
                regex: /^(\d)+(px)$/,
                regexText: 'Invalid width',
                value: element.style.width
            }, {
                xtype: 'textfield',
                fieldLabel: 'Color',
                name: 'color',
                emptyText: Compass.ErpApp.Utility.rgbToHex(elemComputedStyles.color),
                value: element.style.color
            },{
                xtype: 'textfield',
                fieldLabel: 'Background Color',
                name: 'backgroundColor',
                emptyText: Compass.ErpApp.Utility.rgbToHex(elemComputedStyles.backgroundColor),
                value: element.style.backgroundColor

            }, {
                xtype: 'textfield',
                fieldLabel: 'Font Size',
                name: 'fontSize',
                emptyText: elemComputedStyles.fontSize,
                value: element.style.fontSize
            }, {
                xtype: 'textfield',
                fieldLabel: 'Font Family',
                name: 'fontFamily',
                emptyText: elemComputedStyles.fontFamily,
                value: element.style.fontFamily
            }]
        });
    }
});
