module RailsDbAdmin
  class ErbStringParser
    class << self
      def render(str, options = {})
        locals = options[:locals] || {}
        
        query_params = RailsDbAdmin::QueryParams.new(locals)
        ERB.new(str).result(query_params.get_binding)
      end
    end
    
  end # ErbStringParser
end # RailsDbadmin
