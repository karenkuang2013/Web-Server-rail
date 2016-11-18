require_relative 'configuration'

# Parses, stores and exposes the values from the mime.types file
module WebServer
  class MimeTypes < Configuration
    def initialize(options={})
      super(options)
    end
  
    # @override
    # store information into hash
    # store all the provided mimetype extentions and mimetypes as key-value pari in the hash
    def store(info)
      value = info.first
      keys = info.last
      unless keys == value
        keys.each do |e|
          @hash.store e, value 
        end
      end
    end
    
    # Returns the mime type for the specified extension
    def for_extension(extension)
      @hash[extension]
    end
  end
end
