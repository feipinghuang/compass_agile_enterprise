Ext.ns("Compass.ErpApp.Organizer.Applications.Crm");
/**
 * Method to setup organizer application
 * @param {config} Object containing (organizerLayout : reference to main layout container)
 */
Compass.ErpApp.Organizer.Applications.Crm.Base = function(config) {
    this.setup = function() {
        config.organizerLayout.addApplication({
            title: 'CRM',
            id: 'crmTaskTabPanel',
            tabs: [{
                xtype: 'crmpartygrid',
                itemId: 'customersPanel',

                contactPurposes: [{
                    fieldLabel: 'Home',
                    internalIdentifier: 'home'
                }, {
                    fieldLabel: 'Work',
                    internalIdentifier: 'work'
                }, {
                    fieldLabel: 'Billing',
                    internalIdentifier: 'billing'
                }],
                partyRelationships: [{
                    title: 'Employees',
                    relationshipType: 'employee_customer',
                    toRoleType: 'customer',
                    fromRoleType: 'employee',
                    contactPurposes: [{
                        fieldLabel: 'Home',
                        internalIdentifier: 'home'
                    }, {
                        fieldLabel: 'Work',
                        internalIdentifier: 'work'
                    }, {
                        fieldLabel: 'Billing',
                        internalIdentifier: 'billing'
                    }]
                }]
            }],
            menuItems: [{
                title: 'Customers',
                tabItemId: 'customersPanel',
                imgSrc: '/assets/erp_app/organizer/applications/crm/customer_360_64x64.png'
            }]

        });
    };
};