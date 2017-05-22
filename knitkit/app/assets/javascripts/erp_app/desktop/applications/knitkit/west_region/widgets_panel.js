Ext.define("Compass.ErpApp.Desktop.Applications.Knitkit.WidgetsPanel",{
    extend:"Ext.panel.Panel",
    alias:'widget.knitkit_WidgetsPanel',
    
    constructor : function(config) {
        var widgetsStore = Ext.create('Ext.data.Store',{
            autoDestroy: true,
            fields:['name', 'iconUrl', 'addWidget', 'about'],
            data: Compass.ErpApp.Widgets.AvailableWidgets
        });
        
        this.widgetsDataView = Ext.create("Ext.view.View",{
            style:'overflow:auto',
            itemSelector: 'div.thumb-wrap',
            store:widgetsStore,
            tpl: [
                '<tpl for=".">',
                '<div data-qtip="{about}" class="thumb-wrap" id="{name}">',
                '<div class="thumb"><img src="{iconUrl}" class="thumb-img"></div>',
                '<span>{name}</span></div>',
                '</tpl>',
                '<div class="x-clear"></div>'
            ],
            listeners:{
                itemcontextmenu: function(view, record, htmlitem, index, e, options){
                    e.stopEvent();
                    var contextMenu = Ext.create("Ext.menu.Menu",{
                        items:[{
                            text:'Add Widget',
                            iconCls:'icon-add',
                            handler:function(btn){
                                record.data.addWidget({
                                    websiteBuilder: false,
                                    success: function(content) {
                                        //add rendered template to center region editor
                                        Ext.getCmp('knitkitCenterRegion').addContentToActiveCodeMirror(content);
                                    }
                                });
                            }
                        }]
                    });
                    contextMenu.showAt(e.xy);
                },
                
                viewready: function(dataView) {
                    var win = Ext.getCmp('knitkit');
                    var panel = dataView.up('panel');
                    var widgetsNodeList = panel.el.dom.querySelectorAll('div.thumb-wrap');
                    var store = dataView.getStore();
                    widgetsNodeList.forEach(function(node){
                        var elem = document.getElementById(node.id);
                        console.log(elem);
                        elem.setAttribute('draggable', true);
                        jQuery(elem).on('dragstart', function(event) {
                            console.log("Drag Started");
                            if (!win.dragoverqueueProcessTimerTask) {
                                win.dragoverqueueProcessTimerTask = new Compass.ErpApp.Utility.TimerTask(function() {
                                    DragDropFunctions.ProcessDragOverQueue();
                                }, 100);
                                win.dragoverqueueProcessTimerTask.start();
                            } 
                            // widgets component IID would be used to set retrive its Source in the iFrame
                            event.originalEvent.dataTransfer.setData("widget-name", node.id);
                        });
                        jQuery(elem).on('dragend', function() {
                            console.log("Drag End");
                        });
                    })
                }
            },

            
        });
        
        config = Ext.apply({
            id:'widgets',
            autoDestroy:true,
            margins: '5 5 5 0',
            layout:'fit',
            items: this.widgetsDataView
        }, config);
        
        this.callParent([config]);
    },

    getWidgetData: function(widgetName) {
        var me = this;
        store = me.widgetsDataView.getStore();
        return store.findRecord('name', widgetName).data;
    }
});



