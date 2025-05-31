#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple executable script for running the OpenAPI spec generator
# This is a development helper and NOT part of the main namabar gem

require_relative 'spec_generator'

begin
  puts 'Namabar Development Helper - OpenAPI Spec Generator'
  puts '=' * 60

  generator = Helpers::SpecGenerator.new
  generator.generate

  puts '=' * 60
  puts '✨ All done! Generated files are ready to use.'
rescue StandardError => e
  puts '❌ Error during generation:'
  puts "   #{e.message}"
  puts
  puts 'Stack trace:'
  puts(e.backtrace.map { |line| "   #{line}" })
  exit 1
end
