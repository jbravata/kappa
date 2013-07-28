require 'rspec'
require 'kappa'
require 'common'

describe Twitch::Connection do
  after do
    WebMock.reset!
  end

  describe '#get' do
    it 'raises Arugment error if no path is specified' do
      expect {
        c = Twitch::V2::Connection.new('client_id')
        content = c.get
      }.to raise_error(ArgumentError)
    end

    it 'raises ResponseFormatError if response is not valid JSON' do
      stub_request(:any, /.*api\.twitch\.tv.*/)
        .to_return(:body => '"Invalid JSON')

      expect {
        c = Twitch::V2::Connection.new('client_id')
        json = c.get('/test')
      }.to raise_error(Twitch::Error::ResponseFormatError)
    end

    it 'raises ResponseFormatError with request URL' do
      stub_request(:any, /.*api\.twitch\.tv.*/)
        .to_return(:body => '"Invalid JSON')

      begin
        c = Twitch::V2::Connection.new('client_id')
        json = c.get('/test')
        fail 'Should have raised an error.'
      rescue Twitch::Error::ResponseFormatError => e
        e.request_url.should =~ /test/ 
      end
    end
  end
end