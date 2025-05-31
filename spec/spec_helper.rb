# frozen_string_literal: true

require 'namabar'
require 'webmock/rspec'

# Disable all external HTTP connections during tests
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Reset global configuration before each test
  config.before do
    Namabar.configuration = nil
  end

  # Reset WebMock stubs after each test
  config.after do
    WebMock.reset!
  end
end
