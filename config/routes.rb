Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # API endpoints
  namespace :api do
    namespace :v1 do
      post "convert", to: "conversions#convert"
    end
  end

  # API Documentation with Swagger
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/swagger"
end
