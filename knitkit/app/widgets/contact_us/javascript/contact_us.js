Compass.ErpApp.Widgets.ContactUs = {
    template: new Ext.Template('<%= render_widget :contact_us %>'),

    addContactUs: function () {
        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror(Compass.ErpApp.Widgets.ContactUs.template.apply());
    }
};

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name: 'Contact Us',
    iconUrl: '/assets/icons/mail/mail_48x48.png',
    onClick: Compass.ErpApp.Widgets.ContactUs.addContactUs,
    about: 'This widget creates a form to allow for website inquiries.'
});


