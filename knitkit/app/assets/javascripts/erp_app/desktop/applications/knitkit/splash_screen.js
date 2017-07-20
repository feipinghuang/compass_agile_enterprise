Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.SplashScreen", {
    extend: "Ext.panel.Panel",
    alias: 'widget.knitkit_splash_screen',
    title: 'Startup',
    closable: true,
    items: [{
            html: "<div style='margin: 15px 50px 5px 50px;'><h2 style='margin: 3px 0 10px 0; color: #2fb3d4; text-align: center'>Website Builder Home</h2></div>"
        },

        {
            xtype: 'image',
            style: 'padding-left: 50%; margin-left: -258px;',
            src: '/assets/knitkit/splash/splash.png'
        },

        {
            html: "<div style='margin: 15px 50px 5px 50px;'><p style='margin: 0; color: #222; text-align: center; font-size: 16px; font-weight: 300;'>Click on the shortcuts below to get started.</p></div>"
        },

        {
            xtype: 'panel',
            layout: 'column',
            style: 'width: 480px; margin-top: 0px; padding-top: 5px; margin-left: auto; margin-right: auto;',
            items: [

                {
                    xtype: 'panel',
                    height: 140,
                    width: 150,
                    style: {
                        margin: '0px 0px 5px 10px;',
                        cursor: 'pointer'
                    },
                    bodyStyle: '',
                    border: false,
                    bodyBorder: false,
                    overCls: 'shortcut-hover',
                    items: [

                        {
                            xtype: 'image',
                            src: '/assets/knitkit/splash/images/add_website_105x105.png',
                            height: 115,
                            width: 115,
                            style: 'background-color: #fff; margin-left: 15px;',
                            listeners: {
                                render: function(component) {
                                    component.getEl().on('click', function(e) {

                                        Ext.create("Ext.window.Window", {
                                            modal: true,
                                            title: 'New Website',
                                            buttonAlign: 'center',
                                            width: 360,
                                            defaultFocus: 'name',
                                            items: Ext.create('widget.form', {
                                                labelWidth: 110,
                                                frame: false,
                                                bodyStyle: 'padding:5px 5px 0',
                                                url: '/knitkit/erp_app/desktop/site/new',
                                                defaults: {
                                                    width: 320
                                                },
                                                items: [{
                                                    xtype: 'textfield',
                                                    fieldLabel: 'Name *',
                                                    allowBlank: false,
                                                    name: 'name',
                                                    itemId: 'name'
                                                }, {
                                                    xtype: 'textfield',
                                                    fieldLabel: 'Host *',
                                                    allowBlank: false,
                                                    name: 'host'
                                                }, {
                                                    xtype: 'textfield',
                                                    fieldLabel: 'Title *',
                                                    allowBlank: false,
                                                    name: 'title'
                                                }, {
                                                    xtype: 'textfield',
                                                    fieldLabel: 'Sub Title',
                                                    allowBlank: true,
                                                    name: 'subtitle'
                                                }],
                                                listeners: {
                                                    'render': function(form) {
                                                        Ext.Ajax.request({
                                                            url: '/knitkit/erp_app/desktop/site/get_current_host',
                                                            success: function(response) {
                                                                var obj = Ext.decode(response.responseText);
                                                                if (obj.success) {
                                                                    form.down('[name=host]').setValue(obj.host);
                                                                }
                                                            }
                                                        });
                                                    }
                                                }
                                            }),
                                            buttons: [{
                                                text: 'Submit',
                                                listeners: {
                                                    'click': function(button) {
                                                        var knitkitModule = compassDesktop.getModule('knitkit-win'),
                                                            knitkitWindow = compassDesktop.desktop.getWindow('knitkit'),
                                                            window = button.findParentByType('window'),
                                                            formPanel = window.query('.form')[0];

                                                        formPanel.getForm().submit({
                                                            waitMsg: 'Please wait...',
                                                            success: function(form, action) {
                                                                var obj = Ext.decode(action.response.responseText);
                                                                if (obj.success) {
                                                                    var combo = knitkitWindow.down('websitescombo');
                                                                    combo.store.load({
                                                                        callback: function(records, operation, succes) {
                                                                            for (i = 0; i < records.length; i++) {
                                                                                if (records[i].data.id == obj.website.id) {
                                                                                    combo.select(records[i]);

                                                                                    knitkitModule.selectWebsite(records[i]);
                                                                                    window.close();

                                                                                    break;
                                                                                }
                                                                            }
                                                                        }
                                                                    });
                                                                }
                                                            },
                                                            failure: function(form, action) {
                                                                Ext.Msg.alert("Error", "Error creating website");
                                                            }
                                                        });
                                                    }
                                                }
                                            }, {
                                                text: 'Close',
                                                handler: function(btn) {
                                                    btn.up('window').close();
                                                }
                                            }]
                                        }).show();


                                    }, component);

                                    component.getEl().on('mouseover', function() {
                                        component.setSrc('/assets/knitkit/splash/images/add_website_105x105-active.png');
                                    });
                                    component.getEl().on('mouseout', function() {
                                        component.setSrc('/assets/knitkit/splash/images/add_website_105x105.png');
                                    });
                                }
                            }
                        }, {
                            html: "<p style='background-color: #fff; margin: 0px 0px 0px 0px; text-align: center'>Create a website</p>"
                        }
                    ]
                },

                {
                    xtype: 'panel',
                    height: 140,
                    width: 150,
                    style: {
                        margin: '0px 0px 5px 10px;',
                        cursor: 'pointer'
                    },
                    bodyStyle: '',
                    border: false,
                    bodyBorder: false,
                    overCls: 'shortcut-hover',
                    items: [

                        {
                            xtype: 'image',
                            src: '/assets/knitkit/splash/images/find_themes_105x105.png',
                            height: 115,
                            width: 115,
                            style: 'background-color: #fff; margin-left: 15px;',
                            listeners: {
                                render: function(component) {
                                    component.getEl().on('click', function(e) {

                                        var cr = this.findParentByType('knitkit_centerregion');
                                        cr.openIframeInTab('Themes and Widgets', 'https://themes.mycompassagile.com');


                                    }, component);

                                    component.getEl().on('mouseover', function() {
                                        component.setSrc('/assets/knitkit/splash/images/find_themes_105x105-active.png');
                                    });
                                    component.getEl().on('mouseout', function() {
                                        component.setSrc('/assets/knitkit/splash/images/find_themes_105x105.png');
                                    });
                                }
                            }
                        }, {
                            html: "<p style='background-color: #fff; margin: 0px 0px 0px 0px; text-align: center'>Find themes and assets</p>"
                        }
                    ]
                }, {
                    xtype: 'panel',
                    height: 140,
                    width: 150,
                    style: {
                        margin: '0px 0px 5px 10px;',
                        cursor: 'pointer'
                    },
                    bodyStyle: '',
                    border: false,
                    bodyBorder: false,
                    overCls: 'shortcut-hover',
                    items: [

                        {
                            xtype: 'image',
                            src: '/assets/knitkit/splash/images/learn_more_105x105.png',
                            height: 115,
                            width: 115,
                            style: 'background-color: #fff; margin-left: 15px;',
                            listeners: {
                                render: function(component) {
                                    component.getEl().on('click', function(e) {

                                        var cr = this.findParentByType('knitkit_centerregion');
                                        cr.openIframeInTab('Building Websites', 'https://docs.mycompassagile.com');

                                    }, component);

                                    component.getEl().on('mouseover', function() {
                                        component.setSrc('/assets/knitkit/splash/images/learn_more_105x105-active.png');
                                    });
                                    component.getEl().on('mouseout', function() {
                                        component.setSrc('/assets/knitkit/splash/images/learn_more_105x105.png');
                                    });
                                }
                            }
                        }, {
                            html: "<p style='background-color: #fff; margin: 0px 0px 0px 0px; text-align: center'>Learn more</p>"
                        }
                    ]
                }

            ]
        }
    ],
    constructor: function(config) {

        var self = this;

        config = Ext.apply({
            //placeholder
        }, config);

        self.callParent(config);
    }
});
