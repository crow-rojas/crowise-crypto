require 'swagger_helper'
require 'webmock/rspec'

RSpec.describe 'Conversions API', type: :request do
  before do
    stub_request(:get, "https://www.buda.com/api/v2/markets")
      .to_return(
        status: 200,
        body: {
          markets: [
            { id: "BTC-CLP", base_currency: "BTC", quote_currency: "CLP" },
            { id: "BTC-PEN", base_currency: "BTC", quote_currency: "PEN" },
            { id: "ETH-CLP", base_currency: "ETH", quote_currency: "CLP" },
            { id: "ETH-PEN", base_currency: "ETH", quote_currency: "PEN" }
          ]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:get, "https://www.buda.com/api/v2/markets/btc-clp/ticker")
      .to_return(
        status: 200,
        body: {
          ticker: {
            last_price: ["1000000.0", "CLP"],
            market_id: "BTC-CLP"
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:get, "https://www.buda.com/api/v2/markets/btc-pen/ticker")
      .to_return(
        status: 200,
        body: {
          ticker: {
            last_price: ["10000.0", "PEN"],
            market_id: "BTC-PEN"
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:get, "https://www.buda.com/api/v2/markets/eth-clp/ticker")
      .to_return(
        status: 200,
        body: {
          ticker: {
            last_price: ["100000.0", "CLP"],
            market_id: "ETH-CLP"
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:get, "https://www.buda.com/api/v2/markets/eth-pen/ticker")
      .to_return(
        status: 200,
        body: {
          ticker: {
            last_price: ["1100.0", "PEN"],
            market_id: "ETH-PEN"
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  path '/api/v1/convert' do
    post 'Converts currency using the best available path' do
      tags 'Currency Conversion'
      description 'Converts an amount from one currency to another using cryptocurrencies as intermediaries. Returns the best conversion rate and the intermediary used.'
      operationId 'convertCurrency'
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :conversion_params, in: :body, schema: { '$ref' => '#/components/schemas/conversion_request' }

      response '200', 'Currency converted successfully' do
        let(:conversion_params) do
          {
            source_currency: 'CLP',
            target_currency: 'PEN',
            amount: 10000
          }
        end

        schema '$ref' => '#/components/schemas/conversion_response'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['source_currency']).to eq('CLP')
          expect(data['target_currency']).to eq('PEN')
          expect(data['source_amount']).to eq(10000.0)
          expect(data['target_amount']).to eq(110.0)
          expect(data['intermediary_currency']).to eq('ETH')
        end
      end

      response '200', 'Same currency conversion' do
        let(:conversion_params) do
          {
            source_currency: 'CLP',
            target_currency: 'CLP',
            amount: 10000
          }
        end

        schema '$ref' => '#/components/schemas/conversion_response'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['source_amount']).to eq(10000.0)
          expect(data['target_amount']).to eq(10000.0)
          expect(data['intermediary_currency']).to be_nil
        end
      end

      response '400', 'Missing required parameters' do
        let(:conversion_params) do
          {
            source_currency: 'CLP'
            # Missing target_currency and amount
          }
        end

        schema '$ref' => '#/components/schemas/error'

        run_test! do |response|
          expect(response.status).to eq(400)
          data = JSON.parse(response.body)
          expect(data['error']).to include('Missing required parameters')
        end
      end

      response '400', 'Invalid amount' do
        let(:conversion_params) do
          {
            source_currency: 'CLP',
            target_currency: 'PEN',
            amount: 'invalid'
          }
        end

        schema '$ref' => '#/components/schemas/error'

        run_test! do |response|
          expect(response.status).to eq(400)
          data = JSON.parse(response.body)
          expect(data['error']).to include('Amount must be a valid number')
        end
      end

      response '400', 'Invalid source currency' do
        let(:conversion_params) do
          {
            source_currency: 'XXX',
            target_currency: 'PEN',
            amount: 10000
          }
        end

        schema '$ref' => '#/components/schemas/error'

        run_test! do |response|
          expect(response.status).to eq(400)
          data = JSON.parse(response.body)
          expect(data['error']).to include('Invalid source currency')
        end
      end

      response '400', 'Invalid target currency' do
        let(:conversion_params) do
          {
            source_currency: 'CLP',
            target_currency: 'XXX',
            amount: 10000
          }
        end

        schema '$ref' => '#/components/schemas/error'

        run_test! do |response|
          expect(response.status).to eq(400)
          data = JSON.parse(response.body)
          expect(data['error']).to include('Invalid target currency')
        end
      end
    end
  end
end
