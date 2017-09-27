Compass AE is a set of Engines or Slices-style Rails plugins that incrementally add the functionality of an ERP to a Rails application.
It is meant to stay completely out of the directories that a Rails application developer would use, so your app and public directories are clean for you to use.
It's Object-Relational layer is based conceptually on the phenomenal Data Model Resource Book series, by Len Silverston, as well as the Archetype Patterns work of Arlow and Neustadt. These models and many similar works have become so widely recognized so as to represent to a certain extent a de facto standard for how to organize ERP-type software. Our choice to create an open source erp framework by staying close to them at a logical level allows these excellent books to serve as reference guides for the conceptual underpinnings of the O/R components.

##Getting Started

To get started simply install the compass_ae gem

    gem install compass_ae
    
Once installed you will get a compass_ae command line utility, use this command to create a new Compass AE application

    compass_ae new [your apps name]

###Development

You can also create a Compass AE application with our github source via this command

    compass_ae dev [your apps name]
    
this will clone our repository into a folder named compass_agile_enterprise within your lib folder of the rails application

##License
CompassERP’s foundation modules and base applications are released under a GPL license. CompassERP development is supported by [TrueNorth Technology Solutions](http://www.truenorthtechnology.com), which offers vertical solutions based on this framework, support and consulting services around the technology.



