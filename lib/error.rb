# This class is not required, but it makes it handy for
# processing errors of your own creation...

module WebServer
  class Error < StandardError

      attr_reader :client, :request, :root_exception
      
      def initialize(exception, request, client, response)
          @root_exception=exception
          @request=request
          @client=client
          @response=response
      end
      
      def method_missing(method, *args)
          if root_exception.response_to?(method)
              return root_exception.send(method, *args)
          end
          
          super
      end
  end
end
