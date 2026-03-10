---
name: transfer
description: Transfer tokens and native assets to any address with ENS name resolution, manage ERC-20 approvals, and check token allowances. Use this whenever someone wants to send crypto, transfer tokens, approve a spender, check allowances, or send to an ENS name like vitalik.eth.
---

# Transfers & Approvals

Transfer native assets and tokens to any address (including ENS names), manage ERC-20 token approvals, and check allowances.

## Actions

### Transfer Token

Transfer a native asset or token to a destination address. Supports ENS names (e.g., `vitalik.eth`) which are automatically resolved via the Trust Wallet naming service.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `assetId` | string | Yes | Token ID (e.g., `c60` for ETH, `c60_t0xA0b86991...` for USDC on Ethereum) |
| `to` | string | Yes | Destination address or ENS name |
| `amount` | string | Yes | Amount in smallest unit (wei, lamports, satoshis) |
| `memo` | string | No | Optional memo/note |

**Example — send 0.001 ETH to an ENS name:**

```json
{
  "assetId": "c60",
  "to": "vitalik.eth",
  "amount": "1000000000000000"
}
```

**Response:**

```json
{
  "hash": "0x2a37fcca21541021f3b4efd954992bcb9050d7a42bafbad309c6947ffdcebf4b",
  "chainKey": "ethereum",
  "to": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
  "resolvedFrom": "vitalik.eth"
}
```

The `resolvedFrom` field appears only when ENS resolution was performed.

### Asset ID Reference

| Asset | Asset ID |
|-------|----------|
| ETH (native) | `c60` |
| BNB (native) | `c714` |
| SOL (native) | `c501` |
| BTC (native) | `c0` |
| USDC on Ethereum | `c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` |
| USDT on Ethereum | `c60_t0xdAC17F958D2ee523a2206206994597C13D831ec7` |
| USDT on BSC | `c714_t0x55d398326f99059fF775485246999027B3197955` |

See [setup](../setup/SKILL.md) for the full asset ID format and chain list.

---

### Approve Token

Approve a spender to use tokens on your behalf (ERC-20 `approve`). Required before swapping ERC-20 tokens through a DEX router.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `assetId` | string | Yes | Token ID to approve (must be a token, not native) |
| `spender` | string | Yes | Spender contract address |
| `amount` | string | Yes | Amount to approve in smallest unit, or `"unlimited"` |

**Example — approve USDC for a DEX router:**

```json
{
  "assetId": "c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
  "spender": "0x3d90f66B534Dd8482b181e24655A9e8265316BE9",
  "amount": "unlimited"
}
```

**Response:**

```json
{
  "hash": "0xabc123...",
  "chainKey": "ethereum"
}
```

Using `"unlimited"` sets the max uint256 allowance. For better security, approve only the amount needed.

---

### Check Allowance

Check how much of a token a spender is approved to use.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `assetId` | string | Yes | Token ID to check |
| `owner` | string | Yes | Token owner address |
| `spender` | string | Yes | Spender address to check |

**Response:**

```json
{
  "assetId": "c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
  "owner": "0xD4BC...",
  "spender": "0x3d90...",
  "allowance": "1000000000"
}
```

Allowance is in the token's smallest unit. For USDC (6 decimals), `1000000000` = 1,000 USDC.

## Amount Conversion

Balances and amounts are always in the smallest unit:

| Token | Decimals | 1.0 in smallest unit |
|-------|----------|---------------------|
| ETH | 18 | `1000000000000000000` |
| BNB | 18 | `1000000000000000000` |
| USDC | 6 | `1000000` |
| USDT | 6 | `1000000` |
| SOL | 9 | `1000000000` |
| BTC | 8 | `100000000` |
