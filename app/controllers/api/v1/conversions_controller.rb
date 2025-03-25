module Api
  module V1
    class ConversionsController < ApplicationController
      rescue_from StandardError, with: :render_error
      rescue_from ArgumentError, with: :render_bad_request

      # Converts an amount from one currency to another using the best available path
      #
      # @description This action receives source and target currencies along with an amount,
      #              and finds the best conversion path using cryptocurrencies as intermediaries.
      #
      # @param [String] source_currency The source currency code (CLP, PEN, COP)
      # @param [String] target_currency The target currency code (CLP, PEN, COP)
      # @param [String/Number] amount The amount to convert, expressed in the source currency
      #
      # @return [JSON] A JSON object containing:
      #   - source_currency: The source currency code
      #   - target_currency: The target currency code
      #   - source_amount: The original amount in source currency
      #   - target_amount: The converted amount in target currency
      #   - intermediary_currency: The cryptocurrency used as intermediary (nil if same currencies)
      def convert
        source_currency = params[:source_currency]&.upcase
        target_currency = params[:target_currency]&.upcase
        amount = params[:amount]

        validate_params(source_currency, target_currency, amount)

        result = CurrencyConverter.convert(source_currency, target_currency, amount)

        render json: {
          source_currency: source_currency,
          target_currency: target_currency,
          source_amount: amount.to_f,
          target_amount: result[:amount],
          intermediary_currency: result[:intermediary]
        }, status: :ok
      end

      private

        # Validates that all required parameters are present and correctly formatted
        #
        # @param [String] source_currency The source currency code to validate
        # @param [String] target_currency The target currency code to validate
        # @param [String/Number] amount The amount to validate
        #
        # @raises [ArgumentError] If any parameter is missing or invalid
        # @return [nil] If validation passes
        def validate_params(source_currency, target_currency, amount)
          if source_currency.blank? || target_currency.blank? || amount.blank?
            raise ArgumentError, "Missing required parameters: source_currency, target_currency, and amount are required"
          end

          unless amount.to_s.match?(/\A\d+(\.\d+)?\z/)
            raise ArgumentError, "Amount must be a valid number"
          end
        end

        # Renders a standardized error response for any unhandled exceptions
        #
        # @param [StandardError] error The error that was raised
        #
        # @return [JSON] A JSON object with an error message and 500 status code
        def render_error(error)
          Rails.logger.error("Error: #{error.message}")
          render json: { error: error.message }, status: :internal_server_error
        end

        # Renders a standardized error response for bad request errors
        #
        # @param [ArgumentError] error The error that was raised during parameter validation
        #
        # @return [JSON] A JSON object with an error message and 400 status code
        def render_bad_request(error)
          render json: { error: error.message }, status: :bad_request
        end
    end
  end
end
