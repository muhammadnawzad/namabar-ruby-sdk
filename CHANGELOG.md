# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-05-31

### Added

- Initial release of Namabar Ruby SDK
- Complete OTP verification API coverage
- Complete messaging API coverage  
- HTTParty-based HTTP client with authentication
- RBS type definitions for all classes and methods
- Comprehensive YARD documentation
- Global configuration management
- Error handling with custom error classes

### Features

- `create_verification_code` - Create and send OTP codes
- `verify_verification_code` - Verify OTP codes
- `get_verification_code_by_id` - Get verification details
- `send_message` - Send SMS/messages
- `get_message` - Get message details
- `get_message_status` - Check message delivery status
