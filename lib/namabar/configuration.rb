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
  #
  # @example Configure using the global configuration
  #   Namabar.configure do |config|
  #     config.api_key = 'your-api-key'
  #   end
  #
  # @see Namabar.configure
  class Configuration
    # @return [String, nil] the API key for authenticating with the Namabar API
    # @example Set API key
    #   config.api_key = '1234567890abcdef'
    attr_accessor :api_key
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
    #   end
    #
    # @example Configuration with validation
    #   Namabar.configure do |config|
    #     config.api_key = ENV.fetch('NAMABAR_API_KEY') { raise 'API key required' }
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
