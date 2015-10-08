module RailsDbAdmin
  class ErbStringParser
    ERB_REGEX_PATTERN = /\<\%\=\s*(\$|@{1,2})?[A-Za-z][A-Za-z0-9_]*\s*\%\>/
    class << self
      def render(str, options = {})
        locals = options[:locals] || {}
        # convert all variables to underscore as
        # ERB parser has issues with capitalized variables
        _str = str.gsub(ERB_REGEX_PATTERN) do |w|
          w.delete(' ').underscore 
        end
        # convert all to locals to underscore
        _locals = {}
        locals.each do |k,v|
          _locals[k.to_s.delete(' ').underscore] = v
        end
        
        query_params = RailsDbAdmin::QueryParams.new(_locals)
        ERB.new(_str).result(query_params.get_binding)
      end

    end
  end
end
