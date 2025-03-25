class WelcomeController < ApplicationController
  def index
    render json: {
      message: "Welcome to Crowise Crypto API! 🔥",
      description: "A REST API for optimal currency conversion using cryptocurrencies as intermediaries",
      documentation: "Please visit /api-docs for the full API documentation",
      endpoints: {
        api_docs: "#{request.base_url}/api-docs",
        conversion_api: "#{request.base_url}/api/v1/convert"
      }
    }
  end
end
