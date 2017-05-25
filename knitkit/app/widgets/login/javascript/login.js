Compass.ErpApp.Widgets.Login = {
    buildLoginHeaderTemplate: function(websiteBuilder) {
        return Compass.ErpApp.Shared.Helpers.WidgetStatementBuilder.buildTemplate({
            widgetName: 'login',
            websiteBuilder: websiteBuilder,
            action: 'login_header',
            paramsArray: [
                {
                    key: 'login_url',
                    value: 'loginWidgetLoginUrl',
                    isVariable: true
                },
                {
                    key: 'signup_url',
                    value: 'loginWidgetSignUpUrl',
                    isVariable: true
                }
            ]
            
        });
    },
    buildLoginPageTemplate: function(websiteBuilder) {
        return Compass.ErpApp.Shared.Helpers.WidgetStatementBuilder.buildTemplate({
            widgetName: 'login',
            websiteBuilder: websiteBuilder,
            paramsArray: [
                {
                    key: 'login_to',
                    value: 'loginWidgetLoginTo',
                    isVariable: true
                },
                {
                    key: 'logout_to',
                    value: 'loginWidgetLogoutTo',
                    isVariable: true
                },
                {
                    key: 'signup_url',
                    value: 'loginWidgetSignUpUrl',
                    comment: 'optional field if Sign Up widget is setup',
                    commented: true,
                    isVariable: true
                },
                {
                    key: 'reset_password',
                    value: 'loginWidgetResetPasswordUrl',
                    commment: 'optional field if Reset Password widget is setup',
                    commented: true,
                    isVariable: true
                }
            ]
        });
    },
    addWidget: function (options) {
        var self = this;
        var success = options.success,
            websiteBuilder = options.websiteBuilder;
        var addLoginWidgetWindow = Ext.create("Ext.window.Window", {
            layout: 'fit',
            width: 375,
            title: 'Add Login Widget',
            plain: true,
            buttonAlign: 'center',
            items: Ext.create("Ext.form.Panel", {
                labelWidth: 100,
                frame: false,
                bodyStyle: 'padding:5px 5px 0',
                defaults: {
                    width: 225
                },
                items: [
                    {
                        xtype: 'combo',
                        forceSelection: true,
                        store: [
                            [':login_header', 'Header'],
                            [':login_page', 'Page']
                        ],
                        fieldLabel: 'Widget View',
                        value: ':login_page',
                        name: 'widgetLayout',
                        allowBlank: false,
                        triggerAction: 'all',
                        listeners: {
                            change: function (field, newValue, oldValue) {
                                var basicForm = field.findParentByType('form').getForm();
                                var loginWidgetLoginToField = basicForm.findField('loginWidgetLoginTo');
                                var loginWidgetLogoutToField = basicForm.findField('loginWidgetLogoutTo');
                                var loginWidgetLoginUrlField = basicForm.findField('loginWidgetLoginUrl');
                                var loginWidgetSignUpUrlField = basicForm.findField('loginWidgetSignUpUrl');
                                var loginWidgetResetPasswordUrlField = basicForm.findField('loginWidgetResetPasswordUrl');
                                if (newValue == ':login_header') {
                                    loginWidgetLoginToField.hide();
                                    loginWidgetLogoutToField.hide();
                                    loginWidgetLoginUrlField.show();
                                    loginWidgetResetPasswordUrlField.hide();
                                    loginWidgetLoginUrlField.setValue('/login');
                                    loginWidgetSignUpUrlField.setValue('/sign-up');
                                    loginWidgetResetPasswordUrlField.setValue('/reset-password');
                                }
                                else {
                                    loginWidgetLoginToField.show();
                                    loginWidgetLogoutToField.show();
                                    loginWidgetLoginUrlField.hide();
                                    loginWidgetResetPasswordUrlField.show();
                                    loginWidgetLoginToField.setValue('/home');
                                    loginWidgetLogoutToField.setValue('/home');
                                    loginWidgetSignUpUrlField.setValue('/sign-up');
                                }
                            }
                        }
                    },
                    {
                        xtype: 'textfield',
                        fieldLabel: 'Login To',
                        allowBlank: false,
                        value: '/home',
                        id: 'loginWidgetLoginTo'
                    },
                    {
                        xtype: 'textfield',
                        fieldLabel: 'Logout To',
                        allowBlank: false,
                        value: '/home',
                        id: 'loginWidgetLogoutTo'
                    },
                    {
                        xtype: 'textfield',
                        fieldLabel: 'Login Url',
                        allowBlank: false,
                        hidden: true,
                        value: '/login',
                        id: 'loginWidgetLoginUrl'
                    },
                    {
                        xtype: 'textfield',
                        toolTip: 'Only needed if Signup widget is setup.',
                        fieldLabel: 'Sign Up Url',
                        allowBlank: true,
                        value: '/sign-up',
                        id: 'loginWidgetSignUpUrl'
                    },
                    {
                        xtype: 'textfield',
                        toolTip: 'Only needed if Reset Password widget is setup.',
                        fieldLabel: 'Reset Password Url',
                        allowBlank: true,
                        hidden: true,
                        value: '/reset-password',
                        id: 'loginWidgetResetPasswordUrl'
                    }
                ]
            }),
            buttons: [
                {
                    text: 'Submit',
                    listeners: {
                        'click': function (button) {
                            var content = null;
                            var window = button.findParentByType('window');
                            var formPanel = window.query('form')[0];
                            var basicForm = formPanel.getForm();
                            var action = basicForm.findField('widgetLayout').getValue();

                            var loginWidgetSignUpUrlField = basicForm.findField('loginWidgetSignUpUrl');
                            var loginWidgetResetPasswordUrlField = basicForm.findField('loginWidgetResetPasswordUrl');
                            var data = {
                                action: action,
                            };
                            data.loginWidgetSignUpUrl = loginWidgetSignUpUrlField.getValue();
                            data.loginWidgetResetPasswordUrl = loginWidgetResetPasswordUrlField.getValue();
                            if (action == ':login_header') {
                                var loginWidgetLoginUrlField = basicForm.findField('loginWidgetLoginUrl');
                                data.loginWidgetLoginUrl = loginWidgetLoginUrlField.getValue();
                                content = Compass.ErpApp.Widgets.Login.buildLoginHeaderTemplate(websiteBuilder).apply(data);
                            }
                            else {
                                var loginWidgetLoginToField = basicForm.findField('loginWidgetLoginTo');
                                var loginWidgetLogoutToField = basicForm.findField('loginWidgetLogoutTo');
                                data.loginWidgetLoginTo = loginWidgetLoginToField.getValue();
                                data.loginWidgetLogoutTo = loginWidgetLogoutToField.getValue();
                                content = Compass.ErpApp.Widgets.Login.buildLoginPageTemplate(websiteBuilder).apply(data);
                            }

                            addLoginWidgetWindow.close();

                            // execute success passing in content
                            if(success) {
                                success(content);
                            }
                            
                        }
                    }
                },
                {
                    text: 'Close',
                    handler: function () {
                        addLoginWidgetWindow.close();
                    }
                }
            ]
        });
        addLoginWidgetWindow.show();
    }
};

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name: 'Login',
    iconUrl: '/assets/icons/login/login_48x48.png',
    addWidget: Compass.ErpApp.Widgets.Login.addWidget,
    about: 'This widget creates a login form to allow users to log into the website.'
});


