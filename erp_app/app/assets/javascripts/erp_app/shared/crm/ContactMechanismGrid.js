var statesStore = Ext.create('Ext.data.Store', {
    autoLoad: true,
    proxy: {
        type: 'ajax',
        url: '/erp_app/organizer/crm/contact_mechanisms/states',
        reader: {
            type: 'json',
            root: 'states'
        }
    },
    fields: [
        {
            name: 'state'
        },
        {
            name: 'geo_zone_code'
        }
    ]
});

Ext.define("Compass.ErpApp.Shared.Crm.ContactMechanismGrid", {
    extend: "Ext.grid.Panel",
    alias: 'widget.contactmechanismgrid',
    cls: 'contactmechanismgrid',
    border: false,
    frame: false,
    header: false,

    /**
     * @cfg {Array} contactPurposes
     * Array of contactPurposes that can be added to a contact.
     *
     * @example
     * {
     *   fieldLabel: 'Default',
     *   internalIdentifier: 'default'
     * }
     */
    contactPurposes: [
        {
            fieldLabel: 'Default',
            internalIdentifier: 'default'
        }
    ],

    /**
     * @cfg {String} contactPurposesTitle
     * Title of contact purposes fieldset.
     */
    contactPurposesTitle: 'Contact Purpose',

    initComponent: function () {
        var me = this,
            config = me.initialConfig;

        me.addEvents(
            /*
             * @event contactcreated
             * Fires when a contact is created
             * @param {Compass.ErpApp.Shared.Crm.ContactMechanismGrid} this
             * @param {String} ContactType {PhoneNumber, PostalAddress, EmailAddress}
             * @param {Record} record
             */
            'contactcreated',
            /*
             * @event contactupdated
             * Fires when a contact is updated
             * @param {Compass.ErpApp.Shared.Crm.ContactMechanismGrid} this
             * @param {String} ContactType {PhoneNumber, PostalAddress, EmailAddress}
             * @param {Record} record
             */
            'contactupdated',
            /*
             * @event contactdestroyed
             * Fires when a contact is destroyed
             * @param {Compass.ErpApp.Shared.Crm.ContactMechanismGrid} this
             * @param {String} ContactType {PhoneNumber, PostalAddress, EmailAddress}
             * @param {Record} record
             */
            'contactdestroyed'
        );

        var store = Ext.create('Ext.data.Store', {
            fields: config['fields'],
            autoLoad: false,
            autoSync: true,
            proxy: {
                type: 'ajax',
                url: '/erp_app/organizer/crm/contact_mechanisms',
                extraParams: {
                    party_id: config['partyId'],
                    contact_type: config['contactMechanism']
                },
                reader: {
                    type: 'json',
                    successProperty: 'success',
                    idProperty: 'id',
                    root: 'data',
                    totalProperty: 'totalCount',
                    messageProperty: 'message'
                }
            },
            remoteSort: true
        });

        this.store = store;

        this.bbar = Ext.create("Ext.PagingToolbar", {
            pageSize: 30,
            store: store,
            displayInfo: true,
            displayMsg: 'Displaying {0} - {1} of {2}',
            emptyMsg: "No " + config.title
        });

        this.callParent(arguments);
    },

    constructor: function (config) {
        var me = this;

        if (config.columns === undefined) {
            config.columns = [];
        }

        config.columns = config.columns.concat([
            {
                header: 'Contact Purposes',
                dataIndex: 'contact_purposes',
                flex: 1,
                sortable: false
            },
            {
                header: 'Created',
                dataIndex: 'created_at',
                renderer: Ext.util.Format.dateRenderer('m/d/Y g:i a'),
                flex: 1
            },
            {
                header: 'Last Update',
                dataIndex: 'updated_at',
                renderer: Ext.util.Format.dateRenderer('m/d/Y g:i a'),
                flex: 1
            }
        ]);

        config.columns.unshift({
            header: 'Description',
            dataIndex: 'description',
            width: 200,
            editor: {
                xtype: 'textfield'
            }
        });

        config.columns.unshift({
            header: 'Primary',
            sortable: false,
            flex: 0.5,
            dataIndex: 'is_primary',
            renderer: function (v) {
                if (v) {
                    return 'Yes';
                }
                else {
                    return 'No';
                }
            },
            width: 200,
            editor: {
                xtype: 'checkbox'
            }
        });

        config.fields = config.dataFields.concat([
            'contact_purpose_iids',
            'contact_purposes',
            'created_at' ,
            'updated_at',
            'id',
            {
                name: 'is_primary',
                type: 'boolean'
            },
            'description'
        ]);

        var toolBarItems = [
            {
                text: 'Add',
                xtype: 'button',
                iconCls: 'icon-add',
                handler: function (button) {
                    var grid = button.up('grid'),
                        fields = config.formFields;

                    Ext.create('widget.window', {
                        closable: false,
                        modal: true,
                        buttonAlign: 'center',
                        title: config.addFormTitle,
                        layout: 'fit',
                        items: [
                            {
                                xtype: 'form',
                                url: '/erp_app/organizer/crm/contact_mechanisms',
                                bodyPadding: 5,
                                width: 250,
                                layout: 'anchor',
                                defaults: {
                                    anchor: '100%'
                                },
                                defaultType: 'textfield',
                                items: fields
                            }
                        ],
                        buttons: [
                            {
                                text: 'Add',
                                handler: function (btn) {
                                    var window = btn.up('window'),
                                        form = window.down('form');

                                    if (form.isValid()) {
                                        form.submit({
                                            waitMsg: 'Saving...',
                                            method: 'POST',
                                            params: {
                                                party_id: config['partyId'],
                                                contact_type: config['contactMechanism']
                                            },
                                            success: function (form, action) {
                                                if (action.result.success) {
                                                    window.close();

                                                    grid.getView().getSelectionModel().deselectAll();
                                                    grid.store.load();

                                                    grid.fireEvent('contactcreated', me, config['contactMechanism'], action.result.data);
                                                }
                                                else {
                                                    Ext.Msg.alert('Failed', action.result.msg);
                                                }
                                            },
                                            failure: function (form, action) {
                                                Ext.Msg.alert('Failed', action.result.msg);
                                            }
                                        })
                                    }
                                }
                            },
                            {
                                text: 'Cancel',
                                handler: function (btn) {
                                    btn.up('window').close();
                                }
                            }
                        ]
                    }).show();
                }
            },
            '-',
            {
                text: 'Edit',
                type: 'button',
                iconCls: 'icon-edit',
                handler: function (button) {
                    var grid = button.up('grid'),
                        selection = grid.getView().getSelectionModel().getSelection()[0];

                    if (selection) {
                        grid.editContact(selection);
                    }
                }
            },
            '-',
            {
                text: 'Delete',
                type: 'button',
                iconCls: 'icon-delete',
                handler: function (button) {
                    var grid = button.findParentByType('contactmechanismgrid');
                    var selection = grid.getView().getSelectionModel().getSelection()[0];
                    if (selection) {

                        Ext.MessageBox.confirm(
                            'Confirm', 'Are you sure?',
                            function (btn) {
                                if (btn == 'yes') {
                                    Ext.Ajax.request({
                                        url: '/erp_app/organizer/crm/contact_mechanisms/' + selection.get('id'),
                                        params: {
                                            party_id: config['partyId'],
                                            contact_type: config['contactMechanism']
                                        },
                                        method: 'DELETE',
                                        success: function (response) {
                                            responseObj = Ext.JSON.decode(response.responseText);

                                            if (responseObj.success) {
                                                grid.getView().getSelectionModel().deselectAll();
                                                grid.store.load();

                                                grid.fireEvent('contactdestroyed', me, config['contactMechanism'], selection);
                                            }
                                            else {
                                                Ext.Msg.alert('Failed', 'Could not remove');
                                            }

                                        },
                                        failure: function () {
                                            Ext.Msg.alert('Failed', 'Could not remove');
                                        }
                                    });
                                }
                            }
                        );
                    }
                }
            }
        ];

        if (!Ext.isEmpty(config.toolbarItems)) {
            toolBarItems = toolBarItems.concat(config.toolbarItems);
        }

        config.formFields.unshift({
            name: 'description',
            fieldLabel: 'Description'
        });

        config.formFields.unshift({
            name: 'is_primary',
            fieldLabel: 'Primary Contact',
            xtype: 'checkbox'
        });

        // setup contact purposes

        var contactPurposeCheckBoxes = [];
        Ext.each(config.contactPurposes, function (contactPurpose) {
            contactPurposeCheckBoxes.push({
                boxLabel: contactPurpose.fieldLabel,
                name: 'contact_purpose[]',
                inputValue: contactPurpose.internalIdentifier
            });
        });

        config.formFields.push({
            xtype: 'fieldset',
            title: config.contactPurposesTitle,
            items: [
                {
                    xtype: 'checkboxgroup',
                    itemId: 'contactPurposes',
                    columns: 2,
                    items: contactPurposeCheckBoxes
                }
            ]
        });

        config = Ext.apply({
            layout: 'fit',
            frame: false,
            region: 'center',
            loadMask: true,
            dockedItems: {
                xtype: 'toolbar',
                docked: 'top',
                items: toolBarItems
            }
        }, config);

        var listeners = {
            itemdblclick: function (grid, record, item, index) {
                grid.ownerCt.editContact(record);
            }
        };

        config['listeners'] = Ext.apply(listeners, config['listeners']);

        this.callParent([config]);
    },

    editContact: function (selection) {
        var grid = this,
            config = this.initialConfig,
            fields = config.formFields;

        Ext.create('widget.window', {
            closable: false,
            modal: true,
            buttonAlign: 'center',
            title: config.addFormTitle,
            layout: 'fit',
            items: [
                {
                    xtype: 'form',
                    bodyPadding: 5,
                    width: 250,
                    layout: 'anchor',
                    defaults: {
                        anchor: '100%'
                    },
                    defaultType: 'textfield',
                    items: fields
                }
            ],
            buttons: [
                {
                    text: 'Update',
                    handler: function (btn) {
                        var window = btn.up('window'),
                            form = window.down('form');

                        if (form.isValid()) {
                            form.submit({
                                url: '/erp_app/organizer/crm/contact_mechanisms/' + selection.get('id'),
                                waitMsg: 'Saving...',
                                method: 'PUT',
                                params: {
                                    party_id: config['partyId'],
                                    contact_type: config['contactMechanism']
                                },
                                success: function (form, action) {
                                    if (action.result.success) {
                                        window.close();

                                        grid.getView().getSelectionModel().deselectAll();
                                        grid.store.load();

                                        grid.fireEvent('contactupdated', grid, config['contactMechanism'], action.result.data);
                                    }
                                    else {
                                        Ext.Msg.alert('Failed', action.result.msg);
                                    }
                                },
                                failure: function (form, action) {
                                    Ext.Msg.alert('Failed', action.result.msg);
                                }
                            })
                        }
                    }
                },
                {
                    text: 'Cancel',
                    handler: function (btn) {
                        btn.up('window').close();
                    }
                }
            ],
            listeners: {
                show: function () {
                    var form = this.down('form');
                    form.getForm().setValues(selection.data);

                    // check contact purposes
                    Ext.each(selection.data.contact_purpose_iids.split(','), function (contactPurpose) {
                        var checkboxes = form.query('#contactPurposes checkbox');
                        for (i = 0; i < checkboxes.length; i++) {
                            var checkbox = checkboxes[i];
                            if (checkbox.initialConfig.inputValue == contactPurpose) {
                                checkbox.setValue(true);
                            }
                        }
                    });
                }
            }
        }).show();
    }
});

/**
 * PhoneNbrGrid
 * This grid extends the ContactMechanismGrid and sets it up with columns for
 * displaying phone numbers
 */
Ext.define("Compass.ErpApp.Shared.Crm.ContactMechanismGrid.PhoneNumberGrid", {
    extend: "Compass.ErpApp.Shared.Crm.ContactMechanismGrid",
    alias: 'widget.phonenumbergrid',

    constructor: function (config) {

        this.callParent([Ext.apply(config, {
            title: 'Phone Numbers',
            contactMechanism: 'PhoneNumber',
            columns: [
                {
                    header: 'Phone Number',
                    dataIndex: 'phone_number',
                    flex: 1,
                    width: 200
                }
            ],
            dataFields: [
                {
                    name: 'phone_number'
                }
            ],
            addFormTitle: 'Add Phone Number',
            editFormTitle: 'Edit Phone Number',
            formFields: [
                {
                    xtype: 'businessmodulephonenumberfield',
                    fieldLabel: 'Phone Number',
                    name: 'phone_number',
                    allowBlank: false
                }
            ]
        })]);
    }
});

/**
 * EmailAddrGrid
 * This grid extends ContactMechanismGrid and provides a column configuration for
 * displaying and editing email addresses for a given party
 */
Ext.define("Compass.ErpApp.Shared.Crm.ContactMechanismGrid.EmailAddressGrid", {
    extend: "Compass.ErpApp.Shared.Crm.ContactMechanismGrid",
    alias: 'widget.emailaddressgrid',

    constructor: function (config) {

        this.callParent([Ext.apply(config, {
            title: 'Email Addresses',
            contactMechanism: 'EmailAddress',
            columns: [
                {
                    header: 'Email Address',
                    dataIndex: 'email_address',
                    flex: 1,
                    editor: {
                        xtype: 'textfield'
                    },
                    width: 200
                }
            ],
            dataFields: [
                {
                    name: 'email_address'
                }
            ],
            toolbarItems: [
                '-',
                {
                    xtype: 'button',
                    text: 'Send Email',
                    iconCls: 'icon-mail',
                    handler: function (btn) {
                        var required = '<span style="color:red;font-weight:bold" data-qtip="Required">*</span>',
                            grid = btn.findParentByType('emailaddressgrid'),
                            selection = grid.getView().getSelectionModel().getSelection()[0],
                            sendEmailWindow = null;

                        if (selection) {
                            if (!sendEmailWindow) {
                                var form = Ext.widget('form', {
                                    layout: {
                                        type: 'vbox',
                                        align: 'stretch'
                                    },
                                    border: false,
                                    bodyPadding: 10,
                                    buttonAlign: 'center',
                                    fieldDefaults: {
                                        labelAlign: 'top',
                                        labelWidth: 100,
                                        labelStyle: 'font-weight:bold'
                                    },
                                    items: [
                                        {
                                            xtype: 'displayfield',
                                            fieldLabel: 'Send To',
                                            width: 300,
                                            value: selection.get('email_address')
                                        },
                                        {
                                            xtype: 'textfield',
                                            fieldLabel: 'CC',
                                            width: 300,
                                            vtype: 'email',
                                            name: 'cc_email'
                                        },
                                        {
                                            xtype: 'textfield',
                                            fieldLabel: 'Subject',
                                            name: 'subject',
                                            width: 300,
                                            afterLabelTextTpl: required,
                                            allowBlank: false
                                        },
                                        {
                                            xtype: 'htmleditor',
                                            name: 'message',
                                            fieldLabel: 'Message',
                                            height: 200,
                                            allowBlank: false
                                        }
                                    ],

                                    buttons: [
                                        {
                                            text: 'Send',
                                            handler: function (btn) {
                                                if (this.up('form').getForm().isValid()) {
                                                    this.up('form').getForm().submit({
                                                        waitMsg: 'sending email',
                                                        url: '/erp_app/organizer/crm/contact_mechanisms/' + selection.get('id') + '/send_email',
                                                        success: function (form, result) {
                                                            btn.up('form').getForm().reset();
                                                            btn.up('window').hide();
                                                            Ext.Msg.alert('Email Sent!', 'Your emails has been sent.');
                                                        },
                                                        failure: function (form, result) {
                                                            Ext.Msg.alert('Error', 'Could not send email.');
                                                        }
                                                    });


                                                }
                                            }
                                        },
                                        {
                                            text: 'Cancel',
                                            handler: function () {
                                                this.up('form').getForm().reset();
                                                this.up('window').hide();
                                            }
                                        }
                                    ]
                                });

                                sendEmailWindow = Ext.widget('window', {
                                    title: 'Send Email',
                                    closeAction: 'hide',
                                    layout: 'fit',
                                    resizable: true,
                                    modal: true,
                                    items: form,
                                    defaultFocus: 'firstName'
                                });
                            }
                            sendEmailWindow.show();
                        }
                    }
                }],
            addFormTitle: 'Add Email Address',
            editFormTitle: 'Edit Email Address',
            formFields: [
                {
                    fieldLabel: 'Email Address',
                    name: 'email_address',
                    vType: 'email',
                    allowBlank: false
                }
            ]
        })]);

    }
});

/**
 * PostalAddrGrid
 * This extends the ContactMechanismGrid and setups up configuration for
 * displaying and editing postal addresses for a given party
 */
Ext.define("Compass.ErpApp.Shared.Crm.ContactMechanismGrid.PostalAddressGrid", {
    extend: "Compass.ErpApp.Shared.Crm.ContactMechanismGrid",
    alias: 'widget.postaladdressgrid',

    constructor: function (config) {
        this.callParent([Ext.apply(config, {
            title: 'Postal Addresses',
            contactMechanism: 'PostalAddress',
            columns: [
                {
                    header: 'Address Line 1',
                    flex: 1,
                    dataIndex: 'address_line_1'
                },
                {
                    header: 'Address Line 2',
                    flex: 1,
                    dataIndex: 'address_line_2'
                },
                {
                    header: 'City',
                    flex: 1,
                    dataIndex: 'city'
                },
                {
                    header: 'State',
                    flex: 1,
                    dataIndex: 'state'
                },
                {
                    header: 'Zip',
                    flex: 0.5,
                    dataIndex: 'zip'
                },
                {
                    header: 'Country',
                    flex: 0.5,
                    dataIndex: 'country'
                }
            ],
            dataFields: [
                {
                    name: 'address_line_1'
                },
                {
                    name: 'address_line_2'
                },
                {
                    name: 'city'
                },
                {
                    name: 'state'
                },
                {
                    name: 'zip'
                },
                {
                    name: 'country'
                }

            ],
            toolbarItems: [
                '-',
                {
                    xtype: 'button',
                    text: 'Map It',
                    iconCls: 'icon-map',
                    handler: function (button) {
                        var grid = button.up('postaladdressgrid');
                        var selection = grid.getView().getSelectionModel().getSelection()[0];
                        if (selection) {
                            var addressLines;
                            if (Compass.ErpApp.Utility.isBlank(selection.get('address_line_2'))) {
                                addressLines = selection.get('address_line_1');
                            }
                            else {
                                addressLines = selection.get('address_line_1') + ' ,' + selection.get('address_line_2');
                            }

                            var fullAddress = addressLines + ' ,' + selection.get('city') + ' ,' + selection.get('state') + ' ,' + selection.get('zip') + ' ,' + selection.get('country');
                            var mapwin = Ext.create('Ext.Window', {
                                layout: 'fit',
                                title: addressLines,
                                width: 450,
                                height: 450,
                                border: false,
                                items: {
                                    xtype: 'googlemappanel',
                                    zoomLevel: 17,
                                    mapType: 'hybrid',
                                    dropPins: [
                                        {
                                            address: fullAddress,
                                            center: true,
                                            title: addressLines
                                        }
                                    ]
                                }
                            });
                            mapwin.show();
                        }
                    }
                }
            ],
            addFormTitle: 'Add Postal Address',
            editFormTitle: 'Edit Postal Address',
            formFields: [
                {
                    fieldLabel: 'Address Line 1',
                    name: 'address_line_1',
                    allowBlank: false
                },
                {
                    fieldLabel: 'Address Line 2',
                    name: 'address_line_2'
                },
                {
                    fieldLabel: 'City',
                    name: 'city',
                    allowBlank: false
                },
                {
                    fieldLabel: 'State',
                    name: 'state',
                    xtype: 'combo',
                    forceSelection: true,
                    typeAhead: true,
                    queryMode: 'local',
                    displayField: 'state',
                    valueField: 'geo_zone_code',
                    store: statesStore
                },
                {
                    fieldLabel: 'Zip',
                    name: 'zip',
                    regex: /^\d{5}(-\d{4})?$/,
                    regexText: "Must be a valid 5 or 9 digit zip code",
                    allowBlank: false
                },
                {
                    fieldLabel: 'Country',
                    name: 'country',
                    value: 'USA',
                    allowBlank: false
                }
            ]
        })]);
    }
});
