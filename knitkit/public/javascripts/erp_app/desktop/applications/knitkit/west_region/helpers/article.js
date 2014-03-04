Compass.ErpApp.Desktop.Applications.Knitkit.addArticleOptions = function (self, items, record) {


    items.push({
        text:'Edit Article Attributes',
        iconCls:'icon-document',
        listeners:{
            'click':function () {

                var self = this;
                var itemId = 'editArticle-'+record.get('id');
                var editArticleWindow = Ext.ComponentQuery.query('#'+itemId).first();

                if(Compass.ErpApp.Utility.isBlank(editArticleWindow)){
                    var editArticleWindow = Ext.create("Ext.window.Window",{
                        layout:'fit',
                        width:375,
                        title:'Edit Article',
                        itemId:itemId,
                        plain: true,
                        buttonAlign:'center',
                        items: {
                            xtype: 'form',
                            labelWidth: 110,
                            frame:false,
                            bodyStyle:'padding:5px 5px 0',
                            width: 425,
                            url:'/knitkit/erp_app/desktop/articles/update/',
                            defaults: {width: 225},
                            items: [
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Title',
                                    allowBlank:false,
                                    name:'title',
                                    value: record.data.text
                                },
                                {
                                    xtype:'radiogroup',
                                    fieldLabel:'Display title?',
                                    name:'display_title',
                                    columns:2,
                                    items:[
                                        {
                                            boxLabel:'Yes',
                                            name:'display_title',
                                            inputValue: 'yes',
                                            checked:record.data.display_title
                                        },

                                        {
                                            boxLabel:'No',
                                            name:'display_title',
                                            inputValue:'no',
                                            checked:!record.data.display_title
                                        }]
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Internal ID',
                                    allowBlank:true,
                                    name:'internal_identifier',
                                    value: record.data.internal_identifier
                                },
                                {
                                    xtype:'textfield',
                                    fieldLabel:'Tags',
                                    allowBlank:true,
                                    name:'tags',
                                    itemId: 'tag_list',
                                    value: record.data.tag_list
                                },
                                {
                                    xtype: 'displayfield',
                                    fieldLabel: 'Created At',
                                    name: 'created_at',
                                    value: record.data.created_at
                                },
                                {
                                    xtype: 'displayfield',
                                    fieldLabel: 'Updated At',
                                    name: 'updated_at',
                                    value: record.data.updated_at
                                },
                                {
                                    xtype:'hidden',
                                    allowBlank:false,
                                    name:'id',
                                    itemId: 'record_id',
                                    value: record.data.id
                                }
                            ]
                        },
                        buttons: [{
                            text:'Submit',
                            listeners:{
                                'click':function(button){
                                    var window = button.findParentByType('window');
                                    var formPanel = window.query('form')[0];
                                    var values = formPanel.getValues();
                                    formPanel.getForm().submit({
                                        reset:false,
                                        success:function(form, action){
                                            var obj = Ext.decode(action.response.responseText);
                                            if(obj.success){
                                                record.set('text', values.title);
                                                record.set('display_title', !Ext.isEmpty(values.display_title));
                                                if(formPanel.getForm().findField('tag_list')){
                                                    var tag_list = formPanel.getForm().findField('tag_list').getValue();
                                                    record.set('tag_list', tag_list);
                                                }
                                                editArticleWindow.close();
                                            }
                                            else{
                                                Ext.Msg.alert("Error", obj.msg);
                                            }
                                        },
                                        failure:function(form, action){
                                            Ext.Msg.alert("Error", "Error updating article");
                                        }
                                    });
                                }
                            }
                        },{
                            text: 'Close',
                            handler: function(){
                                editArticleWindow.close();
                            }
                        }]
                    });
                }
                editArticleWindow.show();
            }
        }
    });

    items.push({
        text:'Delete Article',
        iconCls:'icon-delete',
        listeners:{
            'click':function () {

                Ext.MessageBox.confirm('Confirm', 'Are you sure you want to remove this article from the page?', function (btn) {
                    if (btn == 'no') {
                        return false;
                    }
                    else if (btn == 'yes') {
                        //self.setWindowStatus('Deleting article...');

                        Ext.Ajax.request({
                            url: '/knitkit/erp_app/desktop/section/detach_article',
                            method: 'POST',
                            params:{
                                id: record.data.parentItemId,
                                article_id: record.data.id
                            },
                            success: function(response) {
                                var obj =  Ext.decode(response.responseText);
                                if(obj.success){
                                    //self.initialConfig['centerRegion'].clearWindowStatus();
                                    //self.getStore().load();
                                    record.remove();

                                }
                                else{
                                    Ext.Msg.alert('Error', 'Error detaching Article');
                                    //self.initialConfig['centerRegion'].clearWindowStatus();
                                }
                            },
                            failure: function(response) {
                                //self.initialConfig['centerRegion'].clearWindowStatus();
                                Ext.Msg.alert('Error', 'Error detaching Article');
                            }
                        });
                    }
                });
            }
        }
    });

    return items;
}