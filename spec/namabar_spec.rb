# frozen_string_literal: true

RSpec.describe Namabar do
  subject(:namabar) { described_class }

  it 'has a version number' do
    expect(Namabar::VERSION).not_to be_nil
  end

  describe '.configure' do
    it 'creates a configuration instance if none exists' do
      expect(namabar.configuration).to be_nil

      namabar.configure do |config|
        config.api_key = 'test-key'
      end

      expect(namabar.configuration).to be_a(Namabar::Configuration)
    end

    it 'yields the configuration for modification' do
      namabar.configure do |config|
        config.api_key = 'test-api-key'
        config.service_id = 'test-service-id'
      end

      expect(namabar.configuration.api_key).to eq('test-api-key')
      expect(namabar.configuration.service_id).to eq('test-service-id')
    end

    it 'returns the configuration instance' do
      result = namabar.configure do |config|
        config.api_key = 'test-key'
      end

      expect(result).to be_a(Namabar::Configuration)
      expect(result).to eq(namabar.configuration)
    end

    it 'reuses existing configuration instance' do
      first_config = namabar.configure { |c| c.api_key = 'first' }
      second_config = namabar.configure { |c| c.api_key = 'second' }

      expect(first_config).to eq(second_config)
      expect(namabar.configuration.api_key).to eq('second')
    end
  end

  describe '.client' do
    before do
      namabar.configure do |config|
        config.api_key = 'test-api-key'
        config.service_id = 'test-service-id'
      end
    end

    it 'creates a new client instance' do
      client = namabar.client
      expect(client).to be_a(Namabar::Client)
    end
  end

  describe Namabar::Error do
    subject(:error) { described_class }

    it 'is a StandardError subclass' do
      expect(error.new).to be_a(StandardError)
    end

    it 'can be raised and rescued' do
      expect do
        raise error, 'test error'
      end.to raise_error(error, 'test error')
    end
  end
end
