---
name: balance
description: Check native coin balances, token holdings, search for tokens, and get detailed asset information across any blockchain supported by Trust Wallet.
---

# Balance & Assets

Check wallet balances, token holdings, and search for assets across all supported chains.

**Base URL:** `https://gateway.us.trustwallet.com`
**Auth:** HMAC-SHA256 (see [setup](../setup/SKILL.md))

## Endpoints

### Get Native Balance

`POST /v1/balance`

Get the native coin balance for one or more addresses.

**Request body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `version` | number | Yes | API version, use `2` |
| `assets` | array | Yes | Array of `{ address, coin }` objects |
| `assets[].address` | string | Yes | Wallet address |
| `assets[].coin` | number | Yes | SLIP-44 coin ID (e.g., 60 for Ethereum, 714 for BSC) |

```json
{
  "version": 2,
  "assets": [
    { "address": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045", "coin": 60 }
  ]
}
```

**Response:**

```json
{
  "docs": [
    {
      "address": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
      "coin": 60,
      "balance": "1234567890000000000",
      "balanceUSD": "2345.67"
    }
  ]
}
```

The `balance` field is in the smallest unit (wei for Ethereum, lamports for Solana, satoshis for Bitcoin). Divide by `10^decimals` for the human-readable amount.

---

### Get Token Holdings

`POST /v1/assets`

Get all token holdings for an address on a specific chain.

**Request body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `version` | number | Yes | API version, use `2` |
| `includeDisabledAssets` | boolean | No | Include delisted tokens (default: `false`) |
| `assets` | array | Yes | Array of `{ address, coin }` objects |
| `assets[].address` | string | Yes | Wallet address |
| `assets[].coin` | number | Yes | SLIP-44 coin ID |

```json
{
  "version": 2,
  "includeDisabledAssets": false,
  "assets": [
    { "address": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045", "coin": 60 }
  ]
}
```

**Response:**

```json
{
  "docs": [
    {
      "asset_id": "c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
      "name": "USD Coin",
      "symbol": "USDC",
      "decimals": 6,
      "balance": "1000000000",
      "balanceUSD": "1000.00",
      "icon_url": "https://assets.trustwalletapp.com/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png"
    }
  ]
}
```

---

### Search Assets

`GET /v1/search/assets`

Search for tokens by name, symbol, or contract address.

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `query` | string | Yes | Search term (name, symbol, or address) |
| `type` | string | No | Filter type, use `all` (default) |
| `version` | string | No | API version, use `24` |
| `limit` | number | No | Max results (default: 10) |
| `networks` | string | No | Comma-separated SLIP-44 coin IDs to filter by chain |

**Example request:**

```
GET /v1/search/assets?query=USDC&type=all&version=24&limit=10&networks=60,714
```

**Response:**

```json
{
  "docs": [
    {
      "asset_id": "c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
      "name": "USD Coin",
      "symbol": "USDC",
      "decimals": 6,
      "icon_url": "https://assets.trustwalletapp.com/...",
      "price": {
        "price": 1.0,
        "percent_change_24h": 0.01
      }
    }
  ]
}
```

---

### Get Asset Info

`GET /v1/assets/{assetId}`

Get detailed information about a specific asset.

**Path parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `assetId` | string | Yes | Asset ID (e.g., `c60` for ETH, `c60_t0xA0b8...` for a token) |

**Example request:**

```
GET /v1/assets/c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
```

**Response:**

```json
{
  "asset_id": "c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
  "name": "USD Coin",
  "symbol": "USDC",
  "decimals": 6,
  "type": "ERC20",
  "website": "https://www.circle.com/usdc",
  "description": "USDC is a fully collateralized US dollar stablecoin.",
  "explorer_url": "https://etherscan.io/token/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
  "icon_url": "https://assets.trustwalletapp.com/...",
  "links": {
    "twitter": "https://twitter.com/circle",
    "telegram": "https://t.me/circle"
  }
}
```
