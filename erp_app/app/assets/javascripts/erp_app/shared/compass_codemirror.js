/**
 * @class Ext.ux.panel.CodeMirror
 * @extends Ext.Panel
 * Converts a panel into a code mirror editor with toolbar
 * @constructor
 *
 * @author Dan Ungureanu - ungureanu.web@gmail.com / http://www.devweb.ro
 * @Enhanced Russell Holmes
 */

Ext.define("Compass.ErpApp.Shared.CodeMirror", {
    extend: "Ext.panel.Panel",
    header: false,
    alias: 'widget.codemirror',
    codeMirrorInstance: null,

    statics: {

        /**
         * Helper method to determine mode for CodeMirror based on file type
         */

        determineCodeMirrorMode: function (fileName) {
            var fileType = fileName.split('.').pop(),
                mode = null;

            switch (fileType) {
                case 'rb':
                    mode = 'ruby';
                    break;
                case 'erb':
                case 'rhtml':
                    mode = 'rhtml';
                    break;
                case 'liquid':
                    mode = 'rhtml';
                    break;
                case 'css':
                    mode = 'css';
                    break;
                case 'js':
                    mode = 'javascript';
                    break;
                case 'sql':
                    mode = 'sql';
                    break;
                case 'yml':
                case 'yaml':
                    mode = 'yaml';
                    break;
                case 'md':
                    mode = 'markdown';
                    break;
                case 'html':
                    mode = 'htmlmixed';
                    break;
                case 'xml':
                    mode = 'xml';
                    break;
            }

            return mode;
        }
    },

    /**
     * @cfg {String} mode The default mode to use when the editor is initialized. When not given, this will default to the first mode that was loaded.
     * It may be a string, which either simply names the mode or is a MIME type associated with the mode. Alternatively,
     * it may be an object containing configuration options for the mode, with a name property that names the mode
     * (for example {name: "javascript", json: true}). The demo pages for each mode contain information about what
     * configuration parameters the mode supports.
     */
    mode: null,

    /**
     * @cfg {Boolean} showMode Enable mode combo in the toolbar.
     */
    showMode: true,

    /**
     * @cfg {Boolean} showLineNumbers Enable line numbers button in the toolbar.
     */
    showLineNumbers: true,

    /**
     * @cfg {Boolean} enableMatchBrackets Force matching-bracket-highlighting to happen
     */
    enableMatchBrackets: true,

    /**
     * @cfg {Boolean} enableElectricChars Configures whether the editor should re-indent the current line when a character is typed
     * that might change its proper indentation (only works if the mode supports indentation).
     */
    enableElectricChars: false,

    /**
     * @cfg {Boolean} enableIndentWithTabs Whether, when indenting, the first N*tabSize spaces should be replaced by N tabs.
     */
    enableIndentWithTabs: true,

    /**
     * @cfg {Boolean} enableSmartIndent Whether to use the context-sensitive indentation that the mode provides (or just indent the same as the line before).
     */
    enableSmartIndent: true,

    /**
     * @cfg {Boolean} enableLineWrapping Whether CodeMirror should scroll or wrap for long lines.
     */
    enableLineWrapping: true,

    /**
     * @cfg {Boolean} enableLineNumbers Whether to show line numbers to the left of the editor.
     */
    enableLineNumbers: true,

    /**
     * @cfg {Boolean} enableCodeFolding Whether to allow code folding.
     */
    enableCodeFolding: true,

    /**
     * @cfg {Boolean} enableGutter Can be used to force a 'gutter' (empty space on the left of the editor) to be shown even
     * when no line numbers are active. This is useful for setting markers.
     */
    enableGutter: true,

    /**
     * @cfg {Boolean} enableFixedGutter When enabled (off by default), this will make the gutter stay visible when the
     * document is scrolled horizontally.
     */
    enableFixedGutter: false,

    /**
     * @cfg {Number} firstLineNumber At which number to start counting lines.
     */
    firstLineNumber: 1,

    /**
     * @cfg {Boolean} readOnly <tt>true</tt> to mark the field as readOnly.
     */
    readOnly: false,

    /**
     * @cfg {Number} pollInterval Indicates how quickly (miliseconds) CodeMirror should poll its input textarea for changes.
     * Most input is captured by events, but some things, like IME input on some browsers, doesn't generate events
     * that allow CodeMirror to properly detect it. Thus, it polls.
     */
    pollInterval: 100,

    /**
     * @cfg {Number} indentUnit How many spaces a block (whatever that means in the edited language) should be indented.
     */
    indentUnit: 4,

    /**
     * @cfg {Number} tabSize The width of a tab character.
     */
    tabSize: 4,

    /**
     * @cfg {String} theme The theme to style the editor with. You must make sure the CSS file defining the corresponding
     * .cm-s-[name] styles is loaded (see the theme directory in the distribution). The default is "default", for which
     * colors are included in codemirror.css. It is possible to use multiple theming classes at onceâ€”for example
     * "foo bar" will assign both the cm-s-foo and the cm-s-bar classes to the editor.
     */
    theme: 'vibrant-ink',

    /**
     * @cfg {Boolean} disable save button.
     */
    disableSave: false,

    /**
     * @cfg {Array} additional toolbar items to add.
     */
    tbarItems: [],

    /**
     * @cfg {Array} disable toolbar.
     */
    disableToolbar: false,

    constructor: function (config) {
        config = Ext.applyIf({
            layout: 'fit',
            autoScroll: true,
            items: [
                {
                    xtype: 'textarea',
                    height: '100%',
                    value: config.sourceCode
                }
            ]
        }, config);

        this.callParent([config]);
    },

    initComponent: function () {
        var me = this;

        me.addEvents(
            /**
             * @event save
             * Fired when saving contents.
             * @param {Compass.ErpApp.Shared.CodeMirror} codemirror This object
             * @param (contents) contents needing to be saved
             */
            'save'
        );

        me.callParent(arguments);

        me.createToolbar();

        me.on('resize', function () {
            if (me.codeMirrorInstance) {
                me.codeMirrorInstance.refresh();
            }
        }, me);
    },

    onRender: function (ct, position) {
        this.callParent(arguments);
        this.on('afterlayout', this.setupCodeMirror, this, {
            single: true
        });
    },

    createToolbar: function (editor) {
        var me = this,
            availableModes = [],
            tipsEnabled = Ext.tip.QuickTipManager && Ext.tip.QuickTipManager.isEnabled(),
            baseCSSPrefix = Ext.baseCSSPrefix;

        Ext.each(Ext.Object.getKeys(CodeMirror.modes), function (name) {
            if (name == 'null') {
                availableModes.push(['text/plain'])
            }
            else {
                availableModes.push([name])
            }
        });

        availableModes.push(['rhtml']);

        items = [];

        // change mode
        if (me.showMode) {
            items.push({
                xtype: 'label',
                text: 'Mode'
            });

            items.push({
                xtype: 'combo',
                store: Ext.create('Ext.data.ArrayStore', {
                    fields: ['name'],
                    data: availableModes
                }),
                queryMode: 'local',
                displayField: 'name',
                valueField: 'name',
                listeners: {
                    change: function (comp, newValue, oldValue) {
                        var mode = newValue;

                        if (newValue == 'rhtml') {
                            mode = 'application/x-erb'
                        }

                        me.codeMirrorInstance.setOption('mode', mode);
                        me.codeMirrorInstance.refresh();
                    }
                }
            });
        }

        items.push({
            text: 'Undo',
            iconCls: 'icon-undo',
            handler: function () {
                this.codeMirrorInstance.undo();
            },
            scope: this
        });

        items.push({
            text: 'Redo',
            iconCls: 'icon-redo',
            handler: function () {
                this.codeMirrorInstance.redo();
            },
            scope: this
        });

        // line numbers button
        if (me.showLineNumbers)
            items.push({
                cls: baseCSSPrefix + 'btn-icon',
                iconCls: baseCSSPrefix + 'edit-insertorderedlist',
                itemId: 'insertorderedlist',
                tooltip: tipsEnabled ? 'Line Numbers' || undef : undef,
                enableToggle: true,
                handler: function () {
                    me.enableLineNumbers = !me.enableLineNumbers;
                    me.codeMirrorInstance.setOption('lineNumbers', me.enableLineNumbers);
                }
            });

        if (!me.disableSave) {
            items.push({
                text: 'Save',
                iconCls: 'icon-save',
                handler: this.save,
                scope: this
            });
        }

        items = items.concat(me.tbarItems);

        if (!me.disableToolbar) {
            me.addDocked({
                xtype: 'toolbar',
                cls: Ext.baseCSSPrefix + 'html-editor-tb',
                dock: 'top',
                enableOverflow: true,
                items: items
            });

            me.updateToolbarButtons();
        }
    },

    updateToolbarButtons: function () {
        var me = this;

        try {
            btns = me.getToolbar().items.map;
            if (me.showLineNumbers) {
                btns['insertorderedlist'].toggle(me.enableLineNumbers);
            }
        } catch (err) {

        }
    },

    setupCodeMirror: function () {
        var me = this,
            mode = me.mode || null,
            codeMirrorMode = null,
            css = null,
            textAreaComp = me.down('textarea'),
            modeCombo = me.down('combo');

        if (mode == 'rhtml') {
            codeMirrorMode = 'application/x-erb'
        }
        else{
            codeMirrorMode = mode;
        }

        this.initialConfig.codeMirrorConfig = Ext.apply({
            foldGutter: me.enableCodeFolding,
            matchBrackets: me.enableMatchBrackets,
            electricChars: me.enableElectricChars,
            indentUnit: me.indentUnit,
            smartIndent: me.enableSmartIndent,
            indentWithTabs: me.indentWithTabs,
            pollInterval: me.pollInterval,
            lineNumbers: me.enableLineNumbers,
            lineWrapping: me.enableLineWrapping,
            firstLineNumber: me.firstLineNumber,
            tabSize: me.tabSize,
            gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"],
            fixedGutter: me.enableFixedGutter,
            theme: me.theme,
            mode: codeMirrorMode,
            undoDepth: 5,
            extraKeys: {
                "Ctrl-S": function (instance) {
                    me.fireEvent('save', me, me.getValue());
                },
                "Cmd-S": function (instance) {
                    me.fireEvent('save', me, me.getValue());
                }
            },
            showCursorWhenSelecting: true,
            tabMode: "indent",
            onChange: function () {
                var code = self.codeMirrorInstance.getValue();
                textAreaComp.setValue(code);
            },
            onKeyEvent: function (editor, event) {
                event.cancelBubble = true; // fix suggested by koblass user on Sencha forums (http://www.sencha.com/forum/showthread.php?167047-Ext.ux.form.field.CodeMirror-for-Ext-4.x&p=862029&viewfull=1#post862029)
                me.fireEvent('keyevent', me, event);
            }
        }, this.initialConfig.codeMirrorConfig);

        me.codeMirrorInstance = CodeMirror.fromTextArea(textAreaComp.inputEl.dom, this.initialConfig.codeMirrorConfig);
        me.codeMirrorInstance.setCursor(1);

        // Enable Code Folding (Requires 'lineNumbers' to be set to 'true')
        if (me.enableLineNumbers && me.enableCodeFolding) {
            me.codeMirrorInstance.on("gutterClick", CodeMirror.newFoldFunction(CodeMirror.tagRangeFinder));
        }

        if (me.showMode) {
            // set value of mode combo
            if (mode == null) {
                modeCombo.setValue('text/plain');
            }
            else {
                modeCombo.setValue(mode);
            }
        }

        // change the codemirror css
        css = Ext.util.CSS.getRule('.CodeMirror', true);
        if (css) {
            css.style.height = '100%';
            css.style.overflow = 'hidden';
        }
        css = Ext.util.CSS.getRule('.CodeMirror-scroll', true);
        if (css) {
            css.style.height = '100%';
        }

        var tdElement = Ext.get(textAreaComp.inputEl.up('td', 1, true));
        tdElement.setStyle('height', '100%');

        me.codeMirrorInstance.refresh();
    },

    save: function () {
        this.fireEvent('save', this, this.getValue());
    },

    setValue: function (value) {
        this.codeMirrorInstance.setValue(value);
    },

    getValue: function () {
        return this.codeMirrorInstance.getValue();
    },

    getCursor: function () {
        return this.codeMirrorInstance.getCursor();
    },

    getSelection: function () {
        return this.codeMirrorInstance.getSelection();
    },

    insertContent: function (value) {
        this.codeMirrorInstance.replaceRange(value, this.codeMirrorInstance.getCursor());
    },

    focus: function(){
        this.callParent();
        this.codeMirrorInstance.focus();
    }
});
