// A statement builder which constructs widget render statements so that
// the individual widget needn't hand construct them.
Ext.ns('Compass.ErpApp.Shared.Helpers').WidgetStatementBuilder = (function(){
    
    function _buildTemplate(options) {
        var widgetName = options.widgetName,
            websiteBuilder = options.websiteBuilder,
            action = options.action,
            paramsArray = options.paramsArray;
        
        var statement = _renderStatement(widgetName, websiteBuilder),
            statementOffset = statement.indexOf(':');
        
        templateStatement = "<%= "
            + _renderStatement(widgetName, websiteBuilder, action, statementOffset) + ",\n"
            + Ext.String.repeat(' ', statementOffset + 5) + "params: {\n"
            + _renderStatementParams(paramsArray, statementOffset)
            + "\n" + Ext.String.repeat(' ', statementOffset + 5) +
            "}\n %>"

        return new Ext.Template(templateStatement);
    }

    function _renderStatement(widgetName, websiteBuilder, action, statementOffset) {
        var statementStr = websiteBuilder ? "render_builder_widget ": "render_widget";
        statementStr += " :" + widgetName;
        if (action != undefined) {
            statementStr += ",\n" + Ext.String.repeat(' ', statementOffset + 5) + "action: :" + action;
        }
             
        return statementStr;
    }


    function _renderStatementParams(paramsArray, statementOffset) {
        return Ext.Array.map((paramsArray || []), function(params){
            var paramStr = Ext.String.repeat(' ', statementOffset + 7)
                + (params.commented ? "# " : '')
                + (params.isVariable ? params.key + ": " + "'{" + params.value + "}'" : params.key + ": " + params.value);
            if(Compass.ErpApp.Utility.isBlank(params.comment)) {
                return paramStr
            } else {
                return Ext.String.repeat(' ', statementOffset + 7)
                    +
                    "# " + params.comment
                    + "\n" + paramStr;
            }    
        }).join(",\n");
        
    }

    return {
        buildTemplate: _buildTemplate
    };

})();
