require 'rails_helper'
require 'webmock/rspec'

RSpec.describe CurrencyConverter do
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
            last_price: [ "1000000.0", "CLP" ],
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
            last_price: [ "10000.0", "PEN" ],
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
            last_price: [ "100000.0", "CLP" ],
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
            last_price: [ "1100.0", "PEN" ],
            market_id: "ETH-PEN"
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe '.convert' do
    context 'when converting between different currencies' do
      it 'converts currency using the best intermediary' do
        # For the given test data:
        # CLP -> BTC -> PEN: 10000 CLP -> 0.01 BTC -> 100 PEN
        # CLP -> ETH -> PEN: 10000 CLP -> 0.1 ETH -> 110 PEN (better)
        result = CurrencyConverter.convert("CLP", "PEN", 10000)

        expect(result[:amount]).to eq(110.0)
        expect(result[:intermediary]).to eq("ETH")
      end
    end

    context 'when source and target are the same' do
      it 'returns the same amount' do
        result = CurrencyConverter.convert("CLP", "CLP", 10000)

        expect(result[:amount]).to eq(10000.0)
        expect(result[:intermediary]).to be_nil
      end
    end

    context 'with invalid currencies' do
      it 'raises error for invalid source currency' do
        expect {
          CurrencyConverter.convert("INVALID", "PEN", 10000)
        }.to raise_error(ArgumentError, /Invalid source currency/)
      end

      it 'raises error for invalid target currency' do
        expect {
          CurrencyConverter.convert("CLP", "INVALID", 10000)
        }.to raise_error(ArgumentError, /Invalid target currency/)
      end
    end
  end
end
