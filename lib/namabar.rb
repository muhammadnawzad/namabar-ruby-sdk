# frozen_string_literal: true

require 'namabar/version'
require 'namabar/configuration'
require 'namabar/client'
require 'namabar/endpoints'

# The main Namabar module providing convenient access to the Namabar API
#
# This module serves as the primary entry point for the Namabar gem, offering:
# - Global configuration management
# - Client creation and management
# - Error handling for the entire gem
#
# @example Basic usage
#   Namabar.configure do |config|
#     config.api_key = 'your-api-key'
#   end
#
#   client = Namabar.client
#   response = client.send_message(...)
#
# @see Client
# @see Configuration
module Namabar
  # Base error class for all Namabar-related errors
  #
  # All errors raised by the Namabar gem inherit from this class,
  # making it easy to rescue all gem-related errors with a single rescue clause.
  #
  # @example Rescuing all Namabar errors
  #   begin
  #     client.send_message(...)
  #   rescue Namabar::Error => e
  #     puts "Namabar error: #{e.message}"
  #   end
  class Error < StandardError; end

  class << self
    # @return [Configuration, nil] the current global configuration instance
    attr_accessor :configuration
  end

  # Configure the Namabar gem globally
  #
  # This method allows you to set global configuration options that will be
  # used by all Client instances unless overridden. The configuration is
  # yielded to the provided block for modification.
  #
  # @yield [config] Yields the configuration object for modification
  # @yieldparam config [Configuration] the configuration instance to modify
  # @return [Configuration] the configured Configuration instance
  #
  # @example Configure API credentials
  #   Namabar.configure do |config|
  #     config.api_key = ENV['NAMABAR_API_KEY']
  #   end
  #
  # @see Configuration
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
    configuration
  end

  # Create a new Namabar API client
  #
  # Creates and returns a new Client instance using the global configuration.
  # This is a convenience method equivalent to calling Client.new directly.
  #
  # @param args [Array] arguments to pass to the Client constructor (currently none accepted)
  # @return [Client] a new configured client instance
  #
  # @example Create a client
  #   client = Namabar.client
  #   response = client.send_message(...)
  #
  # @see Client#initialize
  def self.client(*args)
    Client.new(*args)
  end
end
