require 'spec_helper'

describe WebServer::HttpdConf do
  let(:conf_file) { 'httpd.conf' }
  let(:conf_file_path) { File.join FIXTURES_DIRECTORY, conf_file }
  let(:options) { {configuration_directory: FIXTURES_DIRECTORY, conf_file: conf_file} }
  let(:httpd_file) { WebServer::HttpdConf.new(options) }

  describe '#initialize' do
    it 'reads the correct file' do
      expect(File).to receive(:new).with(conf_file_path, 'r')
      httpd_file # instantiate object via let
    end
  end

  describe '#server_root' do
    it 'returns the server_root' do
      expect(httpd_file.server_root).to eq 'server_root/with/path'
    end
  end

  describe '#document_root' do
    it 'returns the document_root' do
      expect(httpd_file.document_root).to eq 'document_root'
    end
  end

  describe '#directory_index' do
    it 'returns the directory_index' do
      expect(httpd_file.directory_index).to eq 'i.html'
    end
  end

  describe '#port' do
    it 'returns the port' do
      expect(httpd_file.port).to eq 1234
    end
  end

  describe '#log_file' do 
    it 'returns the log file' do
      expect(httpd_file.log_file).to eq 'log_file'
    end
  end

  describe '#access_file_name' do 
    it 'returns the access file' do
      expect(httpd_file.access_file_name).to eq 'access_file'
    end
  end

  describe '#script_aliases' do
    let(:aliases) { ['/script_alias/', '/script_alias_2/'] }

    it 'returns a list of script aliases' do
      expect(httpd_file.script_aliases).to include *aliases
    end
  end

  describe '#script_alias_path' do
    it 'returns the aliased path' do
      expect(httpd_file.script_alias_path('/script_alias/')).to eq 'script/alias/directory'
    end

    it 'returns nil when aliased path does not exist' do
      expect(httpd_file.script_alias_path('/none')).to be_nil
    end

    it 'matches only complete matches' do
      expect(httpd_file.script_alias_path('/script_alias')).to be_nil
    end
  end

  describe '#aliases' do
    let(:aliases) { ['/ab/', '/~traciely/'] }

    it 'returns a list of script aliases' do
      expect(httpd_file.aliases).to include *aliases
    end
  end

  describe '#alias_path' do
    it 'returns the aliased path' do
      expect(httpd_file.alias_path('/ab/')).to eq 'alias/public_html/ab1/ab2/'
    end

    it 'returns nil when aliased path does not exist' do
      expect(httpd_file.alias_path('/none')).to be_nil
    end

    it 'matches only complete matches' do
      expect(httpd_file.alias_path('/ab')).to be_nil
    end
  end
end

