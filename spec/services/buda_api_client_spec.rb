require 'rails_helper'
require 'webmock/rspec'

RSpec.describe BudaApiClient do
  before do
    stub_request(:get, "https://www.buda.com/api/v2/markets")
      .to_return(
        status: 200,
        body: {
          markets: [
            { id: "BTC-CLP", base_currency: "BTC", quote_currency: "CLP" },
            { id: "BTC-PEN", base_currency: "BTC", quote_currency: "PEN" },
            { id: "BTC-COP", base_currency: "BTC", quote_currency: "COP" },
            { id: "ETH-CLP", base_currency: "ETH", quote_currency: "CLP" }
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
  end

  describe '.markets' do
    it 'fetches markets' do
      markets = BudaApiClient.markets
      expect(markets.length).to eq(4)
      expect(markets.first["id"]).to eq("BTC-CLP")
    end
  end

  describe '.ticker' do
    it 'fetches ticker' do
      ticker = BudaApiClient.ticker("btc-clp")
      expect(ticker["market_id"]).to eq("BTC-CLP")
      expect(ticker["last_price"][0]).to eq("1000000.0")
    end
  end

  describe '.available_markets' do
    it 'returns available markets' do
      markets = BudaApiClient.available_markets
      expect(markets.length).to eq(4)
      expect(markets).to include("BTC-CLP")
    end
  end

  describe '.available_cryptocurrencies' do
    it 'returns available cryptocurrencies' do
      cryptos = BudaApiClient.available_cryptocurrencies
      expect(cryptos.length).to eq(2)
      expect(cryptos).to include("BTC")
      expect(cryptos).to include("ETH")
    end
  end

  describe '.fiat_currencies' do
    it 'returns fiat currencies' do
      fiats = BudaApiClient.fiat_currencies
      expect(fiats.length).to eq(3)
      expect(fiats).to include("CLP")
      expect(fiats).to include("PEN")
      expect(fiats).to include("COP")
    end
  end
end
