# Crowise Crypto API, the best currency converter 🔥

A REST API that communicates with [Buda.com API](https://api.buda.com/#rest-api) to provide optimal currency conversion paths between different fiat currencies using cryptocurrencies as intermediaries.

## Live API

The API is deployed and available at: <https://crowise-crypto.fly.dev>

API Documentation (Swagger UI): <https://crowise-crypto.fly.dev/api-docs>

## Features

- Converts between CLP, PEN, and COP currencies using cryptocurrencies as intermediaries
- Automatically finds the best conversion rate by comparing available cryptocurrency markets
- Simple RESTful API with JSON responses
- Comprehensive API documentation with Swagger/OpenAPI
- Deployed on fly.io

## Requirements

- Ruby 3.4.2
- Rails 8.0.2

## Setup

### Local Development

1. Clone the repository:

   ```bash
   git clone https://github.com/crow-rojas/crowise-crypto.git
   cd crowise-crypto
   ```

2. Install dependencies:

   ```bash
   bundle install
   ```

3. Start the server:

   ```bash
   rails s
   ```

4. Access the API documentation at <http://localhost:3000/api-docs>.

### Docker Deployment

This project is hosted at [fly.io](https://fly.io/), so, with the Dockerfile already configured, the app is deployed automatically when you push to the repository.

## Testing

Run the test suite:

```bash
bundle exec rspec
```

## API Documentation

### Currency Conversion Endpoint

Convert an amount from one currency to another using the best available cryptocurrency as an intermediary.

**Endpoint:** `POST /api/v1/convert`

**Request Parameters:**

| Parameter        | Type    | Required | Description                          |
|------------------|---------|----------|--------------------------------------|
| source_currency  | String  | Yes      | Source currency code (CLP, PEN, COP) |
| target_currency  | String  | Yes      | Target currency code (CLP, PEN, COP) |
| amount           | Numeric | Yes      | Amount in source currency to convert |

**Example Request:**

```bash
curl -X POST https://crowise-crypto.fly.dev/api/v1/convert \
  -H "Content-Type: application/json" \
  -d '{"source_currency":"CLP","target_currency":"PEN","amount":10000}'
```

**Success Response (200 OK):**

```json
{
  "source_currency": "CLP",
  "target_currency": "PEN",
  "source_amount": 10000.0,
  "target_amount": 40.35,
  "intermediary_currency": "BTC"
}
```

**Error Response (400 Bad Request):**

```json
{
  "error": "Invalid source currency: XYZ. Valid options are: CLP, PEN, COP"
}
```

## Implementation Details

The currency conversion process works as follows:

1. The API receives a request with source currency, target currency, and amount
2. It validates that both currencies are supported
3. If both currencies are the same, it returns the original amount
4. Otherwise, it fetches all available cryptocurrency markets from Buda.com
5. For each cryptocurrency available:
   - It checks if markets exist for both source and target currency
   - It calculates the conversion rate through this cryptocurrency
   - It keeps track of the best conversion rate found
6. The API returns the converted amount and the cryptocurrency used as intermediary
