Ext.define("Compass.ErpApp.Shared.NotesGrid", {
    extend: "Ext.grid.Panel",
    alias: 'widget.shared_notesgrid',

     /**
      * @cfg {String} baseURL
      * Base url for CRUDing notes.
      */
    baseURL: '/erp_app/shared/notes',

    title: 'Notes',

    listeners: {
        activate: function () {
            this.store.loadPage(1);
        }
    },

    deleteNote: function (rec) {
        var me = this;

        Ext.Ajax.request({
            url: me.baseURL + '/' + rec.get('id'),
            method: 'DELETE',
            params: {
              business_module_id: me.businessModuleId
            },
            success: function (response) {
                var obj = Ext.decode(response.responseText);
                if (obj.success) {
                    me.getStore().load();
                }
                else {
                    Ext.Msg.alert('Error', 'Error deleting note.');
                }
            },
            failure: function (response) {
                Ext.Msg.alert('Error', 'Error deleting note.');
            }
        });
    },

    setParams: function (params) {
        this.recordId = params.recordId;
        this.recordType = params.recordType;
        this.store.proxy.setExtraParams({
            recordType: me.recordType,
            recordId: me.recordId
        });

    },

    buildNoteTypeStore: function(){
        var me = this;
      
        return Ext.create('Ext.data.Store', {
            proxy: {
                type: 'ajax',
                url: '/api/v1/note_types',
                reader: {
                    type: 'json',
                    root: 'note_types'
                }
            },
            fields: [
                {
                    name: 'id',
                    type: 'int'
                },
                {
                    name: 'description',
                    type: 'string'
                }
            ]
        });

    },

    canAddNote: function(){
        return currentUser.hasCapability('create', 'Note');
    },

    initComponent: function () {
        var me = this;

        var notesStore = Ext.create('Ext.data.Store', {
            proxy: {
                type: 'ajax',
                url: me.baseURL,
                extraParams: {
                  record_type: me.recordType,
                  record_id: me.recordId,
                  business_module_id: me.businessModuleId
                },
                reader: {
                    type: 'json',
                    root: 'notes'
                }
            },
            remoteSort: true,
            fields: [
                {
                    name: 'id',
                    type: 'int'
                },
                {
                    name: 'note_type_desc',
                    type: 'string'
                },
                {
                    name: 'summary',
                    type: 'string'
                },
                {
                    name: 'content',
                    type: 'string'
                },
                {
                    name: 'created_by_username',
                    type: 'string'
                },
                {
                    name: 'created_at',
                    type: 'date'
                }
            ]
        });

        var columns = [
            {
                header: 'Note Type',
                dataIndex: 'note_type_desc',
                flex: 1
            },
            {
                header: 'Summary',
                dataIndex: 'summary',
                sortable: false,
                flex: 1
            },
            {
                header: 'Created By',
                dataIndex: 'created_by_username',
                sortable: false,
                flex: 1
            },
            {
                header: 'Created',
                dataIndex: 'created_at',
                sortable: true,
                renderer: Ext.util.Format.dateRenderer('m/d/Y H:i:s'),
                flex: 1
            }
        ];

        columns.push({
            menuDisabled: true,
            resizable: false,
            xtype: 'actioncolumn',
            align: 'center',
            width: 50,
            items: [
                {
                    icon: '/assets/icons/eye/eye_16x16.png',
                    tooltip: 'View',
                    style: {
                        marginRight: '10px'
                    },
                    disabled: !currentUser.hasCapability('view', 'Note'),
                    getClass: function (value, metadata) {
                        return 'x-action-col-icon-margin';
                    },
                    handler: function (grid, rowIndex, colIndex) {
                        var rec = grid.getStore().getAt(rowIndex);
                        var noteWindow = Ext.create("Ext.window.Window", {
                            width: 325,
                            height: 400,
                            buttonAlign: 'center',
                            autoScroll: true,
                            layout: 'fit',
                            items: {
                                xtype: 'panel',
                                html: rec.get('content')
                            },
                            buttons: [
                                {
                                    text: 'Close',
                                    handler: function () {
                                        noteWindow.close();
                                    }
                                }
                            ]
                        });
                        noteWindow.show();
                    }
                },
                {
                    icon: '/assets/icons/delete/delete_16x16.png',
                    tooltip: 'Delete',
                    disabled: !currentUser.hasCapability('delete', 'Note'),
                    getClass: function (value, metadata) {
                        return 'x-action-col-icon-margin';
                    },
                    handler: function (grid, rowIndex, colIndex) {
                        Ext.MessageBox.confirm('Confirm', 'Are you sure you want to delete this note?', function (btn) {
                            if (btn == 'no') {
                                return false;
                            }
                            else if (btn == 'yes') {
                                var rec = grid.getStore().getAt(rowIndex);
                                me.deleteNote(rec);
                            }
                        });
                    }
                }
            ]
        });

        var toolBarItems = [];
        if (me.canAddNote()) {
            toolBarItems.push({
                text: 'Add Note',
                iconCls: 'icon-add',
                handler: function () {
                    var noteTypeStore = me.buildNoteTypeStore(),
                        addNoteWindow = Ext.create("Ext.window.Window", {
                        layout: 'fit',
                        itemId: 'addNoteWindow',
                        width: 325,
                        title: 'New Note',
                        height: 450,
                        plain: true,
                        buttonAlign: 'center',
                        items: Ext.widget('form', {
                            frame: false,
                            layout: '',
                            bodyStyle: 'padding:5px 5px 0',
                            url: me.baseURL,
                            items: [
                                {
                                    emptyText: 'Select Type...',
                                    xtype: 'combo',
                                    labelAlign: 'top',
                                    forceSelection: true,
                                    store: noteTypeStore,
                                    displayField: 'description',
                                    valueField: 'id',
                                    fieldLabel: 'Note Type',
                                    name: 'note_type_id',
                                    allowBlank: false,
                                    triggerAction: 'all'
                                },
                                {
                                    xtype: 'label',
                                    html: 'Note:',
                                    cls: "x-form-item x-form-item-label card-label"
                                },
                                {
                                    xtype: 'textarea',
                                    allowBlank: false,
                                    height: 300,
                                    width: 300,
                                    name: 'content'
                                }
                            ]
                        }),
                        buttons: [
                            {
                                text: 'Submit',
                                listeners: {
                                    'click': function (button) {
                                        var window = button.findParentByType('window');
                                        var formPanel = window.query('.form')[0];
                                        formPanel.getForm().submit({
                                            reset: true,
                                            params: {
                                              record_type: me.recordType,
                                              record_id: me.recordId,
                                              business_module_id: me.businessModuleId
                                            },
                                            success: function (form, action) {
                                                var obj = Ext.decode(action.response.responseText);
                                                if (obj.success) {
                                                    me.getStore().load();
                                                    addNoteWindow.close();
                                                }
                                                else {
                                                    Ext.Msg.alert("Error", obj.message);
                                                }
                                            },
                                            failure: function (form, action) {
                                                if (action.response !== undefined) {
                                                    var obj = Ext.decode(action.response.responseText);
                                                    Ext.Msg.alert("Error", obj.message);
                                                }
                                                else {
                                                    Ext.Msg.alert("Error", 'Error adding note.');
                                                }
                                            }
                                        });
                                    }
                                }
                            },
                            {
                                text: 'Close',
                                handler: function () {
                                    addNoteWindow.close();
                                }
                            }
                        ]
                    });
                    addNoteWindow.show();
                }
            });
        }

        me.store = notesStore;
        me.columns = columns;
        me.dockedItems = [
            {
                xtype: 'toolbar',
                dock: 'top',
                items: toolBarItems
            },
            {
                xtype: 'pagingtoolbar',
                dock: 'bottom',
                pageSize: 30,
                store: notesStore,
                displayInfo: true,
                displayMsg: 'Displaying {0} - {1} of {2}',
                emptyMsg: "No Notes"
            }
        ];

        me.callParent();
    }
});
