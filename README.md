# Namabar Ruby SDK

A lightweight Ruby SDK for interacting with the Namabar OTP & Messaging API. Provides simple, well-documented methods for each API endpoint with seamless HTTParty integration.

## Features

- **Easy Setup**: Configure API credentials once, use everywhere
- **Complete API Coverage**: All OTP verification and messaging endpoints
- **Type Safety**: Full RBS type definitions included
- **Zero Heavy Dependencies**: Just HTTParty and that's it!

## Installation

Add to your `Gemfile`:

```ruby
gem 'namabar'
```

Then run:

```bash
bundle install
```

Or install directly:

```bash
gem install namabar
```

## Configuration

Configure your API credentials before using the client:

```ruby
Namabar.configure do |config|
  config.api_key = ENV.fetch('NAMABAR__API_KEY')
  config.service_id = ENV.fetch('NAMABAR__SERVICE_ID')
end
```

## Usage

Create a client and start making API calls:

```ruby
client = Namabar.client
```

### OTP Verification

**Create and send a verification code:**

```ruby
response = client.create_verification_code(
  to: '+964751234567',
  service_id: 'your-service-id',
  locale: 'en',                    # optional
  external_id: 'user-123',         # optional
  template_data: { name: 'John' }  # optional
)

if response.success?
  verification_id = response.parsed_response['data']['id']
  puts "Verification code sent! ID: #{verification_id}"
end
```

**Verify the code:**

```ruby
response = client.verify_verification_code(
  id: verification_id,
  code: '123456'
)

if response.success?
  puts "Code verified successfully!"
else
  puts "Verification failed: #{response.parsed_response['message']}"
end
```

**Get verification code details:**

```ruby
response = client.get_verification_code_by_id(id: verification_id)
puts response.parsed_response['data']
```

### Messaging

**Send a message:**

```ruby
response = client.send_message(
  type: 'sms',
  to: '+964751234567',
  service_id: 'your-service-id',
  text: 'Hello from Namabar!',      # optional (for custom text)
  template: 'welcome_template',     # optional (for templates)
  external_id: 'msg-456'           # optional
)

if response.success?
  message_id = response.parsed_response['data']['id']
  puts "Message sent! ID: #{message_id}"
end
```

**Get message details:**

```ruby
response = client.get_message(id: message_id)
puts response.parsed_response['data']
```

**Check message status:**

```ruby
response = client.get_message_status(id: message_id)
status = response.parsed_response['data']['status']
puts "Message status: #{status}"
```

### Response Handling

All methods return `HTTParty::Response` objects:

```ruby
response = client.create_verification_code(...)

# Check success
if response.success?
  data = response.parsed_response['data']
  puts "Success: #{data}"
else
  puts "Error #{response.code}: #{response.parsed_response['message']}"
end

# Access raw response
puts response.body
puts response.headers
puts response.code
```

### Error Handling

```ruby
begin
  response = client.create_verification_code(...)
rescue Namabar::Error => e
  puts "Namabar SDK error: #{e.message}"
rescue => e
  puts "General error: #{e.message}"
end
```

## API Reference

The SDK provides these methods corresponding to Namabar API endpoints:

**OTP Verification:**

- `create_verification_code(to:, service_id:, **options)` - Create and send OTP
- `verify_verification_code(id:, code:)` - Verify OTP code  
- `get_verification_code_by_id(id:)` - Get verification details

**Messaging:**

- `send_message(type:, to:, service_id:, **options)` - Send message
- `get_message(id:)` - Get message details
- `get_message_status(id:)` - Get message status

All methods return `HTTParty::Response` objects with the API response.

## Development & Contributing

Please refer to the [Development](/helpers/README.md) file for more information. Also, please refer to the [Contributing](/CONTRIBUTING.md) file for contributing to the project.

## License

Released under the MIT License. See [LICENSE](LICENSE.txt) for details.
