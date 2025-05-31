# frozen_string_literal: true

require 'httparty'
require_relative 'configuration'
require_relative 'endpoints'

module Namabar
  # HTTP client for interacting with the Namabar API
  #
  # This class provides the core HTTP functionality for making requests to the Namabar API.
  # It uses HTTParty for HTTP operations and includes all endpoint methods from the Endpoints module.
  #
  # The client automatically handles:
  # - Base URI configuration
  # - Authentication via API key headers
  # - Content-Type and Accept headers
  # - JSON request/response handling
  #
  # @example Basic usage
  #   # Configure globally first
  #   Namabar.configure do |config|
  #     config.api_key = 'your-api-key'
  #     config.service_id = 'your-service-id'
  #   end
  #
  #   # Create and use client
  #   client = Namabar::Client.new
  #   response = client.send_message(
  #     type: 'sms',
  #     to: '+1234567890',
  #     text: 'Hello from Namabar!',
  #     service_id: 'sms-service'
  #   )
  #   puts response.code # => 200
  #   puts response.body # => parsed JSON response
  #
  # @see Endpoints
  # @see Configuration
  class Client
    include HTTParty
    include Endpoints

    base_uri 'https://api.namabar.krd'

    # Initialize a new Namabar API client
    #
    # Creates a new client instance using the global Namabar configuration.
    # The client will be configured with the API key and default headers
    # required for authentication and proper JSON communication.
    #
    # @raise [StandardError] if Namabar.configuration is nil or api_key is not set
    #
    # @example Create a client
    #   client = Namabar::Client.new
    #
    # @see Namabar.configure
    def initialize
      @config = Namabar.configuration
      self.class.headers(
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'X-API-Key' => @config.api_key
      )
    end

    # Get default HTTP options for requests
    #
    # Returns a hash containing the default options that should be included
    # with every HTTP request, including headers for authentication and content type.
    #
    # @return [Hash] hash containing default headers and options
    #
    # @example Using default options
    #   opts = client.default_options
    #   opts = opts.merge(query: { limit: 10 })
    #   response = HTTParty.get('/endpoint', opts)
    def default_options
      { headers: self.class.headers }
    end
  end
end
