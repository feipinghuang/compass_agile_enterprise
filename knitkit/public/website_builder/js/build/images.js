(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function () {
	"use strict";

	require('./modules/ui');
	require('./modules/builder');
	require('./modules/config');
	require('./modules/imageLibrary');
	require('./modules/account');

}());
},{"./modules/account":2,"./modules/builder":3,"./modules/config":5,"./modules/imageLibrary":6,"./modules/ui":8}],2:[function(require,module,exports){
(function () {
	"use strict";

	var appUI = require('./ui.js').appUI;

	var account = {
        
        buttonUpdateAccountDetails: document.getElementById('accountDetailsSubmit'),
        buttonUpdateLoginDetails: document.getElementById('accountLoginSubmit'),
        
        init: function() {
            
            $(this.buttonUpdateAccountDetails).on('click', this.updateAccountDetails);
            $(this.buttonUpdateLoginDetails).on('click', this.updateLoginDetails);
                        
        },
        
        
        /*
            updates account details
        */
        updateAccountDetails: function() {
            
            //all fields filled in?
            
            var allGood = 1;
            
            if( $('#account_details input#firstname').val() === '' ) {
                $('#account_details input#firstname').closest('.form-group').addClass('has-error');
                allGood = 0;
            } else {
                $('#account_details input#firstname').closest('.form-group').removeClass('has-error');
                allGood = 1;
            }
            
            if( $('#account_details input#lastname').val() === '' ) {
                $('#account_details input#lastname').closest('.form-group').addClass('has-error');
                allGood = 0;
            } else {
                $('#account_details input#lastname').closest('.form-group').removeClass('has-error');
                allGood = 1;
            }
		
            if( allGood === 1 ) {

                var theButton = $(this);
                
                //disable button
                $(this).addClass('disabled');
                
                //show loader
                $('#account_details .loader').fadeIn(500);
                
                //remove alerts
                $('#account_details .alerts > *').remove();
                
                $.ajax({
                    url: appUI.siteUrl+"users/uaccount",
                    type: 'post',
                    dataType: 'json',
                    data: $('#account_details').serialize()
                }).done(function(ret){
                    
                    //enable button
                    theButton.removeClass('disabled');
                    
                    //hide loader
                    $('#account_details .loader').hide();
                    $('#account_details .alerts').append( $(ret.responseHTML) );

                    if( ret.responseCode === 1 ) {//success
                        setTimeout(function () { 
                            $('#account_details .alerts > *').fadeOut(500, function () { $(this).remove(); });
                        }, 3000);
                    }
                });

            }
            
        },
        
        
        /*
            updates account login details
        */
        updateLoginDetails: function() {
			
			console.log(appUI);
            
            var allGood = 1;
            
            if( $('#account_login input#email').val() === '' ) {
                $('#account_login input#email').closest('.form-group').addClass('has-error');
                allGood = 0;
            } else {
                $('#account_login input#email').closest('.form-group').removeClass('has-error');
                allGood = 1;
            }
            
            if( $('#account_login input#password').val() === '' ) {
                $('#account_login input#password').closest('.form-group').addClass('has-error');
                allGood = 0;
            } else {
                $('#account_login input#password').closest('.form-group').removeClass('has-error');
                allGood = 1;
            }
            
            if( allGood === 1 ) {
                
                var theButton = $(this);

                //disable button
                $(this).addClass('disabled');
                
                //show loader
                $('#account_login .loader').fadeIn(500);
                
                //remove alerts
                $('#account_login .alerts > *').remove();
                
                $.ajax({
                    url: appUI.siteUrl+"users/ulogin",
                    type: 'post',
                    dataType: 'json',
                    data: $('#account_login').serialize()
                }).done(function(ret){
                    
                    //enable button
                    theButton.removeClass('disabled');
                    
                    //hide loader
                    $('#account_login .loader').hide();
                    $('#account_login .alerts').append( $(ret.responseHTML) );
					
                    if( ret.responseCode === 1 ) {//success
                        setTimeout(function () { 
                            $('#account_login .alerts > *').fadeOut(500, function () { $(this).remove(); });
                        }, 3000);
                    }
                
                });
            
            }
            
        }
        
    };
    
    account.init();

}());
},{"./ui.js":8}],3:[function(require,module,exports){
(function () {
	"use strict";

    var siteBuilderUtils = require('./utils.js');
    var bConfig = require('./config.js');
    var appUI = require('./ui.js').appUI;


	 /*
        Basic Builder UI initialisation
    */
    var builderUI = {
        
        allBlocks: {},                                              //holds all blocks loaded from the server
        menuWrapper: document.getElementById('menu'),
        primarySideMenuWrapper: document.getElementById('main'),
        buttonBack: document.getElementById('backButton'),
        buttonBackConfirm: document.getElementById('leavePageButton'),
        
        siteBuilderModes: document.getElementById('siteBuilderModes'),
        aceEditors: {},
        frameContents: '',                                      //holds frame contents
        templateID: 0,                                          //holds the template ID for a page (???)
        radioBlockMode: document.getElementById('modeBlock'),
                
        modalDeleteBlock: document.getElementById('deleteBlock'),
        modalResetBlock: document.getElementById('resetBlock'),
        modalDeletePage: document.getElementById('deletePage'),
        buttonDeletePageConfirm: document.getElementById('deletePageConfirm'),
        
        dropdownPageLinks: document.getElementById('internalLinksDropdown'),
        
        tempFrame: {},
                
        init: function(){
                                                
            //load blocks
            $.getJSON(appUI.baseUrl+'elements.json?v=12345678', function(data){ builderUI.allBlocks = data; builderUI.implementBlocks(); });
            
            //sitebar hover animation action
            $(this.menuWrapper).on('mouseenter', function(){
                
                $(this).stop().animate({'left': '0px'}, 500);
                
            }).on('mouseleave', function(){
                
                $(this).stop().animate({'left': '-190px'}, 500);
                
                $('#menu #main a').removeClass('active');
                $('.menu .second').stop().animate({
                    width: 0
                }, 500, function(){
                    $('#menu #second').hide();
                });
                
            });
            
            //prevent click event on ancors in the block section of the sidebar
            $(this.primarySideMenuWrapper).on('click', 'a:not(.actionButtons)', function(e){e.preventDefault();});
            
            $(this.buttonBack).on('click', this.backButton);
            $(this.buttonBackConfirm).on('click', this.backButtonConfirm);
            
            //notify the user of pending chnages when clicking the back button
            $(window).bind('beforeunload', function(){
                if( site.pendingChanges === true ) {
                    return 'Your site contains changed which haven\'t been saved yet. Are you sure you want to leave?';
                }
            });
                                                
            //make sure we start in block mode
            $(this.radioBlockMode).radiocheck('check').on('click', this.activateBlockMode);
            
        },
        
        
        /*
            builds the blocks into the site bar
        */
        implementBlocks: function() {

            var newItem, loaderFunction;
            
            for( var key in this.allBlocks.elements ) {
                
                var niceKey = key.toLowerCase().replace(" ", "_");
                
                $('<li><a href="" id="'+niceKey+'">'+key+'</a></li>').appendTo('#menu #main ul#elementCats');
                
                for( var x = 0; x < this.allBlocks.elements[key].length; x++ ) {
                    
                    if( this.allBlocks.elements[key][x].thumbnail === null ) {//we'll need an iframe
                        
                        //build us some iframes!
                        
                        if( this.allBlocks.elements[key][x].sandbox !== null ) {
                            
                            if( this.allBlocks.elements[key][x].loaderFunction !== null ) {
                                loaderFunction = 'data-loaderfunction="'+this.allBlocks.elements[key][x].loaderFunction+'"';
                            }
                            
                            newItem = $('<li class="element '+niceKey+'"><iframe src="'+appUI.baseUrl+this.allBlocks.elements[key][x].url+'" scrolling="no" sandbox="allow-same-origin"></iframe></li>');
                        
                        } else {
                            
                            newItem = $('<li class="element '+niceKey+'"><iframe src="about:blank" scrolling="no"></iframe></li>');
                        
                        }
                        
                        newItem.find('iframe').uniqueId();
                        newItem.find('iframe').attr('src', appUI.baseUrl+this.allBlocks.elements[key][x].url);
                    
                    } else {//we've got a thumbnail
                        
                        if( this.allBlocks.elements[key][x].sandbox !== null ) {
                            
                            if( this.allBlocks.elements[key][x].loaderFunction !== null ) {
                                loaderFunction = 'data-loaderfunction="'+this.allBlocks.elements[key][x].loaderFunction+'"';
                            }
                            
                            newItem = $('<li class="element '+niceKey+'"><img src="'+appUI.baseUrl+this.allBlocks.elements[key][x].thumbnail+'" data-srcc="'+appUI.baseUrl+this.allBlocks.elements[key][x].url+'" data-height="'+this.allBlocks.elements[key][x].height+'" data-sandbox="" '+loaderFunction+'></li>');
                            
                        } else {
                                
                            newItem = $('<li class="element '+niceKey+'"><img src="'+appUI.baseUrl+this.allBlocks.elements[key][x].thumbnail+'" data-srcc="'+appUI.baseUrl+this.allBlocks.elements[key][x].url+'" data-height="'+this.allBlocks.elements[key][x].height+'"></li>');
                                
                        }
                    }
                    
                    newItem.appendTo('#menu #second ul#elements');
            
                    //zoomer works

                    var theHeight;
                    
                    if( this.allBlocks.elements[key][x].height ) {
                        
                        theHeight = this.allBlocks.elements[key][x].height*0.25;
                    
                    } else {
                        
                        theHeight = 'auto';
                        
                    }
                    
                    newItem.find('iframe').zoomer({
                        zoom: 0.25,
                        width: 270,
                        height: theHeight,
                        message: "Drag&Drop Me!"
                    });
                
                }
            
            }
            
            //draggables
            builderUI.makeDraggable();
            
        },
                
        
        /*
            event handler for when the back link is clicked
        */
        backButton: function() {
            
            if( site.pendingChanges === true ) {
                $('#backModal').modal('show');
                return false;
            }
            
        },
        
        
        /*
            button for confirming leaving the page
        */
        backButtonConfirm: function() {
            
            site.pendingChanges = false;//prevent the JS alert after confirming user wants to leave
            
        },
        
        
        /*
            activates block mode
        */
        activateBlockMode: function() {
                        
            site.activePage.toggleFrameCovers('On');
            
            //trigger custom event
            $('body').trigger('modeBlocks');
            
        },
        
       
        /*
            makes the blocks and templates in the sidebar draggable onto the canvas
        */
        makeDraggable: function() {
                        
            $('#elements li, #templates li').each(function(){

                $(this).draggable({
                    helper: function() {
                        return $('<div style="height: 100px; width: 300px; background: #F9FAFA; box-shadow: 5px 5px 1px rgba(0,0,0,0.1); text-align: center; line-height: 100px; font-size: 28px; color: #16A085"><span class="fui-list"></span></div>');
                    },
                    revert: 'invalid',
                    appendTo: 'body',
                    connectToSortable: '#pageList > ul',
                    start: function(){

                        //switch to block mode
                        $('input:radio[name=mode]').parent().addClass('disabled');
                        $('input:radio[name=mode]#modeBlock').radiocheck('check');
                    
                    }
                
                }); 
            
            });
            
            $('#elements li a').each(function(){
                
                $(this).unbind('click').bind('click', function(e){
                    e.preventDefault();
                });
            
            });
            
        },
        
        
        /*
            Implements the site on the canvas, called from the Site object when the siteData has completed loading
        */
        populateCanvas: function() {

            var i;
                                    
            //if we have any blocks at all, activate the modes
            if( Object.keys(site.pages).length > 0 ) {
                var modes = builderUI.siteBuilderModes.querySelectorAll('input[type="radio"]');
                for( i = 0; i < modes.length; i++ ) {
                    modes[i].removeAttribute('disabled'); 
                }
            }
            
            var counter = 1;
                        
            //loop through the pages
                                    
            for( i in site.pages ) {
                
                var newPage = new Page(i, site.pages[i], counter);
                                            
                counter++;
                                
            }
            
            //activate the first page
            if(site.sitePages.length > 0) {
                site.sitePages[0].selectPage();
            }
                                    
        }
        
    };


    /*
        Page constructor
    */
    function Page (pageName, page, counter) {
    
        this.name = pageName || "";
        this.pageID = page.pages_id || 0;
        this.blocks = [];
        this.parentUL = {}; //parent UL on the canvas
        this.status = '';//'', 'new' or 'changed'
        this.scripts = [];//tracks script URLs used on this page
        
        this.pageSettings = {
            title: page.pages_title || '',
            meta_description: page.meta_description || '',
            meta_keywords: page.meta_keywords || '',
            header_includes: page.header_includes || '',
            page_css: page.page_css || ''
        };
                
        this.pageMenuTemplate = '<a href="" class="menuItemLink">page</a><span class="pageButtons"><a href="" class="fileEdit fui-new"></a><a href="" class="fileDel fui-cross"><a class="btn btn-xs btn-primary btn-embossed fileSave fui-check" href="#"></a></span></a></span>';
        
        this.menuItem = {};//reference to the pages menu item for this page instance
        this.linksDropdownItem = {};//reference to the links dropdown item for this page instance
        
        this.parentUL = document.createElement('UL');
        this.parentUL.setAttribute('id', "page"+counter);
                
        /*
            makes the clicked page active
        */
        this.selectPage = function() {
            
            //console.log('select:');
            //console.log(this.pageSettings);
                        
            //mark the menu item as active
            site.deActivateAll();
            $(this.menuItem).addClass('active');
                        
            //let Site know which page is currently active
            site.setActive(this);
            
            //display the name of the active page on the canvas
            site.pageTitle.innerHTML = this.name;
            
            //load the page settings into the page settings modal
            site.inputPageSettingsTitle.value = this.pageSettings.title;
            site.inputPageSettingsMetaDescription.value = this.pageSettings.meta_description;
            site.inputPageSettingsMetaKeywords.value = this.pageSettings.meta_keywords;
            site.inputPageSettingsIncludes.value = this.pageSettings.header_includes;
            site.inputPageSettingsPageCss.value = this.pageSettings.page_css;
                          
            //trigger custom event
            $('body').trigger('changePage');
            
            //reset the heights for the blocks on the current page
            for( var i in this.blocks ) {
                
                if( Object.keys(this.blocks[i].frameDocument).length > 0 ){
                    this.blocks[i].heightAdjustment();
                }
            
            }
            
            //show the empty message?
            this.isEmpty();
                                    
        };
        
        /*
            changed the location/order of a block within a page
        */
        this.setPosition = function(frameID, newPos) {
            
            //we'll need the block object connected to iframe with frameID
            
            for(var i in this.blocks) {
                
                if( this.blocks[i].frame.getAttribute('id') === frameID ) {
                    
                    //change the position of this block in the blocks array
                    this.blocks.splice(newPos, 0, this.blocks.splice(i, 1)[0]);
                    
                }
                
            }
                        
        };
        
        /*
            delete block from blocks array
        */
        this.deleteBlock = function(block) {
            
            //remove from blocks array
            for( var i in this.blocks ) {
                if( this.blocks[i] === block ) {
                    //found it, remove from blocks array
                    this.blocks.splice(i, 1);
                }
            }
            
            site.setPendingChanges(true);
            
        };
        
        /*
            toggles all block frameCovers on this page
        */
        this.toggleFrameCovers = function(onOrOff) {
            
            for( var i in this.blocks ) {
                                 
                this.blocks[i].toggleCover(onOrOff);
                
            }
            
        };
        
        /*
            setup for editing a page name
        */
        this.editPageName = function() {
            
            if( !this.menuItem.classList.contains('edit') ) {
            
                //hide the link
                this.menuItem.querySelector('a.menuItemLink').style.display = 'none';
            
                //insert the input field
                var newInput = document.createElement('input');
                newInput.type = 'text';
                newInput.setAttribute('name', 'page');
                newInput.setAttribute('value', this.name);
                this.menuItem.insertBefore(newInput, this.menuItem.firstChild);
                    
                newInput.focus();
        
                var tmpStr = newInput.getAttribute('value');
                newInput.setAttribute('value', '');
                newInput.setAttribute('value', tmpStr);
                            
                this.menuItem.classList.add('edit');
            
            }
            
        };
        
        /*
            Updates this page's name (event handler for the save button)
        */
        this.updatePageNameEvent = function(el) {
            
            if( this.menuItem.classList.contains('edit') ) {
            
                //el is the clicked button, we'll need access to the input
                var theInput = this.menuItem.querySelector('input[name="page"]');
                
                //make sure the page's name is OK
                if( site.checkPageName(theInput.value) ) {
                   
                    this.name = site.prepPageName( theInput.value );
            
                    this.menuItem.querySelector('input[name="page"]').remove();
                    this.menuItem.querySelector('a.menuItemLink').innerHTML = this.name;
                    this.menuItem.querySelector('a.menuItemLink').style.display = 'block';
            
                    this.menuItem.classList.remove('edit');
                
                    //update the links dropdown item
                    this.linksDropdownItem.text = this.name;
                    this.linksDropdownItem.setAttribute('value', this.name+".html");
                    
                    //update the page name on the canvas
                    site.pageTitle.innerHTML = this.name;
            
                    //changed page title, we've got pending changes
                    site.setPendingChanges(true);
                                        
                } else {
                    
                    alert(site.pageNameError);
                    
                }
                                        
            }
            
        };
        
        /*
            deletes this entire page
        */
        this.delete = function() {
                        
            //delete from the Site
            for( var i in site.sitePages ) {
                
                if( site.sitePages[i] === this ) {//got a match!
                    
                    //delete from site.sitePages
                    site.sitePages.splice(i, 1);
                    
                    //delete from canvas
                    this.parentUL.remove();
                    
                    //add to deleted pages
                    site.pagesToDelete.push(this.name);
                    
                    //delete the page's menu item
                    this.menuItem.remove();
                    
                    //delet the pages link dropdown item
                    this.linksDropdownItem.remove();
                    
                    //activate the first page
                    site.sitePages[0].selectPage();
                    
                    //page was deleted, so we've got pending changes
                    site.setPendingChanges(true);
                    
                }
                
            }
                        
        };
        
        /*
            checks if the page is empty, if so show the 'empty' message
        */
        this.isEmpty = function() {
            
            if( this.blocks.length === 0 ) {
                
                site.messageStart.style.display = 'block';
                site.divFrameWrapper.classList.add('empty');
                             
            } else {
                
                site.messageStart.style.display = 'none';
                site.divFrameWrapper.classList.remove('empty');
                
            }
                        
        };
            
        /*
            preps/strips this page data for a pending ajax request
        */
        this.prepForSave = function() {
            
            var page = {};
                    
            page.name = this.name;
            page.pageSettings = this.pageSettings;
            page.status = this.status;
            page.blocks = [];
                    
            //process the blocks
                    
            for( var x = 0; x < this.blocks.length; x++ ) {
                        
                var block = {};
                        
                if( this.blocks[x].sandbox ) {
                            
                    block.frameContent = "<html>"+$('#sandboxes #'+this.blocks[x].sandbox).contents().find('html').html()+"</html>";
                    block.sandbox = true;
                    block.loaderFunction = this.blocks[x].sandbox_loader;
                            
                } else {
                                                        
                    block.frameContent = this.blocks[x].getSource();
                    block.sandbox = false;
                    block.loaderFunction = '';
                            
                }
                        
                block.frameHeight = this.blocks[x].frameHeight;
                block.originalUrl = this.blocks[x].originalUrl;
                                                                
                page.blocks.push(block);
                        
            }
            
            return page;
            
        };
            
        /*
            generates the full page, using skeleton.html
        */
        this.fullPage = function() {
            
            var page = this;//reference to self for later
            page.scripts = [];//make sure it's empty, we'll store script URLs in there later
                        
            var newDocMainParent = $('iframe#skeleton').contents().find( bConfig.pageContainer );
            
            //empty out the skeleton first
            $('iframe#skeleton').contents().find( bConfig.pageContainer ).html('');
            
            //remove old script tags
            $('iframe#skeleton').contents().find( 'script' ).each(function(){
                $(this).remove();
            });

            var theContents;
                        
            for( var i in this.blocks ) {
                
                //grab the block content
                if (this.blocks[i].sandbox !== false) {
                                
                    theContents = $('#sandboxes #'+this.blocks[i].sandbox).contents().find( bConfig.pageContainer ).clone();
                            
                } else {
                                
                    theContents = $(this.blocks[i].frameDocument.body).find( bConfig.pageContainer ).clone();
                            
                }
                                
                //remove video frameCovers
                theContents.find('.frameCover').each(function () {
                    $(this).remove();
                });
                
                //remove video frameWrappers
                theContents.find('.videoWrapper').each(function(){
                    
                    var cnt = $(this).contents();
                    $(this).replaceWith(cnt);
                    
                });
                
                //remove style leftovers from the style editor
                for( var key in bConfig.editableItems ) {
                                                                
                    theContents.find( key ).each(function(){
                                                                        
                        $(this).removeAttr('data-selector');
                        
                        $(this).css('outline', '');
                        $(this).css('outline-offset', '');
                        $(this).css('cursor', '');
                                                                        
                        if( $(this).attr('style') === '' ) {
                                        
                            $(this).removeAttr('style');
                                    
                        }
                                
                    });
                            
                }
                
                //remove style leftovers from the content editor
                for ( var x = 0; x < bConfig.editableContent.length; ++x) {
                                
                    theContents.find( bConfig.editableContent[x] ).each(function(){
                                    
                        $(this).removeAttr('data-selector');
                                
                    });
                            
                }
                
                //append to DOM in the skeleton
                newDocMainParent.append( $(theContents.html()) );
                
                //do we need to inject any scripts?
                var scripts = $(this.blocks[i].frameDocument.body).find('script');
                var theIframe = document.getElementById("skeleton");
                                            
                if( scripts.size() > 0 ) {
                                
                    scripts.each(function(){

                        var script;
                                    
                        if( $(this).text() !== '' ) {//script tags with content
                                        
                            script = theIframe.contentWindow.document.createElement("script");
                            script.type = 'text/javascript';
                            script.innerHTML = $(this).text();
                                        
                            theIframe.contentWindow.document.body.appendChild(script);
                                    
                        } else if( $(this).attr('src') !== null && page.scripts.indexOf($(this).attr('src')) === -1 ) {
                            //use indexOf to make sure each script only appears on the produced page once
                                        
                            script = theIframe.contentWindow.document.createElement("script");
                            script.type = 'text/javascript';
                            script.src = $(this).attr('src');
                                        
                            theIframe.contentWindow.document.body.appendChild(script);
                            
                            page.scripts.push($(this).attr('src'));
                                    
                        }
                                
                    });
                            
                }
            
            }
            
            console.log(this.scripts);
            
        };
            
        /*
            clear out this page
        */
        this.clear = function() {
            
            var block = this.blocks.pop();
            
            while( block !== undefined ) {
                
                block.delete();
                
                block = this.blocks.pop();
                
            }
                                    
        };
         
        
        //loop through the frames/blocks
        
        if( page.hasOwnProperty('blocks') ) {
        
            for( var x = 0; x < page.blocks.length; x++ ) {
            
                //create new Block
            
                var newBlock = new Block();
            
                page.blocks[x].src = appUI.siteUrl+"sites/getframe/"+page.blocks[x].frames_id;
                
                //sandboxed block?
                if( page.blocks[x].frames_sandbox === '1') {
                                        
                    newBlock.sandbox = true;
                    newBlock.sandbox_loader = page.blocks[x].frames_loaderfunction;
                
                }
                        
                newBlock.frameID = page.blocks[x].frames_id;
                newBlock.createParentLI(page.blocks[x].frames_height);
                newBlock.createFrame(page.blocks[x]);
                newBlock.createFrameCover();
                newBlock.insertBlockIntoDom(this.parentUL);
                                                                    
                //add the block to the new page
                this.blocks.push(newBlock);
                                        
            }
            
        }
        
        //add this page to the site object
        site.sitePages.push( this );
        
        //plant the new UL in the DOM (on the canvas)
        site.divCanvas.appendChild(this.parentUL);
        
        //make the blocks/frames in each page sortable
        
        var thePage = this;
        
        $(this.parentUL).sortable({
            revert: true,
            placeholder: "drop-hover",
            beforeStop: function(event, ui){
                
                //template or regular block?
                var attr = ui.item.attr('data-frames');

                var newBlock;
                    
                if (typeof attr !== typeof undefined && attr !== false) {//template, build it
                 
                    $('#start').hide();
                                        
                    //clear out all blocks on this page    
                    thePage.clear();
                                            
                    //create the new frames
                    var frameIDs = ui.item.attr('data-frames').split('-');
                    var heights = ui.item.attr('data-heights').split('-');
                    var urls = ui.item.attr('data-originalurls').split('-');
                        
                    for( var x = 0; x < frameIDs.length; x++) {
                                                
                        newBlock = new Block();
                        newBlock.createParentLI(heights[x]);
                        
                        var frameData = {};
                        
                        frameData.src = appUI.siteUrl+'sites/getframe/'+frameIDs[x];
                        frameData.frames_original_url = appUI.siteUrl+'sites/getframe/'+frameIDs[x];
                        frameData.frames_height = heights[x];
                        
                        newBlock.createFrame( frameData );
                        newBlock.createFrameCover();
                        newBlock.insertBlockIntoDom(thePage.parentUL);
                        
                        //add the block to the new page
                        thePage.blocks.push(newBlock);
                        
                        //dropped element, so we've got pending changes
                        site.setPendingChanges(true);
                            
                    }
                
                    //set the tempateID
                    builderUI.templateID = ui.item.attr('data-pageid');
                                                                                    
                    //make sure nothing gets dropped in the lsit
                    ui.item.html(null);
                        
                    //delete drag place holder
                    $('body .ui-sortable-helper').remove();
                    
                } else {//regular block
                
                    //are we dealing with a new block being dropped onto the canvas, or a reordering og blocks already on the canvas?
                
                    if( ui.item.find('.frameCover > button').size() > 0 ) {//re-ordering of blocks on canvas
                    
                        //no need to create a new block object, we simply need to make sure the position of the existing block in the Site object
                        //is changed to reflect the new position of the block on th canvas
                    
                        var frameID = ui.item.find('iframe').attr('id');
                        var newPos = ui.item.index();
                    
                        site.activePage.setPosition(frameID, newPos);
                                        
                    } else {//new block on canvas
                                                
                        //new block                    
                        newBlock = new Block();
                                
                        newBlock.placeOnCanvas(ui);
                                    
                    }
                    
                }
                
            },
            start: function(event, ui){
                    
                if( ui.item.find('.frameCover').size() !== 0 ) {
                    builderUI.frameContents = ui.item.find('iframe').contents().find( bConfig.pageContainer ).html();
                }
            
            },
            over: function(){
                    
                $('#start').hide();
                
            }
        });
        
        //add to the pages menu
        this.menuItem = document.createElement('LI');
        this.menuItem.innerHTML = this.pageMenuTemplate;
        
        $(this.menuItem).find('a:first').text(pageName).attr('href', '#page'+counter);
        
        var theLink = $(this.menuItem).find('a:first').get(0);
        
        //bind some events
        this.menuItem.addEventListener('click', this, false);
        
        this.menuItem.querySelector('a.fileEdit').addEventListener('click', this, false);
        this.menuItem.querySelector('a.fileSave').addEventListener('click', this, false);
        this.menuItem.querySelector('a.fileDel').addEventListener('click', this, false);
        
        //add to the page link dropdown
        this.linksDropdownItem = document.createElement('OPTION');
        this.linksDropdownItem.setAttribute('value', pageName+".html");
        this.linksDropdownItem.text = pageName;
                
        builderUI.dropdownPageLinks.appendChild( this.linksDropdownItem );
        
        site.pagesMenu.appendChild(this.menuItem);
                    
    }
    
    Page.prototype.handleEvent = function(event) {
        switch (event.type) {
            case "click": 
                                
                if( event.target.classList.contains('fileEdit') ) {
                
                    this.editPageName();
                    
                } else if( event.target.classList.contains('fileSave') ) {
                                        
                    this.updatePageNameEvent(event.target);
                
                } else if( event.target.classList.contains('fileDel') ) {
                    
                    var thePage = this;
                
                    $(builderUI.modalDeletePage).modal('show');
                    
                    $(builderUI.modalDeletePage).off('click', '#deletePageConfirm').on('click', '#deletePageConfirm', function() {
                        
                        thePage.delete();
                        
                        $(builderUI.modalDeletePage).modal('hide');
                        
                    });
                                        
                } else {
                    
                    this.selectPage();
                
                }
                
        }
    };


    /*
        Block constructor
    */
    function Block () {
        
        this.frameID = 0;
        this.sandbox = false;
        this.sandbox_loader = '';
        this.status = '';//'', 'changed' or 'new'
        this.originalUrl = '';
        
        this.parentLI = {};
        this.frameCover = {};
        this.frame = {};
        this.frameDocument = {};
        this.frameHeight = 0;
        
        this.annot = {};
        this.annotTimeout = {};
        
        /*
            creates the parent container (LI)
        */
        this.createParentLI = function(height) {
            
            this.parentLI = document.createElement('LI');
            this.parentLI.setAttribute('class', 'element');
            //this.parentLI.setAttribute('style', 'height: '+height+'px');
            
        };
        
        /*
            creates the iframe on the canvas
        */
        this.createFrame = function(frame) {
                        
            this.frame = document.createElement('IFRAME');
            this.frame.setAttribute('frameborder', 0);
            this.frame.setAttribute('scrolling', 0);
            this.frame.setAttribute('src', frame.src);
            this.frame.setAttribute('data-originalurl', frame.frames_original_url);
            this.originalUrl = frame.frames_original_url;
            //this.frame.setAttribute('data-height', frame.frames_height);
            //this.frameHeight = frame.frames_height;
            this.frame.setAttribute('style', 'background: '+"#ffffff url('"+appUI.baseUrl+"images/loading.gif') 50% 50% no-repeat");
                        
            $(this.frame).uniqueId();
            
            //sandbox?
            if( this.sandbox !== false ) {
                            
                this.frame.setAttribute('data-loaderfunction', this.sandbox_loader);
                this.frame.setAttribute('data-sandbox', this.sandbox);
                            
                //recreate the sandboxed iframe elsewhere
                var sandboxedFrame = $('<iframe src="'+frame.src+'" id="'+this.sandbox+'" sandbox="allow-same-origin"></iframe>');
                $('#sandboxes').append( sandboxedFrame );
                            
            }
                        
        };
            
        /*
            insert the iframe into the DOM on the canvas
        */
        this.insertBlockIntoDom = function(theUL) {
            
            this.parentLI.appendChild(this.frame);
            theUL.appendChild( this.parentLI );
            
            this.frame.addEventListener('load', this, false);
            
        };
            
        /*
            sets the frame document for the block's iframe
        */
        this.setFrameDocument = function() {
            
            //set the frame document as well
            if( this.frame.contentDocument ) {
                this.frameDocument = this.frame.contentDocument;   
            } else {
                this.frameDocument = this.frame.contentWindow.document;
            }
            
            //this.heightAdjustment();
                                    
        };
        
        /*
            creates the frame cover and block action button
        */
        this.createFrameCover = function() {
            
            //build the frame cover and block action buttons
            this.frameCover = document.createElement('DIV');
            this.frameCover.classList.add('frameCover');
            this.frameCover.classList.add('fresh');
            this.frameCover.style.height = this.frameHeight+"px";
                    
            var delButton = document.createElement('BUTTON');
            delButton.setAttribute('class', 'btn btn-danger deleteBlock');
            delButton.setAttribute('type', 'button');
            delButton.innerHTML = '<span class="fui-trash"></span> remove';
            delButton.addEventListener('click', this, false);
                    
            var resetButton = document.createElement('BUTTON');
            resetButton.setAttribute('class', 'btn btn-warning resetBlock');
            resetButton.setAttribute('type', 'button');
            resetButton.innerHTML = '<i class="fa fa-refresh"></i> reset';
            resetButton.addEventListener('click', this, false);
                    
            var htmlButton = document.createElement('BUTTON');
            htmlButton.setAttribute('class', 'btn btn-inverse htmlBlock');
            htmlButton.setAttribute('type', 'button');
            htmlButton.innerHTML = '<i class="fa fa-code"></i> source';
            htmlButton.addEventListener('click', this, false);
                    
            this.frameCover.appendChild(delButton);
            this.frameCover.appendChild(resetButton);
            this.frameCover.appendChild(htmlButton);
                            
            this.parentLI.appendChild(this.frameCover);
                                                        
        };
            
        /*
            automatically corrects the height of the block's iframe depending on its content
        */
        this.heightAdjustment = function() {
            
            var pageContainer = this.frameDocument.body.querySelector( bConfig.pageContainer );
            var height = pageContainer.scrollHeight;
                                               
            this.frame.style.height = height+"px";
            this.parentLI.style.height = height+"px";
            this.frameCover.style.height = height+"px";
            
            this.frameHeight = height;
                                                                                    
        };
            
        /*
            deletes a block
        */
        this.delete = function() {
                        
            //remove from DOM/canvas with a nice animation
            $(this.frame.parentNode).fadeOut(500, function(){
                    
                this.remove();
                    
                site.activePage.isEmpty();
                
            });
            
            //remove from blocks array in the active page
            site.activePage.deleteBlock(this);
            
            //sanbox
            if( this.sanbdox ) {
                document.getElementById( this.sandbox ).remove();   
            }
            
            //element was deleted, so we've got pending change
            site.setPendingChanges(true);
                        
        };
            
        /*
            resets a block to it's orignal state
        */
        this.reset = function() {
            
            //reset frame by reloading it
            this.frame.contentWindow.location.reload();
            
            //sandbox?
            if( this.sandbox ) {
                var sandboxFrame = document.getElementById(this.sandbox).contentWindow.location.reload();  
            }
            
            //element was deleted, so we've got pending changes
            site.setPendingChanges(true);
            
        };
            
        /*
            launches the source code editor
        */
        this.source = function() {
            
            //hide the iframe
            this.frame.style.display = 'none';
            
            //disable sortable on the parentLI
            $(this.parentLI.parentNode).sortable('disable');
            
            //built editor element
            var theEditor = document.createElement('DIV');
            theEditor.classList.add('aceEditor');
            $(theEditor).uniqueId();
            
            this.parentLI.appendChild(theEditor);
            
            //build and append error drawer
            var newLI = document.createElement('LI');
            var errorDrawer = document.createElement('DIV');
            errorDrawer.classList.add('errorDrawer');
            errorDrawer.setAttribute('id', 'div_errorDrawer');
            errorDrawer.innerHTML = '<button type="button" class="btn btn-xs btn-embossed btn-default button_clearErrorDrawer" id="button_clearErrorDrawer">CLEAR</button>';
            newLI.appendChild(errorDrawer);
            errorDrawer.querySelector('button').addEventListener('click', this, false);
            this.parentLI.parentNode.insertBefore(newLI, this.parentLI.nextSibling);
            
            
            var theId = theEditor.getAttribute('id');
            var editor = ace.edit( theId );
            
            var pageContainer = this.frameDocument.querySelector( bConfig.pageContainer );
            var theHTML = pageContainer.innerHTML;
            
            editor.setValue( theHTML );
            editor.setTheme("ace/theme/twilight");
            editor.getSession().setMode("ace/mode/html");
            
            var block = this;
            
            
            editor.getSession().on("changeAnnotation", function(){
                
                block.annot = editor.getSession().getAnnotations();
                
                clearTimeout(block.annotTimeout);

                var timeoutCount;
                
                if( $('#div_errorDrawer p').size() === 0 ) {
                    timeoutCount = bConfig.sourceCodeEditSyntaxDelay;
                } else {
                    timeoutCount = 100;
                }
                
                block.annotTimeout = setTimeout(function(){
                                                            
                    for (var key in block.annot){
                    
                        if (block.annot.hasOwnProperty(key)) {
                        
                            if( block.annot[key].text !== "Start tag seen without seeing a doctype first. Expected e.g. <!DOCTYPE html>." ) {
                            
                                var newLine = $('<p></p>');
                                var newKey = $('<b>'+block.annot[key].type+': </b>');
                                var newInfo = $('<span> '+block.annot[key].text + "on line " + " <b>" + block.annot[key].row+'</b></span>');
                                newLine.append( newKey );
                                newLine.append( newInfo );
                    
                                $('#div_errorDrawer').append( newLine );
                        
                            }
                    
                        }
                
                    }
                
                    if( $('#div_errorDrawer').css('display') === 'none' && $('#div_errorDrawer').find('p').size() > 0 ) {
                        $('#div_errorDrawer').slideDown();
                    }
                        
                }, timeoutCount);
                
            
            });
            
            //buttons
            var cancelButton = document.createElement('BUTTON');
            cancelButton.setAttribute('type', 'button');
            cancelButton.classList.add('btn');
            cancelButton.classList.add('btn-danger');
            cancelButton.classList.add('editCancelButton');
            cancelButton.classList.add('btn-wide');
            cancelButton.innerHTML = '<span class="fui-cross"></span> Cancel';
            cancelButton.addEventListener('click', this, false);
            
            var saveButton = document.createElement('BUTTON');
            saveButton.setAttribute('type', 'button');
            saveButton.classList.add('btn');
            saveButton.classList.add('btn-primary');
            saveButton.classList.add('editSaveButton');
            saveButton.classList.add('btn-wide');
            saveButton.innerHTML = '<span class="fui-check"></span> Save';
            saveButton.addEventListener('click', this, false);
            
            var buttonWrapper = document.createElement('DIV');
            buttonWrapper.classList.add('editorButtons');
            
            buttonWrapper.appendChild( cancelButton );
            buttonWrapper.appendChild( saveButton );
            
            this.parentLI.appendChild( buttonWrapper );
            
            builderUI.aceEditors[ theId ] = editor;
            
        };
            
        /*
            cancels the block source code editor
        */
        this.cancelSourceBlock = function() {

            //enable draggable on the LI
            $(this.parentLI.parentNode).sortable('enable');
		
            //delete the errorDrawer
            $(this.parentLI.nextSibling).remove();
        
            //delete the editor
            this.parentLI.querySelector('.aceEditor').remove();
            $(this.frame).fadeIn(500);
                        
            $(this.parentLI.querySelector('.editorButtons')).fadeOut(500, function(){
                $(this).remove();
            });
            
        };
            
        /*
            updates the blocks source code
        */
        this.saveSourceBlock = function() {
            
            //enable draggable on the LI
            $(this.parentLI.parentNode).sortable('enable');
            
            var theId = this.parentLI.querySelector('.aceEditor').getAttribute('id');
            var theContent = builderUI.aceEditors[theId].getValue();
            
            //delete the errorDrawer
            document.getElementById('div_errorDrawer').parentNode.remove();
            
            //delete the editor
            this.parentLI.querySelector('.aceEditor').remove();
            
            //update the frame's content
            this.frameDocument.querySelector( bConfig.pageContainer ).innerHTML = theContent;
            this.frame.style.display = 'block';
            
            //sandboxed?
            if( this.sandbox ) {
                
                var sandboxFrame = document.getElementById( this.sandbox );
                var sandboxFrameDocument = sandboxFrame.contentDocument || sandboxFrame.contentWindow.document;
                
                builderUI.tempFrame = sandboxFrame;
                
                sandboxFrameDocument.querySelector( bConfig.pageContainer ).innerHTML = theContent;
                                
                //do we need to execute a loader function?
                if( this.sandbox_loader !== '' ) {
                    
                    /*
                    var codeToExecute = "sandboxFrame.contentWindow."+this.sandbox_loader+"()";
                    var tmpFunc = new Function(codeToExecute);
                    tmpFunc();
                    */
                    
                }
                
            }
            
            $(this.parentLI.querySelector('.editorButtons')).fadeOut(500, function(){
                $(this).remove();
            });
            
            //adjust height of the frame
            this.heightAdjustment();
            
            //new page added, we've got pending changes
            site.setPendingChanges(true);
            
            //block has changed
            this.status = 'changed';

        };
            
        /*
            clears out the error drawer
        */
        this.clearErrorDrawer = function() {
            
            var ps = this.parentLI.nextSibling.querySelectorAll('p');
                        
            for( var i = 0; i < ps.length; i++ ) {
                ps[i].remove();  
            }
                        
        };
            
        /*
            toggles the visibility of this block's frameCover
        */
        this.toggleCover = function(onOrOff) {
            
            if( onOrOff === 'On' ) {
                
                this.parentLI.querySelector('.frameCover').style.display = 'block';
                
            } else if( onOrOff === 'Off' ) {
             
                this.parentLI.querySelector('.frameCover').style.display = 'none';
                
            }
            
        };
            
        /*
            returns the full source code of the block's frame
        */
        this.getSource = function() {
            
            var source = "<html>";
            source += this.frameDocument.head.outerHTML;
            source += this.frameDocument.body.outerHTML;
            
            return source;
            
        };
            
        /*
            places a dragged/dropped block from the left sidebar onto the canvas
        */
        this.placeOnCanvas = function(ui) {
            
            //frame data, we'll need this before messing with the item's content HTML
            var frameData = {}, attr;
                
            if( ui.item.find('iframe').size() > 0 ) {//iframe thumbnail
                    
                frameData.src = ui.item.find('iframe').attr('src');
                frameData.frames_original_url = ui.item.find('iframe').attr('src');
                frameData.frames_height = ui.item.height();
                    
                //sandboxed block?
                attr = ui.item.find('iframe').attr('sandbox');
                                
                if (typeof attr !== typeof undefined && attr !== false) {
                    this.sandbox = siteBuilderUtils.getRandomArbitrary(10000, 1000000000);
                    this.sandbox_loader = ui.item.find('iframe').attr('data-loaderfunction');
                }
                                        
            } else {//image thumbnail
                    
                frameData.src = ui.item.find('img').attr('data-srcc');
                frameData.frames_original_url = ui.item.find('img').attr('data-srcc');
                frameData.frames_height = ui.item.find('img').attr('data-height');
                                    
                //sandboxed block?
                attr = ui.item.find('img').attr('data-sandbox');
                                
                if (typeof attr !== typeof undefined && attr !== false) {
                    this.sandbox = siteBuilderUtils.getRandomArbitrary(10000, 1000000000);
                    this.sandbox_loader = ui.item.find('img').attr('data-loaderfunction');
                }
                    
            }                
                                
            //create the new block object
            this.frameID = 0;
            this.parentLI = ui.item.get(0);
            this.parentLI.innerHTML = '';
            this.status = 'new';
            this.createFrame(frameData);
            this.parentLI.style.height = this.frameHeight+"px";
            this.createFrameCover();
                
            this.frame.addEventListener('load', this);
                
            //insert the created iframe
            ui.item.append($(this.frame));
                                           
            //add the block to the current page
            site.activePage.blocks.splice(ui.item.index(), 0, this);
                
            //custom event
            ui.item.find('iframe').trigger('canvasupdated');
                                
            //dropped element, so we've got pending changes
            site.setPendingChanges(true);
            
        };
            
        
    }
    
    Block.prototype.handleEvent = function(event) {
        switch (event.type) {
            case "load": 
                this.setFrameDocument();
                this.heightAdjustment();
                
                $(this.frameCover).removeClass('fresh', 500);

                break;
                
            case "click":
                
                var theBlock = this;
                
                //figure out what to do next
                
                if( event.target.classList.contains('deleteBlock') ) {//delete this block
                    
                    $(builderUI.modalDeleteBlock).modal('show');                    
                    
                    $(builderUI.modalDeleteBlock).off('click', '#deleteBlockConfirm').on('click', '#deleteBlockConfirm', function(){
                        theBlock.delete(event);
                        $(builderUI.modalDeleteBlock).modal('hide');
                    });
                    
                } else if( event.target.classList.contains('resetBlock') ) {//reset the block
                    
                    $(builderUI.modalResetBlock).modal('show'); 
                    
                    $(builderUI.modalResetBlock).off('click', '#resetBlockConfirm').on('click', '#resetBlockConfirm', function(){
                        theBlock.reset();
                        $(builderUI.modalResetBlock).modal('hide');
                    });
                       
                } else if( event.target.classList.contains('htmlBlock') ) {//source code editor
                    
                    theBlock.source();
                    
                } else if( event.target.classList.contains('editCancelButton') ) {//cancel source code editor
                    
                    theBlock.cancelSourceBlock();
                    
                } else if( event.target.classList.contains('editSaveButton') ) {//save source code
                    
                    theBlock.saveSourceBlock();
                    
                } else if( event.target.classList.contains('button_clearErrorDrawer') ) {//clear error drawer
                    
                    theBlock.clearErrorDrawer();
                    
                }
                
        }
    };


    /*
        Site object literal
    */
    /*jshint -W003 */
    var site = {
        
        pendingChanges: false,      //pending changes or no?
        pages: {},                  //array containing all pages, including the child frames, loaded from the server on page load
        is_admin: 0,                //0 for non-admin, 1 for admin
        data: {},                   //container for ajax loaded site data
        pagesToDelete: [],          //contains pages to be deleted
                
        sitePages: [],              //this is the only var containing the recent canvas contents
        
        sitePagesReadyForServer: {},     //contains the site data ready to be sent to the server
        
        activePage: {},             //holds a reference to the page currently open on the canvas
        
        pageTitle: document.getElementById('pageTitle'),//holds the page title of the current page on the canvas
        
        divCanvas: document.getElementById('pageList'),//DIV containing all pages on the canvas
        
        pagesMenu: document.getElementById('pages'), //UL containing the pages menu in the sidebar
                
        buttonNewPage: document.getElementById('addPage'),
        liNewPage: document.getElementById('newPageLI'),
        
        inputPageSettingsTitle: document.getElementById('pageData_title'),
        inputPageSettingsMetaDescription: document.getElementById('pageData_metaDescription'),
        inputPageSettingsMetaKeywords: document.getElementById('pageData_metaKeywords'),
        inputPageSettingsIncludes: document.getElementById('pageData_headerIncludes'),
        inputPageSettingsPageCss: document.getElementById('pageData_headerCss'),
        
        buttonSubmitPageSettings: document.getElementById('pageSettingsSubmittButton'),
        
        modalPageSettings: document.getElementById('pageSettingsModal'),
        
        buttonSave: document.getElementById('savePage'),
        
        messageStart: document.getElementById('start'),
        divFrameWrapper: document.getElementById('frameWrapper'),
        
        skeleton: document.getElementById('skeleton'),
		
		autoSaveTimer: {},
        
        init: function() {
                        
            $.getJSON(appUI.siteUrl+"sites/siteData", function(data){
                
                if( data.site !== undefined ) {
                    site.data = data.site;
                }
                if( data.pages !== undefined ) {
                    site.pages = data.pages;
                }
                
                site.is_admin = data.is_admin;
                
				if( $('#pageList').size() > 0 ) {
                	builderUI.populateCanvas();
				}
                
                //fire custom event
                $('body').trigger('siteDataLoaded');
                
            });
            
            $(this.buttonNewPage).on('click', site.newPage);
            $(this.modalPageSettings).on('show.bs.modal', site.loadPageSettings);
            $(this.buttonSubmitPageSettings).on('click', site.updatePageSettings);
            $(this.buttonSave).on('click', function(){site.save(true);});
            
            //auto save time 
            this.autoSaveTimer = setTimeout(site.autoSave, bConfig.autoSaveTimeout);
                            
        },
        
        autoSave: function(){
                                    
            if(site.pendingChanges) {
                site.save(false);
            }
			
			window.clearInterval(this.autoSaveTimer);
            this.autoSaveTimer = setTimeout(site.autoSave, bConfig.autoSaveTimeout);
        
        },
                
        setPendingChanges: function(value) {
                        
            this.pendingChanges = value;
            
            if( value === true ) {
				
				//reset timer
				window.clearInterval(this.autoSaveTimer);
            	this.autoSaveTimer = setTimeout(site.autoSave, bConfig.autoSaveTimeout);
                
                $('#savePage .bLabel').text("Save now (!)");
                
                if( site.activePage.status !== 'new' ) {
                
                    site.activePage.status = 'changed';
                    
                }
			
            } else {
	
                $('#savePage .bLabel').text("Nothing to save");
				
                site.updatePageStatus('');

            }
            
        },
                   
        save: function(showConfirmModal) {
                                    
            //fire custom event
            $('body').trigger('beforeSave');

            //disable button
            $("a#savePage").addClass('disabled');
	
            //remove old alerts
            $('#errorModal .modal-body > *, #successModal .modal-body > *').each(function(){
                $(this).remove();
            });
	
            site.prepForSave(false);
            
            var serverData = {};
            serverData.pages = this.sitePagesReadyForServer;
            if( this.pagesToDelete.length > 0 ) {
                serverData.toDelete = this.pagesToDelete;
            }
            serverData.siteData = this.data;

            $.ajax({
                url: appUI.siteUrl+"sites/save",
                type: "POST",
                dataType: "json",
                data: serverData,
            }).done(function(res){
	
                //enable button
                $("a#savePage").removeClass('disabled');
	
                if( res.responseCode === 0 ) {
			
                    if( showConfirmModal ) {
				
                        $('#errorModal .modal-body').append( $(res.responseHTML) );
                        $('#errorModal').modal('show');
				
                    }
		
                } else if( res.responseCode === 1 ) {
		
                    if( showConfirmModal ) {
		
                        $('#successModal .modal-body').append( $(res.responseHTML) );
                        $('#successModal').modal('show');
				
                    }
			
			
                    //no more pending changes
                    site.setPendingChanges(false);
			

                    //update revisions?
                    $('body').trigger('changePage');
                
                }
            });
    
        },
        
        /*
            preps the site data before sending it to the server
        */
        prepForSave: function(template) {
            
            this.sitePagesReadyForServer = {};
            
            if( template ) {//saving template, only the activePage is needed
                
                this.sitePagesReadyForServer[this.activePage.name] = this.activePage.prepForSave();
                
                this.activePage.fullPage();
                
            } else {//regular save
            
                //find the pages which need to be send to the server
                for( var i = 0; i < this.sitePages.length; i++ ) {
                                
                    if( this.sitePages[i].status !== '' ) {
                                    
                        this.sitePagesReadyForServer[this.sitePages[i].name] = this.sitePages[i].prepForSave();
                    
                    }
                
                }
            
            }
                                                                            
        },
        
        
        /*
            sets a page as the active one
        */
        setActive: function(page) {
            
            //reference to the active page
            this.activePage = page;
            
            //hide other pages
            for(var i in this.sitePages) {
                this.sitePages[i].parentUL.style.display = 'none';   
            }
            
            //display active one
            this.activePage.parentUL.style.display = 'block';
            
        },
        
        
        /*
            de-active all page menu items
        */
        deActivateAll: function() {
            
            var pages = this.pagesMenu.querySelectorAll('li');
            
            for( var i = 0; i < pages.length; i++ ) {
                pages[i].classList.remove('active');
            }
            
        },
        
        
        /*
            adds a new page to the site
        */
        newPage: function() {
            
            site.deActivateAll();
            
            //create the new page instance
            
            var pageData = [];
            var temp = {
                pages_id: 0
            };
            pageData[0] = temp;
            
            var newPageName = 'page'+(site.sitePages.length+1);
            
            var newPage = new Page(newPageName, pageData, site.sitePages.length+1);
            
            newPage.status = 'new';
            
            newPage.selectPage();
            newPage.editPageName();
        
            newPage.isEmpty();
                        
            site.setPendingChanges(true);
                                    
        },
        
        
        /*
            checks if the name of a page is allowed
        */
        checkPageName: function(pageName) {
            
            //make sure the name is unique
            for( var i in this.sitePages ) {
                
                if( this.sitePages[i].name === pageName && this.activePage !== this.sitePages[i] ) {
                    this.pageNameError = "The page name must be unique.";
                    return false;
                }   
                
            }
            
            return true;
            
        },
        
        
        /*
            removes unallowed characters from the page name
        */
        prepPageName: function(pageName) {
            
            pageName = pageName.replace(' ', '');
            pageName = pageName.replace(/[?*!.|&#;$%@"<>()+,]/g, "");
            
            return pageName;
            
        },
        
        
        /*
            save page settings for the current page
        */
        updatePageSettings: function() {
            
            site.activePage.pageSettings.title = site.inputPageSettingsTitle.value;
            site.activePage.pageSettings.meta_description = site.inputPageSettingsMetaDescription.value;
            site.activePage.pageSettings.meta_keywords = site.inputPageSettingsMetaKeywords.value;
            site.activePage.pageSettings.header_includes = site.inputPageSettingsIncludes.value;
            site.activePage.pageSettings.page_css = site.inputPageSettingsPageCss.value;
                        
            site.setPendingChanges(true);
            
            $(site.modalPageSettings).modal('hide');
            
        },
        
        
        /*
            update page statuses
        */
        updatePageStatus: function(status) {
            
            for( var i in this.sitePages ) {
                this.sitePages[i].status = status;   
            }
            
        }
    
    };

    builderUI.init(); site.init();

    
    //**** EXPORTS
    module.exports.site = site;
    module.exports.builderUI = builderUI;

}());
},{"./config.js":5,"./ui.js":8,"./utils.js":9}],4:[function(require,module,exports){
(function () {
    "use strict";

    var siteBuilder = require('./builder.js');

    /*
        constructor function for Element
    */
    module.exports.Element = function (el) {
                
        this.element = el;
        this.sandbox = false;
        this.parentFrame = {};
        this.parentBlock = {};//reference to the parent block element
        
        //make current element active/open (being worked on)
        this.setOpen = function() {
            
            $(this.element).off('mouseenter mouseleave click');
            
            if( $(this.element).closest('body').width() !== $(this.element).width() ) {
                                
                $(this.element).css({'outline': '3px dashed red', 'cursor': 'pointer'});
            
            } else {
                
                $(this.element).css({'outline': '3px dashed red', 'outline-offset':'-3px',  'cursor': 'pointer'});
            
            }
            
        };
        
        //sets up hover and click events, making the element active on the canvas
        this.activate = function() {
            
            var element = this;
            
            $(this.element).css({'outline': 'none', 'cursor': 'inherit'});
                                    
            $(this.element).on('mouseenter', function() {
                
                if( $(this).closest('body').width() !== $(this).width() ) {
                    
                    $(this).css({'outline': '3px dashed red', 'cursor': 'pointer'});
                            
                } else {
                    
                    $(this).css({'outline': '3px dashed red', 'outline-offset': '-3px', 'cursor': 'pointer'});
                
                }
            
            }).on('mouseleave', function() {
                
                $(this).css({'outline': '', 'cursor': '', 'outline-offset': ''});
            
            }).on('click', function(e) {
                                                                
                e.preventDefault();
                e.stopPropagation();
                
                element.clickHandler(this);
            
            });
            
        };
        
        this.deactivate = function() {
            
            $(this.element).off('mouseenter mouseleave click');
            $(this.element).css({'outline': 'none', 'cursor': 'inherit'});

        };
        
        //removes the elements outline
        this.removeOutline = function() {
            
            $(this.element).css({'outline': 'none', 'cursor': 'inherit'});
            
        };
        
        //sets the parent iframe
        this.setParentFrame = function() {
            
            var doc = this.element.ownerDocument;
            var w = doc.defaultView || doc.parentWindow;
            var frames = w.parent.document.getElementsByTagName('iframe');
            
            for (var i= frames.length; i-->0;) {
                
                var frame= frames[i];
                
                try {
                    var d= frame.contentDocument || frame.contentWindow.document;
                    if (d===doc)
                        this.parentFrame = frame;
                } catch(e) {}
            }
            
        };
        
        //sets this element's parent block reference
        this.setParentBlock = function() {
            
            //loop through all the blocks on the canvas
            for( var i = 0; i < siteBuilder.site.sitePages.length; i++ ) {
                                
                for( var x = 0; x < siteBuilder.site.sitePages[i].blocks.length; x++ ) {
                                        
                    //if the block's frame matches this element's parent frame
                    if( siteBuilder.site.sitePages[i].blocks[x].frame === this.parentFrame ) {
                        //create a reference to that block and store it in this.parentBlock
                        this.parentBlock = siteBuilder.site.sitePages[i].blocks[x];
                    }
                
                }
                
            }
                        
        };
        
        
        this.setParentFrame();
        
        /*
            is this block sandboxed?
        */
        
        if( this.parentFrame.getAttribute('data-sandbox') ) {
            this.sandbox = this.parentFrame.getAttribute('data-sandbox');   
        }
                
    };

}());
},{"./builder.js":3}],5:[function(require,module,exports){
(function () {
	"use strict";
        
    module.exports.pageContainer = "#page";
    
    module.exports.editableItems = {
        'span.fa': ['color', 'font-size'],
        '.bg.bg1': ['background-color'],
        'nav a, a.edit': ['color', 'font-weight', 'text-transform'],
        'h1, h2, h3, h4, h5, p': ['color', 'font-size', 'background-color', 'font-family'],
        'a.btn, button.btn': ['border-radius', 'font-size', 'background-color'],

        'img': ['border-top-left-radius', 'border-top-right-radius', 'border-bottom-left-radius', 'border-bottom-right-radius', 'border-color', 'border-style', 'border-width'],
        'hr.dashed': ['border-color', 'border-width'],
        '.divider > span': ['color', 'font-size'],
        'hr.shadowDown': ['margin-top', 'margin-bottom'],
        '.footer a': ['color'],
        '.bg.bg1, .bg.bg2, .header10, .header11': ['background-image', 'background-color'],
        '.frameCover': []
    };
    
    module.exports.editableItemOptions = {
        'nav a : font-weight': ['400', '700'],
        'a.btn : border-radius': ['0px', '4px', '10px'],
        'img : border-style': ['none', 'dotted', 'dashed', 'solid'],
        'img : border-width': ['1px', '2px', '3px', '4px'],
        'h1, h2, h3, h4, h5, p : font-family': ['default', 'Lato', 'Helvetica', 'Arial', 'Times New Roman'],
        'h2 : font-family': ['default', 'Lato', 'Helvetica', 'Arial', 'Times New Roman'],
        'h3 : font-family': ['default', 'Lato', 'Helvetica', 'Arial', 'Times New Roman'],
        'p : font-family': ['default', 'Lato', 'Helvetica', 'Arial', 'Times New Roman']
    };

    module.exports.editableContent = ['.editContent', '.navbar a', 'button', 'a.btn', '.footer a:not(.fa)', '.tableWrapper', 'h1'];

    module.exports.autoSaveTimeout = 60000;
    
    module.exports.sourceCodeEditSyntaxDelay = 10000;
                    
}());
},{}],6:[function(require,module,exports){
(function (){
	"use strict";

    var bConfig = require('./config.js');
    var siteBuilder = require('./builder.js');
    var editor = require('./styleeditor.js').styleeditor;
    var appUI = require('./ui.js').appUI;

    var imageLibrary = {
        
        imageModal: document.getElementById('imageModal'),
        inputImageUpload: document.getElementById('imageFile'),
        buttonUploadImage: document.getElementById('uploadImageButton'),
        imageLibraryLinks: document.querySelectorAll('.images > .image .buttons .btn-primary, .images .imageWrap > a'),//used in the library, outside the builder UI
        myImages: document.getElementById('myImages'),//used in the image library, outside the builder UI
    
        init: function(){
            
            $(this.imageModal).on('show.bs.modal', this.imageLibrary);
            $(this.inputImageUpload).on('change', this.imageInputChange);
            $(this.buttonUploadImage).on('click', this.uploadImage);
            $(this.imageLibraryLinks).on('click', this.imageInModal);
            $(this.myImages).on('click', '.buttons .btn-danger', this.deleteImage);
            
        },
        
        
        /*
            image library modal
        */
        imageLibrary: function() {
                        			
            $('#imageModal').off('click', '.image button.useImage');
			
            $('#imageModal').on('click', '.image button.useImage', function(){
                
                //update live image
                $(editor.activeElement.element).attr('src', $(this).attr('data-url'));

                //update image URL field
                $('input#imageURL').val( $(this).attr('data-url') );
				
                //hide modal
                $('#imageModal').modal('hide');
				
                //height adjustment of the iframe heightAdjustment
				editor.activeElement.parentBlock.heightAdjustment();							
				
                //we've got pending changes
                siteBuilder.site.setPendingChanges(true);
			
                $(this).unbind('click');
            
            });
            
        },
        
        
        /*
            image upload input chaneg event handler
        */
        imageInputChange: function() {
            
            if( $(this).val() === '' ) {
                //no file, disable submit button
                $('button#uploadImageButton').addClass('disabled');
            } else {
                //got a file, enable button
                $('button#uploadImageButton').removeClass('disabled');
            }
            
        },
        
        
        /*
            upload an image to the image library
        */
        uploadImage: function() {
            
            if( $('input#imageFile').val() !== '' ) {
                
                //remove old alerts
                $('#imageModal .modal-alerts > *').remove();
                
                //disable button
                $('button#uploadImageButton').addClass('disable');

                //show loader
                $('#imageModal .loader').fadeIn(500);
                
                var form = $('form#imageUploadForm');
                var formdata = false;

                if (window.FormData){
                    formdata = new FormData(form[0]);
                }
                
                var formAction = form.attr('action');
                
                $.ajax({
                    url : formAction,
                    data : formdata ? formdata : form.serialize(),
                    cache : false,
                    contentType : false,
                    processData : false,
                    dataType: "json",
                    type : 'POST'
                }).done(function(ret){
                    
                    //enable button
                    $('button#uploadImageButton').addClass('disable');
                    
                    //hide loader
                    $('#imageModal .loader').fadeOut(500);
                    
                    if( ret.responseCode === 0 ) {//error
                        
                        $('#imageModal .modal-alerts').append( $(ret.responseHTML) );
			
                    } else if( ret.responseCode === 1 ) {//success
                        
                        //append my image
                        $('#myImagesTab > *').remove();
                        $('#myImagesTab').append( $(ret.myImages) );
                        $('#imageModal .modal-alerts').append( $(ret.responseHTML) );
                        
                        setTimeout(function(){$('#imageModal .modal-alerts > *').fadeOut(500);}, 3000);
                    
                    }
                
                });
            
            } else {

                alert('No image selected');
            
            }
            
        },
        
        
        /*
            displays image in modal
        */
        imageInModal: function(e) {
            
            e.preventDefault();
    		
    		var theSrc = $(this).closest('.image').find('img').attr('src');
    		
    		$('img#thePic').attr('src', theSrc);
    		
    		$('#viewPic').modal('show');
            
        },
        
        
        /*
            deletes an image from the library
        */
        deleteImage: function(e) {
            
            e.preventDefault();
    		
    		var toDel = $(this).closest('.image');
    		var theURL = $(this).attr('data-img');
    		
    		$('#deleteImageModal').modal('show');
    		
    		$('button#deleteImageButton').click(function(){
    		
    			$(this).addClass('disabled');
    			
    			var theButton = $(this);
    		
    			$.ajax({
                    url: appUI.siteUrl+"assets/delImage",
    				data: {file: theURL},
    				type: 'post'
    			}).done(function(){
    			
    				theButton.removeClass('disabled');
    				
    				$('#deleteImageModal').modal('hide');
    				
    				toDel.fadeOut(800, function(){
    									
    					$(this).remove();
    										
    				});
    			
    			});
    		
    		
    		});
            
        }
        
    };
    
    imageLibrary.init();

}());
},{"./builder.js":3,"./config.js":5,"./styleeditor.js":7,"./ui.js":8}],7:[function(require,module,exports){
(function (){
	"use strict";

	var canvasElement = require('./canvasElement.js').Element;
	var bConfig = require('./config.js');
	var siteBuilder = require('./builder.js');

    var styleeditor = {

        radioStyle: document.getElementById('modeStyle'),
        labelStyleMode: document.getElementById('modeStyleLabel'),
        buttonSaveChanges: document.getElementById('saveStyling'),
        activeElement: {}, //holds the element currenty being edited
        allStyleItemsOnCanvas: [],
        _oldIcon: [],
        styleEditor: document.getElementById('styleEditor'),
        formStyle: document.getElementById('stylingForm'),
        buttonRemoveElement: document.getElementById('deleteElementConfirm'),
        buttonCloneElement: document.getElementById('cloneElementButton'),
        buttonResetElement: document.getElementById('resetStyleButton'),
        selectLinksInernal: document.getElementById('internalLinksDropdown'),
        selectLinksPages: document.getElementById('pageLinksDropdown'),
        videoInputYoutube: document.getElementById('youtubeID'),
        videoInputVimeo: document.getElementById('vimeoID'),
        inputCustomLink: document.getElementById('internalLinksCustom'),
        selectIcons: document.getElementById('icons'),
        buttonDetailsAppliedHide: document.getElementById('detailsAppliedMessageHide'),
        buttonCloseStyleEditor: document.querySelector('#styleEditor > a.close'),
        ulPageList: document.getElementById('pageList'),

        init: function() {

            //events
            $(this.radioStyle).on('click', this.activateStyleMode);
            $(this.buttonSaveChanges).on('click', this.updateStyling);
            $(this.formStyle).on('focus', 'input', this.animateStyleInputIn).on('blur', 'input', this.animateStyleInputOut);
            $(this.buttonRemoveElement).on('click', this.deleteElement);
            $(this.buttonCloneElement).on('click', this.cloneElement);
            $(this.buttonResetElement).on('click', this.resetElement);
            $(this.selectLinksInernal).on('change', this.resetSelectLinksInternal);
            $(this.selectLinksPages).on('change', this.resetSelectLinksPages);
            $(this.videoInputYoutube).on('focus', function(){ $(styleeditor.videoInputVimeo).val(''); });
            $(this.videoInputVimeo).on('focus', function(){ $(styleeditor.videoInputYoutube).val(''); });
            $(this.inputCustomLink).on('focus', this.resetSelectAllLinks);
            $(this.buttonDetailsAppliedHide).on('click', function(){$(this).parent().fadeOut(500);});
            $(this.buttonCloseStyleEditor).on('click', this.closeStyleEditor);
            $(document).on('modeContent modeBlocks', 'body', this.deActivateMode);

            //chosen font-awesome dropdown
            $(this.selectIcons).chosen({'search_contains': true});

            //check if formData is supported
            if (!window.FormData){
                this.hideFileUploads();
            }

            //show the style mode radio button
            $(this.labelStyleMode).show();

            //listen for the beforeSave event
            $('body').on('beforeSave', this.closeStyleEditor);

        },


        /*
            Activates style editor mode
        */
        activateStyleMode: function() {

            var i;

            //Element object extention
            canvasElement.prototype.clickHandler = function(el) {
                styleeditor.styleClick(el);
            };

            // Remove overlay span from portfolio
            for(i = 1; i <= $("ul#page1 li").length; i++){
                var id = "#ui-id-" + i;
                $(id).contents().find(".overlay").remove();
            }


            //trigger custom event
            $('body').trigger('modeDetails');

            //disable frameCovers
            for( i = 0; i < siteBuilder.site.sitePages.length; i++ ) {
                siteBuilder.site.sitePages[i].toggleFrameCovers('Off');
            }

            //create an object for every editable element on the canvas and setup it's events

            for( i = 0; i < siteBuilder.site.sitePages.length; i++ ) {

                for( var x = 0; x < siteBuilder.site.sitePages[i].blocks.length; x++ ) {

                    for( var key in bConfig.editableItems ) {

                        $(siteBuilder.site.sitePages[i].blocks[x].frame).contents().find( bConfig.pageContainer + ' '+ key ).each(function(){

                            var newElement = new canvasElement(this);

                            newElement.activate();

                            styleeditor.allStyleItemsOnCanvas.push( newElement );

                            $(this).attr('data-selector', key);

                        });

                    }

                }

            }

            /*$('#pageList ul li iframe').each(function(){

                for( var key in bConfig.editableItems ) {

                    $(this).contents().find( bConfig.pageContainer + ' '+ key ).each(function(){

                        var newElement = new canvasElement(this);

                        newElement.activate();

                        styleeditor.allStyleItemsOnCanvas.push( newElement );

                        $(this).attr('data-selector', key);

                    });

                }

            });*/

        },


        /*
            Event handler for when the style editor is envoked on an item
        */
        styleClick: function(el) {

            //if we have an active element, make it unactive
            if( Object.keys(this.activeElement).length !== 0) {
                this.activeElement.activate();
            }

            //set the active element
            var activeElement = new canvasElement(el);
            activeElement.setParentBlock();
            this.activeElement = activeElement;

            //unbind hover and click events and make this item active
            this.activeElement.setOpen();

            var theSelector = $(this.activeElement.element).attr('data-selector');

            $('#editingElement').text( theSelector );

            //activate first tab
            $('#detailTabs a:first').click();

            //hide all by default
            $('ul#detailTabs li:gt(0)').hide();

            //what are we dealing with?
            if( $(this.activeElement.element).prop('tagName') === 'A' || $(this.activeElement.element).parent().prop('tagName') === 'A' ) {

                this.editLink(this.activeElement.element);

            }

			if( $(this.activeElement.element).prop('tagName') === 'IMG' ){

                this.editImage(this.activeElement.element);

            }

			if( $(this.activeElement.element).attr('data-type') === 'video' ) {

                this.editVideo(this.activeElement.element);

            }

			if( $(this.activeElement.element).hasClass('fa') ) {

                this.editIcon(this.activeElement.element);

            }

            //load the attributes
            this.buildeStyleElements(theSelector);

            //open side panel
            this.toggleSidePanel('open');
        },


        /*
            dynamically generates the form fields for editing an elements style attributes
        */
        buildeStyleElements: function(theSelector) {

            //delete the old ones first
            $('#styleElements > *:not(#styleElTemplate)').each(function(){

                $(this).remove();

            });

            for( var x=0; x<bConfig.editableItems[theSelector].length; x++ ) {

                //create style elements
                var newStyleEl = $('#styleElTemplate').clone();
                newStyleEl.attr('id', '');
                newStyleEl.find('.control-label').text( bConfig.editableItems[theSelector][x]+":" );

                if( theSelector + " : " + bConfig.editableItems[theSelector][x] in bConfig.editableItemOptions) {//we've got a dropdown instead of open text input

                    newStyleEl.find('input').remove();

                    var newDropDown = $('<select class="form-control select select-primary btn-block select-sm"></select>');
                    newDropDown.attr('name', bConfig.editableItems[theSelector][x]);


                    for( var z=0; z<bConfig.editableItemOptions[ theSelector+" : "+bConfig.editableItems[theSelector][x] ].length; z++ ) {

                        var newOption = $('<option value="'+bConfig.editableItemOptions[theSelector+" : "+bConfig.editableItems[theSelector][x]][z]+'">'+bConfig.editableItemOptions[theSelector+" : "+bConfig.editableItems[theSelector][x]][z]+'</option>');


                        if( bConfig.editableItemOptions[theSelector+" : "+bConfig.editableItems[theSelector][x]][z] === $(styleeditor.activeElement.element).css( bConfig.editableItems[theSelector][x] ) ) {
                            //current value, marked as selected
                            newOption.attr('selected', 'true');

                        }

                        newDropDown.append( newOption );

                    }

                    newStyleEl.append( newDropDown );
                    newDropDown.select2();

                } else {

                    newStyleEl.find('input').val( $(styleeditor.activeElement.element).css( bConfig.editableItems[theSelector][x] ) ).attr('name', bConfig.editableItems[theSelector][x]);

                    if( bConfig.editableItems[theSelector][x] === 'background-image' ) {

                        newStyleEl.find('input').bind('focus', function(){

                            var theInput = $(this);

                            $('#imageModal').modal('show');
                            $('#imageModal .image button.useImage').unbind('click');
                            $('#imageModal').on('click', '.image button.useImage', function(){

                                $(styleeditor.activeElement.element).css('background-image',  'url("'+$(this).attr('data-url')+'")');

                                //update live image
                                theInput.val( 'url("'+$(this).attr('data-url')+'")' );

                                //hide modal
                                $('#imageModal').modal('hide');

                                //we've got pending changes
                                siteBuilder.site.setPendingChanges(true);

                            });

                        });

                    } else if( bConfig.editableItems[theSelector][x].indexOf("color") > -1 ) {

                        if( $(styleeditor.activeElement.element).css( bConfig.editableItems[theSelector][x] ) !== 'transparent' && $(styleeditor.activeElement.element).css( bConfig.editableItems[theSelector][x] ) !== 'none' && $(styleeditor.activeElement.element).css( bConfig.editableItems[theSelector][x] ) !== '' ) {

                            newStyleEl.val( $(styleeditor.activeElement.element).css( bConfig.editableItems[theSelector][x] ) );

                        }

                        newStyleEl.find('input').spectrum({
                            preferredFormat: "hex",
                            showPalette: true,
                            allowEmpty: true,
                            showInput: true,
                            palette: [
                                ["#000","#444","#666","#999","#ccc","#eee","#f3f3f3","#fff"],
                                ["#f00","#f90","#ff0","#0f0","#0ff","#00f","#90f","#f0f"],
                                ["#f4cccc","#fce5cd","#fff2cc","#d9ead3","#d0e0e3","#cfe2f3","#d9d2e9","#ead1dc"],
                                ["#ea9999","#f9cb9c","#ffe599","#b6d7a8","#a2c4c9","#9fc5e8","#b4a7d6","#d5a6bd"],
                                ["#e06666","#f6b26b","#ffd966","#93c47d","#76a5af","#6fa8dc","#8e7cc3","#c27ba0"],
                                ["#c00","#e69138","#f1c232","#6aa84f","#45818e","#3d85c6","#674ea7","#a64d79"],
                                ["#900","#b45f06","#bf9000","#38761d","#134f5c","#0b5394","#351c75","#741b47"],
                                ["#600","#783f04","#7f6000","#274e13","#0c343d","#073763","#20124d","#4c1130"]
                            ]
                        });

                    }

                }

                newStyleEl.css('display', 'block');

                $('#styleElements').append( newStyleEl );

                $('#styleEditor form#stylingForm').height('auto');

            }

        },


        /*
            Applies updated styling to the canvas
        */
        updateStyling: function() {

            var elementID;

            $('#styleEditor #tab1 .form-group:not(#styleElTemplate) input, #styleEditor #tab1 .form-group:not(#styleElTemplate) select').each(function(){

				if( $(this).attr('name') !== undefined ) {

                	$(styleeditor.activeElement.element).css( $(this).attr('name'),  $(this).val());

				}

                /* SANDBOX */

                if( styleeditor.activeElement.sandbox ) {

                    elementID = $(styleeditor.activeElement.element).attr('id');

                    $('#'+styleeditor.activeElement.sandbox).contents().find('#'+elementID).css( $(this).attr('name'),  $(this).val() );

                }

                /* END SANDBOX */

            });

            //links
            if( $(styleeditor.activeElement.element).prop('tagName') === 'A' ) {

                //change the href prop?
                if( $('select#internalLinksDropdown').val() !== '#' ) {

                    $(styleeditor.activeElement.element).attr('href', $('select#internalLinksDropdown').val());

                } else if( $('select#pageLinksDropdown').val() !== '#' ) {

                    $(styleeditor.activeElement.element).attr('href', $('select#pageLinksDropdown').val() );

                } else if( $('input#internalLinksCustom').val() !== '' ) {

                    $(styleeditor.activeElement.element).attr('href', $('input#internalLinksCustom').val());

                }

                /* SANDBOX */

                if( styleeditor.activeElement.sandbox ) {

                    elementID = $(styleeditor.activeElement.element).attr('id');

                    if( $('select#internalLinksDropdown').val() !== '#' ) {

                        $('#'+styleeditor.activeElement.sandbox).contents().find('#'+elementID).attr('href', $('select#internalLinksDropdown').val());

                    } else if( $('select#pageLinksDropdown').val() !== '#' ) {

                        $('#'+styleeditor.activeElement.sandbox).contents().find('#'+elementID).attr('href', $('select#pageLinksDropdown').val() );

                    } else if( $('input#internalLinksCustom').val() !== '' ) {

                        $('#'+styleeditor.activeElement.sandbox).contents().find('#'+elementID).attr('href', $('input#internalLinksCustom').val());

                    }

                }

                /* END SANDBOX */

            }

            if( $(styleeditor.activeElement.element).parent().prop('tagName') === 'A' ) {

                //change the href prop?
				if( $('select#internalLinksDropdown').val() !== '#' ) {

                    $(styleeditor.activeElement.element).parent().attr('href', $('select#internalLinksDropdown').val());

                } else if( $('select#pageLinksDropdown').val() !== '#' ) {

                    $(styleeditor.activeElement.element).parent().attr('href', $('select#pageLinksDropdown').val() );

                } else if( $('input#internalLinksCustom').val() !== '' ) {

                    $(styleeditor.activeElement.element).parent().attr('href', $('input#internalLinksCustom').val());

                }

                /* SANDBOX */

                if( styleeditor.activeElement.sandbox ) {

                    elementID = $(styleeditor.activeElement.element).attr('id');

                    if( $('select#internalLinksDropdown').val() !== '#' ) {

                        $('#'+styleeditor.activeElement.sandbox).contents().find('#'+elementID).parent().attr('href', $('select#internalLinksDropdown').val());

                    } else if( $('select#pageLinksDropdown').val() !== '#' ) {

                        $('#'+styleeditor.activeElement.sandbox).contents().find('#'+elementID).parent().attr('href', $('select#pageLinksDropdown').val() );

                    } else if( $('input#internalLinksCustom').val() !== '' ) {

                        $('#'+styleeditor.activeElement.sandbox).contents().find('#'+elementID).parent().attr('href', $('input#internalLinksCustom').val());

                    }

                }

                /* END SANDBOX */

            }

            //icons
            if( $(styleeditor.activeElement.element).hasClass('fa') ) {

                //out with the old, in with the new :)
                //get icon class name, starting with fa-
                var get = $.grep(styleeditor.activeElement.element.className.split(" "), function(v, i){

                    return v.indexOf('fa-') === 0;

                }).join();

                //if the icons is being changed, save the old one so we can reset it if needed

                if( get !== $('select#icons').val() ) {

                    $(styleeditor.activeElement.element).uniqueId();
                    styleeditor._oldIcon[$(styleeditor.activeElement.element).attr('id')] = get;

                }

                $(styleeditor.activeElement.element).removeClass( get ).addClass( $('select#icons').val() );


                /* SANDBOX */

                if( styleeditor.activeElement.sandbox ) {

                    elementID = $(styleeditor.activeElement.element).attr('id');
                    $('#'+styleeditor.activeElement.sandbox).contents().find('#'+elementID).removeClass( get ).addClass( $('select#icons').val() );

                }

                /* END SANDBOX */

            }

            //video URL
            if( $(styleeditor.activeElement.element).attr('data-type') === 'video' ) {

                if( $('input#youtubeID').val() !== '' ) {

                    $(styleeditor.activeElement.element).prev().attr('src', "//www.youtube.com/embed/"+$('#video_Tab input#youtubeID').val());

                } else if( $('input#vimeoID').val() !== '' ) {

                    $(styleeditor.activeElement.element).prev().attr('src', "//player.vimeo.com/video/"+$('#video_Tab input#vimeoID').val()+"?title=0&amp;byline=0&amp;portrait=0");

                }

                /* SANDBOX */

                if( styleeditor.activeElement.sandbox ) {

                    elementID = $(styleeditor.activeElement.element).attr('id');

                    if( $('input#youtubeID').val() !== '' ) {

                        $('#'+styleeditor.activeElement.sandbox).contents().find('#'+elementID).prev().attr('src', "//www.youtube.com/embed/"+$('#video_Tab input#youtubeID').val());

                    } else if( $('input#vimeoID').val() !== '' ) {

                        $('#'+styleeditor.activeElement.sandbox).contents().find('#'+elementID).prev().attr('src', "//player.vimeo.com/video/"+$('#video_Tab input#vimeoID').val()+"?title=0&amp;byline=0&amp;portrait=0");

                    }

                }

                /* END SANDBOX */

            }

            $('#detailsAppliedMessage').fadeIn(600, function(){

                setTimeout(function(){ $('#detailsAppliedMessage').fadeOut(1000); }, 3000);

            });

            //adjust frame height
            styleeditor.activeElement.parentBlock.heightAdjustment();


            //we've got pending changes
            siteBuilder.site.setPendingChanges(true);

        },


        /*
            on focus, we'll make the input fields wider
        */
        animateStyleInputIn: function() {

            $(this).css('position', 'absolute');
            $(this).css('right', '0px');
            $(this).animate({'width': '100%'}, 500);
            $(this).focus(function(){
                this.select();
            });

        },


        /*
            on blur, we'll revert the input fields to their original size
        */
        animateStyleInputOut: function() {

            $(this).animate({'width': '42%'}, 500, function(){
                $(this).css('position', 'relative');
                $(this).css('right', 'auto');
            });

        },


        /*
            when the clicked element is an anchor tag (or has a parent anchor tag)
        */
        editLink: function(el) {

            $('a#link_Link').parent().show();

            var theHref;

            if( $(el).prop('tagName') === 'A' ) {

                theHref = $(el).attr('href');

            } else if( $(el).parent().prop('tagName') === 'A' ) {

                theHref = $(el).parent().attr('href');

            }

            var zIndex = 0;

            var pageLink = false;

            //the actual select

            $('select#internalLinksDropdown').prop('selectedIndex', 0);

            //set the correct item to "selected"
            $('select#internalLinksDropdown option').each(function(){

                if( $(this).attr('value') === theHref ) {

                    $(this).attr('selected', true);

                    zIndex = $(this).index();

                    pageLink = true;

                }

            });


            //the pretty dropdown
            $('.link_Tab .btn-group.select .dropdown-menu li').removeClass('selected');
            $('.link_Tab .btn-group.select .dropdown-menu li:eq('+zIndex+')').addClass('selected');
            $('.link_Tab .btn-group.select:eq(0) .filter-option').text( $('select#internalLinksDropdown option:selected').text() );
            $('.link_Tab .btn-group.select:eq(1) .filter-option').text( $('select#pageLinksDropdown option:selected').text() );

            if( pageLink === true ) {

                $('input#internalLinksCustom').val('');

            } else {

                if( $(el).prop('tagName') === 'A' ) {

                    if( $(el).attr('href')[0] !== '#' ) {
                        $('input#internalLinksCustom').val( $(el).attr('href') );
                    } else {
                        $('input#internalLinksCustom').val( '' );
                    }

                } else if( $(el).parent().prop('tagName') === 'A' ) {

                    if( $(el).parent().attr('href')[0] !== '#' ) {
                        $('input#internalLinksCustom').val( $(el).parent().attr('href') );
                    } else {
                        $('input#internalLinksCustom').val( '' );
                    }

                }

            }

            //list available blocks on this page, remove old ones first

            $('select#pageLinksDropdown option:not(:first)').remove();
            $('#pageList ul:visible iframe').each(function(){

                if( $(this).contents().find( bConfig.pageContainer + " > *:first" ).attr('id') !== undefined ) {

                    var newOption;

                    if( $(el).attr('href') === '#'+$(this).contents().find( bConfig.pageContainer + " > *:first" ).attr('id') ) {

                        newOption = '<option selected value=#'+$(this).contents().find( bConfig.pageContainer + " > *:first" ).attr('id')+'>#'+$(this).contents().find( bConfig.pageContainer + " > *:first" ).attr('id')+'</option>';

                    } else {

                        newOption = '<option value=#'+$(this).contents().find( bConfig.pageContainer + " > *:first" ).attr('id')+'>#'+$(this).contents().find( bConfig.pageContainer + " > *:first" ).attr('id')+'</option>';

                    }

                    $('select#pageLinksDropdown').append( newOption );

                }

            });

            //if there aren't any blocks to list, hide the dropdown

            if( $('select#pageLinksDropdown option').size() === 1 ) {

                $('select#pageLinksDropdown').next().hide();
                $('select#pageLinksDropdown').next().next().hide();

            } else {

                $('select#pageLinksDropdown').next().show();
                $('select#pageLinksDropdown').next().next().show();

            }

        },


        /*
            when the clicked element is an image
        */
        editImage: function(el) {

            $('a#img_Link').parent().show();

            //set the current SRC
            $('.imageFileTab').find('input#imageURL').val( $(el).attr('src') );

            //reset the file upload
            $('.imageFileTab').find('a.fileinput-exists').click();

        },


        /*
            when the clicked element is a video element
        */
        editVideo: function(el) {

            var matchResults;

            $('a#video_Link').parent().show();
            $('a#video_Link').click();

            //inject current video ID,check if we're dealing with Youtube or Vimeo

            if( $(el).prev().attr('src').indexOf("vimeo.com") > -1 ) {//vimeo

                matchResults = $(el).prev().attr('src').match(/player\.vimeo\.com\/video\/([0-9]*)/);

                $('#video_Tab input#vimeoID').val( matchResults[matchResults.length-1] );
                $('#video_Tab input#youtubeID').val('');

            } else {//youtube

                //temp = $(el).prev().attr('src').split('/');
                var regExp = /.*(?:youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=)([^#\&\?]*).*/;
                matchResults = $(el).prev().attr('src').match(regExp);

                $('#video_Tab input#youtubeID').val( matchResults[1] );
                $('#video_Tab input#vimeoID').val('');

            }

        },


        /*
            when the clicked element is an fa icon
        */
        editIcon: function() {

            $('a#icon_Link').parent().show();

            //get icon class name, starting with fa-
            var get = $.grep(this.activeElement.element.className.split(" "), function(v, i){

                return v.indexOf('fa-') === 0;

            }).join();

            $('select#icons option').each(function(){

                if( $(this).val() === get ) {

                    $(this).attr('selected', true);

                    $('#icons').trigger('chosen:updated');

                }

            });

        },


        /*
            delete selected element
        */
        deleteElement: function() {

            var toDel;

            //determine what to delete
            if( $(styleeditor.activeElement.element).prop('tagName') === 'A' ) {//ancor

                if( $(styleeditor.activeElement.element).parent().prop('tagName') ==='LI' ) {//clone the LI

                    toDel = $(styleeditor.activeElement.element).parent();

                } else {

                    toDel = $(styleeditor.activeElement.element);

                }

            } else if( $(styleeditor.activeElement.element).prop('tagName') === 'IMG' ) {//image

                if( $(styleeditor.activeElement.element).parent().prop('tagName') === 'A' ) {//clone the A

                    toDel = $(styleeditor.activeElement.element).parent();

                } else {

                    toDel = $(styleeditor.activeElement.element);

                }

            } else {//everything else

                toDel = $(styleeditor.activeElement.element);

            }


            toDel.fadeOut(500, function(){

                var randomEl = $(this).closest('body').find('*:first');

                toDel.remove();

                /* SANDBOX */

                var elementID = $(styleeditor.activeElement.element).attr('id');

                $('#'+styleeditor.activeElement.sandbox).contents().find('#'+elementID).remove();

                /* END SANDBOX */

                styleeditor.activeElement.parentBlock.heightAdjustment();

                //we've got pending changes
                siteBuilder.site.setPendingChanges(true);

            });

            $('#deleteElement').modal('hide');

            styleeditor.closeStyleEditor();

        },


        /*
            clones the selected element
        */
        cloneElement: function() {

            var theClone, theClone2, theOne, cloned, cloneParent, elementID;

            if( $(styleeditor.activeElement.element).parent().hasClass('propClone') ) {//clone the parent element

                theClone = $(styleeditor.activeElement.element).parent().clone();
                theClone.find( $(styleeditor.activeElement.element).prop('tagName') ).attr('style', '');

                theClone2 = $(styleeditor.activeElement.element).parent().clone();
                theClone2.find( $(styleeditor.activeElement.element).prop('tagName') ).attr('style', '');

                theOne = theClone.find( $(styleeditor.activeElement.element).prop('tagName') );
                cloned = $(styleeditor.activeElement.element).parent();

                cloneParent = $(styleeditor.activeElement.element).parent().parent();

            } else {//clone the element itself

                theClone = $(styleeditor.activeElement.element).clone();

                theClone.attr('style', '');

                /*if( styleeditor.activeElement.sandbox ) {
                    theClone.attr('id', '').uniqueId();
                }*/

                theClone2 = $(styleeditor.activeElement.element).clone();
                theClone2.attr('style', '');

                /*
                if( styleeditor.activeElement.sandbox ) {
                    theClone2.attr('id', theClone.attr('id'));
                }*/

                theOne = theClone;
                cloned = $(styleeditor.activeElement.element);

                cloneParent = $(styleeditor.activeElement.element).parent();

            }

            cloned.after( theClone );

            /* SANDBOX */

            if( styleeditor.activeElement.sandbox ) {

                elementID = $(styleeditor.activeElement.element).attr('id');
                $('#'+styleeditor.activeElement.sandbox).contents().find('#'+elementID).after( theClone2 );

            }

            /* END SANDBOX */

            //make sure the new element gets the proper events set on it
            var newElement = new canvasElement(theOne.get(0));
            newElement.activate();

            //possible height adjustments
            styleeditor.activeElement.parentBlock.heightAdjustment();

            //we've got pending changes
            siteBuilder.site.setPendingChanges(true);

        },


        /*
            resets the active element
        */
        resetElement: function() {

            if( $(styleeditor.activeElement.element).closest('body').width() !== $(styleeditor.activeElement.element).width() ) {

                $(styleeditor.activeElement.element).attr('style', '').css({'outline': '3px dashed red', 'cursor': 'pointer'});

            } else {

                $(styleeditor.activeElement.element).attr('style', '').css({'outline': '3px dashed red', 'outline-offset':'-3px', 'cursor': 'pointer'});

            }

            /* SANDBOX */

            if( styleeditor.activeElement.sandbox ) {

                var elementID = $(styleeditor.activeElement.element).attr('id');
                $('#'+styleeditor.activeElement.sandbox).contents().find('#'+elementID).attr('style', '');

            }

            /* END SANDBOX */

            $('#styleEditor form#stylingForm').height( $('#styleEditor form#stylingForm').height()+"px" );

            $('#styleEditor form#stylingForm .form-group:not(#styleElTemplate)').fadeOut(500, function(){

                $(this).remove();

            });


            //reset icon

            if( styleeditor._oldIcon[$(styleeditor.activeElement.element).attr('id')] !== null ) {

                var get = $.grep(styleeditor.activeElement.element.className.split(" "), function(v, i){

                    return v.indexOf('fa-') === 0;

                }).join();

                $(styleeditor.activeElement.element).removeClass( get ).addClass( styleeditor._oldIcon[$(styleeditor.activeElement.element).attr('id')] );

                $('select#icons option').each(function(){

                    if( $(this).val() === styleeditor._oldIcon[$(styleeditor.activeElement.element).attr('id')] ) {

                        $(this).attr('selected', true);
                        $('#icons').trigger('chosen:updated');

                    }

                });

            }

            setTimeout( function(){styleeditor.buildeStyleElements( $(styleeditor.activeElement.element).attr('data-selector') );}, 550);

            siteBuilder.site.setPendingChanges(true);

        },


        resetSelectLinksPages: function() {

            $('#internalLinksDropdown').select2('val', '#');

        },

        resetSelectLinksInternal: function() {

            $('#pageLinksDropdown').select2('val', '#');

        },

        resetSelectAllLinks: function() {

            $('#internalLinksDropdown').select2('val', '#');
            $('#pageLinksDropdown').select2('val', '#');
            this.select();

        },

        /*
            hides file upload forms
        */
        hideFileUploads: function() {

            $('form#imageUploadForm').hide();
            $('#imageModal #uploadTabLI').hide();

        },


        /*
            closes the style editor
        */
        closeStyleEditor: function(){

            if( Object.keys(styleeditor.activeElement).length > 0 ) {
                styleeditor.activeElement.removeOutline();
                styleeditor.activeElement.activate();
            }

            if( $('#styleEditor').css('left') === '0px' ) {

                styleeditor.toggleSidePanel('close');

            }

        },


        /*
            toggles the side panel
        */
        toggleSidePanel: function(val) {

            if( val === 'open' && $('#styleEditor').css('left') === '-300px' ) {
                $('#styleEditor').animate({'left': '0px'}, 250);
            } else if( val === 'close' && $('#styleEditor').css('left') === '0px' ) {
                $('#styleEditor').animate({'left': '-300px'}, 250);
            }

        },


        /*
            Event handler for when this mode gets deactivated
        */
        deActivateMode: function() {

            if( Object.keys( styleeditor.activeElement ).length > 0 ) {
                styleeditor.closeStyleEditor();
            }

            //deactivate all style items on the canvas
            for( var i =0; i < styleeditor.allStyleItemsOnCanvas.length; i++ ) {
                styleeditor.allStyleItemsOnCanvas[i].deactivate();
            }

            //Add overlay again
            // for(var i = 1; i <= $("ul#page1 li").length; i++){
            //     var id = "#ui-id-" + i;
            //     alert(id);
            //     // overlay = $('<span class="overlay"><span class="fui-eye"></span></span>');
            //     // $(id).contents().find('a.over').append( overlay );
            // }

        }

    };

    styleeditor.init();

    exports.styleeditor = styleeditor;

}());
},{"./builder.js":3,"./canvasElement.js":4,"./config.js":5}],8:[function(require,module,exports){
(function () {

/* globals siteUrl:false, baseUrl:false */
    "use strict";
        
    var appUI = {
        
        firstMenuWidth: 190,
        secondMenuWidth: 300,
        loaderAnimation: document.getElementById('loader'),
        secondMenuTriggerContainers: $('#menu #main #elementCats, #menu #main #templatesUl'),
        siteUrl: siteUrl,
        baseUrl: baseUrl,
        
        setup: function(){
            
            // Fade the loader animation
            $(appUI.loaderAnimation).fadeOut(function(){
                $('#menu').animate({'left': -appUI.firstMenuWidth}, 1000);
            });
            
            // Tabs
            $(".nav-tabs a").on('click', function (e) {
                e.preventDefault();
                $(this).tab("show");
            });
            
            $("select.select").select2();
            
            $(':radio, :checkbox').radiocheck();
            
            // Tooltips
            $("[data-toggle=tooltip]").tooltip("hide");
            
            // Table: Toggle all checkboxes
            $('.table .toggle-all :checkbox').on('click', function () {
                var $this = $(this);
                var ch = $this.prop('checked');
                $this.closest('.table').find('tbody :checkbox').radiocheck(!ch ? 'uncheck' : 'check');
            });
            
            // Add style class name to a tooltips
            $(".tooltip").addClass(function() {
                if ($(this).prev().attr("data-tooltip-style")) {
                    return "tooltip-" + $(this).prev().attr("data-tooltip-style");
                }
            });
            
            $(".btn-group").on('click', "a", function() {
                $(this).siblings().removeClass("active").end().addClass("active");
            });
            
            // Focus state for append/prepend inputs
            $('.input-group').on('focus', '.form-control', function () {
                $(this).closest('.input-group, .form-group').addClass('focus');
            }).on('blur', '.form-control', function () {
                $(this).closest('.input-group, .form-group').removeClass('focus');
            });
            
            // Table: Toggle all checkboxes
            $('.table .toggle-all').on('click', function() {
                var ch = $(this).find(':checkbox').prop('checked');
                $(this).closest('.table').find('tbody :checkbox').checkbox(!ch ? 'check' : 'uncheck');
            });
            
            // Table: Add class row selected
            $('.table tbody :checkbox').on('check uncheck toggle', function (e) {
                var $this = $(this)
                , check = $this.prop('checked')
                , toggle = e.type === 'toggle'
                , checkboxes = $('.table tbody :checkbox')
                , checkAll = checkboxes.length === checkboxes.filter(':checked').length;

                $this.closest('tr')[check ? 'addClass' : 'removeClass']('selected-row');
                if (toggle) $this.closest('.table').find('.toggle-all :checkbox').checkbox(checkAll ? 'check' : 'uncheck');
            });
            
            // Switch
            $("[data-toggle='switch']").wrap('<div class="switch" />').parent().bootstrapSwitch();
                        
            appUI.secondMenuTriggerContainers.on('click', 'a:not(.btn)', appUI.secondMenuAnimation);
                        
        },
        
        secondMenuAnimation: function(){
        
            $('#menu #main a').removeClass('active');
            $(this).addClass('active');
	
            //show only the right elements
            $('#menu #second ul li').hide();
            $('#menu #second ul li.'+$(this).attr('id')).show();

            if( $(this).attr('id') === 'all' ) {
                $('#menu #second ul#elements li').show();		
            }
	
            $('.menu .second').css('display', 'block').stop().animate({
                width: appUI.secondMenuWidth
            }, 500);	
                
        }
        
    };
    
    //initiate the UI
    appUI.setup();


    //**** EXPORTS
    module.exports.appUI = appUI;
    
}());
},{}],9:[function(require,module,exports){
(function () {
	"use strict";
    
    exports.getRandomArbitrary = function(min, max) {
        return Math.floor(Math.random() * (max - min) + min);
    };
    
}());
},{}]},{},[1]);
