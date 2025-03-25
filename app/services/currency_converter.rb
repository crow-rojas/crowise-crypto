require 'net/http'
require 'json'

# Service that handles currency conversion between fiat currencies 
# using cryptocurrencies as intermediaries
class CurrencyConverter
  class << self
    # Converts an amount from one fiat currency to another using cryptocurrencies as intermediaries
    #
    # This method finds the best conversion rate among all available cryptocurrencies
    # on Buda.com and returns the converted amount along with the intermediary used.
    #
    # @param [String] source_currency The source currency code (e.g., "CLP", "PEN", "COP")
    # @param [String] target_currency The target currency code (e.g., "CLP", "PEN", "COP")
    # @param [Numeric, String] amount The amount to convert in the source currency
    #
    # @return [Hash] A hash containing:
    #   - amount: [Float] The converted amount in the target currency
    #   - intermediary: [String, nil] The cryptocurrency used as intermediary, or nil if source and target are the same
    #
    # @raise [ArgumentError] If the source or target currency is invalid
    def convert(source_currency, target_currency, amount)
      validate_currencies(source_currency, target_currency)
      amount = amount.to_f

      return { amount: amount, intermediary: nil } if source_currency == target_currency

      cryptos = BudaApiClient.available_cryptocurrencies
      
      best_conversion = find_best_conversion(source_currency, target_currency, amount, cryptos)
      
      {
        amount: best_conversion[:amount],
        intermediary: best_conversion[:intermediary]
      }
    end

    private

    # Validates that both source and target currencies are supported
    #
    # @param [String] source_currency The source currency code to validate
    # @param [String] target_currency The target currency code to validate
    #
    # @raise [ArgumentError] If either currency is not in the list of supported fiat currencies
    def validate_currencies(source_currency, target_currency)
      valid_currencies = BudaApiClient.fiat_currencies
      
      unless valid_currencies.include?(source_currency)
        raise ArgumentError, "Invalid source currency: #{source_currency}. Valid options are: #{valid_currencies.join(', ')}"
      end
      
      unless valid_currencies.include?(target_currency)
        raise ArgumentError, "Invalid target currency: #{target_currency}. Valid options are: #{valid_currencies.join(', ')}"
      end
    end

    # Finds the best conversion path through available cryptocurrencies
    #
    # Tests all available cryptocurrencies as intermediaries and returns
    # the one that yields the highest converted amount.
    #
    # @param [String] source_currency The source currency code
    # @param [String] target_currency The target currency code
    # @param [Float] amount The amount to convert
    # @param [Array<String>] cryptos List of available cryptocurrencies to try as intermediaries
    #
    # @return [Hash] A hash containing:
    #   - amount: [Float] The best converted amount, rounded to 2 decimal places
    #   - intermediary: [String] The cryptocurrency that produced the best rate
    def find_best_conversion(source_currency, target_currency, amount, cryptos)
      best_amount = 0
      best_crypto = nil

      cryptos.each do |crypto|
        next unless market_exists?(crypto, source_currency) && market_exists?(crypto, target_currency)

        buy_market = "#{crypto}-#{source_currency}"
        sell_market = "#{crypto}-#{target_currency}"

        buy_ticker = BudaApiClient.ticker(buy_market.downcase)
        sell_ticker = BudaApiClient.ticker(sell_market.downcase)

        buy_price = buy_ticker['last_price'][0].to_f
        sell_price = sell_ticker['last_price'][0].to_f

        crypto_amount = amount / buy_price
        
        converted_amount = crypto_amount * sell_price

        if converted_amount > best_amount
          best_amount = converted_amount
          best_crypto = crypto
        end
      end

      { amount: best_amount.round(2), intermediary: best_crypto }
    end

    # Checks if a specific market exists on Buda.com
    #
    # @param [String] crypto The cryptocurrency code
    # @param [String] currency The fiat currency code
    #
    # @return [Boolean] True if the market exists, false otherwise
    def market_exists?(crypto, currency)
      market_id = "#{crypto}-#{currency}".downcase
      BudaApiClient.available_markets.map(&:downcase).include?(market_id)
    end
  end
end
