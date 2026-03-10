---
name: alerts
description: Create and manage price alerts for any token — get notified when a token's price goes above or below a target. Use this whenever someone wants to set a price alert, track token prices, get notified about price movements, or manage their existing alerts.
---

# Price Alerts

Create price alerts that trigger when a token's price crosses a target threshold. Alerts are stored locally at `~/.tw-agent/alerts.json` and checked against live prices from the Amber swap API.

## Actions

### Create Alert

Set a price alert for a token. Triggers when the current price goes above or below the target.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `tokenId` | string | Yes | Token ID (e.g., `c60` for ETH, `c60_t0xA0b8...` for ERC-20) |
| `chainKey` | string | Yes | Chain key (e.g., `ethereum`, `bsc`) |
| `condition` | string | Yes | `"above"` or `"below"` |
| `targetPrice` | number | Yes | Target price in USD (must be positive) |

**Example — alert when ETH goes above $2,500:**

```json
{
  "tokenId": "c60",
  "chainKey": "ethereum",
  "condition": "above",
  "targetPrice": 2500
}
```

**Response:**

```json
{
  "id": "a1b2c3d4",
  "message": "Alert created: notify when c60 goes above $2500"
}
```

**Example — alert when BNB drops below $500:**

```json
{
  "tokenId": "c714",
  "chainKey": "bsc",
  "condition": "below",
  "targetPrice": 500
}
```

---

### List Alerts

List all price alerts, optionally filtered to active only.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `activeOnly` | boolean | No | Only show active (untriggered) alerts (default: `false`) |

**Response:**

```json
{
  "alerts": [
    {
      "id": "a1b2c3d4",
      "tokenId": "c60",
      "chainKey": "ethereum",
      "condition": "above",
      "targetPrice": 2500,
      "active": true,
      "createdAt": "2026-03-10T12:00:00Z"
    },
    {
      "id": "e5f6g7h8",
      "tokenId": "c714",
      "chainKey": "bsc",
      "condition": "below",
      "targetPrice": 500,
      "active": false,
      "triggeredAt": "2026-03-11T08:30:00Z"
    }
  ],
  "count": 2
}
```

---

### Check Alerts

Check all active alerts against current live prices. Alerts that match their condition are triggered and deactivated.

**Parameters:** None

**Response:**

```json
{
  "checked": 3,
  "triggered": 1,
  "alerts": [
    {
      "id": "a1b2c3d4",
      "tokenId": "c60",
      "chainKey": "ethereum",
      "condition": "above",
      "targetPrice": 2500,
      "active": false,
      "triggeredAt": "2026-03-11T10:00:00Z"
    }
  ]
}
```

Prices are fetched from the Amber swap API (same source as `get_token_price`). Triggered alerts are automatically deactivated so they don't fire again.

---

### Delete Alert

Remove a price alert by ID.

**Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Alert ID to delete |

**Response:**

```json
{
  "success": true,
  "message": "Alert a1b2c3d4 deleted"
}
```

## Workflow

1. **Create** an alert with a target price and condition
2. **Check** alerts periodically (or use the CLI `tw-agent watch` command for continuous monitoring)
3. **List** alerts to see which are active and which have triggered
4. **Delete** alerts you no longer need
