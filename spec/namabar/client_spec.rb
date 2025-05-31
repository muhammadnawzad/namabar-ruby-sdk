# frozen_string_literal: true

RSpec.describe Namabar::Client do
  let(:api_key) { 'test-api-key' }

  before do
    Namabar.configure do |config|
      config.api_key = api_key
    end
  end

  describe '#initialize' do
    it 'creates a client instance' do
      client = described_class.new
      expect(client).to be_a(described_class)
    end

    it 'includes HTTParty functionality' do
      expect(described_class).to include(HTTParty)
    end

    it 'includes Endpoints module' do
      expect(described_class).to include(Namabar::Endpoints)
    end

    it 'sets the base URI' do
      expect(described_class.base_uri).to eq('https://api.namabar.krd')
    end

    it 'sets default headers including API key' do
      headers = described_class.headers

      expect(headers['Content-Type']).to eq('application/json')
      expect(headers['Accept']).to eq('application/json')
      expect(headers['X-API-Key']).to eq(api_key)
    end

    context 'when configuration is missing' do
      before do
        Namabar.configuration = nil
      end

      it 'raises an error when api_key is nil' do
        expect { described_class.new }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#default_options' do
    let(:client) { described_class.new }

    it 'returns a hash with headers' do
      options = client.default_options
      expect(options).to be_a(Hash)
      expect(options).to have_key(:headers)
    end

    it 'includes all the configured headers' do
      options = client.default_options
      headers = options[:headers]

      expect(headers['Content-Type']).to eq('application/json')
      expect(headers['Accept']).to eq('application/json')
      expect(headers['X-API-Key']).to eq(api_key)
    end
  end

  describe 'header configuration' do
    it 'can add extra headers to requests' do
      # Create client with standard headers
      client = described_class.new

      # Test that we can modify headers
      described_class.headers('Custom-Header' => 'custom-value')

      options = client.default_options
      expect(options[:headers]['Custom-Header']).to eq('custom-value')

      # Standard headers should still be present
      expect(options[:headers]['Content-Type']).to eq('application/json')
      expect(options[:headers]['Accept']).to eq('application/json')
      expect(options[:headers]['X-API-Key']).to eq(api_key)
    end

    it 'allows per-request header customization' do
      client = described_class.new

      # Mock a request to verify headers are passed correctly
      stub_request(:get, 'https://api.namabar.krd/test')
        .with(
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'X-API-Key' => api_key,
            'Custom-Request-Header' => 'test-value'
          }
        )
        .to_return(status: 200, body: '{"success": true}')

      opts = client.default_options
      opts[:headers]['Custom-Request-Header'] = 'test-value'

      response = described_class.get('/test', opts)
      expect(response.code).to eq(200)
    end
  end

  describe 'HTTParty integration' do
    let(:client) { described_class.new }

    it 'can make GET requests' do
      stub_request(:get, 'https://api.namabar.krd/test')
        .to_return(
          status: 200,
          body: '{"result": "success"}',
          headers: { 'Content-Type' => 'application/json' }
        )

      response = described_class.get('/test', client.default_options)
      expect(response.code).to eq(200)
      expect(response.parsed_response).to eq({ 'result' => 'success' })
    end

    it 'can make POST requests' do
      stub_request(:post, 'https://api.namabar.krd/test')
        .with(
          body: '{"test":"data"}',
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'X-API-Key' => api_key
          }
        )
        .to_return(
          status: 201,
          body: '{"created": true}',
          headers: { 'Content-Type' => 'application/json' }
        )

      opts = client.default_options.merge(body: '{"test":"data"}')
      response = described_class.post('/test', opts)

      expect(response.code).to eq(201)
      expect(response.parsed_response).to eq({ 'created' => true })
    end
  end
end
