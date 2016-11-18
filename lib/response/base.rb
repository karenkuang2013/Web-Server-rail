module WebServer
  module Response
    # Provides the base functionality for all HTTP Responses 
    # (This allows us to inherit basic functionality in derived responses
    # to handle response code specific behavior)
    class Base
      attr_reader :version, :code, :headers, :body

      def initialize(resource, options={})
        @version = DEFAULT_HTTP_VERSION
        @code = 200 
        @headers = Response.default_headers
        @body = ""
      end

      def to_s
        "#{@version} #{@code} #{message}\n #{@headers}\n\n#{@body}"
      end

      def message
        RESPONSE_CODES[@code]
      end

      def content_length
        @body.length
      end
    end
  end
end
