# frozen_string_literal: true

module Namabar
  # One to one mapping of API endpoint methods from OpenAPI specification
  #
  # This module contains methods that correspond to API endpoints defined
  # in the OpenAPI spec. Each method provides a convenient Ruby interface to the HTTP endpoints.
  #
  # All methods return HTTParty::Response objects which can be used to
  # access response data, status codes, headers, etc.
  #
  # @example Basic usage
  #   client = Namabar::Client.new
  #   response = client.some_endpoint(param: 'value')
  #   puts response.code
  #   puts response.body
  module Endpoints
    # Create Verification Code
    #
    # Generates and sends a new verification code to the specified recipient using the configured verify service.
    #
    # @param to [string]  (required)
    # @param locale [String]  (optional)
    # @param external_id [string]  (optional)
    # @param code [string]  (optional)
    # @param service_id [String]  (required)
    # @param template_data [object]  (optional)
    # @return [HTTParty::Response] the HTTP response object
    #
    # @example
    #   response = create_verification_code(to: 'value', service_id: 'value')
    #   puts response.code
    def create_verification_code(to:, service_id:, locale: nil, external_id: nil, code: nil, template_data: nil)
      url = '/verification-codes'
      opts = default_options

      body_data = {
        'to' => to,
        'locale' => locale,
        'externalId' => external_id,
        'code' => code,
        'serviceId' => service_id,
        'templateData' => template_data
      }.compact

      unless body_data.empty?
        opts = opts.merge(body: body_data.to_json)
        opts[:headers] ||= {}
        opts[:headers]['Content-Type'] = 'application/json'
      end

      self.class.post(url, opts)
    end

    # Verify OTP Code
    #
    # Verifies a previously sent verification code. Returns the verification status and any associated data.
    #
    # @param id [string] The id of the verification code to verify. (required)
    # @param code [string]  (required)
    # @return [HTTParty::Response] the HTTP response object
    #
    # @example
    #   response = verify_verification_code(id: 'value', code: 'value')
    #   puts response.code
    def verify_verification_code(id:, code:)
      url = '/verification-codes/{id}/verify'
      url = url.gsub('{id}', id.to_s)
      opts = default_options

      body_data = {
        'code' => code
      }.compact

      unless body_data.empty?
        opts = opts.merge(body: body_data.to_json)
        opts[:headers] ||= {}
        opts[:headers]['Content-Type'] = 'application/json'
      end

      self.class.post(url, opts)
    end

    # Get Verification Code
    #
    # Retrieves details about a specific verification code.
    #
    # @param id [string] The ID of the verification code to retrieve (required)
    # @return [HTTParty::Response] the HTTP response object
    #
    # @example
    #   response = get_verification_code_by_id(id: 'value')
    #   puts response.code
    def get_verification_code_by_id(id:)
      url = '/verification-codes/{id}'
      url = url.gsub('{id}', id.to_s)
      opts = default_options

      self.class.get(url, opts)
    end

    # Send New Message
    #
    # Creates and sends a new message through the specified messaging service. Requires the CreateMessage permission.
    #
    # @param type [String]  (required)
    # @param to [string]  (required)
    # @param external_id [string]  (optional)
    # @param service_id [String]  (required)
    # @param text [string]  (optional)
    # @param template [String]  (optional)
    # @return [HTTParty::Response] the HTTP response object
    #
    # @example
    #   response = send_message(type: 'value', to: 'value', service_id: 'value')
    #   puts response.code
    def send_message(type:, to:, service_id:, external_id: nil, text: nil, template: nil)
      url = '/messages'
      opts = default_options

      body_data = {
        'type' => type,
        'to' => to,
        'externalId' => external_id,
        'serviceId' => service_id,
        'text' => text,
        'template' => template
      }.compact

      unless body_data.empty?
        opts = opts.merge(body: body_data.to_json)
        opts[:headers] ||= {}
        opts[:headers]['Content-Type'] = 'application/json'
      end

      self.class.post(url, opts)
    end

    # Get Message Details
    #
    # Retrieves detailed information about a specific message including its status, cost, and delivery information.
    #
    # @param id [string] The ID of the message to get. (required)
    # @return [HTTParty::Response] the HTTP response object
    #
    # @example
    #   response = get_message(id: 'value')
    #   puts response.code
    def get_message(id:)
      url = '/messages/{id}'
      url = url.gsub('{id}', id.to_s)
      opts = default_options

      self.class.get(url, opts)
    end

    # Get Message Status
    #
    # Retrieves the status of a specific message, can be used for polling message delivery status.
    #
    # @param id [string] The ID of the message to get. (required)
    # @return [HTTParty::Response] the HTTP response object
    #
    # @example
    #   response = get_message_status(id: 'value')
    #   puts response.code
    def get_message_status(id:)
      url = '/messages/{id}/status'
      url = url.gsub('{id}', id.to_s)
      opts = default_options

      self.class.get(url, opts)
    end
  end
end
