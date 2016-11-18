# HttpdConf and MimeTypes, both derived from this parent class.
module WebServer
  class Configuration
    attr_accessor :file, :hash

    # open the file and parse it, store the data in hash
    def initialize(options={})	
      @hash = Hash.new
      open_file options
      parse_file
    end
  
    # parse options to obtain the full directory for the file
    # File.join saves the work of iterating the hash to obtain the file path
    def open_file options
      path = File.join options.values
      raise ArgumentError unless File.exists?(path)
      @file = File.new(path, 'r')
    end

    # read the file data into hash
    # 3 steps:
    # 1. discard empty line and comments
    # 2. extract the information in key-value format and store it in an array
    # 3. store the data in the array into the hash
    def parse_file()
      unless @file.nil?
        @file.each do |line|
          line.chomp!
          # puts line
          if line.empty? || line =~ /(\s*)#(.*)/i
            next
          else
            info = extract_info(line)
            store info
          end
        end
      end
    end
    
    # extract the information from the passed in string
    # split the string into an array. the first element should be the key and the rest are the value (to store in the hash)
    # clean the value if needed.
    # return a new array with two elements: key and value 
    def extract_info(line)
      array = line.split
      key = array.first
      value = array.drop(1)   # drop the first element
      value.each{|e| e.delete! "\""}
      return key, value
    end

    # store the information into the hash
    # needs to be override in subclasses   
    def store(info)
    end
  end
end
