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
                regex: /^(\d)+(px)$/,
                regexText: 'Invalid font size, Try something like 10px',
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
    },

    loadSelectedTextProperties: function(iframe) {
        var me = this;
        me.removeAll();

        var selection = iframe.contentWindow.getSelection();

        // find values for selection
        var color = null,
            backgroundColor = null,
            fontSize = null,
            fontFamily = null;
        
        if (selection.rangeCount > 0) {
            var range = selection.getRangeAt(0),
                startContainerStyle = range.startContainer.parentNode.style,
                endContainerStyle = range.endContainer.parentNode.style;

            // If the values are consistent through out the selection get them else get nothing
            function getSelectionProperty(propName) {
                return startContainerStyle[propName] == endContainerStyle[propName] ? startContainerStyle[propName] : null;
            }
            
            color = getSelectionProperty('color');
            backgroundColor = getSelectionProperty('backgroundColor');
            fontSize = getSelectionProperty('fontSize');
            fontFamily = getSelectionProperty('fontFamily');
        }
            
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
                        
                        // construct selected text style
                        var style = '';
                        for(var attr in properties) {
                            if(!Compass.ErpApp.Utility.isBlank(properties[attr]))
                                style += attr + ':' + properties[attr] + '; ';
                        }

                        var selection = iframe.contentWindow.getSelection();
                        
                        if (selection.rangeCount > 0) {

                            var range = selection.getRangeAt(0),
                                startContainer = range.startContainer,
                                startParent = startContainer.parentNode,
                                endContainer = range.endContainer,
                                endParent = endContainer.parentNode;


                            if (startContainer.nodeValue.trim() == endContainer.nodeValue.trim() &&
                                endContainer.nodeValue.trim() == range.toString() &&
                                startParent.isSameNode(endParent) &&
                                startParent.nodeName == 'SPAN') {
                                var existingStyle = startParent.style.cssText;
                                startParent.style.cssText = existingStyle + style;

                                me.cleanUpDuplicateStyles(startParent);
                                me.unwrapBlankStyledSpan(startParent);
                            } else {
                                // there is no direct way of inserting a span so the hack is insert an anchor tag
                                // wrap it the a span and then remove the anchor tag
                                var uniqueId = iframe.id + '-wrap-link';
                                iframe.contentDocument.execCommand('CreateLink', false, uniqueId);
                                var sel = $(iframe.contentDocument.body).find('.container > .row > .col-md-12').find('a[href="' + uniqueId + '"]');
                                sel.wrap('<span class="temp-internal-select" style="' + style +'"></span>');
                                sel.contents().unwrap();
                                $(iframe.contentDocument.body).find('.container > .row > .col-md-12').find(".temp-internal-select").each(function(){
                                    me.cleanUpDuplicateStyles($(this)[0]);
                                    $(this).removeAttr('class');
                                    me.unwrapBlankStyledSpan($(this)[0]);
                                });
                            }

                            
                            // close the toolbar
                            if (iframe.contentWindow.__pen__) iframe.contentWindow.__pen__._menu.style.display = 'none';

                            me.down('#applyStatus').setText('Applied Successfully')
                            me.down('#applyStatus').show();
                            setTimeout(function(){
                                me.down('#applyStatus').hide();
                                me.down('#applyStatus').setText('');
                            }, 3000)

                        }

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
                value: 'Selected Text'
            }, {
                xtype: 'compassaecolorpicker',
                fieldLabel: 'Color',
                name: 'color',
                value: color
            }, {
                xtype: 'compassaecolorpicker',
                fieldLabel: 'Background Color',
                name: 'background',
                value: backgroundColor
            }, {
                xtype: 'textfield',
                fieldLabel: 'Font Size',
                regex: /^(\d)+(px)$/,
                regexText: 'Invalid font size, Try something like 10px',
                name: 'font-size',
                value: fontSize
            }, {
                xtype: 'textfield',
                fieldLabel: 'Font Family',
                name: 'font-family',
                value: fontFamily
            }]
        });
    },

    cleanUpDuplicateStyles: function(node) {
        if (!node.style) return;
        Ext.each(node.style.cssText.split(';'), function(nodeStyle){
            if (!Compass.ErpApp.Utility.isBlank(nodeStyle)) {
                var styleFrags = nodeStyle.split(':');
                $(node).find('[style*=' + styleFrags[0] + ']').each(function(){
                    $(this).css(styleFrags[0].trim(), '');
                });

            }
        });
    },

    unwrapBlankStyledSpan: function(node) {
        $(node).find('[style=""]').each(function(){
            $(this).contents().unwrap();
        });
    }


});


