Ext.define("CompassAE.ErpApp.Shared.Party.LoginInfoPanel", {
    extend: 'Ext.form.Panel',
    alias: 'widget.partylogininfopanel',

    layout: 'hbox',
    title: 'Login Info',
    autoScroll: true,
    fieldSetHeights: 375,

    userId: null,
    loginPath: null,
    websiteId: null,
    partyId: null,
    user: null,
    showStatus: true,

    dockedItems: {
        xtype: 'toolbar',
        docked: 'top',
        items: [{
            text: 'Save',
            iconCls: 'icon-save',
            handler: function(btn) {
                btn.up('form').save(btn);
            }
        }]
    },

    initComponent: function() {
        var me = this;

        me.addEvents(
            /*
             * @event userinformationloaded
             * Fires when user information is loaded
             * @param {CompassAE.ErpApp.Shared.Party.LoginInfoPanel} this panel
             * @param {Object} User information
             */
            'userinformationloaded',

            /*
             * @event userinformationsaved
             * Fires when user information is saved
             * @param {CompassAE.ErpApp.Shared.Party.LoginInfoPanel} this panel
             * @param {Object} User information
             */
            'userinformationsaved'
        );

        me.on('afterrender', function() {
            if (me.user || me.userId) {
                me.load();
            } else {
                me.setupForNewUser();
            }
        });

        me.on('activate', function() {
            if (me.user) {
                me.setFields();
            } else if (me.userId) {
                me.load();
            } else {
                me.setupForNewUser();
            }
        });

        me.items = [{
            xtype: 'fieldset',
            height: me.fieldSetHeights,
            width: 450,
            bodyPadding: '5px',
            style: {
                marginLeft: '10px',
                marginRight: '10px',
                padding: '5px'
            },
            defaults: {
                width: 400
            },
            itemId: 'loginInfoFieldSet',
            items: [{
                width: 250,
                xtype: 'imageuploadfield',
                itemId: 'profileImage',
                title: 'Profile Image',
                buttonText: 'Choose image',
                spriteMode: false,
                allowBlank: true,
                imageWidth: 100,
                imageHeight: 100,
                submit: false,
                name: 'profile_image',
                previewImageSrc: '/assets/default-profile.png'
            }, {
                xtype: 'textfield',
                fieldLabel: 'Username',
                name: 'username',
                allowBlank: false,
                itemId: 'username'
            }, {
                xtype: 'textfield',
                vtype: 'email',
                fieldLabel: 'Email',
                allowBlank: false,
                name: 'email',
                itemId: 'email'
            }, {
                xtype: 'textfield',
                fieldLabel: 'Password',
                itemId: 'password',
                name: 'password',
                inputType: 'password'
            }, {
                xtype: 'textfield',
                fieldLabel: 'Password Confirmation',
                itemId: 'passwordConfirmation',
                name: 'password_confirmation',
                inputType: 'password'
            }]
        }, {
            xtype: 'fieldset',
            height: me.fieldSetHeights,
            width: 450,
            style: {
                marginLeft: '10px',
                marginRight: '10px',
                padding: '5px'
            },
            defaults: {
                width: 400
            },
            itemId: 'activityFieldSet',
            items: [{
                xtype: 'displayfield',
                fieldLabel: 'Last Login',
                itemId: 'lastLogin'
            }, {
                xtype: 'displayfield',
                fieldLabel: 'Last Logout',
                itemId: 'lastLogout'
            }, {
                xtype: 'displayfield',
                fieldLabel: 'Last Activity',
                itemId: 'lastActivity'
            }, {
                xtype: 'displayfield',
                fieldLabel: '# Failed Logins',
                itemId: 'faildLogins'
            }]
        }];

        me.callParent(arguments);
    },

    setupForNewUser: function() {
        var me = this;

        me.down('#password').allowBlank = false;
        me.down('#passwordConfirmation').allowBlank = false;
        if (!me.down('#autoActivate')) {
            me.down('#loginInfoFieldSet').add({
                xtype: 'radiogroup',
                fieldLabel: 'Auto Activate?',
                labelWrap: true,
                itemId: 'autoActivate',
                columns: [75, 75],
                items: [{
                    boxLabel: 'Yes',
                    name: 'auto_activate',
                    inputValue: 'yes',
                    checked: true
                }, {
                    boxLabel: 'No',
                    name: 'auto_activate',
                    inputValue: 'no'
                }]
            });
        }
    },

    save: function(btn) {
        var me = this;

        if (me.isValid()) {
            btn.disable();

            me.submitWithImage({
                url: (me.user ? ('/api/v1/users/' + me.userId) : '/api/v1/users'),
                method: (me.user ? 'PUT' : 'POST'),
                params: {
                    login_url: me.loginPath,
                    party_id: me.partyId,
                    website_id: me.websiteId
                },
                waitMsg: 'Please Wait',
                success: function(response) {
                    if (response.success) {
                        me.user = response.user;
                        me.setFields();
                        btn.enable();

                        me.fireEvent('userinformationsaved', me, me.user);
                    } else {
                        if (response && response.message) {
                            Ext.Msg.error('Error', response.message);
                        } else {
                            Ext.Msg.error('Error', 'Could not update user');
                        }
                    }
                },
                failure: function(response) {
                    if (response && response.message) {
                        Ext.Msg.error('Error', response.message);
                    } else {
                        Ext.Msg.error('Error', 'Could not update user');
                    }

                    btn.enable();
                }
            });
        }
    },

    load: function() {
        var me = this;

        var mask = new Ext.LoadMask({
            msg: 'Please wait...',
            target: me
        });
        mask.show();

        Compass.ErpApp.Utility.ajaxRequest({
            url: '/api/v1/users/' + (me.userId || me.user.id),
            method: 'GET',
            errorMessage: 'Could not load Login Info',
            success: function(response) {
                if (response.user) {
                    me.user = response.user;
                    me.setFields();
                }

                me.fireEvent('userinformationloaded', me, me.user);

                mask.hide();
            },
            failure: function() {
                mask.hide();
            }
        });
    },

    setFields: function(user) {
        var me = this;

        me.down('#username').setValue(me.user.username);
        me.down('#email').setValue(me.user.email);
        me.down('#password').reset();
        me.down('#passwordConfirmation').reset();
        me.down('#faildLogins').setValue((me.user.failed_login_count || 0));

        if (me.down('#autoActivate')) {
            me.down('#autoActivate').destroy();
        }

        // add Status
        if (!me.down('#status') && me.showStatus) {
            me.down('#loginInfoFieldSet').insert(1, {
                xtype: 'radiogroup',
                fieldLabel: 'Status',
                labelWrap: true,
                itemId: 'status',
                columns: 3,
                items: [{
                    boxLabel: 'Active',
                    name: 'status',
                    inputValue: 'active',
                    checked: (me.user.activation_state == 'active')
                }, {
                    boxLabel: 'Pending',
                    name: 'status',
                    inputValue: 'pending',
                    checked: (me.user.activation_state == 'pending')
                }, {
                    boxLabel: 'Inactive',
                    name: 'status',
                    inputValue: 'inactive',
                    checked: (me.user.activation_state == 'inactive')
                }]
            });
        }

        if (me.user.profile_image_url) {
            me.down('#profileImage').setValue(me.user.profile_image_url);
        }

        if (me.user.last_login_at) {
            me.down('#lastLogin').setValue(Ext.util.Format.date(me.user.last_login_at, 'F j, Y, g:i a'));
        } else {
            me.down('#lastLogin').setValue('Has not logged in');
        }

        if (me.user.last_login_at) {
            me.down('#lastLogin').setValue(Ext.util.Format.date(me.user.last_login_at, 'F j, Y, g:i a'));
        } else {
            me.down('#lastLogin').setValue('Has not logged in');
        }

        if (me.user.last_logout_at) {
            me.down('#lastLogout').setValue(Ext.util.Format.date(me.user.last_logout_at, 'F j, Y, g:i a'));
        } else {
            me.down('#lastLogout').setValue('Has not logged out');
        }

        if (me.user.last_activity_at) {
            me.down('#lastActivity').setValue(Ext.util.Format.date(me.user.last_activity_at, 'F j, Y, g:i a'));
        } else {
            me.down('#lastActivity').setValue('Has not had activity');
        }
    }
});