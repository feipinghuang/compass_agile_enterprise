Ext.override(Ext.data.Store, {
    setExtraParam: function(name, value) {
        this.proxy.extraParams = this.proxy.extraParams || {};
        this.proxy.extraParams[name] = value;
        this.proxy.applyEncoding(this.proxy.extraParams);
    }
});

// fix for tempHidden in ExtJS 4.0.7 - Invoice Mgmt window was not opening correctly
// taken from http://www.sencha.com/forum/showthread.php?160222-quot-this.tempHidden-is-undefined-quot-Error-Workaround
Ext.override(Ext.ZIndexManager, {
    tempHidden: [],

    show: function() {
        var comp, x, y;

        while (comp = this.tempHidden.shift()) {
            x = comp.x;
            y = comp.y;

            comp.show();
            comp.setPosition(x, y);
        }
    }
});

Ext.override(Ext.Msg, {
    warning: function(title, msg, fn, scope) {
        Ext.Msg.show({
            title: title,
            msg: msg,
            buttons: Ext.Msg.OK,
            icon: Ext.Msg.WARNING,
            fn: fn,
            scope: scope
        });
    },

    error: function(title, msg, fn, scope) {
        Ext.Msg.show({
            title: title,
            msg: msg,
            buttons: Ext.Msg.OK,
            icon: Ext.Msg.ERROR,
            fn: fn,
            scope: scope
        });
    },

    success: function(title, msg, fn, scope) {
        Ext.Msg.show({
            title: title,
            msg: msg,
            buttons: Ext.Msg.OK,
            icon: Ext.MessageBox.INFO,
            fn: fn,
            scope: scope
        });
    }
});

Ext.define('Compass.ErpApp.Shared.RowEditingOverride', {
    override: 'Ext.grid.RowEditor',

    hideToolTip: Ext.emptyFn,

    showToolTip: Ext.emptyFn,

    updateButton: Ext.emptyFn,

    loadRecord: function(record) {
        var me = this,
            form = me.getForm(),
            fields = form.getFields(),
            items = fields.items,
            length = items.length,
            i, displayFields,
            isValid;

        // temporarily suspend events on form fields before loading record to prevent the fields' change events from firing
        for (i = 0; i < length; i++) {
            items[i].suspendEvents();
        }

        form.loadRecord(record);
        form.reset();

        for (i = 0; i < length; i++) {
            items[i].resumeEvents();
        }

        if (!record.phantom) {
            isValid = form.isValid();
            if (me.errorSummary) {
                if (isValid) {
                    me.hideToolTip();
                } else {
                    me.showToolTip();
                }
            }
        }

        // render display fields so they honor the column renderer/template
        displayFields = me.query('>displayfield');
        length = displayFields.length;

        for (i = 0; i < length; i++) {
            me.renderColumnData(displayFields[i], record);
        }
    }
});

Ext.define('Compass.ErpApp.Shared.RowEditingPluginOverride', {
    override: 'Ext.grid.plugin.RowEditing',

    startEdit: function(record, columnHeader) {
        var me = this,
            editor = me.getEditor(),
            context;

        if (Ext.isEmpty(columnHeader)) {
            columnHeader = me.grid.getTopLevelVisibleColumnManager().getHeaderAtIndex(0);
        }

        if (editor.beforeEdit() !== false) {
            context = me.callSuper([record, columnHeader]);
            if (context) {
                me.context = context;

                // If editing one side of a lockable grid, cancel any edit on the other side.
                if (me.lockingPartner) {
                    me.lockingPartner.cancelEdit();
                }
                editor.startEdit(context.record, context.column, context);
                me.fireEvent('editstarted', editor);
                me.editing = true;
                return true;
            }
        }
        return false;
    },

    /**
     * This patch fixes a bug in ExtJs 4.2.2 grid row editing plugin which prohibts and inline update
     * after you tried to update even when there is a validation failure.
     **/
    completeEdit: function() {
        var me = this;
        if (me.validateEdit() && this.editing) {
            me.editing = false;
            me.fireEvent('edit', me, me.context);
        }
    }

});

// fix hide submenu (in chrome 43)
Ext.override(Ext.menu.Menu, {
    onMouseLeave: function(e) {
        var me = this;

        // BEGIN FIX
        var visibleSubmenu = false;
        me.items.each(function(item) {
            if (item.menu && item.menu.isVisible()) {
                visibleSubmenu = true;
            }
        });

        if (visibleSubmenu) {
            //console.log('apply fix hide submenu');
            return;
        }
        // END FIX

        me.deactivateActiveItem();

        if (me.disabled) {
            return;
        }

        me.fireEvent('mouseleave', me, e);
    }
});

Ext.override(Ext.grid.RowEditor, {
    initComponent: function() {
        var me = this;
        me.addEvents(
            /*
             * @event updated
             * Fires when a record is updated
             * @param {Compass.ErpApp.Shared.BusinessModule.DetailView} this
             * @param {Int} updatedPartyId
             */
            'updated'
        );
        me.callParent();
    }
});

// Upate to include time zone
Ext.JSON.encodeDate = function(o) {
    return '"' + Ext.Date.format(o, 'c') + '"';
};
