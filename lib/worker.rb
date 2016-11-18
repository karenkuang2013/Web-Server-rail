require_relative 'request'
require_relative 'response'

# This class will be executed in the context of a thread, and
# should instantiate a Request from the client (socket), perform
# any logging, and issue the Response to the client.
module WebServer
  class Worker
    # Takes a reference to the client socket and the server object
    def initialize(client, server=nil)
        @client = client 
        @server = server
        process_request
    end

    # Processes the request
    def process_request
      logger = @server.logger
      request = WebServer::Request.new @client
      resource = WebServer::Resource.new request, @server.conf, @server.mime 
      response = WebServer::Response::Factory.create resource
      logger.log request, response
      @client.puts response
    end
  end
end
