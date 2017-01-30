Ext.namespace('Compass.ErpApp.Desktop.Applications.Knitkit.WebsiteBuilder').config = {
    pageContainer: "#page",
    editableItems: {
        'span.fa': ['color', 'font-size'],
        '.bg.bg1': ['background-color'],
        'nav a': ['color', 'font-weight', 'text-transform'],
        'img': ['border-top-left-radius', 'border-top-right-radius', 'border-bottom-left-radius', 'border-bottom-right-radius', 'border-color', 'border-style', 'border-width'],
        'hr.dashed': ['border-color', 'border-width'],
        '.divider > span': ['color', 'font-size'],
        'hr.shadowDown': ['margin-top', 'margin-bottom'],
        '.footer a': ['color'],
        '.social a': ['color'],
        '.bg.bg1, .bg.bg2, .header10, .header11': ['background-image', 'background-color'],
        '.frameCover': [],
        '.editContent': ['content', 'color', 'font-size', 'background-color', 'font-family'],
        'a.btn, button.btn': ['border-radius', 'font-size', 'background-color'],
        '#pricing_table2 .pricing2 .bottom li': ['content']
    },
    editableItemOptions: {
        'nav a : font-weight': ['400', '700'],
        'a.btn, button.btn : border-radius': ['0px', '4px', '10px'],
        'img : border-style': ['none', 'dotted', 'dashed', 'solid'],
        'img : border-width': ['1px', '2px', '3px', '4px'],
        'h1, h2, h3, h4, h5, p : font-family': ['default', 'Lato', 'Helvetica', 'Arial', 'Times New Roman'],
        'h2 : font-family': ['default', 'Lato', 'Helvetica', 'Arial', 'Times New Roman'],
        'h3 : font-family': ['default', 'Lato', 'Helvetica', 'Arial', 'Times New Roman'],
        'p : font-family': ['default', 'Lato', 'Helvetica', 'Arial', 'Times New Roman'],
    },
    inlineEditableSettings: [{
        'attrName': 'contenteditable',
        'attrValue': 'true'
    }, {
        'attrName': 'spellcheck',
        'attrValue': 'true'
    }, {
        'attrName': 'role',
        'attrValue': 'textbox'
    }, {
        'attrName': 'data-placeholder',
        'attrValue': 'Type your text'
    }],
    responsiveModes: {
        desktop: '97%',
        mobile: '480px',
        tablet: '1024px'
    },
    mediumCssUrls: [
        '//cdn.jsdelivr.net/medium-editor/latest/css/medium-editor.min.css',
        '../css/medium-bootstrap.css'
    ],
    mediumButtons: ['bold', 'italic', 'underline', 'anchor', 'orderedlist', 'unorderedlist', 'h1', 'h2', 'h3', 'h4', 'removeFormat'],
    externalJS: [
        'js/builder_in_block.js'
    ]
};