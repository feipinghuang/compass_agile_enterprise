Compass.ErpApp.Widgets.ContactUs = {
    buildTemplate: function(websiteBuilder) {
        if(websiteBuilder) {
            return new Ext.Template("<%= render_builder_widget :contact_us %>");
        } else {
            return new Ext.Template("<%= render_widget :contact_us %>");
        }

    },
    addWidget: function (options) {
        var websiteBuilder = options.websiteBuilder,
            success = options.success;
        if(success) {
            var statement = Compass.ErpApp.Widgets.ContactUs.buildTemplate(websiteBuilder).apply();
            success(statement);
        }
    }
};

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name: 'Contact Us',
    iconUrl: '/assets/icons/mail/mail_48x48.png',
    addWidget: Compass.ErpApp.Widgets.ContactUs.addWidget,
    about: 'This widget creates a form to allow for website inquiries.'
});


