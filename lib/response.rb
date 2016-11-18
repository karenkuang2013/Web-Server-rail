# "require" is similar to import in Java
# require_relative  include files from a relative directory
#
# modules are a way of groupting together methods, classes and constants. modules give you two major benefits:
# 1. provide a namespace and prevent name clashes
# 2. implement mixin facility
# ModuleName.method / MOduleName::Constant
# ---------------relative info about code here ---------------------------------

require_relative 'response/base'

module WebServer
  module Response
    DEFAULT_HTTP_VERSION = 'HTTP/1.1'

    RESPONSE_CODES = {
      200 => 'OK',
      201 => 'Successfully Created',
      304 => 'Not Modified',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      500 => 'Internal Server Error'
    }

    def self.default_headers
      {
        'Date' => Time.now.strftime('%a, %e %b %Y %H:%M:%S %Z'),
        'Server' => 'John Roberts CSC 667'
      }
    end

    module Factory
      def self.create(resource)
        if resource.protected?
          if !auth_info? # no Authorization header, 401
            response = Response::Unauthorized.new(resource)
          else 
            if !resource.authorized? # 403
              response = Response::Forbidden.new(resource) 
            else
              # work the same as no authorization needed 
              response = no_auth_response resource
            end
          end
        else
          response = no_auth_response resource
        end
        response
      end
   
      def no_auth_response resource
        case resource.request_method
        when "POST" || "PUT"
          Response::SuccessfullyCreated.new(resource)
        when "GET"
          if !File.exists? resource.resolve
            Response::NotFound.new(resource)
          else
            Response::Base.new(resource) 
            # need to check cache
          end
        end
      end 

      def self.error(resource, error_object)
        Response::ServerError.new(resource, exception: error_object)
      end

    end
  end
end
