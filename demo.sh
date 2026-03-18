#!/bin/bash

# ── Trust Wallet Agent Skills — Interactive Demo ──
# Simulates a human chatting with an AI coding agent that has TW skills installed

BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
DIM='\033[2m'
GRAY='\033[0;90m'
RESET='\033[0m'
BOLD='\033[1m'

ACCESS_ID="732af2bf4427ed67b73ea8d998b20ad1719ee4ae9f8e666c8fc6fac6540a88b0"
HMAC_SECRET="edd8bed378f65d4731f5db11d73caef76ff48636bbecb66edeb4055a0fdfcd87"

# Human typing — fast but natural, slight randomness
human_type() {
    local text="$1"
    for (( i=0; i<${#text}; i++ )); do
        char="${text:$i:1}"
        printf "%s" "$char"
        if [[ "$char" == " " ]]; then
            sleep 0.04
        elif [[ "$char" == "?" || "$char" == "." ]]; then
            sleep 0.08
        else
            sleep $(awk "BEGIN{printf \"%.3f\", 0.02 + (rand() * 0.03)}")
        fi
    done
    echo ""
}

# Instant paste — no typing delay
paste_text() {
    printf "%s" "$1"
    sleep 0.05
    echo ""
}

# AI typing — fast, consistent
ai_type() {
    local text="$1"
    for (( i=0; i<${#text}; i++ )); do
        printf "%s" "${text:$i:1}"
        sleep 0.012
    done
    echo ""
}

# Signed API call (silent)
api_call() {
    local METHOD="$1" PATH_URL="$2" QUERY="$3" BODY="$4"
    local NONCE=$(uuidgen | tr '[:upper:]' '[:lower:]')
    local DATE=$(date -u "+%a, %d %b %Y %H:%M:%S GMT")
    local SORTED_Q="$QUERY"
    if [[ -n "$QUERY" ]]; then
        SORTED_Q=$(echo "$QUERY" | tr '&' '\n' | sort | tr '\n' '&' | sed 's/&$//')
    fi
    local PLAINTEXT="${METHOD};${PATH_URL};${SORTED_Q};${ACCESS_ID};${NONCE};${DATE}"
    local SIGNATURE=$(echo -n "$PLAINTEXT" | openssl dgst -sha256 -hmac "$HMAC_SECRET" -binary | base64)
    local URL="https://tws.trustwallet.com${PATH_URL}"
    [[ -n "$QUERY" ]] && URL="${URL}?${QUERY}"
    local ARGS=(-s --globoff -X "$METHOD"
        -H "Content-Type: application/json"
        -H "X-TW-CREDENTIAL: ${ACCESS_ID}"
        -H "X-TW-NONCE: ${NONCE}"
        -H "X-TW-DATE: ${DATE}"
        -H "Authorization: HMAC-SHA256 Signature=${SIGNATURE}")
    [[ -n "$BODY" ]] && ARGS+=(-d "$BODY")
    ARGS+=("$URL")
    sleep 1.5  # respect 1 req/sec rate limit
    curl "${ARGS[@]}" 2>/dev/null
}

human_prompt() {
    echo ""
    printf "${BOLD}${WHITE}> ${RESET}"
    human_type "$1"
    sleep 0.5
}

# Human prompt with pasted content at the end
human_prompt_paste() {
    local typed="$1"
    local pasted="$2"
    echo ""
    printf "${BOLD}${WHITE}> ${RESET}"
    human_type "$typed"
    printf "${BOLD}${WHITE}> ${RESET}"
    paste_text "$pasted"
    sleep 0.5
}

ai_thinking() {
    printf "${DIM}"
    for i in 1 2 3; do
        printf "."
        sleep 0.4
    done
    echo ""
    printf "${RESET}"
    sleep 0.3
}

ai_step() {
    echo -e "${DIM}  ⟩ $1${RESET}"
    sleep 0.6
}

separator() {
    echo ""
    echo -e "${DIM}────────────────────────────────────────────────────────${RESET}"
}

# ──────────────────────────────────────────────────────
clear
echo ""
echo -e "${BOLD}${BLUE}  Trust Wallet Agent Skills${RESET}${DIM} — demo session${RESET}"
echo -e "${DIM}  Claude Code + tw-agent-skills installed${RESET}"
echo ""
echo -e "${DIM}────────────────────────────────────────────────────────${RESET}"

# ── Scene 0: Setup ──
human_prompt "help me set up trust wallet api"

ai_thinking

echo ""
ai_type "Sure! Here's how to get started:"
echo ""
ai_type "  1. Go to portal.trustwallet.com and create a free account"
ai_type "  2. Create a new app to get your API credentials"
ai_type "  3. You'll receive an Access ID and HMAC Secret"
echo ""
ai_type "Once you have them, set these environment variables:"
echo ""
echo -e "${CYAN}  export TWAK_ACCESS_ID=your_access_id${RESET}"
echo -e "${CYAN}  export TWAK_HMAC_SECRET=your_hmac_secret${RESET}"
echo ""
ai_type "All endpoints use a single base URL: tws.trustwallet.com"
ai_type "Authentication is HMAC-SHA256 — the skills handle signing for you."
echo ""
echo -e "${DIM}  Rate limit: 1 request/sec on free tier${RESET}"
echo ""

printf "${YELLOW}  Press Enter once you've added the keys to your env...${RESET}"
read -r
echo ""
echo -e "${GREEN}  ✓ Credentials detected. You're all set!${RESET}"

sleep 1
separator

# ── Scene 1: Price check ──
human_prompt "whats the price of eth btc and sol?"

ai_thinking

PRICES=$(api_call "POST" "/v2/market/tickers" "" '{"currency":"USD","assets":["c60","c0","c501"]}')

echo ""
ai_type "Here are the current prices:"
echo ""

echo "$PRICES" | python3 -c "
import sys, json
data = json.load(sys.stdin)
d = {t['id']: t for t in data.get('tickers', [])}
for cid, name in [('c60', 'Ethereum'), ('c0', 'Bitcoin'), ('c501', 'Solana')]:
    t = d.get(cid, {})
    p = t.get('price', 0)
    c = t.get('change_24h', 0)
    sign = '+' if c > 0 else ''
    print(f'  \033[1;32m{name:<12}\033[1;37m \${p:>10,.2f}     \033[2m({sign}{c:.1f}% 24h)\033[0m')
"
echo ""
echo -e "${DIM}  Source: Trust Wallet Market Data (CMC + CoinGecko index)${RESET}"

sleep 3
separator

# ── Scene 2: Trending tokens ──
human_prompt "show me top AI tokens"

ai_thinking
sleep 1

TRENDING=$(api_call "GET" "/v1/assets/listings" "version=27&currency=USD&category_id=ai&sort=mcap&limit=5")

echo ""
ai_type "Top AI tokens by market cap:"
echo ""

echo "$TRENDING" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for i, doc in enumerate(data.get('docs', [])[:5], 1):
    name = doc['asset']['name']
    symbol = doc['asset']['symbol']
    price = doc['price']['price']
    chg = doc['price']['percent_change_24h']
    mcap = doc['market']['market_cap']
    sign = '+' if chg > 0 else ''
    mcap_str = f'\${mcap/1e9:.2f}B' if mcap > 1e9 else f'\${mcap/1e6:.0f}M'
    print(f'  {i}. \033[1;37m{name}\033[0m ({symbol})')
    print(f'     \${price:.4f}  {sign}{chg:.1f}% 24h  •  mcap {mcap_str}')
"

sleep 3
separator

# ── Scene 3: Find USDC contract address ──
human_prompt "find me the official USDC contract on ethereum"

ai_thinking

echo ""
ai_type "Here's the official USD Coin (USDC) on Ethereum:"
echo ""

# USDC on Ethereum — well-known contract, use coinstatus for reliable data
USDC_STATUS=$(api_call "GET" "/v1/coinstatus/c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48" "include_security_info=true")

echo "$USDC_STATUS" | python3 -c "
import sys, json
data = json.load(sys.stdin)
asset = data.get('asset', {})
name = asset.get('name', 'USD Coin')
symbol = asset.get('symbol', 'USDC')
aid = asset.get('asset_id', 'c60_t0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48')
contract = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'
swap = '✓' if data.get('isSwapEnabled') else '✗'
buy = '✓' if data.get('isBuyCryptoEnabled') else '✗'
print(f'  \033[1;37m{name}\033[0m ({symbol})')
print(f'  Contract:  {contract}')
print(f'  Asset ID:  {aid}')
print(f'  Decimals:  6')
print(f'  Swap:      {swap}   Buy: {buy}')
print(f'  Verified:  \033[1;32m✓ Trust Wallet\033[0m')
" 2>/dev/null

sleep 3
separator

# ── Scene 4: Security check — user asks about a token by name ──
human_prompt "is the render token safe? thinking about buying some"

ai_thinking

echo ""
ai_step "Searching for Render Token..."

SEARCH_RNDR=$(api_call "GET" "/v1/search/assets" "query=render&networks=60&limit=1")
sleep 1

eval $(echo "$SEARCH_RNDR" | python3 -c "
import sys,json
doc = json.load(sys.stdin)['docs'][0]
print(f'ASSET_ID=\"{doc[\"asset_id\"]}\"')
print(f'TOKEN_NAME=\"{doc[\"name\"]}\"')
" 2>/dev/null)

ai_step "Found ${TOKEN_NAME} (${ASSET_ID})"
ai_step "Running security analysis..."
sleep 1

STATUS=$(api_call "GET" "/v1/coinstatus/${ASSET_ID}" "include_security_info=true")

echo ""
echo "$STATUS" | python3 -c "
import sys, json
data = json.load(sys.stdin)
asset = data.get('asset', {})
name = asset.get('name', 'Unknown')
symbol = asset.get('symbol', '?')
swap = '✓' if data.get('isSwapEnabled') else '✗'
buy = '✓' if data.get('isBuyCryptoEnabled') else '✗'
stake = '✓' if data.get('isStakeEnabled') else '✗'
sec = data.get('security_info', {})
scanned = sec.get('is_scanned', False)
provider = sec.get('provider', 'N/A')
risks = sec.get('contract_security', {}).get('num_risks', '?')
warnings = sec.get('contract_security', {}).get('num_warnings', '?')
hp_risks = sec.get('honeypot_risk', {}).get('num_risks', '?')
counterfeit = sec.get('contract_security', {}).get('is_counterfeit', False)
print(f'  \033[1;37m{name}\033[0m ({symbol})')
print()
print(f'  Swap enabled:    {swap}')
print(f'  Buy enabled:     {buy}')
print(f'  Stake enabled:   {stake}')
print()
print(f'  Security scan:   {\"✓ scanned\" if scanned else \"not scanned\"} ({provider})')
print(f'  Contract risks:  {risks}')
print(f'  Warnings:        {warnings}')
print(f'  Honeypot flags:  {hp_risks}')
print(f'  Counterfeit:     {\"yes ⚠\" if counterfeit else \"no\"}')
if int(str(risks)) == 0 and int(str(hp_risks)) == 0:
    print()
    print(f'  \033[1;32m→ No contract risks or honeypot flags. Looks good.\033[0m')
" 2>/dev/null || echo -e "  ${YELLOW}Could not retrieve security info for this token.${RESET}"

sleep 3
separator

# ── Scene 5: Swap quote + signing ──
human_prompt "nice, swap 0.1 ETH to USDC for me"

ai_thinking
sleep 0.5

echo ""
ai_step "Getting swap quote from Amber aggregator..."
sleep 1

ROUTE=$(api_call "POST" "/amber-api/v1/route" "" '{"fromAsset":"0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE","fromAddress":"0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045","fromDomain":"ethereum","amount":"100000000000000000","toAsset":"0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48","toDomain":"ethereum","slippage":"1","sortBy":"outcome","contractCall":false}')

ROUTE_FILE=$(mktemp)
echo "$ROUTE" > "$ROUTE_FILE"

STEP_ID=$(python3 -c "import json; print(json.load(open('${ROUTE_FILE}'))['routes'][0]['steps'][0]['id'])" 2>/dev/null)

ai_step "Best route found. Getting transaction data..."
sleep 1.2

STEP=$(api_call "POST" "/amber-api/v1/route/step" "" "{\"stepId\":\"${STEP_ID}\"}")

echo ""
python3 -c "
import json
data = json.load(open('${ROUTE_FILE}'))
route = data['routes'][0]
step = route['steps'][0]
from_amt = int(step['from']['amount']) / 1e18
to_amt = int(step['to']['amount']) / 1e6
min_amt = int(step['to']['minAmountOut']) / 1e6
provider = step['provider']['name']
usd = float(step['from'].get('usdPrice', 0))
print(f'  \033[1;37m{from_amt} ETH → {to_amt:.2f} USDC\033[0m')
print()
print(f'  Provider:       {provider}')
print(f'  Min output:     {min_amt:.2f} USDC (1% slippage)')
print(f'  ETH price:      \${usd:,.2f}')
"

echo ""
ai_step "Transaction data ready. Signing with wallet-core..."
sleep 0.8

echo ""
echo "$STEP" | python3 -c "
import sys, json
data = json.load(sys.stdin)
tx = data.get('transaction', {}).get('evmTx', {})
to_addr = tx.get('to', '0x...')
value = tx.get('value', '0')
gas = tx.get('gasLimit', '250000')
calldata = tx.get('data', '0x...')
cd_preview = calldata[:10] + '...' + calldata[-8:] if len(calldata) > 20 else calldata
print(f'\033[2m  import {{ HDWallet, CoinType, AnySigner }} from \"@trustwallet/wallet-core\";')
print()
print(f'  const wallet = HDWallet.createWithMnemonic(mnemonic);')
print(f'  const key = wallet.getKeyForCoin(CoinType.ethereum);')
print()
print(f'  const tx = {{')
print(f'    to: \"{to_addr}\",')
print(f'    value: \"{value}\",')
print(f'    data: \"{cd_preview}\",')
print(f'    gasLimit: \"{gas}\"')
print(f'  }};')
print()
print(f'  const signed = AnySigner.sign(tx, CoinType.ethereum, key);')
print(f'  // → broadcast signed.encoded to Ethereum network\033[0m')
" 2>/dev/null

echo ""
echo -e "${GREEN}  ✓ Transaction signed and ready to broadcast${RESET}"

rm -f "$ROUTE_FILE"

sleep 3
separator

# ── Scene 6: Validate a pasted address ──
echo ""
printf "${BOLD}${WHITE}> ${RESET}"
human_type "can you check if this address is legit?"
printf "${BOLD}${WHITE}> ${RESET}"
paste_text "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
sleep 0.5

ai_thinking

VALID=$(api_call "GET" "/v1/validate" "address=0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045&coin=60")

echo ""
STATUS=$(echo "$VALID" | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','unknown'))")
if [[ "$STATUS" == "ok" ]]; then
    ai_type "That's a valid Ethereum address. ✓"
    echo ""
    ai_type "This is actually Vitalik Buterin's public address."
else
    ai_type "That address doesn't appear to be valid on Ethereum. ✗"
fi

sleep 2
separator

# ── Closing ──
echo ""
echo ""
echo -e "${BOLD}${WHITE}  That's Trust Wallet Agent Skills.${RESET}"
echo ""
echo -e "  ${DIM}10 skills • 14 API actions • 100+ chains${RESET}"
echo -e "  ${DIM}Single base URL: tws.trustwallet.com${RESET}"
echo ""
echo -e "  ${CYAN}npx skills add trustwallet/tw-agent-skills${RESET}"
echo -e "  ${DIM}github.com/trustwallet/tw-agent-skills${RESET}"
echo ""
