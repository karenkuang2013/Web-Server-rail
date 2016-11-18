module WebServer
  class Logger

    # Takes the absolute path to the log file, and any options
    # you may want to specify.  I include the option :echo to 
    # allow me to decide if I want my server to print out log
    # messages as they get generated
    def initialize(log_file_path, options={})
      @log_file = File.open log_file_path, 'w'
      @log_no = 0;
    end
    
    # Log a message using the information from Request and 
    # Response objects
    def log(request, response)
      time = Time.new.strftime("%Y-%m-%d %H-%M-%S")
      http_request = "#{request.http_method} #{request.uri}"
      http_response = "#{response.code}"
      @log_file.puts "#{++@log_no} -- [#{time}] #{http_request} #{http_response}"
    end

    # Allow the consumer of this class to flush and close the 
    # log file
    def close
      @log_file.close
    end
  end
end
