(function () {
	"use strict";

	var MediumEditor = require('medium-editor');
	var rangy = require('rangy');
    require('rangy/lib/rangy-classapplier');

    rangy.init();

    module.exports.HighlighterButton = MediumEditor.extensions.button.extend({

        name: 'highlighter',
        tagNames: ['mark'], // nodeName which indicates the button should be 'active' when isAlreadyApplied() is called
		contentDefault: '<b>H</b>', // default innerHTML of the button
		contentFA: '<i class="fa fa-paint-brush"></i>', // innerHTML of button when 'fontawesome' is being used
		aria: 'Hightlight', // used as both aria-label and title attributes
		action: 'highlight', // used as the data-action attribute of the button
        iframeWin: {},

        init: function () {

        	MediumEditor.extensions.button.prototype.init.call(this);

		    this.classApplier = rangy.createClassApplier('highlight', {
		        elementTagName: 'mark',
		        normalize: true
		    });

		    this.iframeWin = rangy.dom.getIframeWindow(this.window.frameElement);

		},

		handleClick: function (event) {

		    this.classApplier.toggleSelection(this.iframeWin);
		    return false;

		}
		
    });

}());