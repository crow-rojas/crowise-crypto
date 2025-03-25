# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Crowise Crypto API, the best currency converter 🔥',
        version: 'v1',
        description: 'A REST API that communicates with Buda.com API to provide optimal currency conversion paths between different fiat currencies using cryptocurrencies as intermediaries.'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        }
      ],
      components: {
        schemas: {
          conversion_request: {
            type: 'object',
            properties: {
              source_currency: { type: 'string', description: 'Source currency code (CLP, PEN, COP)' },
              target_currency: { type: 'string', description: 'Target currency code (CLP, PEN, COP)' },
              amount: { type: 'number', format: 'float', description: 'Amount in source currency to convert' }
            },
            required: ['source_currency', 'target_currency', 'amount']
          },
          conversion_response: {
            type: 'object',
            properties: {
              source_currency: { type: 'string', description: 'Source currency code' },
              target_currency: { type: 'string', description: 'Target currency code' },
              source_amount: { type: 'number', format: 'float', description: 'Original amount in source currency' },
              target_amount: { type: 'number', format: 'float', description: 'Converted amount in target currency' },
              intermediary_currency: { type: 'string', nullable: true, description: 'Cryptocurrency used as intermediary' }
            }
          },
          error: {
            type: 'object',
            properties: {
              error: { type: 'string' }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
