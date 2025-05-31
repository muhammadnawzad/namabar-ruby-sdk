# frozen_string_literal: true

RSpec.describe Namabar::Configuration do
  let(:config) { described_class.new }

  describe '#api_key' do
    it 'can be set and retrieved' do
      config.api_key = 'test-api-key'
      expect(config.api_key).to eq('test-api-key')
    end

    it 'defaults to nil' do
      expect(config.api_key).to be_nil
    end

    it 'can be set to nil' do
      config.api_key = 'test'
      config.api_key = nil
      expect(config.api_key).to be_nil
    end
  end

  describe '#service_id' do
    it 'can be set and retrieved' do
      config.service_id = 'test-service-id'
      expect(config.service_id).to eq('test-service-id')
    end

    it 'defaults to nil' do
      expect(config.service_id).to be_nil
    end

    it 'can be set to nil' do
      config.service_id = 'test'
      config.service_id = nil
      expect(config.service_id).to be_nil
    end
  end

  describe 'when used with module-level configure method' do
    it 'can be configured via Namabar.configure' do
      Namabar.configure do |config|
        config.api_key = 'module-api-key'
        config.service_id = 'module-service-id'
      end

      expect(Namabar.configuration.api_key).to eq('module-api-key')
      expect(Namabar.configuration.service_id).to eq('module-service-id')
    end
  end
end
