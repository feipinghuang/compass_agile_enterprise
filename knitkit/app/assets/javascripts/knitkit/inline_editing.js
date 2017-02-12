Compass.ErpApp.Utility.createNamespace("Knitkit");

Knitkit.InlineEditing = {
    contentDiv: null,
    websiteId: null,
    contentId: null,

    closeEditor: function (editor) {
        editor.destroy();

        var body = jQuery("body");

        jQuery('#editableContentContainer').remove();
        jQuery('#editableContentOverlay').remove();
        body.removeClass('modal-open');
        body.removeClass('inline-editing');
    },

    saved: function (editor, result, status, xhr) {
        jQuery('#editableContentOverlay').css('z-index', '1001');

        if (result.success === true) {
            this.closeEditor(editor);
        }
        else {
            jQuery('#inlineEditSaveResult').html(" Could not update.  Please try again.");
        }
    },

    error: function (xhr, status, error) {
        jQuery('#inlineEditSaveResult').html(" Could not update.  Please try again.");
    },

    closeEditorClick: function () {
        //make sure modal is not already showing
        if (jQuery("#warning-modal").length === 0) {
            var editor = CKEDITOR.instances['inlineEditTextarea'];
            if (editor.checkDirty()) {
                jQuery('#editableContentOverlay').css('z-index', '1003');

                var warningModal = jQuery('<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true"></div>'),
                    modalDialog = jQuery('<div class="modal-dialog"></div>'),
                    modalContent = jQuery('<div class="modal-content"></div>'),
                    modalHeader = jQuery('<div class="modal-header"><h4 class="modal-title" id="myModalLabel">Please Confirm</h4></div>'),
                    modalBody = jQuery('<div class="modal-body">You have unsaved changes. Are you sure you want to exit?</div>'),
                    footer = jQuery('<div class="modal-footer"></div>'),
                    yesBtn = jQuery('<button type="button" class="btn btn-default" data-dismiss="modal">Yes</button>'),
                    noBtn = jQuery('<button type="button" class="btn btn-primary" data-dismiss="modal">No</button>');

                footer.append(yesBtn);
                footer.append(noBtn);
                modalContent.append(modalHeader);
                modalContent.append(modalBody);
                modalContent.append(footer);
                modalDialog.append(modalContent);
                warningModal.append(modalDialog);

                noBtn.bind('click', function () {
                    warningModal.modal('hide');
                    warningModal.remove();
                    jQuery('#editableContentOverlay').css('z-index', '1001');
                });

                yesBtn.bind('click', function () {
                    Knitkit.InlineEditing.closeEditor(editor);
                    warningModal.modal('hide');
                    warningModal.remove();
                });

                jQuery("body").append(warningModal);

                warningModal.modal({backdrop: false});
            }
            else {
                Knitkit.InlineEditing.closeEditor(editor);
            }
        }
        return false;
    },

    setup: function (websiteId) {
        var content = jQuery('div.knitkit_content'),
            body = jQuery("body");

        this.websiteId = websiteId;

        content.bind('mouseenter', function () {
            var div = jQuery(this);
            div.addClass('knitkit-inlineedit-editable');
        });

        content.bind('mouseleave', function () {
            var div = jQuery(this);
            div.removeClass('knitkit-inlineedit-editable');
        });

        content.bind('click', function () {
            var self = Knitkit.InlineEditing;
            var div = jQuery(this);
            self.contentId = div.attr('contentid');
            self.lastUpdate = div.attr('lastupdate');
            var data = div.html();

            var dialogHeader = jQuery("<div class='header'></div>");
            var closeLink = jQuery("<a class='inline-edit-close'><img width='24px' height='24px' src='/assets/inline_edit/close.png' /></a><br />");
            var textarea = jQuery('<textarea name="inline-edit-textarea" id="inlineEditTextarea" ></textarea>');
            var messageSpan = jQuery("<span class='inline-edit-message' id='inlineEditMessage'>Last Update: <span id='inlineEditLastUpdate'>" + self.lastUpdate + "</span><span id='inlineEditSaveResult'></span></span>");

            var editableContentContainer = jQuery("<div id='editableContentContainer' style='font-size:12px;' class='modal-container'></div>");
            var ckeditorWrapper = jQuery("<div class='ckeditor_wrapper'></div>");
            var actionResultDiv = jQuery("<div class='editable-content-actionresult'></div>");

            var CKEDITOR_BASEPATH = '/javascripts/ckeditor/';

            dialogHeader.append(closeLink);
            editableContentContainer.append(dialogHeader);
            editableContentContainer.append(ckeditorWrapper);
            ckeditorWrapper.append(textarea);
            textarea.val(data);
            editableContentContainer.append(actionResultDiv);
            actionResultDiv.append(messageSpan);

            var overlay = jQuery("<div id='editableContentOverlay' class='modal-overlay'></div>");

            body.append(editableContentContainer);
            body.append(overlay);

            body.addClass('inline-editing');

            closeLink.bind('click', self.closeEditorClick);

            CKEDITOR.replace('inline-edit-textarea',
                {
                    height: 300,
                    enterMode: CKEDITOR.ENTER_BR,
                    allowedContent: true,
                    extraPlugins: 'inlineeditsave,codemirror',
                    toolbar: [
                        { name: 'document', items: [ 'Source', '-', 'InlineEditSave' ] },
                        { name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline' ] },
                        { name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent',
                            '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock' ] },
                        { name: 'links', items: [ 'Link', 'Unlink', 'Anchor' ] },
                        '/',
                        { name: 'styles', items: [ 'Styles', 'Format', 'Font', 'FontSize' ] },
                        { name: 'colors', items: [ 'TextColor', 'BGColor' ] }
                    ],
                    on: {
                        instanceReady: function (ev) {
                            Knitkit.InlineEditing.contentDiv = div;
                            this.focus();
                        },
                        dataReady: function (ev) {
                            this.resetDirty();
                        }
                    }
                });

        });
    }
};