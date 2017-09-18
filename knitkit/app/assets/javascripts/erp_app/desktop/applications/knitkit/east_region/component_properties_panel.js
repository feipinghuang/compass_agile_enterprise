Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.ComponentPropertiesFormPanel", {
    extend: "Ext.form.Panel",
    alias: 'widget.knitkitcomponentpropertiesformpanel',
    title: 'Properties Edit',
    autoDestroy: true,

    buildElementCommonPropertiesConfig: function(element, iframe) {
        return [{
            xtype: 'displayfield',
            fieldLabel: 'Element Type',
            value: element.tagName
        }, {
            xtype: 'textfield',
            fieldLabel: 'ID',
            emptyText: 'None',
            name: 'id',
            value: element.id
        }, {
            xtype: 'textfield',
            fieldLabel: 'Class',
            emptyText: 'None',
            name: 'className',
            value: element.className.match(iframe.id + '-enclose') ? element.className.replace(iframe.id + '-enclose', '') : element.className
        }];
    },

    loadElementProperties: function(element, iframe) {
        var me = this;
        var items = me.buildElementCommonPropertiesConfig(element, iframe);
        if (element.tagName == 'IMG') {
            items = items.concat([{
                xtype: 'textfield',
                fieldLabel: 'Height',
                name: 'height',
                regex: /^(\d)+$/,
                regexText: 'Invalid height',
                value: element.height
            }, {
                xtype: 'textfield',
                fieldLabel: 'Width',
                name: 'width',
                regex: /^(\d)+$/,
                regexText: 'Invalid width',
                value: element.width,
            }, {
                xtype: 'textfield',
                fieldLabel: 'Source',
                name: 'src',
                value: element.src,
            }, {
                xtype: 'textfield',
                fieldLabel: 'Alt',
                name: 'alt',
                value: element.alt
            }, {
                xtype: 'combo',
                name: 'align',
                fieldLabel: 'Align',
                displayField: 'alignment',
                valueField: 'name',
                store: {
                    fields: ['alignment', 'name'],
                    data:[
                        {'alignment': 'Top', name: 'top'},
                        {'alignment': 'Bottom', name: 'bottom'},
                        {'alignment': 'Middle', name: 'middle'},
                        {'alignment': 'Left', name: 'left'},
                        {'alignment': 'Right', name: 'right'}
                    ]
                },
                value: element.align
            }])
        } else {
            items = items.concat([{
                xtype: 'textfield',
                fieldLabel: 'Height',
                name: 'height',
                regex: /^(\d)+(px)$/,
                regexText: 'Invalid height, Try something like 10px',
                value: element.style.height
            }, {
                xtype: 'textfield',
                fieldLabel: 'Width',
                name: 'width',
                regex: /^(\d)+(px)$/,
                regexText: 'Invalid width. Try something like 10px',
                value: element.style.width,
            }, {
                xtype: 'compassaecolorpicker',
                fieldLabel: 'Color',
                name: 'color',
                value: element.style.color
            }, {
                xtype: 'compassaecolorpicker',
                fieldLabel: 'Background Color',
                name: 'backgroundColor',
                value: element.style.backgroundColor
            }, {
                xtype: 'textfield',
                fieldLabel: 'Font Size',
                name: 'fontSize',
                value: element.style.fontSize
            }, {
                xtype: 'textfield',
                fieldLabel: 'Font Family',
                name: 'fontFamily',
                value: element.style.fontFamily
            }]);
        }

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
                emptyText: 'Not Set'
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
                                if (element.tagName == 'IMG')
                                    element[attr] = properties[attr];
                                else
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
            items: items 
        });
    }
});
