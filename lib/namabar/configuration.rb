# frozen_string_literal: true

module Namabar
  # Configuration class for storing Namabar API credentials and settings
  #
  # This class holds the configuration options required to authenticate
  # and interact with the Namabar API. It's typically configured once
  # globally and then used by all Client instances.
  #
  # @example Configure with API credentials
  #   config = Namabar::Configuration.new
  #   config.api_key = ENV.fetch('NAMABAR__API_KEY', nil)
  #   config.service_id = ENV.fetch('NAMABAR__SERVICE_ID', nil)
  #
  # @example Configure using the global configuration
  #   Namabar.configure do |config|
  #     config.api_key = 'your-api-key'
  #     config.service_id = 'your-default-service-id'
  #   end
  #
  # @see Namabar.configure
  class Configuration
    # @return [String, nil] the API key for authenticating with the Namabar API
    # @example Set API key
    #   config.api_key = '1234567890abcdef'
    attr_accessor :api_key

    # @return [String, nil] the default service ID to use for API operations
    # @note This can be overridden on a per-request basis for most endpoints
    # @example Set service ID
    #   config.service_id = 'sms-service-production'
    attr_accessor :service_id
  end

  class << self
    # @return [Configuration, nil] the global configuration instance
    attr_accessor :configuration

    # Configure the Namabar gem with API credentials and settings
    #
    # This method provides a convenient way to set up the global configuration
    # that will be used by all Client instances. The configuration object is
    # yielded to the provided block for modification.
    #
    # @yield [config] Yields the configuration object for modification
    # @yieldparam config [Configuration] the configuration instance to modify
    # @return [Configuration] the configured Configuration instance
    #
    # @example Basic configuration
    #   Namabar.configure do |config|
    #     config.api_key = ENV.fetch('NAMABAR__API_KEY', nil)
    #     config.service_id = ENV.fetch('NAMABAR_SERVICE_ID', nil)
    #   end
    #
    # @example Configuration with validation
    #   Namabar.configure do |config|
    #     config.api_key = ENV.fetch('NAMABAR_API_KEY') { raise 'API key required' }
    #     config.service_id = ENV.fetch('NAMABAR_SERVICE_ID') { raise 'Service ID required' }
    #   end
    #
    # @see Configuration
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
      configuration
    end
  end
end
