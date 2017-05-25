Compass.ErpApp.Widgets.ContactUs = {
    buildStatement: function(websiteBuilder) {
        return Compass.ErpApp.Shared.Helpers.WidgetStatementBuilder.buildTemplate({
            widgetName: 'contact_us',
            websiteBuilder: websiteBuilder
        }).apply();
        
    },
    addWidget: function (options) {
        var websiteBuilder = options.websiteBuilder,
            success = options.success;
        if(success) {
            var statement = Compass.ErpApp.Widgets.ContactUs.buildStatement(websiteBuilder);
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


