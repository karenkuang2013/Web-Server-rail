module WebServer
  module Response
    # Class to handle 401 responses
    class Unauthorized < Base
      def initialize(resource, options={})
        super(resource,options)
        @code = 401
        @headers.store "WWW-Authenticate", "Basic"
      end
    end
  end
end
