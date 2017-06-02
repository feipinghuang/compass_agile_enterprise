Ext.ns('Compass.ErpApp.Desktop.Applications.Knitkit').WidgetDndHelper = (function(){

    function _startDragDrop() {
        if (!win.dragoverqueueProcessTimerTask) {
            win.dragoverqueueProcessTimerTask = new Compass.ErpApp.Utility.TimerTask(function() {
                DragDropFunctions.ProcessDragOverQueue();
            }, 100);
            win.dragoverqueueProcessTimerTask.start();
        }
        DragDropFunctions.AddEntryToDragOverQueue(currentElement, elementRectangle, mousePosition);
    }

    function _endDragDrop() {
        if (win.dragoverqueueProcessTimerTask && win.dragoverqueueProcessTimerTask.isRunning()) {
            win.dragoverqueueProcessTimerTask.stop();
            DragDropFunctions.removePlaceholder();
            DragDropFunctions.ClearContainerContext();
            win.dragoverqueueProcessTimerTask = null;
        }
    }
    
    function _insertWidget(widgetSource) {
        // get the drop markers
        var insertionPoint = jQuery("iframe").contents().find(".drop-marker");
        
        // get the container frame from the insertion point
        var containerFrame = document.getElementById(insertionPoint.parents('.item.content').attr('id') + '-frame'),
            containerWindow = containerFrame.contentWindow,
            containerDocument = containerFrame.contentDocument || containerWindow.document;

        // The widget source contains DOM elements and script tags which needs
        // to be executed in the context of the container iframe.
        
        var dropComponent = jQuery(widgetSource);
        // accumulate scripts
        scripts = [];
        dropComponent.children().filter('script').each(function(){
            scripts.push(jQuery(this).detach().html());
        });
        // insert widget DOM
        insertionPoint.after(dropComponent);
        
        // execute accumulated scripts
        scripts.forEach(function(script){
            var expression = 'return function(window, document){\n' + script + '\n}',
                scriptFunc = new Function(expression)();
            scriptFunc.apply(containerWindow, [containerWindow, containerDocument]);
        });

        //remove drop markers 
        insertionPoint.remove();
        
        return dropComponent;
    }

})();
    
    
    
