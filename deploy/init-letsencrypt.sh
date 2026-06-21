#!/bin/sh
# One-time Let's Encrypt bootstrap for api.refk.tech.
#
# Run this ONCE on the VPS, from the repo root, after DNS for api.refk.tech
# points at the server and the stack can bind :80 / :443:
#
#   sh deploy/init-letsencrypt.sh
#
# It places a throwaway self-signed cert so nginx can start, brings nginx up,
# then asks Certbot for the real certificate over the HTTP-01 challenge and
# reloads nginx. After this, the `certbot` service auto-renews.
set -e

DOMAIN="api.refk.tech"
EMAIL="${CERTBOT_EMAIL:-hafes44@gmail.com}"   # override: CERTBOT_EMAIL=you@x sh deploy/init-letsencrypt.sh
STAGING="${CERTBOT_STAGING:-0}"               # set to 1 to test against the LE staging CA first

COMPOSE="docker compose -f docker-compose.prod.yml"
LIVE_PATH="/etc/letsencrypt/live/$DOMAIN"

echo "### Creating a dummy certificate for $DOMAIN so nginx can boot ..."
$COMPOSE run --rm --entrypoint "/bin/sh -c '\
  mkdir -p $LIVE_PATH && \
  openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
    -keyout $LIVE_PATH/privkey.pem \
    -out $LIVE_PATH/fullchain.pem \
    -subj /CN=localhost'" certbot

echo "### Starting nginx ..."
$COMPOSE up -d nginx

echo "### Deleting dummy certificate ..."
$COMPOSE run --rm --entrypoint "/bin/sh -c 'rm -rf /etc/letsencrypt/live/$DOMAIN /etc/letsencrypt/archive/$DOMAIN /etc/letsencrypt/renewal/$DOMAIN.conf'" certbot

STAGING_ARG=""
if [ "$STAGING" != "0" ]; then
  STAGING_ARG="--staging"
fi

echo "### Requesting the real Let's Encrypt certificate for $DOMAIN ..."
$COMPOSE run --rm --entrypoint "certbot certonly --webroot -w /var/www/certbot \
  $STAGING_ARG \
  --email $EMAIL \
  -d $DOMAIN \
  --rsa-key-size 2048 \
  --agree-tos \
  --no-eff-email \
  --non-interactive \
  --force-renewal" certbot

echo "### Reloading nginx ..."
$COMPOSE exec nginx nginx -s reload

echo "### Done. https://$DOMAIN should now serve a valid certificate."
