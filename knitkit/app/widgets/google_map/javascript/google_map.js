Compass.ErpApp.Widgets.GoogleMap = {
    buildTemplate: function(websiteBuilder) {
        if(websiteBuilder) {
            return new Ext.Template("<%= render_builder_widget :google_map,\n",
                                    ':params => {\n',
                                    '   :zoom => {zoom},',
                                    "   :map_type => '{mapType}',",
                                    '   :drop_pins => [\n{dropPins}\n',
                                    "]}%>");
        } else {
            return new Ext.Template("<%= render_widget :google_map,\n",
                                    ':params => {\n',
                                    '   :zoom => {zoom},',
                                    "   :map_type => '{mapType}',",
                                    '   :drop_pins => [\n{dropPins}\n',
                                    "]}%>");
            
        }
            
    },
    dropPinTemplate: new Ext.XTemplate('<tpl for=".">', '{:title => \'{title}\', :address => \'{address}\'}{[xindex === xcount ? "" : ","]}', '</tpl>'),

    addWidget: function (options) {
        var websiteBuilder = options.websiteBuilder,
            success = options.success;
        
        // Define our data model
        var GoogleMapAddressModel = Ext.define('GoogleMapAddress', {
            extend: 'Ext.data.Model',
            fields: ['title', 'address']
        });

        // create the Data Store
        var store = Ext.create('Ext.data.Store', {
            // destroy the store if the grid is destroyed
            autoDestroy: true,
            model: 'GoogleMapAddress',
            proxy: {
                type: 'memory'
            },
            data: [
                {
                    title: 'TrueNorth.',
                    address: '1 S Orange Ave Orlando, FL 32801'
                }
            ]
        });


        var rowEditing = Ext.create('Ext.grid.plugin.RowEditing', {
            clicksToMoveEditor: 1,
            autoCancel: false,
            listeners: {
                'edit': function (editor, e) {
                    editor.record.commit();
                }
            }
        });


        var grid = Ext.create('Ext.grid.Panel', {
            autoDestroy: true,
            autoScroll: true,
            region: 'center',
            store: store,
            columns: [
                {
                    header: 'Title',
                    dataIndex: 'title',
                    width: 160,
                    editor: {
                        allowBlank: false
                    }
                },
                {
                    header: 'Address',
                    dataIndex: 'address',
                    flex: 1,
                    editor: {
                        allowBlank: false
                    }
                }
            ],
            frame: false,
            tbar: [
                {
                    text: 'Add Location',
                    iconCls: 'icon-add',
                    handler: function () {
                        rowEditing.cancelEdit();
                        store.insert(0, new GoogleMapAddressModel());
                        rowEditing.startEdit(0, 0);
                    }
                },
                {
                    itemId: 'removelocation',
                    text: 'Remove Location',
                    iconCls: 'icon-delete',
                    handler: function () {
                        var sm = grid.getSelectionModel();
                        rowEditing.cancelEdit();
                        store.remove(sm.getSelection());
                        if (store.getCount() > 0) {
                            sm.select(0);
                        }
                    },
                    disabled: true
                }
            ],
            plugins: [rowEditing],
            listeners: {
                'selectionchange': function (view, records) {
                    grid.down('#removelocation').setDisabled(!records.length);
                }
            }
        });

        var formPanel = Ext.create("Ext.form.Panel", {
            region: 'north',
            frame: false,
            bodyStyle: 'padding:5px 5px 0',
            items: [
                {
                    xtype: 'combo',
                    forceSelection: true,
                    store: [
                        ['HYBRID', 'HYBRID'],
                        ['ROADMAP', 'ROADMAP'],
                        ['SATELLITE', 'SATELLITE'],
                        ['TERRAIN', 'TERRAIN']
                    ],
                    fieldLabel: 'Map Type',
                    value: 'SATELLITE',
                    name: 'mapType',
                    allowBlank: false,
                    triggerAction: 'all'
                },
                {
                    xtype: 'numberfield',
                    fieldLabel: 'Zoom',
                    allowBlank: false,
                    value: 18,
                    id: 'zoom'
                }
            ]
        });


        var addGoogleMapWidgetWindow = Ext.create("Ext.window.Window", {
            layout: 'border',
            width: 500,
            title: 'Add Map Widget',
            height: 350,
            plain: true,
            buttonAlign: 'center',
            items: [formPanel, grid],
            buttons: [
                {
                    text: 'Submit',
                    listeners: {
                        'click': function (button) {
                            var window = button.findParentByType('window');
                            var formPanel = window.query('form')[0];
                            var basicForm = formPanel.getForm();
                            var mapType = basicForm.findField('mapType').getValue();
                            var zoom = basicForm.findField('zoom').getValue();

                            var data = {mapType: mapType, zoom: zoom, dropPins: null};
                            var dropPins = [];
                            grid.store.each(function (record) {
                                dropPins.push({
                                    title: record.data.title,
                                    address: record.data.address
                                })
                            });

                            data['dropPins'] = Compass.ErpApp.Widgets.GoogleMap.dropPinTemplate.apply(dropPins);
                            var content = Compass.ErpApp.Widgets.GoogleMap.buildTemplate(websiteBuilder).apply(data);
                            addGoogleMapWidgetWindow.close();

                            if(success) {
                                success(content);
                            }
                        }
                    }
                },
                {
                    text: 'Close',
                    handler: function () {
                        addGoogleMapWidgetWindow.close();
                    }
                }
            ]
        });
        addGoogleMapWidgetWindow.show();
    }
}

Compass.ErpApp.Widgets.AvailableWidgets.push({
    name: 'Google Map',
    iconUrl: '/assets/icons/map/map_48x48.png',
    addWidget: Compass.ErpApp.Widgets.GoogleMap.addWidget,
    about: 'This widget creates a google map with drop points you setup.'
});
