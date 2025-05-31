# Namabar Development Helpers

This directory contains development helper scripts that are **NOT part of the main namabar gem**. These are tools used during development to generate code from external sources.

## Files

### `generate.rb` ⭐
Simple executable script for running the OpenAPI spec generator. This is the easiest way to regenerate the endpoint files.

**Usage:**
```bash
# From the project root (recommended)
./helpers/generate.rb

# Or alternatively
ruby helpers/generate.rb
```

### `spec_generator.rb`
A Ruby script that generates HTTParty wrapper methods and RBS type signatures from the Namabar OpenAPI specification.

**What it does:**
- Fetches the OpenAPI spec from `https://api.namabar.krd/openapi/v1.json`
- Generates Ruby method definitions in `lib/namabar/endpoints.rb`
- Generates RBS type signatures in `sig/endpoints.rbs`

**Usage:**
```bash
# From the project root
ruby helpers/spec_generator.rb

# Or use the simpler generate.rb script above
```

**Dependencies:**
- `json` (stdlib)
- `open-uri` (stdlib)
- `dry-inflector` (gem)
- `erb` (stdlib)
- `fileutils` (stdlib)

### `method_template.erb`
ERB template used by `spec_generator.rb` to generate the Ruby method definitions. This template defines the structure and format of the generated endpoint methods.

**Features:**
- Generates comprehensive YARD documentation
- Handles path parameters, query parameters, and request bodies
- Includes usage examples for each method
- Properly types parameters and return values

## Important Notes

⚠️ **These are development tools only** - they are not included when the gem is built or installed.

⚠️ **Generated files should not be edited manually** - any changes will be overwritten the next time the generator runs.

## Running the Generator

The generator should be run whenever:
- The API specification changes
- New endpoints are added
- Parameter types or requirements change

**Quick start:**
```bash
./helpers/generate.rb
```

The generated files (`lib/namabar/endpoints.rb` and `sig/endpoints.rbs`) should be committed to version control after generation.

## Development Notes

The `SpecGenerator` class is designed to be:
- **Modular**: Each major function is broken into small, focused methods
- **Well-documented**: Every method has YARD documentation
- **Error-tolerant**: Handles missing or invalid OpenAPI spec gracefully
- **Maintainable**: Clear separation of concerns and readable code structure

If you need to modify the generation logic:
1. Update the appropriate method in `SpecGenerator`
2. For template changes, modify `method_template.erb`
3. Test your changes by running the generator
4. Verify the generated output is correct 
