/**
 * This componet handles icon upload along with preview and drag drop.
 * Usage: include it as xtype: 'imageuploadfield', including this field in a form requires us to submit it via a method submitWithImage instead of submit.
 * TODO: allow only 64X(nx64) images in spriteMode amd move 64 to config.
 */

Ext.define('Compass.ErpApp.Shared.ImageUploadField', {
    alias: 'widget.imageuploadfield',
    extend: 'Ext.form.FieldSet',

    mixins: {
        field: 'Ext.form.field.Field'
    },

    style: {
        paddingBottom: '10px'
    },

    /**
     * @cfg {String} title of the fieldset which includes this field
     */

    title: 'Choose an icon for the Module',

    /**
     * @cfg {String} text of the button, which is one of the ways to choose image
     */
    buttonText: 'Choose Icon',

    /**
     * @cfg {String} name of the params which contained the image. This is will be used to process the image in the server side
     */
    name: 'image',

    /**
     * @cfg {String} src of preview image
     */
    previewImageSrc: null,

    /**
     * @cfg {Boolean} this mode enables upload of image sprites with normal and hover state icons of 64x64 stacked vertically
     */
    spriteMode: true,

    /**
     * @cfg {Boolean} width of image
     */
    imageWidth: 64,

    /**
     * @cfg {Boolean} height of image
     */
    imageHeight: 64,

    /**
     * text to be displayed in the drag area
     */
    dragAreaText: 'Drop an image here',

    /**
     * text to be displayed in the drag area
     */
    file: null,

    layout: 'column',

    listeners: {
        destroy: function(comp) {
            // destroy the corresponding attached image data if exists
            var form = comp.containerForm;
            if (form && form.uploadableImages) {
                var image = Ext.Array.findBy(form.uploadableImages, function(img) {
                    return img.imageKey == comp.name;
                });
                Ext.Array.remove(form.uploadableImages, image);
            }

        }
    },

    initComponent: function() {
        var me = this;

        var upLoadButton = {
            xtype: 'fileuploadfield',
            inputId: 'fileuploadfield_' + me.id,
            name: me.name,
            layout: me.layout,
            allowBlank: me.allowBlank,
            buttonText: me.buttonText,
            submit: false,
            buttonOnly: true,
            listeners: {
                change: function(input, value, opts) {
                    var canvas = Ext.ComponentQuery.query('image[canvas="' + input.inputId + '"]')[0],
                        file = input.getEl().down('input[type=file]').dom.files[0];
                    me.attachImage(file, canvas);
                }
            }
        };

        var previewImage = {
            xtype: 'image',
            frame: true,
            canvas: upLoadButton.inputId,
            width: me.imageWidth,
            height: me.imageHeight,
            animate: 2000,
            hidden: true,
            scope: this
        };

        me.dropTargetId = 'droptaget-' + (me.itemId || Math.random().toString());

        var dropTarget = {
            xtype: 'component',
            html: '<div class="drop-target"' + 'id=' + '\'' + me.dropTargetId + '\'' + '>' + me.dragAreaText + '</div>'
        };

        me.items = [{
            columnWidth: 0.5,
            items: [upLoadButton, dropTarget]
        }, {
            columnWidth: 0.5,
            items: [previewImage]
        }];

        me.on('afterrender', function(e) {
            var form = me.up('form'),
                previewImage = me.down('image');

            me.containerForm = form;

            if (me.value) {
                if (me.spriteMode) {
                    me.setupSpriteImage(previewImage, me.value);
                } else {
                    previewImage.setSrc(me.value);
                }

                previewImage.show();

            } else if (!Ext.isEmpty(me.previewImageSrc)) {
                if (me.spriteMode) {
                    me.setupSpriteImage(previewImage, me.previewImageSrc);
                } else {
                    previewImage.setSrc(me.previewImageSrc);
                }

                previewImage.show();
            }

            var dropWindow = document.getElementById(me.dropTargetId);
            dropWindow.addEventListener('dragenter', function(e) {
                e.preventDefault();
                e.dataTransfer.dropEffect = 'none';
            }, false);

            dropWindow.addEventListener('dragover', function(e) {
                e.preventDefault();
                dropWindow.classList.add('drop-target-hover');
            });

            dropWindow.addEventListener('drop', function(e) {
                e.preventDefault();
                dropWindow.classList.remove('drop-target-hover');
                var file = e.dataTransfer.files[0],
                    canvas = Ext.ComponentQuery.query('image[canvas="' + previewImage.canvas + '"]')[0];
                me.attachImage(file, canvas);
            }, false);


            dropWindow.addEventListener('dragleave', function(e) {
                dropWindow.classList.remove('drop-target-hover');
            }, false);

        });

        me.callParent(arguments);
    },

    setPreviewSrc: function(src) {
        var previewImage = this.down('image');
        previewImage.setSrc(src);
        previewImage.show();
    },

    setValue: function(src) {
        if (src && src.image_url) {
            this.setPreviewSrc(src.image_url);
            this.value = src.image_url;
        } else {
            this.setPreviewSrc(src);
            this.value = src;
        }
    },

    getSubmitData: function() {
        return null;
    },

    attachImage: function(file, canvas) {
        var me = this,
            form = me.up('form');
        if (file.type == "image/jpeg" ||
            file.type == "image/jpg" ||
            file.type == "image/png" ||
            file.type == "image/gif" ||
            file.type == "image/ico"
        ) {

            if (!form.uploadableImages) {
                form.uploadableImages = [];
            }
            // find already attached image by the component name
            var image = Ext.Array.findBy(form.uploadableImages, function(img) {
                return img.imageKey == me.name;
            });

            // if image exists update it else add a new image
            if (image) {
                image.imageFile = file;
            } else {
                form.uploadableImages.push({
                    imageKey: me.name,
                    imageFile: file
                });
            }

            var reader = new FileReader();
            reader.onload = function(e) {
                if (me.spriteMode) {
                    me.setupSpriteImage(canvas, e.target.result);
                } else {
                    canvas.setSrc(e.target.result);
                }
            };
            reader.readAsDataURL(file);
            canvas.show();

            me.imageDropped = true;
            me.file = file;
            me.down('fileuploadfield').allowBlank = true;
            me.down('fileuploadfield').submitValue = false;

        } else {
            Ext.Msg.alert('Error', 'Only images please, supported files are jpeg,jpg,png,gif,ico');
        }
    },

    getFile: function() {
        var me = this;
        var file = null;

        if (me.file) {
            file = me.file;
        } else {
            if (document.getElementById(me.down('fileuploadfield').getId() + '-button-fileInputEl'))
                file = document.getElementById(me.down('fileuploadfield').getId() + '-button-fileInputEl').files[0];
        }

        return file;
    },

    validate: function() {
        valid = true;

        if (!this.down('fileuploadfield').validate()) {
            if (this.getEl())
                this.getEl().setStyle('border', '1px solid red');

            valid = false;
        } else {
            if (this.getEl())
                this.getEl().setStyle('border', '1px solid #b5b8c8;');
        }

        return valid;
    },

    setAllowBlank: function(value) {
        if (typeof(value) == "boolean") {
            this.allowBlank = value;
            this.down('fileuploadfield').allowBlank = value;
        }
    },

    /**
     * sets up the image sprit and css class for normal and hover state
     * @params{Object} image, the image field
     * @params{String} imageSrc, the image URL or URL constructed from file reader before uploading
     */
    setupSpriteImage: function(image, imageSrc) {
        var me = this,
            spriteModeId = 'sprite-mode';
        Ext.util.CSS.removeStyleSheet(spriteModeId);
        Ext.util.CSS.createStyleSheet(
            '.normal-state' + '{background: url(' + "\'" + imageSrc + "\'" + ') 0 0; width: ' + me.imageWidth + 'px; height: ' + me.imageHeight + 'px;}' +
            '.normal-state:hover' + '{background: url(' + "\'" + imageSrc + "\'" + ') 0 -' + me.imageHeight + 'px; width: ' + me.imageWidth + 'px; height: ' + me.imageHeight + 'px;}',
            spriteModeId
        );
        image.setSrc('');
        image.addCls('normal-state');

    }

});


/**
 * include a method submitWithImage for form. This method should be used when a form as xtype: 'imageuploadfield'.
 * it accepts params in the same as submit method, form.submitWithImage({
                                                                          url: 'some url',
                                                                          method: 'POST',
                                                                          params: {
                                                                            param_1: 'some value',
                                                                            param_2: 'some value'
                                                                            },
                                                                            success: function(result){} //  [OPTIONAL]
                                                                            failure: function(result){} // [OPTIONAL]
                                                                       });
 */

Ext.override(Ext.FormPanel, {
    submitWithImage: function(options) {
        var form = this,
            uploadableImages = form.uploadableImages,
            params = Ext.merge(this.getValues(), options.params),
            formData = new FormData(document.createElement('form'));

        for (var attr in params) {
            formData.append(attr, (Ext.isEmpty(params[attr]) ? '' : params[attr]));
        }

        if (uploadableImages) {
            Ext.each(uploadableImages, function(uploadableImage) {
                formData.append(uploadableImage['imageKey'], uploadableImage['imageFile']);
            });
        }

        formData.append('authenticity_token', Compass.ErpApp.AuthentictyToken);
        formData.append('client_utc_offset', (0 - new Date().getTimezoneOffset()));

        // get all file fields and append the data
        Ext.each(this.query('filefield'), function(fileField) {
            var image = null;

            // find already attached image by the component name
            if (uploadableImages) {
                image = Ext.Array.findBy(uploadableImages, function(img) {
                    return img.imageKey == fileField.name;
                });
            }

            if (document.getElementById(fileField.getId() + '-button-fileInputEl') && Ext.isEmpty(image) && Ext.isEmpty(fileField.up('imageuploadfield')))
                formData.append(fileField.name, document.getElementById(fileField.getId() + '-button-fileInputEl').files[0]);
        });

        var xhr = new XMLHttpRequest(),
            method = options.method || 'POST';
        xhr.open(method, options.url);

        var messageBox = null;
        xhr.addEventListener('loadstart', function(e) {
            messageBox = Ext.MessageBox.show({
                msg: options.waitMsg,
                progressText: 'Saving...',
                width: 300,
                wait: true,
                waitConfig: {
                    interval: 200
                }
            });
        }, false);

        xhr.addEventListener('loadend', function(evt) {
            var obj = Ext.decode(evt.target.responseText);

            if (evt.target.status === 200) {
                Ext.MessageBox.hide();

                if (obj.success) {
                    // remove all attached uploaded images from the form
                    form.removeAttachedUploadedImages();
                    if (typeof(options.success) === 'function') {
                        options.success(obj);
                    }
                } else {
                    if (typeof(options.failure === 'function')) {
                        options.failure(obj);
                    }
                }
            } else {
                messageBox.hide();
                if (typeof(options.failure === 'function')) {
                    options.failure(obj);
                }
            }

        }, false);

        xhr.send(formData);
    },

    // remove all images uploadable by image upload component
    removeAttachedUploadedImages: function() {
        if (this.uploadableImages) {
            delete this.uploadableImages;
        }
    }

});