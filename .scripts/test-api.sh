#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:3000}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@thecardwalla.com}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-Admin@12345}"

USER_NAME="${USER_NAME:-Ahmed}"
USER_F_NAME="${USER_F_NAME:-Hassan}"
USER_EMAIL="${USER_EMAIL:-ahmed.media71@gmail.com}"
USER_PASSWORD="${USER_PASSWORD:-User@12345}"
USER_CONTACT="${USER_CONTACT:-03001234567}"
USER_DOB="${USER_DOB:-1999-01-01}"
USER_ADDRESS="${USER_ADDRESS:-Karachi}"
USER_CITY="${USER_CITY:-Karachi}"
USER_COUNTRY="${USER_COUNTRY:-Pakistan}"
USER_GENDER="${USER_GENDER:-1}"

ADMIN_TOKEN=""
USER_TOKEN=""
USER_ID=""
BLOCKED_USER_ID=""
OTP_CODE=""

line() {
  printf '\n==================================================\n'
}

step() {
  printf '\n[%s]\n' "$1"
}

show() {
  local method="$1"
  local url="$2"
  local data="${3:-}"
  echo
  echo ">>> ${method} ${url}"
  if [[ -n "$data" ]]; then
    echo ">>> BODY: $data"
  fi
}

req() {
  local method="$1"
  local url="$2"
  local data="${3:-}"
  local auth="${4:-}"

  show "$method" "$url" "$data"

  if [[ -n "$data" && -n "$auth" ]]; then
    curl -sS -X "$method" "$url" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $auth" \
      -d "$data"
  elif [[ -n "$data" ]]; then
    curl -sS -X "$method" "$url" \
      -H "Content-Type: application/json" \
      -d "$data"
  elif [[ -n "$auth" ]]; then
    curl -sS -X "$method" "$url" \
      -H "Authorization: Bearer $auth"
  else
    curl -sS -X "$method" "$url"
  fi

  echo
}

extract_json() {
  local expr="$1"
  python -c "import sys, json; data=json.load(sys.stdin); print($expr)"
}

line
step "1. Health Check"
req GET "$BASE_URL/health"

line
step "2. Admin Signin"
ADMIN_LOGIN_RESPONSE=$(
  curl -sS -X POST "$BASE_URL/api/auth/signin" \
    -H "Content-Type: application/json" \
    -d "{
      \"email\": \"$ADMIN_EMAIL\",
      \"password\": \"$ADMIN_PASSWORD\"
    }"
)
echo "$ADMIN_LOGIN_RESPONSE"
ADMIN_TOKEN=$(echo "$ADMIN_LOGIN_RESPONSE" | extract_json "data['data']['token']")
echo "ADMIN_TOKEN captured"

line
step "3. User Signup"
SIGNUP_RESPONSE=$(
  curl -sS -X POST "$BASE_URL/api/auth/signup" \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"$USER_NAME\",
      \"f_name\": \"$USER_F_NAME\",
      \"email\": \"$USER_EMAIL\",
      \"password\": \"$USER_PASSWORD\",
      \"contact\": \"$USER_CONTACT\",
      \"dob\": \"$USER_DOB\",
      \"address\": \"$USER_ADDRESS\",
      \"city\": \"$USER_CITY\",
      \"country\": \"$USER_COUNTRY\",
      \"gender\": $USER_GENDER
    }"
)
echo "$SIGNUP_RESPONSE"
USER_TOKEN=$(echo "$SIGNUP_RESPONSE" | extract_json "data['data']['token']")
USER_ID=$(echo "$SIGNUP_RESPONSE" | extract_json "data['data']['user']['id']")
echo "USER_TOKEN captured"
echo "USER_ID=$USER_ID"

line
step "4. User Signin"
req POST "$BASE_URL/api/auth/signin" "{
  \"email\": \"$USER_EMAIL\",
  \"password\": \"$USER_PASSWORD\"
}"

line
step "5. Get Own Profile"
req GET "$BASE_URL/api/users/me" "" "$USER_TOKEN"

line
step "6. Update Own Profile"
req PATCH "$BASE_URL/api/users/me" "{
  \"name\": \"Ahmed Updated\",
  \"city\": \"Lahore\",
  \"country\": \"Pakistan\"
}" "$USER_TOKEN"

line
step "7. Change Own Password"
req POST "$BASE_URL/api/auth/update-password" "{
  \"current_password\": \"$USER_PASSWORD\",
  \"new_password\": \"User@123456\"
}" "$USER_TOKEN"

USER_PASSWORD="User@123456"

line
step "8. Signin With New Password"
USER_LOGIN_RESPONSE=$(
  curl -sS -X POST "$BASE_URL/api/auth/signin" \
    -H "Content-Type: application/json" \
    -d "{
      \"email\": \"$USER_EMAIL\",
      \"password\": \"$USER_PASSWORD\"
    }"
)
echo "$USER_LOGIN_RESPONSE"
USER_TOKEN=$(echo "$USER_LOGIN_RESPONSE" | extract_json "data['data']['token']")
echo "USER_TOKEN refreshed"

line
step "9. Create Contact Us"
req POST "$BASE_URL/api/contact-us" "{
  \"name\": \"Test Contact\",
  \"email\": \"contact@example.com\",
  \"contact\": \"03009998888\",
  \"subject\": 4,
  \"message\": \"Need help with order details.\"
}"

line
step "10. Admin List Contact Us"
req GET "$BASE_URL/api/contact-us?limit=10&offset=0" "" "$ADMIN_TOKEN"

line
step "11. Create Sales Rows For Authenticated User"
req POST "$BASE_URL/api/sales" "{
  \"transaction\": \"TXN-10001\",
  \"items\": [
    { \"code\": \"A1\", \"count\": 1 },
    { \"code\": \"B2\", \"count\": 2 }
  ]
}" "$USER_TOKEN"

line
step "12. List My Sales"
req GET "$BASE_URL/api/sales?limit=10&offset=0" "" "$USER_TOKEN"

line
step "13. Admin List Users"
req GET "$BASE_URL/api/users?limit=10&offset=0" "" "$ADMIN_TOKEN"

line
step "14. Admin Get One User"
req GET "$BASE_URL/api/users/$USER_ID" "" "$ADMIN_TOKEN"

line
step "15. Admin Update User"
req PATCH "$BASE_URL/api/users/$USER_ID" "{
  \"city\": \"Islamabad\",
  \"status\": 1
}" "$ADMIN_TOKEN"

line
step "16. Admin Create Another User"
ADMIN_CREATE_RESPONSE=$(
  curl -sS -X POST "$BASE_URL/api/auth/users" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -d "{
      \"name\": \"Blocked\",
      \"f_name\": \"User\",
      \"email\": \"blocked.user@example.com\",
      \"password\": \"Blocked@123\",
      \"contact\": \"03112223333\",
      \"dob\": \"1998-01-01\",
      \"address\": \"Karachi\",
      \"city\": \"Karachi\",
      \"country\": \"Pakistan\",
      \"gender\": 1,
      \"role\": 1,
      \"status\": 1
    }"
)
echo "$ADMIN_CREATE_RESPONSE"
BLOCKED_USER_ID=$(echo "$ADMIN_CREATE_RESPONSE" | extract_json "data['data']['id']")
echo "BLOCKED_USER_ID=$BLOCKED_USER_ID"

line
step "17. Admin Block User"
req PATCH "$BASE_URL/api/auth/users/$BLOCKED_USER_ID/block" "{
  \"status\": 2
}" "$ADMIN_TOKEN"

line
step "18. Blocked User Signin Should Fail"
req POST "$BASE_URL/api/auth/signin" "{
  \"email\": \"blocked.user@example.com\",
  \"password\": \"Blocked@123\"
}"

line
step "19. Forgot Password Trigger"
req POST "$BASE_URL/api/auth/forgot-password" "{
  \"email\": \"$USER_EMAIL\"
}"

line
step "20. Manual OTP Step"
echo "Open your email inbox and copy the OTP."
read -r -p "Enter OTP for $USER_EMAIL: " OTP_CODE

line
step "21. Reset Password With OTP"
req POST "$BASE_URL/api/auth/reset-password" "{
  \"email\": \"$USER_EMAIL\",
  \"otp\": \"$OTP_CODE\",
  \"new_password\": \"User@99999\"
}"

USER_PASSWORD="User@99999"

line
step "22. Signin With Reset Password"
req POST "$BASE_URL/api/auth/signin" "{
  \"email\": \"$USER_EMAIL\",
  \"password\": \"$USER_PASSWORD\"
}"

line
step "23. Unauthorized Access Test"
req GET "$BASE_URL/api/users/me"

line
step "24. Rate Limit Probe On Signin"
for i in $(seq 1 6); do
  echo "Attempt $i"
  curl -sS -X POST "$BASE_URL/api/auth/signin" \
    -H "Content-Type: application/json" \
    -d "{
      \"email\": \"nobody@example.com\",
      \"password\": \"Wrong@123\"
    }"
  echo
done

line
step "Done"
echo "Smoke test completed."
