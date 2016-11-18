require 'socket'
Dir.glob('lib/**/*.rb').each do |file|
  require file
end

module WebServer
  class Server
    DEFAULT_PORT = 2468

    attr_accessor :conf, :mime, :logger

    def initialize(options={})
      # Set up WebServer's configuration files and logger here
      # Do any preparation necessary to allow threading multiple requests
      @conf = HttpdConf.new conf_path
      @mime = MimeTypes.new mime_path
      @logger = Logger.new log_path 
    end

    def current_dir
      File.dirname(__FILE__)
    end

    def conf_dir
      File.join current_dir, 'config'
    end

    def conf_path
      {configuration_directory: conf_dir, conf_file: 'httpd.conf'}
    end
   
    def mime_path
      {configuration_directory: conf_dir, mime_file: 'mime.types'}
    end

    def log_path
      File.join current_dir, @conf.log_file
    end
    def start
      # Begin your 'infinite' loop, reading from the TCPServer, and
      # processing the requests as connections are made
      # @logger.log_message="{SERVER} Starts on port #{conf.port}"

      #creating a thread when socket opened
      #create worker with socket
      while true 
       Thread.start(server.accept) do |client|
         Worker.new(client,self)
         client.close
        end
        @logger.close
      end
    end

    def server
      @server ||= TCPServer.open(@conf.port)
    end

    private
  end
end

WebServer::Server.new.start
