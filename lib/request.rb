# The Request class encapsulates the parsing of an HTTP Request
module WebServer
  class Request
    attr_accessor :http_method, :uri, :version, :headers, :body, :params

    # Request creation receives a reference to the socket over which
    # the client has connected
    def initialize(socket)
      # Perform any setup, then parse the request
      @socket = socket
      @body = ""
      @headers = Hash.new
      @params = Hash.new
      parse
      # print to_s
    end

    # This method is purely for the purpose of debugging.
    def to_s
      output = "--------------------------------\n"

      output += "#{@http_method} #{@uri} #{@version}\n"

      @params.keys.each do |key|
        output += "#{key}: #{@params[key]}\n"
      end

      output += "\n"
  
      @headers.keys.each do |header|
        output += "#{header}: #{@headers[header]}\n"
      end

      output += "\n"

      unless @body.nil?
        output += "#{@body}\n"
      end

      output += "--------------------------------\n"

      output
    end

    # I've added this as a convenience method, see TODO (This is called from the logger
    # to obtain information during server logging)
    def user_id
      # TODO: This is the userid of the person requesting the document as determined by 
      # HTTP authentication. The same value is typically provided to CGI scripts in the 
      # REMOTE_USER environment variable. If the status code for the request (see below) 
      # is 401, then this value should not be trusted because the user is not yet authenticated.
      '-'
    end

    # Parse the request from the socket - Note that this method takes no parameters
    # HTTP Request format:
    # Method Request-URI HTTP-Version
    # Headers
    #
    # Body (optional)
   
    # 1. parse the first line - request line
    # 2. parse lines as headers until reading an empty line
    # 3. parse the body until EOF
    def parse
      parse_request_line
      while (line = next_line) != nil do
        if !line.empty?        
           parse_header(line)
        else break
        end
      end
      while (line = next_line) != nil do
        parse_body(line)
      end
    end

    def next_line
      @socket.readline.chomp! unless @socket.eof?
    end

    # request line format: 
    # Method Request-URI HTTP-Version
    # note that URI is followed by '?' if there are parameters
    def parse_request_line
      array = next_line.split
      @http_method = array.first
      @version = array.last
      array[1].match(/([^\?]*)\?(.*)/)
      @uri = $1
      parse_params($2)
    end

    # store header in key-value format in headers
    # needs to convert '-' => '_' and downcase to upcase
    # this is due to the EVN CGI
    def parse_header(header_line)
      header_line.match(/(.*):\s(.*)/)
      value = $2
      key = $1.gsub('-', '_').upcase
      @headers.store key, value
    end

    def parse_body(body_line)
      @body += body_line
    end

    # parametera are seperated with '&', and they are in key-value pair seperated with '=' 
    def parse_params(string)
      unless string == nil
        param_array = string.split('&')
        param_array.each do |e|
          e = e.split('=')
          @params.store(e.first, e.last)
        end
      end
    end
  end
end
