/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets, vendor/assets/stylesheets,
 * or vendor/assets/stylesheets of plugins, if any, can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the top of the
 * compiled file, but it's generally better to create a new file per style scope.
 *
 *= require_self
 */

// Generated by CoffeeScript 1.3.3
/*
Ext.ux.callout.Callout - CSS styleable floating callout container with optional arrow for use with Ext JS 4.0+
http://github.com/CodeCatalyst/Ext.ux.callout.Callout

@author John Yanarella
@version: 1.0.1

Copyright (c) 2012 CodeCatalyst, LLC - http://www.codecatalyst.com/

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

Ext.define('Ext.ux.callout.Callout', {
  extend: 'Ext.Container',
  alias: 'widget.callout',
  cls: 'default',
  componentCls: 'x-ux-callout',
  floating: true,
  shadow: false,
  padding: 16,
  config: {
    /**
    		@cfg {Ext.Component} Target {@link Ext.Component} (optional).
    */

    target: null,
    /**
    		@cfg {String} Position relative to {@link #target} - see {@link Ext.Element#alignTo} for valid values.
    */

    relativePosition: 'c-c',
    /**
    		@cfg {Array} X and Y offset relative to {@link #target} (optional).
    */

    relativeOffsets: null,
    /**
    		@cfg {String} Callout arrow location - valid values: none, top, bottom, left, right, top-right, top-left, bottom-right, bottom-left, left-top, left-bottom, right-top, right-bottom
    */

    calloutArrowLocation: 'none',
    /**
    		@cfg {Number} Duration in milliseconds for the fade in animation when a callout is shown.
    */

    fadeInDuration: 200,
    /**
    		@cfg {Number} Duration in milliseconds for the fade out animation when a callout is hidden.
    */

    fadeOutDuration: 200,
    /**
    		@cfg {Boolean] Indicates whether to automatically hide the callout after a mouse click anywhere outside of the callout.
    */

    autoHide: true,
    /**
    		@cfg {Number} Duration in milliseconds to show the callout before automatically dismissing it.  A value of 0 will disable automatic dismissal.
    */

    dismissDelay: 0
  },
  /**
  	@protected
  	@property {Object} The dismissal timer id.
  */

  dismissTimer: null,
  /**
  	@inheritdoc
  */

  initComponent: function() {
    if (Ext.getVersion('extjs') && Ext.getVersion('extjs').isLessThan('4.1.0')) {
      Ext.applyIf(this, this.config);
    }
    return this.callParent(arguments);
  },
  /**
  	@inheritdoc
  */

  destroy: function() {
    this.clearTimers();
    return this.callParent(arguments);
  },
  /**
  	@inheritdoc
  */

  show: function() {
    var elementOrComponent;
    this.callParent(arguments);
    this.removeCls(['top', 'bottom', 'left', 'right', 'top-left', 'top-right', 'bottom-left', 'bottom-right', 'left-top', 'left-bottom', 'right-top', 'right-bottom']);
    if (this.getCalloutArrowLocation() !== 'none') {
      this.addCls(this.getCalloutArrowLocation());
    }
    if (this.getTarget() != null) {
      elementOrComponent = Ext.isString(this.getTarget()) ? Ext.ComponentQuery.query(this.getTarget())[0] : this.getTarget();
      this.getEl().anchorTo(elementOrComponent.el || elementOrComponent, this.getRelativePosition(), this.getRelativeOffsets() || [0, 0], false, 50, Ext.bind(function() {
        this.afterSetPosition(this.getEl().getLeft(), this.getEl().getRight());
      }, this));
    }
    if (!(this.dismissTimer != null) && this.getDismissDelay() > 0) {
      this.dismissTimer = Ext.defer(this.hide, this.getDismissDelay(), this);
    }
    return this;
  },
  /**
  	@inheritdoc
  */

  hide: function() {
    this.clearTimers();
    this.getEl().removeAnchor();
    return this.callParent(arguments);
  },
  /**
  	@protected
  	@method
  	Clear any timers that potentially be running.
  */

  clearTimers: function() {
    if (this.dismissTimer != null) {
      clearTimeout(this.dismissTimer);
    }
    this.dismissTimer = null;
  },
  /**
  	@inheritdoc
  */

  onShow: function() {
    this.callParent(arguments);
    this.mon(Ext.getDoc(), 'mousedown', this.onDocMouseDown, this);
    this.getEl().setOpacity(0.0);
    this.getEl().fadeIn({
      duration: this.getFadeInDuration()
    });
  },
  /**
  	@inheritdoc
  */

  onHide: function(animateTarget, cb, scope) {
    this.mun(Ext.getDoc(), 'mousedown', this.onDocMouseDown, this);
    this.getEl().fadeOut({
      duration: this.getFadeOutDuration(),
      callback: function() {
        this.getEl().hide();
        this.afterHide(cb, scope);
      },
      scope: this
    });
  },
  /**
  	@protected
  	Handles a 'mousedown' event on the current HTML document.
  */

  onDocMouseDown: function(event) {
    if (this.getAutoHide() && !event.within(this.getEl())) {
      this.hide();
    }
  }
});
