# Service for interfacing with the Buda.com cryptocurrency exchange API
# Provides methods to fetch market data, tickers, and available currencies
module BudaApiClient
  class << self
    # Fetches all available markets from Buda.com
    #
    # @return [Array<Hash>] An array of market objects with the following keys:
    #   - id: The market identifier (e.g., "BTC-CLP")
    #   - base_currency: The cryptocurrency code (e.g., "BTC")
    #   - quote_currency: The fiat currency code (e.g., "CLP")
    def markets
      response = get_request('markets')
      response['markets']
    end

    # Fetches the current ticker information for a specific market
    #
    # @param [String] market_id The market identifier (e.g., "btc-clp")
    #
    # @return [Hash] The ticker data with the following keys:
    #   - last_price: An array containing [price, currency]
    #   - market_id: The market identifier
    def ticker(market_id)
      response = get_request("markets/#{market_id}/ticker")
      response['ticker']
    end

    # Returns a list of all available market identifiers
    #
    # @return [Array<String>] Array of market identifiers (e.g., ["BTC-CLP", "ETH-CLP"])
    def available_markets
      markets.map { |market| market['id'] }
    end

    # Returns a list of all available cryptocurrencies
    #
    # @return [Array<String>] Array of unique cryptocurrency codes (e.g., ["BTC", "ETH"])
    def available_cryptocurrencies
      markets.map { |market| market['base_currency'] }.uniq
    end

    # Returns the list of supported fiat currencies
    #
    # @return [Array<String>] Array of fiat currency codes (e.g., ["CLP", "PEN", "COP"])
    def fiat_currencies
      ['CLP', 'PEN', 'COP']
    end

    private

      # Makes a GET request to the Buda.com API
      #
      # @param [String] path The API endpoint path to request
      #
      # @return [Hash] The parsed JSON response
      # @raise [RuntimeError] If the API request fails
      def get_request(path)
        uri = URI("https://www.buda.com/api/v2/#{path}")
        response = Net::HTTP.get(uri)
        JSON.parse(response)
      rescue => e
        Rails.logger.error("Error fetching from Buda API: #{e.message}")
        raise "Failed to connect to Buda API: #{e.message}"
      end
    end
end
