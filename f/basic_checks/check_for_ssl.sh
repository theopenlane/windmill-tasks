# shellcheck shell=bash
# arguments of the form X="$I" are parsed as parameters X of type string
DOMAIN="$1"
PORT="${2:-443}"

if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <domain> [port]"
  exit 1
fi

echo "Checking SSL certificate for $DOMAIN on port $PORT..."

EXPIRY_DATE=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:$PORT" 2>/dev/null \
  | openssl x509 -noout -enddate \
  | cut -d= -f2)

if [ -z "$EXPIRY_DATE" ]; then
  echo "❌ Failed to retrieve certificate expiration date."
  exit 1
fi

EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))

echo "Certificate expires on: $EXPIRY_DATE"
echo "Days remaining: $DAYS_LEFT"

if [ "$DAYS_LEFT" -lt 0 ]; then
  echo "❌ Error: Certificate has already expired!"
  exit 1
elif [ "$DAYS_LEFT" -lt 30 ]; then
  echo "⚠️  Warning: Certificate expires in less than 30 days!"
fi

exit 0