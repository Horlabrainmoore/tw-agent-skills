---
name: history
description: Get transaction history and details for any wallet address — transfers, swaps, approvals, and contract interactions across all supported chains.
---

# Transaction History

Query transaction history and get details for individual transactions.

**Base URL:** `https://gateway.us.trustwallet.com`
**Auth:** HMAC-SHA256 (see [setup](../setup/SKILL.md))

## Endpoints

### Get Transaction History

`GET /v1/txhub/txs`

Get paginated transaction history for a wallet address.

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `address` | string | Yes | Wallet address |
| `asset` | string | No | Filter by asset ID (e.g., `c60`, `c60_t0xA0b8...`) |
| `chain` | string | No | Filter by chain key (e.g., `ethereum`, `bsc`) |
| `from` | string | No | Start date (ISO 8601, e.g., `2026-01-01T00:00:00Z`) |
| `to` | string | No | End date (ISO 8601) |
| `limit` | number | No | Max results per page (default: 20) |
| `tx_type` | string | No | Filter by type: `transfer`, `swap`, `approve`, `contract_call` |

**Example request:**

```
GET /v1/txhub/txs?address=0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045&chain=ethereum&limit=10
```

**Response:**

```json
{
  "docs": [
    {
      "id": "tx-unique-id",
      "hash": "0xabc123...",
      "chain": "ethereum",
      "type": "transfer",
      "status": "completed",
      "from": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
      "to": "0xRecipient...",
      "amount": "1000000000000000000",
      "fee": "2100000000000000",
      "date": "2026-02-27T14:30:00Z",
      "metadata": {
        "asset_id": "c60",
        "symbol": "ETH",
        "decimals": 18,
        "name": "Ethereum"
      }
    }
  ]
}
```

**Transaction types:**

| Type | Description |
|------|-------------|
| `transfer` | Token or native coin transfer |
| `swap` | DEX swap |
| `approve` | ERC-20 token approval |
| `contract_call` | Generic smart contract interaction |

**Status values:** `completed`, `pending`, `failed`

---

### Get Transaction Details

`GET /v1/txhub/txs/{hash}`

Get detailed information about a specific transaction by its hash.

**Path parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `hash` | string | Yes | Transaction hash |

**Query parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `chain` | string | Yes | Chain key (e.g., `ethereum`, `bsc`, `solana`) |

**Example request:**

```
GET /v1/txhub/txs/0xabc123def456...?chain=ethereum
```

**Response:**

```json
{
  "id": "tx-unique-id",
  "hash": "0xabc123def456...",
  "chain": "ethereum",
  "type": "transfer",
  "status": "completed",
  "from": "0xSender...",
  "to": "0xRecipient...",
  "amount": "1000000000000000000",
  "fee": "2100000000000000",
  "date": "2026-02-27T14:30:00Z",
  "block_number": 19876543,
  "nonce": 42,
  "metadata": {
    "asset_id": "c60",
    "symbol": "ETH",
    "decimals": 18,
    "name": "Ethereum"
  }
}
```
