#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open-uri'
require 'dry/inflector'
require 'erb'
require 'fileutils'

# Helper script for generating HTTParty wrappers from OpenAPI specifications.
# This is a development tool and is NOT part of the main namabar gem.
#
# Usage:
#   ruby helpers/spec_generator.rb
#
# This script will:
# 1. Fetch the OpenAPI spec from the namabar API
# 2. Generate method definitions in lib/namabar/endpoints.rb
# 3. Generate RBS type signatures in sig/endpoints.rbs
module Helpers
  # Generates HTTParty wrappers and RBS signature files from OpenAPI specifications
  #
  # This class fetches an OpenAPI specification, parses it, and generates:
  # - Ruby method definitions using ERB templates
  # - RBS type signature files for type checking
  #
  # @example
  #   generator = SpecGenerator.new
  #   generator.generate
  class SpecGenerator # rubocop:disable Metrics/ClassLength
    # @return [String] the OpenAPI specification URL
    attr_reader :spec_url

    # @return [Dry::Inflector] inflector for string transformations
    attr_reader :inflector

    # Initialize a new SpecGenerator
    #
    # @param spec_url [String] URL to fetch the OpenAPI specification from
    def initialize(spec_url: 'https://api.namabar.krd/openapi/v1.json')
      @spec_url = spec_url
      @inflector = Dry::Inflector.new
      @template = load_erb_template
    end

    # Main entry point - generates all files from the OpenAPI spec
    #
    # @return [void]
    def generate
      puts "🚀 Starting generation from #{spec_url}..."

      @spec = fetch_and_validate_spec
      prepare_output_directories
      generate_methods_module
      generate_signature_definitions

      puts '✅ Generation complete!'
    end

    private

    # Load and compile the ERB template
    #
    # @return [ERB] compiled ERB template
    def load_erb_template
      template_path = File.expand_path('method_template.erb', __dir__)
      ERB.new(File.read(template_path), trim_mode: '-')
    end

    # Fetch the OpenAPI spec from the URL and validate its structure
    #
    # @return [Hash] parsed OpenAPI specification
    # @raise [StandardError] if the spec is invalid or unreachable
    def fetch_and_validate_spec
      puts "📡 Fetching spec from #{spec_url}..."

      raw_data = URI.open(spec_url).read # rubocop:disable Security/Open
      parsed_spec = JSON.parse(raw_data)

      validate_spec_structure(parsed_spec)
      parsed_spec
    rescue StandardError => e
      raise "Failed to fetch or parse OpenAPI spec: #{e.message}"
    end

    # Validate that the OpenAPI spec has required structure
    #
    # @param spec [Hash] the parsed OpenAPI specification
    # @return [void]
    # @raise [StandardError] if required keys are missing
    def validate_spec_structure(spec)
      required_keys = %w[openapi paths components]
      missing_keys = required_keys - spec.keys

      return if missing_keys.empty?

      raise "Invalid OpenAPI spec: missing required keys: #{missing_keys.join(", ")}"
    end

    # Create necessary output directories
    #
    # @return [void]
    def prepare_output_directories
      sig_dir = File.expand_path('../sig', __dir__)
      FileUtils.mkdir_p(sig_dir)
    end

    # Generate the Ruby methods module using ERB template
    #
    # @return [void]
    def generate_methods_module
      content = @template.result(binding)
      output_path = File.expand_path('../lib/namabar/endpoints.rb', __dir__)

      File.write(output_path, content)
      puts "🔧 Generated methods module: #{output_path}"
    end

    # Generate RBS type signature definitions
    #
    # @return [void]
    def generate_signature_definitions
      method_signatures = build_method_signatures
      rbs_content = wrap_in_module_structure(method_signatures)

      sig_file = File.expand_path('../sig/endpoints.rbs', __dir__)
      File.write(sig_file, rbs_content)
      puts "🔧 Generated type signatures: #{sig_file}"
    end

    # Build method signatures from the OpenAPI spec
    #
    # @return [Array<String>] array of RBS method signature lines
    def build_method_signatures
      paths = @spec.fetch('paths', {})

      paths.flat_map do |path, actions|
        actions.map { |verb, operation| build_single_method_signature(operation, verb, path) }
      end.flatten
    end

    # Build a single method signature with comments
    #
    # @param operation [Hash] OpenAPI operation definition
    # @param verb [String] HTTP verb (get, post, etc.)
    # @param path [String] API endpoint path
    # @return [Array<String>] lines for this method signature
    def build_single_method_signature(operation, verb, path)
      method_name = generate_method_name(operation, verb, path)
      parameters = collect_parameters(operation)

      comments = generate_method_comments(operation, verb, path)
      signature = generate_rbs_signature(method_name, parameters)

      [comments, signature, ''].flatten
    end

    # Generate documentation comments for a method
    #
    # @param operation [Hash] OpenAPI operation definition
    # @param verb [String] HTTP verb
    # @param path [String] API endpoint path
    # @return [Array<String>] comment lines
    def generate_method_comments(operation, verb, path)
      comments = []
      comments << "    # #{operation["operationId"] || "#{verb} #{path}"}"

      all_params = operation.fetch('parameters', []) + extract_body_parameters(operation)
      all_params.each do |param|
        comments << build_parameter_comment(param)
      end

      comments << '    # @return [HTTParty::Response]'
      comments
    end

    # Build a parameter comment line
    #
    # @param param [Hash] parameter definition
    # @return [String] parameter comment line
    def build_parameter_comment(param)
      param_name = inflector.underscore(param['name'])
      param_type = param.dig('schema', 'type') || 'String'
      required_text = param['required'] ? 'required' : 'optional'

      "    # @param #{param_name} [#{param_type}] (#{required_text})"
    end

    # Generate RBS method signature
    #
    # @param method_name [String] name of the method
    # @param parameters [Hash] method parameters
    # @return [String] RBS method signature
    def generate_rbs_signature(method_name, parameters)
      if parameters.empty?
        "    def #{method_name}: () -> HTTParty::Response"
      else
        param_list = build_rbs_parameter_list(parameters)
        "    def #{method_name}: (#{param_list}) -> HTTParty::Response"
      end
    end

    # Build RBS parameter list string
    #
    # @param parameters [Hash] method parameters
    # @return [String] formatted parameter list
    def build_rbs_parameter_list(parameters)
      parameters.map do |name, type|
        if type.start_with?('?')
          "?#{name}: #{type[1..]}"
        else
          "#{name}: #{type}"
        end
      end.join(', ')
    end

    # Wrap method signatures in proper RBS module structure
    #
    # @param method_signatures [Array<String>] method signature lines
    # @return [String] complete RBS content
    def wrap_in_module_structure(method_signatures)
      lines = ['module Namabar', '  module Endpoints']
      lines.concat(method_signatures)
      lines.push('  end', 'end')
      lines.join("\n")
    end

    # Generate a Ruby method name from operation details
    #
    # @param operation [Hash] OpenAPI operation definition
    # @param verb [String] HTTP verb
    # @param path [String] API endpoint path
    # @return [String] generated method name
    def generate_method_name(operation, verb, path)
      base = (operation['operationId'] || "#{verb}_#{path}")
             .gsub(/[^0-9A-Za-z_]/, '_')

      base.strip.squeeze('_').sub(/^_|_$/, '').downcase
    end

    # Collect and type all parameters for a method
    #
    # @param operation [Hash] OpenAPI operation definition
    # @return [Hash] parameter name to type mapping
    def collect_parameters(operation)
      all_params = operation.fetch('parameters', []) + extract_body_parameters(operation)

      all_params.to_h do |param|
        name = inflector.underscore(param['name'])
        type = map_openapi_type_to_rbs(param.dig('schema', 'type'))
        final_type = param['required'] ? type : "?#{type}"

        [name, final_type]
      end
    end

    # Map OpenAPI schema types to RBS types
    #
    # @param openapi_type [String] OpenAPI schema type
    # @return [String] corresponding RBS type
    def map_openapi_type_to_rbs(openapi_type)
      case openapi_type
      when 'integer' then 'Integer'
      when 'boolean' then 'bool'
      when 'number' then 'Float'
      when 'array' then 'Array[untyped]'
      when 'object' then 'Hash[String, untyped]'
      else 'String'
      end
    end

    # Extract body parameters from request body schema
    #
    # @param operation [Hash] OpenAPI operation definition
    # @return [Array<Hash>] array of parameter definitions
    def extract_body_parameters(operation)
      return [] unless operation['requestBody']

      schema = resolve_request_body_schema(operation)
      return [] unless schema

      schema.fetch('properties', {}).map do |name, info|
        {
          'name' => name,
          'required' => Array(schema['required']).include?(name),
          'schema' => info
        }
      end
    end

    # Resolve request body schema, handling $ref references
    #
    # @param operation [Hash] OpenAPI operation definition
    # @return [Hash, nil] resolved schema or nil
    def resolve_request_body_schema(operation)
      raw_schema = operation.dig('requestBody', 'content', 'application/json', 'schema')
      return nil unless raw_schema

      raw_schema['$ref'] ? resolve_schema_reference(raw_schema['$ref']) : raw_schema
    end

    # Resolve a JSON Schema $ref reference
    #
    # @param ref [String] reference string (e.g., "#/components/schemas/User")
    # @return [Hash] resolved schema definition
    def resolve_schema_reference(ref)
      key = ref.split('/').last
      @spec.fetch('components', {}).fetch('schemas', {}).fetch(key)
    end
  end
end

# Run the generator if this file is executed directly
Helpers::SpecGenerator.new.generate if __FILE__ == $PROGRAM_NAME
