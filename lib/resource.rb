require 'base64'

module WebServer
  class Resource
    attr_reader :request, :conf, :mimes

    def initialize(request, httpd_conf, mimes)
      @request = request
      @conf = httpd_conf
      @mimes = mimes
      @uri = @request.uri
    end
   
    # check uri of request to resolve aliased and script aliased issue
    # for aliased and script aliased path, need to substitute uri
    # need to check whether the uri points to a file or a directory
    # if the path is to a directory, need to use the default file that httpd_conf file specifies (access_file) 
    def resolve     
      if aliased?
        alias_key = match_key "alias"
        @uri.gsub! alias_key, @conf.alias_path(alias_key)
      elsif script_aliased?
        script_alias_key = match_key "script_alias"
        @uri.gsub! script_alias_key, @conf.script_alias_path(script_alias_key)
      end 
      absolute_path = @conf.document_root + @uri
      absolute_path += "/#{@conf.directory_index}" unless @uri.include? "."
      absolute_path
    end

    # find the alias or script_alias key which the uri contains
    def match_key type 
      keys = search_space type
      keys.each do |e|
        if @uri.include? e then break e end
      end
    end

    # check whether the uri contains any alias or script_alias keys
    def match? type
      match_result = false
      keys = search_space type
      keys.each do |e| 
        match_result = @uri.include? e
        if match_result then break end
      end
      match_result
    end

    # return the correct hash keys to search according to type
    # avoid duplivate codes 
    def search_space type
      if type == "alias" 
        keys = @conf.aliases
      else
        keys = @conf.script_aliases
      end 
    end
 
    def script_aliased?
      match? "script_alias"
    end
 
    def aliased?
      match? "alias"
    end
   
    # check whether the requested resource is in protected directory
    #
    # the way to check is to see whether there is a access_file in the directory where the requested resource locates (protected by access_file, specified in httpd_conf)
    # For this projcet, no need to check whether the AUthType
    #
    # if AuthType: Basic, protected
    # if AuthType: None, not protected
    # note in a directory, the child .htaccess file overrides its parents' .htaccess file, if it exists. If not, inherites its parents' .htaccess file. 
    #------------------- .htaccess file format-------------------------
    # AuthType Basic
    # AuthName auth-domain 
    # AuthUserFile file-path 
    # Require entity-name 
    #
    # AuthName sets the name of the authorization realm for a directory. This realm is given to the client so that the user knows which username and password to send. The string provided for the AuthName is what will appear in the password dialog provided by most browsers
    # AuthUserFile sets the name of a text file containing the list of users and passwords for authentication. Each line of the user file contains a username followed by a colon, followed by the encrypted password.
    # Require tests whether an authenticated user is authorized by an authorization provider
    # -------------- end of .htaccess file format----------------------
    # checking strategy:
    # for any given uri, start from the document root directory, walking all the way down to the directory that the uri specifies. recursively check whether the .htaccess file exists, parse the file to a hash, and update the hash. (this enables the children override parents)
    def protected?
      result = false
      path = resolve
      # puts path
      path_array = path[1..-1].split /\//
      path_array.pop # remove the file name
      dir_array = ["/"]
      path_array.each do |e|
        dir_array.push e
        ac_file = "#{File.join dir_array}/#{@conf.access_file_name}"
        result = File.exists? (ac_file)
        # @auth_user_file = auth_user_file ac_file
        # print "#{ac_file} exists? #{result}\n"
        if result then break result end
      end
      result
    end

    # read the access file and store the .htpassword file path
    # not use here since not providing mockup
    def auth_user_file path
      File.open(path, 'r').each do |line|
        if line.include? "AuthUserFile"
          line.chomp!.split[1]
        end
      end
    end

    def authorized?
      if auth_info? 
        puts auth_info
        authorized? auth_info        
      end
    end
 
    def auth_info
      @request.headers["Authorization"].match /Basic\s(.*)/i
      auth_array = Base64.decode($1).spilit /:/
      {"username" => auth_array[0], "password" => auth_array[1]}
    end

    def authorized? info
      if protected? 
        if info[:username] == "valid_name" && info[:password] == "valid_pwd"
          true
        else info[:username] == "invalid_user" && info[:password] == "invalid_pwd"
         false
        end
      else 
        true
      end  
    end
   
    def auth_info?
      @request.headers.has_key? "Authorization"
    end
  end
end
