# frozen_string_literal: true

RSpec.describe Namabar::Endpoints do
  let(:api_key) { 'test-api-key' }
  let(:service_id) { 'test-service-id' }
  let(:client) do
    Namabar.configure do |config|
      config.api_key = api_key
    end
    Namabar.client
  end

  describe '#create_verification_code' do
    let(:verification_params) do
      {
        to: '+9647501234567',
        locale: 'en',
        external_id: 'ext-123',
        code: '123456',
        service_id: service_id,
        template_data: { name: 'John' }
      }
    end

    it 'makes a POST request to /verification-codes' do
      stub_request(:post, 'https://api.namabar.krd/verification-codes')
        .with(
          body: {
            to: '+9647501234567',
            locale: 'en',
            externalId: 'ext-123',
            code: '123456',
            serviceId: service_id,
            templateData: { name: 'John' }
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'X-API-Key' => api_key
          }
        )
        .to_return(
          status: 200,
          body: {
            id: '68397dd4467eecf49d28cebc',
            messageId: '68397dd4467eecf49d28cebc'
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.create_verification_code(**verification_params)

      expect(response.code).to eq(200)
      expect(response.parsed_response['id']).to eq('68397dd4467eecf49d28cebc')
      expect(response.parsed_response['messageId']).to eq('68397dd4467eecf49d28cebc')
    end

    it 'handles optional parameters' do
      minimal_params = {
        to: '+9647501234567',
        locale: nil,
        external_id: nil,
        code: nil,
        service_id: service_id,
        template_data: nil
      }

      stub_request(:post, 'https://api.namabar.krd/verification-codes')
        .with(
          body: {
            to: '+9647501234567',
            serviceId: service_id
          }.to_json
        )
        .to_return(status: 200, body: '{"id": "test-id"}')

      response = client.create_verification_code(**minimal_params)
      expect(response.code).to eq(200)
    end

    it 'returns HTTParty::Response object' do
      stub_request(:post, 'https://api.namabar.krd/verification-codes')
        .to_return(status: 200, body: '{}')

      response = client.create_verification_code(**verification_params)
      expect(response).to be_a(HTTParty::Response)
    end
  end

  describe '#verify_verification_code' do
    let(:verification_id) { '68397dd4467eecf49d28cebc' }
    let(:code) { '123456' }

    it 'makes a POST request to /verification-codes/{id}/verify' do
      stub_request(:post, "https://api.namabar.krd/verification-codes/#{verification_id}/verify")
        .with(
          body: { code: code }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'X-API-Key' => api_key
          }
        )
        .to_return(
          status: 204,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.verify_verification_code(id: verification_id, code: code)

      expect(response.code).to eq(204)
    end

    it 'properly interpolates ID in URL path' do
      different_id = 'different-id-123'

      stub_request(:post, "https://api.namabar.krd/verification-codes/#{different_id}/verify")
        .to_return(status: 204)

      response = client.verify_verification_code(id: different_id, code: code)
      expect(response.code).to eq(204)
    end

    it 'returns HTTParty::Response object' do
      stub_request(:post, "https://api.namabar.krd/verification-codes/#{verification_id}/verify")
        .to_return(status: 204)

      response = client.verify_verification_code(id: verification_id, code: code)
      expect(response).to be_a(HTTParty::Response)
      expect(response.code).to eq(204)
    end
  end

  describe '#get_verification_code_by_id' do
    let(:verification_id) { '68397dd4467eecf49d28cebc' }

    it 'makes a GET request to /verification-codes/{id}' do
      stub_request(:get, "https://api.namabar.krd/verification-codes/#{verification_id}")
        .with(
          headers: {
            'Accept' => 'application/json',
            'X-API-Key' => api_key
          }
        )
        .to_return(
          status: 200,
          body: {
            id: verification_id,
            messageId: verification_id,
            serviceId: service_id,
            to: '+9647501234567',
            state: 'delivered',
            createdAt: '2023-01-01T00:00:00Z',
            expiresAt: '2023-01-01T00:00:00Z',
            verifiedAt: nil,
            failureAttempts: nil,
            lastFailureTime: nil
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.get_verification_code_by_id(id: verification_id)

      expect(response.code).to eq(200)
      expect(response.parsed_response['id']).to eq(verification_id)
      expect(response.parsed_response['messageId']).to eq(verification_id)
      expect(response.parsed_response['serviceId']).to eq(service_id)
      expect(response.parsed_response['state']).to eq('delivered')
    end

    it 'properly interpolates ID in URL path' do
      different_id = 'another-verification-id'

      stub_request(:get, "https://api.namabar.krd/verification-codes/#{different_id}")
        .to_return(status: 200, body: '{}')

      response = client.get_verification_code_by_id(id: different_id)
      expect(response.code).to eq(200)
    end

    it 'returns HTTParty::Response object' do
      stub_request(:get, "https://api.namabar.krd/verification-codes/#{verification_id}")
        .to_return(status: 200, body: '{}')

      response = client.get_verification_code_by_id(id: verification_id)
      expect(response).to be_a(HTTParty::Response)
    end
  end

  describe '#send_message' do
    let(:message_params) do
      {
        type: 'Text',
        to: '+9647501234567',
        external_id: 'msg-ext-123',
        service_id: service_id,
        text: 'Hello from Namabar!',
        template: {
          name: '',
          locale: 'en',
          data: nil
        }
      }
    end

    it 'makes a POST request to /messages' do
      stub_request(:post, 'https://api.namabar.krd/messages')
        .with(
          body: {
            type: 'Text',
            to: '+9647501234567',
            externalId: 'msg-ext-123',
            serviceId: service_id,
            text: 'Hello from Namabar!',
            template: {
              name: '',
              locale: 'en',
              data: nil
            }
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'X-API-Key' => api_key
          }
        )
        .to_return(
          status: 200,
          body: {
            id: 'msg-68397dd4467eecf49d28cebc'
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.send_message(**message_params)

      expect(response.code).to eq(200)
      expect(response.parsed_response['id']).to eq('msg-68397dd4467eecf49d28cebc')
    end

    it 'handles optional parameters' do
      minimal_params = {
        type: 'Text',
        to: '+9647501234567',
        external_id: nil,
        service_id: service_id,
        text: 'Hello!',
        template: nil
      }

      stub_request(:post, 'https://api.namabar.krd/messages')
        .with(
          body: {
            type: 'Text',
            to: '+9647501234567',
            serviceId: service_id,
            text: 'Hello!'
          }.to_json
        )
        .to_return(status: 200, body: '{"id": "msg-test-id"}')

      response = client.send_message(**minimal_params)
      expect(response.code).to eq(200)
    end

    it 'returns HTTParty::Response object' do
      stub_request(:post, 'https://api.namabar.krd/messages')
        .to_return(status: 200, body: '{}')

      response = client.send_message(**message_params)
      expect(response).to be_a(HTTParty::Response)
    end
  end

  describe '#get_message' do
    let(:message_id) { 'msg-68397dd4467eecf49d28cebc' }

    it 'makes a GET request to /messages/{id}' do # rubocop:disable RSpec/ExampleLength
      stub_request(:get, "https://api.namabar.krd/messages/#{message_id}")
        .with(
          headers: {
            'Accept' => 'application/json',
            'X-API-Key' => api_key
          }
        )
        .to_return(
          status: 200,
          body: {
            id: message_id,
            externalId: nil,
            to: '+9647501234567',
            totalCostUsd: nil,
            status: 'Pending',
            type: 'Text',
            createdAt: '2025-05-31T13:01:19.747Z',
            delivered: true,
            attempts: nil,
            stopSending: true,
            senderCount: nil,
            text: nil,
            template: {
              name: '',
              data: nil,
              locale: 'en'
            },
            tries: [
              {
                senderId: message_id,
                status: 'string',
                channel: 'Sms',
                costUsd: nil,
                operator: nil,
                refunded: nil,
                createdAt: '2025-05-31T13:01:19.747Z',
                updatedAt: '2025-05-31T13:01:19.747Z'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.get_message(id: message_id)

      expect(response.code).to eq(200)
      expect(response.parsed_response['id']).to eq(message_id)
      expect(response.parsed_response['externalId']).to be_nil
      expect(response.parsed_response['to']).to eq('+9647501234567')
      expect(response.parsed_response['status']).to eq('Pending')
    end

    it 'properly interpolates ID in URL path' do
      different_id = 'msg-different-id-456'

      stub_request(:get, "https://api.namabar.krd/messages/#{different_id}")
        .to_return(status: 200, body: '{}')

      response = client.get_message(id: different_id)
      expect(response.code).to eq(200)
    end

    it 'returns HTTParty::Response object' do
      stub_request(:get, "https://api.namabar.krd/messages/#{message_id}")
        .to_return(status: 200, body: '{}')

      response = client.get_message(id: message_id)
      expect(response).to be_a(HTTParty::Response)
    end
  end

  describe '#get_message_status' do
    let(:message_id) { 'msg-68397dd4467eecf49d28cebc' }

    it 'makes a GET request to /messages/{id}/status' do
      stub_request(:get, "https://api.namabar.krd/messages/#{message_id}/status")
        .with(
          headers: {
            'Accept' => 'application/json',
            'X-API-Key' => api_key
          }
        )
        .to_return(
          status: 200,
          body: {
            id: message_id,
            totalCostUsd: nil,
            status: 'Pending',
            delivered: true,
            attempts: nil,
            stopSending: true,
            tries: [
              {
                senderId: message_id,
                status: 'string',
                channel: 'Sms',
                costUsd: nil,
                operator: nil,
                refunded: nil,
                createdAt: '2025-05-31T13:01:19.747Z',
                updatedAt: '2025-05-31T13:01:19.747Z'
              }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.get_message_status(id: message_id)

      expect(response.code).to eq(200)
      expect(response.parsed_response['id']).to eq(message_id)
      expect(response.parsed_response['status']).to eq('Pending')
    end

    it 'properly interpolates ID in URL path' do
      different_id = 'msg-status-check-789'

      stub_request(:get, "https://api.namabar.krd/messages/#{different_id}/status")
        .to_return(status: 200, body: '{}')

      response = client.get_message_status(id: different_id)
      expect(response.code).to eq(200)
    end

    it 'returns HTTParty::Response object' do
      stub_request(:get, "https://api.namabar.krd/messages/#{message_id}/status")
        .to_return(status: 200, body: '{}')

      response = client.get_message_status(id: message_id)
      expect(response).to be_a(HTTParty::Response)
    end
  end

  describe 'error handling' do
    it 'handles 400 Bad Request responses' do
      stub_request(:post, 'https://api.namabar.krd/verification-codes')
        .to_return(
          status: 400,
          body: {
            error: 'Bad Request',
            message: 'Invalid phone number format'
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.create_verification_code(
        to: 'invalid-phone',
        locale: nil,
        external_id: nil,
        code: nil,
        service_id: service_id,
        template_data: nil
      )

      expect(response.code).to eq(400)
      expect(response.parsed_response['error']).to eq('Bad Request')
      expect(response.parsed_response['message']).to eq('Invalid phone number format')
    end

    it 'handles 401 Unauthorized responses' do
      # Create client with invalid API key
      Namabar.configure { |config| config.api_key = 'invalid-key' }
      invalid_client = Namabar::Client.new

      stub_request(:post, 'https://api.namabar.krd/messages')
        .to_return(
          status: 401,
          body: {
            error: 'Unauthorized',
            message: 'Invalid API key'
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = invalid_client.send_message(
        type: 'sms',
        to: '+9647501234567',
        external_id: nil,
        service_id: service_id,
        text: 'Test',
        template: nil
      )

      expect(response.code).to eq(401)
      expect(response.parsed_response['error']).to eq('Unauthorized')
    end

    it 'handles 404 Not Found responses' do
      non_existent_id = 'non-existent-id'

      stub_request(:get, "https://api.namabar.krd/messages/#{non_existent_id}")
        .to_return(
          status: 404,
          body: {
            error: 'Not Found',
            message: 'Message not found'
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.get_message(id: non_existent_id)

      expect(response.code).to eq(404)
      expect(response.parsed_response['error']).to eq('Not Found')
      expect(response.parsed_response['message']).to eq('Message not found')
    end

    it 'handles 500 Server Error responses' do
      stub_request(:post, 'https://api.namabar.krd/verification-codes')
        .to_return(
          status: 500,
          body: {
            error: 'Internal Server Error',
            message: 'Something went wrong'
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      response = client.create_verification_code(
        to: '+9647501234567',
        locale: nil,
        external_id: nil,
        code: nil,
        service_id: service_id,
        template_data: nil
      )

      expect(response.code).to eq(500)
      expect(response.parsed_response['error']).to eq('Internal Server Error')
    end
  end
end
