# Parses, stores, and exposes the values from the httpd.conf file
module WebServer
  class HttpdConf < Configuration
 
    def initialize(options={})
      super(options)
    end

    # @override
    # store the information into the hash
    # two situation:
    # 1. if value is a two elements array, the key-value is for alias data, and will be stored in a subhash
    #    if the key is first time found, create a new subhash
    #    store the value in key-value format in the subhash
    # 2. if value is a one element array, the key-value is for non-alias data. just store the data into the hash
    def store(info)
      key = info.first
      value = info.last
      if value.length == 2         # alias type
        unless @hash.has_key? key  # first time key
          sub_hash = Hash.new      # create a new hash for the new key
          @hash.store(key, sub_hash)
        end
        # store value into the subhash, note value is a two element array
        sub_key = value.first
        sub_value = value.last
        sub_hash = @hash[key]      # retrieve the subhash
        sub_hash.store sub_key, sub_value
      else  # non-alias data, note the value is a one element array
        @hash.store(key, value.first)
      end
    end
  
    # Returns the value of the ServerRoot
    def server_root 
      @hash["ServerRoot"]
    end

    # Returns the value of the DocumentRoot
    def document_root
      @hash["DocumentRoot"]
    end

    # Returns the directory index file
    def directory_index
      @hash["DirectoryIndex"]
    end

    # Returns the *integer* value of Listen
    def port
      @hash["Listen"].to_i
    end

    # Returns the value of LogFile
    def log_file
      @hash["LogFile"]
    end

    # Returns the name of the AccessFile 
    def access_file_name
      @hash["AccessFileName"]
    end

    # Returns an array of ScriptAlias directories
    def script_aliases
      @hash["ScriptAlias"].keys
    end

    # Returns the aliased path for a given ScriptAlias directory
    def script_alias_path(path)
      @hash["ScriptAlias"][path]
    end

    # Returns an array of Alias directories
    def aliases
      @hash["Alias"].keys
    end

    # Returns the aliased path for a given Alias directory
    def alias_path(path)
      @hash["Alias"][path]
    end
  end
end
