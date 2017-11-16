Ext.define("Compass.ErpApp.Desktop.Applications.RailsDbAdmin.SplashScreen", {
    title: 'Startup',
    extend: "Ext.panel.Panel",
    alias: 'widget.railsdbadmin_splash_screen',
    bodyStyle: 'background-color: #f2f6fa;',
    autoScroll: true,
    items: [
        {
            html: "<div style='background-color: #f2f6fa; padding: 15px 50px 5px 50px;'><h2 style='margin: 3px 0px 0px 0px; color: #2fb3d4; text-align: center'>CompassAE Database Navigator</h2></div>"
        },
        {
            xtype: 'image',
            style: 'background-color: #f2f6fa; padding-left: 50%; margin-top: 20px; margin-left: -150px;',
            src: '/assets/splash/db_admin_splash.png'
        },
        {
            html: "<div style='background-color: #f2f6fa; padding: 15px 50px 5px 35px;'><p style='margin: 0px 0px 10px 5px; color: #222; text-align: center; font-size: 16px; font-weight: 300;'>Click on the shortcuts below to get started.</p></div>"
        },
        {
            xtype: 'panel',
            layout: 'column',
            style: 'background-color: #f2f6fa; width: 450px; margin-top: 0px; margin-left: auto; margin-right: auto;',
            items: [

                {
                    xtype: 'panel',
                    height: 140,
                    width: 150,
                    style:{
                        margin: '',
                        cursor: 'pointer'
                    },
                    bodyStyle: 'background-color: #f2f6fa;',
                    border: false,
                    bodyBorder: false,
                    overCls: 'shortcut-hover',
                    items: [
                        {
                            xtype: 'image',
                            src: '/assets/splash/icons/console_icon.png',
                            height: 115,
                            width: 115,
                            style: 'background-color: #f2f6fa; margin-left: 15px;',
                            listeners: {
                                render: function (component) {
                                    component.getEl().on('click', function (e) {

                                        var module = compassDesktop.getModule('rails_db_admin-win');
                                        module.addConsolePanel();

                                    }, component);

                                    component.getEl().on('mouseover', function () {
                                            component.setSrc('/assets/splash/icons/console_icon_active.png');
                                        }
                                    );
                                    component.getEl().on('mouseout', function () {
                                            component.setSrc('/assets/splash/icons/console_icon.png');
                                        }
                                    );
                                }
                            }
                        },
                        {
                            html: "<p style='background-color: #f2f6fa; margin: 0px; text-align: center'>Open a console</p>"
                        }
                    ]
                },

                {
                    xtype: 'panel',
                    height: 140,
                    width: 150,
                    style:{
                        margin: '',
                        cursor: 'pointer'
                    },
                    bodyStyle: 'background-color: #f2f6fa;',
                    border: false,
                    bodyBorder: false,
                    overCls: 'shortcut-hover',
                    items: [
                        {
                            xtype: 'image',
                            src: '/assets/splash/icons/db_icon.png',
                            height: 115,
                            width: 115,
                            style: 'background-color: #f2f6fa; margin-left: 15px;',
                            listeners: {
                                render: function (component) {
                                    component.getEl().on('click', function (e) {

                                        var module = compassDesktop.getModule('rails_db_admin-win');
                                        module.openIframeInTab('CompassAE Documentation - Data Models', 'https://docs.mycompassagile.com');

                                    }, component);

                                    component.getEl().on('mouseover', function () {
                                            component.setSrc('/assets/splash/icons/db_icon_active.png');
                                        }
                                    );
                                    component.getEl().on('mouseout', function () {
                                            component.setSrc('/assets/splash/icons/db_icon.png');
                                        }
                                    );
                                }
                            }
                        },
                        {
                            html: "<p style='background-color: #f2f6fa; margin: 0px; text-align: center'>Browse the DB</p>"
                        }
                    ]
                },
                {
                    xtype: 'panel',
                    height: 140,
                    width: 150,
                    style:{
                        margin: '',
                        cursor: 'pointer'
                    },
                    bodyStyle: 'background-color: #f2f6fa;',
                    border: false,
                    bodyBorder: false,
                    overCls: 'shortcut-hover',
                    items: [
                        {
                            xtype: 'image',
                            src: '/assets/splash/icons/help_icon.png',
                            height: 115,
                            width: 115,
                            style: 'background-color: #f2f6fa; margin-left: 15px;',
                            listeners: {
                                render: function (component) {
                                    component.getEl().on('click', function (e) {

                                        var module = compassDesktop.getModule('rails_db_admin-win');
                                        module.openIframeInTab('CompassAE Documentation - Data Models', 'https://docs.mycompassagile.com');

                                    }, component);

                                    component.getEl().on('mouseover', function () {
                                            component.setSrc('/assets/splash/icons/help_icon_active.png');
                                        }
                                    );
                                    component.getEl().on('mouseout', function () {
                                            component.setSrc('/assets/splash/icons/help_icon.png');
                                        }
                                    );

                                }
                            }
                        },
                        {
                            html: "<p style='background-color: #f2f6fa; margin: 0px; text-align: center'>Learn more</p>"
                        }
                    ]
                }
            ]
        }
    ]

});