require 'spec_helper'

describe WebServer::MimeTypes do
  describe '#initialize' do
    let(:mime_file) { 'mime.types' }
    let(:mime_file_path) { File.join FIXTURES_DIRECTORY, mime_file }
    let(:options) { {configuration_directory: FIXTURES_DIRECTORY, mime_file: mime_file} }
    let(:mime_types) { WebServer::MimeTypes.new(options) }

    it 'reads the correct file' do
      expect(File).to receive(:new).with(mime_file_path, 'r')
      WebServer::MimeTypes.new(options)
    end

    it 'returns the correct mime type (single entry)' do
      expect(mime_types.for_extension('png')).to eq 'image/png'
    end

    it 'returns the correct mime type (multiple entry)' do
      expect(mime_types.for_extension('jpeg')).to eq 'image/jpeg'
      expect(mime_types.for_extension('jpg')).to eq 'image/jpeg'
      expect(mime_types.for_extension('jpe')).to eq 'image/jpeg'
    end
  end
end
